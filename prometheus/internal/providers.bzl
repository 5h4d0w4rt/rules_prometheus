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
    },
)
