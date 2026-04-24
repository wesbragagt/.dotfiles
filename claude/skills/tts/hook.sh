#!/usr/bin/env bash
# Stop hook: speak Claude's last response via kokoro-tts
[ -f "$HOME/.claude/tts_enabled" ] || exit 0

MODEL="$HOME/kokoro-models/kokoro-v1.0.onnx"
VOICES="$HOME/kokoro-models/voices-v1.0.bin"

python3 -c "
import json, sys, re, subprocess

data = json.load(sys.stdin)
content = data.get('last_assistant_message', '')

# Strip code blocks and markdown
text = re.sub(r'\`\`\`[\s\S]*?\`\`\`', '.', content)
text = re.sub(r'\`[^\`]+\`', '', text)
text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
text = re.sub(r'\*([^*]+)\*', r'\1', text)
text = re.sub(r'#{1,6}\s+', '', text)
text = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', text)
text = re.sub(r'<[^>]+>', '', text)
text = re.sub(r'\n+', ' ', text).strip()
if text:
    subprocess.run(
        ['kokoro-tts', '-', '--stream', '--model', '$MODEL', '--voices', '$VOICES'],
        input=text.encode(), check=False
    )
" 2>/dev/null || true
