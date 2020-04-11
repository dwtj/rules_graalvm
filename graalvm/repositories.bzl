load("@rules_graalvm//graalvm/repositories:known_graalvm_repositories.bzl", "fetch_known_graalvm_repositories")

def rules_graalvm_dependencies():
    fetch_known_graalvm_repositories()

def rules_graalvm_toolchains():
    native.register_toolchains("@rules_graalvm//graalvm/toolchains/remote/linux/x86_64:graalvm_runtime_toolchain")
    native.register_toolchains("@rules_graalvm//graalvm/toolchains/remote/linux/x86_64:graalvm_compiler_toolchain")
