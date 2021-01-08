```
/usr/bin/env bash

# example script for starting backfilled prometheus from openmetrics data documented for later
# bazel run -- //:promtool tsdb create-blocks-from openmetrics -r prometheus/internal/testseries.om testdata/
# /bazel-rules_prometheus/external/prometheus_darwin/prometheus --config.file=./examples/prometheus.yml --storage.tsdb.path=./testdata/
```