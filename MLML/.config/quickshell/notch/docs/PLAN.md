# Notch — M0 Recon and Plan

Status: M0 complete. M1 built and since revised twice based on visual/interaction review; see the addendum at the bottom of this file for what changed from the plan below.

## 1. Detected environment

| Area | Finding |
|---|---|
| Compositor | Hyprland 0.56.2 |
| Shell runtime | Quickshell 0.3.1 (Nixpkgs build, `qs` at `/etc/profiles/per-user/excalibur/bin/qs`) |
| Monitors | `eDP-1` 1920x1080@60 (laptop panel, scale 1) and `HDMI-A-1` 1920x1080@240 (external, scale 1, currently focused). Both report `reserved: 0 50 0 0` — something already reserves a 50px strip at the top of every monitor (see Notification daemon row). No HiDPI/scale handling needed. |
| Audio | PipeWire stack: `pipewire`, `pipewire-pulse`, `wireplumber` all active. No `pactl`/`pamixer` binary; `wpctl` present. Native `Quickshell.Services.Pipewire` covers this — no CLI fallback needed. |
| Network | NetworkManager active, `nmcli` 1.58.0 present, no `iwd`. Native `Quickshell.Networking` module exists in 0.3.1 — use it instead of shelling out to `nmcli`. |
| GPU | Hybrid: NVIDIA RTX 4070 Max-Q (dGPU) + AMD Raphael (iGPU, likely driving the compositor). No `nvidia-smi`/`radeontop`/`intel_gpu_top` installed — GPU/VRAM stat has no read path yet on either GPU. |
| Bluetooth | `bluetooth.service` active, `bluetoothctl` present. Native `Quickshell.Bluetooth` module exists in 0.3.1 — use it instead of shelling out. |
| Battery/power | `upower` present: one battery (`BAT0`) + AC adapter (`ADP0`). This is a laptop — battery tile is a live feature. `PowerProfiles` in `Quickshell.Services.UPower` covers the power-profile tile. |
| Notification daemon | **`swaync` is currently running.** Notch's own `NotificationServer` will need to own the `org.freedesktop.Notifications` DBus name, which conflicts with swaync running at the same time. **Needs explicit sign-off before M2** to stop/disable swaync — not done in M0. (Corrected in M1: `hyprctl layers` shows the 50px top reservation on both monitors actually belongs to the existing `vortex` Quickshell bar (namespace `quickshell`, a 1890×35 top-strip layer), not swaync — swaync itself reserves no panel space.) |
| Fonts | JetBrainsMono Nerd Font installed (regular/mono/propo, all weights) — covers icon glyphs and tabular-friendly monospace numerals. Noto Sans Symbols as fallback. |
| CLI tools (from CLAUDE.md's list) | Installed: `nmcli`, `bluetoothctl`, `wpctl`, `hyprctl`. **Missing**: `playerctl`, `brightnessctl`, `khal`, `matugen`, `wallust`, `grim`. |

Most of the missing CLI tools are moot because native Quickshell modules cover Mpris, Bluetooth, and Networking. The real gaps:
- **`brightnessctl`** — no native Quickshell brightness API exists in 0.3.1; still required for the Control Center brightness slider.
- **`grim`** — required for the screenshot-based visual QA step CLAUDE.md's own dev loop prescribes.
- **`khal`** — only needed if the optional calendar event-list feature is wanted.
- **`matugen`/`wallust`** — only needed for the optional theme-import feature.

## 2. Quickshell reference

Cloned locally at `~/src/quickshell`, checked out at tag `v0.3.1` (commit `1a4716c`) to exactly match the installed `qs` binary. Docs cross-checked at `https://quickshell.org/docs/v0.3.1/`. Confirmed module/type surface to use for each feature:

| Feature | Module | Confirmed types / members |
|---|---|---|
| Notch window, per-monitor | `Quickshell` (core) | `PanelWindow` (`anchors`, `exclusiveZone`, `margins`, `aboveWindows`) + `Variants` for per-screen instances. `WlrLayershell.namespace` (parent of `PanelWindow`) is the property to set for a compositor blur-per-namespace layer rule. |
| Media (MPRIS) | `Quickshell.Services.Mpris` | `Mpris.players` — `ObjectModel` of `MprisPlayer`; `MprisPlaybackState`, `MprisLoopState` enums. Exact `MprisPlayer` member names (title/artist/artUrl/position/length, `play()`/`pause()`/`next()`/`previous()`/seek) to be pinned down by reading `src/services/mpris/*` in the local checkout before M2 implementation — the entry point is confirmed. |
| Notifications | `Quickshell.Services.Notifications` | `NotificationServer` (capability flags: `bodySupported`, `actionsSupported`, `imageSupported`, `bodyMarkupSupported`, `inlineReplySupported`, `actionIconsSupported`, `bodyHyperlinksSupported`, `bodyImagesSupported`, `persistenceSupported`; `notification(Notification)` signal — must set `notification.tracked = true` to retain it); `Notification` (`summary`, `body`, `urgency` via `NotificationUrgency`, `actions`, image/icon, `timeout`, `keepOnReload`); `NotificationCloseReason`. |
| Volume / audio | `Quickshell.Services.Pipewire` | `Pipewire.defaultAudioSink`/`defaultAudioSource` (`PwNode`, read-only, may transiently be null), `preferredDefaultAudioSink`/`Source` (settable hint), `Pipewire.nodes` (filter by `isStream`/`isSink`/`audio != null`), `Pipewire.ready`. Volume/mute live on `PwNodeAudio`: `node.audio.volume: real` (writable, proportional across channels), `node.audio.volumes: list<real>` (per-channel), `node.audio.muted: bool` (writable). **Gotcha**: `node.audio` is only valid once the node is bound via `PwObjectTracker { objects: [node] }` — every volume/mute control widget needs that wrapper. |
| Battery / power profile | `Quickshell.Services.UPower` | `UPower.displayDevice` (check `UPower.ready` first), `UPower.devices`, `UPower.onBattery`; `PowerProfiles` singleton + `PowerProfile` enum. |
| Bluetooth | `Quickshell.Bluetooth` | `Bluetooth`, `BluetoothAdapter`, `BluetoothDevice` + state enums. |
| Network | `Quickshell.Networking` | `Network`, `NetworkDevice`, `WifiDevice`, `WifiNetwork`, `NMSettings`. |
| App launcher | `Quickshell` (core) | `DesktopEntries.applications` (already excludes Hidden/NoDisplay), `DesktopEntries.byId()` / `heuristicLookup()`; `DesktopEntry.name`/`icon`/`exec`/`execute()`. |
| Icons | `Quickshell.Widgets` | `IconImage`. |
| IPC | `Quickshell.Io` | `IpcHandler { target: "notch"; function toggleLauncher(): void {...} }`, driven by `qs ipc call notch toggleLauncher`. Max 10 args; types limited to `string`/`int`/`bool`/`real`/`color`/`void`. |
| Hyprland global shortcuts | `Quickshell.Hyprland` | `GlobalShortcut { name; description }`, `pressed()`/`released()` signals; bound in `hyprland.conf` via `bind = <mods>, <key>, global, quickshell:<name>` (Hyprland-native protocol, no xdg-portal). |

**Native vs. fallback matrix**: Mpris, Notifications, Pipewire, UPower, Bluetooth, Networking, DesktopEntries, IPC, and GlobalShortcuts are all natively covered by Quickshell 0.3.1 — no CLI shell-out needed for any of them. This is broader native coverage than CLAUDE.md anticipated (it suggested `nmcli`/`bluetoothctl` fallbacks, which turn out to be unnecessary at this Quickshell version). The only feature with **no native API** is:
- **Brightness** — falls back to `brightnessctl` via `Process`, exactly as CLAUDE.md anticipated.

Before writing MPRIS/Pipewire control code in M2, the exact `MprisPlayer` and `PwNode`/`PwNodeAudio` member list will be re-verified by reading the QML type registrations directly in `~/src/quickshell` rather than relying on doc prose (which was incomplete on some overview pages).

## 3. Design reference

Visual/interaction model: **DynamicLake** (the macOS Dynamic Island app) — idle mini-pill, feature-state morphing, music controls, glanceable calendar/notification content, hover/click-driven expansion. This lines up with CLAUDE.md's existing feature list and morph behavior, so no scope change.

Material: DynamicLake also ships translucent "Liquid Glass"/"Frosted Glass" skins, but the pill stays **pure black and opaque**, per CLAUDE.md's original spec and confirmed explicitly during M0 — no blur/translucency on the pill body itself. (A layer-shell blur *rule* may still be documented in M4 for the notch namespace's edges/corners, but it does not make the fill translucent.)

