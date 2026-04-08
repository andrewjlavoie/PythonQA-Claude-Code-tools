# Python Dev Tools for Claude Code

Drop-in Python development infrastructure for Claude Code. One script adds QA tools, Claude Code skills, hooks, project conventions, and CI templates to any Python project.

## What's Included

### QA Tools (8 tools)

| Tool | What it does |
|------|-------------|
| **ruff** | Linting, formatting, import sorting, syntax modernization |
| **pyright** | Static type checking |
| **bandit** | Security vulnerability scanning |
| **radon** | Code complexity analysis |
| **vulture** | Dead code detection |
| **interrogate** | Docstring coverage |
| **pytest** | Testing with coverage |
| **pip-audit** | Dependency vulnerability scanning |

### Claude Code Skills (8 skills)

| Skill | What it does |
|-------|-------------|
| `/qa` | Run QA checks — quick, full, fix, lint, type, test, security |
| `/test` | Generate tests, run coverage, find untested files |
| `/debug` | Trace errors, profile performance, analyze imports |
| `/refactor` | Complexity analysis, modernize, dead code, simplify, split |
| `/docs` | Generate docstrings, README, API reference, changelog |
| `/deps` | Audit dependencies, find outdated/unused, manage packages |
| `/scaffold` | Create modules, packages, CLI entry points, models, config |
| `/migrate` | Python version upgrades, typing, pydantic-v2, uv, pathlib |

### Hooks

| Hook | Trigger | What it does |
|------|---------|-------------|
| **post-edit-lint** | After file edit | Auto-formats and fixes the edited `.py` file with ruff |
| **pre-bash-venv** | Before pip/python commands | Warns if no virtual environment is active |
| **post-edit-test** | After file edit (optional) | Runs corresponding test file automatically |

### Also Included

- **CLAUDE.md** — Python coding conventions template (type annotations, docstrings, testing patterns, workflow)
- **settings.json** — Pre-allowed QA tool permissions, deny rules for dangerous operations
- **GitHub Actions** — PR quality check workflow
- **Pre-commit config** — ruff + bandit hooks (optional)

## Quick Start

```bash
# Full install (everything)
./init.sh /path/to/your/project

# Then in your project:
cd /path/to/your/project
pip install -r requirements-dev.txt
make qa-quick
```

## Profiles

```bash
# Full: QA + skills + hooks + CLAUDE.md + settings + CI (default)
./init.sh /path/to/project

# QA only: QA tools and /qa skill (backward compatible)
./init.sh /path/to/project --profile qa

# Minimal: pyproject.toml config + ruff/pyright + auto-lint hook
./init.sh /path/to/project --profile minimal

# Legacy wrapper (equivalent to --profile qa)
./init_qa.sh /path/to/project
```

## Options

```
./init.sh /path/to/project [options]

  --src DIR           Source directory (default: auto-detect from src/, lib/, app/)
  --python VER        Python target, e.g. py310, py311, py312 (default: py312)
  --line-length N     Max line length (default: 120)
  --profile PROFILE   Install profile: full|qa|minimal (default: full)
  --no-hooks          Skip Claude Code hooks
  --no-skills         Skip Claude Code skills (except /qa)
  --no-ci             Skip CI/CD templates
  --no-claude-md      Skip CLAUDE.md generation
  --with-precommit    Include pre-commit configuration
  --dry-run           Preview what would be created
```

## What Gets Created

Full profile creates:

```
your-project/
├── CLAUDE.md                   # Python conventions for Claude Code
├── pyproject.toml              # All tool configuration
├── requirements-dev.txt        # QA tool dependencies
├── qa_check.sh                 # Comprehensive check (8 tools, ~5 min)
├── qa_quick.sh                 # Quick check (4 tools, ~1 min)
├── Makefile                    # Shortcut commands
├── tests/
│   └── __init__.py
├── .claude/
│   ├── settings.json           # Permissions + hook config
│   ├── hooks/
│   │   ├── post-edit-lint.sh   # Auto-format after edits
│   │   ├── pre-bash-venv.sh    # Venv guard
│   │   └── post-edit-test.sh   # Auto-test (optional)
│   └── skills/
│       ├── qa.md               # /qa
│       ├── test.md             # /test
│       ├── debug.md            # /debug
│       ├── refactor.md         # /refactor
│       ├── docs.md             # /docs
│       ├── deps.md             # /deps
│       ├── scaffold.md         # /scaffold
│       └── migrate.md          # /migrate
└── .github/
    └── workflows/
        └── pr-qa.yml           # PR quality checks
```

Existing files are never overwritten. Settings are merged (requires `jq`). If a CLAUDE.md already exists, the conventions section is appended rather than skipping the file entirely.

## Make Commands

```bash
make help           # Show all commands
make qa             # Comprehensive check (all 8 tools)
make qa-quick       # Quick check (format, lint, types, security)
make format         # Auto-fix formatting and lint issues
make lint           # Lint only
make type           # Type checking only
make security       # Security scan
make test           # Tests with coverage
make test-fail      # Re-run only failed tests
make test-cov       # Tests with HTML coverage report
make complexity     # Cyclomatic complexity analysis
make dead-code      # Find unused code
make docstrings     # Docstring coverage report
make deps-check     # Check for outdated dependencies
make deps-audit     # Audit dependencies for vulnerabilities
make deps-tree      # Show dependency tree
make profile        # Profile a command (make profile CMD="python script.py")
make clean          # Remove QA artifacts
```

## Customization

All configuration lives in `pyproject.toml`. Common things to tweak:

| Setting | Location | Default |
|---------|----------|---------|
| Line length | `[tool.ruff] line-length` | 120 |
| Python version | `[tool.ruff] target-version` | py312 |
| Lint rules | `[tool.ruff.lint] select` | E, W, F, I, N, UP, B, C4, SIM, PTH |
| Type strictness | `[tool.pyright] typeCheckingMode` | basic |
| Docstring coverage | `[tool.interrogate] fail-under` | 60% |

## Repository Layout

```
pyqa_tools_for_cc/
├── README.md
├── init.sh                     # Main installer
├── init_qa.sh                  # Legacy wrapper (--profile qa)
└── templates/
    ├── pyproject.toml
    ├── requirements-dev.txt
    ├── qa_check.sh
    ├── qa_quick.sh
    ├── Makefile
    ├── CLAUDE.md
    ├── settings.json
    ├── pre-commit-config.yaml
    ├── skills/
    │   ├── qa.md
    │   ├── test.md
    │   ├── debug.md
    │   ├── refactor.md
    │   ├── docs.md
    │   ├── deps.md
    │   ├── scaffold.md
    │   └── migrate.md
    ├── hooks/
    │   ├── post-edit-lint.sh
    │   ├── pre-bash-venv.sh
    │   └── post-edit-test.sh
    └── ci/
        └── pr-qa.yml
```
