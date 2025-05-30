{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  console.keyMap = "de";

  # Display manager and Wayland setup
  services.xserver.enable = false;
 
  # Enable Hyprland
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Your user (Home Manager will manage packages)
  users.users.nico = {
    isNormalUser = true;
    description = "Nico";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.pam.services.gtklock = {
    text = ''
      auth     include login
      account  include login
      password include login
      session  include login
    '';
  };


  # Define your system version
  system.stateVersion = "24.11";
}
