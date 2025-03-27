{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.default-home;
  inherit (config.snowfallorg) user;
  classicalAliases = {
    fuggit = "git add . && git commit --amend --no-edit && git push --force";
    gcm = "git checkout main || git checkout master";
  };
  myAliases =
    {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      j = "jobs";
      ee = "exit 0";
      sc = "sudo systemctl";
      jc = "journalctl -xeu";
      nm = "sudo nmcli";
      rc = "sudo resolvectl";
      ls = "exa";
      ll = "exa -las new";
      cls = "clear";
      de = "direnv";
      dea = "de allow";
      der = "de reload";
      vi = "hx";
      vim = "hx";
      nano = "hx";
      pico = "hx";
      hxv = "hx --vsplit";
      g = "git";
      gc = "g checkout";
      gC = "g commit";
      gs = "g status";
      gS = "g switch";
      gp = "g pull";
      gP = "g push";
      gPf = "gP --force-with-lease";
      gb = "g branch";
      gd = "g diff";
      gf = "g fetch";
      gR = "g rebase";
      gRc = "gR --continue";
      gRa = "gR --abort";
      gcp = "g cherry-pick";
      gcpc = "gcp --continue";
      gcpa = "gcp --abort";
      gr = "git remote";
      grg = "gr get-url";
      grs = "gr set-url";
      gra = "gr add";
      grpo = "gr prune origin";
      gau = "g add --update";
      gCnv = "gC --no-verify";
      gCam = "gC --amend";
      gCC = "gC --amend --no-verify";
      gbl = "g blame -wCCC";
      nfu = "nix flake update --commit-lock-file";
      sci = "step certificate inspect";
      #TODO: feels odd putting aliases in without installing the program but I like to keep the
      #  environments separate between repos?
      k = "kubectl";
      kc = "k config";
      kl = "k logs";
      kg = "k get";
      kd = "k describe";
      kD = "k delete";
      kgn = "kg node";
      kgp = "kg pod";
      kdn = "kd node";
      kdp = "kd pod";
      kgnp = "kgp --all-namespaces --output wide --field-selector spec.nodeName=";
      kcns = "kc set-context --current --namespace";
      kcgc = "kc get-contexts";
      kcc = "kc use-context";
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
      shl = "echo $SHLVL";
      # flushdns = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
      phonesetup = ''        nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb tcpip 5555 \
                      && nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb shell pm grant net.dinglisch.android.taskerm android.permission.WRITE_SECURE_SETTINGS \
                      && nix shell nixpkgs/release-24.05#android-tools --keep-going -c adb shell settings put global force_fsg_nav_bar 1
      '';
    }
    # TODO: If the OpenGL-non NixOS system thing ever gets resolved...
    // lib.optionalAttrs cfg.isThatOneWeirdMachine {alac = "nohup nixGLNvidia alacritty &";}
    # Have to put here as modules are Nix config and not home-manager (?)
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin darwinAliases;
  darwinAliases = {
    dr = "darwin-rebuild";
    drc = "dr check --flake .";
    drs = "dr switch --flake .";
    flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    brute-force-darwin-rebuild-check = "until drc ; do : ; done";
    brute-force-darwin-rebuild-switch = "until drs ; do : ; done";
    brute-force-flake-update = "until nix flake update --commit-lock-file ; do : ; done";
    brute-force-direnv-reload = "until direnv reload ; do : ; done";
  };
  # Ref: https://github.com/phip1611/nixos-configs/blob/main/common/modules/user-env/env/cargo.nix
  # List of binaries to create a symlink to in `~/.cargo/bin`.
  # From my testing, adding "cargo" and "rustc" should be enough, but better
  # be safe.
  cargoSymlinkBins = [
    "cargo"
    "cargo-clippy"
    "rustc"
    "rustdoc"
    "rustfmt"
    "rustup"
  ];

  # Function that creates a list of cargo symlinks for the home-manager.
  createCargoBinSymlinks = mkOutOfStoreSymlink: bins:
    builtins.foldl'
    (acc: bin:
      {
        ".cargo/bin/${bin}".source = mkOutOfStoreSymlink "/etc/profiles/per-user/${cfg.username}/bin/${bin}";
      }
      // acc)
    {} # accumulator
    
    bins;

  dummyCargoEnvFile = pkgs.writeText "dummy-cargo-env-file.sh" ''
    # Dummy cargo env file generated by NixOS/home-manager.
    # This is only here so that scripts that expect this standard path to be
    # available don't fail. One example are the scripts in the cloud-hypervisor
    # repository, which source this file.
  '';
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
      isThatOneWeirdMachine = mkOption {
        type = bool;
        description = "IYKYK";
        default = false;
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
            general.live_config_reload = true;
            font.size = 14;
            font.normal.family = "FiraCode Nerd Font";
            terminal.shell.program = "zellij";
            keyboard.bindings = let
              zeroKeyReset = {
                key = "Zero";
                mods = "Control";
                action = "ResetFontSize";
              };
            in
              [
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
              ]
              ++ lib.optional (!cfg.isThatOneWeirdMachine) zeroKeyReset;
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
        jujutsu = {
          enable = true;
          settings = {
            user = {
              name = "Ariel Richtman";
              email = "ariel@richtman.au";
            };
            ui = {
              default-command = "status";
              editor = "hx";
              paginate = "never";
              # TODO: configure mergiraf for JJ
              diff.tool = "delta";
              merge-editor = "mergiraf";
            };
            merge-tools = {
              mergiraf = {
                merge-args = ["merge" "--output" "$output" "$base" "$left" "$right"];
              };
              delta = {
                # Ref: https://github.com/jj-vcs/jj/issues/5250
                diff-args = ["--line-numbers" "$left" "$right"];
                diff-expected-exit-codes = [1];
              };
            };
            signing = {
              behaviour = "own";
              backend = "ssh";
              key = "~/.ssh/id_ed25519.pub";
            };
            git = {
              sign-on-push = true;
            };
            "--scope" = [
              {
                "--when" = {
                  repositories = ["~/repos/gl/"];
                };
                user = {
                  email = "ariel.richtman@silverrailtech.com";
                };
              }
            ];
          };
        };
        git = {
          enable = true;
          delta.enable = true;
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
          ignores = lib.arichtman.sourceGitignoreList {
            languages = ["hugo" "rust" "linux" "macos" "csharp" "direnv" "python" "windows" "terraform" "dotnetcore" "terragrunt" "rust-analyzer" "node" "yarn"];
            hash = "12gswbdnlsx1gzqxns6s6nzsc0kkvnprr44abc1v8l6in8rjyj57";
            filterFunction = x: x != "Cargo.lock";
          };
          attributes = import ./git/attributes.nix;
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
              autoSquash = true;
            };
            fetch = {
              prune = true;
              pruneTags = true;
              all = true;
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
              followTags = true;
            };
            merge.mergiraf = {
              name = "mergiraf";
              driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P";
            };
            url = {
              "https://github.com" = {insteadOf = "gh";};
              "https://gitlab.com" = {insteadOf = "gl";};
              "https://codeberg.org" = {insteadOf = "cb";};
            };
            # Ref: https://blog.gitbutler.com/how-git-core-devs-configure-git/
            column.ui = "auto";
            branch.sort = "-committerdate";
            tag.sort = "version:refname";
            help.autocorrect = "prompt";
            commit.verbose = true;
            rerere = {
              enabled = true;
              autoUpdate = true;
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
            function llog { journalctl _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value $1) ; }
            if command -v nix-your-shell > /dev/null; then
              nix-your-shell zsh | source /dev/stdin
            fi
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
        inherit (cfg) username;
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
          netcat
          # Ref: https://github.com/ibraheemdev/modern-unix
          xh # curl replacement
          # TODO disabled due to build issues on x86_64-linux
          # dog # dig replacement
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
          nerd-fonts.fira-code # This actually makes it available to Alacritty
          cyme # lsusb replacement
          step-cli # Certificate tooling
          # Nix tooling
          nix-init
          nix-update
          nix-index
          nurl
          nix-bash-completions
          nix-your-shell
          # Kube stuff
          kubectl
          kubectl-neat
          kubectl-tree
          kubectl-ktop
          kubectl-df-pv
          kubectl-graph
          kubectl-klock
          kubectl-gadget
          kubectl-images
          kubectl-doctor
          kubectl-explore
          kubectl-view-secret
          # Lang servers
          nil # nix
          marksman # md
          terraform-ls # tf
          gopls
          # rust-analyzer # rust
          lldb_18 # Rust debugging - TODO, switch to lldb proper after v18 so lldb-dap is available
          alejandra # nix formatter
          dprint # markdown formatting (it does more though)
          helm-ls
          yaml-language-server
          ansible-language-server
          vscode-langservers-extracted
          dockerfile-language-server-nodejs
          docker-compose-language-service
          jq-lsp
          buf
          nixd
          ruff-lsp
          # jj VCS
          jujutsu
          gg-jj
          # diff tool
          mergiraf
          arichtman.mamediff
          # langs
          rustup
          #TODO: dont have these on mac, aarch64 at least
          # trippy
          jujutsu # VCS tool
          # Ref: https://terminaltrove.com
        ];
        file =
          # Ref: https://github.com/phip1611/nixos-configs/blob/main/common/modules/user-env/env/cargo.nix
          createCargoBinSymlinks config.lib.file.mkOutOfStoreSymlink cargoSymlinkBins
          // {
            ".config/helix" = {
              source = ./helix;
              recursive = true;
            };
            ".cargo/config.toml".source = cargo/config.toml;
            ".cargo/env".source = dummyCargoEnvFile;
            ".config/terraform" = {
              source = ./terraform;
              recursive = true;
            };
            # Required to create empty directory for Terraform plugin cache since TF won't create if not exist 🙄
            # https://github.com/nix-community/home-manager/issues/2104
            ".terraform.d/plugin-cache/.keep".text = "";
            ".dprint.jsonc".source = dprint/.dprint.jsonc;
          };
        sessionPath = ["/home/${cfg.username}/.cargo/bin"];

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
