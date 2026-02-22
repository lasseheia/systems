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

  xdg.configFile."opencode/AGENTS.md".text = ''
    # Personal OpenCode Rules

    - Never run `git push`.
    - Only create commits when I explicitly ask for it.
    - Show the `git diff` before creating a commit.
  '';

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      bash = {
        "*" = "ask";
        "git *" = "allow";
        "git commit *" = "ask";
        "git push *" = "deny";
      };
    };
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
        colors = {
          primary = {
            foreground = "0xd7dce5";
          };
          cursor = {
            text = "0x16181a";
            cursor = "0x6f94b6";
          };
          normal = {
            black = "0x1f2329";
            red = "0xc97b87";
            green = "0x7fa766";
            yellow = "0xc9b07b";
            blue = "0x6f94b6";
            magenta = "0x9d88bf";
            cyan = "0x5f9ea8";
            white = "0xb8c0cc";
          };
          bright = {
            black = "0x3c434f";
            red = "0xd28a95";
            green = "0x8ab375";
            yellow = "0xd4bc8a";
            blue = "0x7ea1c4";
            magenta = "0xaa98c8";
            cyan = "0x6fadb6";
            white = "0xd7dce5";
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
      shellWrapperName = "y";
    };

    opencode = {
      enable = true;
      settings.theme = "transparent";
      themes.transparent = ./opencode-transparent-theme.json;
    };
  };
}
