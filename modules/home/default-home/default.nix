{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.default-home;
  user = config.snowfallorg.user;
  classicalAliases = {
    fuggit = "git add . && git commit --amend --no-edit && git push --force";
    gcm = "git checkout main || git checkout master";
    # ref: https://medium.com/@kcmueller/delete-local-git-branches-that-were-deleted-on-remote-repository-b596b71b530c
    fuhgetaboutit = "git branch -vv | grep ': gone]'|  grep -v '\*' | awk '{ print $1; }' | xargs -r git branch -d";
  };
  myAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    j = "jobs";
    k = "kill";
    ee = "exit 0";
    sc = "sudo systemctl";
    jc = "journalctl -xe";
    ls = "exa";
    ll = "exa -las new";
    cls = "clear";
    vi = "hx";
    vim = "hx";
    nano = "hx";
    pico = "hx";
    gc = "git checkout";
    gC = "git commit";
    gs = "git status";
    gS = "git switch";
    gp = "git pull";
    gP = "git push";
    gb = "git branch";
    gd = "git diff";
    gf = "git fetch";
    grpo = "git remote prune origin";
    gau = "git add --update";
    nfu = "nix flake update --commit-lock-file";
    #TODO: feels odd putting aliases in without installing the program but I like to keep the
    #  environments separate between repos?
    kc = "kubectl";
    kcc = "kubectl config";
    kcg = "kubectl get";
    kcd = "kubectl describe";
    kcns = "kubectl config set-context --current --namespace";
    kccc = "kubectl config use-context";
    tg = "terragrunt";
    tgv = "terragrunt validate";
    tgi = "terragrunt init";
    tgp = "terragrunt plan";
    tga = "terragrunt apply";
    tgaa = "terragrunt apply -auto-approve";
    tf = "terraform";
    tfv = "terraform validate";
    tfi = "terraform init";
    tfp = "terraform plan";
    tfa = "terraform apply";
    tfaa = "terraform apply -auto-approve";
  };
in
  with lib; {
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
        data = ["$HOME/.nix-profile/share"];
      };

      programs = {
        alacritty = {
          enable = true;
          settings = {
            window.option_as_alt = "Both";
            live_config_reloade = true;
            font.size = 14;
            font.normal.family = "FiraCode Nerd Font";
            shell.program = "zellij";
          };
        };
        nushell = {
          # enable = true;
          environmentVariables = {
            EDITOR = "hx";
            # TODO: Not sure if worth doing "better".
            #  the .bashrc switcheroo doesn't update the environment which
            #  might majorly fuck with some scripts
            SHELL = "nu";
          };
          shellAliases = myAliases;
          configFile.text = ''
            $env.config = { show_banner: false }
          '';
        };
        zellij = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          settings = {};
        };
        starship = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
        # TODO: Look at disabling when comfortable
        # It may never make sense though as system shell is bash
        #  so in any fallback scenario you'd still like to have your aliases/PATH set.
        bash = {
          enable = true;
          enableCompletion = true;
          bashrcExtra = ''
            if [[ $- == *i* ]] && [[ ! -z "$(command -v nu)" ]]; then
              exec nu "$@"
            fi
          '';
        };
        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };
        # I wanted to do a generic loginShellInit but $SHELL is set to <SHELL> in context
        # There's probably a Nix context value I can use but I don't know it
        bat.enable = true;
        # TODO: This is also not being found as valid??
        # thefuck.enable = true;
        command-not-found.enable = true;
        direnv = {
          enable = true;
          #TODO: enable zsh integration possible?
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          nix-direnv.enable = true;
          config.global = {
            load_dotenv = true;
            silent = true;
          };
          config.whitelist = {
            prefix = [
              "$HOME/repos/bne"
              "$HOME/repos/arichtman"
            ];
          };
        };
        fzf = {
          enable = true;
          #TODO: enable zsh integreation possible?
          enableBashIntegration = true;
        };
        gpg.enable = true;
        htop.enable = true;
        jq.enable = true;
        less.enable = true;
        git = {
          enable = true;
          delta.enable = true;
          lfs.enable = true;
          userEmail = cfg.git.email;
          userName = cfg.git.username;
          aliases = {
            c = "commit";
            co = "checkout";
            s = "status";
            b = "branch";
            S = "switch";
            d = "diff";
            f = "fetch";
          };
          # Note: regex to select non-comments ^[^#\n].*
          # TODO: Generate the file from fetchURL call, run regex, remove .envrc line
          ignores = import ./.gitignore.nix;
          extraConfig = {
            # ref: https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
            rebase = {
              updateRefs = true;
              autoStash = true;
            };
            merge.autoStash = true;
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
        zsh = {
          enable = true;
          enableCompletion = true;
          enableAutosuggestions = true;
          autocd = true;
          syntaxHighlighting.enable = true;
          initExtra = ''
            function gedditdafuckouttahere () {
              git submodule deinit --force $1 ;
              rm -fr .git/modules/$1 ;
              git rm --force $1 ;
            }
          '';
          #TODO: check if direnv/nix-direnv adds shell completion/hooks anyhow
          #  or these can be enabled by config
          #TODO: see about using something like basename ${0/-/} to generalize shell init
        };
        carapace = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
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
        stateVersion = "22.11";

        sessionVariables = {
          # TODO: Remove if subsumed by silent = true
          DIRENV_LOG_FORMAT = "";
          AWS_EC2_METADATA_DISABLED = "true";
          EDITOR = "hx";
          TF_CLI_ARGS_plan = "-compact-warnings";
          TF_CLI_ARGS_apply = "-compact-warnings";
        };

        packages = with pkgs; [
          # Ref: https://github.com/ibraheemdev/modern-unix
          xh # curl replacement
          dog # dig replacement
          procs # ps replacement
          du-dust # du replacement
          duf # df replacement
          sd # sed replacement
          gping # ping replacement
          broot # tree + tui navigation
          choose # cut/awk replacement
          ripgrep # find replacement
          jless # json tui
          # Nix tooling
          nix-init
          nix-update
          nix-index
          nurl
          # Lang servers
          nil # nix
          marksman # md
          terraform-ls # tf
          rust-analyzer # rust
          alejandra # nix formatter
          helix # editor/ide
          nnn # file manager
          thefuck # the infamous
          dprint # markdown formatting (it does more though)
          # exa # ls replacement
          eza # exa is unmaintained 🫣
          # The essentials
          dig
          wget
          # whois
          #TODO: dont have these on mac, aarch64 at least
          # trippy
          # This actually makes it available to Alacritty
          fira-code-nerdfont
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
          ".dprint.jsonc".source = dprint/.dprint.jsonc;
        };

        enableNixpkgsReleaseCheck = true;
        shellAliases = myAliases // classicalAliases;
      };
    };
  }
