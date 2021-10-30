load(":providers.bzl", "AlertmanagerInfo", "AmtoolInfo", "PrometheusInfo", "PromtoolInfo")
load(":platforms.bzl", "CpuConstraintsInfo", "OsConstraintsInfo", "PLATFORMS")

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
    return [
        platform_common.ToolchainInfo(
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
        ),
    ]

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

def declare_toolchains(_platforms_info = PLATFORMS):
    """
        Create prometheus_toolchain rules for every supported platform and link toolchains to them

    Args:
        _platforms_info: pre-built PrometheusPlatformInfo provider with info on all available os+architectures
    """

    for platform in _platforms_info.available_platforms:
        platform_info = getattr(_platforms_info.platforms, platform)

        prometheus_toolchain(
            name = "prometheus_{platform}".format(platform = platform),
            prometheus = "@prometheus_{platform}//:prometheus".format(platform = platform),
            promtool = "@prometheus_{platform}//:promtool".format(platform = platform),
            promtool_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:promtool.sh.tpl",
            prometheus_executor_template = "@io_bazel_rules_prometheus//prometheus/internal:prometheus.sh.tpl",

            # https://docs.bazel.build/versions/main/be/common-definitions.html#common.tags
            # exclude toolchain from expanding on wildcard
            # so you won't download all dependencies for all platforms
            tags = ["manual"],
        )

        native.toolchain(
            name = "prometheus_toolchain_{platform}".format(platform = platform),
            target_compatible_with = [
                getattr(OsConstraintsInfo, platform_info.os),
                getattr(CpuConstraintsInfo, platform_info.cpu),
            ],
            exec_compatible_with = [
                getattr(OsConstraintsInfo, platform_info.os),
                getattr(CpuConstraintsInfo, platform_info.cpu),
            ],
            toolchain = ":prometheus_{platform}".format(platform = platform),
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
