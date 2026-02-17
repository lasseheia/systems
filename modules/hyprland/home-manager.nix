{ osConfig, pkgs, ... }:

let
  hostname = osConfig.networking.hostName;
in
{
  home.packages = with pkgs; [
    lxqt.lxqt-policykit
    wl-clipboard # for cliphist
    pamixer
    pavucontrol
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
  };

  home.sessionVariables = {
    BROWSER = "brave";
  };

  services.dunst.enable = true;

  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        path = "${./wallpapers}";
        duration = "30m";
        apply-shadow = true;
        sorting = "random";
      };
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 750;
      height = 400;
      always_parse_args = true;
      show_all = false;
      print_command = true;
      insensitive = true;
      prompt = "Hmm, what do you want to run?";
    };
    style = builtins.readFile ./wofi.css;
  };

  services.copyq.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      misc = {
        disable_hyprland_logo = true;
      };
    };
    extraConfig = builtins.readFile ./hyprland/${hostname}.conf;
  };

  programs.zsh.initExtraFirst = ''
    [[ "$(tty)" = "/dev/tty1" ]] && exec start-hyprland
  '';

  programs.waybar = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./waybar/${hostname}.json);
    style = builtins.readFile ./waybar/${hostname}.css;
  };

  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.override { enableWlrSupport = true; };
  };
}
