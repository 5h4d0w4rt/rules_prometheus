load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":toolchain.bzl", "prometheus_register_toolchains")

_ALERTMANAGER_BUILD_FILE_CONTENTS = """
exports_files([
    "alertmanager",
    "amtool",
])
"""

_PROMETHEUS_BUILD_FILE_CONTENTS = """
exports_files([
    "prometheus",
    "promtool",
])
"""

_PROMETHEUS_BINARIES_PLATFORMS_MAP = {
    "darwin-amd64": {
        "prometheus": {
            "sha256": "0c631ec66d4abf1be936707dde7b0be37b4e5805fdd21b77093765037dc8e5da",
            "url": (
                "https://github.com/prometheus/prometheus/releases/download/" +
                "v{version}/prometheus-{version}.darwin-amd64.tar.gz"
            ),
        },
        "alertmanager": {
            "sha256": "b508eb6f5d1b957abbee92f9c37deb99a3da3311572bed34357ac8acbb75e510",
            "url": (
                "https://github.com/prometheus/alertmanager/releases/download/" +
                "v{version}/alertmanager-{version}.darwin-amd64.tar.gz"
            ),
        },
    },
}

def prometheus_repositories(prometheus_version = "2.24.0", alertmanager_version = "0.21.0"):
    http_archive(
        name = "prometheus_darwin",
        sha256 = _PROMETHEUS_BINARIES_PLATFORMS_MAP["darwin-amd64"]["prometheus"]["sha256"],
        urls = [
            _PROMETHEUS_BINARIES_PLATFORMS_MAP["darwin-amd64"]["prometheus"]["url"].format(
                version = prometheus_version,
            ),
        ],
        strip_prefix = "prometheus-{version}.darwin-amd64".format(
            version = prometheus_version,
        ),
        build_file_content = _PROMETHEUS_BUILD_FILE_CONTENTS,
    )
    http_archive(
        name = "alertmanager_darwin",
        sha256 = _PROMETHEUS_BINARIES_PLATFORMS_MAP["darwin-amd64"]["alertmanager"]["sha256"],
        urls = [_PROMETHEUS_BINARIES_PLATFORMS_MAP["darwin-amd64"]["alertmanager"]["url"].format(
            version = alertmanager_version,
        )],
        strip_prefix = "alertmanager-{version}.darwin-amd64".format(
            version = alertmanager_version,
        ),
        build_file_content = _ALERTMANAGER_BUILD_FILE_CONTENTS,
    )

    prometheus_register_toolchains()
