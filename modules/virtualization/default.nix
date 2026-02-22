{ inputs, ... }:

{
  imports = [ inputs.nixvirt.nixosModules.default ];

  users.users.lasse.extraGroups = [ "libvirtd" ];

  virtualisation = {
    libvirt = {
      enable = true;
      connections = {
        "qemu:///system" = {
          domains = [ { definition = ./domains/gaming.xml; } ];
        };
      };
    };

    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  services.spice-vdagentd.enable = true;

  # IOMMU
  boot = {
    kernelParams = [ "amd_iommu=on" ];
    blacklistedKernelModules = [
      "nvidia"
      "nouveau"
    ];
    kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
    extraModprobeConfig = "options vfio-pci ids=10de:1e84,10de:10f8,10de:1ad8,10de:1ad9";
  };

  # Looking Glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 1000 kvm -" ];

  home-manager.users.lasse = ./home-manager.nix;
}
