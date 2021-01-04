load(
    "//prometheus/internal:promtool.bzl",
    _promtool = "promtool",
    _promtool_config_test = "promtool_config_test",
    _promtool_rules_test = "promtool_rules_test",
    _promtool_unit_test = "promtool_unit_test",
)
load(
    "//prometheus/internal:toolchain.bzl",
    _prometheus_register_toolchains = "prometheus_register_toolchains",
)
load(
    "//prometheus/internal:prom.bzl",
    _prometheus = "prometheus",
)

promtool_unit_test = _promtool_unit_test
promtool_config_test = _promtool_config_test
prometheus_register_toolchains = _prometheus_register_toolchains
promtool = _promtool
promtool_rules_test = _promtool_rules_test
prometheus = _prometheus
