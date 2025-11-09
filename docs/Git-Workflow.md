# Git Workflow Guide

This guide outlines the commit message standards and workflow practices for maintaining clean, meaningful Git history.

## Commit Message Format

All commit messages must follow this structure:

```
<Subject line: max 72 characters>

<Blank line>

<Body: detailed explanation wrapped at 72 characters>
```

### Subject Line

- **Maximum 72 characters** (GitHub displays fully up to 72)
- **Imperative mood** (e.g., "Add feature" not "Added feature")
- **Be specific** - avoid vague terms like "fix", "update", "changes" alone
- **No period** at the end

### Body

- **Wrap at 72 characters** per line
- **Explain what and why**, not how
- Focus on the reasoning behind the change
- Include context that isn't obvious from the code

### Example

```
Fix invoice validation in SAP receiver

The validation was failing for invoices with multiple
line items due to incorrect sum calculation in
validate_invoice_totals function.
```

## Commit Guidelines

### Always Do

- ✅ Use imperative mood: "Add feature" not "Added feature"
- ✅ Be specific about what changed
- ✅ Explain why the change was needed
- ✅ Test functionality before committing
- ✅ Keep commits atomic and focused on single responsibility

### Never Do

- ❌ Use vague messages: "fix", "update", "changes" without context
- ❌ Commit without testing first
- ❌ Include tool/AI mentions in commit messages
- ❌ Use past tense: "Fixed bug" (use "Fix bug" instead)
- ❌ Commit multiple unrelated changes together

## Validation Commands

Before committing, validate your commit message:

```bash
# Check commit message length (first line should be ≤72 chars)
echo "Your commit message" | wc -c

# Verify imperative mood - should start with action verb
echo "Add|Fix|Update|Remove|Refactor|Improve|..."
```

## Git Hooks

To automatically enforce commit message standards, set up global Git hooks:

### One-Time Setup

Run these commands once to set up validation for all repositories:

```bash
# Create global hooks directory
mkdir -p ~/.git-hooks

# Configure Git to use global hooks
git config --global core.hooksPath ~/.git-hooks

# Create commit message validator
cat > ~/.git-hooks/commit-msg << 'EOF'
#!/bin/bash
commit_file="$1"
commit_msg=$(cat "$commit_file")

# Reject AI/tool mentions
if echo "$commit_msg" | grep -iq "claude\|ai\|generated\|assisted\|🤖"; then
    echo "❌ COMMIT REJECTED: Contains AI/tool mentions"
    exit 1
fi

# Check first line length (≤72 chars)
first_line=$(echo "$commit_msg" | head -n1)
if [ ${#first_line} -gt 72 ]; then
    echo "❌ COMMIT REJECTED: First line too long (${#first_line}/72)"
    exit 1
fi

# Check for vague messages
if echo "$first_line" | grep -E "^(fix|update|change|modify)$" > /dev/null; then
    echo "❌ COMMIT REJECTED: Too vague - be specific"
    exit 1
fi

echo "✅ Commit message validated"
exit 0
EOF

# Make the hook executable
chmod +x ~/.git-hooks/commit-msg
```

### What the Hook Validates

The commit-msg hook automatically checks:

1. **No AI/tool mentions** - Keeps commit history professional
2. **First line ≤72 characters** - Ensures readability in Git logs
3. **No vague messages** - Prevents meaningless commits like "fix" or "update"

### Amending Commit Messages

If you need to fix a commit message after committing:

```bash
# Edit the last commit message
git commit --amend

# Or if using AI tools that add unwanted text
git commit --amend -m "Your corrected message

Detailed explanation of the change and why it was made."
```

## Examples

### Good Commit Messages

```
Add user authentication middleware

Implements JWT-based authentication for API endpoints.
Required to secure user data access and prevent
unauthorized API usage.
```

```
Fix memory leak in file upload handler

The handler wasn't closing file streams properly,
causing memory to accumulate over time. Added explicit
close() calls in finally blocks.
```

```
Refactor database connection pooling

Moved from manual connection management to connection
pooling library. Improves performance under high load
and reduces database connection overhead.
```

### Bad Commit Messages

```
❌ fix
❌ update
❌ changes
❌ Fixed the bug
❌ Updated files
❌ Made changes to the code
❌ Fix invoice validation (Generated with AI)
```

### Why These Are Bad

- Too vague - doesn't explain what was fixed/updated
- Past tense instead of imperative mood
- Contains tool/AI mentions
- Doesn't explain the reasoning or context

## Quick Reference

```bash
# Good commit message structure
git commit -m "Add feature X" -m "Detailed explanation of why..."

# Check your last commit message
git log -1 --pretty=%B

# Amend if needed
git commit --amend

# View commit history with proper formatting
git log --oneline --graph --decorate

# Stage and commit in one go (only for tracked files)
git commit -am "Your message"
```

## Best Practices

1. **Commit often** - Small, focused commits are better than large ones
2. **Test before committing** - Never commit broken code
3. **Write for future you** - Explain why, not what (code shows what)
4. **Keep it atomic** - One logical change per commit
5. **Use branches** - Feature branches keep main/master clean

## Resources

- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/) - Comprehensive guide
- [Conventional Commits](https://www.conventionalcommits.org/) - Structured commit format
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project) - Official Git documentation
