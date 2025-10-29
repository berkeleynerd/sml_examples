# SML Task Manager Tutorial

A comprehensive tutorial for learning the **SML (Simple Markup Language)** library - a formally verified Ada/SPARK XML subset designed for safety-critical applications.

## 🎯 Tutorial Overview

This tutorial teaches you how to use the SML library through a practical task management system, covering:
- Document parsing and validation
- Schema definition and validation
- Programmatic document building
- Document transformation patterns
- Analysis and query techniques

## 🚀 Quick Start

```bash
# Build the tutorial
alr build

# Run the complete tutorial
./bin/task_tutorial_test

# Run individual lessons
./bin/lesson_2_fixed        # Schema validation (with fixes)
./bin/lesson_3_building     # Document building
./bin/lesson_4_transformation # Document transformation
./bin/lesson_5_analysis     # Analysis and queries
```

## 📚 Five Progressive Lessons

### Lesson 1: Basic Parsing ✅
Learn to parse SML documents and handle errors gracefully.
- Parse documents from files
- Navigate the DOM tree
- Extract text values
- Handle parse errors

### Lesson 2: Schema Validation ✅ (Fixed!)
Understand schema validation with custom types.
- Define schemas with constraints
- Validate documents against schemas
- Handle validation errors
- **Note**: Validation bugs have been fixed! Custom types now work correctly.

### Lesson 3: Building Documents ✅
Create structured documents programmatically.
- Build documents from scratch
- Add elements and text content
- Create hierarchical structures
- Serialize and save documents

### Lesson 4: Document Transformation ✅
Transform documents using the read-only pattern.
- Parse source documents
- Extract and analyze data
- Build new transformed documents
- Work with limited types

### Lesson 5: Document Analysis ✅
Analyze documents and generate reports.
- Traverse documents for statistics
- Find elements matching criteria
- Generate analysis reports
- Query patterns for immutable documents

## 🔧 Key Concepts

### Limited Types
SML uses Ada's limited types for memory safety:
- Parsed documents are **immutable** (read-only)
- Cannot use assignment operator on documents
- Must use `declare` blocks with initialization

### Transformation Pattern
Since parsed documents can't be modified:
```ada
1. Parse source document (read-only)
2. Traverse and collect data
3. Build new document with changes
4. Save the new document
```

### Memory Bounds
Default limits ensure predictable memory usage:
- 10,000 nodes maximum
- 1MB total string storage
- Suitable for documents up to ~50KB

## 📝 Student Exercises

Complete 5 hands-on exercises in `STUDENT_EXERCISES.md`:

1. **Parse and Count** - Basic traversal
2. **Build Shopping List** - Document creation
3. **Task Filter** - Transformation pattern
4. **Schema Validator** - Custom validation
5. **Task Manager CLI** - Complete application

## 📁 Project Structure

```
task_tutorial_test/
├── src/
│   ├── task_tutorial_test.adb     # Main tutorial
│   ├── lesson_2_fixed.adb         # Schema validation
│   ├── lesson_3_building.adb      # Document building
│   ├── lesson_4_transformation.adb # Transformation
│   └── lesson_5_analysis.adb      # Analysis/queries
├── fixtures/
│   ├── tasks_simple_sml.sml       # Sample task data
│   ├── tasks_simple.schema.sml    # Task schema
│   └── fixed_inline.schema.sml    # Working schema
├── STUDENT_EXERCISES.md           # Practice problems
└── README.md                       # This file
```

## 🛠️ Installation

### Prerequisites
- Ada 2022 compiler (GNAT)
- Alire package manager
- 2MB stack size (configured automatically)

### Build from Source
```bash
# Clone the repository
git clone [repository-url]
cd task_tutorial_test

# Build with Alire
alr build

# Run tests
alr test
```

## 🐛 Known Issues & Fixes

### Schema Validation (FIXED!)
Previously, validation always passed due to three bugs in type resolution. These have been fixed:
- ✅ Line 119: Unknown types now properly error
- ✅ Line 809: Complex types properly validated
- ✅ Line 1260: Simple types properly validated

### Testing Validation
```bash
# See validation working correctly
./bin/test_type_resolution

# Test with custom types
./bin/test_validation_final
```

## 📊 API Patterns

### Parsing
```ada
declare
   Result : constant Parse_Result := Parse_File("document.sml");
begin
   if Result.Success then
      -- Work with Result.Doc
   end if;
end;
```

### Building
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

### Validation
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

## 🎓 Learning Path

1. **Start Here**: Run `./bin/task_tutorial_test` for the complete tutorial
2. **Deep Dive**: Explore individual lessons for detailed examples
3. **Practice**: Complete the student exercises
4. **Build**: Create your own SML-based application

## 📚 Additional Resources

### Documentation
- `SCHEMA_VALIDATION_ISSUES.md` - Validation implementation details
- `LESSON_3_REVIEW_RESULTS.md` - Building patterns analysis
- `VALIDATION_FIX_RESULTS.md` - Fix verification

### Test Files
- `fixtures/` - Sample documents and schemas
- `src/test_*.adb` - Validation test suite

## 🤝 Contributing

This tutorial is part of the SML formal verification project. Contributions welcome:
- Report bugs in tutorial code
- Suggest new exercises
- Improve documentation
- Add example applications

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- SML Library Team - For the formally verified foundation
- Ada/SPARK Community - For safety-critical tooling
- Tutorial Testers - For feedback and improvements

---

## ✨ What You'll Build

By completing this tutorial, you'll create:
- A working task management system
- Custom schemas with validation
- Document transformation tools
- Analysis and reporting utilities
- A solid foundation in formally verified XML processing

**Ready to start?** Run `./bin/task_tutorial_test` and begin your journey into safe, verified document processing!

---

*Tutorial Version: 1.0 | SML Library: Latest | Ada: 2022*