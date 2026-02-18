{ pkgs, ... }:

{
  home.packages = [
    pkgs.htop
    pkgs.kubectl
    pkgs.jq
    pkgs.yq-go
    pkgs.yarn
    pkgs.ipcalc
    pkgs.killall
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.sauce-code-pro
  ];

  xdg.configFile."zellij/config.kdl" = {
    source = ./zellij.kdl;
  };

  programs = {

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      initContent = builtins.readFile ./zshrc;
      oh-my-zsh = {
        enable = true;
      };
    };

    atuin.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
      extraOptions = [ "--group-directories-first" ];
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    fzf.enable = true;

    bat.enable = true;

    alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 0.8;
          option_as_alt = "OnlyLeft";
        };
        selection = {
          save_to_clipboard = true;
        };
        font = {
          normal = {
            family = "FiraCode Nerd Font";
            style = "Regular";
          };
        };
      };
    };

    zellij.enable = true;

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        azure = {
          disabled = false;
        };
        kubernetes = {
          disabled = false;
          symbol = "⎈ ";
        };
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    opencode = {
      enable = true;
      settings.theme = "transparent";
      themes.transparent = ./opencode-transparent-theme.json;
    };
  };
}
