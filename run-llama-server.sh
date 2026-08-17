#!/usr/bin/env bash

# Source settings
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

# Run llama-server
exec "${LLAMA_SERVER}" \
  -m "${MODEL_FILE}" \
  -c ${CTX_SIZE} \
  -ngl ${GPU_LAYERS} \
  --port ${PORT} \
  --host 127.0.0.1 \
  --parallel 1 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --flash-attn on \
  --jinja

