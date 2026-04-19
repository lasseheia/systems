{
  nix.settings.experimental-features = "nix-command flakes";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.users.nixos.openssh.authorizedKeys.keyFiles = [
    ../../keys/users/lasse_ed25519.pub
  ];

  console.keyMap = "no";
}
