#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================"
echo " Setting up Daily Mole (mo clean) "
echo "========================================"

# 1. Check if 'mo' is installed
if ! command -v mo &> /dev/null; then
    echo "Error: 'mo' is not installed or not in PATH."
    echo "Please install mole first: https://github.com/tw93/mole"
    exit 1
fi

MO_PATH=$(which mo)
echo "Found 'mo' at: $MO_PATH"

# 2. Configure passwordless sudo for 'mo'
# We need to add a rule to /etc/sudoers.d/
SUDOERS_FILE="/etc/sudoers.d/daily-mole-clean"
echo "Configuring passwordless sudo for 'mo'..."
echo "You may be prompted for your password now to set this up."

# Safely write the sudoers rule
echo "$USER ALL=(ALL) NOPASSWD: $MO_PATH" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE"
# Validate the sudoers file
sudo visudo -c -f "$SUDOERS_FILE" > /dev/null
echo "Passwordless sudo configured successfully."

# 3. Create the LaunchAgent Plist for daily execution
PLIST_LABEL="com.daily.mole.clean"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$PLIST_DIR/$PLIST_LABEL.plist"

echo "Creating LaunchAgent at $PLIST_PATH..."

mkdir -p "$PLIST_DIR"

cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/sudo</string>
        <string>$MO_PATH</string>
        <string>clean</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/daily-mole-clean.log</string>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/daily-mole-clean.log</string>
</dict>
</plist>
EOF

# 4. Load the LaunchAgent
echo "Loading LaunchAgent..."
# Unload it first if it already exists, so we can reload it cleanly
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "========================================"
echo " Setup complete! "
echo " 'sudo mo clean' will now run automatically every day at 12:00 PM."
echo " Logs can be found at: $HOME/Library/Logs/daily-mole-clean.log"
echo "========================================"
