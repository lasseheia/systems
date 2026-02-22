{ inputs, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostId = "b648d918"; # Randomly generated host ID, this is required for ZFS
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ]; # Continue boot even if /boot fails to mount
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none"; # Disable automatic mounting; set mountpoints per dataset below
          compression = "zstd"; # Efficient, modern compression
        };
        options.ashift = "12"; # Ensures proper 4K alignment for NVMe/SSD devices
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          "root/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          "root/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "root/swap" = {
            type = "zfs_volume";
            size = "4G";
            content = {
              type = "swap";
              mountOptions = [
                "defaults"
                "nofail"
              ];
            };
            options = {
              volblocksize = "4096"; # Basic block size setting for swap
            };
          };
        };
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.enableRedistributableFirmware = true;
}
