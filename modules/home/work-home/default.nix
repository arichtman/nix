{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.work-home;
in
  with lib; {
    options.work-home = with types; {
      enabled = mkOption {
        type = bool;
        description = "Enable work home configuration";
        default = false;
      };
    };
    config = mkIf (cfg.enabled) {
      programs = {
        ssh = {
          enable = true;
          matchBlocks = {
            gl = {
              user = "ubuntu";
              hostname = "gitlab-bne.silverrail.io";
              identityFile = "~/.ssh/gitlab-prod";
            };
            vpn = {
              user = "ubuntu";
              hostname = "vpn-bne.silverrail.io";
              identityFile = "~/.ssh/openvpn";
            };
            bb = {
              user = "ubuntu";
              hostname = "bamboo.silverrailtech.net";
              identityFile = "~/.ssh/AWS-DevTest.pem";
            };
            art = {
              user = "ubuntu";
              hostname = "artifactory-bne.silverrail.io";
              identityFile = "~/.ssh/artifactory_main-instance";
            };
          };
        };
        git = {
          extraConfig = {
            "includeIf \"gitdir:~/repos/gh/arichtman/\"" = {
              path = "~/.config/git/personal";
            };
          };
        };
      };
      home = {
        # Annoyingly, the precedence order of git config means the default user still overrides
        shellAliases."set-private-git-config" = "git config user.email '10679234+arichtman@users.noreply.github.com' ; git config user.name 'Ariel Richtman'";
        file = {
          ".config/git/personal".text = ''
            [user]
              email = "10679234+arichtman@users.noreply.github.com"
              name = "Ariel Richtman"
          '';
        };
        packages = with pkgs; [
          git-remote-codecommit
          teams
          slack
          zoom-us
          k9s
          awscli2
          kubectl
          (terraform.overrideAttrs (self: {
            # lol this isn't even v1.6.4??? I hate nixpkgs pinning story
            version = "1.6.4";
            src = fetchFromGitHub {
              owner = "hashicorp";
              repo = "terraform";
              rev = "v${self.version}";
              # hash = lib.fakeSha256;
              hash = "sha256-k/ugXlHK7lEKfOpSBXQNUdcq26rVVdjo53U+7ChJLIc=";
            };
          }))
          terragrunt
          # Ref: https://github.com/NixOS/nixpkgs/issues/291753
          # mitmproxy
          kubernetes-helm
          docker-client
          docker-buildx
          docker-compose
          docker-ls
          docker-slim
          docker-gc
          dive
          lazydocker
          docker-credential-helpers
        ];
      };
    };
  }
