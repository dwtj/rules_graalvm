load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _fetch_known_graalvm_releases():
    # TODO(dwtj): Put this in its own file somewhere. (But where?)
    BUILD_FILE_CONTENT = """
load("@rules_graalvm//graalvm:defs.bzl", "graalvm_runtime_toolchain")
graalvm_runtime_toolchain(
    name = "graalvm_runtime_toolchain",
    graalvm_executable = "//:bin/java",
)
"""

    maybe(
        http_archive,
        name = "graalvm_linux_x86_64",
        sha256 = "d16c4a340a4619d98936754caeb6f49ee7a61d809c5a270e192b91cbc474c726",
        url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz",
        build_file_content = BUILD_FILE_CONTENT,
        strip_prefix = "graalvm-ce-java11-20.0.0",
    )

def _fetch_custom_rules_java():
    # NB(dwtj): `me_dwtj_rules_java` is a fork of `rules_java`. It includes a
    # PR which hasn't yet been merged into `rules_java` or `bazel-federation`.
    # This PR defines some platform/toolchain constraints for selecting Java
    # toolchains and runtimes.  Our `rules_graalvm` uses these constraints in
    # our own rule definitions.  Once these definitions (or something similar)
    # reach the `bazel-federation`, this external repository should no longer be
    # used.
    # TODO(dwtj): Reconsider whether we actually need these constraint defs.

    # [master] as of 2020-04-05:
    ME_DWTJ_RULES_JAVA_COMMIT = "c05a11100aa6a0d170d98767589331b6f741fa51"

    ME_DWTJ_RULES_JAVA_SHA256 = "8901695f2e186d21c20ea71d09ac534b8528a0d7639bda9b116ddf8f5438e014"

    http_archive(
        name = "me_dwtj_rules_java",
        sha256 = ME_DWTJ_RULES_JAVA_SHA256,
        strip_prefix = "rules_java-{}".format(ME_DWTJ_RULES_JAVA_COMMIT),
        url = "https://github.com/dwtj/archive/{}.zip".format(ME_DWTJ_RULES_JAVA_COMMIT),
    )

def rules_graalvm_dependencies():
    _fetch_custom_rules_java()
    _fetch_known_graalvm_releases()

def rules_graalvm_toolchain():
    native.register_toolchains("@rules_graalvm//graalvm/toolchains/runtime/linux/x86_64")
