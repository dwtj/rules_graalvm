These rules use Bazel platforms for toolchain resolution. You will need to use
the flag `--incompatible_use_toolchain_resolution_for_java_rules`. For example,
add this to your project's `.bazelrc` file:

```
--incompatible_use_toolchain_resolution_for_java_rules
```

These rules currently depend upon [`dwtj/rules_java`](https://github.com/dwtj/rules_java),
a fork of [`bazelbuild/rules_java`](https://github.com/bazelbuild/rules_java).
This is a temporary workaround. We hope to switch to the upstream
`bazelbuild/rules_java` as soon as it supports platform-based tool resolution.
See:

- [Design Document](https://docs.google.com/document/d/1dumNYb-3L8xswa2zjz7HizjhT05HIsEbQc2KuV3rdnk/edit?usp=sharing)
- [Pull Request](https://github.com/bazelbuild/rules_java/pull/8)
- [Tracking Issue](https://github.com/bazelbuild/bazel/issues/7849)

