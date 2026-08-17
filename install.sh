#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Base directories
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="${BASE_DIR}/deepseek-harness"
LLAMA_DIR="${BASE_DIR}/llama.cpp"
MODEL_DIR="${BASE_DIR}/models"
REPO_ID="unsloth/Qwen3.8-27B-GGUF"
MODEL_FILENAME="Qwen3.8-27B-Q8_0.gguf"
MODEL_FILE="${MODEL_DIR}/${MODEL_FILENAME}"

echo "=== DeepSeek Harness & Local LLM Setup ==="
echo "Base Directory: ${BASE_DIR}"
echo ""

# 1. Install local pnpm to avoid global dependency issues
echo "--> Installing pnpm locally in workspace..."
cd "${BASE_DIR}"
npm install --no-save pnpm

PNPM_BIN="${BASE_DIR}/node_modules/.bin/pnpm"
echo "pnpm installed at: ${PNPM_BIN}"
echo ""

# 2. Clone and install deepseek-harness
if [ ! -d "${HARNESS_DIR}" ]; then
  echo "--> Cloning deepseek-harness..."
  git clone https://github.com/deepseek-ai/deepseek-harness.git "${HARNESS_DIR}"
else
  echo "--> deepseek-harness directory already exists, skipping clone."
fi

echo "--> Building deepseek-harness..."
cd "${HARNESS_DIR}"
"${PNPM_BIN}" install
"${PNPM_BIN}" run build
echo "deepseek-harness build completed."
echo ""

# 3. Clone and compile llama.cpp
if [ ! -d "${LLAMA_DIR}" ]; then
  echo "--> Cloning llama.cpp..."
  git clone https://github.com/ggerganov/llama.cpp.git "${LLAMA_DIR}"
else
  echo "--> llama.cpp directory already exists, skipping clone."
fi

echo "--> Compiling llama-server with CUDA support..."
cd "${LLAMA_DIR}"

# Detect and set CUDACXX path if CUDA compilers are found in common locations
if [ -f "/usr/local/cuda-12.8/bin/nvcc" ]; then
  export CUDACXX="/usr/local/cuda-12.8/bin/nvcc"
elif [ -f "/usr/local/cuda-13.0/bin/nvcc" ]; then
  export CUDACXX="/usr/local/cuda-13.0/bin/nvcc"
fi

# Run cmake configuration
# If CUDA is installed and nvcc is available, it will configure CUDA backend
cmake -B build -DGGML_CUDA=ON -DCMAKE_BUILD_TYPE=Release

# Build llama-server
cmake --build build --config Release --target llama-server -j$(nproc)
echo "llama-server compilation completed."
echo ""

# 4. Download Qwen3.8 GGUF model
echo "--> Setting up model directory..."
mkdir -p "${MODEL_DIR}"

echo "--> Downloading Qwen3.8-27B-Q8_0.gguf..."
echo "Note: This is a ~29GB download. If the connection is interrupted, re-run this script to resume."

if command -v hf >/dev/null 2>&1; then
  hf download "${REPO_ID}" "${MODEL_FILENAME}" --local-dir "${MODEL_DIR}" 
else
  echo "Error: huggingface-cli is not installed. Please install it (e.g., pip install huggingface_hub)."
  exit 1
fi

echo ""
echo "=== Installation & Setup Complete! ==="
echo "You can now run the stack using: ./start.sh"
