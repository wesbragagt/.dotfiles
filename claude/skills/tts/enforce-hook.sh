#!/usr/bin/env bash
# UserPromptSubmit hook: inject TTS style enforcement when tts_enabled exists
[ -f "$HOME/.claude/tts_enabled" ] || exit 0

cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalSystemPrompt": "TTS MODE ACTIVE. Your response will be piped through kokoro-tts and spoken aloud. Rules: no markdown (no bullets, headers, bold, italic, code fences, inline code), short direct sentences, no filler phrases. Describe code verbally instead of showing blocks. Write as natural spoken language."
  }
}
EOF
