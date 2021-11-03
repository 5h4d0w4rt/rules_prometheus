load("@io_bazel_rules_prometheus//prometheus/internal:defaults.bzl", "DEFAULT_PLATFORMS")
load("@bazel_skylib//lib:structs.bzl", "structs")

INCOMPATIBLE = "@platforms//:incompatible"

def declare_platforms(name = "platforms", _platforms_info = DEFAULT_PLATFORMS):
    """
        Generates constraint_values and platform targets for valid platforms.

    Args:
        name: name
        _platforms_info: pre-built PrometheusPlatformsInfo provider with info on all available os+architectures
    """

    for platform in structs.to_dict(_platforms_info.platforms):
        platform_info = getattr(_platforms_info.platforms, platform)

        native.platform(
            name = "prometheus_platform_{platform}".format(platform = platform),
            constraint_values = platform_info.cpu_constraints + platform_info.os_constraints,
        )
