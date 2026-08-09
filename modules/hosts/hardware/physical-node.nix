{
  den,
  self',
  lib,
  ...
}: {
  den.aspects.physical-node = {
    # lib.trace (_ = host.is-physical-node);
    nixos = {volumes}: {
      # Bootloader.
      boot.loader.grub.devices = [self'.nixos.filesystems."/boot".device];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # ---- HARDWARE -----
      # Note: This really only works for very homogenous machines.
      # Luckily all my physical nodes are about the same!

      boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      boot.kernelModules = ["kvm-intel"];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/${volumes.rootUuid}";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/${volumes.bootUuid}";
        fsType = "vfat";
      };
      networking.interfaces.eno1.wakeOnLan.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      # hardware.cpu.intel.updateMicrocode = lib.mkDefault self'.config.hardware.enableRedistributableFirmware;
    };
  };
}
