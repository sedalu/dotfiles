#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Claude Code status line — Catppuccin Mocha palette, mirrors Starship prompt style.

input=$(cat)

# --- Colors (Catppuccin Mocha ANSI) ---
blue='\033[38;2;137;180;250m'    # blue      #89b4fa
mauve='\033[38;2;203;166;247m'   # mauve     #cba6f7
green='\033[38;2;166;227;161m'   # green     #a6e3a1
yellow='\033[38;2;249;226;175m'  # yellow    #f9e2af
red='\033[38;2;243;138;168m'     # red       #f38ba8
subtext='\033[38;2;166;173;200m' # subtext0  #a6adc8
reset='\033[0m'

# --- Data from JSON ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Directory: shorten home to ~, truncate to last 3 segments ---
home="$HOME"
short_cwd="${cwd/#$home/~}"
IFS='/' read -ra parts <<< "$short_cwd"
if (( ${#parts[@]} > 3 )); then
    short_cwd="${parts[-3]}/${parts[-2]}/${parts[-1]}"
fi

# --- Git branch (skip optional lock) ---
branch=""
if git_root=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --git-dir 2>/dev/null); then
    branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
             || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Context usage color ---
ctx_color="$green"
if [[ -n "$used" ]]; then
    used_int=${used%.*}
    if (( used_int >= 80 )); then
        ctx_color="$red"
    elif (( used_int >= 50 )); then
        ctx_color="$yellow"
    fi
fi

# --- Assemble ---
line=""
line+="${blue}${short_cwd}${reset}"
if [[ -n "$branch" ]]; then
    line+=" ${mauve} ${branch}${reset}"
fi
line+=" ${subtext}${model}${reset}"
if [[ -n "$used" ]]; then
    line+=" ${ctx_color}${used}%${reset}"
fi

printf "%b" "$line"
