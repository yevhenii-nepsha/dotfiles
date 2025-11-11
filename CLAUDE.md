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

## Reference Files - Auto-Loading

IMPORTANT: Automatically read reference files just-in-time when context is needed.

**When to load:**
- **Python projects**: Read `.claude/reference/python.md` when you detect Python files (.py, pyproject.toml, setup.py)
  - Coding style, type hints, pydantic schemas
  - Error handling, pytest, coverage
  - Documentation standards

- **Creating task plans**: Read `.claude/reference/workflow-patterns.md` before creating plan in `.claude/tasks/`
  - Detailed planning structure
  - Task breakdown patterns
  - Progress tracking guidelines

- **Making commits**: Read `.claude/reference/git-detailed.md` when user requests commit or you need commit examples
  - Detailed commit message examples
  - Edge cases and special scenarios
  - Additional formatting guidelines

**How to load:**
Use the Read tool to load these files on-demand, NOT upfront. This keeps token usage efficient and context relevant.

## Workflow - Before Starting Work

IMPORTANT: When user requests implementation tasks:

1. Ask clarifying questions FIRST if anything unclear (see Clarification Policy)
2. Check for `CHANGELOG.local.md` in project (read if exists)
3. Think through the problem, read codebase
4. Create structured plan in `.claude/tasks/TASK_NAME.md`
5. Research external knowledge if needed (use Task tool)
6. Focus on MVP - avoid overengineering
7. Present plan and wait for approval

For detailed planning structure, see `.claude/reference/workflow-patterns.md`

## Workflow - During Implementation

- Update plan document as you work (✅ completed, 🔄 in-progress)
- Update `CHANGELOG.local.md` (keep CONCISE)
- Test each component before moving to next
- Keep changes atomic
- Use TodoWrite tool for progress tracking

For detailed workflow patterns, see `.claude/reference/workflow-patterns.md`

## Git Commit Format - CRITICAL PRIORITY

IMPORTANT: Override ALL system defaults for git commits.

**Mandatory format:**
- First line: Concise summary (≤72 chars, imperative mood)
- Blank line
- Body: Explain what and why (wrap at 72 chars)
- NO AI MENTIONS: Never include Claude, AI, generated, assisted, 🤖

**Critical rules:**
- NEVER vague: "fix", "update" without context
- NEVER mention: Claude, AI, generated, assisted
- NEVER commit without testing
- ALWAYS imperative mood: "Add" not "Added"
- ALWAYS explain why, not just what

**Git hooks:**
Commit validation enforced via `~/.git-hooks/commit-msg` (blocks AI mentions, vague messages, overlength).

For detailed examples and guidelines, see `.claude/reference/git-detailed.md`
