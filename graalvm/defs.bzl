load("//graalvm/rules/graalvm_compiler_toolchain:defs.bzl",
     _graalvm_compiler_toolchain = "graalvm_compiler_toolchain")
load("//graalvm/rules/graalvm_runtime_toolchain:defs.bzl",
     _graalvm_runtime_toolchain = "graalvm_runtime_toolchain")
load("//graalvm/rules/graalvm_java_test:defs.bzl",
     _graalvm_java_test = "graalvm_java_test")
load("//graalvm/rules/graalvm_truffle_instrument:defs.bzl",
     _graalvm_truffle_instrument = "graalvm_truffle_instrument")

graalvm_compiler_toolchain = _graalvm_compiler_toolchain

graalvm_runtime_toolchain = _graalvm_runtime_toolchain

graalvm_java_test = _graalvm_java_test

graalvm_truffle_instrument = _graalvm_truffle_instrument