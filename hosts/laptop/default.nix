{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  modules.hyprland.profile = "laptop";

  system.stateVersion = "23.05";

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

  boot.kernelParams = [ "noresume" ];
  swapDevices = lib.mkForce [ ];
}
