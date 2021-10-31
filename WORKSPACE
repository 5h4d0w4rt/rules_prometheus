workspace(name = "io_bazel_rules_prometheus")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# all dependencies are called from there
load("@io_bazel_rules_prometheus//:deps.bzl", "prometheus_repositories")

prometheus_repositories()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
