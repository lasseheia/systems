{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "zjstatus-plugin";
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.24.0/zjstatus.wasm";
    hash = "sha256-HM7ezh3tYs8+IJvmkM3TnKb7noIo7XGpUfZQf5lWZps=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 "$src" "$out/share/zellij/plugins/zjstatus.wasm"
    runHook postInstall
  '';
}
