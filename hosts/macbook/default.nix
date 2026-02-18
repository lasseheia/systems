{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.default
  ];

  system.stateVersion = 4;
  nix.enable = false; # Required to use nix-darwin
  nix.package = pkgs.lix;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = {
    system = "aarch64-darwin";
  };

  programs.zsh.enable = true;

  users.users.lasse = {
    name = "lasse";
    home = "/Users/lasse";
  };

  environment.systemPackages = with pkgs; [
    podman
    alacritty
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.lasse = {
    home.stateVersion = "23.11";
    imports = [
      ../../modules/terminal/home-manager.nix
      ../../modules/neovim/home-manager.nix
      ../../modules/git/home-manager.nix
    ];
  };

  # - Previously, some nix-darwin options applied to the user running
  #   `darwin-rebuild`. As part of a long‐term migration to make
  #   nix-darwin focus on system‐wide activation and support first‐class
  #   multi‐user setups, all system activation now runs as `root`, and
  #   these options instead apply to the `system.primaryUser` user.

  #   You currently have the following primary‐user‐requiring options set:

  #   * `services.skhd.enable`
  #   * `services.yabai.enable`

  #   To continue using these options, set `system.primaryUser` to the name
  #   of the user you have been using to run `darwin-rebuild`. In the long
  #   run, this setting will be deprecated and removed after all the
  #   functionality it is relevant for has been adjusted to allow
  #   specifying the relevant user separately, moved under the
  #   `users.users.*` namespace, or migrated to Home Manager.

  #   If you run into any unexpected issues with the migration, please
  #   open an issue at <https://github.com/nix-darwin/nix-darwin/issues/new>
  #   and include as much information as possible.
  system.primaryUser = "lasse";

  system.defaults = {
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
  system.keyboard = {
    enableKeyMapping = true;
    swapLeftCtrlAndFn = true;
    swapLeftCommandAndLeftAlt = true;
    remapCapsLockToEscape = true;
  };

  services.aerospace = {
    enable = true;
  };
}
