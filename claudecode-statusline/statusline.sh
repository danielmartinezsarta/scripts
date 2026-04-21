#!/bin/bash
# Claude Code status line - Devious Diamonds (Oh My Posh) style
# Palette from: C:\dmsa-git\scripts\devious-diamonds.omp.json

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

# Parse rate limits (five_hour — nested inside rate_limits object)
RATE_5H_PCT=$(echo "$input" | sed -n 's/.*"five_hour"[^}]*"used_percentage"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1)
RATE_5H_PCT=${RATE_5H_PCT%.*}
RATE_5H_RESET=$(echo "$input" | sed -n 's/.*"five_hour"[^}]*"resets_at"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)

# Parse session cost
COST_USD=$(echo "$input" | sed -n 's/.*"total_cost_usd"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1)

# Get git branch and shorten: feature/user/BDB-123-desc → feat/BDB-123-desc
GIT_BRANCH_RAW=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH=""
if [ -n "$GIT_BRANCH_RAW" ]; then
  # Extract branch type prefix
  case "$GIT_BRANCH_RAW" in
    feature/*) PREFIX="feat" ;;
    bugfix/*|bug/*)  PREFIX="bug" ;;
    hotfix/*)  PREFIX="hotfix" ;;
    release/*) PREFIX="release" ;;
    *)         PREFIX="" ;;
  esac

  # Get the last segment (after last /)
  LAST_PART="${GIT_BRANCH_RAW##*/}"

  # Extract ticket ID if present (e.g. BDB-5001 from BDB-5001-mobile-auth-session)
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

# .NET version detection (disabled to save statusline space)
# DOTNET_VER=""
# if ls "$CWD"/*.csproj "$CWD"/*.sln "$CWD"/*.fsproj 2>/dev/null | head -1 > /dev/null 2>&1; then
#   DOTNET_FULL=$(dotnet --version 2>/dev/null)
#   if [ -n "$DOTNET_FULL" ]; then
#     DOTNET_MAJOR="${DOTNET_FULL%%.*}"
#     DOTNET_REST="${DOTNET_FULL#*.}"
#     DOTNET_MINOR="${DOTNET_REST%%.*}"
#     DOTNET_VER="${DOTNET_MAJOR}.${DOTNET_MINOR}"
#   fi
# fi

# Devious Diamonds palette - truecolor ANSI
BG_CLAUDE=$'\033[48;2;217;119;87m'    # #D97757 Claude brand orange
BG_LTMAGENTA=$'\033[48;2;255;153;204m' # #FF99CC lightMagenta (cost)
BG_MAGENTA=$'\033[48;2;255;128;191m'  # #FF80BF
BG_YELLOW=$'\033[48;2;255;202;128m'   # #FFCA80
BG_BLUE=$'\033[48;2;149;128;255m'     # #9580FF (path, like OMP)
BG_CYAN=$'\033[48;2;128;255;234m'     # #80FFEA
BG_RED=$'\033[48;2;255;149;128m'      # #FF9580
BG_PURPLE=$'\033[48;2;170;153;255m'   # #AA99FF (git branch)
BG_GREEN=$'\033[48;2;138;255;128m'    # #8AFF80 Dracula green (rate ok)
FG_BLACK=$'\033[38;2;27;26;35m'       # #1B1A23
FG_MAGENTA=$'\033[38;2;255;128;191m'
FG_YELLOW=$'\033[38;2;255;202;128m'
FG_BLUE=$'\033[38;2;149;128;255m'
FG_CYAN=$'\033[38;2;128;255;234m'
FG_RED=$'\033[38;2;255;149;128m'
FG_CLAUDE=$'\033[38;2;217;119;87m'
FG_LTMAGENTA=$'\033[38;2;255;153;204m'
FG_PURPLE=$'\033[38;2;170;153;255m'   # #AA99FF
FG_GREEN=$'\033[38;2;138;255;128m'
FG_WHITE=$'\033[38;2;255;255;255m'
RST=$'\033[0m'

# Icons
ICON_CLAUDE="✦"
ICON_DOTNET=$(printf '\xee\x9c\x8c')  # nf-dev-dotnet  \ue70c
ICON_FOLDER=$(printf '\xef\x84\x94')  # nf-fa-folder_open_o \uf114
ICON_GIT=$(printf '\xee\x9c\xa5')     # nf-dev-git_branch
ICON_RATE=$(printf '\xef\x83\xa4')    # nf-fa-tachometer \uf0e4
ARROW=$(printf '\xee\x82\xb0')        # powerline right arrow

# --- Build segments ---
OUT=""
LAST_FG=""

# Segment: Model + context size (Claude brand orange bg)
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
  LAST_FG="$FG_CLAUDE"
fi

# Segment: Git branch (purple bg)
if [ -n "$GIT_BRANCH" ]; then
  OUT+="${BG_PURPLE}${ARROW}${FG_BLACK} ${ICON_GIT} ${GIT_BRANCH} ${RST}${FG_PURPLE}"
  LAST_FG="$FG_PURPLE"
fi

# Segment: Current directory (blue bg, only when no git branch available)
if [ -z "$GIT_BRANCH" ]; then
  FOLDER=$(basename "$CWD")
  if [ -n "$FOLDER" ]; then
    OUT+="${BG_BLUE}${ARROW}${FG_BLACK} ${ICON_FOLDER} ${FOLDER} ${RST}${FG_BLUE}"
    LAST_FG="$FG_BLUE"
  fi
fi

# Segment: Rate limit 5h (green < 50%, yellow 50-79%, red >= 80% + reset countdown)
if [ -n "$RATE_5H_PCT" ]; then
  RESET_LABEL=""
  if [ "$RATE_5H_PCT" -ge 80 ]; then
    RATE_BG="$BG_RED"; RATE_FG="$FG_RED"
    # Show reset countdown in red zone only
    if [ -n "$RATE_5H_RESET" ]; then
      NOW=$(date +%s)
      DIFF=$((RATE_5H_RESET - NOW))
      if [ "$DIFF" -gt 0 ]; then
        HOURS=$((DIFF / 3600))
        MINS=$(( (DIFF % 3600) / 60 ))
        if [ "$HOURS" -gt 0 ]; then
          RESET_LABEL=" ${HOURS}h${MINS}m"
        else
          RESET_LABEL=" ${MINS}m"
        fi
      fi
    fi
  elif [ "$RATE_5H_PCT" -ge 50 ]; then
    RATE_BG="$BG_YELLOW"; RATE_FG="$FG_YELLOW"
  else
    RATE_BG="$BG_GREEN"; RATE_FG="$FG_GREEN"
  fi
  OUT+="${RATE_BG}${ARROW}${FG_BLACK} ${ICON_RATE} ${RATE_5H_PCT}%${RESET_LABEL} ${RST}${RATE_FG}"
  LAST_FG="$RATE_FG"
fi

# Segment: Context usage (cyan < 75%, soft yellow 75-89%, red >= 90%)
if [ -n "$CONTEXT_PCT" ]; then
  if [ "$CONTEXT_PCT" -ge 90 ]; then
    CTX_BG="$BG_RED"; CTX_FG="$FG_RED"
  elif [ "$CONTEXT_PCT" -ge 75 ]; then
    CTX_BG=$'\033[48;2;255;220;150m'; CTX_FG=$'\033[38;2;255;220;150m'
  else
    CTX_BG="$BG_CYAN"; CTX_FG="$FG_CYAN"
  fi
  OUT+="${CTX_BG}${ARROW}${FG_BLACK} ${CONTEXT_PCT}% ${RST}${CTX_FG}"
  LAST_FG="$CTX_FG"
fi

# Segment: Session cost (light magenta bg)
if [ -n "$COST_USD" ]; then
  COST_DISPLAY=$(printf '%.2f' "$COST_USD")
  OUT+="${BG_LTMAGENTA}${ARROW}${FG_BLACK} \$${COST_DISPLAY} ${RST}${FG_LTMAGENTA}"
  LAST_FG="$FG_LTMAGENTA"
fi

# Closing arrow
if [ -n "$LAST_FG" ]; then
  OUT+="${LAST_FG}${ARROW}${RST}"
fi

printf '%s' "$OUT"
