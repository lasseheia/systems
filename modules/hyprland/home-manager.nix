{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  profile = osConfig.modules.hyprland.profile;
  waybarCommon = builtins.fromJSON (builtins.readFile ./waybar/common.json);
  waybarHost = builtins.fromJSON (builtins.readFile ./waybar/${profile}.json);
  waybarCommonStyle = builtins.readFile ./waybar/common.css;
  waybarHostStyle = builtins.readFile ./waybar/${profile}.css;
in
{
  home.packages = with pkgs; [
    lxqt.lxqt-policykit
    wl-clipboard # for cliphist
    pamixer
    pwvucontrol
    overskride
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
  };

  home.sessionVariables = {
    BROWSER = "brave";
    GTK_THEME = "Adwaita:dark";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
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
      env = [
        "GTK_THEME,Adwaita:dark"
        "GTK_APPLICATION_PREFER_DARK_THEME,1"
      ];

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
          range = 10;
          render_power = 2;
          color = "rgba(00000044)";
        };
        blur = {
          enabled = true;
          size = 4;
          passes = 1;
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
        vfr = true;
      };
    };
    extraConfig = ''
      ${builtins.readFile ./hyprland/common.conf}
      ${builtins.readFile ./hyprland/${profile}.conf}
    '';
  };

  programs.waybar = {
    enable = true;
    settings = lib.recursiveUpdate waybarCommon waybarHost;
    style = ''
      ${waybarCommonStyle}

      ${waybarHostStyle}
    '';
  };

  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.override { enableWlrSupport = true; };
  };
}
