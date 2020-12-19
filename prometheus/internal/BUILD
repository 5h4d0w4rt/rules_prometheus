load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(":toolchain.bzl", "declare_toolchains")

package(
    default_visibility = ["//prometheus:__subpackages__"],
)

exports_files([
    "promtool.bzl",
    "providers.bzl",
    "toolchain.bzl",
])

exports_files(
    glob([
        "*.bat",
        "*.sh",
        "*.sh.tpl",
    ]),
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "promtool",
    srcs = ["promtool.bzl"],
    deps = [":toolchain"],
)

bzl_library(
    name = "providers",
    srcs = ["providers.bzl"],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

declare_toolchains()
