---
name: debug
description: Debug Python errors — trace exceptions, profile performance, analyze imports
user_invocable: true
---

Debug Python code. Parse the argument to determine the action:

- "<error message or traceback>": Analyze the traceback:
  1. Read the source files referenced in each stack frame
  2. Identify the root cause (not just the symptom)
  3. Check for common Python pitfalls: mutable default arguments, late binding closures, circular imports, iterator exhaustion, shallow vs deep copy issues
  4. Suggest the minimal fix with explanation
  5. If the fix is clear and safe, offer to apply it

- "profile <command>": Profile the command for performance:
  1. Run `python -m cProfile -s cumulative <command> 2>&1 | head -40`
  2. Identify the top time-consuming functions
  3. Read the source of hot functions and suggest optimizations

- "imports <module>": Analyze import performance:
  1. Run `python -X importtime -c "import <module>" 2>&1`
  2. Parse the import time tree
  3. Identify slow imports that could be lazy-loaded or deferred

- "why <exception_type>": Explain the exception:
  1. Describe what the exception means
  2. List the 3-5 most common causes with code examples
  3. Suggest typical fixes for each cause

When analyzing errors, always read the actual source at the traceback line numbers rather than guessing. Suggest the minimal fix — don't rewrite surrounding code.
