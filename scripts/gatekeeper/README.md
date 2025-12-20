# Gatekeeper 🛡️

Gatekeeper is a lightweight, native macOS security tripwire. It monitors your
Mac for wake and unlock events and sends real-time alerts to a Healthchecks.io
instance.

It is designed to detect both physical access and remote VNC access by listening
to system-level notifications.

## Features

- **Instant Tripwire**: Sends an immediate /fail signal to Healthchecks.io upon
  wake or screen unlock.
- **Diagnostic Logging**: Captures the local IP address and the active user at
  the time of the event.
- **Dead Man's Switch**: Sends a heartbeat every 5 minutes. If the Mac is
  stolen, powered off, or disconnected from the internet, you will receive an
  "offline" alert.
- **Auto-Arming**: Automatically resets the alert to "Green" status 10 seconds
  after a tripwire event.
- **Zero Dependencies**: A single Swift binary using native macOS APIs
  (NSWorkspace).

## Project Structure

- `gatekeeper.swift`: The Swift source code for the background daemon.
- `gatekeeper`: The compiled binary (executable).
- `com.yourname.gatekeeper.plist`: The macOS LaunchAgent configuration.

## Installation

### Configure Healthchecks.io

1. Create a new Check.
1. Set Period to 5 minutes.
1. Set Grace to 1 minute.
1. Copy your UUID for the steps below.

### Prepare the Script

Update the `hcUUID` variable in `gatekeeper.swift` with your UUID.

### Compile the Binary

Run the following command in your terminal:

```bash
swiftc gatekeeper.swift -o gatekeeper
```

### Setup the LaunchAgent

    Copy your .plist file to the macOS LaunchAgents directory:

```bash
cp com.yourname.gatekeeper.plist ~/Library/LaunchAgents/
```

Note: Ensure the ProgramArguments path in the plist points to the exact location
of your compiled gatekeeper binary.

### Start the Service

```bash
launchctl load ~/Library/LaunchAgents/com.yourname.gatekeeper.plist
```

## Alert Logic

| Status        | Meaning                           | Action                                                                |
| ------------- | --------------------------------- | --------------------------------------------------------------------- |
| Green         | System is healthy and monitoring. | None.                                                                 |
| Red (Instant) | Tripwire Triggered!               | Someone has woken or unlocked the Mac.                                |
| Red (Delayed) | System Offline.                   | The 5-minute heartbeat was missed. Mac is likely off or disconnected. |

## Diagnostic Data

When an alert fires, check the Events log in your Healthchecks dashboard. You
will see a payload similar to:
`TRIPWIRE: Unlock | User: john | IP: 192.168.1.42`

## Maintenance & Debugging

To view if the process is running: Bash

```bash
ps aux | grep gatekeeper
```

To stop the monitor: Bash

```bash
launchctl unload ~/Library/LaunchAgents/com.yourname.gatekeeper.plist
```

To view logs (if configured): Standard output and errors are typically discarded
to /dev/null for stealth, but can be redirected to /tmp/gatekeeper.out for
debugging.
