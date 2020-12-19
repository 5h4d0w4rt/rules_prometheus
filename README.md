# Prometheus bazel rules

# Setup
You will need recent [Bazel](https://bazel.build) release, otherwise rules will download and discover dependent required tools


## Initial project setup
```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_bazel_rules_prometheus",
    sha256 = "6e7817ed382373d1056ea9fe8a3e3c06bcffd11cee14c22a6930ca38b65aaf07",
    strip_prefix = "rules_prometheus-7cd073209bb04b06eacd8145c4576044c5ee6cc0",
    urls = ["https://github.com/5h4d0w4rt/rules_prometheus/archive/0.0.2-alpha.zip"],
)

load("@io_bazel_rules_prometheus//:deps.bzl", "prometheus_repositories")

prometheus_repositories()

load("@io_bazel_rules_prometheus//prometheus:prometheus.bzl", "prometheus_register_toolchains")

prometheus_register_toolchains()
```


## Rules

- promtool_unit_test
- promtool_config_test
