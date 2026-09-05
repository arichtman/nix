{inputs, ...}: {
  # TODO: Consider flake-file for shoving limited inputs into files https://flake-file.denful.dev/
  # flake-file.inputs.nixocaine.url = "https://git.madhouse-project.org/iocaine/nixocaine/archive/main.tar.gz";
  den.aspects.controller.iocaine = {
    nixos = let
      # Easier to make it a string than have to call toString
      iocainePort = "42069";
      iocaineMetricsPort = "42042";
    in
      {host}: {
        imports = with inputs.nixocaine.nixosModules; [
          default
        ];

        # Ref: https://iocaine.madhouse-project.org/documentation/3/getting-started/nixos/
        services = {
          iocaine = {
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
          caddy = {
            extraConfig = ''
              (iocaine) {
                @read method GET HEAD
                reverse_proxy @read [::1]:${iocainePort} {
                  @fallback status 421
                  handle_response @fallback
                }
              }
            '';
          };
          prometheus.scrapeConfigs = [(host.mkLocalScrapeConfig "iocaine" iocaineMetricsPort)];
        };
      };
  };
}
