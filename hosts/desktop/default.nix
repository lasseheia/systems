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

  nixpkgs.hostPlatform = "x86_64-linux";

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

  networking.wireless.iwd.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
    };
  };
  users.users.lasse.extraGroups = [ "podman" ];

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

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };
}
