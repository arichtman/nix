{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.default-home;
  darwinAliases = {
    dr = "darwin-rebuild";
    drc = "dr check --flake .";
    drs = "dr switch --flake .";
    flushdns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
    brute-force-darwin-rebuild-check = "until drc ; do : ; done";
    brute-force-darwin-rebuild-switch = "until drs ; do : ; done";
    brute-force-flake-update = "until nix flake update --commit-lock-file ; do : ; done";
    brute-force-direnv-reload = "until direnv reload ; do : ; done";
    # Ope, looks like Alacritty launch is cooked on x86_64 Darwin
    alac = "open -a alacritty; exit 0";
  };
in {
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
    // lib.optionalAttrs (cfg.isThatOneWeirdMachine || (pkgs.stdenv.hostPlatform.isDarwin && !pkgs.stdenv.hostPlatform.isAarch)) {alac = "nohup nixGLNvidia alacritty &";}
    # Have to put here as modules are Nix config and not home-manager (?)
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin darwinAliases;
}
