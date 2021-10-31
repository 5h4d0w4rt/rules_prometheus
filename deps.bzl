load(
    "@//prometheus:defs.bzl",
    _prometheus_dependencies = "prometheus_dependencies",
    _prometheus_repositories = "prometheus_repositories",
)

rules_prometheus_repositories = _prometheus_repositories
rules_prometheus_dependencies = _prometheus_dependencies
