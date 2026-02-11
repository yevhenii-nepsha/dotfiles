# Knowledge Base Workflow

IMPORTANT: This workflow is MANDATORY for every session. Never skip these steps.

## At Session Start

YOU MUST check `.claude/knowledge/` for existing notes relevant to the current task.
Read all relevant knowledge files before starting work. This restores context from
previous sessions and prevents rediscovering known issues or repeating decisions.

## After Task Completion or Commit

YOU MUST create or update the relevant knowledge file in `.claude/knowledge/`.

### What to Record

- Architecture decisions and their reasoning
- Non-obvious workarounds and gotchas discovered
- Tool/API quirks that caused problems
- Configuration details that took effort to figure out
- Compilation or build steps for generated artifacts

### File Naming

Use descriptive names matching the feature or topic: `sketchybar.md`, `neovim.md`, `docker.md`.

## DO NOT

- Skip reading knowledge base at session start
- Forget to update knowledge base after completing work
- Record obvious or easily re-discoverable information
- Wait until end of session to update — update after each task/commit
