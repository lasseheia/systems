{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  ssh_key_file = ../../keys/users/lasse_ed25519.pub;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./incus/nixos
    ../../modules/common.nix
    ../../modules/services/openssh.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  console.keyMap = "no";

  system.stateVersion = "24.11";
  networking.hostName = "server";

  boot = {
    zfs.forceImportRoot = false;

    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 15;
    };

    kernelParams = [ "noresume" ];
    consoleLogLevel = 3;
  };

  # Keep zram swap, but do not wait for the ZFS zvol swap device during boot.
  swapDevices = lib.mkForce [ ];

  zramSwap.memoryPercent = 20;

  powerManagement.cpuFreqGovernor = "performance";

  users.mutableUsers = false;
  users.users = {
    root = {
      isNormalUser = false;
      hashedPassword = "!";
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
  };
}
