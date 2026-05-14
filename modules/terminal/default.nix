{ pkgs, ... }:

{
  console = {
    earlySetup = true;
    keyMap = "no";
    font = "ter-i16b";
    packages = with pkgs; [ terminus_font ];
  };

  users.defaultUserShell = pkgs.zsh;

  programs.ssh.startAgent = true;

  nix.extraOptions = ''
    trusted-users = root lasse
  '';

  home-manager.users.lasse = ./home-manager.nix;
}
