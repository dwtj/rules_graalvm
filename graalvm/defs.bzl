load("//graalvm/rules/runtime_toolchain:defs.bzl",
     _graalvm_runtime_toolchain = "graalvm_runtime_toolchain")
load("//graalvm/rules/java_test:defs.bzl",
     _graalvm_java_test = "graalvm_java_test")

graalvm_runtime_toolchain = _graalvm_runtime_toolchain

graalvm_java_test = _graalvm_java_test
