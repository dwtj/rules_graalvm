workspace(name = "rules_graalvm")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# USE BAZEL-FEDERATION TO FETCH RULE DEPENDENCIES #############################

# [master] as of 2020-04-05:
BAZEL_FEDERATION_COMMIT = "6de8b927bd8044ba07e854a9db60e6c16e026c2b"

BAZEL_FEDERATION_SHA256 = "8c06aca9387af2bd46a492c4c4100eb56b7fb1b8d0f4dc2eb7253753ba550780"

http_archive(
    name = "bazel_federation",
    sha256 = BAZEL_FEDERATION_SHA256,
    strip_prefix = "bazel-federation-{}".format(BAZEL_FEDERATION_COMMIT),
    type = "zip",
    url = "https://github.com/bazelbuild/bazel-federation/archive/{}.zip".format(BAZEL_FEDERATION_COMMIT),
)

load(
    "@bazel_federation//:repositories.bzl",
    "bazel_stardoc",
    "rules_java",
    "rules_pkg",
)

rules_java()

load("@bazel_federation//setup:rules_java.bzl", "rules_java_setup")

rules_java_setup()

rules_pkg()

load("@bazel_federation//setup:rules_pkg.bzl", "rules_pkg_setup")

rules_pkg_setup()

bazel_stardoc()

load("@bazel_federation//setup:bazel_stardoc.bzl", "bazel_stardoc_setup")

bazel_stardoc_setup()

# FETCH & REGISTER GRAALVM TOOLCHAINS FOR TESTING #############################

load(
    "//graalvm:repositories.bzl",
    "rules_graalvm_dependencies",
    "rules_graalvm_toolchains",
)

rules_graalvm_dependencies()

rules_graalvm_toolchains()


# FETCH SOME TEST DEPENDENCIES FROM MAVEN CENTRAL #############################

RULES_JVM_EXTERNAL_TAG = "3.2"

RULES_JVM_EXTERNAL_SHA256 = "82262ff4223c5fda6fb7ff8bd63db8131b51b413d26eb49e3131037e79e324af"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA256,
    strip_prefix = "rules_jvm_external-{}".format(RULES_JVM_EXTERNAL_TAG),
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/{}.zip".format(RULES_JVM_EXTERNAL_TAG),
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

ORG_GRAALVM_TRUFFLE_VERSION = "20.0.0"

maven_install(
    artifacts = [
        "org.graalvm.truffle:truffle-api:{}".format(ORG_GRAALVM_TRUFFLE_VERSION),
        "org.graalvm.sdk:graal-sdk:{}".format(ORG_GRAALVM_TRUFFLE_VERSION),
    ],
    fetch_sources = True,
    repositories = [
        "https://jcenter.bintray.com/",
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
)
