load("@rules_java//java:defs.bzl",
     "java_import",
)

load("@rules_graalvm//graalvm:defs.bzl",
     "graalvm_runtime_toolchain",
     "graalvm_compiler_toolchain",
)

def _configure_compiler_toolchain(srcs):
    java_import(
        name = "truffle_api",
        jars = ["//:lib/truffle/truffle-api.jar"],
    )
    graalvm_compiler_toolchain(
        name = "graalvm_compiler_toolchain",
        graalvm_truffle_api = ":truffle_api",
    )

def _configure_runtime_toolchain(srcs):
    graalvm_runtime_toolchain(
        name = "graalvm_runtime_toolchain",
        graalvm_java_executable = "//:bin/java",
        srcs = srcs,
    )

def default_graalvm_repository(srcs):
    """Used to declare that a GraalVM repository provides some toolchains.

    This function is meant to be called as a workspace rule from the root
    `BUILD.bazel` file of a GraalVM CE external repository. For example, this
    is called from `graalvm_linux_x86_64.BUILD.bazel`, the `build_file` for
    the `@graalvm_linux_x86_64` external workspace. By calling this function
    in this way, certain toolchains are declared within an external
    repository. For example, this function is used to declare
    `@graalvm_linux_x86_64//:graalvm_runtime_toolchain`.
    """
    _configure_compiler_toolchain(srcs)
    _configure_runtime_toolchain(srcs)

