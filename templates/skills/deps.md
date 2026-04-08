---
name: deps
description: Manage Python dependencies — audit, add, check outdated, find unused
user_invocable: true
---

Manage project dependencies. Parse the argument to determine the action:

- No argument or "check": Check for outdated packages:
  1. Run `pip list --outdated`
  2. Group updates by severity: major (breaking), minor (features), patch (fixes)
  3. Flag any packages with known deprecation timelines

- "audit": Scan for security vulnerabilities:
  1. Run `pip-audit` (install with `pip install pip-audit` if missing)
  2. Summarize vulnerabilities by severity (critical, high, medium, low)
  3. Suggest specific version upgrades to fix each vulnerability

- "tree": Show the dependency tree:
  1. Run `pipdeptree` (install with `pip install pipdeptree` if missing)
  2. Highlight any version conflicts or circular dependencies

- "unused": Find potentially unused dependencies:
  1. Collect all import statements from `{{SRC_DIR}}/` and `tests/` (recursively)
  2. Map import names to package names (handle cases like `PIL` → `Pillow`, `cv2` → `opencv-python`)
  3. Compare against installed packages / requirements files
  4. List packages that appear in requirements but are never imported
  5. Note: some packages are runtime-only (drivers, plugins) — flag these as "verify manually"

- "add <package>": Add a new dependency:
  1. Check that a virtual environment is active
  2. Run `pip install <package>`
  3. Detect the requirements file: if `pyproject.toml` has `[project.dependencies]`, add there; otherwise add to `requirements.txt`
  4. Pin to compatible version (e.g., `package>=X.Y.Z,<X+1`)

- "sync": Sync the environment:
  1. If `uv.lock` exists: run `uv sync`
  2. Elif `requirements.txt` exists: run `pip install -r requirements.txt`
  3. If `requirements-dev.txt` exists, also install that

Always warn if no virtual environment is detected (`$VIRTUAL_ENV` unset, no `.venv/` or `venv/` directory, no `uv.lock`).
