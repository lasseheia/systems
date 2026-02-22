{
  lib,
  pkgs,
  ...
}:
{
  options.modules.hyprland.profile = lib.mkOption {
    type = lib.types.enum [
      "desktop"
      "laptop"
      "server"
      "rpi"
    ];
    description = "Host profile used to select Hyprland and Waybar config files.";
  };

  config = {
    programs.dconf.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    # https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services.blueman.enable = true;

    security.rtkit.enable = true;

    home-manager.users.lasse = ./home-manager.nix;
  };
}
