workspace(name = "io_bazel_rules_prometheus")

load(":deps.bzl", "prometheus_repositories")

prometheus_repositories()

load("@io_bazel_rules_prometheus//prometheus:prometheus.bzl", "prometheus_register_toolchains")

prometheus_register_toolchains()
