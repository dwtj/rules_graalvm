"""Defines and implements the `graalvm_java_test` rule.

Also defines a few private helper functions to support this rule.
"""

load("//graalvm/rules/graalvm_truffle_instrument:defs.bzl",
     "GraalVmTruffleInstrumentInfo",
)

def _to_short_path(classpath_item):
    """Used as a map function to convert a file to its short path.
    """
    return classpath_item.short_path

def _depset_of_runtime_classpaths_from_java_infos(java_infos):
    """Returns a depset of all runtime classpaths of given `JavaInfo`s.
    """
    return depset(
        transitive = [java_info.compilation_info.runtime_classpath for java_info in java_infos]
    )

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
    `DefaultInfo.executable`. In a sense, it seems that Bazel's execution phase
    is used to build test artifacts and a later phase (call it the testing
    phase) is used to run these test artifacts. In retrospect, I might have
    gleaned this by reading the documentation more closely:
    [Executable Rules and Test Rules](https://docs.bazel.build/versions/3.0.0/skylark/rules.html#executable-rules-and-test-rules),
    """

    # TODO(dwtj): The classpath separator is ; on Windows.
    UNIX_LIKE_CLASSPATH_SEPARATOR = ":"

    # Build a list of `JavaInfo` objects, one from each direct Java dependency.
    # Then convert it to a depset.
    java_deps_runtime_classpath = _depset_of_runtime_classpaths_from_java_infos(
        [dep[JavaInfo] for dep in ctx.attr.java_deps]
    )

    # Build a list of `JavaInfo` objects, one from each Truffle Instrument. Then
    # convert it to a depset.
    # TODO(dwtj): A truffle instrument was very likely built with `truffle-api`
    #  a dependency. Currently, this will be included in this list. But surely
    #  the GraalVM brings its own implementation of the classes in this API. I
    #  suspect that we shouldn't append the user's copy of `truffle-api` to the
    #  truffle classpath. So, we ought to filter somehow.
    truffle_runtime_classpath = _depset_of_runtime_classpaths_from_java_infos(
        [dep[GraalVmTruffleInstrumentInfo].java_library[JavaInfo] for dep in ctx.attr.truffle_instruments]
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

    # If there are any truffle instruments, append each to the truffle classpath.
    args.add_joined(
        truffle_runtime_classpath,
        join_with = UNIX_LIKE_CLASSPATH_SEPARATOR,
        omit_if_empty = True,
        format_joined = "-Dtruffle.class.path.append=%s",
        map_each = _to_short_path,
    )

    # If there are any runtime java dependencies, append each to the classpath.
    args.add_joined(
        "-classpath",
        java_deps_runtime_classpath,
        join_with = UNIX_LIKE_CLASSPATH_SEPARATOR,
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

    # Merge the truffle classpath with the normal Java one. All files from both
    # are needed at runtime.
    runfiles_depset = depset (
        transitive = [truffle_runtime_classpath, java_deps_runtime_classpath],
    )

    # Build the set of files needed at runtime:
    runfiles = ctx.runfiles(
        files = [
            java,
            args_file,
        ],
        transitive_files = runfiles_depset,
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
