# SML Task Manager Tutorial

A comprehensive, **lesson-based tutorial** for learning the SML (Simple Markup Language) Ada/SPARK library through building a practical task management system.

## 🎯 Overview

This tutorial teaches you how to use all major features of the SML library through **5 progressive lessons**. Each lesson is a complete, self-contained Alire project that builds upon the previous lessons.

**What You'll Learn:**
- **Parsing** SML documents with comprehensive error reporting
- **Schema validation** to ensure data integrity
- **DOM manipulation** for creating and modifying documents
- **Document transformation** using the read-only pattern
- **Complex queries and analysis** on structured data

**Why This Approach:**
- ✅ Each lesson is **self-contained** - build and run independently
- ✅ Each lesson **includes all previous lessons** - review anytime
- ✅ **Proven continuity** - automated validation ensures completeness
- ✅ **Progressive complexity** - master one concept before moving on

## 📚 The 5 Lessons

### [Lesson 1: Basic Parsing](lesson-1-basic-parsing/)
**Learn:** Parse SML documents, navigate the DOM, handle errors

**Topics:**
- Loading documents from files with `Parse_File`
- Handling `Parse_Result` (success/error)
- Navigating DOM tree with `First_Child`, `Next_Sibling`
- Extracting text content from elements
- Understanding immutable documents

**Executables:** 1
- `lesson_1_basic_parsing` ✅

```bash
cd lesson-1-basic-parsing
alr build
./bin/lesson_1_basic_parsing
```

---

### [Lesson 2: Schema Validation](lesson-2-schema-validation/)
**Learn:** Validate documents against schemas with custom types

**Topics:**
- Loading schemas with `Load_Schema`
- Document validation with `Validate_Document`
- Custom type definitions (ranges, enumerations)
- Handling validation errors with detailed paths
- Understanding `Validation_Result`

**Executables:** 2
- `lesson_1_basic_parsing` (from Lesson 1) ✅
- `lesson_2_schema_validation` (new) ✅

```bash
cd lesson-2-schema-validation
alr build
./bin/lesson_1_basic_parsing      # Still works!
./bin/lesson_2_schema_validation  # New!
```

---

### [Lesson 3: Building Documents](lesson-3-building-documents/)
**Learn:** Create structured documents programmatically

**Topics:**
- Creating documents with `Create_Document`
- Adding elements with `Add_Child_Element`
- Adding text nodes with `Add_Text_Node`
- Serializing with `Serialize_Formatted`
- Writing to files with `Write_Document`

**Executables:** 3
- `lesson_1_basic_parsing` (from Lesson 1) ✅
- `lesson_2_schema_validation` (from Lesson 2) ✅
- `lesson_3_building` (new) ✅

```bash
cd lesson-3-building-documents
alr build
./bin/lesson_3_building  # Build documents from scratch!
```

---

### [Lesson 4: Document Transformation](lesson-4-transformation/)
**Learn:** Transform documents using the read-only pattern

**Topics:**
- Understanding immutable parsed documents
- Reading and analyzing source documents
- Building new documents based on source data
- The transformation pattern: parse → extract → build → save
- Working with limited types correctly

**Executables:** 4
- `lesson_1_basic_parsing` (from Lesson 1) ✅
- `lesson_2_schema_validation` (from Lesson 2) ✅
- `lesson_3_building` (from Lesson 3) ✅
- `lesson_4_transformation` (new) ✅

```bash
cd lesson-4-transformation
alr build
./bin/lesson_4_transformation  # Transform task data!
```

---

### [Lesson 5: Analysis and Queries](lesson-5-analysis/)
**Learn:** Analyze documents and generate reports

**Topics:**
- Complex document traversal patterns
- Filtering by multiple criteria
- Aggregating statistics
- Building analysis reports
- Query optimization techniques

**Executables:** 5
- `lesson_1_basic_parsing` (from Lesson 1) ✅
- `lesson_2_schema_validation` (from Lesson 2) ✅
- `lesson_3_building` (from Lesson 3) ✅
- `lesson_4_transformation` (from Lesson 4) ✅
- `lesson_5_analysis` (new) ✅

```bash
cd lesson-5-analysis
alr build
./bin/lesson_5_analysis  # Analyze task databases!
```

---

## 🚀 Quick Start

### Prerequisites

