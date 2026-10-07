{ stdenvNoCC, fetchurl }:

let
  version = "0.25.0";
in
stdenvNoCC.mkDerivation {
  pname = "zjstatus-plugin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjstatus.wasm";
    hash = "sha256-KCzqshnlbhkIyfrDOQckH+bD4e99hfqrPl9DjO+HuP4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 "$src" "$out/share/zellij/plugins/zjstatus.wasm"
    runHook postInstall
  '';
}
