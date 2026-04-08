#!/bin/bash
# Pre-bash hook: warn if running pip/python commands outside a virtual environment.
# Prevents accidental system-level package installs.
# Trigger: PreToolUse on Bash

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check commands that start with pip or python
if ! echo "$CMD" | grep -qE '^\s*(pip |pip3 |python -m pip |python3 -m pip )'; then
    exit 0
fi

# Skip read-only pip commands
if echo "$CMD" | grep -qE '^\s*(pip |pip3 )(list|show|freeze|check)'; then
    exit 0
fi

# Check for virtual environment indicators
if [[ -n "$VIRTUAL_ENV" ]]; then
    exit 0
fi

# Check for local venv directories
for venv_dir in .venv venv env; do
    if [[ -d "$venv_dir" ]]; then
        exit 0
    fi
done

# Check for uv (manages venvs transparently)
if [[ -f "uv.lock" ]]; then
    exit 0
fi

echo "WARNING: No virtual environment detected."
echo "Running pip install outside a venv may affect system packages."
echo "Consider: python -m venv .venv && source .venv/bin/activate"
exit 2
