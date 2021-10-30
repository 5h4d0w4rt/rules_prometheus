PromtoolInfo = provider(
    doc = "Promtool metadata provider",
    fields = {
        "tool": "Promtool label",
        "template": "Template script that will be filled with execution details",
    },
)

PrometheusInfo = provider(
    doc = "Prometheus server metadata provider",
    fields = {
        "tool": "Prometheus label",
        "template": "Template script that will be filled with execution details",
    },
)

AlertmanagerStubInfo = provider(
    doc = "Alertmanager metadata provider stub",
    fields = {
        # "tool": "Alertmanager label",
        # "template": "Template script that will be filled with execution details",
    },
)
AlertmanagerInfo = AlertmanagerStubInfo

AmtoolStubInfo = provider(
    doc = "Amtool metadata provider stub",
    fields = {
        # "tool": "Amtool label",
        # "template": "Template script that will be filled with execution details",
    },
)
AmtoolInfo = AmtoolStubInfo

PrometheusPlatformsInfo = provider(
    # this should store os-arch combinations for toolchain generation
    doc = "OS and CPU platforms, constraints and available architectures metadata provider",
    fields = {
        "platforms": "mapping of PrometheusPlatformInfo providers",
        "available_platforms": "list of platforms",
    },
)

PrometheusPlatformInfo = provider(
    # this should store os-arch combinations for toolchain generation
    doc = "OS and CPU platform constraints metadata provider",
    fields = [
        "os",
        "cpu",
    ],
)
