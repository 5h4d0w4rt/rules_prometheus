load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

package(default_visibility = ["//visibility:public"])

exports_files(["defs.bzl"])

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
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
    input = "defs.bzl",
    symbol_names = [
        "promtool",
        "promtool_config_test",
        "promtool_rules_test",
        "promtool_unit_test",
        "prometheus",
    ],
    deps = [
        ":defs",
    ],
)
