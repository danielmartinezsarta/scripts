# Claude Code Status Line - Devious Diamonds Theme

A custom powerline-style status line for Claude Code CLI, inspired by the Devious Diamonds Oh My Posh theme.

```
 ✦ Opus 4.7 (1M)   security-reviewer   feat/BDB-5001   5h 12% · 7d 30%   42%  $1.23 
 ─── orange ─────── magenta ──────────── purple ──────── green ───────────── cyan ── lt.magenta ─
```

## Segments

| # | Segment | Color | Description |
|---|---------|-------|-------------|
| 1 | Model + context size | `#D97757` Claude orange | Current model and its context window (e.g. `(1M)`, `(200K)`) |
| 2 | Agent | `#FF80BF` magenta | Active `--agent` name. Only renders when an agent is running. |
| 3 | Git branch | `#AA99FF` purple | Shortened branch (`feat/BDB-123`). Falls back to folder name when no git repo |
| 4 | Rate limits (5h + 7d) | green / yellow / red | Combined 5-hour and 7-day Claude usage windows, colored by the worse of the two, with reset countdown when in the red zone |
| 5 | Context | `#80FFEA` cyan | Context window usage with color alerts |
| 6 | Session cost | `#FF99CC` light magenta | Total USD cost of the current session |

### Rate limit colors

Color is driven by the higher-used window (5h or 7d). Both windows are displayed when present; only one when the other is absent.

- **< 50%** — Green (plenty of headroom)
- **50-79%** — Yellow (attention)
- **>= 80%** — Red, with `Xh Ym` countdown to the reset of the driving window

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
- `jq` for JSON parsing (ships with macOS at `/usr/bin/jq`; `brew install jq` on older systems)
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

Follow the pattern of existing segments. The script reads every field with a single `jq` call (see the top of `statusline.sh`) and assigns them into shell variables via `IFS=$'\x1f'`. Add new fields there and a rendering block further down.

The full Claude Code JSON schema is documented at [code.claude.com/docs/en/statusline](https://code.claude.com/docs/en/statusline). Highlights:

```json
{
  "model": { "id": "...", "display_name": "Opus 4.7" },
  "context_window": { "used_percentage": 42, "remaining_percentage": 58, "context_window_size": 1000000 },
  "cost": { "total_cost_usd": 1.23, "total_duration_ms": 45000, "total_lines_added": 156 },
  "workspace": { "current_dir": "/path/to/project", "git_worktree": "feature-xyz" },
  "rate_limits": { "five_hour": { "used_percentage": 23.5, "resets_at": 1738425600 } },
  "agent": { "name": "security-reviewer" },
  "session_id": "abc123...",
  "version": "2.1.90"
}
```
