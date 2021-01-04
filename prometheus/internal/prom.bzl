def _prometheus_impl(ctx):
    prom_info = ctx.toolchains["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"].prometheusToolchainInfo.prometheus
    prom_template = ctx.file._template
    exec = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    runfiles = ctx.runfiles(
        files = ctx.files._template,
        transitive_files = prom_info.tool.files,
    )
    ctx.actions.expand_template(
        template = prom_template,
        output = exec,
        is_executable = True,
        substitutions = {
            "%tool_path%": "%s" % prom_info.tool.files_to_run.executable.short_path,
        },
    )
    return [DefaultInfo(runfiles = runfiles, executable = exec)]

_prometheus = rule(
    implementation = _prometheus_impl,
    attrs = {
        "_template": attr.label(
            default = Label("@io_bazel_rules_prometheus//prometheus/internal:prom.manual_runner.sh.tpl"),
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"],
)

def prometheus(name, **kwargs):
    """
    Prometheus runner which will launch prometheus server

    Example:
    ```
    load("//prometheus:prometheus.bzl", "prometheus")

    package(default_visibility = ["//visibility:public"])

    prometheus(
        name = "prometheus",
    )
    ```
    """
    runner = name + "-runner"
    _prometheus(
        name = runner,
        tags = ["manual"],
        **kwargs
    )
    native.sh_binary(
        name = name,
        srcs = [runner],
        tags = ["manual"],
    )
