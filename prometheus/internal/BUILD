load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load(":toolchain.bzl", "declare_toolchains")
load(":prom.bzl", "prometheus_server")

package(
    default_visibility = [
        "//prometheus:__subpackages__",
    ],
)

prometheus_server(
    name = "test_server",
    scrape_jobs = """
  - {
    "job_name": "_prometheus",
    "static_configs": [
    {
        "targets": [
        "localhost:9090"
        ]
    }
    ]
}
  - {
    "job_name": "_data_generator",
    "static_configs": [
    {
        "targets": [
        "localhost:10500"
        ]
    }
    ]
}
""",
    tags = [
        "local",
        "manual",
        "no-cache",
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

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

declare_toolchains()
