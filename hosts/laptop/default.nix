{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  modules.hyprland.profile = "laptop";

  system.stateVersion = "23.05";
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    optimise.automatic = true;
  };
  nixpkgs.stdenv.hostPlatform = "x86_64-linux";

  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/common.nix
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/terminal
    ../../modules/git
  ];

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];

  networking.wireless.iwd.enable = true;

  users.users.lasse = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  boot.kernelParams = [ "noresume" ];
  swapDevices = lib.mkForce [ ];

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lasse = {
      programs.home-manager.enable = true;
      home = {
        stateVersion = "23.05";
        username = "lasse";
        homeDirectory = "/home/lasse";
      };
    };
  };
}
