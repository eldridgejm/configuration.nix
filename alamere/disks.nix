{ pkgs, config, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  # Mount disks
  fileSystems."/mnt/dc" = {
    device = "/dev/lvmdc/lvol0";
    fsType = "ext4";
  };

  fileSystems."/backup" = {
    device = "/dev/disk/by-uuid/622f34fe-aee0-4f38-814e-fbd7e131b87f";
    fsType = "ext4";
  };

  fileSystems."/mnt/arch" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };
}
