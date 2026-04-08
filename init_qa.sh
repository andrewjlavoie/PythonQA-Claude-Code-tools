#!/bin/bash

# ============================================================================
# Python QA Tools — Project Initializer (Legacy Wrapper)
# This script is a backward-compatible wrapper around init.sh.
# It installs only QA tools and the /qa skill (profile: qa).
#
# Usage:
#   ./init_qa.sh /path/to/your/project [options]
#
# For the full Python dev toolkit (skills, hooks, CLAUDE.md, CI), use:
#   ./init.sh /path/to/your/project
#
# Options:
#   --src DIR         Source directory name (default: auto-detect or "src")
#   --python VER      Python version target (default: "py312")
#   --line-length N   Max line length (default: 120)
#   --no-skill        Skip creating the Claude Code /qa slash command
#   --dry-run         Show what would be done without writing files
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Translate --no-skill to --no-skills for init.sh compatibility
ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--no-skill" ]]; then
        ARGS+=("--no-skills")
    else
        ARGS+=("$arg")
    fi
done

exec "$SCRIPT_DIR/init.sh" --profile qa "${ARGS[@]}"
