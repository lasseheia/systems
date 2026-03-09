{ inputs, pkgs, ... }:

let
  dockerShim = pkgs.writeShellScriptBin "docker" ''
    #!/usr/bin/env bash
    exec ${pkgs.podman}/bin/podman "$@"
  '';
in
{
  imports = [
    inputs.home-manager.darwinModules.default
  ];

  system = {
    stateVersion = 4;
    primaryUser = "lasse";
    defaults = {
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = true; # Use F1, F2, etc. keys as standard function keys.
        AppleMetricUnits = 1;
        AppleICUForce24HourTime = true;
        AppleTemperatureUnit = "Celsius";
        AppleMeasurementUnits = "Centimeters";
        AppleInterfaceStyle = "Dark";
        AppleScrollerPagingBehavior = true; # Jump to the spot that's clicked on the scroll bar
        "com.apple.swipescrolldirection" = false; # Whether to enable "Natural" scrolling direction
      };
      hitoolbox.AppleFnUsageType = "Do Nothing"; # What the Fn key does when pressed alone
    };
  };

  nix = {
    enable = false; # Required to use nix-darwin
    package = pkgs.lix;
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        argocd = prev.argocd.overrideAttrs (old: {
          ui = old.ui.overrideAttrs (_: {
            offlineCache = prev.fetchYarnDeps {
              yarnLock = "${old.src}/ui/yarn.lock";
              hash = "sha256-kqBolkQiwZUBic0f+Ek5HwYsOmro1+FStkDLXAre79o=";
            };
          });
        });
      })
    ];
    hostPlatform = {
      system = "aarch64-darwin";
    };
  };

  programs.zsh.enable = true;

  users.users.lasse = {
    name = "lasse";
    home = "/Users/lasse";
  };

  environment.systemPackages = with pkgs; [
    podman
    glab
    dockerShim
    azure-cli
    kubectl
    kubelogin
    kargo
    alacritty
    rectangle
    terraform
    terraform-ls
    pre-commit
    dotnet-ef
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lasse = {
      home.stateVersion = "23.11";
      imports = [
        ../../modules/terminal/home-manager.nix
        ../../modules/neovim/home-manager.nix
        ../../modules/git/home-manager.nix
      ];
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCtrlAndFn = true;
    swapLeftCommandAndLeftAlt = true;
    remapCapsLockToEscape = true;
  };
}
