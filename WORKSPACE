workspace(name = "io_bazel_rules_prometheus")

load(":deps.bzl", "prometheus_repositories")

prometheus_repositories()

register_toolchains(
    "//prometheus/toolchain:all",
)
