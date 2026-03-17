---
name: research
description: Research skill that delegates investigation to a single subagent. Use this skill whenever the user asks to research, investigate, explore, look into, or learn about any topic. Invoke it for questions like "research X", "what do we know about Y", "look into Z for me", "deep dive on", or "find out about".
argument-hint: <topic or question>
---

# Research

Conduct research by delegating to a single haiku researcher agent, then presenting the findings.

## How it works

1. **Delegate** one haiku researcher agent with the full question
2. **Present** findings as a coherent, cited summary

## Step 1: Spawn the researcher agent

Launch one agent using the Agent tool with:
- `subagent_type: "researcher"`
- `model: "haiku"`
- A focused prompt covering the full question (include all relevant angles in a single prompt)

**Agent prompt template:**
```
Original question: [USER'S FULL QUESTION]

Research this topic thoroughly. Cover:
- Core concepts and background
- How it works / practical usage
- Tradeoffs, alternatives, and known issues
- Real-world examples or current state of practice

Return your findings as structured markdown with source references where possible.
```

## Step 2: Present findings

Once the agent returns, present a clean response:

```
## Research: [Topic]

### [Thematic sections]
[findings organized around the user's actual question]

### Key takeaways
[3–5 bullets distilling the most important points]

### Sources & further reading
[any URLs or references the agent surfaced]
```

- Flag gaps where the agent couldn't find good information
- Keep the user's original question in mind — organize the output around answering *their* question
