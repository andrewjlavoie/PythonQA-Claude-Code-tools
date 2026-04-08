#!/bin/bash
# Post-edit hook: auto-format and fix Python files after Claude edits them.
# Runs ruff format + ruff check --fix silently on the edited file.
# Trigger: PostToolUse on Edit|Write

command -v jq >/dev/null 2>&1 || exit 0
command -v ruff >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty')

if [[ -n "$FILE" && "$FILE" == *.py && -f "$FILE" ]]; then
    ruff format "$FILE" 2>/dev/null
    ruff check "$FILE" --fix --silent 2>/dev/null
fi
