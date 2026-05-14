{
  imports = [
    ../../modules/services/openssh.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";

  users.users.nixos.openssh.authorizedKeys.keyFiles = [
    ../../keys/users/lasse_ed25519.pub
  ];

  console.keyMap = "no";
}
