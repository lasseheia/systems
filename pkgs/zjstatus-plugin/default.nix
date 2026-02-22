{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "zjstatus-plugin";
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    hash = "9a4b88fdceee8eb2b8c28111c53e94254d61c994";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 "$src" "$out/share/zellij/plugins/zjstatus.wasm"
    runHook postInstall
  '';
}
