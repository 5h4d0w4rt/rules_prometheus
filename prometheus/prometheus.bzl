load(
    "//prometheus/internal:promtool.bzl",
    _promtool_unit_test = "promtool_unit_test",
)
load(
    "//prometheus/internal:promtool.bzl",
    _promtool_config_test = "promtool_config_test",
)

promtool_unit_test = _promtool_unit_test
promtool_config_test = _promtool_config_test
