{ lib, ... }:
{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix.extraOptions = ''
    trusted-users = root lasse
  '';
  nix.settings = {
    experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = lib.mkDefault true;
  };
  nix.optimise.automatic = lib.mkDefault true;

  programs.ssh.startAgent = true;

  networking.firewall.enable = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Oslo";
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings.LC_TIME = lib.mkDefault "nb_NO.UTF-8";
  };

  security.polkit.enable = lib.mkDefault true;
}
