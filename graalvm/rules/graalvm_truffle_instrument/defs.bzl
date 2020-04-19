GraalVmTruffleInstrumentInfo = provider(
    doc = "Information about a GraalVM Truffle Instrument.",
    fields = [
        "java_library",
    ],
)

def _graalvm_truffle_instrument_impl(ctx):
    return GraalVmTruffleInstrumentInfo(
        java_library = ctx.attr.java_library
    )

graalvm_truffle_instrument = rule(
    implementation = _graalvm_truffle_instrument_impl,
    attrs = {
        "java_library": attr.label(
            providers = [JavaInfo],
        ),
    },
)