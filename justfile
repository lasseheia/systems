repo_root := justfile_directory()
tofu_dir := repo_root / "hosts/server/incus/opentofu"

# List available recipes
default:
    @just --list

rebuild:
    sudo nixos-rebuild switch \
        --flake "{{ repo_root }}/hosts/$(hostname -s)#$(hostname -s)"

rebuild-server:
    nixos-rebuild switch \
        --flake "{{ repo_root }}/hosts/server#server" \
        --target-host root@server.heia.sh

# Rebuild macbook locally (nix-darwin)
rebuild-macbook:
    sudo darwin-rebuild switch \
      --flake {{ repo_root }}/hosts/macbook#macbook

# Rebuild a NixOS host remotely (builds on target)
rebuild-remote host ip user="root":
    nixos-rebuild switch \
      --flake {{ repo_root }}/hosts/{{ host }}#{{ host }} \
      --target-host {{ user }}@{{ ip }} \
      --build-host {{ user }}@{{ ip }} \
      --fast

# Rebuild an Incus instance remotely
rebuild-incus instance ip="10.0.0.171" user="root" port="2222":
    NIX_SSHOPTS="-p {{ port }}" nixos-rebuild switch \
      --flake {{ repo_root }}/hosts/server/incus/instances/{{ instance }}#default \
      --target-host {{ user }}@{{ ip }} \
      --build-host {{ user }}@{{ ip }}

# Install a NixOS host remotely via nixos-anywhere
install-remote host ip user="nixos":
    nixos-anywhere \
      --flake {{ repo_root }}/hosts/{{ host }}#{{ host }} \
      --target-host {{ user }}@{{ ip }}

# Build the installer ISO image
build-iso:
    nix build {{ repo_root }}/hosts/installer#nixosConfigurations.installer.config.system.build.isoImage

# Flash an ISO image to a USB device
flash-usb device image:
    sudo wipefs -a {{ device }}
    sudo dd if={{ image }} of={{ device }} bs=4M status=progress conv=fsync

# Build Incus instance images (metadata + disk image)
build-incus instance:
    nix build {{ repo_root }}/hosts/server/incus/instances/{{ instance }}#nixosConfigurations.default.config.system.build.metadata --print-out-paths
    nix build {{ repo_root }}/hosts/server/incus/instances/{{ instance }}#nixosConfigurations.default.config.system.build.qemuImage --print-out-paths

tofu *args:
    direnv exec "{{ tofu_dir }}" tofu -chdir="{{ tofu_dir }}" {{ args }}
