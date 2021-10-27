load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(":toolchain.bzl", "declare_toolchains_dummy", "declare_toolchains_prod")

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
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    deps = [":providers"],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    deps = [":toolchain"],
)

declare_toolchains_prod(
    architectures = {
        "darwin-amd64": {
            "exec": [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
            "target": [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
        },
        "linux-amd64": {
            "exec": [
                "@platforms//os:linux",
                "@platforms//cpu:x86_64",
            ],
            "target": [
                "@platforms//os:linux",
                "@platforms//cpu:x86_64",
            ],
        },
    },
)

declare_toolchains_dummy(
    architectures = (
        "dragonfly-amd64",
        "freebsd-386",
        "freebsd-amd64",
        "freebsd-armv6",
        "freebsd-armv7",
        "linux-386",
        "linux-arm64",
        "linux-armv5",
        "linux-armv6",
        "linux-armv7",
        "linux-mips64",
        "linux-mips64le",
        "linux-ppc64",
        "linux-ppc64le",
        "linux-s390x",
        "netbsd-386",
        "netbsd-amd64",
        "netbsd-armv6",
        "netbsd-armv7",
        "openbsd-386",
        "openbsd-amd64",
        "windows-386",
        "windows-amd64",
    ),
)
