JAVA_TEST_SCRIPT_TEMPLATE = "//graalvm/rules/graalvm_java_test:graalvm_java_test_script.sh.template"

def _graalvm_java_test_impl(ctx):
    java = ctx.toolchains["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"].graalvm_runtime_toolchain_info.graalvm_java_executable

    # TODO(dwtj): Not yet implemented. Always just prints VM version.
    script = ctx.actions.declare_file(ctx.attr.name + ".graalvm_java_test_script.sh")
    ctx.actions.expand_template(
        output = script,
        template = ctx.file._test_script_template,
        substitutions = {
            "{GRAALVM_JAVA_EXECUTABLE}": java.path,
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        files = [java],
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
        "_test_script_template": attr.label(
            allow_single_file = True,
            # TODO(dwtj): Maybe get the test script template from the toolchain.
            default = Label(JAVA_TEST_SCRIPT_TEMPLATE),
        ),
    },
    test = True,
    toolchains = ["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"],
)
