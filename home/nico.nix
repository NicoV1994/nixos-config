{ config, pkgs, ... }:

{
  home.username = "nico";
  home.homeDirectory = "/home/nico";

  programs.home-manager.enable = true;

  # Let Home Manager install and manage these apps:
  home.packages = with pkgs; [
    wezterm
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    vanilla-dmz
    wofi
    kdePackages.dolphin
    swww
    gtklock
    neovim
    git
    wget
    bitwarden
    brave
    firefox
    teams-for-linux
    vscode-fhs
    dbeaver-bin
  ];

  # Link config files from your repo
  xdg.configFile."hypr/hyprland.conf".source = ../dotfiles/hyprland/hyprland.conf;
  xdg.configFile."waybar/config".source = ../dotfiles/waybar/config;
  xdg.configFile."wezterm/wezterm.lua".source = ../dotfiles/wezterm/wezterm.lua;
  # xdg.configFile."nvim/init.lua".source = ../dotfiles/nvim/init.lua;

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
