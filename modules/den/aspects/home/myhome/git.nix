{
  lib,
  home,
  ...
}: {
  den.aspects.home.git = {pkgs, ...}: {
    homeManager.programs = {
      git = let
        downloadGitignore = arguments @ {
          languages ? [],
          hash ? lib.fakeSha256,
          # Allow variadic arguments so we have one API
          ...
        }:
          builtins.fetchurl {
            url = "https://www.toptal.com/developers/gitignore/api/${lib.concatStringsSep "," arguments.languages}";
            name = "myGitignore"; # Required as both "," and "%2C" are invalid store paths
            # For some godforsaken reason arguments.hash bombs on missing property
            sha256 = hash;
          };
        sourceGitignoreList = arguments @ {
          # Default this to a no-op processing where every list item is retained.
          # TODO: Allow this to take a list of functions and recurse down to progressively apply them.
          filterFunction ? (_: true),
          ...
        }: let
          gitignoreFile = downloadGitignore arguments;
          rawText = builtins.readFile gitignoreFile;
          splitList = builtins.split "\n" rawText;
          pureList = builtins.filter (x: x != []) splitList;
        in
          builtins.filter filterFunction pureList;
      in {
        enable = true;
        ignores =
          (sourceGitignoreList {
            languages = [
              "hugo"
              "rust"
              "linux"
              "macos"
              "csharp"
              "direnv"
              "python"
              "windows"
              "terraform"
              "dotnetcore"
              "terragrunt"
              "rust-analyzer"
              "node"
              "yarn"
            ];
            hash = "12gswbdnlsx1gzqxns6s6nzsc0kkvnprr44abc1v8l6in8rjyj57";
            filterFunction = x: x != "Cargo.lock";
          })
          ++ [".helix/"];
        attributes = import ./_attributes.nix;
        signing = {
          signByDefault = true;
          key = "~/.ssh/id_ed25519.pub";
        };
        settings = {
          user = {
            email = home.userSettings.git.email;
            name = home.userSettings.git.username;
          };
          alias = {
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
          url =
            {
              "https://github.com" = {
                insteadOf = "gh";
              };
              "https://gitlab.com" = {
                insteadOf = "gl";
              };
              "https://codeberg.org" = {
                insteadOf = "cb";
              };
              # Ref: https://is-a.cat/@ar/114307233150170664
              "git@codeberg.org:" = {
                insteadOf = "https://codeberg.org/";
              };
              "git@gitlab.com:" = {
                insteadOf = "https://gitlab.com/";
              };
            }
            // lib.optionalAttrs (!pkgs.stdenv.hostPlatform.isAarch) {
              "git@github.com:" = {
                insteadOf = "https://github.com/";
              };
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
    };
  };
}
