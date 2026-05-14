{
  pkgs,
  inputs,
  modulesPath,
  ...
}:

{
  modules.hyprland.profile = "desktop";

  imports = [
    inputs.home-manager.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/common.nix
    ../../modules/users/lasse.nix
    ../../modules/terminal
    ../../modules/neovim
    ../../modules/git
    ../../modules/hyprland
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 10;
  };

  system.stateVersion = "23.05";

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
  };
  modules.users.lasse.extraGroups = [ "podman" ];

  environment.systemPackages = [
    pkgs.prusa-slicer
    pkgs.azuredatastudio
    pkgs.rustdesk-flutter
    pkgs.firefox
    pkgs.signal-desktop
    pkgs.krita
    pkgs.opentabletdriver
    pkgs.orca-slicer
    pkgs.blender
    pkgs.sqlcmd
    pkgs.cura-appimage
    pkgs.podman-compose
  ];
}
