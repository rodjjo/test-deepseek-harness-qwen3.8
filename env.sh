#!/usr/bin/env bash

# Base directories
export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HARNESS_DIR="${BASE_DIR}/deepseek-harness"
export LLAMA_SERVER="${BASE_DIR}/llama.cpp/build/bin/llama-server"
export MODEL_FILE="${BASE_DIR}/models/Qwen3.8-27B-Q3_K_M.gguf"
export PNPM_BIN="${BASE_DIR}/node_modules/.bin/pnpm"
export DSH_HOME="${BASE_DIR}/dsh_home"

# Configuration
export PORT=8000
export CTX_SIZE=16384
export GPU_LAYERS=999 
export SESSION_NAME="dsh"

# DeepSeek Harness Settings
export DEEPSEEK_BASE_URL="http://127.0.0.1:${PORT}/v1"
export DEEPSEEK_API_KEY="local-key-unused"
