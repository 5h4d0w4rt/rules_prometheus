# Prometheus bazel rules

Prometheus/Alertmanager rules for Bazel

# TODO
- autodocs and improve rules documentation
- better examples
- integrate alertmanager and amtool into rules and workspace binaries
- start prometheus server/alertmanager with input configs
- run some binary tests against prometheus server and alertmanager for smoke/integration/load testing
- unit test rules and toolchains
- add linux toolchain
- make toolchains work in containers
- create CI config so repo is scalable

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

- promtool

```
//:promtool
load("//prometheus:prometheus.bzl", "promtool")

package(default_visibility = ["//visibility:public"])

promtool(
    name = "promtool",
)
```

```bash
bazel run //:promtool check rules examples/rules.json

Checking examples/rules.json
  SUCCESS: 2 rules found
```

- promtool_rules_test

```
//examples:test_rules_yml
promtool_rules_test(
    name = "test_rules_yml",
    srcs = ["rules.yml"],
)
```

```bash
bazel test //examples:test_rules_yml

//examples:unit_test_rules_yml                                           PASSED in 0.3s
```

- promtool_unit_test

```

//examples:unit_test_rules_yml

load("//prometheus:prometheus.bzl", "promtool_unit_test")
promtool_unit_test(
name = "unit_test_rules_yml",
srcs = [
"tests.yml",
],
rules = ["rules.yml"],
)

```

```bash
bazel test //examples:unit_test_rules_yml

INFO: Build completed successfully, 3 total actions
//examples:unit_test_rules_yml                                                PASSED in 0.1s

Executed 1 out of 1 test: 1 test passes.
```

- promtool_config_test

```
//examples:test_config_yml

load("//prometheus:prometheus.bzl", "promtool_config_test")
promtool_config_test(
    name = "test_config_yml",
    srcs = ["prometheus.yml"],
)
```

```bash
bazel test //examples:test_config_yml

INFO: Build completed successfully, 3 total actions
//examples:test_config_yml                                               PASSED in 0.1s

Executed 1 out of 1 test: 1 test passes.
```
