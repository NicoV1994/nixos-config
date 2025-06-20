{ config, pkgs, ... }:

{
  home.username = "nico";
  home.homeDirectory = "/home/nico";

  programs.home-manager.enable = true;

  # Let Home Manager install and manage these apps:
  home.packages = with pkgs; [
    # c compiler
    gcc
    gnumake
    pkg-config
    cmake

    # system
    ghostty
    wezterm
    nerd-fonts.jetbrains-mono #wezterm waybar
    nerd-fonts.fira-code #wezterm
    vanilla-dmz #cursor
    wofi #d-menu
    kdePackages.dolphin #file explorere
    swww #background image
    gtklock #lockscreen
    wl-clipboard #clipboard

    # terminal tools
    tmux
    neovim
    ripgrep #for fuzzy finding (leader s g)
    unzip

    # tools
    git
    wget
    bitwarden
    brave
    firefox
    teams-for-linux
    vscode-fhs
    dbeaver-bin

    # Qt theming tools
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
  ];

  # Link config files from your repo
  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/hyprland/hyprland.conf;
  xdg.configFile."waybar/config".source = ../dotfiles/waybar/config;
  xdg.configFile."waybar/style.css".source = ../dotfiles/waybar/style.css;
  xdg.configFile."wezterm/wezterm.lua".source = ../dotfiles/wezterm/wezterm.lua;
  xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
  xdg.configFile."ghostty/config".source = ../dotfiles/ghostty/config;
  home.file.".tmux.conf".source = ../dotfiles/tmux/.tmux.conf;

  # GTK + Theme settings (Nord/dark)
  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
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
    gtk-theme-name=Nordic
    gtk-application-prefer-dark-theme=1
  '';

  # Qt config (enables qt5ct + kvantum for dark)
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "kvantum";
  };

  # Enable Waybar support (with modules defined in your dotfiles)
  programs.waybar.enable = true;

  # Use Wayland-optimized environment for apps
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XCURSOR_THEME = "DMZ-White";
    XCURSOR_SIZE = "24";
  };

  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  home.stateVersion = "24.11";
}
