# 0002: Secrets Policy

## Status
Accepted

## Context
This repository should remain safe to push to Git and easy to review. Some future setup work may need private values such as SSH keys, VPN credentials, API tokens, Wi-Fi passwords, or `.env` files.

## Decision
Do not add a Nix secrets framework yet.

Keep secrets out of Git. Store SSH keys in `~/.ssh`, keep passwords and tokens in Bitwarden or another password manager, and restore project-local secrets manually when needed.

Revisit `sops-nix` or `agenix` only when manual secret restore becomes painful, such as when this config needs to support multiple machines or declarative service credentials.

## Consequences
The repo stays simpler and avoids premature secrets tooling. A fresh install is not fully one-command reproducible because private credentials still require manual restore.
