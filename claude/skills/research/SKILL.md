---
name: research
description: Research skill that delegates investigation to a single subagent. Use this skill whenever the user asks to research, investigate, explore, look into, or learn about any topic. Invoke it for questions like "research X", "what do we know about Y", "look into Z for me", "deep dive on", or "find out about".
argument-hint: <topic or question>
---

# Research

Conduct research by delegating to the `researcher` subagent, then presenting the findings.

## Step 1: Classify the question

Choose a mode:
- `answer` — factual, single-concept, or quick-lookup questions
- `deep-research` — comparisons, how-to, multi-part, or open-ended questions

## Step 2: Spawn the researcher agent

Launch one agent using the Agent tool with:
- `subagent_type: "researcher"`
- `model: "haiku"`

**Agent prompt — use this exact structure:**
```
text: [USER'S FULL QUESTION]
mode: answer | deep-research
```

The agent returns JSON: `{ "answer": "...", "citations": [{ "url": "...", "title": "..." }] }`

## Step 3: Present findings

### For `mode: answer`

```
### [Topic]

- [key point]
- [key point]
- [key point]

**Sources**
- [Title](url)
```

### For `mode: deep-research`

```
### [Topic]

- [key point]
- [key point]
- [key point]

**Examples**
[code snippet or real-world usage from the answer — include both if present]

**Sources**
- [Title](url)
```

- Extract 3–5 bullets from the `answer` field
- For deep-research, pull out any code snippets and real-world usage examples into the **Examples** section
- List all `citations` as markdown links under **Sources**
- Flag gaps if citations are sparse or the answer is thin
