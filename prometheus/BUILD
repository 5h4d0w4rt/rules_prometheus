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
        "@//prometheus/internal:defaults",
        "@//prometheus/internal:platforms",
        "@//prometheus/internal:prom",
        "@//prometheus/internal:promtool",
        "@//prometheus/internal:providers",
        "@//prometheus/internal:repositories",
        "@//prometheus/internal:toolchain",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
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
