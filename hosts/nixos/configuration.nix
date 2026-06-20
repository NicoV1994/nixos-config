{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./dev/milon.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fwupd.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  services.auto-cpufreq.enable = false;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    powertop
    upower
  ];

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
  programs.hyprland.withUWSM = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Container runtime
  virtualisation.docker.enable = true;

  nico.dev.milon = {
    enable = true;
    carenext = {
      enable = true;
      trustedInterfaces = [
        "docker0"
        # Stable Docker Compose bridge for the Milon CareNext local stack.
        "br-carenext"
      ];
    };
    flutter.enable = true;
  };

  # Your user (Home Manager will manage packages)
  users.users.nico = {
    isNormalUser = true;
    description = "Nico";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "kvm" ];
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
