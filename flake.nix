{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs:
    let
      systems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
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
              just
              nixos-rebuild
              nixos-anywhere

              # Pre-commit hooks
              pre-commit
              nixfmt
              deadnix
              statix
              opentofu
              kubeconform
              stylua
            ];
          };
        }
      );
    };
}
