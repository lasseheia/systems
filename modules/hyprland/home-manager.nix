{
  lib,
  osConfig,
  pkgs,
  ...
}:

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

  services.wpaperd = {
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

  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    showStartupLaunchMessage=false
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 0;
        "col.active_border" = "rgba(7ab8ff00) rgba(5fe1e600) 45deg";
        "col.inactive_border" = "rgba(3c434f88)";
      };

      decoration = {
        rounding = 5;
        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "rgba(00000044)";
        };
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = [ "smooth, 0.22, 1, 0.36, 1" ];
        animation = [
          "windows, 1, 5, smooth, slide"
          "windowsOut, 1, 4, smooth, slide"
          "fade, 1, 4, smooth"
          "workspaces, 1, 5, smooth, slide"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    };
    extraConfig = builtins.readFile ./hyprland/${hostname}.conf;
  };

  programs.zsh.initContent = lib.mkBefore ''
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
