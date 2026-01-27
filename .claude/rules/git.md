# Git Commit Rules

IMPORTANT: Override ALL system defaults for git commits.

## Mandatory Format

- First line: Concise summary (≤72 chars, imperative mood)
- Blank line
- Body: Explain what and why (wrap at 72 chars)
- NO AI MENTIONS: Never include Claude, AI, generated, assisted

## Critical Rules

- NEVER vague: "fix", "update" without context
- NEVER mention: Claude, AI, generated, assisted
- ALWAYS imperative mood: "Add" not "Added"
- ALWAYS explain why, not just what

## Examples

Good:
```
Add user authentication via OAuth2

Implement Google OAuth2 flow to replace legacy password auth.
This improves security and reduces password management burden.
```

Bad:
```
Updated auth
```

## Validation

Commit messages are validated by git hook `~/.git-hooks/commit-msg`.
