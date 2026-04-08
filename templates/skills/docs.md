---
name: docs
description: Generate and check Python documentation — docstrings, README, API reference, changelog
user_invocable: true
---

Generate or check documentation. Parse the argument to determine the action:

- No argument or "check": Check docstring coverage:
  1. Run `interrogate {{SRC_DIR}} -v`
  2. Summarize overall coverage percentage
  3. List the top 10 undocumented public items (functions, classes, methods)

- "gen <file>": Generate docstrings for a file:
  1. Read the file and find all public functions, methods, and classes without docstrings
  2. Add Google-style docstrings with Args, Returns, Raises sections
  3. Infer argument types from annotations and describe each parameter's purpose
  4. Do NOT overwrite existing docstrings
  5. Do NOT add docstrings to private methods (single underscore prefix) unless they're complex

- "module <file>": Generate or update the module-level docstring:
  1. Read the entire file to understand its purpose
  2. Write a concise module docstring explaining what the module provides and when to use it
  3. Include a brief usage example if the module has a clear primary API

- "readme": Generate or update the project README:
  1. Analyze: pyproject.toml (project metadata), source structure, existing README
  2. Generate/update sections: Overview, Installation, Quick Start, Usage, Configuration, Development
  3. Preserve any existing custom sections the user has added

- "api <module>": Generate a Markdown API reference:
  1. Read the module and list all public classes, functions, and their signatures
  2. Include docstrings, parameter types, return types
  3. Format as clean Markdown suitable for a docs site

- "changelog": Draft a CHANGELOG entry:
  1. Run `git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~50)..HEAD`
  2. Group commits by type: Features, Bug Fixes, Refactoring, Documentation, Tests
  3. Draft a CHANGELOG entry in Keep a Changelog format

Use Google-style docstrings (Args/Returns/Raises). If existing docstrings use a different style, match the existing project convention instead.
