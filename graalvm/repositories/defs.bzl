load("@rules_graalvm//graalvm:defs.bzl", "graalvm_runtime_toolchain")

def default_graalvm_repository():
    graalvm_runtime_toolchain(
        name = "graalvm_runtime_toolchain",
        graalvm_java_executable = "//:bin/java",
    )
