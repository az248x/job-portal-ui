#!/usr/bin/env bash
# Claude Code status line for job-portal-ui
# Displays: model name | context % with a block progress bar | cost | time

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

cost_fmt=$(printf '$%.3f' "$cost")
duration_sec=$(( duration_ms / 1000 ))
mins=$(( duration_sec / 60 ))
secs=$(( duration_sec % 60 ))
time_fmt=$(printf '%dm%02ds' "$mins" "$secs")

if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")

  filled=$(( used_int / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done

  if [ "$used_int" -le 50 ]; then
    color="\033[32m"
  elif [ "$used_int" -le 80 ]; then
    color="\033[33m"
  else
    color="\033[31m"
  fi
  reset="\033[0m"

  printf "%s  |  ctx: ${color}%s${reset} %d%%  |  %s  |  %s" \
    "$model" "$bar" "$used_int" "$cost_fmt" "$time_fmt"
else
  printf "%s  |  ctx: ░░░░░░░░░░ --%%  |  %s  |  %s" "$model" "$cost_fmt" "$time_fmt"
fi
