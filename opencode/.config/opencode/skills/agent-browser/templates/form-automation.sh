#!/bin/bash
set -euo pipefail

# Form Automation Workflow Template
# Usage: ./form-automation.sh <form_url>

FORM_URL="${1:?Usage: $0 <form_url>}"

# Navigate to form
agent-browser open "$FORM_URL"
agent-browser wait networkidle

# Get form elements
agent-browser snapshot -i

# Example form filling (customize based on actual form):
# agent-browser fill @e1 "John Doe"           # Name field
# agent-browser fill @e2 "john@example.com"   # Email field
# agent-browser fill @e3 "password123"        # Password field
# agent-browser select @e4 "Option A"         # Dropdown
# agent-browser check @e5                     # Checkbox
# agent-browser click @e6                     # Radio button

# Submit form
# agent-browser click @e7                     # Submit button
# agent-browser wait networkidle

# Verify submission
# agent-browser wait url "success"
# agent-browser get url
# agent-browser snapshot -i
# agent-browser screenshot --output "form-result.png"

# Cleanup
# agent-browser close
