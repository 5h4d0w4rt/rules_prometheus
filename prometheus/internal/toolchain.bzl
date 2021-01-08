load(":providers.bzl", "AlertmanagerInfo", "AmtoolInfo", "PrometheusInfo", "PromtoolInfo")

PrometheusToolchainInfo = provider(
    doc = "Prometheus Toolchain metadata, contains prometheus, alertmanager, promtool and amtool's necessary data",
    fields = {
        "name": "Label name of the toolchain",
        "prometheus": "PrometheusInfo provider",
        "promtool": "PromtoolInfo provider",
        "amtool": "Amtool provider",
        "alertmanager": "Alertmanager provider",
    },
)

def _prometheus_toolchain_impl(ctx):
    """Toolchain main implementation function"""
    toolchain_info = platform_common.ToolchainInfo(
        prometheusToolchainInfo = PrometheusToolchainInfo(
            name = ctx.label.name,
            prometheus = PrometheusInfo(
                tool = ctx.attr.prometheus,
                template = ctx.attr.prometheus_executor_template,
            ),
            promtool = PromtoolInfo(
                tool = ctx.attr.promtool,
                template = ctx.attr.promtool_executor_template,
            ),
            amtool = AmtoolInfo(),
            alertmanager = AlertmanagerInfo(),
        ),
    )
    return [toolchain_info]

prometheus_toolchain = rule(
    implementation = _prometheus_toolchain_impl,
    doc = "Prometheus toolchain implements main instruments of this rule set",
    attrs = {
        "prometheus": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool_executor_template": attr.label(mandatory = True, allow_single_file = True),
        "prometheus_executor_template": attr.label(mandatory = True, allow_single_file = True),
    },
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchains():
    """Create prometheus_toolchain rules for every supported platform and link toolchains to them"""
    prometheus_toolchain(
        name = "prometheus_darwin",
        prometheus = "@prometheus_darwin//:prometheus",
        promtool = "@prometheus_darwin//:promtool",
        promtool_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:promtool.sh.tpl",
        prometheus_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:prometheus.sh.tpl",
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
    """Register all toolchains"""
    native.register_toolchains("@io_bazel_rules_prometheus//prometheus/internal:prometheus_toolchain_darwin")
