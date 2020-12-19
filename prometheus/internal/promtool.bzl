def _promtool_unit_test_impl(ctx):
    """promtool_unit_test implementation: we spawn test runner task from template and provide required tools and actions from toolchain"""

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    promtool_info = ctx.toolchains["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"].prometheusToolchainInfo.promtool
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
    test = True,
    attrs = {
        "_action": attr.string(default = "test rules"),
        "srcs": attr.label_list(mandatory = True, allow_files = True, cfg = "target"),
        "rules": attr.label_list(mandatory = True, allow_files = True),
    },
    toolchains = ["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"],
)

def _promtool_config_test_impl(ctx):
    """promtool_unit_test implementation: we spawn executor task from template and provide required tools"""

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.

    promtool_info = ctx.toolchains["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"].prometheusToolchainInfo.promtool
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
    test = True,
    attrs = {
        "_action": attr.string(default = "check config"),
        "srcs": attr.label_list(mandatory = True, allow_files = True),
    },
    toolchains = ["@io_bazel_rules_prometheus//prometheus/internal:toolchain_type"],
)
