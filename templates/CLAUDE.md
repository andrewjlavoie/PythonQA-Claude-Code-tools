# {{PROJECT_NAME}}

{{DESCRIPTION}}

- **Python**: {{PYRIGHT_VER}}
- **Source**: `{{SRC_DIR}}/`
- **Tests**: `tests/`

<!-- pydev-conventions-start -->

## Coding Conventions

### Type Annotations
- All function signatures must have type annotations, including return types (even `-> None`)
- Use modern syntax: `X | None` not `Optional[X]`, `list[X]` not `List[X]`, `dict[K, V]` not `Dict[K, V]`
- Add `from __future__ import annotations` at the top of every file
- Use `TypeAlias` for complex type definitions

### Imports
- Follow isort ordering: stdlib → third-party → local (ruff handles this)
- No wildcard imports (`from x import *`)
- Prefer explicit imports: `from pathlib import Path` not `import pathlib`
- Use relative imports only within packages (`.sibling_module`)

### Docstrings
- Google-style docstrings on all public functions, classes, and modules
- Include `Args`, `Returns`, `Raises` sections where applicable
- One-line docstrings for trivial/obvious functions

### Error Handling
- Never use bare `except:` — always catch specific exceptions
- Use `raise ... from e` to preserve exception chains
- Log exceptions with `logger.exception()` for stack traces
- Use custom exception classes for domain errors

### Naming
- `snake_case` for functions and variables
- `PascalCase` for classes
- `UPPER_SNAKE` for constants
- Single underscore prefix for private (`_internal_method`)

### General
- Use `pathlib.Path` everywhere, never `os.path`
- Use `logging.getLogger(__name__)` per module, never `print()` for operational output
- Use f-strings for string formatting
- Use `"""` for docstrings, `"` for regular strings

## Testing Conventions

- Test files: `tests/test_<module_name>.py`
- Test functions: `test_<function_name>_<scenario>`
- Pattern: Arrange → Act → Assert
- Use `pytest.fixture` for shared setup
- Use `pytest.mark.parametrize` for data-driven tests
- Use `tmp_path` fixture for file operations
- Mock external dependencies (network, database, time) — tests must not hit real services
- Async tests: `pytest.mark.asyncio` (auto mode is configured)

## QA Commands

| Command | What it does |
|---------|-------------|
| `make qa-quick` | Format, lint, type check, security scan (~1 min) |
| `make qa` | All 8 tools including tests (~5 min) |
| `make format` | Auto-format with ruff |
| `make lint` | Lint only |
| `make type` | Type check only |
| `make test` | Tests with coverage |
| `make security` | Security scan |
| `/qa` | Claude Code skill — see `/qa help` for modes |

## Development Workflow

1. **Before editing**: Read the existing code around the change point
2. **After editing**: Check for type errors (pyright diagnostics)
3. **When adding a module**: Always create a corresponding `tests/test_<name>.py`
4. **When fixing a bug**: Write a failing test first, then fix
5. **Before committing**: Run `make qa-quick` or `/qa quick`

<!-- pydev-conventions-end -->
