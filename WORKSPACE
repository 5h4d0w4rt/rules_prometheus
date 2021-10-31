workspace(name = "io_bazel_rules_prometheus")

# all dependencies are called from there
load("@//:deps.bzl", "rules_prometheus_dependencies", "rules_prometheus_repositories")

# this downloads dependencies required for prometheus to work
rules_prometheus_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# this downloads prometheus blobs and registers toolchain
rules_prometheus_repositories()
