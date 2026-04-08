#!/bin/bash
# Post-edit hook: auto-run corresponding test file after editing source code.
# OPTIONAL — this hook is commented out in settings.json by default.
# Enable it for tight test feedback loops during development.
# Trigger: PostToolUse on Edit|Write

command -v jq >/dev/null 2>&1 || exit 0
command -v pytest >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty')

# Only act on Python files
if [[ -z "$FILE" || "$FILE" != *.py ]]; then
    exit 0
fi

# Skip if the edited file is itself a test
if echo "$FILE" | grep -qE '(^|/)tests?/|test_'; then
    exit 0
fi

# Derive the test file name
BASENAME=$(basename "$FILE" .py)
TEST_FILE="tests/test_${BASENAME}.py"

if [[ -f "$TEST_FILE" ]]; then
    echo "--- Running related tests: $TEST_FILE ---"
    pytest "$TEST_FILE" -v --tb=short -q 2>&1 | tail -10
fi
