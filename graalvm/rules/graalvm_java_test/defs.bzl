load("//graalvm/rules/graalvm_truffle_instrument:defs.bzl",
     "GraalVmTruffleInstrumentInfo",
)

def _to_short_path(classpath_item):
    """Used as a map function to convert a file to its short path.
    """
    return classpath_item.short_path


def _graalvm_java_test_impl(ctx):
    """Write a test script and declare it to be this rule instance's executable.

    During the execution phase (i.e. when Bazel preforms the `ctx.actions`
    emitted below), we construct a test script for this `graalvm_java_test` rule
    instance. This test script is designed to execute a `java_test` on a GraalVM
    `java` executable.

    This newly created test script is set as this `graalvm_java_test` instance's
    executable by setting `executable = script` in the returned `DefaultInfo`
    provider.

    LessonLearned(dwtj): While drafting this rule, I was somewhat confused
    about how to ensure that bazel runs your test. I thought that the test
    should be run with an explicit `ctx.action` call. However, I've learned
    that tests themselves (i.e. what you actually want to execute when you
    invoke `bazel test ...`) don't have an explicit `ctx.action`. One just
    assigns a newly created executable build artifact (e.g. `script`) to
    `DefaultInfo.executable`. In a sense, it seems that the execution phase
    is used to build test artifacts and a later phase (call it the testing
    phase) is used to run these test artifacts.

    [Bazel Docs: Executable Rules and Test Rules](https://docs.bazel.build/versions/3.0.0/skylark/rules.html#executable-rules-and-test-rules),
    """
    # TODO(dwtj): Use TruffleInstruments

    # Build classpath depset:
    # TODO(dwtj): Re-implement this using `java_common.merge()`
    runtime_classpath = depset(
        transitive = [dep[JavaInfo].compilation_info.runtime_classpath for dep in ctx.attr.java_deps]
    )

    # Declare a file to hold all `java` command arguments.
    args_file = ctx.actions.declare_file(ctx.attr.name + ".graalvm_java_test.args")

    # Use toolchain info to declare and write a test script
    toolchain_type = "@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"
    toolchain_info = ctx.toolchains[toolchain_type].graalvm_runtime_toolchain_info

    java = toolchain_info.graalvm_java_executable
    template = toolchain_info.graalvm_java_test_script_template

    script = ctx.actions.declare_file(ctx.attr.name + ".graalvm_java_test.sh")

    ctx.actions.expand_template(
        output = script,
        template = template,
        substitutions = {
            "{GRAALVM_JAVA_EXECUTABLE}": java.path,
            "{GRAALVM_JAVA_ARGUMENTS_FILE}": args_file.short_path,
        },
        is_executable = True,
    )

    # Build an arguments list to write to the arguments file.
    args = ctx.actions.args()

    # Add classpath:
    args.add_joined(
        "-classpath",
        runtime_classpath,
        # TODO(dwtj): The classpath separator is ; on Windows.
        join_with = ":",
        omit_if_empty = True,
        map_each = _to_short_path,
    )

    # Add main class specifier:
    # TODO(dwtj): Validate the `main_class` attribute.
    args.add(ctx.attr.main_class)

    # Write the args file:
    ctx.actions.write(
        output = args_file,
        content = args,
        is_executable = False,
    )

    # Build the set of files needed at runtime:
    runfiles = ctx.runfiles(
        files = [
            java,
            args_file,
        ],
        transitive_files = runtime_classpath,
    )

    return DefaultInfo(executable = script, runfiles = runfiles)

graalvm_java_test = rule(
    implementation = _graalvm_java_test_impl,
    attrs = {
        "main_class": attr.string(
            mandatory = True,
        ),
        "java_deps": attr.label_list(
            providers = [JavaInfo]
        ),
        "truffle_instruments": attr.label_list(
            providers = [GraalVmTruffleInstrumentInfo],
        )
    },
    test = True,
    toolchains = ["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"],
)
