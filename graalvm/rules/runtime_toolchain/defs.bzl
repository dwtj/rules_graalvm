GraalVmRuntimeToolchainInfo = provider(
    doc = "Information about how to invoke the GraalVM.",
    fields = ["graalvm_executable"],
)

def _graalvm_runtime_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        graalvm_runtime_toolchain_info = GraalVmRuntimeToolchainInfo(
            graalvm_executable = ctx.file.graalvm_executable,
        ),
    )
    return [toolchain_info]

graalvm_runtime_toolchain = rule(
    implementation = _graalvm_runtime_toolchain_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "graalvm_executable": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
    },
)
