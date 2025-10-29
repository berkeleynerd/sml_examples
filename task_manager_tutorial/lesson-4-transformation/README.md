# Lesson 4: Document Transformation

## Overview

This lesson teaches the transformation pattern - the fundamental technique for "modifying" immutable parsed documents. You'll learn to combine parsing (reading) and building (writing) to transform existing documents into new ones, working with the SML library's limited type system rather than against it.

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Understand the transformation pattern** (parse → analyze → build → save)
2. **Extract data from parsed documents** through read-only traversal
3. **Build new documents based on extracted data** using the Builder API
4. **Filter documents** by selective copying
5. **Generate summary reports** from document analysis
6. **Work correctly with immutable parsed documents**
7. **Combine all previous lessons** into complete workflows

## Prerequisites

- Completion of **Lessons 1-3**
- Understanding of parsing, validation, and building
- Familiarity with DOM navigation and immutable documents
- Knowledge of the Builder API

## Building and Running

```bash
# Build the lesson
cd lesson-4-transformation
alr build

# Run previous lessons (still work!)
./bin/lesson_1_basic_parsing
./bin/lesson_2_schema_validation
./bin/lesson_3_building

# Run lesson 4 (new!)
./bin/lesson_4_transformation
```

## Expected Output

```
================================
  Lesson 4: Document Transformation
================================

This lesson demonstrates the transformation pattern:
  1. Parse source document (read-only)
  2. Analyze/traverse to extract data
  3. Build new transformed document
  4. Save the result

This pattern works WITH the limited type system,
not against it. We never try to modify parsed documents.

================================
  Example 1: Summary Report Generation
================================

Creating task summary report...
[OK] Summary report saved to task_summary.sml
  Total tasks:  3
  Completed:  1
  Pending:  2

================================
  Example 2: Active Tasks Filter
================================

Creating active tasks document...
[OK] Filtered document saved
  Active tasks:  2

================================
  Transformation Pattern Summary
================================

Key takeaways:
  * Never modify parsed documents (they're limited/immutable)
  * Use read-only traversal to extract data
  * Build fresh documents for output
  * This pattern is safer and more functional
  * Works perfectly with formal verification
```

## Key Concepts

### The Transformation Pattern

The transformation pattern is the cornerstone of document processing with immutable parsed documents:

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Parse   │ → │ Analyze  │ → │  Build   │ → │   Save   │
│  Source  │   │ Extract  │   │   New    │   │  Result  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
```

**Why This Pattern:**
- Parsed documents are immutable (limited types)
- Cannot modify in place
- Must create new documents for outputs
- Separates reading from writing
- Enables formal verification
- Prevents accidental corruption

### Step 1: Parse (Read)

Load the source document in read-only mode:

```ada
declare
   Source : constant Parse_Result := Parse_File("input.sml");
begin
   if not Source.Success then
      Put_Line("Parse error: " &
         Source.Error.Message(1 .. Source.Error.Msg_Length));
      return;
   end if;

   --  Source.Doc is immutable - can only read, never write
end;
```

**Key points:**
- Use `constant` to emphasize immutability
- Always check `Success` before using
- Document is valid only within this scope

### Step 2: Analyze (Extract)

Traverse the source document to extract needed data:

```ada
--  Extract statistics from source
declare
   Root : constant Node_Id := SML.DOM.Root(Source.Doc);
   Tasks_Node, Task_Node : Node_Id;
   Task_Count : Natural := 0;
begin
   --  Find tasks container
   Tasks_Node := First_Child(Source.Doc, Root);
   while Tasks_Node /= Null_Node loop
      if Kind(Source.Doc, Tasks_Node) = Element and then
         Name(Source.Doc, Tasks_Node) = "tasks"
      then
         exit;
      end if;
      Tasks_Node := Next_Sibling(Source.Doc, Tasks_Node);
   end loop;

   --  Count tasks
   if Tasks_Node /= Null_Node then
      Task_Node := First_Child(Source.Doc, Tasks_Node);
      while Task_Node /= Null_Node loop
         if Kind(Source.Doc, Task_Node) = Element and then
            Name(Source.Doc, Task_Node) = "task"
         then
            Task_Count := Task_Count + 1;
         end if;
         Task_Node := Next_Sibling(Source.Doc, Task_Node);
      end loop;
   end if;

   --  Now have extracted data: Task_Count
