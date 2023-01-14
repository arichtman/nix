{ config, pkgs, ... }:

{
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
    ];

    shellAliases = {
      ll = "ls -hAlLrt";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      cls = "clear";
    };
    enableNixpkgsReleaseCheck = true;
  };
  programs.git = {
    enable = true;
    userEmail = "10679234+arichtman@users.noreply.github.com";
    userName = "Richtman, Ariel";
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
  programs = {
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
