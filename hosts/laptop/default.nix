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
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/terminal
    ../../modules/git
  ];

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];

  networking = {
    wireless.iwd.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/Oslo";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "nb_NO.UTF-8";
    };
  };

  security.polkit.enable = true;

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
