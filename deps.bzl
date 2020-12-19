load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

PROMETHEUS_VERSION = "2.23.0"
PROMETHEUS_DARWIN_ARCH = "darwin-amd64"
PROMETHEUS_DARWIN = "{PROMETHEUS_VERSION}.{PROMETHEUS_DARWIN_ARCH}"
PROMETHEUS_DARWIN_URL = "https://github.com/prometheus/prometheus/releases/download/v{PROMETHEUS_VERSION}/prometheus-{PROMETHEUS_VERSION}.{PROMETHEUS_DARWIN_ARCH}.tar.gz"

def prometheus_repositories():
    http_archive(
        name = "prometheus_darwin",
        sha256 = "d589a45495cea1aa74bff82335d2145f2d93b8b357c3398739b9139c74dc0cfe",
        urls = [PROMETHEUS_DARWIN_URL],
        strip_prefix = "prometheus-%s.%s" % (PROMETHEUS_VERSION, PROMETHEUS_DARWIN_ARCH),
        build_file = "@io_bazel_rules_prometheus//:prometheus.BUILD",
    )
