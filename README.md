# Example Usage: `WORKSPACE` File

```
RULES_GRAALVM_COMMIT = "ca52548f8c6a29b0ff67d18e659560595505b4d7"
RULES_GRAALVM_SHA256 = "22fa03e5cf07ee10ae4e8455b4a38c090c932a647e7d1f96a5090469d3b0362b"

http_archive(
    name = "rules_graalvm",
    sha256 = RULES_GRAALVM_SHA256,
    strip_prefix = "rules_graalvm-{}".format(RULES_GRAALVM_COMMIT),
    url = "https://github.com/dwtj/rules_graalvm/archive/{}.zip".format(RULES_GRAALVM_COMMIT),
)

load("@rules_graalvm//graalvm:repositories.bzl",
     "rules_graalvm_dependencies",
     "rules_graalvm_toolchains")

rules_graalvm_dependencies()
rules_graalvm_toolchains()
```


# Example Usage: `BUILD` File

```
load("@rules_java//java:defs.bzl", "java_binary")
load("@rules_graalvm//graalvm:defs.bzl", "graalvm_java_test")

java_binary(
    name = "hello",
    main_class = "hello.Main",
    srcs = [":Main.java"],
)

graalvm_java_test(
    name = "hello_from_graalvm",
    main_class = "hello.Main",
    java_deps = [":hello"],
)
```