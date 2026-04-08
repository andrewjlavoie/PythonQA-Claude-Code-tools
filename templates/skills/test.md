---
name: test
description: Generate, run, and manage Python tests
user_invocable: true
---

Run or generate Python tests. Parse the argument to determine the action:

- No argument: Run `pytest -v --tb=short` (quick test run, concise output)
- "gen <file_or_module>": Generate pytest tests for the specified file/module:
  - Read the source file and identify all public functions, methods, and classes
  - Generate comprehensive tests in `tests/test_<module_name>.py`:
    - Happy path for each public function/method
    - Edge cases: empty inputs, None, boundary values, empty collections
    - Error cases: expected exceptions with `pytest.raises`
    - Use `pytest.fixture` for shared setup
    - Use `pytest.mark.parametrize` for data-driven test cases
    - Follow Arrange-Act-Assert pattern
    - Use `tmp_path` for any file operations
    - Mock external dependencies (network, database, filesystem outside tmp_path)
  - After generating, run the tests to verify they pass. Fix import or fixture issues if they fail.
- "cov": Run `pytest --cov={{SRC_DIR}} --cov-report=term-missing -v` and highlight files with low coverage
- "cov <file>": Run `pytest --cov={{SRC_DIR}}/<file> --cov-report=term-missing -v` for a specific module
- "fail": Run `pytest --lf -v` (rerun only last-failed tests)
- "watch <pattern>": Run `pytest -v -k "<pattern>"` (run tests matching the pattern)
- "missing": Scan `{{SRC_DIR}}/` for `.py` files and compare against `tests/` to find source files without corresponding `test_<name>.py` files. List them with line counts so the user can prioritize which to test first.

After running, summarize: how many passed/failed/skipped, and what needs attention.
