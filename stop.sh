#!/usr/bin/env bash

# Load environment settings
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"


echo "=== Stopping DeepSeek Harness & Local LLM ==="

if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  echo "--> Killing tmux session '${SESSION_NAME}'..."
  tmux kill-session -t "${SESSION_NAME}"
  echo "Tmux session '${SESSION_NAME}' stopped."
else
  echo "No active tmux session '${SESSION_NAME}' found."
fi

# Clean up any remaining llama-server process just in case
if pgrep -f "llama-server" >/dev/null; then
  echo "--> Cleaning up lingering llama-server processes..."
  pkill -f "llama-server" || true
fi

echo "Done."
