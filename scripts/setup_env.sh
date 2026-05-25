#!/bin/bash
set -euo pipefail

TOOLS=("bash" "grep" "awk" "sed" "sort")

MISSING=()

for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING+=("$tool")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Missing required tools: ${MISSING[*]}"
    exit 1
fi

echo "All required tools are installed"