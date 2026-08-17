#!/usr/bin/env bash

# Source settings
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

# Go to harness directory and run the web UI
cd "${HARNESS_DIR}"
exec "${PNPM_BIN}" dsh web
