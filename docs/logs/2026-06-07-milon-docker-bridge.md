# Milon Docker Bridge Firewall Trust

Date: 2026-06-07
Status: Follow-up needed

## Problem

The NixOS config trusts a specific Docker bridge interface, `br-f078f06683cb`, and it was unclear whether this was still needed for the Milon project.

## Context

The trusted bridge is configured in `hosts/nixos/configuration.nix` through `nico.dev.carenext.trustedInterfaces`. This is host-specific local development networking for `/home/nico/Haggla/Milon/milon-care-next`.

## Root Cause

The bridge is not random stale config. It belongs to Docker Compose network `app_default_network`, created by Compose project `db` from `/home/nico/Haggla/Milon/milon-care-next/db/docker-compose.yml`.

The stack containers were all stopped during review, but the network still existed and mapped to interface `br-f078f06683cb`.

## Fix

Kept `br-f078f06683cb` in `networking.firewall.trustedInterfaces` and clarified the comment in `hosts/nixos/configuration.nix` so future reviews know it is for the Milon `db` stack.

## Validation

Verified the bridge and Compose project with Docker/network inspection, then ran `just check` after the config comment update.

## Follow-Up

If the Milon `db` Compose network is recreated, Docker may assign a different bridge interface name. Re-check the bridge before removing or changing this trusted interface.

## Useful Commands

```bash
ip link show br-f078f06683cb
docker network inspect app_default_network
docker ps -a --format '{{.Names}} {{.Status}} {{.Networks}} {{.Image}}'
docker compose ls --all
```
