load("//prometheus:defs.bzl", "prometheus", "promtool")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

exports_files(["deps.bzl"])

promtool(
    name = "promtool",
)

prometheus(
    name = "prom",
)

bzl_library(
    name = "deps",
    srcs = ["deps.bzl"],
    deps = [
        "//prometheus/internal:repositories.bzl",
    ],
)
