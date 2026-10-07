{
  pkgs,
  inputs,
  modulesPath,
  ...
}:

{
  modules.hyprland.profile = "desktop";
  networking.hostName = "desktop";

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

  nix.package = pkgs.lixPackageSets.stable.lix;

  system.stateVersion = "23.05";

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
  };
  hardware.graphics.enable32Bit = true;
  programs.gamemode.enable = true;
  services = {
    blueman.enable = false;
    pipewire = {
      alsa.support32Bit = true;
      wireplumber.extraConfig."10-disable-bluetooth" = {
        "wireplumber.profiles".main = {
          "monitor.bluez" = "disabled";
          "monitor.bluez-midi" = "disabled";
        };
      };
    };
  };
  environment.systemPackages = [
    pkgs.lutris
    pkgs.prusa-slicer
    pkgs.azuredatastudio
    pkgs.rustdesk-flutter
    pkgs.firefox
    pkgs.signal-desktop
    pkgs.krita
    pkgs.orca-slicer
    pkgs.blender
    pkgs.sqlcmd
    pkgs.cura-appimage
    pkgs.podman-compose
    pkgs.smartmontools
    pkgs.nvme-cli
  ];
}
