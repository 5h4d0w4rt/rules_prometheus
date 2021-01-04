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
    doc = """Private rule implemented for invocation in public prometheus() runner""",
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
    """Prometheus runner which will launch prometheus server

    This will emit runnable sh_binary target which will invoke prometheus server with all arguments passed along.
    Tool will have access to workspace. It is intended for convenient in-workspace usage by human and not to be invoked programmatically.

    Example:
    ```
    load("//prometheus:prometheus.bzl", "prometheus")

    package(default_visibility = ["//visibility:public"])

    prometheus(
        name = "prometheus",
    )
    ```

    Args:
      name: A unique name for this target.
      **kwargs: Attributes to be passed along

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
