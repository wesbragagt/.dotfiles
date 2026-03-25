---
name: w-debug
description: Diagnose bugs, errors, and unexpected behavior — then suggest a fix. Use whenever the user describes something broken: error messages, crashes, wrong output, "this isn't working", "why is X happening". Delegates to a debugger subagent using a four-phase investigation (root cause → pattern → hypothesis → fix) before recommending anything. Never writes code — produces a structured prose diagnosis only.
argument-hint: "<problem description>"
---

# w-debug

Triage a bug systematically: explore first, ask targeted questions, then delegate to a debugger subagent.

## Step 1: Explore

Before asking anything, do lightweight exploration to understand the landscape:

- Read any files mentioned in the error or description
- Follow the stack trace if one was provided — read each file it touches
- Check recent git history if relevant (`git log --oneline -10`)
- Look for related files (config, tests, imports) that might be involved

The goal is to arrive at the clarifying questions already informed — not to diagnose, just to know what you don't know.

## Step 2: Enter plan mode and ask clarifying questions

After exploring, enter plan mode and ask **1–5 targeted questions** based on what's still unclear. Only ask what exploration couldn't answer. Fewer questions is better — skip any that are obvious from the code.

Good questions surface things like:
- Conditions that are hard to infer (environment, user state, timing)
- What changed recently if git history isn't available
- How often / under what conditions the issue reproduces
- Whether a specific hypothesis you already have can be confirmed or ruled out

Wait for the user's answers before proceeding.

## Step 3: Spawn the debugger subagent

Exit plan mode, then launch one agent using the Agent tool with:
- `subagent_type: "debugger"`
- `model: "sonnet"`

Use this prompt, filling in everything you've gathered:

```
You are a systematic debugger. Investigate this problem and produce a structured diagnosis.

IMPORTANT: Do not write any code. Output analysis, explanations, and recommendations in prose only.

## Problem
[USER'S FULL DESCRIPTION]

## Context gathered
- Error: [full error message and stack trace, or "not provided"]
- Trigger: [what causes it, or "not provided"]
- Frequency: [always / intermittently / rarely, or "not provided"]
- Recent changes: [what changed before this started, or "not provided"]
- Relevant files: [file paths explored]
- Additional context from user: [answers to clarifying questions]

## Investigation — complete these four phases in order

### Phase 1: Root Cause Investigation
- Read the full error message and stack trace carefully
- Trace the execution path from entry point to the failure
- Read every file mentioned in the stack trace or description
- Identify the exact line and condition where the failure originates

### Phase 2: Pattern Analysis
- Classify the bug type: race condition, null reference, off-by-one, auth timing, state mutation, type mismatch, async boundary, missing guard, etc.
- Are there similar patterns elsewhere in the codebase that may also be affected?

### Phase 3: Hypothesis Testing
- Form ONE specific, falsifiable hypothesis about the root cause
- State what evidence supports it and what would disprove it
- Do not list multiple possible causes — commit to the best-supported one

### Phase 4: Fix Recommendation (only after Phase 3)
- Describe precisely what needs to change and why it addresses the root cause, not just the symptom
- Recommend the most practical test type (unit, integration, or e2e) to catch this regression, with a brief rationale for why that type fits best

## Output format

**Root Cause**
Clear explanation of what's failing and why. Can be multiple sentences if the immediate and underlying causes are distinct.

**Evidence**
What confirms this from the code, trace, or behavior.

**Fix**
Which file, which function, what logic needs to change and how — in prose, no code.

**Regression Test**
Recommend unit, integration, or e2e — briefly explain why that type is the right fit — then describe what it should verify.
```

## Step 4: Present the diagnosis

```
**Root cause:** [one-line summary]

[Full diagnosis report]
```
