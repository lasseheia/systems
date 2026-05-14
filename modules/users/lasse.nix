{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  homeDir = if isDarwin then "/Users/lasse" else "/home/lasse";
in {
  users.users.lasse = {
    home = homeDir;
    shell = pkgs.zsh;
  }
  // lib.optionalAttrs (!isDarwin) {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lasse = {
      programs.home-manager.enable = true;
      home = {
        stateVersion = lib.mkDefault "23.05";
        username = "lasse";
        homeDirectory = homeDir;
      };
    };
  };
}
