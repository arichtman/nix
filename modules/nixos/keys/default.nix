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
      users.users.nixos.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxGxm6tCZlV3vJ6+yAkmQKcqVagfhgaf2aHzVQHvay+"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMB0EONXbHFqCgHpvJDtFVrDyJeNVHb+XeweP+vYHf0F"
      ];
    };
  }
