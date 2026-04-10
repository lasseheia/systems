{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  dockerShim = pkgs.writeShellScriptBin "docker" (
    lib.replaceStrings [ "@PODMAN@" ] [ "${pkgs.podman}" ] (builtins.readFile ./scripts/docker-shim.sh)
  );
  keyboardMappingJson = builtins.toJSON {
    UserKeyMapping = config.system.keyboard.userKeyMapping;
  };
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
    package = pkgs.lixPackageSets.stable.lix;
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        inherit (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })
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
    #pre-commit
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

  launchd.user.agents.keyboard-remap = lib.mkIf config.system.keyboard.enableKeyMapping {
    script = lib.replaceStrings [ "@KEYMAP_JSON@" ] [ keyboardMappingJson ] (
      builtins.readFile ./scripts/keyboard-remap.sh
    );
    serviceConfig = {
      RunAtLoad = true;
      StandardOutPath = "/tmp/keyboard-remap.log";
      StandardErrorPath = "/tmp/keyboard-remap.log";
    };
  };
}
