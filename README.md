# 🎙️ Voxtype Voice-to-Text Setup for CachyOS, Niri & Noctalia

A complete, battle-tested setup guide and 1-click automated installer for **Voxtype** push-to-talk voice-to-text dictation on **CachyOS**, **Arch Linux**, **Niri**, **Noctalia**, and **Hyprland**.

Transcribe your speech **100% offline and locally** with zero cloud latency using OpenAI Whisper, typing directly into any focused window with a sleek, rounded Quickshell OSD capsule!

---

## ✨ Features

* 🚀 **100% Offline & Private:** Powered locally by OpenAI Whisper (`base.en` / `small.en` / `medium.en`). Zero telemetry, zero cloud dependencies.
* 💊 **Rounded Quickshell Capsule OSD:** Replaces the clunky default box popup with a modern, smooth, frosted capsule pill with live waveform meters and instant snap-away dismissal.
* ⏱️ **Deliberate Hold Threshold (~350ms):** Tapping the `Home` key won't accidentally trigger recording; holding it down initiates recording, and letting go instantly pastes your speech.
* 🔇 **Silent & Clean:** Annoying beeps and feedback noises muted out-of-the-box.
* 🎯 **Dynamic Theme Colors:** Automatically synchronizes its frosted glass tint and wave colors with your active desktop theme.

---

## 🚀 Quick 1-Click Install

### Option A: Clone & Run
```bash
git clone https://github.com/Sairnaq/voxtype-niri-setup.git
cd voxtype-niri-setup
./install.sh
```

---

### Option B: Using Claude Code / Claude CLI (Zero Effort)
If your friend uses **Claude CLI** (`claude`), they can literally copy-paste this one prompt into Claude:

```text
Please install and set up voxtype from https://github.com/Sairnaq/voxtype-niri-setup.git, run the install.sh script, and add the Home key push-to-talk binding to my ~/.config/niri/config.kdl.
```
*Claude CLI will clone it, install all dependencies, enable the systemd service, and add the keybindings to Niri automatically!*

---


## ⌨️ Compositor Keybindings

### 1. In Niri (`~/.config/niri/config.kdl`):

Add the following to your `binds` block:

```kdl
binds {
    // Push-to-Talk voice dictation on HOME key (with 350ms hold threshold)
    Home { spawn "voxtype-hold" "press"; }
    Home cooldown-ms=0 { spawn "voxtype-hold" "release"; }
}
```

---

### 2. In Hyprland (`~/.config/hypr/hyprland.conf` or `bindings.lua`):

```ini
# Push-to-Talk voice dictation on HOME key
bind = , Home, exec, voxtype-hold press
bindr = , Home, exec, voxtype-hold release
```

---

### 3. In Sway (`~/.config/sway/config`):

```ini
# Push-to-Talk voice dictation on HOME key
bindsym --no-repeat Home exec voxtype-hold press
bindsym --release Home exec voxtype-hold release
```

---

## 🎙️ How to Use

1. Click inside any text box (browser, Discord, terminal, Obsidian, code editor, etc.).
2. **Hold the `Home` key** for a brief moment (~350ms).
3. The rounded pill visualizer appears at the bottom of the screen.
4. Speak naturally.
5. **Release the `Home` key** — the pill snaps away and your transcribed words are typed right at your cursor!

---

## 🛠️ Management & Commands

```bash
# Check current daemon state (idle / recording / transcribing)
voxtype status

# Open the interactive TUI configuration menu (change models, audio devices, etc.)
voxtype configure

# Restart background service after audio device changes
systemctl --user restart voxtype.service

# View live daemon logs
journalctl --user -u voxtype.service -f
```

---

## 📦 Dependencies

* `voxtype-bin` (Core daemon & Whisper engine)
* `quickshell` (Wayland layer-shell HUD OSD)
* `wtype` (Wayland simulated keystroke injector)
* `pipewire` & `pipewire-alsa` (Audio backend)
* `wl-clipboard` (Clipboard fallback)

---

## 📄 License
MIT License. Free to use, modify, and share!
