GraalVmTruffleInstrumentInfo = provider(
    doc = "Information about a GraalVM Truffle Instrument.",
    fields = [
        "java_library",
    ],
)

def _graalvm_truffle_instrument_impl(ctx):
    # TODO(dwtj): Maybe figure out a way to validate whether the given java
    #  library includes exactly one truffle instrument.
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