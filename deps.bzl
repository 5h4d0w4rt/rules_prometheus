load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

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
    PROMETHEUS_DARWIN_ARCH = "darwin-amd64"
    PROMETHEUS_DARWIN = "{prometheus_version}.{PROMETHEUS_DARWIN_ARCH}"
    PROMETHEUS_DARWIN_URL = "https://github.com/prometheus/prometheus/releases/download/v{prometheus_version}/prometheus-{prometheus_version}.{PROMETHEUS_DARWIN_ARCH}.tar.gz"
    http_archive(
        name = "prometheus_darwin",
        sha256 = "d589a45495cea1aa74bff82335d2145f2d93b8b357c3398739b9139c74dc0cfe",
        urls = [PROMETHEUS_DARWIN_URL],
        strip_prefix = "prometheus-%s.%s" % (prometheus_version, PROMETHEUS_DARWIN_ARCH),
        build_file_content = PROMETHEUS_BUILD_FILE_CONTENTS,
    )
    http_archive(
        name = "alertmanager_darwin",
        sha256 = "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
        urls = ["https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.darwin-amd64.tar.gz"],
        strip_prefix = "alertmanager-%s.%s" % (alertmanager_version, PROMETHEUS_DARWIN_ARCH),
        build_file_content = ALERTMANAGER_BUILD_FILE_CONTENTS,
    )