## 4. Directory tree

Per CLAUDE.md's Architecture section (this takes precedence over the more generic `modules/widgets/services/themes/components` split used in other Quickshell configs for this user — this project's own CLAUDE.md already specifies a different, more service-heavy layout):

```
shell.qml                 entry point; PanelWindow + Variants over Quickshell.screens
config/
  Config.qml              user-tunable options (FLOATING vs FLUSH, feature toggles)
  Metrics.qml             sizes, radii, spacing scale, durations, easing curves
services/
  Theme.qml               color tokens, live switch, persistence
  Audio.qml               Pipewire wrapper (PwObjectTracker bindings for volume/mute)
  Media.qml               Mpris wrapper, active-player selection across multiple players
  Notifs.qml              NotificationServer wrapper + history
  SystemStats.qml         CPU/RAM/GPU/temp/disk/net polling, active only while stats view visible
  Network.qml             Quickshell.Networking wrapper
  Brightness.qml          brightnessctl-backed (no native API)
  Bluetooth.qml           Quickshell.Bluetooth wrapper
  Battery.qml             UPower wrapper
components/               Pill, Tile, Slider, Icon, ... (shared, presentation-only)
modules/
  clock/
  calendar/
  launcher/
  media/
  stats/
  control/
  notifications/
  themes/
docs/
  PLAN.md                 this file
  README.md               added in M4: keybinds, layer rules, known limitations
```

