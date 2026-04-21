#!/bin/bash
# Claude Code status line - Devious Diamonds (Oh My Posh) style
# Palette from: devious-diamonds.omp.json
# Requires: jq (ships with macOS at /usr/bin/jq), a Nerd Font, truecolor terminal

input=$(cat)

# Parse all JSON fields in a single jq pass, separated by ASCII Unit Separator
# (\x1f). Not \t, because bash read collapses consecutive whitespace delimiters
# even when IFS is set to a single whitespace char, which shifts empty fields.
IFS=$'\x1f' read -r \
  MODEL CTX_SIZE CONTEXT_PCT CWD COST_USD \
  RATE_5H_PCT RATE_5H_RESET RATE_7D_PCT RATE_7D_RESET \
  AGENT_NAME \
  <<<"$(printf '%s' "$input" | jq -r '[
    (.model.display_name // "" | gsub(" *\\([^)]*\\)"; "")),
    (.context_window.context_window_size // ""),
    (.context_window.used_percentage | if . == null then "" else floor end),
    (.workspace.current_dir // .cwd // ""),
    (.cost.total_cost_usd // ""),
    (.rate_limits.five_hour.used_percentage  | if . == null then "" else floor end),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage  | if . == null then "" else floor end),
    (.rate_limits.seven_day.resets_at // ""),
    (.agent.name // "")
  ] | map(tostring) | join("\u001f")')"

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
BG_MAGENTA=$'\033[48;2;255;128;191m'  # #FF80BF (agent)
BG_YELLOW=$'\033[48;2;255;202;128m'   # #FFCA80
BG_BLUE=$'\033[48;2;149;128;255m'     # #9580FF
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
FG_PURPLE=$'\033[38;2;170;153;255m'
FG_GREEN=$'\033[38;2;138;255;128m'
FG_WHITE=$'\033[38;2;255;255;255m'
RST=$'\033[0m'

# Icons
ICON_CLAUDE="✦"
ICON_DOTNET=$(printf '\xee\x9c\x8c')  # nf-dev-dotnet  
ICON_FOLDER=$(printf '\xef\x84\x94')  # nf-fa-folder_open_o 
ICON_GIT=$(printf '\xee\x9c\xa5')     # nf-dev-git_branch 
ICON_RATE=$(printf '\xef\x83\xa4')    # nf-fa-tachometer 
ICON_AGENT=$(printf '\xef\x95\x84')   # nf-md-robot 
ARROW=$(printf '\xee\x82\xb0')        # powerline right arrow 

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

# Segment: Agent (magenta bg, only when --agent or agent settings active)
if [ -n "$AGENT_NAME" ]; then
  OUT+="${BG_MAGENTA}${ARROW}${FG_BLACK} ${ICON_AGENT} ${AGENT_NAME} ${RST}${FG_MAGENTA}"
  LAST_FG="$FG_MAGENTA"
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

# Segment: Rate limits — combined 5h + 7d, color by the worst of the two.
# Shows reset countdown only in the red zone, for the window driving the color.
RATE_TEXT=""
RATE_PCT_MAX=""
RATE_RESET=""
if [ -n "$RATE_5H_PCT" ] && [ -n "$RATE_7D_PCT" ]; then
  RATE_TEXT="5h ${RATE_5H_PCT}% · 7d ${RATE_7D_PCT}%"
  if [ "$RATE_5H_PCT" -ge "$RATE_7D_PCT" ]; then
    RATE_PCT_MAX="$RATE_5H_PCT"; RATE_RESET="$RATE_5H_RESET"
  else
    RATE_PCT_MAX="$RATE_7D_PCT"; RATE_RESET="$RATE_7D_RESET"
  fi
elif [ -n "$RATE_5H_PCT" ]; then
  RATE_TEXT="5h ${RATE_5H_PCT}%"
  RATE_PCT_MAX="$RATE_5H_PCT"; RATE_RESET="$RATE_5H_RESET"
elif [ -n "$RATE_7D_PCT" ]; then
  RATE_TEXT="7d ${RATE_7D_PCT}%"
  RATE_PCT_MAX="$RATE_7D_PCT"; RATE_RESET="$RATE_7D_RESET"
fi

if [ -n "$RATE_PCT_MAX" ]; then
  RESET_LABEL=""
  if [ "$RATE_PCT_MAX" -ge 80 ]; then
    RATE_BG="$BG_RED"; RATE_FG="$FG_RED"
    if [ -n "$RATE_RESET" ]; then
      NOW=$(date +%s)
      DIFF=$((RATE_RESET - NOW))
      if [ "$DIFF" -gt 0 ]; then
        HOURS=$((DIFF / 3600))
        MINS=$(((DIFF % 3600) / 60))
        if [ "$HOURS" -gt 0 ]; then
          RESET_LABEL=" ${HOURS}h${MINS}m"
        else
          RESET_LABEL=" ${MINS}m"
        fi
      fi
    fi
  elif [ "$RATE_PCT_MAX" -ge 50 ]; then
    RATE_BG="$BG_YELLOW"; RATE_FG="$FG_YELLOW"
  else
    RATE_BG="$BG_GREEN"; RATE_FG="$FG_GREEN"
  fi
  OUT+="${RATE_BG}${ARROW}${FG_BLACK} ${ICON_RATE} ${RATE_TEXT}${RESET_LABEL} ${RST}${RATE_FG}"
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
