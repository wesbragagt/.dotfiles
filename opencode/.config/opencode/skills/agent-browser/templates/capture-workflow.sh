#!/bin/bash
set -euo pipefail

# Capture Workflow Template
# Records video and screenshots of a browser workflow
# Usage: ./capture-workflow.sh <url> <output_prefix>

URL="${1:?Usage: $0 <url> <output_prefix>}"
OUTPUT_PREFIX="${2:-capture}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="${OUTPUT_DIR:-.}"

# Start recording
agent-browser record start --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}.webm"

# Open target URL
agent-browser open "$URL"
agent-browser wait networkidle

# Capture initial state
agent-browser screenshot --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_initial.png"
agent-browser snapshot -i

# Example workflow steps (customize as needed):

# Step 1: Interact with page
# agent-browser click @e1
# agent-browser wait networkidle
# agent-browser screenshot --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_step1.png"

# Step 2: Fill form
# agent-browser snapshot -i
# agent-browser fill @e2 "test data"
# agent-browser screenshot --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_step2.png"

# Step 3: Submit and capture result
# agent-browser click @e3
# agent-browser wait networkidle
# agent-browser screenshot --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_result.png"

# Stop recording
agent-browser record stop

# Capture final state
agent-browser screenshot --full --output "${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_final_full.png"

echo "Capture complete:"
echo "  Video: ${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}.webm"
echo "  Screenshots: ${OUTPUT_DIR}/${OUTPUT_PREFIX}_${TIMESTAMP}_*.png"

# Cleanup
# agent-browser close
