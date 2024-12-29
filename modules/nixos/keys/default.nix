{
  lib,
  config,
  ...
}: let
  cfg = config.myKeys;
in
  with lib; {
    options.myKeys = with types; {
      enable = mkEnableOption "Authorize public keys for SSH access.";
      github = {
        username = mkOption {
          type = str;
          description = "GitHub username to pull keys from.";
        };
        fileHash = mkOption {
          type = str;
          description = "Hash of GitHub public keys file.";
        };
      };
      gitlab = {
        username = mkOption {
          type = str;
          description = "GitLab username to pull keys from.";
        };
        fileHash = mkOption {
          type = str;
          description = "Hash of GitLab public keys file.";
        };
      };
      # TODO: allow enumerated hosts
      # Ref: https://nixos.org/manual/nixos/stable/#section-option-types-submodule
      # Ref: https://github.com/NixOS/nixpkgs/blob/e6ab46982debeab9831236869539a507f670a129/nixos/modules/services/backup/borgbackup.nix#L234
      # TODO: Map TLDs for common sources codeberg github, gitlab
      # hosts = {
      # 		mkOption { type = str; } = {
      # 			username = mkOption { type = str; };
      # 			fileHash = mkOption { type = str; };
      # 	};
      # };
    };
    config = mkIf cfg.enable {
      # TODO: un-hardcode user?
      # Ref: https://hachyderm.io/@jakehamilton/110810308164205009
      # Ref: https://github.com/jakehamilton/config/blob/579827c699d9c78bd42e73f543eafb05a0d6c374/modules/user/default.nix#L30
      # Ref: https://github.com/jakehamilton/config/blob/da5c75ce9c21d282745af5efb14b06fde2364f42/modules/nixos/home/default.nix#L32
      # users.users.${user.name}.openssh.authorizedKeys.keys = arichtman.getPublicKeys "github" cfg.github.username cfg.github.fileHash;
      users.users.nixos.openssh.authorizedKeys.keys = arichtman.getPublicKeys "github" cfg.github.username cfg.github.fileHash;
    };
  }
