# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **Ada 2022** tutorial project teaching the SML (Simple Markup Language) library through 5 progressive lessons. The project uses a **copy-forward continuity strategy** where each lesson includes all previous lessons plus new functionality.

## Build System & Commands

### Prerequisites
- **Ada 2022 compiler** (GNAT)
- **Alire package manager** (required)
- **SML libraries** pinned to `../sml` and `../sml_io` relative to repo root

### Common Build Commands

#### Root Level (All Lessons)
```bash
# Build all executables at root
alr build

# Run specific executables from root
./bin/task_tutorial_test
./bin/lesson_2_fixed
./bin/lesson_3_building
./bin/lesson_4_transformation

# Clean build artifacts
gprclean -P task_tutorial_test.gpr
```

#### Individual Lessons
```bash
# Navigate to specific lesson
cd lesson-<N>-<name>

# Build lesson and all its executables
alr build

# Run lesson executable
./bin/lesson_<N>_<name>

# Example for Lesson 3:
cd lesson-3-building-documents
alr build
./bin/lesson_1_basic_parsing      # Still available from L1
./bin/lesson_2_schema_validation  # Still available from L2
./bin/lesson_3_building           # New in L3
```

### Validation Scripts
```bash
# Verify lesson continuity (fast check)
bash scripts/verify_continuity.sh

# Full build and test validation (comprehensive)
bash scripts/validate_all_lessons.sh
```

### Running Tests
```bash
# From root directory
./bin/test_inline_schema
./bin/test_type_resolution
./bin/test_validation_final
```

## Architecture

### Lesson Progression & Copy-Forward Strategy

Each lesson directory is **self-contained** and includes all code from previous lessons:

1. **lesson-1-basic-parsing/** - Base lesson with 1 executable
   - `src/lesson_1_basic_parsing.adb`

2. **lesson-2-schema-validation/** - Contains L1 + L2 (2 executables)
   - `src/lesson_1_basic_parsing.adb` (copied from L1)
   - `src/lesson_2_schema_validation.adb` (new)
   - `src/sml-schema-loader.adb` (840-line helper module)

3. **lesson-3-building-documents/** - Contains L1-L3 (3 executables)
   - All L1-L2 sources
   - `src/lesson_3_building.adb` (new)

4. **lesson-4-transformation/** - Contains L1-L4 (4 executables)
   - All L1-L3 sources
   - `src/lesson_4_transformation.adb` (new)

5. **lesson-5-analysis/** - Contains L1-L5 (5 executables)
   - All L1-L4 sources
   - `src/lesson_5_analysis.adb` (new)

### Key API Patterns

#### Document Parsing
```ada
declare
   Parse_Res : constant Parse_Result := Parse_File("document.sml");
begin
   if Parse_Res.Success then
      -- Work with Parse_Res.Doc (immutable)
   else
      -- Handle Parse_Res.Error
   end if;
end;
```

#### Schema Validation
```ada
-- 1. Parse schema file
Schema_Parse := Parse_File("schema.sml");
-- 2. Load schema object
Schema_Load := Load_Schema(Schema_Parse.Doc);
-- 3. Parse document to validate
Doc_Parse := Parse_File("document.sml");
-- 4. Validate document against schema
Result := Validate_Document(Schema_Load.Schema, Doc_Parse.Doc);
```

#### Document Building
```ada
declare
   Doc : Document := Create_Document("root");
   Root : constant Node_Id := SML.DOM.Root(Doc);
   Child : Node_Id;
begin
   Add_Child_Element(Doc, Root, "child", Child);
   Add_Text_Node(Doc, Child, "text", Temp);
   -- Serialize and write
   Write_Document(Doc, "output.sml");
end;
```

#### Transformation Pattern (Parse → Extract → Build → Save)
```ada
-- Parsed documents are immutable, so:
-- 1. Parse source document
-- 2. Extract needed data
-- 3. Build new document
-- 4. Save new document
```

### File Organization

#### Source Files
- **Root `src/`**: Contains main executables and tests
  - `task_tutorial_test.adb` - Main test runner
  - `lesson_2_fixed.adb`, `lesson_3_building.adb`, `lesson_4_transformation.adb`
  - `sml-schema-loader.adb/ads` - 840-line schema loading utility

- **Lesson `src/` directories**: Each contains cumulative source files
  - Previous lesson files (copied forward)
  - New lesson-specific implementation

#### Test Fixtures (`fixtures/`)
- 23 SML files for testing various scenarios
- Key files:
  - `tasks_simple.sml` - Basic task database
  - `tasks_simple.schema.sml` - Main schema definition
  - `tasks_invalid.sml`, `task_invalid_status.sml` - Error testing

#### Build Artifacts
- `bin/` - Compiled executables (gitignored)
- `obj/development/` - Object files (gitignored)
- `alire/` - Alire system directory (partially gitignored)

## Development Guidelines

### Adding New Code
1. For new lessons: Create under appropriate lesson directory following copy-forward pattern
2. For tests: Add to root `src/` with `test_` prefix
3. Register executables in:
   - Root: `task_tutorial_test.gpr` (for Main use) and `alire.toml` (executables)
   - Lessons: `lesson_*.gpr` and lesson-specific `alire.toml`

### Code Style
- Ada 2022 standard
- 3-space indentation (`-gnaty3`)
- Lower_snake_case for filenames
- Follow existing naming patterns

### Testing Approach
- Test files are executable mains (`test_*.adb`)
- Use fixtures from `fixtures/` directory
- Each lesson builds on previous ones - test continuity

## Important Notes

1. **Immutable Documents**: Parsed SML documents are read-only. To modify, use the transform pattern: parse → extract → build new → save.

2. **Schema Loader Module**: The 840-line `sml-schema-loader.adb` is a key helper module reused across lessons 2-5.

3. **Continuity Validation**: The `scripts/verify_continuity.sh` script ensures each lesson properly includes all previous lesson code.

4. **Library Dependencies**: SML libraries must be at `../sml` and `../sml_io` relative to repo root (configured via Alire pins).

5. **Build Profiles**: Currently using "development" profile. Object files go to `obj/development/`.

## Troubleshooting

### Missing SML Libraries
Ensure SML libraries exist at:
- `../sml/` (relative to repo root)
- `../sml_io/` (relative to repo root)

### Build Failures
```bash
# Clean and rebuild
gprclean -P task_tutorial_test.gpr
alr build
```

### Executable Not Found
Always run from lesson directory:
```bash
cd lesson-1-basic-parsing
./bin/lesson_1_basic_parsing  # Correct
```

### Validation Issues
Run continuity check:
```bash
bash scripts/verify_continuity.sh
```