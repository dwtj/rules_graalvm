load("@rules_graalvm//graalvm:defs.bzl", "graalvm_runtime_toolchain")

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

    graalvm_runtime_toolchain(
        name = "graalvm_runtime_toolchain",
        graalvm_java_executable = "//:bin/java",
        srcs = srcs,
    )
