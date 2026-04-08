---
name: qa
description: Run QA checks on the codebase (linting, type checking, security, tests)
user_invocable: true
---

Run QA checks on the codebase. Parse the argument to determine which mode:

- No argument or "quick": Run `./qa_quick.sh` (format, lint, type check, security scan)
- "full": Run `./qa_check.sh` (all 8 tools: format, lint, types, security, complexity, dead code, docstrings, tests)
- "fix": Run `ruff format {{SRC_DIR}} && ruff check {{SRC_DIR}} --fix` (auto-fix only, no other checks)
- "lint": Run `ruff check {{SRC_DIR}}` (lint only, no fixes)
- "type": Run `pyright {{SRC_DIR}}` (type check only)
- "test": Run `pytest --cov={{SRC_DIR}} --cov-report=term-missing -v` (tests with coverage)
- "security": Run `bandit -r {{SRC_DIR}} -ll` (security scan only)

After running, summarize the results concisely: which tools passed, which failed, and what needs attention. If ruff found auto-fixable issues, offer to run `ruff check {{SRC_DIR}} --fix`.
