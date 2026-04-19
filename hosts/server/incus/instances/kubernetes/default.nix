{
  system.stateVersion = "26.05";

  console.keyMap = "no";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keyFiles = [ ../../../../../keys/users/lasse_ed25519.pub ];
  };

  services.k3s = {
    enable = true;
    extraFlags = [ "--tls-san=10.0.0.171" ];
  };
  networking.firewall.allowedTCPPorts = [ 6443 ];
}
