{
  config,
  inputs,
  pkgs,
  ...
}:
{
  sops.secrets.renovate-token.sopsFile = inputs.secrets + "/server/renovate.yaml";

  services.renovate = {
    enable = true;
    schedule = "*-*-* 08:00:00";
    credentials.RENOVATE_TOKEN = config.sops.secrets.renovate-token.path;
    runtimePackages = [ pkgs.nix ];
    settings = {
      platform = "github";
      gitAuthor = "Renovate <23742718+lasseheia@users.noreply.github.com>";
      timezone = config.time.timeZone;
      repositories = [ "lasseheia/systems" ];
      autodiscover = false;
      onboarding = false;
      requireConfig = "required";
      binarySource = "global";
      force.automerge = false;
      prConcurrentLimit = 0;
      prHourlyLimit = 0;
    };
  };
}
