{
  den,
  self,
  ...
}: {
  den.aspects.home.terminal = {
    includes = [
      den.aspects.home.jj
      den.aspects.home.git
    ];
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
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
        file = {
          ".config/helix" = {
            source = ./helix;
            recursive = true;
          };
          # It's odd this isn't a more structured config file
          ".config/.ripgreprc".text = "--glob=!**/*.svg";
          ".config/terraform" = {
            source = ./terraform;
            recursive = true;
          };
          # Could toJSON here but YAML means we get LSP support (if we can find JSONschema)
          ".kube/kuberc".source = k8s/kuberc.yaml;
          # Required to create empty directory for Terraform plugin cache since TF won't create if not exist 🙄
          # https://github.com/nix-community/home-manager/issues/2104
          ".terraform.d/plugin-cache/.keep".text = "";
          ".dprint.jsonc".text = builtins.toJSON (import ./_dprint.nix {inherit pkgs;});
        };
        packages = with pkgs;
          [
            # The essentials
            dig
            wget
            netcat
            # Ref: https://github.com/ibraheemdev/modern-unix
            xh # curl replacement
            dog # dig replacement
            procs # ps replacement
            eget # github binary pull tool
            dust # du replacement
            duf # df replacement
            sd # sed replacement
            gping # ping replacement
            trippy # Ping TUI
            choose # cut/awk replacement
            jless # json tui
            yazi # file manager
            eza # exa is unmaintained
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
            nix-tree
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
            kubelogin-oidc
            stern
            # Lang servers
            nil # nix
            markdown-oxide # md
            terraform-ls # tf
            gopls
            lldb
            alejandra # nix formatter
            dprint # formatting (esp MD)
            nixfmt
            helm-ls
            yaml-language-server
            harper # Git commit English
            # ansible-language-server seems to crash
            vscode-langservers-extracted
            dockerfile-language-server
            docker-compose-language-service
            jq-lsp
            yq
            buf
            nixd
            ruff
            # jj VCS
            jujutsu
            gg-jj
            # TODO: use mamediff as a package actually not calling directly
            (callPackage ../../packages/mamediff/_package.nix {})
            # langs
            rustup
            # Ref: https://terminaltrove.com
          ]
          ++ lib.optionals (!pkgs.stdenv.isAarch64) [
            trippy
            rsync
            # dockutil
            gawk
          ]
          ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
            yubikey-manager
            yubioath-flutter
            yubikey-touch-detector
          ];
        sessionVariables = {
          # TODO: Remove if subsumed by silent = true
          DIRENV_LOG_FORMAT = "";
          AWS_EC2_METADATA_DISABLED = "true";
          EDITOR = "hx";
          # Required as our config file placement is tidier but nonstandard
          RIPGREP_CONFIG_PATH = "$HOME/.config/.ripgreprc";
          # This is annoying, ideally I'd set them all in .terraformrc but some options don't seem to be available
          TF_CLI_ARGS_plan = "-compact-warnings";
          TF_CLI_ARGS_apply = "-compact-warnings";
          TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
          TF_CLI_CONFIG_FILE = "$HOME/.config/terraform/.terraformrc";
        };
      };
      programs = {
        alacritty = {
          enable = true;
          package = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) null; # Deliberately unset the package cause Alacritty is just shitful to use/manage when Nix-installed
          settings = {
            window.option_as_alt = "Both";
            general.live_config_reload = true;
            font.size = 14;
            font.normal.family = "FiraCode Nerd Font";
            terminal.shell.program = "zellij";
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
            ];
          };
        };
        # TODO: Look at disabling when comfortable
        bash = {
          enable = true;
          enableCompletion = true;
        };
        bat.enable = true;
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
        delta = {
          enable = true;
          enableGitIntegration = true;
        };
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        gpg.enable = true;
        helix = {
          enable = true;
          defaultEditor = true;
        };
        htop.enable = true;
        jq.enable = true;
        less.enable = true;
        # TODO: reenable when using our local package
        # mergiraf = {
        #   enable = true;
        #   enableGitIntegration = true;
        #   enableJujutsuIntegration = true;
        # };
        readline.enable = true;
        readline.extraConfig = "set enable-bracketed-paste off";
        ripgrep = {
          enable = true;
          # TODO: fix
          # Session variable RIPGREP_CONFIG_PATH doesn't actually get set this way,
          #   meaning this doesn't work and then clashes with my manual implementation.
          # arguments = [
          #   "--glob='!*.svg'"
          # ];
        };
        starship = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          # TODO: get working
          # Ref: https://github.com/jj-vcs/jj/wiki/Starship
          settings = {
            format = "$all\${custom.jj}";
            custom = {
              jj = {
                command = "prompt";
                format = "$output";
                symbol = "🥋 ";
                ignore_timeout = true;
                shell = ["starship-jj" "--ignore-working-copy" "starship"];
                use_stdin = false;
                detect_folders = [".jj"];
              };
            };
          };
        };
        zellij = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          attachExistingSession = true;
          exitShellOnExit = true;
          # Ref: https://github.com/zellij-org/zellij/pull/3047#issuecomment-2532831794
          extraConfig = ''
            bind "Shift Left" { MoveTab "Left"; }
            bind "Shift h" { MoveTab "Left"; }
            bind "Shift Right" { MoveTab "Right"; }
            bind "Shift l" { MoveTab "Right"; }
          '';
        };
        zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          autocd = true;
          syntaxHighlighting.enable = true;
          initContent = ''
            function gedditdafuckouttahere () {
              git submodule deinit --force $1 ;
              rm -fr .git/modules/$1 ;
              git rm --force $1 ;
            }
            function llog { journalctl _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value $1) ; }
            if command -v nix-your-shell > /dev/null; then
              nix-your-shell zsh | source /dev/stdin
            fi
            function rscleanup () {
              kubectl delete rs $(kubectl get rs -l app.kubernetes.io/instance=$1 -o jsonpath='{ .items[?(@.spec.replicas==0)].metadata.name }') --interactive=false ;
            }
          '';
        };
      };
    };
  };
}
