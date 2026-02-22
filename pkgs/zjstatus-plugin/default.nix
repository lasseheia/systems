{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "zjstatus-plugin";
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    hash = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 "$src" "$out/share/zellij/plugins/zjstatus.wasm"
    runHook postInstall
  '';
}
