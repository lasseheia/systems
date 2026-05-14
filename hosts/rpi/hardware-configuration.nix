{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    raspberry-pi = {
      "4" = {
        bluetooth.enable = true;
        #tv-hat.enable = true;
      };
    };
    #  enableRedistributableFirmware = true;
  };
  services.blueman.enable = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
  networking.wireless.iwd.enable = true;
  system.stateVersion = "25.05";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
}
