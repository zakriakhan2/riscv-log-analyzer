#!/bin/bash

set -euo pipefail

echo "==========================================="
echo "Initializing Environment Dependency Check..."
echo "==========================================="

# Array of core system tools required by the analyzer
REQUIRED_TOOLS=("bash" "grep" "awk" "sed")
MISSING_TOOLS=0

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "[ERROR] Required tool '$tool' is missing from the system path." >&2
        MISSING_TOOLS=$((MISSING_TOOLS + 1))
    else
        echo "[OK] Found dependency: $tool"
    fi
done

if [ "$MISSING_TOOLS" -gt 0 ]; then
    echo "-------------------------------------------"
    echo "[FAIL] Environment setup failed. Please install missing tools." >&2
    exit 1
fi

# Ensure output directory exists
mkdir -p output
echo "[OK] Output workspace directory checked/created successfully."

echo "-------------------------------------------"
echo "[SUCCESS] Environment validation complete."
exit 0
