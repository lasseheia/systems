{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  ssh_keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8V+W2mKUj8QpWJe5N8Z6zrekUISHwdXy6vp4nkte4l" ];
  opencodeSnapshotCleanup = pkgs.writeShellScript "opencode-snapshot-cleanup" ''
    set -eu

    SNAPSHOT_DIR="$HOME/.local/share/opencode/snapshot"
    MAX_BYTES=$((10 * 1024 * 1024 * 1024))
    RETAIN_DAYS=14

    if [ ! -d "$SNAPSHOT_DIR" ]; then
      exit 0
    fi

    find "$SNAPSHOT_DIR" -type f \( -name 'tmp_pack_*' -o -name '.tmp-*-pack-*' \) -delete
    find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d -mtime "+$RETAIN_DAYS" -exec rm -rf {} +

    current_bytes="$(du -sb "$SNAPSHOT_DIR" | cut -f1)"
    if [ "$current_bytes" -gt "$MAX_BYTES" ]; then
      rm -rf "$SNAPSHOT_DIR"/* "$SNAPSHOT_DIR"/.[!.]* "$SNAPSHOT_DIR"/..?* 2>/dev/null || true
    fi
  '';

  opencodeLimited = pkgs.writeShellScriptBin "opencode-limited" ''
    exec ${pkgs.systemd}/bin/systemd-run \
      --user \
      --scope \
      --collect \
      --quiet \
      -p CPUQuota=150% \
      ${pkgs.coreutils}/bin/nice -n 10 ${pkgs.opencode}/bin/opencode "$@"
  '';
in
{
  modules.hyprland.profile = "server";

  imports = [
    inputs.home-manager.nixosModules.default
    ./incus/nixos
    ../../modules/terminal
    ../../modules/hyprland
    ../../modules/neovim
    ../../modules/git
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    freerdp
    remmina
  ];

  system.stateVersion = "24.11";
  console.keyMap = "no";
  time.timeZone = "Europe/Oslo";

  networking = {
    hostName = "server";
    firewall = {
      enable = true;
    };
  };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 15;
    };

    kernelParams = [ "noresume" ];
    consoleLogLevel = 3;
  };

  # Keep zram swap, but do not wait for the ZFS zvol swap device during boot.
  swapDevices = lib.mkForce [ ];

  zramSwap = {
    enable = true;
    memoryPercent = 20;
    priority = 100;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  powerManagement.cpuFreqGovernor = "performance";

  users.mutableUsers = true;
  users.users = {
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keys = ssh_keys;
    };
    lasse = {
      isNormalUser = true;
      home = "/home/lasse";
      openssh.authorizedKeys.keys = ssh_keys;
      extraGroups = [
        "wheel"
        "incus-admin"
      ];
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lasse = {
      programs.home-manager.enable = true;
      home = {
        stateVersion = "23.05";
        username = "lasse";
        homeDirectory = "/home/lasse";
      };

      programs = {
        zsh.shellAliases.opencode = "opencode-limited";
        opencode.package = pkgs.opencode;
      };

      home.packages = [ opencodeLimited ];

      systemd.user.services.opencode-snapshot-cleanup = {
        Unit.Description = "Cleanup opencode snapshot cache";
        Service = {
          Type = "oneshot";
          ExecStart = opencodeSnapshotCleanup;
        };
      };

      systemd.user.timers.opencode-snapshot-cleanup = {
        Unit.Description = "Run opencode snapshot cleanup daily";
        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = "1d";
          RandomizedDelaySec = "30m";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
