{
  den.aspects.monitoring.systemExporters = {
    nixos = {
      services = {
        prometheus.exporters.process = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.statsd = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.systemd = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.node = {
          enable = true;
          openFirewall = true;
          # I don't think this is strictly necessary for dual stack but eh
          listenAddress = "[::]";
        };
      };
    };
  };
}
