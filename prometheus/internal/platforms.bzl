INCOMPATIBLE = "@platforms//:incompatible"

_LIST_OF_PLATFORMS = (
    "darwin-amd64",
    "darwin-arm64",
    "dragonfly-amd64",
    "freebsd-386",
    "freebsd-amd64",
    "freebsd-arm64",
    "freebsd-armv6",
    "freebsd-armv7",
    "illumos-amd64",
    "linux-386",
    "linux-amd64",
    "linux-arm64",
    "linux-armv5",
    "linux-armv6",
    "linux-armv7",
    "linux-mips",
    "linux-mips64",
    "linux-mips64le",
    "linux-mipsle",
    "linux-ppc64",
    "linux-ppc64le",
    "linux-s390x",
    "netbsd-386",
    "netbsd-amd64",
    "netbsd-arm64",
    "netbsd-armv6",
    "netbsd-armv7",
    "openbsd-386",
    "openbsd-amd64",
    "openbsd-arm64",
    "openbsd-armv7",
    "windows-386",
    "windows-amd64",
)

PrometheusPlatformsInfo = provider(
    # this should store os-arch combinations for toolchain generation
    doc = "OS and CPU platforms, constraints and available architectures metadata provider",
    fields = {
        "platforms": "mapping of PrometheusPlatformInfo providers",
        "available_platforms": "list of platforms",
    },
)

PrometheusPlatformInfo = provider(
    # this should store os-arch combinations for toolchain generation
    doc = "OS and CPU platform constraints metadata provider",
    fields = [
        "os",
        "cpu",
    ],
)

OsConstraintsInfo = struct(
    darwin = "@platforms//os:osx",
    freebsd = "@platforms//os:freebsd",
    dragonfly = "@platforms//os:freebsd",
    linux = "@platforms//os:linux",
    windows = "@platforms//os:windows",
    netbsd = "@platforms//os:freebsd",
    openbsd = "@platforms//os:openbsd",
    illumos = "@platforms//os:openbsd",
)

CpuConstraintsInfo = struct(
    amd64 = "@platforms//cpu:x86_64",
    arm = "@platforms//cpu:arm",
    arm64 = "@platforms//cpu:arm64",
    armv5 = "@platforms//cpu:arm",
    armv6 = "@platforms//cpu:arm",
    armv7 = "@platforms//cpu:armv7",
    mips64 = "@platforms//cpu:mips64",
    mips64le = "@platforms//cpu:mips64",
    ppc64 = "@platforms//cpu:x86_32",
    ppc64le = "@platforms//cpu:ppc",
    s390x = "@platforms//cpu:s390x",
    mips = "@platforms//cpu:x86_32",
    mipsle = "@platforms//cpu:x86_32",
    # because you can't pass integer as keyword in python
    **{"386": "@platforms//cpu:x86_32"}
)

def platform_info_factory(list_of_platforms):
    return PrometheusPlatformsInfo(
        available_platforms = list_of_platforms,
        platforms = struct(**{
            platform: PrometheusPlatformInfo(
                os = platform.partition("-")[0],
                cpu = platform.partition("-")[-1],
            )
            for platform in list_of_platforms
        }),
    )

PLATFORMS = platform_info_factory(
    _LIST_OF_PLATFORMS,
)

def declare_constraints(_platforms_info = PLATFORMS):
    """Generates constraint_values and platform targets for valid platforms.
    Args:
        _platforms_info: pre-built PrometheusPlatformInfo provider with info on all available os+architectures
    """

    for platform in _platforms_info.available_platforms:
        platform_info = getattr(_platforms_info.platforms, platform)

        native.platform(
            name = "prometheus_platform_{platform}".format(platform = platform),
            constraint_values = [
                getattr(OsConstraintsInfo, platform_info.os),
                getattr(CpuConstraintsInfo, platform_info.cpu),
            ],
        )
