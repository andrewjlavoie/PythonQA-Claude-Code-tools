---
name: refactor
description: Analyze and refactor Python code — complexity, modernization, dead code, simplification
user_invocable: true
---

Analyze or refactor Python code. Parse the argument to determine the action:

- "complexity <file>": Analyze code complexity:
  1. Run `radon cc <file> -a -s` (cyclomatic complexity) and `radon mi <file> -s` (maintainability)
  2. For any function rated C or worse, read the function source
  3. Suggest specific refactoring: extract method, simplify conditionals, replace nested ifs with early returns, use dict dispatch instead of long if/elif chains

- "modernize <file>": Modernize Python syntax:
  1. Run `ruff check <file> --select UP --preview` to preview modernization opportunities
  2. Apply with `ruff check <file> --select UP --fix`
  3. Report what was changed

- "dead": Find dead code:
  1. Run `vulture {{SRC_DIR}} --min-confidence 80`
  2. For each finding, verify it's truly dead — check for: dynamic access via `getattr`, `__all__` exports, framework magic methods (Django/FastAPI/click decorators), test fixtures
  3. Only suggest removing code confirmed as genuinely unused

- "simplify <file>": Simplify code:
  1. Run `ruff check <file> --select SIM` to find simplification opportunities
  2. Apply with `ruff check <file> --select SIM --fix`
  3. Review the result for further simplifications ruff missed (e.g., collapsible context managers, unnecessary intermediate variables)

- "dry <file>": Find repeated patterns:
  1. Read the file and identify duplicate code blocks, similar function bodies, repeated error handling patterns
  2. Suggest DRY improvements: extract shared logic into helper functions, use decorators for cross-cutting concerns, use base classes for shared method patterns
  3. Only suggest extraction when the pattern appears 3+ times or the duplication is substantial

- "split <file>": Suggest module splits:
  1. Read the file and count lines
  2. If >300 lines, identify logical groupings (related classes, related functions, constants/config)
  3. Propose a split into focused modules with a clear import structure
  4. Show what the new `__init__.py` re-exports would look like

After any code changes, run `ruff check {{SRC_DIR}} && pyright {{SRC_DIR}}` to verify nothing broke.
