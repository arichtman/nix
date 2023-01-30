{
  config,
  pkgs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "nixos";
    homeDirectory = "/home/nixos";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";

    packages = with pkgs; [
      vscode-extensions.mkhl.direnv
      vscode-extensions.rust-lang.rust-analyzer
      nix-direnv
      alejandra
    ];

    shellAliases = {
      ll = "ls -hAlLrt";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      cls = "clear";
      gs = "git status";
      fuggit = "git add . && git commit --amend --no-edit && git push --force";
      gc = "git checkout";
      gS = "git switch";
      gp = "git pull";
    };
    enableNixpkgsReleaseCheck = true;
  };
  # Enable unfree packages (for vscode stuff)
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  xdg.systemDirs.data = ["$HOME/.nix-profile/share"];

  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        kamadorueda.alejandra
      ];
    };
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
      enable = true;
      aliases = {
        c = "commit";
        co = "checkout";
        s = "status";
      };
      extraConfig = {
        pull = {
          rebase = true;
        };
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
}