## 5. State machine

- States: `idle`, `clock`, `calendar`, `launcher`, `media`, `stats`, `control`, `notification`.
- `idle` is the resting state; every other state is reachable from `idle` and returns to `idle` on collapse (click-outside, Esc, or timeout).
- `notification` is special: a new toast can interrupt any other state and, on dismissal, returns to whichever state was active before it (or `idle`).
- No direct transitions between two non-idle, non-notification states (e.g. `calendar` → `media` always passes through `idle`) — keeps the morph animation and each state's `Loader { active }` lifecycle simple and avoids compound transition logic.

## 6. Singleton ownership

- **Theme** — color tokens for all themes, live switching, persistence across restarts.
- **Config / Metrics** — sizes, radii, spacing scale, durations, easing curves, the FLOATING/FLUSH toggle. No feature file hardcodes a color, size, or duration.
- **Audio** — Pipewire wrapper; owns `PwObjectTracker` bindings so volume/mute controls work.
- **Media** — Mpris wrapper; picks the active player when multiple exist.
- **Notifs** — NotificationServer wrapper; owns the notification queue, history, and Do Not Disturb state.
- **SystemStats** — CPU/RAM/GPU/temp/disk/network polling; polling only runs while the `stats` view is visible.
- **Network** — Quickshell.Networking wrapper (Wi-Fi state, connectivity).
- **Brightness** — `brightnessctl`-backed `Process` wrapper (no native module exists).
- **Bluetooth** — Quickshell.Bluetooth wrapper (adapter/device state).
- **Battery** — UPower wrapper (`displayDevice`, `onBattery`, `PowerProfiles`).

## 7. External dependencies still to install

Not blocking M0; needed before the milestone noted:

