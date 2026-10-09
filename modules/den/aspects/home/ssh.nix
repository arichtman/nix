{
  den.aspects.home.ssh = {
    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "Host nixos *.systems.richtman.au *.local" = {
            user = "nixos";
          };
          "Host *.local" = {
            user = "nixos";
          };
          "Host proxmox.*" = {
            user = "root";
          };
          "Host opnsense.*" = {
            user = "root";
          };
          "Host github" = {
            hostname = "github.com";
            user = "git";
          };
          # No port forwarding at present on the router as site2site VPN is in place
          # "Host probics" = {
          #   user = "User";
          #   hostname = "mm3756c.glddns.com";
          #   identityFile = "~/.ssh/probics-home";
          #   port = 2222;
          #   # THe ports might be backwards here...
          #   localForward = "5000 localhost:3389";
          # };
          "Host ap" = {
            user = "chanya";
            hostname = "ap.internal";
          };
          os = {
            hostname = "opnsense.internal";
          };
          pm = {
            hostname = "proxmox.internal";
          };
        };
      };
    };
  };
}
