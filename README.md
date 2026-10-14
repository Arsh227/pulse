# Pulse

A tiny macOS menu-bar utility: focus/break timer, screen-edge flash and
notification when a session ends, and a floating scratch note toggled by a
global hotkey (⌃⌥P).

## Build & run
```bash
./bundle.sh && open Pulse.app
```
Durations are configurable under **Settings…** in the menu (⌘,).

Toggle **Launch at Login** from the menu (move Pulse.app to /Applications first).

Requires macOS 13+ and Xcode command-line tools (Swift 5.9+).

## Layout
| File | Role |
|---|---|
| `TimerStore.swift` | Countdown state machine |
| `FlashController.swift` | Full-screen border flash |
| `NoteOverlay.swift` | Floating, persisted note panel |
| `HotkeyManager.swift` | Carbon global hotkey (no permissions needed) |
| `SettingsWindow.swift` | Focus/break duration preferences |
| `AppDelegate.swift` | Status item, menu, wiring |

## Ideas
Configurable durations, custom hotkey recorder, launch at login
(`SMAppService`), Sparkle updates.
