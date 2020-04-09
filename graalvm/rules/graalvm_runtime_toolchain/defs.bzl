GraalVmRuntimeToolchainInfo = provider(
    doc = "Information about how to invoke the GraalVM.",
    fields = [
        "graalvm_java_test_script_template",
        "graalvm_java_executable",
    ],
)

def _graalvm_runtime_toolchain_impl(ctx):
    """Copy rule instance attributes over to `GraalVmRuntimeToolchainInfo`.
    """
    toolchain_info = platform_common.ToolchainInfo(
        graalvm_runtime_toolchain_info = GraalVmRuntimeToolchainInfo(
            graalvm_java_executable = ctx.file.graalvm_java_executable,
            graalvm_java_test_script_template = ctx.file.graalvm_java_test_script_template,
        ),
    )
    return [toolchain_info]

graalvm_runtime_toolchain = rule(
    implementation = _graalvm_runtime_toolchain_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "graalvm_java_executable": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
        "graalvm_java_test_script_template": attr.label(
            allow_single_file = True,
            default = "//graalvm/rules/graalvm_runtime_toolchain/default_templates:graalvm_java_test.sh.template"
        )
    },
)
