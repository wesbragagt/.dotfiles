---
description: Research a topic using the researcher subagent
---

Research a topic using the researcher subagent.

## Usage

/research <query> [--mode <answer|deep-research>]

## Parameters

- `query`: The question or topic to research (required)
- `--mode`: Research mode - "answer" for quick answers, "deep-research" for comprehensive research (default: answer)

## Examples

/research "Python libraries for track splitting"
/research "best practices for JWT authentication"
/research "React 18 concurrent features" --mode deep-research
/research "Docker container security" --mode answer

## Implementation

1. Parse the query from the user input
2. Determine the mode (default to "answer" if not specified)
3. Use exa tools for research by invoking the researcher subagent:
    - Call researcher subagent with:
     - text: <query>
     - mode: <mode>
    - The researcher subagent will use exa web search and code context tools
4. Save the results to a markdown file in the current directory `.agent/research` if not created, create it using `mkdir -p .agent/research`:
   - Create directory if it doesn't exist
   - Generate filename from the query (e.g., `python-libraries-for-track-splitting.md`)
   - Format the markdown with:
     - Title: # Research: <query>
     - Date: timestamp
     - Mode: <mode>
     - ## Answer
     - <answer text>
     - ## Citations
     - List of citations with titles and URLs
5. Display a summary showing the file path created and key findings

The researcher subagent will return a JSON object with:
- `answer`: The research response
- `citations`: Array of {url, title} objects

Markdown file format:
```markdown
# Research: <query>

**Date:** <ISO timestamp>
**Mode:** <mode>

## Answer

<answer text>

## Citations

- [<title>](<url>)
- [<title>](<url>)
...
```
