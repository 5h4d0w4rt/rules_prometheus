def _promtool_impl(ctx):
    promtool_info = (
        ctx.toolchains["@io_bazel_rules_prometheus//prometheus:toolchain"]
            .prometheusToolchainInfo
            .promtool
    )
    promtool_unit_test_runner_template = ctx.file._template
    exec = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    runfiles = ctx.runfiles(
        files = ctx.files._template,
        transitive_files = promtool_info.tool.files,
    )
    ctx.actions.expand_template(
        template = promtool_unit_test_runner_template,
        output = exec,
        is_executable = True,
        substitutions = {
            "%tool_path%": "%s" % promtool_info.tool.files_to_run.executable.short_path,
        },
    )
    return [DefaultInfo(runfiles = runfiles, executable = exec)]

_promtool = rule(
    implementation = _promtool_impl,
    doc = """Private rule implemented for invocation in public promtool() runner""",
    attrs = {
        "_template": attr.label(
            default = Label("@io_bazel_rules_prometheus//prometheus/internal:promtool.manual_runner.sh.tpl"),
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@io_bazel_rules_prometheus//prometheus:toolchain"],
)

def promtool(name, **kwargs):
    """Promtool runner which will launch promtool

    This rule will emit runnable sh_binary target which will invoke promtool binary and all passed arguments along.
        Tool will have access to workspace. It is intended for convenient in-workspace usage by human and not to be invoked programmatically.

    Example:
    ```
    //:promtool
    load("//prometheus:defs.bzl", "promtool")

    package(default_visibility = ["//visibility:public"])

    promtool(
        name = "promtool",
    )
    ```

    Args:
      name: A unique name for this target.
      **kwargs: Attributes to be passed along
    """
    runner = name + "-runner"
    _promtool(
        name = runner,
        tags = ["manual"],
        **kwargs
    )
    native.sh_binary(
        name = name,
        srcs = [runner],
        tags = ["manual"],
    )

def _promtool_unit_test_impl(ctx):
    """promtool_unit_test implementation: we spawn test runner task from template and provide required tools and actions from toolchain"""

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    promtool_info = (
        ctx.toolchains["@io_bazel_rules_prometheus//prometheus:toolchain"]
            .prometheusToolchainInfo
            .promtool
    )
    promtool_unit_test_runner_template = promtool_info.template.files.to_list()[0]

    runfiles = ctx.runfiles(
        files = ctx.files.srcs + ctx.files.rules,
        transitive_files = promtool_info.tool.files,
    )

    test = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = promtool_unit_test_runner_template,
        output = test,
        is_executable = True,
        substitutions = {
            "%srcs%": " ".join([_file.short_path for _file in ctx.files.srcs]),
            "%tool_path%": "%s" % promtool_info.tool.files_to_run.executable.short_path,
            "%action%": ctx.attr._action,
        },
    )
    return [DefaultInfo(runfiles = runfiles, executable = test)]

promtool_unit_test = rule(
    implementation = _promtool_unit_test_impl,
    doc = """
Run "promtool test rules" against test targets and rules files

Example:
```
//examples:unit_test_rules_yml

load("//prometheus:defs.bzl", "promtool_unit_test")
promtool_unit_test(
name = "unit_test_rules_yml",
srcs = [
"tests.yml",
],
rules = ["rules.yml"],
)
```

```bash
bazel test //examples:unit_test_rules_yml

//examples:unit_test_rules_yml                                                PASSED in 0.1s
```

""",
    test = True,
    attrs = {
        "_action": attr.string(default = "test rules"),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            cfg = "target",
            doc = "List of Prometheus Unit Test file targets",
        ),
        "rules": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "List of Rules-under-Test file targets",
        ),
    },
    toolchains = ["@io_bazel_rules_prometheus//prometheus:toolchain"],
)

def _promtool_config_test_impl(ctx):
    """promtool_unit_test implementation: we spawn executor task from template and provide required tools"""

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.

    promtool_info = (
        ctx.toolchains["@io_bazel_rules_prometheus//prometheus:toolchain"]
            .prometheusToolchainInfo
            .promtool
    )
    promtool_unit_test_runner_template = promtool_info.template.files.to_list()[0]

    runfiles = ctx.runfiles(
        files = ctx.files.srcs,
        transitive_files = promtool_info.tool.files,
    )

    test = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = promtool_unit_test_runner_template,
        output = test,
        is_executable = True,
        substitutions = {
            "%srcs%": " ".join([_file.short_path for _file in ctx.files.srcs]),
            "%tool_path%": "%s" % promtool_info.tool.files_to_run.executable.short_path,
            "%action%": ctx.attr._action,
        },
    )
    return [DefaultInfo(runfiles = runfiles, executable = test)]

promtool_config_test = rule(
    implementation = _promtool_config_test_impl,
    doc = """
Run "promtool check config" against config targets

Example:
```
//examples:test_config_yml

load("//prometheus:defs.bzl", "promtool_config_test")
promtool_config_test(
    name = "test_config_yml",
    srcs = ["prometheus.yml"],
)
```

```bash
bazel test //examples:test_config_yml

//examples:test_config_yml                                      PASSED in 0.1s
```
""",
    test = True,
    attrs = {
        "_action": attr.string(default = "check config"),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "List of prometheus configuration targets",
        ),
    },
    toolchains = ["@io_bazel_rules_prometheus//prometheus:toolchain"],
)

def _promtool_rules_test_impl(ctx):
    promtool_info = (
        ctx.toolchains["@io_bazel_rules_prometheus//prometheus:toolchain"]
            .prometheusToolchainInfo
            .promtool
    )
    promtool_unit_test_runner_template = promtool_info.template.files.to_list()[0]

    runfiles = ctx.runfiles(
        files = ctx.files.srcs,
        transitive_files = promtool_info.tool.files,
    )

    test = ctx.actions.declare_file("%s.out.sh" % ctx.label.name)

    ctx.actions.expand_template(
        template = promtool_unit_test_runner_template,
        output = test,
        is_executable = True,
        substitutions = {
            "%srcs%": " ".join([_file.short_path for _file in ctx.files.srcs]),
            "%tool_path%": "%s" % promtool_info.tool.files_to_run.executable.short_path,
            "%action%": ctx.attr._action,
        },
    )
    return [DefaultInfo(runfiles = runfiles, executable = test)]

promtool_rules_test = rule(
    implementation = _promtool_config_test_impl,
    doc = """
Run "promtool check rules" against rules targets

Example:
```
//examples:test_rules_yml
promtool_rules_test(
    name = "test_rules_yml",
    srcs = ["rules.yml"],
)
```

```bash
bazel test //examples:test_rules_yml

//examples:unit_test_rules_yml                                           PASSED in 0.3s
```
""",
    test = True,
    attrs = {
        "_action": attr.string(default = "check rules"),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "List of Prometheus rules file targets",
        ),
    },
    toolchains = ["@io_bazel_rules_prometheus//prometheus:toolchain"],
)
