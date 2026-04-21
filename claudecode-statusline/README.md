# Claude Code Status Line - Devious Diamonds Theme

A custom powerline-style status line for Claude Code CLI, inspired by the Devious Diamonds Oh My Posh theme.

```
 ✦ Opus 4.7 (1M)   feat/BDB-5001   35%   42%  $1.23 
 ─── orange ─────── purple ──────── green ─ cyan ── lt.magenta ─
```

## Segments

| # | Segment | Color | Description |
|---|---------|-------|-------------|
| 1 | Model + context size | `#D97757` Claude orange | Current model and its context window (e.g. `(1M)`, `(200K)`) |
| 2 | Git branch | `#AA99FF` purple | Shortened branch (`feat/BDB-123`). Falls back to folder name when no git repo |
| 3 | Rate limit (5h) | green / yellow / red | 5-hour Claude usage window, with reset countdown when in the red zone |
| 4 | Context | `#80FFEA` cyan | Context window usage with color alerts |
| 5 | Session cost | `#FF99CC` light magenta | Total USD cost of the current session |

### Rate limit colors

- **< 50%** — Green (plenty of headroom)
- **50-79%** — Yellow (attention)
- **>= 80%** — Red, with `Xh Ym` countdown to the next reset

### Context usage colors

- **< 75%** — Cyan (normal)
- **75-89%** — Soft yellow (attention)
- **>= 90%** — Red (critical, consider starting a new conversation)

### Branch shortening

`feature/user/BDB-5001-mobile-auth` → `feat/BDB-5001`. Supported prefixes: `feature/` → `feat`, `bugfix/`|`bug/` → `bug`, `hotfix/`, `release/`. Without a ticket ID, the branch is left untouched.

### .NET segment

The .NET version segment exists in the script (commented out) to keep the status line compact. Uncomment the block in `statusline.sh` to re-enable it.

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
