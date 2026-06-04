# Tasks

This file tracks not-done work for this NixOS config. Tasks are written as small Shape Up style briefs so they are useful both for humans and AI agents.

## Active / Not Done

### Quick Notes Shortcut
Status: Shaped
Appetite: Small

Problem:
I want a very fast way to open a new note without thinking about filenames or folders. The notes should live in one place and be easy to fuzzy find later.

Solution:
Add a Hyprland shortcut, likely `Super+N`, that opens Neovim with a new Markdown file in `~/notes`. The filename should be timestamp based, using a sortable format like `YYYY-MM-DD-HH-MM-SS.md`.

Look And Feel:
The shortcut should feel instant. It should open a terminal editor directly into an empty note file. The notes folder should be boring and stable: plain Markdown files, no database, no app lock-in.

Done When:
- `~/notes` is created automatically if it does not exist.
- Pressing the shortcut opens Neovim on a new timestamped note.
- The filename includes date and time down to seconds.
- Existing notes are never overwritten.
- Notes can be found later with normal shell tools or Neovim/Telescope fuzzy search.

Validation:
- Apply the NixOS config.
- Press the shortcut twice.
- Confirm two different files exist in `~/notes`.
- Confirm Neovim opens the new file each time.

Open Questions:
- Confirm the shortcut should be `Super+N`.
- Decide whether the terminal should be `ghostty` explicitly or use the existing Hyprland `$terminal` variable.

### Install PewDiePie Odysseus
Status: Raw
Appetite: Small

Problem:
I want PewDiePie Odysseus installed on this setup.

Solution:
Find the correct package, app source, or installation method and add it declaratively to this repo if possible.

Look And Feel:
The app should launch from the desktop/app launcher like other installed applications. Prefer a reproducible Nix package over a manual install.

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

### Repository Learning Log And AI Capability
Status: Shaped
Appetite: Medium

Problem:
When we solve bigger problems in this repo, the reasoning and fix can disappear into chat history. Later, humans and AI agents have to rediscover the same context.

Solution:
Add a lightweight log system for major problems and decisions. Use it for significant issues only, not every tiny change. Link the practice from `AGENTS.md` so future AI agents know to read and update it when useful.

Look And Feel:
Logs should be concise and searchable. Each entry should explain what broke, why it happened, what fixed it, and any follow-up. Prefer plain Markdown in a predictable folder, for example `docs/logs/`.

Done When:
- A log folder exists with a template or first entry.
- `AGENTS.md` tells AI agents when to read/write logs.
- The README or task file points to the logs.
- The process is clear enough to use without extra explanation.

Validation:
- Create one sample log entry from a real repo issue.
- Confirm an agent can find the instructions from `AGENTS.md`.
- Confirm the log format is easy to skim.

Open Questions:
- Decide whether logs should be in `docs/logs/` or another root folder.
- Decide the threshold for writing a log entry.

### Flutter Development Environment
Status: Shaped
Appetite: Medium

Problem:
I need this NixOS setup to support Flutter app development.

Solution:
Add the required development tools declaratively. Support Flutter CLI workflows first, then add editor integration if needed.

Look And Feel:
Flutter development should work from the terminal and Neovim without manual one-off system setup. Android support should be explicit because it often needs SDK, licenses, emulator, USB/debug permissions, and environment variables.

Done When:
- `flutter` is available in the user environment or a documented dev shell.
- Android SDK/tooling approach is decided and configured.
- A new Flutter app can be created and analyzed.
- The setup supports running on at least one target, such as Android device, emulator, Linux desktop, or web.

Validation:
- Run `flutter doctor`.
- Run `flutter create` in a temporary directory.
- Run `flutter analyze`.
- Run a sample app on the selected target.

Open Questions:
- Decide whether Flutter should be globally installed in `home.packages` or isolated in a `devShell`.
- Decide primary target: Android phone, Android emulator, Linux desktop, or web.
- Decide whether Neovim should get Dart/Flutter LSP support.

## Betting Table

### Offline Local LLM For OpenCode
Status: Raw
Appetite: Medium

Problem:
I want to use OpenCode while offline by running the strongest local model that the laptop can realistically handle.

Solution:
Investigate local LLM runtimes and model choices for the laptop hardware. Prefer a setup that can be installed declaratively through NixOS/Home Manager and exposed to OpenCode as a local OpenAI-compatible endpoint if possible.

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

### Tune Waybar Microphone Indicator
Status: Shaped
Appetite: Small

Problem:
The microphone indicator should show real input activity without wasting battery or showing constant noise.

Solution:
Tune the current RMS threshold and interval after testing with the actual headset and laptop microphone.

Done When:
- Silent room does not show constant activity.
- Normal speech shows visible activity quickly.
- Muted mode stays cheap and clear.

Validation:
- Test muted, silent unmuted, and normal speech cases.
- Check Waybar CPU usage before and after.

### Power Diagnostics Tools
Status: Raw
Appetite: Small

Problem:
It is hard to measure battery drain and per-process power usage with the current installed tools.

Solution:
Consider adding tools like `powertop`, `upower`, and `powerstat`.

Done When:
- Battery/power state can be inspected from the terminal.
- There is a documented command for checking rough idle drain.

## Done

Completed work can be moved here with a short note and date.
