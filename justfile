host := "nixos"

check:
    nix flake check

fmt:
    nix fmt

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
