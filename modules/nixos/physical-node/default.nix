{
  lib,
  config,
  ...
}: let
  cfg = config.physical-node;
in
  with lib; {
    options.physical-node = with types; {
      volumes = {
        bootUuid = mkOption {
          type = str;
          description = "Boot disk uuid.";
          default = "";
        };
        rootUuid = mkOption {
          type = str;
          description = "Root disk uuid.";
          default = "";
        };
      };
    };
    # TODO: Figure out why my internal library isn't accessible
    # config = mkIf (lib.arichtman.allAttrsSet cfg.volumes) {
    config = mkIf (builtins.all (v: stringLength v > 0) (attrValues cfg.volumes)) {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # ---- HARDWARE -----
      # Note: This really only works for very homogenous machines.
      # Luckily all my physical nodes are the same!

      boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      boot.kernelModules = ["kvm-intel"];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/${cfg.volumes.rootUuid}";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/${cfg.volumes.bootUuid}";
        fsType = "vfat";
      };
      networking.interfaces.eno1.wakeOnLan.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  }
