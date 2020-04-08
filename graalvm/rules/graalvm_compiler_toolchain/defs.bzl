GraalVmCompilerToolchainInfo = provider(
    doc = "Information about how to invoke the GraalVM.",
    fields = ["graalvm_graalvm_truffle_api"],
)

def _graalvm_compiler_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        graalvm_compiler_toolchain_info = GraalVmCompilerToolchainInfo(
            graalvm_graalvm_truffle_api = ctx.attr.graalvm_truffle_api,
        ),
    )
    return [toolchain_info]

graalvm_compiler_toolchain = rule(
    implementation = _graalvm_compiler_toolchain_impl,
    attrs = {
        "graalvm_truffle_api": attr.label(
            allow_single_file = True,
            providers = [JavaInfo],
            mandatory = True,
            # TODO(dwtj): Maybe set a default.
        ),
    },
)
