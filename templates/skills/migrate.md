---
name: migrate
description: Migrate and upgrade Python code — version upgrades, typing modernization, framework migrations
user_invocable: true
---

Migrate or upgrade Python code. Parse the argument to determine the action:

- "python <version>": Analyze Python version compatibility:
  1. Check `pyproject.toml` for current `target-version` / `requires-python`
  2. Scan for deprecated stdlib usage being removed in the target version
  3. Identify new features available in the target version (e.g., match/case in 3.10, tomllib in 3.11, exception groups in 3.11, type parameter syntax in 3.12)
  4. Suggest code that could benefit from the new features
  5. Update `pyproject.toml` target-version and requires-python

- "typing": Modernize type annotations:
  1. Run `ruff check {{SRC_DIR}} --select UP006,UP007,UP035 --preview` to preview
  2. Apply: replace `Optional[X]` with `X | None`, `List[X]` with `list[X]`, `Dict[K,V]` with `dict[K,V]`, `Tuple[...]` with `tuple[...]`, `Set[X]` with `set[X]`
  3. Add `from __future__ import annotations` to files that need it (Python <3.10)
  4. Remove unused imports from `typing` module
  5. Run `pyright {{SRC_DIR}}` to verify type checking still passes

- "pydantic-v2": Migrate Pydantic v1 patterns to v2:
  1. Find all Pydantic usage: `BaseModel`, `validator`, `Field`, `Config`
  2. Migrate: `BaseModel.dict()` → `.model_dump()`, `.json()` → `.model_dump_json()`, `.parse_obj()` → `.model_validate()`, `.parse_raw()` → `.model_validate_json()`
  3. Migrate: `@validator` → `@field_validator`, `@root_validator` → `@model_validator`
  4. Migrate: inner `class Config` → `model_config = ConfigDict(...)`
  5. Run tests to verify the migration didn't break anything

- "uv": Migrate to uv package manager:
  1. Detect current setup: requirements.txt, Pipfile, poetry.lock, setup.py, setup.cfg
  2. Create/update `pyproject.toml` with `[project]` metadata and dependencies
  3. Run `uv sync` to generate `uv.lock`
  4. Report: what files can be removed (old lock files, setup.py if fully migrated)

- "pathlib": Migrate os.path to pathlib:
  1. Run `ruff check {{SRC_DIR}} --select PTH` to find all os.path usage
  2. Apply with `ruff check {{SRC_DIR}} --select PTH --fix`
  3. Review: some migrations need manual attention (e.g., `os.path.join` with unpacking)
  4. Run tests to verify

After any migration, run `ruff check {{SRC_DIR}} && pyright {{SRC_DIR}}` to catch breakage. Run tests if they exist.
