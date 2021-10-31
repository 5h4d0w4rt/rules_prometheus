load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(":toolchain.bzl", "declare_toolchains")
load(":platforms.bzl", "declare_constraints")

package(
    default_visibility = [
        "//prometheus:__subpackages__",
    ],
)

exports_files(
    [
        "repositories.bzl",
    ] + glob([
        "*.bat",
        "*.sh",
        "*.sh.tpl",
    ]),
    visibility = ["//visibility:public"],
)

exports_files([
    "promtool.bzl",
    "prom.bzl",
    "providers.bzl",
    "toolchain.bzl",
])

bzl_library(
    name = "promtool",
    srcs = ["promtool.bzl"],
    deps = [":toolchain"],
)

bzl_library(
    name = "prom",
    srcs = ["prom.bzl"],
    deps = [":toolchain"],
)

bzl_library(
    name = "providers",
    srcs = ["providers.bzl"],
)

bzl_library(
    name = "platforms",
    srcs = ["platforms.bzl"],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    deps = [
        ":platforms",
        ":providers",
    ],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    deps = [
        ":platforms",
        ":toolchain",
    ],
)

declare_platforms(name = "constraints")

declare_toolchains(name = "toolchains")
