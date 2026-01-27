# Python Development Guidelines

IMPORTANT: Read this file when working with Python projects.

## Coding Style

- Use snake_case for functions and variable names
  - Good: `calculate_total()`, `user_name`
  - Bad: `calculateTotal()`, `userName`
- Always include type hints in function signatures
  ```python
  def process_data(items: list[dict], limit: int = 10) -> dict:
      """Process data items with optional limit."""
      pass
  ```
- Avoid short variable names like `x`, `temp`, `i` (except in comprehensions)
- Indentation: 4 spaces per level (never tabs)
- Max line length: 80 characters
- Create pydantic schemas for all data models
  ```python
  from pydantic import BaseModel

  class User(BaseModel):
      name: str
      email: str
      age: int
  ```
- Descriptive function names
  - Good: `check_seed_db()`, `is_valid_animal()`
  - Bad: `functionXYZ()`, `doStuff()`
- All functions have 1-line docstring describing purpose

## Error Handling

- Use try/except blocks with specific exception types
  ```python
  try:
      result = process_data(items)
  except ValueError as e:
      logger.error(f"Invalid data: {e}")
  except KeyError as e:
      logger.error(f"Missing key: {e}")
  ```
- Log errors with context (correlation IDs, function names)
- Never use bare `except:` clauses (always specify exception type)
- Return meaningful error messages to users

## Testing Requirements

- Write unit tests for all new functions using pytest
- Use fixtures for mocking and test setup
  ```python
  @pytest.fixture
  def sample_data():
      return {"id": 1, "name": "test"}

  def test_process_data(sample_data):
      result = process_data(sample_data)
      assert result["status"] == "success"
  ```
- Test both happy path and error scenarios
- Aim for >80% code coverage on new code
- Test file naming: `test_*.py` or `*_test.py`

## Azure Functions Specific

When working with Azure Functions:
- Mock external dependencies (Cosmos DB, HTTP APIs, Service Bus)
- Test orchestrators with mock DurableOrchestrationContext
- Validate activity function inputs/outputs
- Test async functions properly with pytest-asyncio

## Documentation

- All functions must have docstrings (Google-style)
  ```python
  def calculate_total(items: list[dict], tax_rate: float = 0.1) -> float:
      """Calculate total price including tax.

      Args:
          items: List of item dictionaries with 'price' key
          tax_rate: Tax rate as decimal (default: 0.1 for 10%)

      Returns:
          Total price including tax

      Raises:
          ValueError: If items list is empty or tax_rate is negative
      """
      pass
  ```
- Document complex business logic with inline comments
- Use type hints instead of documenting types in docstrings
