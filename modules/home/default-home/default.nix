{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.default-home;
  user = config.snowfallorg.user;
  classicalAliases = {
    fuggit = "git add . && git commit --amend --no-edit && git push --force";
    gcm = "git checkout main || git checkout master";
  };
  myAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    j = "jobs";
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
    gPf = "git push --force-with-lease";
    gb = "git branch";
    gd = "git diff";
    gf = "git fetch";
    grpo = "git remote prune origin";
    gau = "git add --update";
    gbl = "git blame -wCCC";
    nfu = "nix flake update --commit-lock-file";
    #TODO: feels odd putting aliases in without installing the program but I like to keep the
    #  environments separate between repos?
    k = "kubectl";
    kc = "kubectl config";
    kg = "kubectl get";
    kd = "kubectl describe";
    kcns = "kubectl config set-context --current --namespace";
    kcc = "kubectl config use-context";
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
    flushdns = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    phonesetup = ''      nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb tcpip 5555 \
            && nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb shell pm grant net.dinglisch.android.taskerm android.permission.WRITE_SECURE_SETTINGS \
            && nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb shell settings put global force_fsg_nav_bar 1
    '';
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
      nix.extraOptions = "keep-going = true";
      # TODO: Remember what the f*** this fixes and update this comment
      xdg.systemDirs = mkIf pkgs.stdenv.isLinux {
        data = ["$HOME/.nix-profile/share"];
      };

      programs = {
        readline.enable = true;
        readline.extraConfig = "set enable-bracketed-paste off";
        alacritty = {
          enable = true;
          settings = {
            window.option_as_alt = "Both";
            live_config_reload = true;
            font.size = 14;
            font.normal.family = "FiraCode Nerd Font";
            shell.program = "zellij";
            keyboard.bindings = [
              {
                key = "Equals";
                mods = "Control";
                action = "IncreaseFontSize";
              }
              {
                key = "Minus";
                mods = "Control";
                action = "DecreaseFontSize";
              }
              {
                key = "Zero";
                mods = "Control";
                action = "ResetFontSize";
              }
            ];
          };
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
        };
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
        # TODO: Look at disabling when comfortable
        bash = {
          enable = true;
          enableCompletion = true;
        };
        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        bat.enable = true;
        thefuck = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        command-not-found.enable = true;
        direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
          config.global = {
            load_dotenv = true;
            silent = true;
          };
          config.whitelist = {
            prefix = [
              "~/repos/bne"
              "~/repos/*/arichtman"
              "~/repos/gl"
              "~/repos/core"
            ];
          };
        };
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
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
            bl = "blame";
            xclean = "clean --force -x --exclude '.env'";
          };
          # Note: regex to select non-comments ^[^#\n].*
          # TODO: Generate the file from fetchURL call, run regex, remove .envrc line?
          ignores = import ./.gitignore.nix;
          signing = {
            signByDefault = true;
            key = "~/.ssh/id_ed25519.pub";
          };
          extraConfig = {
            gpg.format = "ssh";
            maintenance = {
              auto = "false";
              strategy = "incremental";
            };
            # ref: https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
            rebase = {
              updateRefs = true;
              autoStash = true;
            };
            fetch.prune = true;
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
            url = {
              "https://github.com" = {insteadOf = "gh";};
              "https://gitlab.com" = {insteadOf = "gl";};
              "https://codeberg.org" = {insteadOf = "cb";};
            };
          };
        };
        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          autocd = true;
          syntaxHighlighting.enable = true;
          initExtra = ''
            function gedditdafuckouttahere () {
              git submodule deinit --force $1 ;
              rm -fr .git/modules/$1 ;
              git rm --force $1 ;
            }
          '';
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
          # This is annoying, ideally I'd set them all in .terraformrc but some options don't seem to be available
          TF_CLI_ARGS_plan = "-compact-warnings";
          TF_CLI_ARGS_apply = "-compact-warnings";
          TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
          TF_CLI_CONFIG_FILE = "$HOME/.config/terraform/.terraformrc";
        };

        packages = with pkgs; [
          # The essentials
          dig
          wget
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
          helix # editor/ide
          nnn # file manager
          yazi # file manager
          eza # exa is unmaintained 🫣
          fira-code-nerdfont # This actually makes it available to Alacritty
          # Nix tooling
          nix-init
          nix-update
          nix-index
          nurl
          nix-bash-completions
          # Kube stuff
          kubectl
          # Lang servers
          nil # nix
          marksman # md
          terraform-ls # tf
          rust-analyzer # rust
          alejandra # nix formatter
          dprint # markdown formatting (it does more though)
          helm-ls
          yaml-language-server
          ansible-language-server
          vscode-langservers-extracted
          dockerfile-language-server-nodejs
          docker-compose-language-service
          jq-lsp
          buf-language-server
          nixd
          nil
          ruff-lsp
          #TODO: dont have these on mac, aarch64 at least
          # trippy
        ];
        file = {
          ".config/helix" = {
            source = ./helix;
            recursive = true;
          };
          ".cargo/config.toml".source = cargo/config.toml;
          ".config/terraform" = {
            source = ./terraform;
            recursive = true;
          };
          # Required to create empty directory for Terraform plugin cache since TF won't create if not exist 🙄
          # https://github.com/nix-community/home-manager/issues/2104
          ".terraform.d/plugin-cache/.keep".text = "";
          ".dprint.jsonc".source = dprint/.dprint.jsonc;
        };

        enableNixpkgsReleaseCheck = true;
        shellAliases = myAliases // classicalAliases;
      };
      # Darwin launchpad fixes
      # Ref: https://github.com/nix-community/home-manager/issues/1341#issuecomment-1870352014
      # It's kinda ugly to do it this way but I had issues with the attrset update operator and let scoping
      home.extraActivationPath = with pkgs;
        mkIf pkgs.stdenv.hostPlatform.isDarwin
        # Install MacOS applications to the user Applications folder.
        [
          rsync
          dockutil
          gawk
        ];
    };
  }
