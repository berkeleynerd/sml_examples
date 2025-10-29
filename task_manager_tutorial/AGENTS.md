# Repository Guidelines

This guide helps contributors work effectively in this Ada/Alire tutorial repo. Keep changes small, build frequently, and include runnable examples.

## Project Structure & Module Organization
- `src/` — Ada sources (`.adb` bodies, `.ads` specs). Mains: `task_tutorial_test.adb`, `lesson_*.adb`; tests/demos: `test_*.adb`.
- `config/` — GNAT project config and compiler switches (`config/task_tutorial_test_config.gpr`).
- `fixtures/` — Sample SML documents and schemas used by lessons/tests.
- `bin/` — Built executables (e.g., `./bin/task_tutorial_test`, `./bin/lesson_3_building`).
- `obj/<profile>/` — Build artifacts. Profiles are set in the config GPR.
- `task_tutorial_test.gpr`, `alire.toml` — Project and dependency metadata (Alire).

Naming: use lower_snake_case for file names (`lesson_5_analysis.adb`, `test_validation_final.adb`). Place new executables in `src/` and follow the `lesson_*` or `test_*` pattern when appropriate.

## Build, Test, and Development Commands
- Build all: `alr build` (preferred; resolves deps and calls `gprbuild`).
- Alt build: `gprbuild -P task_tutorial_test.gpr` (direct GNAT build).
- Run full tutorial: `./bin/task_tutorial_test`.
- Run a lesson: `./bin/lesson_4_transformation`.
- Run tests/demos: `./bin/test_type_resolution`, `./bin/test_validation_final`, `./bin/test_inline_schema`.
- Clean artifacts: `gprclean -P task_tutorial_test.gpr`.

Tip: This crate pins `sml` and `sml_io` to sibling paths (`../sml`, `../sml_io`) in `alire.toml`. Ensure those checkouts exist or update/remove the pins before building.

## Coding Style & Naming Conventions
- Language: Ada 2022. Indentation: 3 spaces (`-gnaty3`).
- Keep identifiers and keyword casing consistent with existing files; compiler switches enforce style (`-gnatwa`, `-gnaty*`, `-gnat2022`).
- One public package per file; specs in `.ads`, bodies in `.adb`. Use clear, descriptive names (e.g., `SML_Schema.Loader`).

## Testing Guidelines
- Tests are executable mains under `src/test_*.adb`. Keep inputs in `fixtures/`.
- To add a new test/lesson, create `src/test_<name>.adb` or `src/lesson_<name>.adb`, then register it in `task_tutorial_test.gpr` (`for Main use`) or `alire.toml` (`executables`) so it builds into `bin/`.
- No coverage tool is configured; prioritize runnable examples with expected output.

## Commit & Pull Request Guidelines
- Commits: imperative, concise subject; explain rationale and user impact in the body. Example: `build: add lesson_5 analysis executable`.
- PRs: include a clear description, linked issues, how-to-verify steps (commands to run), and relevant output snippets or screenshots of terminal runs.
