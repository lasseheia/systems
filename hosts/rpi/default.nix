{ pkgs, inputs, ... }:
let
  ssh_key_file = ../../keys/users/lasse_ed25519.pub;
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/common.nix
    ../../modules/users/lasse.nix
    ../../modules/services/openssh.nix
    ../../modules/terminal
    ../../modules/git
    ../../modules/neovim
  ];

  networking.hostName = "rpi";

  users.users = {
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
    lasse = {
      openssh.authorizedKeys.keyFiles = [ ssh_key_file ];
    };
  };

  home-manager.users.lasse = {
    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.config.modifier = "Super";
  };

  programs.sway.enable = true;

  environment.systemPackages = with pkgs; [
    brave
  ];
}
