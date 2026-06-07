{ config, pkgs, ... }:

let
  wallpaper = ../assets/wallpapers/pawel-czerwinski.jpg;
in

{
  home.username = "nico";
  home.homeDirectory = "/home/nico";

  programs.home-manager.enable = true;

  # Let Home Manager install and manage these apps:
  home.packages = with pkgs; [
    direnv #for automatic context switching with nixos
    nix-direnv #for nix to understand direnv

    # c compiler
    gcc
    gnumake
    pkg-config
    cmake

    # system
    ghostty
    fastfetch
    nerd-fonts.jetbrains-mono #waybar
    networkmanagerapplet
    vanilla-dmz #cursor
    wofi #d-menu
    thunar #file explorere
    hyprpaper #background image
    gtklock #lockscreen
    wl-clipboard #clipboard
    grim #screenshots
    slurp #screenshot region picker
    swappy #screenshot editor
    brightnessctl #laptop brightness keys
    playerctl #media keys
    pavucontrol #audio control panel
    tokyonight-gtk-theme #theme

    # terminal tools
    tmux
    neovim
    ripgrep #for fuzzy finding (leader s g)
    codex #OpenAI coding agent CLI
    opencode #OpenCode coding agent CLI
    unzip
    nodejs_22

    # tools
    git
    gh
    just
    lazygit
    usbutils # USB diagnostics, e.g. checking Android phones with lsusb
    wget

    # Flutter / Android development. Terminal builds use devshells/flutter-android.nix.
    android-studio

    bitwarden-desktop
    brave
    librewolf
    proton-vpn
    teams-for-linux
    vscode-fhs
    dbeaver-bin

    # personal / entertainment
    discord

    # Qt theming tools
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
  ];

  # Link config files from your repo
  xdg.configFile."hypr/hyprland.conf".text =
    builtins.replaceStrings
      [ "exec-once = hyprpaper" ]
      [ "exec-once = ${pkgs.hyprpaper}/bin/hyprpaper" ]
      (builtins.readFile ../dotfiles/hyprland/hyprland.conf);
  xdg.configFile."waybar/config".source = ../dotfiles/waybar/config;
  xdg.configFile."waybar/style.css".source = ../dotfiles/waybar/style.css;
  xdg.configFile."waybar/scripts/cpu-status.sh".source = ../dotfiles/waybar/scripts/cpu-status.sh;
  xdg.configFile."waybar/scripts/memory-status.sh".source = ../dotfiles/waybar/scripts/memory-status.sh;
  xdg.configFile."waybar/scripts/mic-status.sh".source = ../dotfiles/waybar/scripts/mic-status.sh;
  xdg.configFile."waybar/scripts/network-status.sh".source = ../dotfiles/waybar/scripts/network-status.sh;
  xdg.configFile."waybar/scripts/power-profile-status.sh".source = ../dotfiles/waybar/scripts/power-profile-status.sh;
  xdg.configFile."waybar/scripts/power-profile-toggle.sh".source = ../dotfiles/waybar/scripts/power-profile-toggle.sh;
  xdg.configFile."waybar/scripts/system-menu.sh".source = ../dotfiles/waybar/scripts/system-menu.sh;
  xdg.configFile."waybar/scripts/vpn-menu.sh".source = ../dotfiles/waybar/scripts/vpn-menu.sh;
  xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
  xdg.configFile."ghostty/config".source = ../dotfiles/ghostty/config;
  home.file.".tmux.conf".source = ../dotfiles/tmux/.tmux.conf;

  xdg.configFile."autostart/proton-vpn.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Proton VPN
    Exec=${pkgs.proton-vpn}/bin/protonvpn-app
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}

    wallpaper {
      monitor =
      path = ${wallpaper}
      fit_mode = cover
    }

    ipc = off
    splash = false
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Keep Firefox as the dedicated streaming browser. Brave stays the work browser,
  # while LibreWolf is installed separately for privacy-focused browsing.
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    policies = {
      Preferences."media.eme.enabled" = {
        Value = true;
        Status = "default";
      };
      ExtensionSettings."uBlock0@raymondhill.net" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      };
    };
  };

  # GTK + Theme settings (Tokyo Night/dark)
  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "DMZ-White";
      package = pkgs.vanilla-dmz;
    };
  };

  # GTK4 apps also respect dark mode:
  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Tokyonight-Dark
    gtk-application-prefer-dark-theme=1
  '';

  # Qt config (enables qt5ct + kvantum for dark)
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "kvantum";
  };

  # Enable Waybar support (with modules defined in your dotfiles)
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # Use Wayland-optimized environment for apps
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XCURSOR_THEME = "DMZ-White";
    XCURSOR_SIZE = "24";
    CHROME_EXECUTABLE = "${pkgs.brave}/bin/brave";
  };

  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec uwsm start hyprland-uwsm.desktop
      fi
    '';
    initExtra = ''
      if [ "$TERM_PROGRAM" = "ghostty" ]; then
        fastfetch
      fi
    '';
  };

  home.stateVersion = "24.11";
}
