{ pkgs, ... }:
{
  networking.nftables.enable = true;
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus; # Default is pkgs.incusStable
    agent.enable = true;
    ui.enable = true;
    preseed = {
      config = {
        "core.https_address" = ":8443";
        "core.storage_buckets_address" = ":8555";
        "images.compression_algorithm" = "gzip";
        "backups.compression_algorithm" = "gzip";
      };
    };
  };
  systemd.services.incus.serviceConfig = {
    Nice = 10;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
    CPUWeight = 20;
    IOWeight = 20;
  };
  networking.firewall.allowedTCPPorts = [
    8443
    8555
  ];
  networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
    53
    67
  ];
  networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
    53
    67
  ];
  security.apparmor.enable = true;
  security.apparmor.includes."abstractions/base" = pkgs.lib.mkAfter ''
    # Allow incusd to execute binaries from the Nix store (gzip, xz, zstd, etc.)
    # Needed for image unpacking which shells out to tar + compression tools
    mrix /nix/store/*/bin/*,
    mrix /nix/store/*/bin/.*,
  '';
}
