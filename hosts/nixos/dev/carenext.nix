{ config, lib, ... }:

let
  cfg = config.nico.dev.carenext;
in
{
  options.nico.dev.carenext = {
    enable = lib.mkEnableOption "CareNext local development networking";

    trustedInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Network interfaces trusted for local CareNext development.";
    };
  };

  config = lib.mkIf cfg.enable {
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

    networking.firewall.trustedInterfaces = cfg.trustedInterfaces;
  };
}
