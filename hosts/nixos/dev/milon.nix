{ config, lib, ... }:

let
  cfg = config.nico.dev.milon;
in
{
  options.nico.dev.milon = {
    enable = lib.mkEnableOption "Milon local development integration";

    carenext = {
      enable = lib.mkEnableOption "CareNext local development networking";

      trustedInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Network interfaces trusted for local CareNext development.";
      };
    };

    flutter = {
      enable = lib.mkEnableOption "Flutter and Android workstation integration for Milon development";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.carenext.enable {
      networking.hosts = {
        "127.0.0.1" = [
          "www.carenext.test"
          "carenext.test"
          "www.carenext.local"
          "carenext.local"
          "login.carenext.test"
          "socket.carenext.test"
          "docs.carenext.test"
        ];
      };

      networking.firewall.trustedInterfaces = cfg.carenext.trustedInterfaces;
    })

    (lib.mkIf cfg.flutter.enable {
      # Allow Android Studio's downloaded SDK tools to run on NixOS.
      programs.nix-ld.enable = true;
    })
  ]);
}