| Tool | Needed for | Milestone |
|---|---|---|
| `grim` | Screenshot-based visual QA (CLAUDE.md's own dev loop) | Needed immediately for M1 onward |
| `brightnessctl` | Control Center brightness slider | M2 |
| `khal` (optional) | Calendar event list | M3 |
| `matugen` / `wallust` (optional) | Theme import from wallpaper | M3 |

Per CLAUDE.md's ground rules, installing packages requires your sign-off — install command to be provided when each is actually needed, matching however you manage packages on this NixOS system (declarative `environment.systemPackages` vs. `nix-env`/`home-manager` — to confirm at that point).

## 8. Action items requiring sign-off before later milestones

Flagged now, **not acted on** in M0:

1. **swaync** must be stopped/disabled before Notch's `NotificationServer` can own the DBus notification name — will ask again at the start of M2.
2. ~~The 50px top reservation on both monitors needs to be understood before M1 decides Notch's own anchoring/margins~~ — resolved in M1: it's the `vortex` bar's own exclusive zone, unrelated to Notch. Notch's window doesn't reserve any space (`ExclusionMode.Ignore`), so the two coexist without conflict.
3. Installing `brightnessctl` and `grim` needs explicit approval before M1/M2, per "ask before installing packages."

## 9. Known unknowns to resolve at implementation time (not blocking, not guesses)

- Exact `MprisPlayer` property/method names — read from `~/src/quickshell` source before M2 media work.
- Exact `PwNode`/`PwNodeAudio` full property list beyond `volume`/`volumes`/`muted` (e.g. anything needed for per-device UI beyond basic volume/mute) — read from source before M2 control-center work.

## Addendum: changes made after visual/interaction review of M1

Based on feedback after seeing M1 running, three things changed from the original plan above:

1. **Window anchoring and space reservation.** The original full-screen (`anchors: top+left+right+bottom`) click-catcher design is gone. The window is now anchored `top+left+right` only, with a fixed `implicitHeight` (`Metrics.windowHeight`, generous enough for any expanded view) and a real `exclusiveZone` (`Metrics.reservedHeight`, sized to the idle pill) via `ExclusionMode.Normal`. This makes Hyprland push other windows down below the notch instead of letting it render on top of them — the original design deliberately avoided reserving space, but that meant the notch could sit on top of window content (e.g. a terminal with no top gap of its own).
2. **Interaction model.** Hover no longer expands the pill; only a click does. Moving the mouse off the pill collapses it (`MouseArea.onExited`). The old "click outside the whole screen, or Esc, collapses" model is gone along with the full-screen catcher it depended on; Esc is kept as a keyboard fallback while expanded (the pill itself takes focus via `WlrKeyboardFocus.OnDemand` while non-idle).
3. **Pill shape.** ~~The pill is a `QtQuick.Shapes` outline with concave top corners at the pill's own outer edge.~~ **Superseded — see the next addendum.** `QtQuick.Shapes` itself (and building a compound outline out of `PathLine`/`PathArc`) is confirmed available and correct in this Quickshell 0.3.1 / Nix install; only the specific corner geometry described here was wrong and was replaced.

## Addendum 2: strip + notch + concave-fillet shape (matches `docs/reference/notch-reference.png`)

You provided an exact reference image (saved at `docs/reference/notch-reference.png`) and precise measurements were taken from it (pixel-sampled with ImageMagick) rather than eyeballed. The corrected shape:

- **Two visually distinct pieces, not one uniformly-colored outline.** A slim full-width `Rectangle` (`Theme.stripBackground`, `#171717`, height `Metrics.stripHeight` = 10px) sits flush at the very top. The notch itself (`Theme.pillBackground`, pure `#000000`) is drawn as a separate `QtQuick.Shapes` `Shape`/`ShapePath`, centered under the strip, content-driven width/height exactly as before (M1's `implicitWidth`/`implicitHeight` logic, renamed `notchWidth`/`notchBodyHeight` since `width`/`height` on the root item now mean the *whole strip's* width, not just the notch's).
- **Concave fillets connect them.** Measuring the reference: at the row right where the strip ends, the notch is at its *widest* (flared out, matching the strip's edge); as you move down, it narrows via a concave `PathArc` (radius = `Metrics.stripHeight`, "roughly equal to the strip's height" per your instruction) to its stable width, after which the sides are straight and vertical — confirmed by sampling the built result too (idle: 113px wide at the strip seam narrowing down; expanded: 261px narrowing to a stable 241px, then narrowing again at the bottom for the rounded corners). The fillet radius is a fixed constant, not derived from the notch's current width/height, so it doesn't change as the body resizes.
- **Bottom stays MacBook-notch style**: convex `PathArc`s, `Metrics.cornerRadiusFor()` (capped, fully round at idle, capped smaller when expanded) — unchanged from M1.
- **Window/mask**: `Pill` now anchors `left+right` to the window (full width, for the strip) instead of being content-sized and centered. The click mask is a `Region` union (nested `Region { ... intersection: Intersection.Combine }`, confirmed against `region.hpp`) of the strip's rect and the notch's own (rounded) rect, so the transparent space beside the notch — which is otherwise inside the `Pill` item's own bounding box now that it spans the full width — still passes clicks through.
- **Config**: `Config.stripEnabled` (default `true`) makes the strip optional, drawn by this shell itself rather than an existing external bar (there wasn't one running to integrate with, and CLAUDE.md's architecture doesn't call for depending on one). FLOATING mode still exists as a simpler fallback (no strip, no fillets, fillet radius degenerates to 0 which naturally yields plain sharp top corners on the flat-top notch) — it wasn't the focus of this round and hasn't been re-verified visually since M1's first pass, only reasoned through.
