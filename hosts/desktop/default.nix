{
  pkgs,
  inputs,
  ...
}:

{
  modules.hyprland.profile = "desktop";

  imports = [
    inputs.sops-nix.nixosModules.sops
    ../../modules/nixos
    ../../modules/home-manager
    #../../modules/virtualization
    ../../modules/terminal
    ../../modules/neovim
    ../../modules/git
    ../../modules/hyprland
    ../../modules/podman
  ];

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
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };
}
