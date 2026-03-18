#!/bin/bash
# Claude Code status line - Devious Diamonds (Oh My Posh) style
# Powerline segments with Dracula-inspired palette
#
# Segments: Model (CTX) | .NET version | Git branch | Folder (no git) | Context %
# Requires: Nerd Font (same as Oh My Posh), truecolor terminal

input=$(cat)

# Parse JSON fields
get_field() {
  echo "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}
get_number() {
  echo "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p" | head -1
}

MODEL=$(get_field "display_name" | sed 's/ *([^)]*)//g')
CTX_SIZE=$(get_number "context_window_size")
CONTEXT_PCT=$(get_number "used_percentage")
CONTEXT_PCT=${CONTEXT_PCT%.*}
CWD=$(get_field "current_dir")

# Get git branch and shorten: feature/user/BDB-123-desc → feat/BDB-123
GIT_BRANCH_RAW=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH=""
if [ -n "$GIT_BRANCH_RAW" ]; then
  case "$GIT_BRANCH_RAW" in
    feature/*) PREFIX="feat" ;;
    bugfix/*|bug/*)  PREFIX="bug" ;;
    hotfix/*)  PREFIX="hotfix" ;;
    release/*) PREFIX="release" ;;
    *)         PREFIX="" ;;
  esac

  LAST_PART="${GIT_BRANCH_RAW##*/}"
  TICKET=$(echo "$LAST_PART" | sed -n 's/^\([A-Z]\{2,\}-[0-9]\{1,\}\).*/\1/p')

  if [ -n "$PREFIX" ] && [ -n "$TICKET" ]; then
    GIT_BRANCH="${PREFIX}/${TICKET}"
  elif [ -n "$TICKET" ]; then
    GIT_BRANCH="$TICKET"
  elif [ -n "$PREFIX" ] && [ "$LAST_PART" != "$GIT_BRANCH_RAW" ]; then
    GIT_BRANCH="${PREFIX}/${LAST_PART}"
  else
    GIT_BRANCH="$GIT_BRANCH_RAW"
  fi
fi

# Get .NET version only when project files exist (mimics oh-my-posh display_mode: files)
DOTNET_VER=""
if ls "$CWD"/*.csproj "$CWD"/*.sln "$CWD"/*.fsproj 2>/dev/null | head -1 > /dev/null 2>&1; then
  DOTNET_FULL=$(dotnet --version 2>/dev/null)
  if [ -n "$DOTNET_FULL" ]; then
    DOTNET_MAJOR="${DOTNET_FULL%%.*}"
    DOTNET_REST="${DOTNET_FULL#*.}"
    DOTNET_MINOR="${DOTNET_REST%%.*}"
    DOTNET_VER="${DOTNET_MAJOR}.${DOTNET_MINOR}"
  fi
fi

# Devious Diamonds palette - truecolor ANSI
BG_CLAUDE=$'\033[48;2;217;119;87m'    # #D97757 Claude brand orange
BG_MAGENTA=$'\033[48;2;255;128;191m'  # #FF80BF
BG_BLUE=$'\033[48;2;149;128;255m'     # #9580FF
BG_CYAN=$'\033[48;2;128;255;234m'     # #80FFEA
BG_RED=$'\033[48;2;255;149;128m'      # #FF9580
FG_BLACK=$'\033[38;2;27;26;35m'       # #1B1A23
FG_MAGENTA=$'\033[38;2;255;128;191m'
FG_BLUE=$'\033[38;2;149;128;255m'
FG_CYAN=$'\033[38;2;128;255;234m'
FG_RED=$'\033[38;2;255;149;128m'
FG_CLAUDE=$'\033[38;2;217;119;87m'
FG_PURPLE=$'\033[38;2;170;153;255m'   # #AA99FF
FG_WHITE=$'\033[38;2;255;255;255m'
RST=$'\033[0m'

# Icons (Nerd Font - UTF-8 encoded)
ICON_CLAUDE="✦"
ICON_DOTNET=$(printf '\xee\x9c\x8c')  # \ue70c
ICON_FOLDER=$(printf '\xef\x84\x94')  # \uf114
ICON_GIT=$(printf '\xee\x9c\xa5')     # \ue725
ARROW=$(printf '\xee\x82\xb0')        # \ue0b0

# --- Build segments ---
OUT=""

# Segment 1: Model + context size (Claude brand orange bg)
CTX_LABEL=""
if [ -n "$CTX_SIZE" ]; then
  CTX_INT=${CTX_SIZE%.*}
  if [ "$CTX_INT" -ge 1000000 ]; then
    CTX_LABEL=" ($((CTX_INT / 1000000))M)"
  elif [ "$CTX_INT" -ge 1000 ]; then
    CTX_LABEL=" ($((CTX_INT / 1000))K)"
  fi
fi
if [ -n "$MODEL" ]; then
  OUT+="${BG_CLAUDE}${FG_WHITE} ${ICON_CLAUDE} ${MODEL}${CTX_LABEL} ${RST}${FG_CLAUDE}"
fi

# Segment 2: .NET version (no background, purple text, only when project files exist)
if [ -n "$DOTNET_VER" ]; then
  OUT+="${ARROW}${RST}${FG_PURPLE} ${ICON_DOTNET} ${DOTNET_VER} ${RST}"
fi

# Segment 3: Git branch (magenta bg) — type/TICKET only
if [ -n "$GIT_BRANCH" ]; then
  OUT+="${BG_MAGENTA}${ARROW}${FG_BLACK} ${ICON_GIT} ${GIT_BRANCH} ${RST}${FG_MAGENTA}"
fi

# Segment 4: Current directory (blue bg, only when no git branch available)
if [ -z "$GIT_BRANCH" ]; then
  FOLDER=$(basename "$CWD")
  if [ -n "$FOLDER" ]; then
    OUT+="${BG_BLUE}${ARROW}${FG_BLACK} ${ICON_FOLDER} ${FOLDER} ${RST}${FG_BLUE}"
  fi
fi

# Segment 5: Context usage (cyan < 75%, soft yellow 75-89%, red >= 90%)
if [ -n "$CONTEXT_PCT" ]; then
  if [ "$CONTEXT_PCT" -ge 90 ]; then
    CTX_BG="$BG_RED"; CTX_FG="$FG_RED"
  elif [ "$CONTEXT_PCT" -ge 75 ]; then
    CTX_BG=$'\033[48;2;255;220;150m'; CTX_FG=$'\033[38;2;255;220;150m'
  else
    CTX_BG="$BG_CYAN"; CTX_FG="$FG_CYAN"
  fi

  OUT+="${CTX_BG}${ARROW}${FG_BLACK} ${CONTEXT_PCT}% ${RST}${CTX_FG}${ARROW}${RST}"
fi

printf '%s' "$OUT"
