{ pkgs, inputs, ... }:
let
  ssh_key_file = ../../keys/users/lasse_ed25519.pub;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/common.nix
    ../../modules/terminal
    ../../modules/git
    ../../modules/neovim
  ];

  networking = {
    hostName = "rpi";
    wireless.iwd.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users = {
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
    lasse = {
      isNormalUser = true;
      home = "/home/lasse";
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
      extraGroups = [ "wheel" ];
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
      wayland.windowManager.sway.enable = true;
      wayland.windowManager.sway.config.modifier = "Super";
    };
  };

  programs.sway.enable = true;

  environment.systemPackages = with pkgs; [
    brave
  ];
}
