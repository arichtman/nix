{lib, ...}: let
  downloadGitignore = arguments @ {
    languages ? [],
    hash ? lib.fakeSha256,
    # Allow variadic arguments so we have one API
    ...
  }:
    builtins.fetchurl {
      url = "https://www.toptal.com/developers/gitignore/api/${lib.concatStringsSep "," arguments.languages}";
      name = "myGitignore"; # Required as both "," and "%2C" are invalid store paths
      # For some godforsaken reason arguments.hash bombs on missing property
      sha256 = hash;
    };
in rec {
  fetchGrafanaDashboard = arguments @ {
    id,
    revision,
    name,
    hash ? lib.fakeSha256,
  }:
    builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/${builtins.toString id}/revisions/${builtins.toString revision}/download";
      name = name;
      sha256 = hash;
    };
  promLocalHostRelabelConfigs = [
    # TODO: Work out why localhost relabel and label override aren't working
    # Relabel localhost so we don't have to open metrics to the world
    {
      source_labels = ["__address__"];
      regex = ".*localhost.*";
      target_label = "instance";
      replacement = "fat-controller.systems.richtman.au";
    }
    # Remove port numbers
    {
      source_labels = ["__address__"];
      regex = "(.+):.*";
      target_label = "instance";
      replacement = "\${1}";
    }
  ];
  mkLocalScrapeConfig = name: port: {
    job_name = builtins.toString name;
    relabel_configs = promLocalHostRelabelConfigs;
    honor_labels = false;
    static_configs = [
      {
        targets = [
          "localhost:${builtins.toString port}"
        ];
        labels = {
          instance = "fat-controller.systems.richtman.au";
        };
      }
    ];
  };
  net = {
    ip6 = {
      prefix = "2403:581e:ab78";
      # TODO: figure out why arichtman doesn't exist on this lib
      # prefixCIDR = "${lib.arichtman.net.ip6.prefix}::/48";
      prefixCIDR = "2403:581e:ab78::/48";
      subnet = "2403:581e:ab78::/64";
      wireguardCIDR = "fd00:f423:5624:9f39::/64";
    };
    ip4 = {
      subnet = "192.168.1.0/24";
    };
  };
  # Pass-through the function in case people want plain gitignores
  inherit downloadGitignore;
  sourceGitignoreList = arguments @ {
    # Default this to a no-op processing where every list item is retained.
    # TODO: Allow this to take a list of functions and recurse down to progressively apply them.
    filterFunction ? (_: true),
    ...
  }: let
    gitignoreFile = downloadGitignore arguments;
    rawText = builtins.readFile gitignoreFile;
    splitList = builtins.split "\n" rawText;
    pureList = builtins.filter (x: x != []) splitList;
  in
    builtins.filter filterFunction pureList;
}
