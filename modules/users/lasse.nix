{ pkgs, lib, config, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  homeDir = if isDarwin then "/Users/lasse" else "/home/lasse";
  cfg = config.modules.users.lasse;
in {
  options.modules.users.lasse = {
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional groups for the lasse user.";
    };
  };

  config = {
    users.users.lasse = {
      home = homeDir;
      shell = pkgs.zsh;
    }
    // lib.optionalAttrs (!isDarwin) {
      isNormalUser = true;
      extraGroups = [ "wheel" ] ++ cfg.extraGroups;
    }
    // lib.optionalAttrs isDarwin {
      name = "lasse";
    };

    programs.zsh.enable = lib.mkIf isDarwin true;

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
  };
}