- **Ada 2022 compiler** (GNAT)
- **Alire package manager** ([install here](https://alire.ada.dev/))
- **SML library** (automatically fetched by Alire via pins)

### Start Learning

```bash
# Clone the repository
git clone [repository-url]
cd task_manager_tutorial

# Start with Lesson 1
cd lesson-1-basic-parsing
alr build
./bin/lesson_1_basic_parsing

# Progress to Lesson 2 when ready
cd ../lesson-2-schema-validation
alr build
./bin/lesson_2_schema_validation

# Continue through lessons 3-5...
```

## 📊 Validation & Proof of Continuity

This tutorial uses a **copy-forward strategy** where each lesson is built by copying the previous lesson and adding new functionality. This proves that each lesson provides a complete foundation for the next.

### Automated Validation

```bash
# Verify continuity (fast)
bash scripts/verify_continuity.sh

# Full validation - build and test all lessons (slow)
bash scripts/validate_all_lessons.sh
```

### Validation Results

| Lesson | Executables | Build Status | Continuity |
|--------|------------|--------------|------------|
| Lesson 1 | 1 | ✅ Success | ✅ Baseline |
| Lesson 2 | 2 | ✅ Success | ✅ Contains L1 |
| Lesson 3 | 3 | ✅ Success | ✅ Contains L1-2 |
| Lesson 4 | 4 | ✅ Success | ✅ Contains L1-3 |
| Lesson 5 | 5 | ✅ Success | ✅ Contains L1-4 |

**Total:** 15 executables, all working ✅

See [VALIDATION_COMPLETE.md](VALIDATION_COMPLETE.md) for detailed validation results.

## 📖 The Task Manager Domain

### Why Task Management?

The task management domain was chosen because:

1. **Universal Understanding** - Everyone understands projects, tasks, and deadlines
2. **Natural Hierarchy** - Projects contain tasks, tasks have subtasks (perfect for XML/SML)
3. **Schema Validation Benefits** - Task data requires validation (priorities 1-5, status enums)
4. **Progressive Complexity** - Start simple, add features incrementally
5. **Real-World Applicable** - Can be extended into an actual useful tool
6. **Safety-Critical Aspects** - Demonstrates why formal verification matters

### Data Model

The tutorial uses a task database with the following structure:

```xml
<task_database>
  <metadata>
    <version>1.0</version>
    <last_updated>2025-01-23</last_updated>
  </metadata>

  <projects>
    <project>
      <id>proj_001</id>
      <name>Project Name</name>
      <status>active</status>
      <created>2025-01-01</created>
      <owner>username</owner>
    </project>
  </projects>

  <tasks>
    <task>
      <id>task_001</id>
      <project_id>proj_001</project_id>
      <title>Task Title</title>
      <priority>1-5</priority>
      <status>todo|in_progress|blocked|review|done</status>
    </task>
  </tasks>
</task_database>
```

### Schema Constraints

The schema enforces:
- **Required Fields**: title, priority, status for tasks
- **Enumerations**: Valid status values (todo, in_progress, done, etc.)
- **Numeric Ranges**: Priority 1-5
- **Type Safety**: Custom types for validation

See [fixtures/tasks_simple.schema.sml](fixtures/tasks_simple.schema.sml) for the complete schema definition.

## 🏗️ Project Structure

```
task_manager_tutorial/
├── lesson-1-basic-parsing/          ← Start here!
│   ├── src/
│   │   └── lesson_1_basic_parsing.adb
│   ├── fixtures/
│   │   ├── tasks_simple_sml.sml
│   │   └── tasks_invalid.sml
│   └── bin/
│       └── lesson_1_basic_parsing
│
├── lesson-2-schema-validation/      ← Includes L1 + validation
│   ├── src/
│   │   ├── lesson_1_basic_parsing.adb    (from L1)
│   │   └── lesson_2_schema_validation.adb (new)
│   └── bin/
│       ├── lesson_1_basic_parsing
│       └── lesson_2_schema_validation
│
├── lesson-3-building-documents/     ← Includes L1-2 + building
├── lesson-4-transformation/         ← Includes L1-3 + transformation
├── lesson-5-analysis/              ← Includes L1-4 + analysis
│
├── fixtures/                        ← Shared test data
├── scripts/                         ← Validation scripts
├── archive/                         ← Old documentation
│
├── README.md                        ← This file
├── VALIDATION_COMPLETE.md           ← Proof of continuity
└── LESSON_VALIDATION_PLAN.md        ← Detailed strategy
```

## 🎓 Learning Path

### Recommended Approach

1. **Read** the lesson README
2. **Build** the lesson with `alr build`
3. **Run** all executables (including previous lessons)
4. **Read** the source code
5. **Experiment** - modify and rebuild
6. **Complete** the exercises (if available)
7. **Move** to the next lesson

### Tips for Success

- ✅ **Don't skip lessons** - each builds on the previous
- ✅ **Run previous executables** - see how concepts connect
- ✅ **Read the source code** - it's well-commented
- ✅ **Experiment** - break things and fix them
- ✅ **Ask questions** - use the issue tracker

## 🔧 Common Patterns

### Parsing Documents

```ada
declare
   Parse_Res : constant Parse_Result := Parse_File("document.sml");
begin
   if Parse_Res.Success then
      -- Work with Parse_Res.Doc
   else
      -- Handle Parse_Res.Error
   end if;
end;
```

### Building Documents

```ada
declare
   Doc : Document := Create_Document("root");
   Root : constant Node_Id := SML.DOM.Root(Doc);
   Child : Node_Id;
begin
   Add_Child_Element(Doc, Root, "child", Child);
   Add_Text_Node(Doc, Child, "text", Temp);
end;
```

### Validating Documents

```ada
-- 1. Parse schema
Schema_Parse := Parse_File("schema.sml");
-- 2. Load schema
Schema_Load := Load_Schema(Schema_Parse.Doc);
-- 3. Parse document
Doc_Parse := Parse_File("document.sml");
-- 4. Validate
Result := Validate_Document(Schema_Load.Schema, Doc_Parse.Doc);
```

## 🐛 Troubleshooting

### Build Errors

**Problem:** `sml not found` or `sml_io not found`

**Solution:** Ensure the SML libraries are in the correct location relative to the lesson folder:
```
task_manager_tutorial/
├── lesson-1-basic-parsing/
../sml/              ← SML library here
../sml_io/           ← SML I/O library here
```

### Runtime Errors

**Problem:** `Parse error: File not found`

**Solution:** Run executables from the lesson directory:
```bash
cd lesson-1-basic-parsing
./bin/lesson_1_basic_parsing  # Correct
```

**Problem:** Previous lesson executable doesn't work in new lesson

**Solution:** This indicates a continuity problem. Run validation:
```bash
bash scripts/verify_continuity.sh
```

## 📝 Additional Documentation

- **[LESSON_VALIDATION_PLAN.md](LESSON_VALIDATION_PLAN.md)** - Complete validation strategy
- **[LESSON_IMPLEMENTATION_PROGRESS.md](LESSON_IMPLEMENTATION_PROGRESS.md)** - Implementation details
- **[VALIDATION_COMPLETE.md](VALIDATION_COMPLETE.md)** - Final validation results
- **[STUDENT_EXERCISES.md](STUDENT_EXERCISES.md)** - Practice problems
- **[AGENTS.md](AGENTS.md)** - Development notes

### Individual Lesson Documentation

Each lesson has its own README:
- [lesson-1-basic-parsing/README.md](lesson-1-basic-parsing/README.md)
- lesson-2-schema-validation/README.md (to be created)
- lesson-3-building-documents/README.md (to be created)
- lesson-4-transformation/README.md (to be created)
- lesson-5-analysis/README.md (to be created)

## 🤝 Contributing

Contributions welcome! Areas where help is needed:
- Additional exercises for each lesson
- More test fixtures
- Documentation improvements
- Bug fixes
- New lesson ideas

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- **SML Library Team** - For the formally verified foundation
- **Ada/SPARK Community** - For safety-critical tooling
- **Tutorial Testers** - For feedback and improvements

## ✨ What You'll Build

By completing this tutorial, you'll:

✅ Master SML document parsing and validation
✅ Understand the DOM API and traversal patterns
✅ Build documents programmatically
✅ Transform documents safely with immutable patterns
✅ Analyze and query complex document structures
✅ Have a solid foundation in formally verified XML processing

**Ready to start?** Head to [Lesson 1: Basic Parsing](lesson-1-basic-parsing/) and begin your journey!

---

*Tutorial Version: 2.0 (Lesson-Based) | SML Library: Latest | Ada: 2022*
*Last Updated: 2025-10-27 | Validation Status: ✅ All lessons verified*
