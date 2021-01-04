load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":toolchain.bzl", "prometheus_register_toolchains")

ALERTMANAGER_BUILD_FILE_CONTENTS = """
exports_files([
    "alertmanager",
    "amtool",
])
"""

PROMETHEUS_BUILD_FILE_CONTENTS = """
exports_files([
    "prometheus",
    "promtool",
])
"""

def prometheus_repositories(prometheus_version = "2.23.0", alertmanager_version = "0.21.0"):
    """define prometheus repositories and download dependencies"""

    prometheus_darwin_arch = "darwin-amd64"
    prometheus_darwin_url = "https://github.com/prometheus/prometheus/releases/download/v{version}/prometheus-{version}.{darwin_arch}.tar.gz".format(
        version = prometheus_version,
        darwin_arch = prometheus_darwin_arch,
    )
    http_archive(
        name = "prometheus_darwin",
        sha256 = "d589a45495cea1aa74bff82335d2145f2d93b8b357c3398739b9139c74dc0cfe",
        urls = [prometheus_darwin_url],
        strip_prefix = "prometheus-{}.{}".format(
            prometheus_version,
            prometheus_darwin_arch,
        ),
        build_file_content = PROMETHEUS_BUILD_FILE_CONTENTS,
    )
    http_archive(
        name = "alertmanager_darwin",
        sha256 = "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
        urls = ["https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.darwin-amd64.tar.gz"],
        strip_prefix = "alertmanager-{}.{}".format(alertmanager_version, prometheus_darwin_arch),
        build_file_content = ALERTMANAGER_BUILD_FILE_CONTENTS,
    )

    prometheus_register_toolchains()
