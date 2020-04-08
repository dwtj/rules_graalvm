load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def fetch_known_graalvm_releases():
    maybe(
        http_archive,
        name = "graalvm_linux_x86_64",
        sha256 = "d16c4a340a4619d98936754caeb6f49ee7a61d809c5a270e192b91cbc474c726",
        url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz",
        build_file = "@rules_graalvm//graalvm/repositories:graalvm_linux_x86_64.BUILD.bazel",
        strip_prefix = "graalvm-ce-java11-20.0.0",
    )