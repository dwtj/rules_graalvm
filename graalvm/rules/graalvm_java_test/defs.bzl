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
    toolchain_type = "@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"
    toolchain_info = ctx.toolchains[toolchain_type].graalvm_runtime_toolchain_info

    java = toolchain_info.graalvm_java_executable
    template = toolchain_info.graalvm_java_test_script_template

    script = ctx.actions.declare_file(ctx.attr.name + ".graalvm_java_test.sh")
    args_file = ctx.actions.declare_file(ctx.attr.name + ".graalvm_java_test.args")

    ctx.actions.expand_template(
        output = script,
        template = template,
        substitutions = {
            "{GRAALVM_JAVA_EXECUTABLE}": java.path,
            "{ARGUMENTS_FILE}": args_file.short_path,
        },
        is_executable = True,
    )

    # Build an arguments list.
    args = ctx.actions.args()
    # TODO(dwtj): Everything!
    args.add("-version")

    ctx.actions.write(
        output = args_file,
        content = args,
        is_executable = False,
    )

    runfiles = ctx.runfiles(
        files = [
            java,
            args_file,
        ],
        # TODO(dwtj): carry forward needed transitive runfiles
        #transitive_files = ctx.attr.something[SomeProviderInfo].depset_of_files,
    )
    return DefaultInfo(executable = script, runfiles = runfiles)

graalvm_java_test = rule(
    implementation = _graalvm_java_test_impl,
    attrs = {
        "java_binary": attr.label(
            mandatory = True,
            providers = [JavaInfo]
        ),
    },
    test = True,
    toolchains = ["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"],
)
