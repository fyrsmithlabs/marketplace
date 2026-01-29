# ASCII Terminal Recordings

This directory contains terminal recordings demonstrating Claude Code marketplace commands in action.

## Format

Recordings use the [asciinema](https://asciinema.org/) `.cast` format (asciicast v2). This format is:
- Human-readable JSON
- Easily embeddable in documentation
- Convertible to SVG/GIF for static display

## Installation

### macOS
```bash
brew install asciinema
```

### Linux/pip
```bash
pip install asciinema
```

### Verify Installation
```bash
asciinema --version
```

## Recording Commands

### Basic Recording
```bash
asciinema rec docs/recordings/{plugin}/{command}.cast
```

### Recording with Title
```bash
asciinema rec -t "Demo: /init command" docs/recordings/fs-dev/init.cast
```

### Recording with Idle Time Limit
```bash
asciinema rec --idle-time-limit 2 docs/recordings/fs-dev/init.cast
```

### Example Session
```bash
# Start recording
asciinema rec docs/recordings/fs-dev/init.cast

# In the recording session:
# 1. Run: claude
# 2. Execute: /init
# 3. Demonstrate the command
# 4. Exit claude
# 5. Press Ctrl+D to stop recording
```

## Naming Conventions

| Plugin | Directory | File Pattern |
|--------|-----------|--------------|
| fs-dev | `fs-dev/` | `{command}.cast` (e.g., `init.cast`) |
| contextd | `contextd/` | `{command}.cast` (e.g., `search.cast`) |
| fs-design | `fs-design/` | `{command}.cast` (e.g., `check.cast`) |

For contextd commands, drop the `contextd:` prefix in filenames:
- `/contextd:search` -> `contextd/search.cast`
- `/contextd:remember` -> `contextd/remember.cast`

## Playback

### Terminal Playback
```bash
asciinema play docs/recordings/fs-dev/init.cast
```

### Web Player
Upload to asciinema.org or embed using the asciinema player:

```html
<script src="https://asciinema.org/a/RECORDING_ID.js" async></script>
```

### Convert to SVG (for static documentation)
```bash
# Install svg-term-cli
npm install -g svg-term-cli

# Convert cast to SVG
svg-term --in docs/recordings/fs-dev/init.cast --out docs/recordings/fs-dev/init.svg
```

### Convert to GIF
```bash
# Install agg (asciinema gif generator)
cargo install --git https://github.com/asciinema/agg

# Convert cast to GIF
agg docs/recordings/fs-dev/init.cast docs/recordings/fs-dev/init.gif
```

## asciicast v2 Format Reference

Recordings are stored in asciicast v2 format:

```json
{"version": 2, "width": 120, "height": 30, "timestamp": 1706540000, "env": {"TERM": "xterm-256color"}}
[0.0, "o", "$ claude\r\n"]
[0.5, "o", "Welcome to Claude Code...\r\n"]
[1.0, "o", "> "]
[1.5, "i", "/help"]
[2.0, "o", "/help\r\n"]
```

- First line: Header with terminal dimensions and metadata
- Subsequent lines: `[timestamp, event_type, data]`
  - `"o"` = output (text displayed)
  - `"i"` = input (optional, for showing typed commands)

## Directory Structure

```
docs/recordings/
├── README.md           # This file
├── CHECKLIST.md        # Recording progress tracker
├── record-all.sh       # Helper script for recording
├── fs-dev/             # fs-dev plugin recordings
│   ├── init.cast
│   ├── yagni.cast
│   └── ...
├── contextd/           # contextd plugin recordings
│   ├── search.cast
│   ├── remember.cast
│   └── ...
└── fs-design/          # fs-design plugin recordings
    └── check.cast
```

## Best Practices

1. **Keep recordings short** - Aim for 30-60 seconds demonstrating core functionality
2. **Use idle time limits** - `--idle-time-limit 2` prevents long pauses
3. **Clear terminal first** - Run `clear` before starting the demo
4. **Use a clean environment** - Avoid personal data in recordings
5. **Show realistic usage** - Demonstrate actual workflows, not just help text
6. **Add titles** - Use `-t` flag for descriptive titles

## Contributing

See `CHECKLIST.md` for the list of commands that need recordings. To contribute:

1. Pick an unrecorded command from the checklist
2. Record using the conventions above
3. Test playback locally
4. Submit a PR with the new `.cast` file
5. Update the checklist
