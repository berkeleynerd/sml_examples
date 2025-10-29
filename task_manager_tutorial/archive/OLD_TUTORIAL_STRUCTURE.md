# SML Task Manager Tutorial

A comprehensive tutorial for learning the SML (Simple Markup Language) Ada/SPARK library through building a practical task management system.

## Overview

This tutorial teaches you how to use all major features of the SML library by building a real-world task management application. The project demonstrates:

- **Parsing** SML documents with comprehensive error reporting
- **Schema validation** to ensure data integrity
- **DOM manipulation** for creating and modifying documents
- **File I/O operations** for persistence
- **Querying and reporting** on structured data

## Why a Task Manager?

The task management domain was chosen because:

1. **Universal Understanding** - Everyone understands projects, tasks, and deadlines
2. **Natural Hierarchy** - Projects contain tasks, tasks have subtasks, perfect for XML/SML structure
3. **Schema Validation Benefits** - Task data requires validation (priorities 1-5, valid dates, status enums)
4. **Progressive Complexity** - Start simple, add features incrementally
5. **Real-World Applicable** - Can be extended into an actual useful tool
6. **Safety-Critical Aspects** - Demonstrates why formal verification matters for data integrity

## Data Model

### Core Entities

```xml
<task_database>
  <metadata>
    <version>1.0</version>
    <last_updated>2025-01-23</last_updated>
  </metadata>

  <projects>
    <project id="proj_001">
      <name>Project Name</name>
      <description>Project Description</description>
      <status>active|planning|on_hold|completed|cancelled</status>
      <created>YYYY-MM-DD</created>
      <owner>username</owner>
      <deadline>YYYY-MM-DD</deadline>  <!-- optional -->
    </project>
  </projects>

  <tasks>
    <task id="task_001" project_id="proj_001">
      <title>Task Title</title>
      <description>Task Description</description>  <!-- optional -->
      <priority>1-5</priority>
      <status>todo|in_progress|blocked|review|done</status>
      <assigned_to>username</assigned_to>  <!-- optional -->
      <estimated_hours>0.5-999.9</estimated_hours>  <!-- optional -->
      <due_date>YYYY-MM-DD</due_date>  <!-- optional -->
      <completed_date>YYYY-MM-DD</completed_date>  <!-- optional -->
      <tags>  <!-- optional -->
        <tag>backend</tag>
        <tag>critical</tag>
      </tags>
      <dependencies>  <!-- optional -->
        <depends_on>task_id</depends_on>
      </dependencies>
      <subtasks>  <!-- optional -->
        <subtask id="st_001" completed="true|false">Subtask description</subtask>
      </subtasks>
    </task>
  </tasks>

  <time_entries>  <!-- optional -->
    <entry task_id="task_001">
      <date>YYYY-MM-DD</date>
      <hours>0.25-24.0</hours>
      <description>Work description</description>
      <user>username</user>
    </entry>
  </time_entries>
</task_database>
```

### Schema Constraints

The schema enforces:

- **Required Fields**: title, priority, status for tasks; name, status, created, owner for projects
- **Enumerations**: Valid status values, priority range (1-5)
- **String Lengths**: Max 100 chars for project names, 200 for task titles
- **Numeric Ranges**: Priority 1-5, hours 0.25-24.0, estimated_hours 0.5-999.9
- **Cardinality**: Max 10 tags per task, max 20 subtasks per task
- **Date Format**: ISO format YYYY-MM-DD

## Tutorial Structure

### Lesson 1: Basic Parsing
**Concepts**: Parse Result handling, Document traversal, Error reporting

- Load and parse a simple task file
- Handle parse errors gracefully
- Check document well-formedness
- Count tasks by status

**Key APIs**:
```ada
Parse_File(path) -> Parse_Result
Is_Well_Formed(doc) -> Boolean
First_Child(doc, node) -> Node_Ref
Next_Sibling(doc, node) -> Node_Ref
Kind(doc, node) -> Node_Kind
Name(doc, node) -> String
Text_Value(doc, node) -> String
```

### Lesson 2: Schema Validation
**Concepts**: Schema loading, Validation results, Error location tracking

- Load schema from file
- Validate documents against schema
- Handle validation errors with detailed messages
- Test both valid and invalid documents

**Key APIs**:
```ada
Load_Schema_From_File(path) -> Schema_Load_Result
Validate(doc, schema) -> Validation_Result
Validation_Result.Is_Valid -> Boolean
Validation_Result.Error_Message -> String
Validation_Result.Error_Location -> String (XPath-style)
```

### Lesson 3: Building Documents Programmatically
**Concepts**: DOM construction, Node creation, Serialization

- Create new document from scratch
- Build hierarchical structure
- Add text content to elements
- Serialize to formatted SML
- Save to file

**Key APIs**:
```ada
Create_Document(root_name) -> Document
Add_Child_Element(doc, parent, name) -> Node_Ref
Add_Text_Node(doc, parent, text) -> Node_Ref
Serialize_Formatted(doc, indent) -> String
Write_Document(path, doc, formatted) -> Write_Result
```

### Lesson 4: Modifying Existing Documents
**Concepts**: DOM manipulation, Content updates, Document persistence

- Load existing document
- Find and modify specific nodes
- Update text content
- Count modifications
- Save changes

**Key APIs**:
```ada
Set_Text_Content(doc, node, new_text)
Delete_Node(doc, node)  -- Uses tombstone pattern
Child_Count(doc, node) -> Natural
Child_At(doc, node, index) -> Node_Ref
```

### Lesson 5: Complex Queries and Reports
**Concepts**: Document analysis, Filtering, Aggregation

- Find high-priority tasks
- Identify tasks with dependencies
- Generate summary statistics
- Build custom reports
- Analyze task relationships

