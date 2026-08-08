{
  config,
  lib,
  ...
}: let
  # Easier to make it a string than have to call toString
  iocainePort = "42069";
  iocaineMetricsPort = "42042";
in {
  # Ref: https://iocaine.madhouse-project.org/documentation/3/getting-started/nixos/
  config = lib.mkIf config.control-node.enable {
    services.iocaine = {
      enable = true;
      config = {
        server = {
          default = {
            bind = "[::1]:${iocainePort}";
            mode = "http";
            use.handler-from = "default";
            use.metrics = "metrics";
          };
          metrics = {
            bind = "[::1]:${iocaineMetricsPort}";
            mode = "prometheus";
            persist-path = "qmk-metrics.json";
            persist-interval = "1h";
          };
        };
        handler.default.config = {
          "ai-robots-txt-path" = "/etc/iocaine/data/ai.robots.txt-robots.json";
          sources = {
            "training-corpus" = [
              "/etc/iocaine/data/corpus/1984.txt"
              "/etc/iocaine/data/corpus/brave-new-world.txt"
            ];
            "wordlists" = ["/etc/iocaine/data/corpus/words.txt"];
          };
        };
      };
    };
    services.prometheus.scrapeConfigs = [(lib.arichtman.mkLocalScrapeConfig "iocaine" iocaineMetricsPort)];
  };
}
