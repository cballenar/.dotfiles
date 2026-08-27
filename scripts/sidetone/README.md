# Sidetone

A minimalist, zero-bloat microphone monitoring daemon for macOS.

## The Problem

My Elgato Wave Neo lacks direct hardware monitoring. This requires proprietary software—which injects unnecessary virtual audio channels, runs background daemons, consumes memory, and locks you into an always-on mic setup which lights up the macOS orange privacy dot or mic icon in the task bar.

## Installation & Usage

```bash
# Rebuild binary and reload background LaunchAgent
./install.sh

# List available device names
sidetone --list-devices

# Configure target devices and sox effects in ~/.config/sidetone/config.json
```

## The Architecture & Trade-Offs

It passes raw, low-latency audio into your ears. Meanwhile, meeting apps (Zoom, Meet, Slack) automatically route the microphone stream through macOS Voice Isolation, ensuring callers still receive background noise filtering.

### Features

- Runs `sox` with a custom buffer for instantaneous physical vocal feedback. Supposedly as low as ~1.3ms.
- Uses native macOS CoreAudio property listeners to sleep completely unless using intended device.
  - If chosen devices are in use: Sidetone starts instantly.
  - Switch to any other device, e.g, speakers: Sidetone terminates.
- Single compiled Swift binary via an unprivileged user LaunchAgent.
- Changes saved to `config.json` are automatically recognized and reloaded live.

### What It Loses

Raw monitoring means that we won't hear the same audio as what listeners will hear. If macOS's Voice Isolation is enabled, you won't hear the processed, noise free audio. It's recommended to run some tests to determine how well it works with your setup.

## Tested Alternatives

- **SoundSource / Rogue Amoeba**: Paid, annoying to use, cluttered UI.
- **BlackHole**: Couldn't get it to work for this setup. Possibly incompatible.
- **AU Lab**: Couldn't get it to work on modern macOS. Possibly outdated.
- **Hear Yourself (Python/py2app)**: Couldn't get it to work on modern macOS. Possibly outdated.
- **LadioCast**: Functional but holds the microphone open 24/7.
- **Elgato Wave Link**: Functional but holds the microphone open 24/7 and while effects are good, they add noticeable latency.
