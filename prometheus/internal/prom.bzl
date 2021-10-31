PROMETHEUS_CONFIG_DEFAULT_CONTENTS = """# my global config
global:
  scrape_interval: 1s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 1s # Evaluate rules every 15 seconds. The default is every 1 minute.
  scrape_timeout: 1s

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "data_generator"
    static_configs:
      - targets: ["localhost:10500"]
  {ADDITIONAL_SCRAPE_JOBS}

{ADDITIONAL_CONTENTS}
"""

def _prometheus_impl(ctx):
    prom_info = (
        ctx.toolchains["@//prometheus:toolchain"]
            .prometheusToolchainInfo
            .prometheus
    )
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
            default = Label("@//prometheus/internal:prom.manual_runner.sh.tpl"),
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@//prometheus:toolchain"],
)

def prometheus(name, **kwargs):
    """Prometheus runner which will launch prometheus server

    This will emit runnable sh_binary target which will invoke prometheus server with all arguments passed along.
    Tool will have access to workspace. It is intended for convenient in-workspace usage by human and not to be invoked programmatically.

    Example:
    ```
    load("//prometheus:defs.bzl", "prometheus")

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
        **kwargs
    )

def _prometheus_server_impl(ctx):
    prom_info = (
        ctx.toolchains["@//prometheus:toolchain"]
            .prometheusToolchainInfo
            .prometheus
    )
    prom_runner_template = prom_info.template.files.to_list()[0]
    args = []

    default_cfg_file = ctx.actions.declare_file("%s.default.config.out.yml" % ctx.label.name)
    default_data_directory = ctx.actions.declare_directory("%s.default.out.data" % ctx.label.name)
    exec = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    if not ctx.attr.config:
        args.append("--config.file=%s" % default_cfg_file.short_path)
    else:
        args.append("--config.file=%s" % ctx.files.config[0].short_path)

    args.append("--storage.tsdb.path=%s" % default_data_directory.short_path)

    runfiles = ctx.runfiles(
        files = ctx.files.config + [default_cfg_file, default_data_directory],
        transitive_files = prom_info.tool.files,
    )

    ctx.actions.expand_template(
        template = prom_runner_template,
        output = exec,
        is_executable = True,
        substitutions = {
            "%tool_path%": "%s" % prom_info.tool.files_to_run.executable.short_path,
            "%data_directory_path%": "%s" % default_data_directory.short_path,
            "%args%": " ".join(args),
        },
    )

    ctx.actions.write(default_cfg_file, content = PROMETHEUS_CONFIG_DEFAULT_CONTENTS.format(
        ADDITIONAL_SCRAPE_JOBS = ctx.attr.scrape_jobs,
        ADDITIONAL_CONTENTS = ctx.attr.additional_contents,
    ))

    ctx.actions.run_shell(
        inputs = [],
        outputs = [default_data_directory],
        arguments = [],
        command = "mkdir -p %s" % default_data_directory.short_path,
    )

    return [DefaultInfo(
        runfiles = runfiles,
        executable = exec,
        files = depset(ctx.files.config + [default_cfg_file, default_data_directory]),
    )]

prometheus_server = rule(
    implementation = _prometheus_server_impl,
    executable = True,
    doc = """Rule implements prometheus server runner""",
    attrs = {
        "config": attr.label(
            allow_single_file = True,
        ),
        "data": attr.label_list(allow_files = True),
        "scrape_jobs": attr.string(default = ""),
        "additional_contents": attr.string(default = ""),
    },
    toolchains = ["@//prometheus:toolchain"],
)
