host := "nixos"

default: help

help:
    @printf '%s\n' "Nico's NixOS Config"
    @printf '%s\n' ""
    @printf '%s\n' "Beginner mental model:"
    @printf '%s\n' "  This repo is the source of truth for the OS, user apps, and dotfiles."
    @printf '%s\n' "  Edit files here instead of clicking through system settings when possible."
    @printf '%s\n' "  A rebuild creates a new generation; old generations are rollback points."
    @printf '%s\n' "  Build/check commands are safe because they do not activate changes."
    @printf '%s\n' "  switch applies the config to the running system and may need logout/reboot."
    @printf '%s\n' "  If something breaks, choose an older generation at boot or roll config back in Git."
    @printf '%s\n' "  Prefer small commits so OS changes are easy to review and undo."
    @printf '%s\n' ""
    @printf '%s\n' "Daily workflow:"
    @printf '%s\n' "  just status      Show changed files"
    @printf '%s\n' "  just check       Validate flake evaluation"
    @printf '%s\n' "  just build       Build system without activating"
    @printf '%s\n' "  just preflight   Format, check, and build before switching"
    @printf '%s\n' "  just switch      Apply system + Home Manager config"
    @printf '%s\n' ""
    @printf '%s\n' "Safe read-only commands:"
    @printf '%s\n' "  just status"
    @printf '%s\n' "  just check"
    @printf '%s\n' "  just build"
    @printf '%s\n' "  just validate"
    @printf '%s\n' ""
    @printf '%s\n' "Editing workflow:"
    @printf '%s\n' "  1. Change files"
    @printf '%s\n' "  2. Run just preflight"
    @printf '%s\n' "  3. Run just switch when ready to apply"
    @printf '%s\n' "  4. Reboot/log out if groups, drivers, or session variables changed"
    @printf '%s\n' ""
    @printf '%s\n' "Flutter Android:"
    @printf '%s\n' "  cd /path/to/flutter-project"
    @printf '%s\n' "  nix develop /home/nico/nixos-config#flutter-android"
    @printf '%s\n' "  flutter doctor -v"
    @printf '%s\n' "  flutter run --flavor development --dart-define API_HOST=..."
    @printf '%s\n' ""
    @printf '%s\n' "Maintenance:"
    @printf '%s\n' "  just clean-generations"
    @printf '%s\n' "  Keeps latest 5 system generations and runs GC."
    @printf '%s\n' "  Only run after confirming the current generation works."
    @printf '%s\n' ""
    @printf '%s\n' "Careful / human-only commands:"
    @printf '%s\n' "  just switch             Activate config"
    @printf '%s\n' "  just boot               Set config for next boot"
    @printf '%s\n' "  just update             Update flake.lock"
    @printf '%s\n' "  just clean-generations  Delete old rollback generations"
    @printf '%s\n' ""
    @printf '%s\n' "More docs:"
    @printf '%s\n' "  docs/flutter-android.md"
    @printf '%s\n' "  docs/maintenance.md"

check:
    @printf 'Running flake check...\n'
    @nix flake check --no-warn-dirty
    @printf 'Flake check complete.\n'

fmt:
    @printf 'Formatting Nix files...\n'
    @nix fmt --no-warn-dirty
    @printf 'Formatting complete.\n'

build:
    @printf 'Building system closure without activation...\n'
    @nix build --no-link --no-warn-dirty .#nixosConfigurations.{{host}}.config.system.build.toplevel
    @printf 'Build complete.\n'

validate: check build

preflight: fmt check build

dry:
    sudo nixos-rebuild dry-build --flake .#{{host}}

switch:
    sudo nixos-rebuild switch --flake .#{{host}}

boot:
    sudo nixos-rebuild boot --flake .#{{host}}

clean-generations:
    @printf 'Deleting old system generations, keeping the latest 5...\n'
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
    @printf 'Garbage collecting unreferenced Nix store paths...\n'
    sudo nix store gc
    @printf 'Generation cleanup complete.\n'

update:
    nix flake update

status:
    git status --short

agent-context:
    @printf '== AGENTS.md ==\n'
    @cat AGENTS.md
    @printf '\n== .agent/context.md ==\n'
    @cat .agent/context.md
    @printf '\n== Relevant files ==\n'
    @printf '%s\n' flake.nix hosts/nixos/configuration.nix home/nico.nix dotfiles/ docs/decisions/
