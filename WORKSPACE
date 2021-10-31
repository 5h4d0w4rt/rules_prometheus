workspace(name = "io_bazel_rules_prometheus")

# all dependencies are called from there
load("@//:deps.bzl", "rules_prometheus_repositories")

rules_prometheus_repositories()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
