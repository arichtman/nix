# Ref: https://github.com/grafana/intro-to-mltp/blob/main/tempo/tempo.yaml
# Ref: https://github.com/euank/yaml2nix
{
  stream_over_http_enabled = true;
  server = {http_listen_port = 3200;};
  distributor = {
    receivers = {
      jaeger = {
        protocols = {
          thrift_http = null;
          grpc = null;
          thrift_binary = null;
          thrift_compact = null;
        };
      };
      otlp = {
        protocols = {
          http = {endpoint = "0.0.0.0:4318";};
          grpc = {endpoint = "0.0.0.0:4317";};
        };
      };
      zipkin = null;
    };
  };
  ingester = {
    trace_idle_period = "10s";
    max_block_bytes = "1_000_000";
    max_block_duration = "5m";
  };
  compactor = {
    compaction = {
      compaction_window = "1h";
      max_block_bytes = "100_000_000";
      block_retention = "1h";
      compacted_block_retention = "10m";
    };
  };
  storage = {
    trace = {
      backend = "local";
      block = {bloom_filter_false_positive = 5.0e-2;};
      wal = {path = "/tmp/tempo/wal";};
      local = {path = "/tmp/tempo/blocks";};
      pool = {
        max_workers = 100;
        queue_depth = 10000;
      };
    };
  };
  metrics_generator = {
    processor = {
      span_metrics = {
        dimensions = ["http.method" "http.target" "http.status_code" "service.version"];
      };
      service_graphs = {
        dimensions = ["http.method" "http.target" "http.status_code" "service.version"];
      };
      local_blocks = {flush_to_storage = true;};
    };
    registry = {
      collection_interval = "5s";
      external_labels = {
        source = "tempo";
        group = "mythical";
      };
    };
    storage = {
      path = "/tmp/tempo/generator/wal";
      remote_write = [
        {
          url = "http://mimir:9009/api/v1/push";
          send_exemplars = true;
        }
      ];
    };
    traces_storage = {path = "/tmp/tempo/generator/traces";};
  };
  overrides = {
    defaults = {
      metrics_generator = {
        processors = ["service-graphs" "span-metrics" "local-blocks"];
        generate_native_histograms = "both";
      };
    };
  };
}
