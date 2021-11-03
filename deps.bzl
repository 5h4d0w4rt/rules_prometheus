load(
    "@io_bazel_rules_prometheus//prometheus:defs.bzl",
    _prometheus_repositories = "prometheus_repositories",
    _prometheus_toolchains = "prometheus_toolchains",
)

rules_prometheus_repositories = _prometheus_repositories
rules_prometheus_toolchains = _prometheus_toolchains
