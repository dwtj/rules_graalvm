TEST_SCRIPT_TEMPLATE = "//graalvm/rules/test:test_script.sh.template"

def _graalvm_test_impl(ctx):
    graalvm_executable = ctx.toolchains["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"].graalvm_runtime_toolchain_info.graalvm_executable

    # TODO(dwtj): Not yet implemented. Always just prints VM version.
    test_script = ctx.actions.declare_file(ctx.attr.name + "_test_script.sh")
    ctx.actions.expand_template(
        output = test_script,
        template = ctx.file._test_script_template,
        substitutions = {
            "{GRAALVM_EXECUTABLE}": graalvm_executable.path
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        files = [graalvm_executable],
        # TODO(dwtj): carry forward needed transitive runfiles
        #transitive_files = ctx.attr.something[SomeProviderInfo].depset_of_files,
    )
    return DefaultInfo(executable = test_script, runfiles = runfiles)

graalvm_test = rule(
    implementation = _graalvm_test_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "_test_script_template": attr.label(
            allow_single_file = True,
            # TODO(dwtj): Maybe get the test script template from the toolchain.
            default = Label(TEST_SCRIPT_TEMPLATE),
        ),
    },
    test = True,
    toolchains = ["@rules_graalvm//graalvm/toolchains/runtime:toolchain_type"],
)
