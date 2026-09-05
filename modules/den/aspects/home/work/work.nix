{
  den.aspects.home.work = {
    homeManager = {pkgs, ...}: {
      home = {
        # Annoyingly, the precedence order of git config means the default user still overrides
        shellAliases = {
          tfpla = "tf providers lock -platform linux_amd64 -platform windows_amd64 -platform darwin_arm64";
          # Terragrunt init all found in subdirectories excluding Terragrunt caches
          tgia = "find . -not -path '*/.*' -type f -name terragrunt.hcl -execdir terragrunt init \;";
        };
        file = {
          # TODO: fill out the rest for work
          ".config/git/work/github".text = ''
            [user]
              email = "Ariel.Richtman@SilverRailTech.com"
          '';
          ".config/git/work/gitlab".text = ''
            [user]
              email = "Ariel.Richtman@SilverRailTech.com"
          '';
        };
        packages = with pkgs; [
          k9s
          awscli2
          kubectl
          terraform
          terraform-docs
          terragrunt
          prek
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
          freerdp
        ];
      };
      programs = {
        ssh = {
          enable = true;
          enableDefaultConfig = false;
          # TODO: matchBlocks deprecated
          matchBlocks = {
            "*" = {
              forwardAgent = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              compression = false;
              # addKeysToAgent = "no";
              # hashKnownHosts = "no";
              # userKnownHostsFile = "~/.ssh/known_hosts";
              # controlMaster = "no";
              # controlPath = "~/.ssh/master-%r@%n:%p";
              # controlPersist = "no";
            };
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
          settings = {
            includeIf = {
              # TODO: tidy
              # Ref: https://chaos.social/@calisti/112190526505794575
              "hasconfig:remote.*.url:git@gitlab.com:arichtman-srt/**" = {
                path = "~/.config/git/work/gitlab";
              };
              "hasconfig:remote.*.url:https://gitlab.com/arichtman-srt/**" = {
                path = "~/.config/git/work/gitlab";
              };
              "hasconfig:remote.*.url:git@github.com:arichtman-srt/**" = {
                path = "~/.config/git/work/github";
              };
              "hasconfig:remote.*.url:https://github.com/arichtman-srt/**" = {
                path = "~/.config/git/work/github";
              };
            };
          };
        };
      };
    };
  };
}
