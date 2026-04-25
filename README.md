# Daily Mole Cleaner

An automated script to run `sudo mo clean` every day on your Mac to keep it clean, without ever prompting for your password.

## Prerequisites

You must have [`mole`](https://github.com/tw93/mole) installed on your system. 

## Installation

1. Clone this repository or download the `setup.sh` script.
2. Open your terminal and navigate to the folder containing the script.
3. Make the script executable (if it isn't already):
   ```bash
   chmod +x setup.sh
   ```
4. Run the setup script:
   ```bash
   ./setup.sh
   ```

*Note: The script will ask for your Mac password once during setup to configure the passwordless sudo permissions for the `mo` executable.*

## How it works

The `setup.sh` script automates two main things:
1. **Passwordless Sudo**: It adds a secure rule to `/etc/sudoers.d/` allowing your specific user to execute `mo` with `sudo` privileges without having to type a password.
2. **macOS LaunchAgent**: It creates a launchd plist file (`com.daily.mole.clean.plist`) that schedules `sudo mo clean` to run automatically every day at 12:00 PM. The script is also triggered immediately on load.

## Logs

You can check the execution logs at any time to verify the daily cleaning is working properly:

```bash
cat ~/Library/Logs/daily-mole-clean.log
```

## Uninstallation

If you ever want to remove this automation, you can manually run the following commands in your terminal:

```bash
# 1. Unload and remove the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.daily.mole.clean.plist
rm ~/Library/LaunchAgents/com.daily.mole.clean.plist

# 2. Remove the passwordless sudoers rule
sudo rm /etc/sudoers.d/daily-mole-clean

# 3. Remove the log file
rm ~/Library/Logs/daily-mole-clean.log
```
