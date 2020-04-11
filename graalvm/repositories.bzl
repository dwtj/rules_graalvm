load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

load("@rules_graalvm//graalvm/repositories:known_graalvm_repositories.bzl", "fetch_known_graalvm_repositories")

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
        url = "https://github.com/dwtj/rules_java/archive/{}.zip".format(ME_DWTJ_RULES_JAVA_COMMIT),
    )

def rules_graalvm_dependencies():
    _fetch_custom_rules_java()
    fetch_known_graalvm_repositories()

def rules_graalvm_toolchains():
    native.register_toolchains("@rules_graalvm//graalvm/toolchains/remote/linux/x86_64:graalvm_runtime_toolchain")
    native.register_toolchains("@rules_graalvm//graalvm/toolchains/remote/linux/x86_64:graalvm_compiler_toolchain")