end;
```

**Key points:**
- Only read operations (First_Child, Next_Sibling, Text_Value)
- Build data structures (variables, arrays) from document
- Never try to modify source document

### Step 3: Build (Transform)

Create a new document using extracted/transformed data:

```ada
--  Build new document from extracted data
declare
   Report : Document := Create_Document("summary");
   Root : constant Node_Id := SML.DOM.Root(Report);
   Stats_Node, Count_Node, Temp : Node_Id;
begin
   Add_Child_Element(Report, Root, "statistics", Stats_Node);

   Add_Child_Element(Report, Stats_Node, "task_count", Count_Node);
   Add_Text_Node(Report, Count_Node,
      Natural'Image(Task_Count), Temp);

   --  Report now contains transformed data
end;
```

**Key points:**
- Use Builder API (from Lesson 3)
- Build entirely new structure
- Can aggregate, filter, or restructure
- Document variable is mutable (no `constant`)

### Step 4: Save (Write)

Write the transformed document to a file:

```ada
declare
   Result : constant Write_Result :=
      Write_Document("output.sml", Report, Formatted => True);
begin
   if Result.Status = Success then
      Put_Line("Saved" & Natural'Image(Result.Bytes_Written) & " bytes");
   else
      Put_Line("Error: " & To_String(Result.Error_Message));
   end if;
end;
```

**Key points:**
- Use Write_Document (from Lesson 3)
- Check Write_Result.Status
- Report file size and errors

### Why Not Modify In Place?

The SML library intentionally prevents in-place modification:

```ada
--  ✗ This DOES NOT compile
declare
   Source : constant Parse_Result := Parse_File("doc.sml");
   Root : constant Node_Id := SML.DOM.Root(Source.Doc);
   New_Child : Node_Id;
begin
   --  ERROR: Source.Doc is a constant, cannot modify
   Add_Child_Element(Source.Doc, Root, "new", New_Child);
end;
```

**Reasons for immutability:**
1. **Safety**: Prevents accidental corruption
2. **Verification**: Formal proofs require immutability
3. **Correctness**: Parsing validates structure once
4. **Clarity**: Read and write are separate operations

## Code Structure

The lesson demonstrates two transformation patterns:

### 1. Summary Report Generation

**Purpose:** Analyze source document and produce statistics

**Pattern:**
```ada
1. Parse source tasks document
2. Traverse tasks and count by status
3. Build summary document with statistics
4. Save summary report
```

**Example transformation:**

Input (`tasks_simple_sml.sml`):
```xml
<task_database>
  <tasks>
    <task>
      <title>Create wireframes</title>
      <status>done</status>
    </task>
    <task>
      <title>Implement navigation</title>
      <status>in_progress</status>
    </task>
    <task>
      <title>Design color scheme</title>
      <status>todo</status>
    </task>
  </tasks>
</task_database>
```

Output (`task_summary.sml`):
```xml
<task_summary>
  <statistics>
    <total_tasks> 3</total_tasks>
    <completed_tasks> 1</completed_tasks>
    <pending_tasks> 2</pending_tasks>
  </statistics>
</task_summary>
```

### 2. Active Tasks Filter

**Purpose:** Filter document by selective copying

**Pattern:**
```ada
1. Parse source tasks document
2. Traverse tasks and test filter condition
3. Build new document with only matching tasks
4. Save filtered document
```

**Example transformation:**

Input (all tasks):
```xml
<task_database>
  <tasks>
    <task><title>Task 1</title><status>todo</status></task>
    <task><title>Task 2</title><status>in_progress</status></task>
    <task><title>Task 3</title><status>done</status></task>
  </tasks>
</task_database>
```

Output (active tasks only):
```xml
<active_tasks>
  <tasks>
    <task>Active task  1</task>
    <task>Active task  2</task>
  </tasks>
</active_tasks>
```

## Common Patterns

### Complete Transformation Workflow

```ada
procedure Transform_Document is
begin
   --  Step 1: Parse source
   declare
      Source : constant Parse_Result := Parse_File("input.sml");
   begin
      if not Source.Success then
         Put_Line("Parse failed");
         return;
      end if;

      --  Step 2: Extract data
      declare
         Root : constant Node_Id := SML.DOM.Root(Source.Doc);
         Data : My_Data_Type;  --  Your extracted data structure
      begin
         --  Traverse Source.Doc and populate Data
         Extract_Data(Source.Doc, Root, Data);

         --  Step 3: Build new document
         declare
            Output : Document := Create_Document("result");
            Out_Root : constant Node_Id := SML.DOM.Root(Output);
         begin
            --  Build Output using Data
            Build_Output(Output, Out_Root, Data);

            --  Step 4: Save result
            declare
               Result : constant Write_Result :=
                  Write_Document("output.sml", Output, Formatted => True);
            begin
               if Result.Status = Success then
                  Put_Line("Transformation complete");
               end if;
            end;
         end;
      end;
   end;
end Transform_Document;
```

### Extract-Transform-Load Pattern

```ada
--  1. Extract: Pull data into Ada structures
type Task_Data is record
   Title : String(1..100);
   Title_Len : Natural;
   Priority : Natural;
   Status : Task_Status;
end record;

Tasks : array (1 .. 100) of Task_Data;
Task_Count : Natural := 0;

--  Extract from document
--  ... traverse and populate Tasks array ...

--  2. Transform: Process the data
for I in 1 .. Task_Count loop
   if Tasks(I).Status = Active then
      --  Include in output
   end if;
end loop;

--  3. Load: Build new document
--  ... create document and populate from Tasks array ...
```

### Filtering Pattern

```ada
--  Filter predicate
function Should_Include(Doc : Document; Task_Node : Node_Id)
   return Boolean is
   Status_Node : Node_Id := First_Child(Doc, Task_Node);
begin
   while Status_Node /= Null_Node loop
      if Kind(Doc, Status_Node) = Element and then
         Name(Doc, Status_Node) = "status"
      then
         declare
            Text : constant Node_Id := First_Child(Doc, Status_Node);
         begin
            if Text /= Null_Node and then Kind(Doc, Text) = SML.DOM.Text then
               return Text_Value(Doc, Text) /= "done";
            end if;
         end;
      end if;
      Status_Node := Next_Sibling(Doc, Status_Node);
   end loop;
   return False;
end Should_Include;

--  Apply filter
Task_Node := First_Child(Source.Doc, Tasks_Parent);
while Task_Node /= Null_Node loop
   if Should_Include(Source.Doc, Task_Node) then
      --  Copy task to output
      Copy_Task(Output, Output_Parent, Source.Doc, Task_Node);
   end if;
   Task_Node := Next_Sibling(Source.Doc, Task_Node);
end loop;
```

### Aggregation Pattern

```ada
--  Aggregate statistics
declare
   Status_Counts : array (Task_Status) of Natural := (others => 0);
begin
   --  Count each status
   Task_Node := First_Child(Source.Doc, Tasks_Node);
   while Task_Node /= Null_Node loop
      --  Determine status
      Status := Get_Task_Status(Source.Doc, Task_Node);
      Status_Counts(Status) := Status_Counts(Status) + 1;

      Task_Node := Next_Sibling(Source.Doc, Task_Node);
   end loop;

   --  Build summary from counts
   for Status in Task_Status loop
      Add_Stat_Element(Report, Status, Status_Counts(Status));
   end loop;
end;
```

### Restructuring Pattern

```ada
--  Input structure:
--  <tasks>
--    <task><priority>1</priority>...
--    <task><priority>2</priority>...
--    <task><priority>1</priority>...

--  Output structure:
--  <tasks_by_priority>
--    <priority level="1">
--      <task>...
--      <task>...
--    </priority>
--    <priority level="2">
--      <task>...

--  Extract tasks into arrays by priority
declare
   Tasks_By_Priority : array (1 .. 5) of Task_Array;
begin
   --  Sort into arrays
   --  ...

   --  Build grouped structure
   for Priority in 1 .. 5 loop
      Add_Child_Element(Output, Root, "priority", Priority_Node);
      for Task of Tasks_By_Priority(Priority) loop
         --  Add task
      end loop;
   end loop;
end;
```

## API Reference

This lesson combines APIs from previous lessons:

### From Lesson 1: Parsing
- `Parse_File(Path)` → `Parse_Result`
- `Root(Doc)` → `Node_Id`
- `First_Child(Doc, Node)` → `Node_Id`
- `Next_Sibling(Doc, Node)` → `Node_Id`
- `Kind(Doc, Node)` → `Node_Kind`
- `Name(Doc, Node)` → `String`
- `Text_Value(Doc, Node)` → `String`

### From Lesson 3: Building
- `Create_Document(Root_Name)` → `Document`
- `Add_Child_Element(Doc, Parent, Name, New_Node)`
- `Add_Text_Node(Doc, Parent, Text, Text_Node)`
- `Serialize_Formatted(Doc, Indent)` → `String`
- `Write_Document(Path, Doc, Formatted)` → `Write_Result`

### Transformation-Specific Patterns

**No new API**, but new usage patterns:

1. **Nested Scope Pattern** - Parse in outer scope, build in inner
2. **Data Structure Bridging** - Extract to Ada types, then rebuild
3. **Selective Copying** - Filter during traversal
4. **Aggregation** - Count/compute during traversal, then build summary

## Troubleshooting

### Cannot Modify Parsed Document

**Problem:** Compiler error when trying to add elements to parsed document

**Solution:** This is correct behavior. Use the transformation pattern:

```ada
--  ✗ Wrong
Source_Parse : constant Parse_Result := Parse_File("in.sml");
Add_Child_Element(Source_Parse.Doc, Root, "new", Child);  -- ERROR

--  ✓ Correct
Source_Parse : constant Parse_Result := Parse_File("in.sml");
--  ... extract data from Source_Parse.Doc ...

Output : Document := Create_Document("result");
Add_Child_Element(Output, Output_Root, "new", Child);  -- OK
```

### Scope Issues

**Problem:** Document not available where needed

**Solution:** Ensure source document scope contains extraction and building:

```ada
--  ✓ Correct - Source in scope for entire transformation
declare
   Source : constant Parse_Result := Parse_File("in.sml");
begin
   --  Extract
   declare
      Data : My_Data;
   begin
      Extract(Source.Doc, Data);

      --  Build (Source still in scope if needed)
      declare
         Output : Document := Create_Document("out");
      begin
         Build(Output, Data);
      end;
   end;
end;
```

### Memory Limits During Transform

**Problem:** Transformation fails with Storage_Error

**Solution:** Transform in batches or stream:

```ada
--  Instead of loading entire document:
--  1. Extract IDs or small metadata
--  2. Process in batches
--  3. Build output incrementally
```

### Performance Issues

**Problem:** Transformation is slow

**Solution:** Minimize traversals:

```ada
--  ✗ Bad - multiple full traversals
Count := Count_Tasks(Source.Doc);
Done := Count_Done(Source.Doc);
Pending := Count_Pending(Source.Doc);

--  ✓ Good - single traversal
(Count, Done, Pending) := Count_All_Stats(Source.Doc);
```

## Important Notes

### Transformation vs Modification

**Important distinction:**
- **Modification**: Change existing document in place (impossible with SML)
- **Transformation**: Create new document based on old (the SML way)

```ada
--  Modification (not possible):
--  parsed_doc.change_element("title", "new value")

--  Transformation (the SML way):
--  1. Parse old document
--  2. Extract title value
--  3. Build new document with new value
--  4. Save new document
```

### Functional Programming Style

Transformation follows functional programming principles:

- **Immutability**: Source documents never change
- **Pure Functions**: Extract operations have no side effects
- **Data Flow**: Clear pipeline from input to output
- **Composability**: Can chain transformations

```ada
--  Functional pipeline
Input → Parse → Extract → Transform → Build → Write → Output
```

### Performance Considerations

Transformation creates new documents, which has tradeoffs:

**Advantages:**
- ✅ Safe (no corruption)
- ✅ Verifiable (formal proofs)
- ✅ Parallelizable (multiple readers)

**Disadvantages:**
- ❌ More memory (two documents in memory)
- ❌ More CPU (traverse + build)
- ❌ More I/O (read + write)

**When to use:**
- Documents are small to medium (< 1MB)
- Safety is critical
- Transformation is infrequent
- Need formal verification

### Combining with Validation

Validate both source and output:

```ada
--  1. Parse and validate source
Source_Parse := Parse_File("input.sml");
--  ... validate Source_Parse.Doc against input schema ...

--  2. Transform
--  ... extract and build ...

--  3. Validate output before saving
Output_Valid := Validate_Document(Output_Schema, Output);
if Output_Valid.Status = Valid then
   Write_Document("output.sml", Output, Formatted => True);
else
   Put_Line("Output validation failed!");
end if;
```

## Exercise Ideas

Try extending this lesson:

1. **Update transformation** - Parse tasks, modify priority values, rebuild
2. **Merge transformation** - Combine multiple source documents into one
3. **Split transformation** - Divide document by criteria into multiple outputs
4. **Enrich transformation** - Add computed fields (e.g., completion percentage)
5. **Format transformation** - Convert structure (e.g., flat to nested)
6. **Validation transformation** - Fix invalid documents automatically
7. **Diff transformation** - Compare two documents, generate differences report
8. **Template application** - Fill template with data from source document

## Next Steps

Proceed to **Lesson 5: Analysis and Queries** to learn advanced document analysis techniques including complex queries, statistical analysis, and generating comprehensive reports from document data.

---

**Lesson 4 of 5** | [← Previous: Lesson 3](../lesson-3-building-documents/README.md) | [Next: Lesson 5 →](../lesson-5-analysis/README.md)
