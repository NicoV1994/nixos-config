{ lib, odysseus, pkgs, ... }:

let
  proxy = pkgs.writeText "odysseus-llama-proxy.py" (builtins.readFile ./odysseus-llama-proxy.py);

  odysseus-start = pkgs.writeShellApplication {
    name = "odysseus-start";
    runtimeInputs = [ pkgs.xdg-utils ];
    text = ''
      /run/wrappers/bin/sudo systemctl start odysseus-chroma.service odysseus.service
      xdg-open http://127.0.0.1:7000 >/dev/null 2>&1 &
    '';
  };

  odysseus-stop = pkgs.writeShellApplication {
    name = "odysseus-stop";
    text = ''
      /run/wrappers/bin/sudo systemctl stop odysseus.service odysseus-chroma.service
    '';
  };

  odysseus-status = pkgs.writeShellApplication {
    name = "odysseus-status";
    text = ''
      systemctl status odysseus.service odysseus-chroma.service
    '';
  };

  odysseus-list-models = pkgs.writeShellApplication {
    name = "odysseus-list-models";
    runtimeInputs = with pkgs; [ coreutils findutils ];
    text = ''
      /run/wrappers/bin/sudo -u odysseus env HOME=/var/lib/odysseus ${pkgs.bash}/bin/bash -lc '
        find -L "$HOME/.cache/huggingface/hub" -iname "*.gguf" ! -iname "mmproj*.gguf" -printf "%p\n" 2>/dev/null | sort
      '
    '';
  };

  odysseus-serve-model = pkgs.writeShellApplication {
    name = "odysseus-serve-model";
    runtimeInputs = with pkgs; [ coreutils findutils gnugrep python3 systemd ];
    text = ''
      pattern="''${1:-}"
      port="''${2:-8080}"
      backend_port="$((port + 10000))"

      if [ "$pattern" = "--help" ] || [ "$pattern" = "-h" ]; then
        printf 'Usage: odysseus-serve-model [model-name-filter] [port]\n'
        printf 'Example: odysseus-serve-model Qwen2.5 8080\n'
        exit 0
      fi

      model="$(/run/wrappers/bin/sudo -u odysseus env HOME=/var/lib/odysseus ${pkgs.bash}/bin/bash -lc '
        pattern="$1"
        files=$(find -L "$HOME/.cache/huggingface/hub" -iname "*.gguf" ! -iname "mmproj*.gguf" 2>/dev/null || true)
        if [ -n "$pattern" ]; then
          printf "%s\n" "$files" | grep -i -- "$pattern" | sort | tail -n 1
        else
          printf "%s\n" "$files" | sort | tail -n 1
        fi
      ' bash "$pattern")"

      if [ -z "$model" ]; then
        printf 'No downloaded GGUF model found for filter: %s\n' "''${pattern:-<any>}" >&2
        exit 1
      fi

      /run/wrappers/bin/sudo systemctl stop odysseus-llama.service odysseus-llama-backend.service >/dev/null 2>&1 || true
      /run/wrappers/bin/sudo systemd-run \
        --unit=odysseus-llama-backend \
        --description="Odysseus llama.cpp backend" \
        --collect \
        --property=User=odysseus \
        --property=Group=odysseus \
        --property=WorkingDirectory=/var/lib/odysseus \
        --property=Restart=on-failure \
        --setenv=HOME=/var/lib/odysseus \
        ${pkgs.llama-cpp}/bin/llama-server \
        --model "$model" \
        --host 127.0.0.1 \
        --port "$backend_port"

      /run/wrappers/bin/sudo systemd-run \
        --unit=odysseus-llama \
        --description="Odysseus llama.cpp localhost proxy" \
        --collect \
        --property=User=odysseus \
        --property=Group=odysseus \
        --property=WorkingDirectory=/var/lib/odysseus \
        --property=Restart=on-failure \
        --setenv=ODYSSEUS_LLAMA_BACKEND_PORT="$backend_port" \
        --setenv=ODYSSEUS_LLAMA_PROXY_PORT="$port" \
        ${pkgs.python3}/bin/python ${proxy}

      printf 'Serving %s\n' "$model"
      printf 'Endpoint: http://127.0.0.1:%s/v1\n' "$port"
      printf 'Logs: journalctl -u odysseus-llama -u odysseus-llama-backend -f\n'
    '';
  };
in
{
  imports = [ odysseus.nixosModules.default ];

  # Experimental: Odysseus is pinned to an unmerged upstream PR.
  # Removal: delete this directory, remove its host import, and drop the flake input.
  services.odysseus = {
    enable = true;
    host = "127.0.0.1";
    llamaCpp = {
      enable = true;
      package = pkgs.llama-cpp;
    };
    port = 7000;
  };

  systemd.services.odysseus.wantedBy = lib.mkForce [ ];
  systemd.services.odysseus-chroma.wantedBy = lib.mkForce [ ];
  users.users.odysseus.shell = pkgs.bashInteractive;

  environment.systemPackages = [
    odysseus-start
    odysseus-stop
    odysseus-status
    odysseus-list-models
    odysseus-serve-model
  ];

  home-manager.users.nico.programs.bash.shellAliases = {
    ody = "odysseus-start";
    ody-models = "odysseus-list-models";
    ody-serve = "odysseus-serve-model";
    ody-serve-status = "systemctl status odysseus-llama odysseus-llama-backend";
    ody-serve-stop = "/run/wrappers/bin/sudo systemctl stop odysseus-llama odysseus-llama-backend";
    ody-stop = "odysseus-stop";
    ody-status = "odysseus-status";
  };
}
