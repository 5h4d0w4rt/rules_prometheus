load("//prometheus/internal:providers.bzl", "PrometheusInfo", "PromtoolInfo")

PrometheusToolchainInfo = provider(fields = [
    "name",
    "prometheus",
    "promtool",
])

# genrule to work with real machine instead of sandboxed bazel environment?

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
