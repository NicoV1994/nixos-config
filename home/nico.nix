{ config, pkgs, ... }:

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
    vanilla-dmz #cursor
    wofi #d-menu
    thunar #file explorere
    hyprpaper #background image
    gtklock #lockscreen
    wl-clipboard #clipboard
    tokyonight-gtk-theme #theme

    # terminal tools
    tmux
    neovim
    ripgrep #for fuzzy finding (leader s g)
    codex #OpenAI coding agent CLI
    unzip
    nodejs_22

    # tools
    git
    gh
    lazygit
    wget
    bitwarden-desktop
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
  xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;
  xdg.configFile."ghostty/config".source = ../dotfiles/ghostty/config;
  home.file.".tmux.conf".source = ../dotfiles/tmux/.tmux.conf;

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = /home/nico/nixos-config/assets/wallpapers/pawel-czerwinski.jpg

    wallpaper {
      monitor = eDP-1
      path = /home/nico/nixos-config/assets/wallpapers/pawel-czerwinski.jpg
      fit_mode = cover
    }

    ipc = off
  '';

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
