load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

package(default_visibility = ["//visibility:public"])

exports_files(["prometheus.bzl"])

bzl_library(
    name = "prometheus",
    srcs = ["prometheus.bzl"],
    deps = [
        "//prometheus/internal:prom",
        "//prometheus/internal:promtool",
        "//prometheus/internal:providers",
        "//prometheus/internal:toolchain",
    ],
)

stardoc(
    name = "docs",
    out = "docs.md",
    input = "prometheus.bzl",
    symbol_names = [
        "promtool",
        "promtool_config_test",
        "promtool_rules_test",
        "promtool_unit_test",
        "prometheus",
    ],
    deps = [
        ":prometheus",
    ],
)
