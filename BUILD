load("//prometheus:prometheus.bzl", "prometheus", "promtool")

package(default_visibility = ["//visibility:public"])

exports_files(["deps.bzl"])

promtool(
    name = "promtool",
)

prometheus(
    name = "prom",
)
