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
  modules.hyprland.profile = "server";

  imports = [
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ./incus/nixos
    ../../modules/common.nix
    ../../modules/services/openssh.nix
    ../../modules/users/lasse.nix
    ../../modules/terminal
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/git
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    freerdp
    remmina
    rustdesk-flutter
  ];

  system.stateVersion = "24.11";
  networking.hostName = "server";
  modules.users.lasse.extraGroups = [ "incus-admin" ];

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

  sops = {
    defaultSopsFile = inputs.secrets + "/server/secrets.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.lasse-password.neededForUsers = true;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
    lasse = {
      hashedPasswordFile = config.sops.secrets.lasse-password.path;
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
  };
}
