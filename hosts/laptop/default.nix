{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  modules.hyprland.profile = "laptop";

  system.stateVersion = "23.05";
  nixpkgs.stdenv.hostPlatform = "x86_64-linux";

  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/common.nix
    ../../modules/users/lasse.nix
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/terminal
    ../../modules/git
  ];

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];

  networking.wireless.iwd.enable = true;

  boot.kernelParams = [ "noresume" ];
  swapDevices = lib.mkForce [ ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };
}
