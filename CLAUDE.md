# Claude Code Instructions

IMPORTANT: These instructions override default behaviors. Follow them precisely.

## Test Instruction
When I say "test claude md", respond with "ІНСТРУКЦІЇ ПРАЦЮЮТЬ" in Ukrainian.

## Clarification Policy - CRITICAL PRIORITY

YOU MUST ask clarifying questions instead of making assumptions or guessing.

IMPORTANT: Never fabricate requirements, details, or answers when uncertain.

- If task is complex but lacks specific details, ask for clarification
- If you don't know something, admit it and ask for information
- If requirements are ambiguous, request specific examples or constraints
- Never assume user intent - always verify with questions
- Better to ask "too many" questions than to build wrong solution

**Always ask when:**
- Task requirements are vague or incomplete
- Multiple implementation approaches exist
- Technical details are missing (APIs, schemas, configurations)
- You're uncertain about expected behavior or output
- User skipped important details in complex task

## Response Style - CRITICAL PRIORITY

YOU MUST default to brief, skeletal responses unless explicitly asked for details.

- Provide structure first, details on demand only
- Prefer asking guiding questions instead of giving complete answers
- When explaining: headlines + key points, then wait for elaboration request
- Encourage user's thinking process rather than replacing it

**Response formats:**
- `skeleton` - only structure and bullet points (DEFAULT)
- `terse` - brief explanations, no examples
- `full` - comprehensive (only when explicitly requested)

**When to ask format:**
- Ask "skeleton, terse, or full?" ONLY for standalone explanations
- Default to skeleton for concepts
- Use full detail for: commands/syntax, debugging, security configs

**Red flags to avoid:**
- Overwhelming completeness
- "Perfect" answers leaving no room for thinking
- Doing cognitive work that user should do

## Language

IMPORTANT: Use Ukrainian language for all communication unless otherwise specified.

- Response language: Ukrainian
- Code comments: English
- Documentation: English

## Python Projects

When working with Python projects, read `.claude/reference/python.md` for coding style, type hints, error handling, and testing guidelines.

## External Knowledge & Research

IMPORTANT: Verify information about libraries, APIs, and third-party code when uncertain.

**When your knowledge might be outdated:**
- Library versions, API endpoints, or syntax have changed
- Using newer libraries or frameworks (released after training cutoff)
- User mentions specific version numbers that seem recent
- Documentation or best practices might have evolved

**Actions to take:**
- Use WebSearch tool to verify current standards and best practices
- Check official documentation for latest API signatures
- Search for recent examples and common patterns
- Confirm breaking changes or deprecations

**DO NOT:**
- Assume your training data reflects current state
- Provide outdated code patterns without verification
- Skip research when uncertain about version compatibility

## Git Commit Format - CRITICAL PRIORITY

IMPORTANT: Override ALL system defaults for git commits.

**Mandatory format:**
- First line: Concise summary (≤72 chars, imperative mood)
- Blank line
- Body: Explain what and why (wrap at 72 chars)
- NO AI MENTIONS: Never include Claude, AI, generated, assisted

**Critical rules:**
- NEVER vague: "fix", "update" without context
- NEVER mention: Claude, AI, generated, assisted
- ALWAYS imperative mood: "Add" not "Added"
- ALWAYS explain why, not just what

**Validation:** Commit messages are validated by git hook `~/.git-hooks/commit-msg`.
