load("@//prometheus/internal:providers.bzl", "AlertmanagerInfo", "AmtoolInfo", "PrometheusInfo", "PromtoolInfo")
load("@//prometheus/internal:defaults.bzl", "DEFAULT_PROMETHEUS_PACKAGE_INFO")

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
        # explanation on cfg https://docs.bazel.build/versions/main/skylark/rules.html#configurations
        "prometheus": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool": attr.label(mandatory = True, allow_single_file = True, executable = True, cfg = "exec"),
        "promtool_executor_template": attr.label(mandatory = True, allow_single_file = True),
        "prometheus_executor_template": attr.label(mandatory = True, allow_single_file = True),
    },
    provides = [platform_common.ToolchainInfo],
)

def declare_toolchains(name = "declare_toolchains", _prometheus_package_info = DEFAULT_PROMETHEUS_PACKAGE_INFO):
    """
        Create prometheus_toolchain rules for every supported platform and link toolchains to them

    Args:
        name: name of the macro
        _prometheus_package_info: pre-built PrometheusPackageInfo provider
            with info all available os+architectures,
            expected versions and available binaries of prometheus and alertmanager
    """

    for platform in _prometheus_package_info.platforms_info.available_platforms:
        platform_info = getattr(_prometheus_package_info.platforms_info.platforms, platform)

        prometheus_toolchain(
            name = "prometheus_{platform}".format(platform = platform),
            prometheus = "@prometheus_{platform}//:prometheus".format(platform = platform),
            promtool = "@prometheus_{platform}//:promtool".format(platform = platform),
            promtool_executor_template = "@//prometheus/internal:promtool.sh.tpl",
            prometheus_executor_template = "@//prometheus/internal:prometheus.sh.tpl",

            # https://docs.bazel.build/versions/main/be/common-definitions.html#common.tags
            # exclude toolchain from expanding on wildcard
            # so you won't download all dependencies for all platforms
            tags = ["manual"],
        )

        native.toolchain(
            name = "prometheus_toolchain_{platform}".format(platform = platform),
            target_compatible_with = platform_info.os_constraints + platform_info.cpu_constraints,
            exec_compatible_with = platform_info.os_constraints + platform_info.cpu_constraints,
            toolchain = ":prometheus_{platform}".format(platform = platform),
            toolchain_type = "@//prometheus:toolchain",
        )

def _link_toolchain_to_prometheus_toolchain(arch):
    return "@//prometheus/internal:prometheus_toolchain_%s" % arch

def build_toolchains(architectures, toolchain_linker = _link_toolchain_to_prometheus_toolchain):
    return [
        toolchain_linker(arch)
        for arch in architectures
    ]

def _prometheus_register_toolchains(toolchains):
    """Register all toolchains"""
    native.register_toolchains(*toolchains)

def prometheus_toolchains(
        name = "prometheus_register_toolchains",
        _prometheus_package_info = DEFAULT_PROMETHEUS_PACKAGE_INFO):
    _prometheus_register_toolchains(
        toolchains =
            build_toolchains(_prometheus_package_info.platforms_info.available_platforms),
    )
