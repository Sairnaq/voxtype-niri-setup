#!/usr/bin/env bash
set -e

echo "🎙️ Installing Voxtype Push-to-Talk Voice Dictation with Universal Theme & WM Integration..."

# 1. Detect Package Manager & Install Dependencies
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
else
    AUR_HELPER="sudo pacman"
fi

echo "📦 Installing Voxtype and required Wayland tools..."
$AUR_HELPER -S --needed --noconfirm voxtype-bin quickshell wtype wl-clipboard libnotify pipewire pipewire-alsa

# 2. Automatically download the Whisper model if missing
echo "📥 Ensuring Whisper base.en model is present..."
mkdir -p "$HOME/.local/share/voxtype/models"
if [ ! -f "$HOME/.local/share/voxtype/models/ggml-base.en.bin" ]; then
    echo "Downloading ggml-base.en.bin (142MB)..."
    curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" -o "$HOME/.local/share/voxtype/models/ggml-base.en.bin"
fi

# 3. Install Hold Controller into ~/.local/bin
mkdir -p "$HOME/.local/bin"
cp -f "$(dirname "$0")/voxtype-hold" "$HOME/.local/bin/voxtype-hold"
chmod +x "$HOME/.local/bin/voxtype-hold"

# Ensure ~/.local/bin is in PATH for future shells
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 4. Install Voxtype Configuration & Custom Frosted Capsule QML OSD
mkdir -p "$HOME/.config/voxtype/quickshell"
cp -f "$(dirname "$0")/config.toml" "$HOME/.config/voxtype/config.toml"
cp -rf "$(dirname "$0")/quickshell/"* "$HOME/.config/voxtype/quickshell/"

# 5. Install & Enable Systemd User Service
mkdir -p "$HOME/.config/systemd/user"
cp -f "$(dirname "$0")/voxtype.service" "$HOME/.config/systemd/user/voxtype.service"

systemctl --user daemon-reload
systemctl --user enable --now voxtype.service

echo ""
echo "⚙️ Detecting Compositor & Automatically Applying Keybindings & Blur..."

# 6. Automatic Window Manager / Compositor Configuration
CONFIGURED_WM=""

# A. NIRI AUTO-DETECTION
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
if [ -f "$NIRI_CONFIG" ]; then
    if ! grep -q "voxtype-hold" "$NIRI_CONFIG"; then
        echo "🔹 Detected Niri! Adding push-to-talk keybinding to ~/.config/niri/config.kdl..."
        cp "$NIRI_CONFIG" "${NIRI_CONFIG}.bak.$(date +%s)"
        cat << 'EOF' >> "$NIRI_CONFIG"

// Voxtype Push-to-Talk Voice Dictation (Home key with 350ms hold delay)
binds {
    Home { spawn "voxtype-hold" "press"; }
    Home cooldown-ms=0 { spawn "voxtype-hold" "release"; }
}
EOF
        CONFIGURED_WM="Niri"
    else
        echo "🔹 Niri: Voxtype keybinding already present in config.kdl."
        CONFIGURED_WM="Niri"
    fi
fi

# B. HYPRLAND AUTO-DETECTION
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_WIN="$HOME/.config/hypr/windows.lua"
if [ -d "$HOME/.config/hypr" ]; then
    # Add blur rule
    if [ -f "$HYPR_WIN" ] && ! grep -q "voxtype-osd" "$HYPR_WIN"; then
        echo "🔹 Detected Omarchy Hyprland! Adding blur rule to windows.lua..."
        echo 'hl.layer_rule({ match = { namespace = "voxtype-osd" }, blur = true, ignore_alpha = 0.2 })' >> "$HYPR_WIN"
    elif [ -f "$HYPR_CONF" ] && ! grep -q "voxtype-osd" "$HYPR_CONF"; then
        echo "🔹 Detected Hyprland! Adding blur layerrule to hyprland.conf..."
        cat << 'EOF' >> "$HYPR_CONF"

# Voxtype Frosted Glass Blur Rule
layerrule = blur, voxtype-osd
layerrule = ignorealpha 0.2, voxtype-osd
EOF
    fi

    # Add keybind
    if [ -f "$HOME/.config/hypr/bindings.lua" ] && ! grep -q "voxtype-hold" "$HOME/.config/hypr/bindings.lua"; then
        echo "🔹 Adding Home key push-to-talk binding to ~/.config/hypr/bindings.lua..."
        cat << 'EOF' >> "$HOME/.config/hypr/bindings.lua"

-- Voxtype Voice Dictation (Home key with 350ms deliberate hold)
hl.unbind("F9")
hl.unbind("SUPER + CTRL + X")
o.bind("HOME", "Start voice dictation (hold threshold)", "voxtype-hold press")
o.bind("HOME", "Stop voice dictation (hold threshold)", "voxtype-hold release", { release = true })
EOF
        CONFIGURED_WM="Hyprland"
    elif [ -f "$HYPR_CONF" ] && ! grep -q "voxtype-hold" "$HYPR_CONF"; then
        echo "🔹 Adding Home key push-to-talk binding to ~/.config/hypr/hyprland.conf..."
        cat << 'EOF' >> "$HYPR_CONF"

# Voxtype Voice Dictation (Home key push-to-talk)
bind = , Home, exec, voxtype-hold press
bindr = , Home, exec, voxtype-hold release
EOF
        CONFIGURED_WM="Hyprland"
    fi
fi

# C. SWAY AUTO-DETECTION
SWAY_CONF="$HOME/.config/sway/config"
if [ -f "$SWAY_CONF" ] && ! grep -q "voxtype-hold" "$SWAY_CONF"; then
    echo "🔹 Detected Sway! Adding push-to-talk binding to ~/.config/sway/config..."
    cat << 'EOF' >> "$SWAY_CONF"

# Voxtype Voice Dictation (Home key push-to-talk)
bindsym --no-repeat Home exec voxtype-hold press
bindsym --release Home exec voxtype-hold release
EOF
    CONFIGURED_WM="Sway"
fi

echo ""
echo "================================================================="
echo "🎉 INSTALLATION COMPLETE & READY TO USE!"
echo "================================================================="
echo "🎙️ Voice Engine : OpenAI Whisper (ggml-base.en.bin)"
echo "💊 OSD Style    : Rounded Frosted Capsule with Dynamic Palette"
echo "⏱️ Activation   : Hold HOME for ~350ms to talk -> release to paste"
if [ -n "$CONFIGURED_WM" ]; then
    echo "⚡ Compositor   : Automatically configured for $CONFIGURED_WM"
fi
echo "================================================================="
echo ""
