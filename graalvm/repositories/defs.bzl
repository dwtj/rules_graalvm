load("@rules_java//java:defs.bzl",
     "java_library",
     "java_import",
     "java_plugin",
)

load("@rules_graalvm//graalvm:defs.bzl",
     "graalvm_runtime_toolchain",
     "graalvm_compiler_toolchain",
)

_KNOWN_GRAALVM_TRUFFLE_PROCESSORS = [
    {
        "target_name": "_TruffleProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.TruffleProcessor",
    },
    {
        "target_name": "_VerifyTruffleProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.verify.VerifyTruffleProcessor",
    },
    {
        "target_name": "_LanguageRegistrationProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.LanguageRegistrationProcessor",
    },
    {
        "target_name": "_InstrumentRegistrationProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.InstrumentRegistrationProcessor",
    },
    {
        "target_name": "_InstrumentableProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.InstrumentableProcessor",
    },
    {
        "target_name": "_VerifyCompilationFinalProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.verify.VerifyCompilationFinalProcessor",
    },
    {
        "target_name": "_OptionProcessor",
        "processor_class": "com.oracle.truffle.dsl.processor.OptionProcessor",
    },
]

def _truffle_dsl_processor(name, processor_class):
    '''Declare `processor_class` as proc in `:graalvm_truffle_dsl_processor_jar`.

    This macro declares a `java_plugin` instance with the given name and
    `//visibility:private` (i.e. package-local).
    '''
    java_plugin(
        name = name,
        processor_class = processor_class,
        deps = [":graalvm_truffle_dsl_processor_jar"],
        visibility = ["//visibility:private"],
    )

def _configure_truffle_api(truffle_api_jar):
    java_import(
        name = "graalvm_truffle_api",
        jars = [truffle_api_jar],
        visibility = ["//visibility:public"],
    )

def _configure_truffle_dsl_processor(truffle_dsl_processor_jar):
    """Declares the `:graalvm_truffle_dsl_processor` `java_library` instance.

    NB(dwtj): We provide `:graalvm_truffle_dsl_processor` to clients who want to
    use GraalVM's `com.oracle.truffle.dsl.processor` package. Because clients
    want these annotation processors to actually run on their code, we can't
    just wrap a JAR file with a `java_import`.

    This is complicated by the fact that the `com.oracle.truffle.dsl.processor`
    package includes a number of annotation processors. (See [1] for a list.) I
    believe that Bazel's current Java rules ignore a JAR file's
    `META-INF/services/javax.annotation.processing.Processor` file. We instead
    need to declare some `java_plugin` rule instances.

    Specifically, we declare one `java_plugin` rule instance for each annotation
    processor. By listing these `java_plugin` instances in the
    `exported_plugins` attribute of the `:graalvm_truffle_dsl_processor`, these
    annotation processors are enabled in Java rules which depend upon
    `:graalvm_truffle_dsl_processor`.

    [1](https://github.com/oracle/graal/blob/022fcbd2479944aeb411f851dc2cb062b1bbb441/truffle/src/com.oracle.truffle.dsl.processor/src/META-INF/services/javax.annotation.processing.Processor)
    """

    java_import(
        name = "graalvm_truffle_dsl_processor_jar",
        jars = [truffle_dsl_processor_jar],
        visibility = ["//visibility:private"],
    )

    for proc in _KNOWN_GRAALVM_TRUFFLE_PROCESSORS:
        _truffle_dsl_processor(
            name = proc["target_name"],
            processor_class = proc["processor_class"]
        )

    # Prefix a colon to each annotation processor's name:
    exported_plugins = [
        ":" + proc["target_name"] for proc in _KNOWN_GRAALVM_TRUFFLE_PROCESSORS
    ]

    java_library(
        name = "graalvm_truffle_dsl_processor",
        exports = [":graalvm_truffle_dsl_processor_jar"],
        exported_plugins = exported_plugins,
        visibility = ["//visibility:public"],
    )

def _configure_compiler_toolchain(srcs):
    graalvm_compiler_toolchain(
        name = "graalvm_compiler_toolchain",
        graalvm_truffle_api = ":graalvm_truffle_api",
    )

def _configure_runtime_toolchain(srcs, graalvm_java_executable):
    graalvm_runtime_toolchain(
        name = "graalvm_runtime_toolchain",
        graalvm_java_executable = graalvm_java_executable,
        srcs = srcs,
    )

def default_graalvm_repository(
    srcs,
    graalvm_java_executable = "//:bin/java",
    truffle_api_jar = "//:lib/truffle/truffle-api.jar",
    truffle_dsl_processor_jar = "//:lib/truffle/truffle-dsl-processor.jar",
    # TODO(dwtj): Import Graal SDK. (See `//:jmods/org.graalvm.sdk.jmod`)
    ):
    """Used to declare that a GraalVM repository provides some definitions.

    This function is meant to be called as a workspace rule from the root
    `BUILD.bazel` file of a GraalVM CE external repository. For example, this
    is called from `graalvm_linux_x86_64.BUILD.bazel`, the `build_file` for
    the `@graalvm_linux_x86_64` external workspace. By calling this function
    in this way, certain toolchains and other rule instances are declared within
    an external repository.

    For example, in the context of `@graalvm_linux_x86_64`, this function is
    used to declare:

    - `@graalvm_linux_x86_64//:graalvm_runtime_toolchain`.
    - `@graalvm_linux_x86_64//:graalvm_compiler_toolchain`.
    - `@graalvm_linux_x86_64//:graalvm_truffle_api`
    - `@graalvm_linux_x86_64//:graalvm_truffle_dsl_processor`
    """
    _configure_truffle_api(truffle_api_jar)
    _configure_truffle_dsl_processor(truffle_dsl_processor_jar)
    _configure_compiler_toolchain(srcs)
    _configure_runtime_toolchain(srcs, graalvm_java_executable)

