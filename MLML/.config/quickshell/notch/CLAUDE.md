# Notch: a Dynamic Island shell for Hyprland (Quickshell)

A Quickshell (QML) shell that recreates Apple's Dynamic Island / notch: one pill at the top center of the screen that morphs fluidly between a compact idle state and expanded states for each feature. It should feel like one cohesive first-party product, not a set of separate widgets.

## Features

Each is a state of the notch:

1. **Clock**: idle-state time; expanded view has larger time and date.
2. **Calendar**: month grid, today highlighted, prev/next month, jump to today. Pure QML date logic. Optional event list via `khal` if installed.
3. **App launcher**: fuzzy search over desktop entries, keyboard-first, icons, frequency-ordered.
4. **Music player**: MPRIS. Album art, title, artist, seekable progress, transport controls. Idle pill shows mini artwork and animated equalizer bars while playing. Handle multiple players.
5. **PC stats**: CPU, RAM, GPU/VRAM (if present), temps, disk, network throughput. Sparklines or ring gauges. Poll only while visible.
6. **Control center**: volume + output device, mic mute, brightness, Wi-Fi, Bluetooth, Do Not Disturb, power profile, battery (if present). Tile layout like macOS/iOS.
7. **Notifications**: freedesktop notification server implemented in Quickshell. Notifications pop out of the notch (icon, app, title, body, actions, urgency-aware), timeout pauses on hover, queue sensibly, keep a history list, honor Do Not Disturb.
8. **Theme switcher**: central `Theme` singleton, at least 4 themes (dark, light, two accent variants), live switch with smooth color transition, persisted across restarts. Optional matugen/wallust import if installed.

## Visual design

- Pure-black (theme-defined) pill, fully rounded, top center, small gap from the top edge (make FLOATING vs FLUSH a config option).
- Idle: small quiet pill with only essentials.
- Expanded: width, height, radius, and opacity animate together with a spring-like ease (subtle overshoot). Content fades/scales in after the shape settles. Collapse is equally smooth.
- One spacing scale, radii that scale with pill size, one icon style, tabular numerals for clock and stats.
- Interaction: hover/click expands, click outside or Esc collapses, everything is also reachable via keyboard and IPC.

## Architecture

```
shell.qml                 entry point; per-monitor via Variants / Quickshell.screens
config/                   Config.qml, Metrics.qml (sizes, durations, easing)
services/                 singletons: Theme, Audio, Media, Notifs, SystemStats, Network, Brightness, ...
components/               shared UI pieces (Pill, Tile, Slider, Icon, ...)
modules/                  one folder per feature (clock, calendar, launcher, media, stats, control, notifications, themes)
docs/                     README.md, progress notes
```

- One notch window owns the morphing shape and a state machine: `idle`, `clock`, `calendar`, `launcher`, `media`, `stats`, `control`, `notification`, with explicit allowed transitions.
- Services are singletons so the UI stays declarative. Feature modules never shell out directly.
- No hardcoded colors, sizes, or durations in feature files. Everything comes from `Theme` and `Metrics`.
- Views are behind `Loader { active: <state condition> }`. Timers and polling run only while their view is visible.
- Exclusive keyboard focus only while a text-input state (launcher) is open; release it on close.
- Expose an `IpcHandler` (e.g. `qs ipc call notch toggle launcher`) and/or Hyprland `GlobalShortcut`s.
- Degrade gracefully: missing tools, no players, no battery, no GPU, no Bluetooth/Wi-Fi hardware must never cause errors or blank UI.

## Quickshell rules (important)

- **Never guess at APIs.** Quickshell changes often. Before using any type, property, or signal, verify it against the docs (https://quickshell.org/docs) or the Quickshell source/examples. If a reference checkout is not available, clone the Quickshell repo somewhere outside this project (e.g. `~/src/quickshell`) and read from it.
- Likely relevant modules: `Quickshell` (`PanelWindow`, `Variants`), `Quickshell.Wayland`, `Quickshell.Hyprland`, `Quickshell.Io` (`Process`, `FileView`, `IpcHandler`), `Quickshell.Services.Mpris`, `Quickshell.Services.Notifications`, `Quickshell.Services.Pipewire`, `Quickshell.Services.UPower`, `DesktopEntries`.
- Where native support is thin, fall back to a CLI tool via `Process` (`playerctl`, `brightnessctl`, `nmcli`, `bluetoothctl`, `wpctl`, `hyprctl`) and say so in a comment.
- Animate with `Behavior`, `SpringAnimation`, or `NumberAnimation`. Avoid anything that forces large layout re-computation every frame.

## Dev loop

- The project lives at `~/.config/quickshell/notch/`, so run it with `qs -c notch`. Quickshell live-reloads on file save.
- Check `qs log -c notch` after every change. Fix all warnings and errors before moving on.
- To see the result, take a screenshot with `grim` (e.g. `grim -g "<region>" /tmp/notch.png`) and look at it. Compare against the design spec above. Do this for every state you change, not just idle.
- Use `qs ipc` calls to drive states from the terminal when testing.

## Ground rules

- **Ask before**: editing anything under `~/.config/hypr/`, killing or replacing the running bar or notification daemon, installing packages, or using `sudo`. Provide the config snippet or install command instead and let me apply it.
- Commit at the end of each milestone with a clear message. Keep commits small and working.
- Prefer editing existing files over creating new ones. No dead code, no duplicated logic, short comments only on non-obvious logic.
- If a requirement conflicts with what Quickshell can actually do, tell me plainly and propose the closest alternative rather than quietly working around it.
- Be direct and technical. Explain a decision only when there was a real tradeoff.

## Milestones

Work in this order, and stop for my review at the end of each one. Tick items off here as they're finished.

- [x] **M0: Recon and plan.** Detect the environment (Hyprland and Quickshell versions, monitors and scale, audio and network stack, GPU, existing notification daemon, installed CLI tools, available fonts). Write findings and the final plan to `docs/PLAN.md`.
- [ ] **M1: Foundation.** `shell.qml`, `Theme`, `Metrics`, the notch window, the morphing pill, the state machine. Clock only. Must run cleanly.
- [ ] **M2: Live data.** Media (MPRIS), notifications, control center.
- [ ] **M3: Tools.** Launcher, calendar, PC stats, theme switcher.
- [ ] **M4: Polish.** Animation tuning, edge cases, multi-monitor check, `docs/README.md` with Hyprland keybinds and layerrules (including the blur rule for the notch namespace), and a "known limitations" section.
