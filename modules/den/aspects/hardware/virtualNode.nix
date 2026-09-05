{
  den.aspects.virtualNode = {
    nixos = {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
    };
  };
}
