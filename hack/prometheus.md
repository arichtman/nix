# Prometheus

```
# TSDB status
curl -s http://localhost:9090/api/v1/status/tsdb | \
  jq '.data' | jq ' . '

# Top metrics by cardinality
curl -s http://localhost:9090/api/v1/status/tsdb | \
  jq '.data.seriesCountByMetricName | sort_by(.value) | reverse | .[0:10]'

# Check specific label on metric for cardinality
curl -s 'http://localhost:9090/api/v1/label/$LABEL/values' | jq '.data | length'

# Check total series count
curl -s 'http://localhost:9090/api/v1/query?query=prometheus_tsdb_head_series' | \
  jq '.data.result[0].value[1]'

# Series count by label pairs
curl -s http://localhost:9090/api/v1/status/tsdb | \
  jq '.data.seriesCountByLabelValuePair | sort_by(.value) | reverse | .[0:20]'
```

Prometheus query times: `prometheus_engine_query_duration_seconds{slice="inner_eval", quantile="0.9"}`

Rule evaluation times: `prometheus_rule_evaluation_duration_seconds{quantile="0.9"}`

Prom memory growth: `rate(process_resident_memory_bytes{job="prometheus"}[1h])`

Relabeled samples vs original: `scrape_samples_post_metric_relabeling - scrape_samples_scraped  > 0`

## References

- [Cardinality problms blog](https://infrarunbook.com/article/prometheus-high-cardinality-issues)
- [MR sample metrics description](https://github.com/prometheus/docs/pull/709/changes)
- [3rd party prom library](https://promhub.shipit.dev/)
