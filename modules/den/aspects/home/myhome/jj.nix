{
  den.aspects.home.jj.homeManager.programs = {
    # TODO: Ref https://andre.arko.net/2025/10/15/jj-part-4-configuration/
    jujutsu = {
      enable = true;
      settings = {
        # Defaults, overriden by path for work
        user = {
          name = "Ariel Richtman";
          email = "ariel@richtman.au";
        };
        # Ref: https://shaddy.dev/notes/jj-tug/
        aliases.tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
        ui = {
          default-command = "status";
          editor = "hx";
          paginate = "never";
          # pager = "bat";
          # TODO: configure mergiraf for JJ
          diff-formatter = "delta";
          merge-editor = "mergiraf";
        };
        merge-tools = {
          mergiraf = {
            merge-args = ["merge" "--output" "$output" "$base" "$left" "$right"];
          };
          delta = {
            # Ref: https://github.com/jj-vcs/jj/issues/5250
            diff-args = ["--line-numbers" "$left" "$right"];
            # Ref: https://github.com/dandavison/delta/issues/1921#issuecomment-3054296748
            diff-expected-exit-codes = [0 1];
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
          {
            "--when" = {
              repositories = ["~/repos/cb/"];
            };
            user = {
              email = "ariel@richtman.au";
            };
          }
          {
            "--when" = {
              commands = ["diff"];
            };
            ui = {
              paginate = "auto";
            };
          }
        ];
      };
    };
  };
}
