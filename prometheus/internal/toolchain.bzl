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

def declare_toolchains_prod(architectures):
    """Create prometheus_toolchain rules for every supported platform and link toolchains to them"""

    for arch in architectures:
        prometheus_toolchain(
            name = "prometheus_%s" % arch,
            prometheus = "@prometheus_%s//:prometheus" % arch,
            promtool = "@prometheus_%s//:promtool" % arch,
            promtool_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:promtool.sh.tpl",
            prometheus_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:prometheus.sh.tpl",
        )

        native.toolchain(
            name = "prometheus_toolchain_%s" % arch,
            exec_compatible_with = [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
            target_compatible_with = [
                "@platforms//os:osx",
                "@platforms//cpu:x86_64",
            ],
            toolchain = "@io_bazel_rules_prometheus//prometheus/internal:prometheus_%s" % arch,
            toolchain_type = "@io_bazel_rules_prometheus//prometheus:toolchain",
        )

def declare_toolchains_dummy(architectures):
    """Experimental: Create toolchain dummies for all platforms"""

    for arch in architectures:
        prometheus_toolchain(
            name = "prometheus_%s" % arch,
            prometheus = "@prometheus_%s//:prometheus" % arch,
            promtool = "@prometheus_%s//:promtool" % arch,
            promtool_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:promtool.sh.tpl",
            prometheus_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:prometheus.sh.tpl",
        )

        native.toolchain(
            name = "prometheus_toolchain_%s" % arch,
            toolchain = "@io_bazel_rules_prometheus//prometheus/internal:prometheus_%s" % arch,
            toolchain_type = "@io_bazel_rules_prometheus//prometheus:toolchain",
        )

def _link_toolchain_to_prometheus_toolchain(arch):
    return "@io_bazel_rules_prometheus//prometheus/internal:prometheus_toolchain_%s" % arch

def build_toolchains(architectures, toolchain_linker = _link_toolchain_to_prometheus_toolchain):
    return [
        toolchain_linker(arch)
        for arch in architectures
    ]

def prometheus_register_toolchains(toolchains):
    """Register all toolchains"""
    native.register_toolchains(*toolchains)
