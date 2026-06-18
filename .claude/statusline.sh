#!/usr/bin/env bash
# Claude Code status line for job-portal-ui
# Displays: model name | context % with a block progress bar

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

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

  printf "%s  |  ctx: ${color}%s${reset} %d%%" \
    "$model" "$bar" "$used_int"
else
  printf "%s  |  ctx: ░░░░░░░░░░ --%%"  "$model"
fi
