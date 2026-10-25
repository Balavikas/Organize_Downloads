#!/bin/bash
# Installs organize_downloads.sh as a background job that runs whenever
# ~/Downloads changes (plus once a minute as a safety net).
set -e

LABEL="com.user.organize-downloads"
SCRIPT_DIR="$HOME/Scripts"
SCRIPT="$SCRIPT_DIR/organize_downloads.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
SRC="$(cd "$(dirname "$0")" && pwd)/organize_downloads.sh"

mkdir -p "$SCRIPT_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cp "$SRC" "$SCRIPT"
chmod +x "$SCRIPT"
xattr -d com.apple.quarantine "$SCRIPT" 2>/dev/null || true

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SCRIPT</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>$HOME/Downloads</string>
  </array>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>ThrottleInterval</key>
  <integer>5</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/organize-downloads.err</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Installed. Downloads will now be organized automatically."
echo "Activity log: ~/Library/Logs/organize-downloads.log"
