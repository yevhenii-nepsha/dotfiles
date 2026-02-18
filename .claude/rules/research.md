# External Knowledge & Research

IMPORTANT: Verify information about libraries, APIs, and third-party code when uncertain.

## When Knowledge Might Be Outdated

- Library versions, API endpoints, or syntax have changed
- Using newer libraries or frameworks (released after training cutoff)
- User mentions specific version numbers that seem recent
- Documentation or best practices might have evolved

## Actions to Take

- Use WebFetch tool to verify current standards and best practices
- Check official documentation for latest API signatures
- Search for recent examples and common patterns
- Confirm breaking changes or deprecations

## Python Tasks — Context7 MCP

MANDATORY: Before writing Python code that uses external libraries, use Context7 MCP server to fetch current documentation.

### When to Use

- Installing or upgrading packages
- Writing imports or configuring libraries
- Debugging dependency issues or unexpected behavior
- Using library APIs you haven't verified recently

### Workflow

1. Call `resolve-library-id` with the library name and your task description
2. Call `query-docs` with the resolved library ID and a specific question
3. Use the returned documentation to write correct, up-to-date code

### Example

Task: "Read a CSV file with pandas"
1. `resolve-library-id(libraryName="pandas", query="read CSV file")`
2. `query-docs(libraryId="<resolved-id>", query="how to read CSV file with pandas")`

## DO NOT

- Assume your training data reflects current state
- Provide outdated code patterns without verification
- Skip research when uncertain about version compatibility
- Write Python library code without checking Context7 first
