---
name: prompter
description: Craft effective prompts for subagent delegation. Use this skill when delegating work to subagents to ensure clear, well-structured prompts that produce high-quality results.
---

This skill provides a systematic approach to crafting prompts for subagent delegation, based on LLM prompting best practices.

## 7-Step Prompt Crafting Framework

### Step 1: Define Clear Intent & Output

State exactly what you want. Be explicit about:
- The task objective
- Desired output format
- Success criteria

```
BAD: "Improve this code"
GOOD: "Refactor this function to reduce complexity. Return the refactored code with a brief explanation of changes made."
```

### Step 2: Provide Context & Motivation

Explain WHY the task matters. Context improves performance:

```
<context>
This function handles payment processing. Errors here cause customer billing issues, so correctness is critical.
</context>
```

### Step 3: Structure with XML Tags

Use XML tags to organize complex prompts unambiguously:

```xml
<task>
  <objective>What needs to be done</objective>
  <constraints>Limitations and requirements</constraints>
  <input>The data/code to work with</input>
  <output_format>Expected format</output_format>
</task>
```

### Step 4: Add Examples (Few-Shot)

Include 3-5 relevant, diverse examples wrapped in tags:

```xml
<examples>
  <example>
    <input>Sample input</input>
    <output>Expected output</output>
  </example>
</examples>
```

### Step 5: Specify Role & Behavior

Set the agent's role and default behaviors:

```xml
<role>You are a security-focused code reviewer specializing in Python.</role>

<behavior>
- Default to action over suggestion
- Flag security issues immediately
- Prefer standard library solutions
</behavior>
```

### Step 6: Define Verification Criteria

Tell the agent how to verify success:

```xml
<verification>
Before completing:
1. Run all tests
2. Check for lint errors
3. Verify the function handles edge cases
</verification>
```

### Step 7: Set Return Requirements

Specify exactly what to return:

```xml
<return>
Provide:
1. The modified files
2. Summary of changes
3. Any remaining issues or next steps
</return>
```

## Prompt Template

Use this template when delegating to subagents:

```xml
<delegation>
  <role>[Agent's specialized role]</role>
  
  <context>
    [Background information and why this matters]
  </context>
  
  <task>
    [Clear description of what needs to be done]
  </task>
  
  <constraints>
    [Limitations, requirements, things to avoid]
  </constraints>
  
  <input>
    [Files, data, or context to work with]
  </input>
  
  <output_format>
    [Expected format and structure of response]
  </output_format>
  
  <verification>
    [How to verify the task was completed correctly]
  </verification>
  
  <return>
    [What to return when done]
  </return>
</delegation>
```

## Best Practices Checklist

Before delegating, verify your prompt:

- [ ] **Clear intent**: Would a new employee understand what to do?
- [ ] **Context provided**: Is the "why" explained?
- [ ] **Structured with tags**: Are instructions, context, and input separated?
- [ ] **Examples included**: Are there 3-5 relevant examples for complex tasks?
- [ ] **Role defined**: Does the agent know its specialization?
- [ ] **Success criteria**: Can the agent verify its own work?
- [ ] **Return format**: Is it clear what to output?

## Common Patterns

### For Code Tasks

```xml
<delegation>
  <role>Senior software engineer specializing in [language/framework]</role>
  <task>Implement [specific feature/fix]</task>
  <constraints>
    - Follow existing code patterns
    - No external dependencies without approval
    - Maintain backward compatibility
  </constraints>
  <verification>Run tests and lint</verification>
  <return>Modified files + summary of changes</return>
</delegation>
```

### For Research Tasks

```xml
<delegation>
  <role>Research analyst</role>
  <task>Investigate [topic]</task>
  <output_format>
    - Summary of findings
    - Key sources with quotes
    - Recommendations
  </output_format>
  <verification>Cross-reference multiple sources</verification>
</delegation>
```

### For Analysis Tasks

```xml
<delegation>
  <role>Code reviewer</role>
  <task>Review [files] for [criteria]</task>
  <output_format>
    For each issue found:
    - File and line number
    - Severity (critical/major/minor)
    - Description
    - Suggested fix
  </output_format>
</delegation>
```

## Anti-Patterns to Avoid

1. **Vague instructions**: "Do something good" → Be specific
2. **Negative-only constraints**: "Don't use X" → Say what TO do
3. **Missing context**: No background → Always explain why
4. **No verification**: No success criteria → Define how to check
5. **Unclear output**: No format specified → Define structure
