#!/usr/bin/env bash

# Load environment settings
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"


echo "=== Starting DeepSeek Harness & Local LLM via Tmux ==="

# Check if model file exists
if [ ! -f "${MODEL_FILE}" ]; then
  echo "Error: Model file not found at ${MODEL_FILE}"
  echo "Please run ./install.sh first to download the model."
  exit 1
fi

# Check if llama-server binary exists
if [ ! -f "${LLAMA_SERVER}" ]; then
  echo "Error: llama-server not found at ${LLAMA_SERVER}"
  echo "Please run ./install.sh first to compile llama.cpp."
  exit 1
fi

# Check if tmux session already exists
if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  echo "Error: Tmux session '${SESSION_NAME}' is already running."
  echo "To stop it, run: ./stop.sh"
  exit 1
fi

# Create local DSH Home if it doesn't exist
mkdir -p "${DSH_HOME}"

echo "--> Starting tmux session '${SESSION_NAME}'..."

# Start a new detached tmux session running the llama-server script
tmux new-session -d -s "${SESSION_NAME}" -n "llama-server" "${BASE_DIR}/run-llama-server.sh"


# Poll the /health endpoint to wait for llama-server initialization
echo "--> Waiting for llama-server to initialize (loading model into GPU/RAM)..."
while true; do
  # Check if tmux session or llama-server process inside it is still active
  if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "Error: Tmux session '${SESSION_NAME}' was terminated unexpectedly."
    exit 1
  fi
  
  HEALTH_STATUS=$(curl -s http://127.0.0.1:${PORT}/health 2>/dev/null || true)
  if echo "${HEALTH_STATUS}" | grep -q '"status":\s*"ok"'; then
    echo "llama-server is ready!"
    break
  fi
  
  sleep 2
done

# Create a new window running the deepseek-harness web UI script
echo "--> Starting DeepSeek Harness Web UI in tmux window..."
tmux new-window -t "${SESSION_NAME}" -n "deepseek-harness" "${BASE_DIR}/run-harness.sh"



echo ""
echo "=== Setup Successful! ==="
echo "Tmux session '${SESSION_NAME}' is running in the background."
echo "  * Local LLM (llama-server) is running on port ${PORT}."
echo "  * DeepSeek Harness Web UI is starting on port 3080."
echo ""
echo "Commands:"
echo "  * To view the logs/console:   tmux attach -t ${SESSION_NAME}"
echo "  * To stop the servers:        ./stop.sh"
echo ""
echo "Open your browser at: http://localhost:3080"
