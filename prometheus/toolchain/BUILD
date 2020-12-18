package(
    default_visibility = ["//visibility:public"],
)

load(":toolchain.bzl", "prometheus_toolchain")

toolchain_type(name = "toolchain_type")

prometheus_toolchain(
    name = "prometheus_darwin",
    prometheus = "@prometheus_darwin//:prometheus",
    promtool = "@prometheus_darwin//:promtool",
    promtool_executor_template = "//prometheus/internal:promtool.sh.tpl",
)

toolchain(
    name = "prometheus_toolchain_darwin",
    exec_compatible_with = [
        "@platforms//os:osx",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:osx",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":prometheus_darwin",
    toolchain_type = ":toolchain_type",
)
