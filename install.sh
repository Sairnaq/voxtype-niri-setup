#!/usr/bin/env bash
set -e

echo "🎙️ Installing Voxtype Push-to-Talk Voice Dictation for CachyOS / Niri / Noctalia..."

# 1. Install dependencies via pacman / paru / yay
if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
else
    AUR_HELPER="sudo pacman"
fi

echo "📦 Installing Voxtype and required Wayland tools..."
$AUR_HELPER -S --needed --noconfirm voxtype-bin quickshell wtype wl-clipboard libnotify pipewire pipewire-alsa

# 2. Automatically download the base.en model if not already present
echo "📥 Ensuring Whisper base.en model is downloaded and ready..."
mkdir -p "$HOME/.local/share/voxtype/models"
if [ ! -f "$HOME/.local/share/voxtype/models/ggml-base.en.bin" ]; then
    echo "Downloading ggml-base.en.bin (142MB)..."
    curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" -o "$HOME/.local/share/voxtype/models/ggml-base.en.bin"
fi

# 3. Setup user binary directory
mkdir -p "$HOME/.local/bin"
cp -f "$(dirname "$0")/voxtype-hold" "$HOME/.local/bin/voxtype-hold"
chmod +x "$HOME/.local/bin/voxtype-hold"

# 4. Setup configuration and custom Quickshell capsule OSD
mkdir -p "$HOME/.config/voxtype/quickshell"
cp -f "$(dirname "$0")/config.toml" "$HOME/.config/voxtype/config.toml"
cp -rf "$(dirname "$0")/quickshell/"* "$HOME/.config/voxtype/quickshell/"

# 5. Install and enable systemd user service
mkdir -p "$HOME/.config/systemd/user"
cp -f "$(dirname "$0")/voxtype.service" "$HOME/.config/systemd/user/voxtype.service"


systemctl --user daemon-reload
systemctl --user enable --now voxtype.service

echo ""
echo "✅ Voxtype installed and running successfully!"
echo ""
echo "👉 Add this keybinding to your ~/.config/niri/config.kdl:"
echo ""
echo 'binds {'
echo '    // Push-to-talk voice dictation on HOME key (350ms deliberate hold)'
echo '    Home { spawn "voxtype-hold" "press"; }'
echo '    Home cooldown-ms=0 { spawn "voxtype-hold" "release"; }'
echo '}'
echo ""
