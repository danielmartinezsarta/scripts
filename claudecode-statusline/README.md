# Claude Code Status Line - Devious Diamonds Theme

A custom powerline-style status line for Claude Code CLI, inspired by the Devious Diamonds Oh My Posh theme.

```
 ✦ Opus 4.6   10.0   feature/my-branch   biodashboard  usage: 42%
 ─── orange ──── purple ──── magenta ─────── blue ─────── cyan ────
```

## Segments

| # | Segment | Color | Description |
|---|---------|-------|-------------|
| 1 | Model | `#D97757` Claude orange | Current Claude model |
| 2 | .NET | `#AA99FF` purple (no bg) | .NET version, only when `.csproj`/`.sln` files exist |
| 3 | Git branch | `#FF80BF` magenta | Current branch from git |
| 4 | Folder | `#9580FF` blue | Current working directory name |
| 5 | Context | `#80FFEA` cyan | Context window usage with color alerts |

### Context usage colors

- **< 75%** — Cyan (normal)
- **75-89%** — Soft yellow (attention)
- **>= 90%** — Red (critical, consider starting a new conversation)

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- A **Nerd Font** in your terminal (same one you use for Oh My Posh)
- Terminal with **truecolor** support (Windows Terminal, iTerm2, etc.)

## Quick Install

```bash
bash install.sh
```

Then restart Claude Code.

## Manual Install

1. Copy `statusline.sh` to `~/.claude/`:

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

3. Restart Claude Code.

## Customization

### Change colors

Edit the palette section in `statusline.sh`. Colors use truecolor ANSI format:

```bash
# Background: \033[48;2;R;G;Bm
# Foreground: \033[38;2;R;G;Bm
BG_CLAUDE=$'\033[48;2;217;119;87m'  # change RGB values here
```

### Remove a segment

Comment out or delete the segment block in the `# --- Build segments ---` section.

### Add a segment

Follow the pattern of existing segments. The JSON data available from Claude Code includes:

```json
{
  "model": { "id": "...", "display_name": "Opus 4.6" },
  "context_window": { "used_percentage": 42, "remaining_percentage": 58 },
  "cost": { "total_cost_usd": 1.23 },
  "workspace": { "current_dir": "/path/to/project" },
  "version": "2.1.74"
}
```
