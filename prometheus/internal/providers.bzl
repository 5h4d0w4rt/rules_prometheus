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
