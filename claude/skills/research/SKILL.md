---
name: research
description: Research skill that delegates investigation to a single subagent. Use this skill whenever the user asks to research, investigate, explore, look into, or learn about any topic. Invoke it for questions like "research X", "what do we know about Y", "look into Z for me", "deep dive on", or "find out about".
argument-hint: <topic or question>
---

# Research

Delegate to the `researcher` subagent, then present findings. Must complete in under 60 seconds.

## Step 1: Classify

- `answer` — single-concept, factual, quick lookup
- `deep-research` — comparisons, how-to, multi-part, open-ended

## Step 2: Spawn researcher

Launch one Agent with `subagent_type: "researcher"`, `model: "haiku"`.

Prompt (use exactly):
```
text: [USER'S FULL QUESTION]
mode: answer | deep-research
```

Returns JSON: `{ "answer": "...", "citations": [{ "url": "...", "title": "..." }] }`

## Step 3: Present

For `answer`:
```
### [Topic]
- [key point x3-5]

**Sources**
- [Title](url)
```

For `deep-research`:
```
### [Topic]
- [key point x3-5]

**Examples**
[code snippets or real-world usage if present in the answer]

**Sources**
- [Title](url)
```

List all `citations` as markdown links. Flag gaps if citations are sparse.
