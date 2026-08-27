#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
DOTFILES_DIR=$(cd -- "$SCRIPT_DIR/../.." &>/dev/null && pwd)

echo "🔨 Compiling sidetone..."
mkdir -p "$DOTFILES_DIR/bin/.local/bin" "$HOME/.local/bin"
swiftc -O "$SCRIPT_DIR/sidetone.swift" -o "$DOTFILES_DIR/bin/.local/bin/sidetone"
chmod +x "$DOTFILES_DIR/bin/.local/bin/sidetone"

if [ ! "$DOTFILES_DIR/bin/.local/bin/sidetone" -ef "$HOME/.local/bin/sidetone" ]; then
    cp "$DOTFILES_DIR/bin/.local/bin/sidetone" "$HOME/.local/bin/sidetone"
fi

echo "⚙️ Setting up LaunchAgent..."
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$LAUNCH_AGENT_DIR/com.user.sidetone.plist"
mkdir -p "$LAUNCH_AGENT_DIR"

cat << EOF > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.sidetone</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.local/bin/sidetone</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/sidetone.err</string>
</dict>
</plist>
EOF

echo "🚀 Loading service..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo "✅ Sidetone service installed and running!"
