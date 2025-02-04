#!/bin/bash

sleep 15
# Name of the tmux session and windows
SESSION_NAME="minerx"
ADMIN_WINDOW="admin"
MINER_WINDOW="11xP104-100"
MONITOR_WINDOW="monitor"

# Paths to the applications
QUAI_MINER_PATH="/home/clu/quai"

# Commands to run the applications
QUAI_MINER_COMMAND="./output/quai-gpu-miner-nvidia -U -P stratum://10.250.35.45:3333"

# Function to check if a session exists
session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

# Function to check if a window exists within a session
window_exists() {
  local session="$1"
  local window="$2"
  tmux list-windows -t "$session" 2>/dev/null | grep -q "^${window}:"
}

# Function to create a window if it doesn't exist
create_window() {
  local session="$1"
  local window="$2"
  local path="$3"
  local command="$4"

  if ! window_exists "$session" "$window"; then
    echo "Creating window: $window"
    tmux new-window -n "$window"
    if [ -n "$command" ]; then
      tmux send-keys -t "$session:$window" "cd $path && exec $command" C-m
    fi
  else
    echo "Window $window already exists."
  fi
}

# Create the session if it doesn't exist
if ! session_exists "$SESSION_NAME"; then
  echo "Creating new tmux session: $SESSION_NAME with initial window: $ADMIN_WINDOW"
  tmux new-session -d -s "$SESSION_NAME" -n "$ADMIN_WINDOW"
else
  echo "Session $SESSION_NAME already exists."
fi

# Create the required windows if they don't exist
create_window "$SESSION_NAME" "$MINER_WINDOW" "$QUAI_MINER_PATH" "$QUAI_MINER_COMMAND"

# Select the miner window as the active window
#tmux select-window -t "$SESSION_NAME:$MINER_WINDOW"

# Attach to the session
#tmux attach-session -t "$SESSION_NAME"
