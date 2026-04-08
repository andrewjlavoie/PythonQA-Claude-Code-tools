#!/bin/bash

# ============================================================================
# Python Dev Tools for Claude Code — Project Initializer
# Installs QA infrastructure, Claude Code skills, hooks, settings, CI templates,
# and a CLAUDE.md convention file into any Python project.
#
# Usage:
#   ./init.sh /path/to/your/project [options]
#
# Options:
#   --src DIR           Source directory name (default: auto-detect or "src")
#   --python VER        Python version target (default: "py312")
#   --line-length N     Max line length (default: 120)
#   --profile PROFILE   Install profile: full|qa|minimal (default: full)
#   --no-hooks          Skip Claude Code hooks
#   --no-skills         Skip Claude Code skills (except /qa in qa profile)
#   --no-ci             Skip CI/CD templates
#   --no-claude-md      Skip CLAUDE.md generation
#   --with-precommit    Include pre-commit configuration
#   --dry-run           Show what would be done without writing files
# ============================================================================

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
SRC_DIR=""
PYTHON_VER="py312"
LINE_LENGTH=120
PROFILE="full"
INSTALL_HOOKS=true
INSTALL_SKILLS=true
INSTALL_CI=true
INSTALL_CLAUDE_MD=true
INSTALL_PRECOMMIT=false
DRY_RUN=false
TARGET=""

usage() {
    echo "Usage: $0 /path/to/project [options]"
    echo ""
    echo "Profiles:"
    echo "  full      Everything: QA + skills + hooks + CLAUDE.md + settings + CI (default)"
    echo "  qa        QA tools and /qa skill only (backward compatible)"
    echo "  minimal   pyproject.toml config + ruff/pyright + auto-lint hook only"
    echo ""
    echo "Options:"
    echo "  --src DIR           Source directory name (default: auto-detect)"
    echo "  --python VER        Python version, e.g. py310, py311, py312 (default: py312)"
    echo "  --line-length N     Max line length (default: 120)"
    echo "  --profile PROFILE   Install profile: full|qa|minimal (default: full)"
    echo "  --no-hooks          Skip Claude Code hooks"
    echo "  --no-skills         Skip Claude Code skills"
    echo "  --no-ci             Skip CI/CD templates"
    echo "  --no-claude-md      Skip CLAUDE.md generation"
    echo "  --with-precommit    Include pre-commit configuration"
    echo "  --dry-run           Show what would be done"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --src) SRC_DIR="$2"; shift 2 ;;
        --python) PYTHON_VER="$2"; shift 2 ;;
        --line-length) LINE_LENGTH="$2"; shift 2 ;;
        --profile) PROFILE="$2"; shift 2 ;;
        --no-hooks) INSTALL_HOOKS=false; shift ;;
        --no-skills) INSTALL_SKILLS=false; shift ;;
        --no-ci) INSTALL_CI=false; shift ;;
        --no-claude-md) INSTALL_CLAUDE_MD=false; shift ;;
        --with-precommit) INSTALL_PRECOMMIT=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help|-h) usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *) TARGET="$1"; shift ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}Error: No target project directory specified${NC}"
    usage
fi

TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

if [[ ! -d "$TARGET" ]]; then
    echo -e "${RED}Error: Directory does not exist: $TARGET${NC}"
    exit 1
fi

# Validate profile
case "$PROFILE" in
    full) ;;
    qa)
        INSTALL_SKILLS=false
        INSTALL_HOOKS=false
        INSTALL_CI=false
        INSTALL_CLAUDE_MD=false
        ;;
    minimal)
        INSTALL_SKILLS=false
        INSTALL_CI=false
        INSTALL_CLAUDE_MD=false
        ;;
    *)
        echo -e "${RED}Error: Unknown profile '$PROFILE'. Use: full, qa, or minimal${NC}"
        exit 1
        ;;
esac

