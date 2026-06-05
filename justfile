host := "nixos"

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
