# Maintenance

This repository creates NixOS generations whenever the system is rebuilt. Generations are useful rollback points, but many rapid rebuilds can consume disk space.

## Generation Cleanup

Keep at least the last 5 system generations by default:

```bash
just clean-generations
```

This runs:

```bash
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
sudo nix store gc
```

The first command removes older system rollback points. The second command garbage-collects store paths that are no longer reachable from any remaining profile, generation, or GC root.

Only run cleanup after the current system generation has been tested and works. Cleanup is destructive because removed generations can no longer be used for rollback.

Good times to run cleanup:

- After many rebuilds in a short time.
- When root disk usage is getting high.
- After a larger setup task is complete and the current generation has booted successfully.

Avoid cleanup:

- Immediately after a risky system change.
- Before confirming the current generation boots and the desktop works.
- When you still want older rollback points available.

## Read-Only Checks

List system generations:

```bash
sudo nix-env --profile /nix/var/nix/profiles/system --list-generations
```

Check store size:

```bash
nix path-info --all --closure-size --human-readable
```

Agents may suggest cleanup commands, but sudo cleanup is human-only.
