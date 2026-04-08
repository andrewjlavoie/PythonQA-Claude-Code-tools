---
name: scaffold
description: Scaffold Python project components — modules, packages, CLI entry points, models, config
user_invocable: true
---

Scaffold new project components. Parse the argument to determine the action:

- "module <name>": Create a new module:
  1. Create `{{SRC_DIR}}/<name>.py` with:
     - `from __future__ import annotations` 
     - Module docstring describing purpose
     - `import logging` with `logger = logging.getLogger(__name__)`
     - A placeholder class or function based on the name
     - Type annotations on all signatures
  2. Create `tests/test_<name>.py` with a basic smoke test
  3. Check existing modules for patterns to follow (imports, structure)

- "package <name>": Create a new package:
  1. Create `{{SRC_DIR}}/<name>/__init__.py` with `__all__` and public re-exports
  2. Create `{{SRC_DIR}}/<name>/core.py` with the primary logic placeholder
  3. Create `tests/test_<name>.py` with a basic test

- "cli <name>": Create a CLI entry point:
  1. Check if `click` is installed; if not, use `argparse`
  2. Create `{{SRC_DIR}}/cli/<name>.py` (or `{{SRC_DIR}}/cli.py` if only one CLI) with:
     - Argument parsing with help text
     - A `main()` function as the entry point
     - Logging setup
     - Error handling that prints user-friendly messages
  3. Add `console_scripts` entry to `pyproject.toml` under `[project.scripts]`

- "model <name>": Create a data model:
  1. Check if `pydantic` is installed; if so, create a Pydantic BaseModel; otherwise use `dataclasses`
  2. Create `{{SRC_DIR}}/models/<name>.py` (or `{{SRC_DIR}}/models.py` if models dir doesn't exist) with:
     - The model class with common fields and type annotations
     - Validation logic (Pydantic validators or `__post_init__`)
     - A `to_dict()` / serialization method if using dataclasses
  3. Create a corresponding test file

- "config": Create project configuration handling:
  1. Create `{{SRC_DIR}}/config.py` with:
     - Environment variable loading (pydantic-settings if available, else `os.environ`)
     - Sensible defaults for common settings (debug, log_level, database_url)
     - A singleton `settings` instance
  2. Create `.env.example` with all config vars documented
  3. Add `.env` to `.gitignore` if not already present

All scaffolded code must include type annotations, docstrings, and follow existing project conventions (read existing files first to match style).
