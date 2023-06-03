{ options, config, pkgs, lib, inputs, ... }:
let
  cfg = config.arichtman.default-home;
in
with lib;
{
  #TODO: This didn't solve our missing config options
  # imports = with inputs; [
  #   home-manager.nixosModules.home-manager
  # ];
  options.arichtman.default-home = with types; {
    username = mkOption {
      type = str;
      description = "Username";
    };
    git = {
      email = mkOption {
        type = str;
        description = "Email to use in git config";
      };
      username = mkOption {
        type = str;
        description = "Username to use in git config";
      };
    };
  };
    config = mkIf (cfg.username != "") {
      home-manager = {
        #TODO: sort out whether we want global or user packages
        # useUserPackages = true;
        useGlobalPkgs = true;
        #TODO: Consider pulling the username from the first key in cfg.users.user
        #  basically all of my systems are only defined for a single user
        users.${cfg.username} = {
          xdg.systemDirs.data = ["$HOME/.nix-profile/share"];

          programs = {
            starship = {
              enable = true;
            };
            # Let Home Manager install and manage itself.
            home-manager.enable = true;
            bash = {
              enable = true;
              enableCompletion = true;
            };
            bat.enable = true;
            command-not-found.enable = true;
            direnv = {
              enable = true;
              enableBashIntegration = true;
              nix-direnv.enable = true;
            };
            fzf = {
              enable = true;
              enableBashIntegration = true;
            };
            gpg.enable = true;
            htop.enable = true;
            jq.enable = true;
            less.enable = true;
            git = {
              lfs.enable = true;
              userEmail = cfg.git.email;
              userName = cfg.git.username;
              enable = true;
              aliases = {
                c = "commit";
                co = "checkout";
                s = "status";
              };
              extraConfig = {
                init.defaultBranch = "main";
                pull = {
                  rebase = true;
                };
                protocol = {
                  http.allow = "never";
                  git.allow = "never";
                };
                credential.helper = "store";
                push = {
                  autoSetupRemote = true;
                  default = "current";
                };
              };
            };
          };
          editorconfig = {
            enable = true;
            settings = {
              "*" = {
                indent_size = 2;
                indent_style = "space";
              };
            };
          };
          home = {
            username = cfg.username;
            homeDirectory = "/home/${cfg.username}";

            stateVersion = "22.11";
            sessionVariables = {
              DIRENV_LOG_FORMAT = "";
              AWS_EC2_METADATA_DISABLED = "true";
              EDITOR = "hx";
            };
           packages = with pkgs; [
            vscode-extensions.mkhl.direnv
            vscode-extensions.rust-lang.rust-analyzer
            alejandra
            helix
          ];
          file = {
            ".config/helix" = {
              source = ./helix;
              recursive = true;
            };
            ".cargo/config.toml".source = cargo/config.toml;
            ".terraformrc".source = terraform/.terraformrc;
            # Required to create empty directory for Terraform plugin cache since TF won't create if not exist 🙄
            # https://github.com/nix-community/home-manager/issues/2104
            ".terraform.d/plugin-cache/.keep".text = "";
          };
          shellAliases = {
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";
            ls = "exa";
            cls = "clear";
            gs = "git status";
            fuggit = "git add . && git commit --amend --no-edit && git push --force";
            gc = "git checkout";
            gS = "git switch";
            gp = "git pull";
            gP = "git push";
            gau = "git add --update";
            nfu = "nix flake update";
          };
          enableNixpkgsReleaseCheck = true;
        };
      };
    };
  };
}