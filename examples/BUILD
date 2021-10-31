load("@//prometheus:defs.bzl", "promtool_config_test", "promtool_rules_test", "promtool_unit_test")

promtool_unit_test(
    name = "unit_test_rules_yml",
    srcs = [
        "tests.yml",
    ],
    rules = ["rules.yml"],
)

promtool_unit_test(
    name = "unit_test_rules_json",
    srcs = [
        "tests.json",
    ],
    rules = ["rules.json"],
)

promtool_unit_test(
    name = "unit_test_rules_multiple_mixed",
    srcs = [
        "tests.json",
        "tests.yml",
    ],
    rules = [
        "rules.json",
        "rules.yml",
    ],
)

promtool_config_test(
    name = "test_config_yml",
    srcs = ["prometheus.yml"],
)

promtool_config_test(
    name = "test_config_json",
    srcs = ["prometheus.json"],
)

promtool_config_test(
    name = "test_config_multiple_mixed",
    srcs = [
        "prometheus.json",
        "prometheus.yml",
    ],
)

promtool_rules_test(
    name = "test_rules_yml",
    srcs = ["rules.yml"],
)

promtool_rules_test(
    name = "test_rules_json",
    srcs = ["rules.json"],
)

promtool_rules_test(
    name = "test_rules_multiple_mixed",
    srcs = [
        "rules.json",
        "rules.yml",
    ],
)

test_suite(
    name = "all_tests",
    tests = [
        "test_rules_multiple_mixed",
        ":test_config_json",
        ":test_config_multiple_mixed",
        ":test_config_yml",
        ":test_rules_json",
        ":test_rules_yml",
        ":unit_test_rules_json",
        ":unit_test_rules_multiple_mixed",
        ":unit_test_rules_yml",
    ],
)
