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

    #TODO: do we want these?
    useUserPackages = true;
    useGlobalPkgs = true;
    programs = {
      starship = {
        enable = true;
      };
      # Let Home Manager install and manage itself.
      home-manager.enable = true;
      #TODO: disable on mac?
      bash = {
        enable = true;
        enableCompletion = true;
        loginShellInit = ''
                eval "$(zoxide init bash)"
              '';
      };
      # I wanted to do a generic loginShellInit but $SHELL is set to <SHELL> in context
      # There's probably a Nix context value I can use but I don't know it
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
          b = "branch";
          S = "switch";
          d = "diff";
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
      #TODO: @JakeHamilton
      username = cfg.username;
      stateVersion = "22.11";

      sessionVariables = {
      #TODO: This isn't overriding the erroneous socket
        DOCKER_HOST = "";
        DIRENV_LOG_FORMAT = "";
        AWS_EC2_METADATA_DISABLED = "true";
        EDITOR = "hx";
      };

      packages = with pkgs; [
        alejandra
        helix
        zoxide
        nnn
        #TODO: does exa.enable cover this?
        exa
        #TODO: same, isn't this in config?
        direnv
        nix-direnv
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
        # TODO: remove after development
        "_modules_home_default-home_default.nix".text = "";
      };

      shellAliases = {
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";
            j = "jobs";
            k = "kill";
            ls = "exa";
            ll = "exa -@las new";
            cls = "clear";
            fuggit = "git add . && git commit --amend --no-edit && git push --force";
            fuhgetaboutit = "git branch -vv | grep ': gone]'|  grep -v '\*' | awk '{ print $1; }' | xargs -r git branch -d";
            # ref: https://medium.com/@kcmueller/delete-local-git-branches-that-were-deleted-on-remote-repository-b596b71b530c
            gc = "git checkout";
            gC = "git commit";
            gs = "git status";
            gS = "git switch";
            gp = "git pull";
            gP = "git push";
            gb = "git branch";
            gd = "git diff";
            gau = "git add --update";
            nfu = "nix flake update --commit-lock-file";
            #TODO: feels odd putting aliases in without installing the program but I like to keep the
            #  environments separate between repos?
            tgi = "terragrunt init";
            tgp = "terragrunt plan";
            tga = "terragrunt apply";
            tfi = "terraform init";
            tfp = "terraform plan";
            tfa = "terraform apply";
          };

      enableNixpkgsReleaseCheck = true;
    };
  };
}

