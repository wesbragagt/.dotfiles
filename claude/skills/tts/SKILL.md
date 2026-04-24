---
name: tts
description: Toggle kokoro-tts text-to-speech for Claude responses. When enabled, Claude's last response is spoken aloud after each turn. Use when user says "/tts", "turn on tts", "enable tts", "disable tts", "turn off tts", "speak to me", "tts toggle".
argument-hint: "[on|off] (omit to toggle current state)"
---

# tts

Toggle text-to-speech using `kokoro-tts`. State is tracked via `~/.claude/tts_enabled`.

## Check current state

```bash
[ -f ~/.claude/tts_enabled ] && echo "on" || echo "off"
```

## Toggle logic

- Arg `on` → enable
- Arg `off` → disable
- No arg → flip current state

## Enable

```bash
touch ~/.claude/tts_enabled
```

Test immediately to confirm it works:
```bash
echo "Text to speech enabled" | kokoro-tts - --stream \
  --model ~/kokoro-models/kokoro-v1.0.onnx \
  --voices ~/kokoro-models/voices-v1.0.bin
```

Tell the user: "TTS enabled."

## Disable

```bash
rm -f ~/.claude/tts_enabled
```

Tell the user: "TTS disabled."

## How it works

The Stop hook at `~/.claude/skills/tts/hook.sh` runs after every response. It checks for `~/.claude/tts_enabled` and pipes the last assistant message through:

```
kokoro-tts - --stream --model ~/kokoro-models/kokoro-v1.0.onnx --voices ~/kokoro-models/voices-v1.0.bin
```

Code blocks and markdown are stripped before speaking.

## Response style when TTS is active

When `~/.claude/tts_enabled` exists, Claude MUST write all responses as natural spoken language:

- No markdown: no bullet lists, no headers, no bold/italic, no code fences
- Short, direct sentences — the way you'd actually talk
- No filler phrases like "Certainly!" or "Great question!"
- If showing code is unavoidable, describe what it does verbally instead of dumping a block
- After toggling TTS on, check the file exists and confirm in plain speech: say something like "Got it, I'll talk to you from here on."
