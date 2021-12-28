load(
    "@io_bazel_rules_prometheus//prometheus/internal:repositories.bzl",
    _prometheus_repositories = "prometheus_repositories",
)
load(
    "@io_bazel_rules_prometheus//prometheus/internal:promtool.bzl",
    _promtool = "promtool",
    _promtool_config_test = "promtool_config_test",
    _promtool_rules_test = "promtool_rules_test",
    _promtool_unit_test = "promtool_unit_test",
)
load(
    "@io_bazel_rules_prometheus//prometheus/internal:prom.bzl",
    _prometheus = "prometheus",
    _prometheus_server="prometheus_server",
)


load(
    "@io_bazel_rules_prometheus//prometheus/internal:toolchain.bzl",
    _prometheus_toolchains = "prometheus_toolchains",
)

prometheus_toolchains = _prometheus_toolchains
prometheus_repositories = _prometheus_repositories
promtool_unit_test = _promtool_unit_test
promtool_config_test = _promtool_config_test
promtool = _promtool
promtool_rules_test = _promtool_rules_test
prometheus = _prometheus
prometheus_server = _prometheus_server 
