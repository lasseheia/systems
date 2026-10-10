{ config, lib, ... }:
let
  backends = {
    ha = "http://haos.incus:8123";
    z2m = "http://zigbee2mqtt.incus:8080";
  };
in
{
  services.resolved = {
    enable = true;
    dnsDelegates.incus.Delegate = {
      DNS = "192.168.0.1";
      Domains = "~incus";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = false;
      credentialFiles.CF_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare-api-token.path;
    };
    certs."heia.sh" = {
      extraDomainNames = [ "*.heia.sh" ];
      extraLegoFlags = [ "--dns.propagation.wait=30s" ];
    };
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts = lib.mapAttrs' (
      name: backend:
      lib.nameValuePair "${name}.heia.sh" {
        useACMEHost = "heia.sh";
        extraConfig = "reverse_proxy ${backend}";
      }
    ) backends;
  };
}
