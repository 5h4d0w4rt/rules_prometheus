load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

package(default_visibility = ["//visibility:public"])

toolchain_type(
    name = "toolchain",
    visibility = ["//visibility:public"],
)

exports_files([
    "defs.bzl",
])

bzl_library(
    name = "api",
    srcs = [
        "@io_bazel_rules_prometheus//prometheus/internal:defaults",
        "@io_bazel_rules_prometheus//prometheus/internal:platforms",
        "@io_bazel_rules_prometheus//prometheus/internal:prom",
        "@io_bazel_rules_prometheus//prometheus/internal:promtool",
        "@io_bazel_rules_prometheus//prometheus/internal:providers",
        "@io_bazel_rules_prometheus//prometheus/internal:repositories",
        "@io_bazel_rules_prometheus//prometheus/internal:toolchain",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":api",
    ],
)

# stardoc(
#     name = "docs",
#     out = "docs.md",
#     input = "defs.bzl",
#     symbol_names = [
#         "promtool",
#         "promtool_config_test",
#         "promtool_rules_test",
#         "promtool_unit_test",
#         "prometheus",
#     ],
#     deps = [
#         ":defs",
#     ],
# )
