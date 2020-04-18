GraalVmCompilerToolchainInfo = provider(
    doc = "Information about how to invoke the GraalVM.",
    fields = [
        "graalvm_javac_executable",
    ],
)

def _graalvm_compiler_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        graalvm_compiler_toolchain_info = GraalVmCompilerToolchainInfo(
            graalvm_javac_executable = ctx.file.graalvm_javac_executable,
        ),
    )
    return [toolchain_info]

graalvm_compiler_toolchain = rule(
    implementation = _graalvm_compiler_toolchain_impl,
    attrs = {
        "graalvm_javac_executable": attr.label(
            allow_single_file = True,
            mandatory = True,
        )
    },
)
