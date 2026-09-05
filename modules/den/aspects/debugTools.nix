{
  den.aspects.debugTools = {
    nixos = {pkgs, ...}: {
      environment = {
        shellAliases = {
          sc = "systemctl";
          jc = "journalctl -xeu";

          k = "kubectl";

          nr = "nixos-rebuild";
          nrt = "nr test --flake .";

          sci = "step certificate inspect";
        };
        systemPackages = with pkgs; [
          git
          helix
          step-cli
          jq
          yq
          tcpdump
          trippy
          bpftools
          ethtool
          btop
          sysstat
          perf
          dig
          file
          pwru
        ];
      };
    };
  };
}
