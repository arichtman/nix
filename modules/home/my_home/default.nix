{ options, config, pkgs, lib, inputs, ... }:
let
  cfg = config.default-home;

  user = config.snowfallorg.user;
in
with lib;
{
  options.default-home = with types; {
    username = mkOption {
      type = str;
      description = "Username";
      default = user.name;
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

  config = {
    xdg.systemDirs = mkIf pkgs.stdenv.isLinux {
      data = [ "$HOME/.nix-profile/share" ];
    };

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
      stateVersion = "22.11";

      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
        AWS_EC2_METADATA_DISABLED = "true";
      };

      packages = with pkgs; [
        vscode-extensions.mkhl.direnv
        vscode-extensions.rust-lang.rust-analyzer
        alejandra
      ];

      file = {
        ".config/helix/config.toml".source = helix/config.toml;
        ".config/helix/languages.toml".source = helix/languages.toml;
        ".cargo/config.toml".source = cargo/config.toml;
      };

      shellAliases = {
        ll = "ls -thrALl";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
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

      # enableNixpkgsReleaseCheck = true;
    };
  };
}

