# Milon Docker Bridge Firewall Trust

Date: 2026-06-07
Status: Fixed with stable bridge

## Problem

The NixOS config trusted a generated Docker bridge interface, `br-f078f06683cb`, and it was unclear whether this was still needed for the Milon project. After Docker recreated `app_default_network`, `carenext.test` started returning Traefik 504 responses because the new bridge was not trusted by the NixOS firewall.

## Context

The trusted bridge is configured in `hosts/nixos/configuration.nix` through `nico.dev.milon.carenext.trustedInterfaces`. This is host-specific local development networking for `/home/nico/Haggla/Milon/milon-care-next`.

CareNext's local Traefik container is started from `/home/nico/Haggla/Milon/milon-care-next/db/docker-compose.yml`. It routes `carenext.test` traffic from Docker back to host ports such as Vite on `5173` and the API on `3000`.

## Root Cause

The bridge is not random stale config. It belongs to Docker Compose network `app_default_network`, created by Compose project `db` from `/home/nico/Haggla/Milon/milon-care-next/db/docker-compose.yml`.

Trusting Docker's generated bridge name is brittle because Docker may assign a different bridge interface if the network is recreated.

## Fix

Pinned the Docker bridge name in CareNext's `db/docker-compose.yml` with `com.docker.network.bridge.name: br-carenext` and changed NixOS to trust `br-carenext` instead of the generated bridge name.

## Validation

Verified the failure by checking direct host ports, Traefik access logs, `docker network inspect app_default_network`, and requests from inside the Traefik container to host ports. After the fix, validated the compose files with `docker compose config --quiet` and the NixOS config with `just build`.

## Follow-Up

After changing the compose file, the existing Docker network must be recreated before the new bridge name appears. Do not run destructive Docker network commands from agents without explicit approval.

## Useful Commands

```bash
docker network inspect app_default_network
docker ps -a --format '{{.Names}} {{.Status}} {{.Networks}} {{.Image}}'
docker compose ls --all
docker exec db-traefik-1 wget -S -O - -T 8 http://host.docker.internal:5173/
ip link show br-carenext
```