# Auto-detect source directory
if [[ -z "$SRC_DIR" ]]; then
    if [[ -d "$TARGET/src" ]]; then
        SRC_DIR="src"
    elif [[ -d "$TARGET/lib" ]]; then
        SRC_DIR="lib"
    elif [[ -d "$TARGET/app" ]]; then
        SRC_DIR="app"
    else
        for dir in "$TARGET"/*/; do
            if [[ -f "${dir}__init__.py" ]]; then
                SRC_DIR="$(basename "$dir")"
                break
            fi
        done
    fi
    if [[ -z "$SRC_DIR" ]]; then
        SRC_DIR="src"
        echo -e "${YELLOW}No source directory detected, defaulting to '$SRC_DIR'${NC}"
    else
        echo -e "${CYAN}Detected source directory: $SRC_DIR${NC}"
    fi
fi

# Auto-detect project name
PROJECT_NAME="$(basename "$TARGET")"
if [[ -f "$TARGET/pyproject.toml" ]] && command -v python3 >/dev/null 2>&1; then
    DETECTED_NAME=$(python3 -c "
import re
with open('$TARGET/pyproject.toml') as f:
    content = f.read()
m = re.search(r'name\s*=\s*\"([^\"]+)\"', content)
if m: print(m.group(1))
" 2>/dev/null)
    if [[ -n "$DETECTED_NAME" ]]; then
        PROJECT_NAME="$DETECTED_NAME"
    fi
fi

# Derive python version for pyright (py312 -> 3.12)
PYRIGHT_VER="${PYTHON_VER//py/}"
PYRIGHT_VER="${PYRIGHT_VER:0:1}.${PYRIGHT_VER:1}"

# Description placeholder
DESCRIPTION="<!-- Add your project description here -->"

echo -e "\n${BOLD}${CYAN}Python Dev Tools for Claude Code${NC}"
echo -e "  Target:       $TARGET"
echo -e "  Source dir:    $SRC_DIR"
echo -e "  Python:       $PYRIGHT_VER"
echo -e "  Line length:  $LINE_LENGTH"
echo -e "  Profile:      $PROFILE"
echo -e "  Hooks:        $INSTALL_HOOKS"
echo -e "  Skills:       $INSTALL_SKILLS"
echo -e "  CI:           $INSTALL_CI"
echo -e "  CLAUDE.md:    $INSTALL_CLAUDE_MD"
echo -e "  Pre-commit:   $INSTALL_PRECOMMIT"
echo ""

COPIED=0
SKIPPED=0

# ── Helper functions ───────────────────────────────────────────────────────

install_template() {
    local template="$1"
    local dest="$2"
    shift 2
    local sed_args=("$@")
    local filename="${dest#$TARGET/}"

    if [[ -f "$dest" ]]; then
        echo -e "  ${YELLOW}[skip]${NC} $filename (already exists)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${GREEN}[write]${NC} $filename"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    sed "${sed_args[@]}" "$template" > "$dest"
    echo -e "  ${GREEN}[write]${NC} $filename"
    COPIED=$((COPIED + 1))
}

copy_file() {
    local src="$1"
    local dest="$2"
    local filename="${dest#$TARGET/}"

    if [[ -f "$dest" ]]; then
        echo -e "  ${YELLOW}[skip]${NC} $filename (already exists)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${GREEN}[copy]${NC} $filename"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo -e "  ${GREEN}[copy]${NC} $filename"
    COPIED=$((COPIED + 1))
}

install_executable() {
    local template="$1"
    local dest="$2"
    shift 2
    local sed_args=("$@")

    install_template "$template" "$dest" "${sed_args[@]}"
    if [[ "$DRY_RUN" != true && -f "$dest" ]]; then
        chmod +x "$dest"
    fi
}

merge_settings() {
    local template="$1"
    local dest="$2"
    local filename="${dest#$TARGET/}"

    if [[ ! -f "$dest" ]]; then
        # No existing settings — just copy
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${GREEN}[write]${NC} $filename"
            return
        fi
        mkdir -p "$(dirname "$dest")"
        cp "$template" "$dest"
        echo -e "  ${GREEN}[write]${NC} $filename"
        COPIED=$((COPIED + 1))
        return
    fi

    # Existing settings — try to merge with jq
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "  ${YELLOW}[skip]${NC} $filename (exists; install jq for auto-merge)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${GREEN}[merge]${NC} $filename"
        return
    fi

    # Deep merge: combine permissions arrays and hooks objects
    local merged
    merged=$(jq -s '
        def merge_arrays: [.[0][], .[1][]] | unique;
        {
            permissions: {
                allow: ([.[0].permissions.allow // [], .[1].permissions.allow // []] | add | unique),
                deny: ([.[0].permissions.deny // [], .[1].permissions.deny // []] | add | unique)
            },
            hooks: (.[0].hooks // {}) * (.[1].hooks // {})
        } * (.[0] | del(.permissions, .hooks)) * (.[1] | del(.permissions, .hooks))
    ' "$dest" "$template" 2>/dev/null)

    if [[ $? -eq 0 && -n "$merged" ]]; then
        echo "$merged" > "$dest"
        echo -e "  ${GREEN}[merge]${NC} $filename"
        COPIED=$((COPIED + 1))
    else
        echo -e "  ${YELLOW}[skip]${NC} $filename (merge failed; check manually)"
        SKIPPED=$((SKIPPED + 1))
    fi
}

# Common sed substitutions
SED_COMMON=(
    -e "s|{{SRC_DIR}}|$SRC_DIR|g"
    -e "s|{{PYTHON_VER}}|$PYTHON_VER|g"
    -e "s|{{PYRIGHT_VER}}|$PYRIGHT_VER|g"
    -e "s|{{LINE_LENGTH}}|$LINE_LENGTH|g"
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g"
    -e "s|{{DESCRIPTION}}|$DESCRIPTION|g"
)

# ── Section 1: QA Tools (all profiles) ─────────────────────────────────────

echo -e "${CYAN}QA tools...${NC}"

install_template "$SCRIPT_DIR/templates/pyproject.toml" "$TARGET/pyproject.toml" \
    "${SED_COMMON[@]}"

for script in qa_check.sh qa_quick.sh; do
    install_executable "$SCRIPT_DIR/templates/$script" "$TARGET/$script" \
        -e "s|{{SRC_DIR}}|$SRC_DIR|g"
done

install_template "$SCRIPT_DIR/templates/Makefile" "$TARGET/Makefile" \
    -e "s|{{SRC_DIR}}|$SRC_DIR|g"

copy_file "$SCRIPT_DIR/templates/requirements-dev.txt" "$TARGET/requirements-dev.txt"

# tests directory
if [[ -d "$TARGET/tests" ]]; then
    echo -e "  ${YELLOW}[skip]${NC} tests/ (already exists)"
elif [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${GREEN}[create]${NC} tests/__init__.py"
else
    mkdir -p "$TARGET/tests"
    touch "$TARGET/tests/__init__.py"
    echo -e "  ${GREEN}[create]${NC} tests/__init__.py"
    COPIED=$((COPIED + 1))
fi

# /qa skill is always installed (all profiles)
install_template "$SCRIPT_DIR/templates/skills/qa.md" "$TARGET/.claude/skills/qa.md" \
    -e "s|{{SRC_DIR}}|$SRC_DIR|g"

# ── Section 2: Skills (full profile, unless --no-skills) ───────────────────

if [[ "$INSTALL_SKILLS" == true ]]; then
    echo -e "${CYAN}Claude Code skills...${NC}"

    for skill in test debug refactor docs deps scaffold migrate; do
        install_template "$SCRIPT_DIR/templates/skills/$skill.md" "$TARGET/.claude/skills/$skill.md" \
            -e "s|{{SRC_DIR}}|$SRC_DIR|g"
    done
fi

# ── Section 3: Hooks (full and qa profiles, unless --no-hooks) ─────────────

if [[ "$INSTALL_HOOKS" == true ]]; then
    echo -e "${CYAN}Claude Code hooks...${NC}"

    for hook in post-edit-lint.sh pre-bash-venv.sh post-edit-test.sh; do
        install_executable "$SCRIPT_DIR/templates/hooks/$hook" "$TARGET/.claude/hooks/$hook" \
            -e "s|{{SRC_DIR}}|$SRC_DIR|g"
    done
fi

# ── Section 4: Settings ────────────────────────────────────────────────────

echo -e "${CYAN}Claude Code settings...${NC}"
merge_settings "$SCRIPT_DIR/templates/settings.json" "$TARGET/.claude/settings.json"

# ── Section 5: CLAUDE.md (full profile, unless --no-claude-md) ─────────────

if [[ "$INSTALL_CLAUDE_MD" == true ]]; then
    echo -e "${CYAN}CLAUDE.md...${NC}"

    if [[ ! -f "$TARGET/CLAUDE.md" ]]; then
        # No existing CLAUDE.md — install the full template
        install_template "$SCRIPT_DIR/templates/CLAUDE.md" "$TARGET/CLAUDE.md" \
            "${SED_COMMON[@]}"
    elif grep -q "pydev-conventions-start" "$TARGET/CLAUDE.md"; then
        echo -e "  ${YELLOW}[skip]${NC} CLAUDE.md (conventions already present)"
        SKIPPED=$((SKIPPED + 1))
    else
        # Existing CLAUDE.md without conventions — append them
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${GREEN}[append]${NC} CLAUDE.md (adding conventions)"
        else
            # Extract just the conventions block (between the markers) and substitute
            echo "" >> "$TARGET/CLAUDE.md"
            sed -n '/pydev-conventions-start/,/pydev-conventions-end/p' \
                "$SCRIPT_DIR/templates/CLAUDE.md" | \
                sed "${SED_COMMON[@]}" >> "$TARGET/CLAUDE.md"
            echo -e "  ${GREEN}[append]${NC} CLAUDE.md (added conventions)"
            COPIED=$((COPIED + 1))
        fi
    fi
fi

# ── Section 6: CI/CD (full profile, unless --no-ci) ───────────────────────

if [[ "$INSTALL_CI" == true ]]; then
    echo -e "${CYAN}CI/CD templates...${NC}"

    install_template "$SCRIPT_DIR/templates/ci/pr-qa.yml" "$TARGET/.github/workflows/pr-qa.yml" \
        "${SED_COMMON[@]}"
fi

# ── Section 7: Pre-commit (only with --with-precommit) ────────────────────

if [[ "$INSTALL_PRECOMMIT" == true ]]; then
    echo -e "${CYAN}Pre-commit config...${NC}"

    copy_file "$SCRIPT_DIR/templates/pre-commit-config.yaml" "$TARGET/.pre-commit-config.yaml"
fi

# ── Append to .gitignore ──────────────────────────────────────────────────

QA_IGNORES="htmlcov/
.coverage
.ruff_cache/
.pytest_cache/"

if [[ -f "$TARGET/.gitignore" ]]; then
    MISSING=false
    while IFS= read -r line; do
        if ! grep -qF "$line" "$TARGET/.gitignore"; then
            MISSING=true
            break
        fi
    done <<< "$QA_IGNORES"

    if [[ "$MISSING" == true && "$DRY_RUN" != true ]]; then
        echo "" >> "$TARGET/.gitignore"
        echo "# QA tool artifacts" >> "$TARGET/.gitignore"
        echo "$QA_IGNORES" >> "$TARGET/.gitignore"
        echo -e "  ${GREEN}[append]${NC} .gitignore (added QA patterns)"
    elif [[ "$MISSING" == true ]]; then
        echo -e "  ${GREEN}[append]${NC} .gitignore (would add QA patterns)"
    else
        echo -e "  ${YELLOW}[skip]${NC} .gitignore (QA patterns already present)"
    fi
else
    if [[ "$DRY_RUN" != true ]]; then
        echo "# QA tool artifacts" > "$TARGET/.gitignore"
        echo "$QA_IGNORES" >> "$TARGET/.gitignore"
        echo -e "  ${GREEN}[write]${NC} .gitignore"
    fi
fi

# ── Summary ────────────────────────────────────────────────────────────────

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${CYAN}Dry run complete — no files written${NC}"
else
    echo -e "${GREEN}Done! ${COPIED} file(s) created/merged, ${SKIPPED} skipped (already exist)${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  cd $TARGET"
    echo -e "  pip install -r requirements-dev.txt"
    echo -e "  make qa-quick     # or ./qa_quick.sh"
    if [[ "$INSTALL_SKILLS" == true ]]; then
        echo -e ""
        echo -e "${CYAN}Available skills in Claude Code:${NC}"
        echo -e "  /qa         QA checks (quick, full, fix, lint, type, test, security)"
        echo -e "  /test       Generate & run tests"
        echo -e "  /debug      Debug errors & profile performance"
        echo -e "  /refactor   Complexity, modernize, dead code, simplify"
        echo -e "  /docs       Docstrings, README, API reference, changelog"
        echo -e "  /deps       Dependency audit, outdated, unused, tree"
        echo -e "  /scaffold   Create modules, packages, CLI, models, config"
        echo -e "  /migrate    Python upgrades, typing, pydantic-v2, uv, pathlib"
    fi
fi
