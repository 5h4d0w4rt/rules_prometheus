load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

exports_files(["prometheus.bzl"])

bzl_library(
    name = "prometheus",
    srcs = ["prometheus.bzl"],
    deps = [
        "//prometheus/internal:prom",
        "//prometheus/internal:promtool",
        "//prometheus/internal:toolchain",
    ],
)
