{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs =
    inputs:
    let
      systems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = systems (
        system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              opentofu
              tofu-ls
              azure-cli
              kubectl
              kubelogin
            ];
          };
        }
      );
    };
}
