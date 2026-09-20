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

## Addendum 2: strip + notch + concave-fillet shape — **superseded, see Addendum 3**

~~A separate-colored full-width strip (`Theme.stripBackground`) with the notch connected to it by a small (radius ≈ strip height) concave fillet.~~ A second, cleaner reference image (`docs/reference/notch-reference.png`) showed almost no visible separate-colored strip and a much larger, gentler curve than this design had — the two reference images actively disagreed on strip prominence, and you confirmed the second one is correct: one solid color, no strip, a big slow curve. `Config.stripEnabled` and `Theme.stripBackground` were removed (dead code once the design changed) rather than left in disabled.

## Addendum 3: single-color notch, one large shared corner radius (current, verified)

The actual final shape, arrived at after the above two attempts didn't match:

- **One color throughout** (`Theme.pillBackground`, pure `#000000`) — no separate strip. `Config.floating` still exists (a plain gap + normal convex rounding, unverified visually since M1) but FLUSH is the default and the only mode built against the reference.
- **One shared `cornerRadius`** (`Metrics.cornerRadiusFor`, fully round at idle, capped at `Metrics.maxCornerRadius` = 48 — deliberately large, "a big slow curve" not a normal small corner radius) drives both the concave top corners and the convex bottom corners.
- **The concave top corners are drawn as explicit cubic Bézier curves (kappa ≈ 0.5523 quarter-circle approximation), not `PathArc`.** `PathArc`'s `direction`/`useLargeArc` flags were tried first and repeatedly gave the wrong (convex-looking, or in one case totally degenerate) result despite matching the on-paper SVG-arc-flag derivation — confirmed wrong by pixel-measuring the rendered output with ImageMagick each time, not by eye. Explicit control points removed the ambiguity. **The real bug wasn't the curve direction at all** — it was that the flat top line segment was inset by `cornerRadius` on both sides regardless of which curve followed it, which structurally forces y=0 to be the *narrow* point no matter what. A genuine concave flare needs the flat top segment to span the shape's *full* width at y=0, narrowing inward as y increases — a different path topology, not just different control points on the same one.
- **The shape needs extra width for the flare.** Since the flare extends *outward* past the notch's own stable width, `Pill`'s own `width` (`shapeWidth`) is `notchWidth + 2*cornerRadius` in FLUSH mode (0 extra in FLOATING mode) — matching your original instruction that "the window must be wider than the notch by the fillet radius on each side." Content is positioned within an inner `notchBounds` item inset by `cornerRadius` from each side, not centered in the full (wider) shape.
- Verified by pixel-sampling both reference images and the rendered result with ImageMagick + a small Python script at every step (not eyeballing), e.g. confirming the built expanded notch is 284px wide right at y=0, narrowing to a stable ~222px, before the bottom rounding takes over — the same wide-then-narrow profile as the reference.
