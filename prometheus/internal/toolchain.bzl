load(":providers.bzl", "PrometheusInfo", "PromtoolInfo")

PrometheusToolchainInfo = provider(
    doc = "Prometheus Toolchain metadata",
    fields = [
        "name",
        "prometheus",
        "promtool",
    ],
)

def _prometheus_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        prometheusToolchainInfo = PrometheusToolchainInfo(
            name = ctx.label.name,
            prometheus = PrometheusInfo(
                tool = ctx.attr.prometheus,
            ),
            promtool = PromtoolInfo(
                tool = ctx.attr.promtool,
                template = ctx.attr.promtool_executor_template,
            ),
        ),
    )
    return [
        toolchain_info,
    ]

prometheus_toolchain = rule(
    implementation = _prometheus_toolchain_impl,
    attrs = {
        "prometheus": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool_executor_template": attr.label(mandatory = True, allow_single_file = True),
    },
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchains():
    prometheus_toolchain(
        name = "prometheus_darwin",
        prometheus = "@prometheus_darwin//:prometheus",
        promtool = "@prometheus_darwin//:promtool",
        promtool_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:promtool.sh.tpl",
    )
    native.toolchain(
        name = "prometheus_toolchain_darwin",
        exec_compatible_with = [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        toolchain = "@io_bazel_rules_prometheus//prometheus/internal:prometheus_darwin",
        toolchain_type = "@io_bazel_rules_prometheus//prometheus/internal:toolchain_type",
    )

def prometheus_register_toolchains():
    native.register_toolchains("@io_bazel_rules_prometheus//prometheus/internal:prometheus_toolchain_darwin")
