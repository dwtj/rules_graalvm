load("//graalvm/rules/runtime_toolchain:defs.bzl",
     _graalvm_runtime_toolchain = "graalvm_runtime_toolchain")
load("//graalvm/rules/test:defs.bzl",
     _graalvm_test = "graalvm_test")

graalvm_runtime_toolchain = _graalvm_runtime_toolchain

graalvm_test = _graalvm_test