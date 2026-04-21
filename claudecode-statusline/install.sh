#!/bin/bash
# Claude Code Status Line Installer - Devious Diamonds theme
# Usage: bash install.sh
#
# What it does:
#   1. Copies statusline.sh to ~/.claude/
#   2. Makes it executable
#   3. Adds the statusLine config to ~/.claude/settings.json
#
# Requirements:
#   - Claude Code CLI installed
#   - A Nerd Font installed in your terminal (same as Oh My Posh)
#   - Truecolor terminal support

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
STATUSLINE_SRC="$SCRIPT_DIR/statusline.sh"

echo "Installing Claude Code status line (Devious Diamonds theme)..."

# Verify source exists
if [ ! -f "$STATUSLINE_SRC" ]; then
  echo "Error: statusline.sh not found in $SCRIPT_DIR"
  exit 1
fi

# Create ~/.claude if needed
mkdir -p "$CLAUDE_DIR"

# Copy and make executable
cp "$STATUSLINE_SRC" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"
echo "  Copied statusline.sh to $CLAUDE_DIR/"

# Configure settings.json
if [ -f "$SETTINGS_FILE" ]; then
  # Check if statusLine is already configured
  if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
    echo "  settings.json already has a statusLine config — skipping."
    echo "  To update manually, set: \"command\": \"bash ~/.claude/statusline.sh\""
  else
    tmp="$(mktemp)"
    if command -v jq >/dev/null 2>&1; then
      # Preferred: use jq for correct JSON manipulation
      jq '. + {statusLine: {type: "command", command: "bash ~/.claude/statusline.sh"}}' \
        "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
      echo "  Updated $SETTINGS_FILE with statusLine config (via jq)."
    else
      # Fallback: portable sed (works on BSD/macOS and GNU/Linux; avoids -i differences)
      sed '1 a\
  "statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" },
' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
      echo "  Updated $SETTINGS_FILE with statusLine config (via sed)."
    fi
  fi
else
  # Create new settings.json
  cat > "$SETTINGS_FILE" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
EOF
  echo "  Created $SETTINGS_FILE with statusLine config."
fi

echo ""
echo "Done! Restart Claude Code to see the new status line."
echo ""
echo "Segments:"
echo "  1. Model name (Claude orange)"
echo "  2. .NET version (purple, only in .NET projects)"
echo "  3. Git branch (magenta)"
echo "  4. Current folder (blue)"
echo "  5. Context usage (cyan < 75% | yellow 75-89% | red >= 90%)"
