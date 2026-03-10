---
name: notebooklm
description: Interact with Google NotebookLM programmatically — create notebooks, add sources, chat, and generate artifacts (audio, quizzes, mind maps, etc.) using the notebooklm-py library.
version: 1.0.0
---

# NotebookLM Skill

Automate Google NotebookLM using the unofficial `notebooklm-py` Python library. Write and run Python scripts with the async `NotebookLMClient` to manage notebooks, sources, chat, and content generation.

## Prerequisites

**Install:**
```bash
pip install "notebooklm-py[browser]"
playwright install chromium
```

**One-time login (opens browser for Google OAuth):**
```bash
~/notebooklm/.venv/bin/notebooklm login
```

Credentials are stored at `~/.notebooklm/storage_state.json`.

**Verify auth:**
```bash
~/notebooklm/.venv/bin/notebooklm auth check --test
```

## Client Setup

All operations use the async `NotebookLMClient` as a context manager:

```python
import asyncio
from notebooklm import NotebookLMClient

async def main():
    async with await NotebookLMClient.from_storage() as client:
        # your operations here
        pass

asyncio.run(main())
```

## Common Operations

### Notebooks

```python
# List all notebooks
notebooks = await client.notebooks.list()
for nb in notebooks:
    print(nb.id, nb.title)

# Create notebook
nb = await client.notebooks.create("My Research")

# Rename
await client.notebooks.rename(nb.id, "New Title")

# Delete
await client.notebooks.delete(nb.id)
```

### Sources

```python
# Add URL (wait=True blocks until processing completes)
await client.sources.add_url(nb.id, "https://example.com/article", wait=True)

# Add local file (PDF, Word, audio, video, image)
await client.sources.add_file(nb.id, "./paper.pdf")

# Add plain text
await client.sources.add_text(nb.id, "My Notes", "Content here...")

# Get full text of a source
text = await client.sources.get_fulltext(nb.id, source_id)

# Rate limiting: add delay between multiple sources
import asyncio
for url in urls:
    await client.sources.add_url(nb.id, url, wait=True)
    await asyncio.sleep(2)
```

### Chat

```python
# Ask a question
result = await client.chat.ask(nb.id, "Summarize the key findings")
print(result.answer)

# Get conversation history
history = await client.chat.history(nb.id)
```

### Artifact Generation

All generation is async — start generation, wait for completion, then download.

```python
# Audio podcast (MP3)
status = await client.artifacts.generate_audio(nb.id, instructions="Make it conversational")
await client.artifacts.wait_for_completion(nb.id, status.task_id)
await client.artifacts.download_audio(nb.id, "podcast.mp3")

# Quiz
status = await client.artifacts.generate_quiz(nb.id, difficulty="medium")
await client.artifacts.wait_for_completion(nb.id, status.task_id)
await client.artifacts.download_quiz(nb.id, "quiz.json", output_format="json")
# output_format options: "json", "markdown", "html"

# Flashcards
status = await client.artifacts.generate_flashcards(nb.id)
await client.artifacts.wait_for_completion(nb.id, status.task_id)
# download_flashcards(nb.id, path, output_format="json")

# Mind map
status = await client.artifacts.generate_mind_map(nb.id)
await client.artifacts.wait_for_completion(nb.id, status.task_id)
await client.artifacts.download_mind_map(nb.id, "mindmap.json")

# Slide deck (PDF or PPTX)
status = await client.artifacts.generate_slide_deck(nb.id)
await client.artifacts.wait_for_completion(nb.id, status.task_id)

# Infographic (PNG)
status = await client.artifacts.generate_infographic(nb.id)
await client.artifacts.wait_for_completion(nb.id, status.task_id)

# Report (Markdown)
status = await client.artifacts.generate_report(nb.id)
await client.artifacts.wait_for_completion(nb.id, status.task_id)

# Data table (CSV)
status = await client.artifacts.generate_data_table(nb.id, prompt="Extract all statistics")
await client.artifacts.wait_for_completion(nb.id, status.task_id)

# Video overview (MP4)
status = await client.artifacts.generate_video(nb.id, style="minimalist")
await client.artifacts.wait_for_completion(nb.id, status.task_id)
```

### Sharing

```python
# Get sharing status
status = await client.sharing.get_status(nb.id)

# Make notebook public/private
await client.sharing.set_public(nb.id, True)

# Add collaborator
await client.sharing.add_user(nb.id, "user@example.com", permission="viewer")

# Remove collaborator
await client.sharing.remove_user(nb.id, "user@example.com")
```

## Complete Example: Research Pipeline

```python
import asyncio
from notebooklm import NotebookLMClient

async def research_pipeline(topic: str, urls: list[str], output_dir: str = "."):
    async with await NotebookLMClient.from_storage() as client:
        # Create notebook
        nb = await client.notebooks.create(f"Research: {topic}")
        print(f"Created notebook: {nb.id}")

        # Add sources with rate limiting
        for url in urls:
            print(f"Adding: {url}")
            await client.sources.add_url(nb.id, url, wait=True)
            await asyncio.sleep(2)

        # Ask initial questions
        summary = await client.chat.ask(nb.id, f"Summarize what these sources say about {topic}")
        print("\n=== Summary ===")
        print(summary.answer)

        key_points = await client.chat.ask(nb.id, "What are the 5 most important insights?")
        print("\n=== Key Points ===")
        print(key_points.answer)

        # Generate audio podcast
        print("\nGenerating podcast...")
        status = await client.artifacts.generate_audio(
            nb.id,
            instructions=f"Discuss {topic} in an engaging way"
        )
        await client.artifacts.wait_for_completion(nb.id, status.task_id)
        await client.artifacts.download_audio(nb.id, f"{output_dir}/{topic}_podcast.mp3")

        # Generate quiz
        print("Generating quiz...")
        status = await client.artifacts.generate_quiz(nb.id)
        await client.artifacts.wait_for_completion(nb.id, status.task_id)
        await client.artifacts.download_quiz(nb.id, f"{output_dir}/{topic}_quiz.json", output_format="json")

        print(f"\nDone! Notebook ID: {nb.id}")
        return nb.id

asyncio.run(research_pipeline(
    topic="quantum computing",
    urls=["https://example.com/article1", "https://example.com/article2"],
    output_dir="./output"
))
```

## Environment Variables (CI/CD)

```bash
# Inject auth JSON directly (no file needed)
export NOTEBOOKLM_AUTH_JSON='{"cookies": [...]}'

# Override storage file path
export NOTEBOOKLM_STORAGE_PATH="/custom/path/storage_state.json"

# Override base directory
export NOTEBOOKLM_HOME="/custom/notebooklm"
```

## Troubleshooting

**Auth expired:** Re-run `notebooklm login` (sessions expire every few weeks).

**Rate limiting:** Add `await asyncio.sleep(2)` between bulk source additions.

**CSRF token errors:** Call `await client.refresh_auth()` manually, or they auto-refresh.

**Diagnose:** `~/notebooklm/.venv/bin/notebooklm auth check --test`

## How to Use This Skill

When asked to interact with NotebookLM, write a Python script using the patterns above, save it to a temp file, and run it with `~/notebooklm/.venv/bin/python`. Always use `async with await NotebookLMClient.from_storage() as client:` and `asyncio.run(main())`. For one-off tasks, write inline scripts rather than full modules.
