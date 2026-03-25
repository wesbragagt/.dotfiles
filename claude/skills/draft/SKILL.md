---
name: draft
description: Draft and write any document to the current directory. Use this skill whenever the user wants to draft, write, create, or brainstorm a document, note, spec, RFC, README, ADR, report, blog post, or any written artifact. Trigger on phrases like "/draft", "draft a doc", "help me write", "let's brainstorm", "I want to create a document", "write a spec for", "draft something about", "help me document", "I need to write up", "create a note about", or any time the user is starting something that will become a written document. Also trigger on "/draft --auto" or "/draft <notes>" when the user passes raw notes/content directly and wants a polished document without a Q&A session. Trigger even for vague writing requests — if the user is in a docs or notes context, default to this skill.
---

# Draft

Help the user produce a polished written document and save it as a file in the current working directory.

## Flags

- `--auto` / `-a` — skip Q&A, go straight to drafting from raw notes or topic
- `--dir <path>` / `-d <path>` — write the file to the specified directory instead of the current working directory

## Modes

### Interactive mode (default)

When the user invokes `/draft` with a topic but no detailed notes, interview them briefly before writing. Keep it concise — 3-5 targeted questions is enough. Ask about:

- The document type and intended filename (if not clear from context)
- The audience and purpose
- Key points or sections they want covered
- Any tone or style preferences (formal, casual, technical, etc.)

Once you have enough context, write the document and save it. Don't ask unnecessary questions — if you can reasonably infer something, do so.

### Auto mode (`/draft --auto` or `/draft <raw notes>`)

When the user passes raw notes or uses `--auto`, skip the Q&A and go straight to drafting. Infer the document type, structure, and filename from the content. Produce a polished version of what they gave you.

## Writing the file

- Determine an appropriate filename based on the document type and topic (e.g., `README.md`, `architecture-decision.md`, `blog-post-draft.md`)
- Write the file to the **current working directory**, or to `--dir <path>` if provided
- Use Markdown unless the content clearly calls for something else (e.g., `.txt` for plain notes)
- After writing, tell the user the filename and full path

## Document quality

Adapt the structure and tone to the document type:

- **READMEs**: clear purpose statement, usage, examples
- **ADRs**: context, decision, consequences
- **Specs/RFCs**: problem statement, proposed solution, alternatives considered
- **Blog posts**: engaging opening, narrative flow, clear takeaway
- **Notes/scratch docs**: whatever structure serves the content best

Write a complete, useful draft — not a skeleton with placeholder sections. If you're missing critical information, ask one targeted question rather than producing something hollow.
