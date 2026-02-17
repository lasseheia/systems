{ inputs, ... }:
let
  ssh_keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8V+W2mKUj8QpWJe5N8Z6zrekUISHwdXy6vp4nkte4l" ];
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./incus/nixos
    ../../modules/terminal
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/git
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    freerdp
    remmina
  ];

  system.stateVersion = "24.11";
  console.keyMap = "no";
  time.timeZone = "Europe/Oslo";

  networking = {
    hostName = "server";
    firewall = {
      enable = true;
    };
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users = {
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keys = ssh_keys;
    };
    lasse = {
      isNormalUser = true;
      home = "/home/lasse";
      openssh.authorizedKeys.keys = ssh_keys;
      extraGroups = [
        "wheel"
        "incus-admin"
      ];
    };
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
