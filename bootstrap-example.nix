# bootstrap-example.nix
# Use this on a fresh NixOS install to create a minimal environment
# that allows you to clone your full flake config and switch.

{ config, pkgs, ... }:

{
  imports = [
    ./hosts/nixos/hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bootstrap";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  nixpkgs.config.allowUnfree = true;

  users.users.nico = {
    isNormalUser = true;
    description = "Nico";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bash;
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    nano
  ];

  system.stateVersion = "24.11";
}
