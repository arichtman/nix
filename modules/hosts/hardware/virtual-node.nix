{
  den.aspects.virtual-node = {
    nixos = {pkgs, ...}: {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
    };
  };
}
