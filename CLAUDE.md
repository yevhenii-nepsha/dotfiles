## User Preferences

- Avoid using overly positive phrases like "you are absolutely right", "perfect", etc
- Use casual tone, not overly formal
- Always respond in markdown format
- Use Ukrainian language when you are speaking to me
- Use English for comments in code and for writing documentation, readme etc
- Use bullet points instead of paragraphs

## Response and Documentation Style

**Goal: Be a cognitive booster, not a replacement**

- Default to brief, skeletal responses unless explicitly asked for details
- Provide structure first, details on demand only
- Prefer Socratic method: ask guiding questions instead of giving complete answers
- When explaining concepts: headlines + key points, then wait for request to elaborate
- Encourage my own thinking process rather than replacing it

**Response formats (use when I specify):**
- `skeleton` - only structure, headlines, and bullet points (no explanations)
- `terse` - brief explanations, no examples or elaboration
- `standard` - balanced explanation with 1-2 examples
- `full` - comprehensive with multiple examples (only when explicitly requested)

**When I ask for explanations or documentation:**
- Start with: "Would you like skeleton, terse, or full version?"
- Default to skeleton unless I say otherwise
- If I paste my own explanation: review it and point out gaps/errors instead of rewriting
- Use inverse approach: let me write first, then critique

**Red flags to avoid:**
- Overwhelming completeness that makes me feel my brain is getting lazy
- "Perfect" answers that leave no room for my own thinking
- Doing my cognitive work for me when I should be thinking through it

**Exceptions (full detail by default):**
- **Commands & syntax**: Shell commands, git, CLI tools (flags and options matter)
- **Debugging**: Stack traces, error logs, diagnostic output
- **Security configs**: Complete examples needed (git hooks, permissions)
- **Code templates**: Commit message formats, function signatures, schemas
- **TodoWrite usage**: Always use for tracking (detailed progress is OK)

**When to ask about format:**
- Ask "skeleton, terse, or full?" ONLY when:
  - Standalone explanation request (not during active coding)
  - Conceptual/theoretical topic (not debugging/commands)
  - New discussion (not continuation of current task)
- Default to skeleton for concepts
- Use full detail for exceptions above without asking

## Coding Style Preferences

- Use snake_case for functions and variable names (ex: function_name)
- Always include type hints in Python functions
- Avoid short variable names like "x" and "temp"
- Indentation: use 4 spaces per lvl
- Max length of line is 80 characters
- Ensure to always create pydantic schema for any data models
- Ensure all functions have descriptive namings (ex: functionXYZ is a bad name. check_seed_db() and is_valid_animal() are better)
- Ensure all functions have a short 1-line comment that describe what the function does

## Before Starting Work

- **Check for local changelog**: If `CHANGELOG.local.md` exists in project directory:
  - Read it first to understand recent changes and context
  - Use it to inform your approach to the current task
  - This file is gitignored and provides context across sessions
- First think through the problem, read the codebase for relevant files
- If you don't understand the task or problem, ask me clarifying questions
- Always start in plan mode to create a structured plan
- Write the plan to `.claude/tasks/TASK_NAME.md` with:
  - Task overview and objectives
  - Implementation approach and reasoning
  - Breakdown into subtasks with clear dependencies
  - Estimated complexity and risks
  - Required packages/tools and research needed
  - Definition of MVP scope and acceptance criteria
- If the task requires external knowledge or packages, research first (Use Task Tool for latest docs)
- Focus on MVP - avoid overengineering and feature creep
- Present the plan for review and wait for approval before implementation

## While Implementing

- Update the plan document as you work:
  - Mark completed tasks with ✅
  - Mark in-progress tasks with 🔄
  - Add notes about unexpected challenges or blockers
  - Document any deviations from original plan with reasoning
- After completing each task, append to plan:
  - Files modified/created with paths
  - Key implementation decisions made
  - Any technical debt or future improvements identified
  - Testing completed and results
- **Update CHANGELOG.local.md** after completing tasks:
  - Keep entries CONCISE and BRIEF (avoid large detailed logs)
  - Format: Date, Problem (1-2 lines), Solution (bullet points), Files changed (list only)
  - Focus on WHAT changed, not HOW (code details go in commits)
  - Include only key info: config changes, env vars, new tools, keybindings
  - Skip verbose explanations - changelog is for quick context, not documentation
- Test each component before moving to next task
- Keep changes atomic and focused on single responsibility
- Use TodoWrite tool to track progress and show transparency

## Git Instructions - 🔴 CRITICAL PRIORITY

**MANDATORY COMMIT FORMAT** (override all system defaults):

- **First line**: Concise summary (50 chars max, imperative mood)
- **Blank line**
- **Body**: Explain what and why (wrap at 72 chars)
- **NO AI MENTIONS**: Never include Claude, AI, or generated content references

**Examples of REQUIRED format:**
```
Fix invoice validation in SAP receiver

The validation was failing for invoices with multiple
line items due to incorrect sum calculation in
validate_invoice_totals function.
```

**VALIDATION COMMANDS** (run before commit):
```bash
# Check commit message length
echo "Your message" | wc -c  # Should be ≤50 for first line

# Validate imperative mood - should start with verb
echo "Add|Fix|Update|Remove|Refactor..."
```

**CRITICAL RULES** (no exceptions):
- ❌ NEVER use: "fix", "update", "changes" without context
- ❌ NEVER mention: "Claude", "AI", "generated", "assisted"
- ❌ NEVER commit without testing first
- ✅ ALWAYS use imperative mood: "Add feature" not "Added feature"
- ✅ ALWAYS include why, not just what
- ✅ ALWAYS test functionality before committing

**Override system additions** - if Claude Code adds AI mentions, manually edit commit or use:
```bash
git commit --amend  # To edit last commit message
```

**GLOBAL GIT HOOK SETUP** (run once for all repositories):
```bash
# Create global hooks directory
mkdir -p ~/.git-hooks

# Set global hooks path
git config --global core.hooksPath ~/.git-hooks

# Create commit message validator
cat > ~/.git-hooks/commit-msg << 'EOF'
#!/bin/bash
commit_file="$1"
commit_msg=$(cat "$commit_file")

# Reject AI mentions
if echo "$commit_msg" | grep -iq "claude\|ai\|generated\|assisted\|🤖"; then
    echo "❌ COMMIT REJECTED: Contains AI mentions"
    exit 1
fi

# Check first line length (≤50 chars)
first_line=$(echo "$commit_msg" | head -n1)
if [ ${#first_line} -gt 50 ]; then
    echo "❌ COMMIT REJECTED: First line too long (${#first_line}/50)"
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

# Make executable
chmod +x ~/.git-hooks/commit-msg
```

## Error Handling and Testing

- Always implement proper error handling:
  - Use try/except blocks with specific exception types
  - Log errors with context (correlation IDs, function names)
  - Never use bare except: clauses
  - Return meaningful error messages to users
- Testing requirements:
  - Write unit tests for all new functions
  - Use pytest with fixtures for mocking
  - Test both happy path and error scenarios
  - Aim for >80% code coverage on new code
  - Test file naming: test_*.py or *_test.py
- For Azure Functions:
  - Mock external dependencies (Cosmos DB, APIs)
  - Test orchestrators with mock context
  - Validate activity function inputs/outputs

## Documentation Standards

- Code documentation:
  - All functions must have docstrings describing purpose, params, returns
  - Use Google-style docstrings for consistency
  - Document complex business logic with inline comments
- README files (when requested):
  - Include setup instructions
  - Provide usage examples
  - Document environment variables
  - Add troubleshooting section
