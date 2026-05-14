{
  pkgs,
  inputs,
  modulesPath,
  ...
}:

{
  modules.hyprland.profile = "desktop";

  imports = [
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/home-manager
    #../../modules/virtualization
    ../../modules/terminal
    ../../modules/neovim
    ../../modules/git
    ../../modules/hyprland
    ../../modules/podman
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 10;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

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

  networking = {
    useNetworkd = true;
    wireless.iwd.enable = true;
    interfaces.wlan0.useDHCP = true;
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
