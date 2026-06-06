# Tasks

This file tracks not-done work for this NixOS config. Tasks are written as small Shape Up style briefs so they are useful both for humans and AI agents.

## Active / Not Done

No active task is selected. Promote one item from the betting table when ready.

## Betting Table

### Install PewDiePie Odysseus
Status: Paused
Appetite: Small

Problem:
I want PewDiePie Odysseus installed on this setup.

Current State:
There is separate branch work for Odysseus, but it is too experimental to continue on `main` right now.

Solution:
Do not proceed until the exact upstream project/app and installation strategy are clearer. If resumed, prefer a reproducible Nix package over a manual install.

Look And Feel:
The app should launch from the desktop/app launcher like other installed applications.

Done When:
- The correct app/project is identified.
- It is installed declaratively if a Nix package or reliable source exists.
- It can be launched after `nixos-rebuild switch`.

Validation:
- Apply the config.
- Launch the app from terminal or app launcher.
- Confirm it starts successfully.

Open Questions:
- Clarify the exact upstream project/app name and source URL.
- Check whether this exists in nixpkgs, Flathub, AppImage, or another trustworthy source.
- Decide whether to keep experimenting on the separate branch or drop it.

### Offline Local LLM For OpenCode
Status: Paused
Appetite: Medium

Problem:
I want to use OpenCode while offline by running the strongest local model that the laptop can realistically handle.

Solution:
Investigate local LLM runtimes and model choices for the laptop hardware. Prefer a setup that can be installed declaratively through NixOS/Home Manager and exposed to OpenCode as a local OpenAI-compatible endpoint if possible.

Current State:
Local LLM work is present/running on an experimental branch, but it is not usable enough right now and is not a priority.

Look And Feel:
The workflow should be simple: start the local model service, point OpenCode at it, and keep working without internet. It should choose quality first within the laptop's RAM/VRAM/CPU limits, but remain usable enough for coding tasks.

Done When:
- The laptop hardware limits are identified, including RAM, GPU/VRAM if available, and CPU.
- A local runtime is chosen, such as Ollama, llama.cpp, LM Studio, or another OpenAI-compatible server.
- One or more candidate coding models are tested locally.
- OpenCode can use the local model endpoint while offline.
- The chosen setup is documented with start/use commands.

Validation:
- Disconnect from the network.
- Start the local model runtime.
- Run OpenCode against the local endpoint.
- Ask it to inspect or edit a small repo task.
- Confirm response speed and quality are acceptable.

Open Questions:
- Which laptop should this target?
- Should the runtime be declarative in NixOS, or is a manually managed app acceptable for first testing?
- Should the priority be best coding quality, fastest usable response, or lowest battery usage?

### Improve Neovim File Navigation
Status: Shaped
Appetite: Small

Problem:
I want to see nearby files and folders from the file I am editing without remembering `:Explore` commands.

Solution:
Add Neo-tree as a sidebar file explorer and bind it to `Space e`.

Look And Feel:
Minimal left sidebar, works with Nerd Font icons, reveals the current file, and does not replace Telescope.

Shortcuts:
- `Space e`: toggle file explorer
- `Space sf`: fuzzy find files with Telescope
- `Space Space`: switch buffers

Done When:
- Neo-tree opens with `Space e`.
- It reveals the current file.
- Telescope shortcuts still work.
- Neovim starts without plugin errors.

Validation:
- Open Neovim.
- Press `Space e`.
- Navigate files with `Enter`.
