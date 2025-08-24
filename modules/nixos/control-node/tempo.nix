{
  config,
  lib,
  ...
}: {
  config.services = lib.mkIf config.control-node.enable {
    grafana.provision.datasources.settings.datasources = [
      {
        # Ref: https://grafana.com/docs/grafana/latest/datasources/tempo/configure-tempo-data-source/#provision-the-data-source
        name = "tempo";
        type = "tempo";
        url = "http://localhost6:${toString config.services.tempo.settings.server.http_listen_port}";
        jsonData = {
          tracesToMetrics = {
            datasourceUid = "prometheus";
            # spanStartTimeShift = "-1h";
            # spanEndTimeShift = "1h";
            # tags = [{ key = "service.name"; value = "service"; }
            #   { key = "job"; }];
            # queries = [{ name = "Sample query"; query = "sum(rate(traces_spanmetrics_latency_bucket{$$__tags}[5m]))"; }];
          };
          # tracesToLogsV2 = {
          #   datasourceUid = "loki";
          #   spanStartTimeShift = "-1h";
          #   spanEndTimeShift = "1h";
          #   tags = [ "job" "instance" "pod" "namespace" ];
          #   filterByTraceID = false;
          #   filterBySpanID = false;
          #   customQuery = true;
          #   query = "method=\"$\${__span.tags.method}\"";
          # };
          # tracesToProfiles = {
          #   datasourceUid = "grafana-pyroscope-datasource";
          #   tags = [ "job" "instance" "pod" "namespace" ];
          #   profileTypeId = "process_cpu:cpu:nanoseconds:cpu:nanoseconds";
          #   customQuery = true;
          #   query = "method=\"$\${__span.tags.method}\"";
          # };
          serviceMap = {datasourceUid = "prometheus";};
          nodeGraph = {enabled = true;};
          search = {hide = false;};
          # traceQuery = {
          #   timeShiftEnabled = true;
          #   spanStartTimeShift = "-1h"; spanEndTimeShift = "1h";
          # };
          spanBar = {
            type = "Tag";
            tag = "http.path";
          };
          streamingEnabled = {
            search = true;
            metrics = true;
          };
        };
      }
    ];
    tempo = {
      enable = true;
      # I don't care so much but it's blocked by my firewall and so noisy in the logs
      extraFlags = ["-reporting.enabled=false"];
      # Ref: https://github.com/grafana/intro-to-mltp/blob/main/tempo/tempo.yaml
      # Ref: https://grafana.com/docs/tempo/latest/configuration/
      settings = {
        stream_over_http_enabled = true;
        server = {
          # Otherwise this tries to bind to 80, which is taken of course.
          http_listen_port = 3200;
          # You would THINK v6 localhost only works, but it doesn't.
          # Somehow back-end it makes the IP into a v4 localhost, which of course we're not bound to.
          # Same dealio with the frontend query worker I think
          # Fuck this noise it can just be firewalled
          # Localhost only for security, all our Grafana queries go thru Grafana anyhow
          # Possibly useful in future
          # Ref: https://github.com/grafana/tempo/blob/main/docs/sources/tempo/configuration/network/ipv6.md
          http_listen_address = "::";
          grpc_listen_address = "::";
          # Annoyingly it says "lookup: no such host" which, no duh, I just want it to bind to my delegated prefix
          # http_listen_address = "${lib.arichtman.net.ip6.prefixCIDR}";
        };
        distributor = {
          receivers = {
            otlp = {
              protocols = {
                http = {endpoint = "[::]:4318";};
                grpc = {endpoint = "[::]:4317";};
              };
            };
          };
        };
        storage = {
          trace = {
            backend = "local";
            local = {
              path = "/var/lib/tempo";
            };
            wal = {
              path = "/var/lib/tempo/wal";
            };
          };
        };
        # querier = {
        #   frontend_worker = {frontend_address = "[::]:9095";};
        # };
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
            path = "/var/lib/tempo/generator/wal";
          };
          traces_storage = {path = "/var/lib/tempo/generator/traces";};
        };
      };
    };
  };
}
