load("@io_bazel_rules_prometheus//prometheus:prometheus.bzl", "promtool")

package(default_visibility = ["//visibility:public"])

promtool(
    name = "promtool",
)