**Advanced Techniques**:
- Traversing nested structures
- Building indexes for efficiency
- Aggregating data across nodes
- Filtering based on multiple criteria

## File Organization

```
sml_examples/
├── fixtures/
│   ├── tasks.schema.sml          # Schema definition
│   ├── tasks_simple.sml          # Basic valid document
│   ├── tasks_complex.sml         # Complex document with all features
│   └── tasks_invalid.sml         # Invalid document for testing
├── src/
│   └── task_manager_tutorial.adb # Tutorial implementation
└── bin/
    └── task_manager_tutorial      # Compiled executable
```

## Running the Tutorial

### Prerequisites

1. Install Alire (Ada package manager)
2. Clone the SML library repository
3. Ensure Ada 2022 compiler is available

### Build Steps

```bash
# Build all components
cd sml && alr build
cd ../sml_io && alr build
cd ../sml_examples && alr build
```

### Execute Tutorial

```bash
cd sml_examples
alr run task_manager_tutorial
```

Or directly:
```bash
cd sml_examples
./bin/task_manager_tutorial
```

## Expected Output

The tutorial will:

1. Parse and analyze simple task lists
2. Validate documents against the schema
3. Create new task databases programmatically
4. Modify existing tasks (todo → in_progress)
5. Generate reports on high-priority tasks and dependencies

Each lesson includes:
- Clear section headers
- Step-by-step explanations
- Success/error messages
- Summary statistics

## Extending the Tutorial

### Additional Features to Implement

1. **Task Assignment**: Find all tasks assigned to a specific user
2. **Deadline Tracking**: Identify overdue tasks
3. **Progress Calculation**: Calculate completion percentage
4. **Time Tracking**: Sum hours worked per task/project
5. **Dependency Resolution**: Order tasks by dependencies
6. **Gantt Chart Data**: Export timeline visualization data

### Schema Extensions

Consider adding:
- Task attachments/links
- Comment threads
- Task history/audit trail
- Custom fields
- Recurring tasks
- Task templates

### Performance Considerations

With default memory settings:
- Max 2,000 nodes per document
- Max 200KB total string storage
- Suitable for ~1000 tasks with full details

For larger datasets, adjust in `SML.Memory_Model`:
```ada
Max_Document_Nodes : constant := 10_000;
Max_String_Storage : constant := 1_000_000;
```

## Benefits of Formal Verification

This tutorial demonstrates how SPARK verification ensures:

1. **Memory Safety**: No buffer overflows or memory leaks
2. **Bounds Checking**: Array accesses always in range
3. **Type Safety**: Strong typing prevents data corruption
4. **Logic Correctness**: Mathematical proofs of algorithm behavior
5. **Absence of Runtime Errors**: Proven at compile time

For a task management system, this means:
- Tasks can't be lost due to memory corruption
- Priority values are guaranteed to be 1-5
- Dates are always valid
- Parent-child relationships remain consistent
- No crashes from malformed input

## Common Patterns

### Iterating Over All Tasks
```ada
Tasks_Node := Find_Element(Doc, Root, "tasks");
Task := First_Child(Doc, Tasks_Node);
while Is_Valid_Node(Doc, Task) loop
   if Name(Doc, Task) = "task" then
      Process_Task(Doc, Task);
   end if;
   Task := Next_Sibling(Doc, Task);
end loop;
```

### Finding Element by Name
```ada
function Find_Child_Element(Doc : Document;
                           Parent : Node_Ref;
                           Name : String) return Node_Ref is
   Child : Node_Ref := First_Child(Doc, Parent);
begin
   while Is_Valid_Node(Doc, Child) loop
      if Kind(Doc, Child) = Element and then
         Name(Doc, Child) = Name then
         return Child;
      end if;
      Child := Next_Sibling(Doc, Child);
   end loop;
   return Invalid_Node_Ref;
end Find_Child_Element;
```

### Getting Text Content
```ada
function Get_Element_Text(Doc : Document;
                         Element : Node_Ref) return String is
   Text_Node : constant Node_Ref := First_Child(Doc, Element);
begin
   if Is_Valid_Node(Doc, Text_Node) and then
      Kind(Doc, Text_Node) = Text then
      return Text_Value(Doc, Text_Node);
   end if;
   return "";
end Get_Element_Text;
```

## Troubleshooting

### Common Issues

1. **Parse Errors**: Check for well-formed SML (matching tags, proper nesting)
2. **Schema Validation Failures**: Review error location (XPath) and constraint details
3. **Memory Limits**: Increase limits in Memory_Model for large documents
4. **File Not Found**: Use absolute paths or ensure working directory is correct

### Debugging Tips

- Enable verbose output in parser for detailed trace
- Use `Is_Well_Formed` before schema validation
- Check `Child_Count` when traversing
- Validate incrementally when building documents

## Next Steps

After completing this tutorial, you can:

1. Build your own SML-based applications
2. Extend the task manager with new features
3. Create custom schemas for your domain
4. Contribute to the SML library development
5. Apply formal verification to your Ada projects

## Resources

- [SML Library Documentation](../sml/README.md)
- [SPARK User Guide](https://docs.adacore.com/spark2014-docs/)
- [Ada 2022 Reference Manual](http://www.ada-auth.org/standards/22rm/html/RM-TOC.html)
- [Alire Package Manager](https://alire.ada.dev/)

## Conclusion

This tutorial demonstrates that formally verified XML processing is both practical and accessible. The SML library provides mathematical guarantees of correctness while maintaining good performance and usability.

The task management system serves as a foundation you can build upon, whether for learning, prototyping, or production use. The combination of Ada's strong typing and SPARK's formal verification creates exceptionally reliable software.

Happy coding with SML!