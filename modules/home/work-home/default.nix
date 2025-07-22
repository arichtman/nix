{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.work-home;
in
  with lib; {
    options.work-home.enabled = lib.mkEnableOption "Enable work home configuration";
    config = mkIf cfg.enabled {
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
            # Ref: https://chaos.social/@calisti/112190526505794575
            includeIf = {
              "hasConfig:remote.*.url:https://github.com/arichtman/**" = {path = "~/.config/git/personal";};
              "hasConfig:remote.*.url:git@github.com:arichtman/**" = {path = "~/.config/git/personal";};
            };
            "includeIf \"gitdir:~/repos/gh/arichtman/\"" = {
              path = "~/.config/git/personal";
            };
          };
        };
      };
      home = {
        # Annoyingly, the precedence order of git config means the default user still overrides
        shellAliases = {
          "set-private-git-config" = "git config user.email '10679234+arichtman@users.noreply.github.com' ; git config user.name 'Ariel Richtman'";
          tfpla = "tf providers lock -enable-plugin-cache -platform linux_amd64 -platform windows_amd64 -platform darwin_arm64";
        };
        file = {
          ".config/git/personal".text = ''
            [user]
              email = "10679234+arichtman@users.noreply.github.com"
              name = "Ariel Richtman"
          '';
        };
        packages = with pkgs; [
          git-remote-codecommit
          k9s
          awscli2
          kubectl
          terraform
          # TODO: clean back up when build is fixed
          inputs.nixpkgs-release.legacyPackages.${system}.terragrunt
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
          taplo
        ];
      };
    };
  }
