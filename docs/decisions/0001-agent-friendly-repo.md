# 0001: Agent-Friendly Repository Structure

## Status
Accepted

## Context
This personal NixOS flake is maintained by a human with help from AI coding agents. Agents need concise, stable instructions so they can make safe changes without rediscovering repository conventions from scratch.

## Decision
Use `AGENTS.md` for coding-agent instructions, guardrails, safe commands, and repo layout expectations.

Use `.agent/context.md` for curated repo memory: current focus, design preferences, and project-specific reminders that should stay short.

Use `docs/decisions/` for important structural decisions so future maintainers can understand why the repository is organized this way.

Use `justfile` as the stable command interface for common validation and rebuild commands, while keeping recipes small wrappers around normal Nix and Git commands.

## Consequences
Humans and agents have a predictable starting point before editing. Structural changes should leave a short decision note instead of relying on chat history. The command interface remains simple and does not replace normal Nix workflows.
