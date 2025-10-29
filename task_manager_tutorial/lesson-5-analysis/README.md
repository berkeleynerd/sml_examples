# Lesson 5: Document Analysis and Queries

## Overview

This final lesson teaches advanced document analysis and querying techniques. You'll learn to collect statistics, find elements matching specific criteria, and generate comprehensive reports - all using read-only traversal patterns that respect document immutability.

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Collect document statistics** through traversal and aggregation
2. **Query documents** to find elements matching criteria
3. **Build analysis helpers** with reusable predicates
4. **Generate comprehensive reports** as new documents
5. **Apply all previous lessons** to real-world analysis tasks
6. **Master the complete SML workflow** from parsing to reporting

## Prerequisites

- Completion of **Lessons 1-4**
- Understanding of parsing, validation, building, and transformation
- Familiarity with traversal patterns and document immutability

## Building and Running

```bash
# Build the lesson
cd lesson-5-analysis
alr build

# Run all previous lessons (they still work!)
./bin/lesson_1_basic_parsing
./bin/lesson_2_schema_validation
./bin/lesson_3_building
./bin/lesson_4_transformation

# Run lesson 5 (completes the tutorial!)
./bin/lesson_5_analysis
```

## Expected Output

```
================================
  Lesson 5: Document Analysis and Queries
================================

This lesson demonstrates how to:
  1. Traverse documents to collect statistics
  2. Find elements matching specific criteria
  3. Generate analysis reports
  4. Work with read-only document queries

Key patterns:
  * Documents are read-only after parsing
  * Use traversal to collect information
  * Build new documents for reports
  * Never modify parsed documents

================================
  Example 1: Collecting Task Statistics
================================

Analyzing task database...
Analysis Results:
  Total Tasks:       3
  Todo:             1
  In Progress:      1
  Done:             1
  High Priority:    1

================================
  Example 2: Finding Tasks by Status
================================

Finding tasks with status: todo
----------------------------------------
  - Design color scheme
Found 1 task(s)

Finding tasks with status: done
----------------------------------------
  - Create wireframes
Found 1 task(s)

================================
  Example 3: Generating Analysis Report
================================

Creating analysis report document...
[OK] Analysis report saved to analysis_report.sml

================================
  Document Analysis Summary
================================

Key takeaways:
  * Parse documents are immutable (limited types)
  * Traverse using First_Child/Next_Sibling pattern
  * Collect data into records or variables
  * Generate new documents for output
  * This pattern ensures memory safety

The read-only traversal pattern is:
  1. Parse source document
  2. Traverse nodes collecting data
  3. Analyze collected information
  4. Build new documents for results
```

## Key Concepts

### Statistical Analysis

Collect aggregate statistics from documents through single-pass traversal:

```ada
--  Define statistics record
type Task_Stats is record
   Total_Count : Natural := 0;
   Todo_Count : Natural := 0;
   In_Progress_Count : Natural := 0;
   Done_Count : Natural := 0;
   High_Priority_Count : Natural := 0;
end record;

--  Collect in single pass
Stats : Task_Stats;
Task_Node := First_Child(Doc, Tasks_Container);
while Task_Node /= Null_Node loop
   Analyze_Task(Doc, Task_Node, Stats);  --  Updates Stats
   Task_Node := Next_Sibling(Doc, Task_Node);
end loop;

--  Now Stats contains complete analysis
```

**Benefits:**
- Single traversal (efficient)
- Aggregate multiple metrics simultaneously
- Clear data structure
- Reusable analysis procedure

### Query by Criteria

Find specific elements matching predicates:

```ada
--  Query: Find tasks with status="todo"
procedure Find_Tasks_By_Status(Doc : Document; Status_Filter : String) is
   Task_Node : Node_Id := First_Child(Doc, Tasks_Container);
   Found_Count : Natural := 0;
begin
   while Task_Node /= Null_Node loop
      if Kind(Doc, Task_Node) = Element and then
         Name(Doc, Task_Node) = "task"
      then
         --  Get status of this task
         declare
            Status : constant String := Get_Status(Doc, Task_Node);
         begin
            if Status = Status_Filter then
               Found_Count := Found_Count + 1;
               --  Process matched task
               Display_Task(Doc, Task_Node);
            end if;
         end;
      end if;
      Task_Node := Next_Sibling(Doc, Task_Node);
   end loop;

   Put_Line("Found" & Natural'Image(Found_Count) & " task(s)");
end Find_Tasks_By_Status;
```

**Pattern:**
- Iterate through candidate elements
- Apply filter predicate
- Process matches
- Report results

### Report Generation

Build new documents containing analysis results:

```ada
procedure Generate_Analysis_Report(Stats : Task_Stats) is
   Report : Document := Create_Document("analysis_report");
   Root : constant Node_Id := SML.DOM.Root(Report);
   Summary, Breakdown, Temp : Node_Id;
begin
   --  Add summary section
   Add_Child_Element(Report, Root, "summary", Summary);

   Add_Child_Element(Report, Summary, "total_tasks", Temp);
   Add_Text_Node(Report, Temp, Natural'Image(Stats.Total_Count), Temp);

   --  Add detailed breakdown
   Add_Child_Element(Report, Root, "status_breakdown", Breakdown);

   Add_Child_Element(Report, Breakdown, "todo", Temp);
   Add_Text_Node(Report, Temp, Natural'Image(Stats.Todo_Count), Temp);

   --  ... more fields ...

   --  Save report
   Result := Write_Document("analysis_report.sml", Report, Formatted => True);
end Generate_Analysis_Report;
```

**Structure:**
```xml
<analysis_report>
  <summary>
    <total_tasks> 3</total_tasks>
    <high_priority_tasks> 1</high_priority_tasks>
  </summary>
  <status_breakdown>
    <todo> 1</todo>
    <in_progress> 1</in_progress>
    <done> 1</done>
  </status_breakdown>
</analysis_report>
```

## Code Structure

The lesson demonstrates three analysis patterns:

### 1. Statistical Collection

**Purpose:** Gather aggregate statistics in single traversal

**Implementation:**
```ada
--  Analysis procedure
procedure Analyze_Task(Doc : Document; Task_Node : Node_Id;
                       Stats : in out Task_Stats) is
begin
   Stats.Total_Count := Stats.Total_Count + 1;

   --  Analyze status
   Status_Text := Get_Child_Text(Doc, Task_Node, "status");
   if Status_Text = "todo" then
      Stats.Todo_Count := Stats.Todo_Count + 1;
   elsif Status_Text = "in_progress" then
      Stats.In_Progress_Count := Stats.In_Progress_Count + 1;
   elsif Status_Text = "done" then
      Stats.Done_Count := Stats.Done_Count + 1;
   end if;

   --  Analyze priority
   Priority_Text := Get_Child_Text(Doc, Task_Node, "priority");
   if Priority_Text'Length > 0 and then
      Priority_Text(Priority_Text'First) = '1'
   then
      Stats.High_Priority_Count := Stats.High_Priority_Count + 1;
   end if;
end Analyze_Task;

--  Usage
Task_Node := First_Child(Doc, Tasks);
while Task_Node /= Null_Node loop
   Analyze_Task(Doc, Task_Node, Stats);
   Task_Node := Next_Sibling(Doc, Task_Node);
end loop;
```

### 2. Query by Criteria

**Purpose:** Find and display elements matching conditions

**Implementation:**
```ada
procedure Find_Tasks_By_Status(Doc : Document; Status_Filter : String) is
   Found_Count : Natural := 0;
begin
   Task_Node := First_Child(Doc, Tasks_Container);
   while Task_Node /= Null_Node loop
      if Is_Task(Doc, Task_Node) then
         Status := Get_Status(Doc, Task_Node);
         if Status = Status_Filter then
            Found_Count := Found_Count + 1;

            --  Display matched task
            Title := Get_Title(Doc, Task_Node);
            Put_Line("  - " & Title);
         end if;
      end if;
      Task_Node := Next_Sibling(Doc, Task_Node);
   end loop;

   Put_Line("Found" & Natural'Image(Found_Count) & " task(s)");
end Find_Tasks_By_Status;
```

### 3. Report Generation

**Purpose:** Create structured documents from analysis results

**Pattern:**
1. Collect statistics (Example 1)
2. Build report document (using Builder API)
3. Save report (using Writer API)
4. Result is a new immutable document

## Common Patterns

### Single-Pass Multiple-Statistic Collection

```ada
--  Collect many statistics in one traversal
procedure Comprehensive_Analysis(Doc : Document) is
   type Analysis_Data is record
      Task_Count : Natural := 0;
      Priority_Sum : Natural := 0;
      Status_Counts : array (Task_Status) of Natural := (others => 0);
      Users : User_Set;  --  Set of assigned users
      --  ... more metrics ...
   end record;

   Data : Analysis_Data;
begin
   Task_Node := First_Child(Doc, Tasks);
   while Task_Node /= Null_Node loop
      --  Count task
      Data.Task_Count := Data.Task_Count + 1;

      --  Sum priority
      Data.Priority_Sum := Data.Priority_Sum + Get_Priority(Doc, Task_Node);

      --  Count by status
      Status := Get_Status(Doc, Task_Node);
      Data.Status_Counts(Status) := Data.Status_Counts(Status) + 1;

      --  Collect users
      User := Get_Assigned_To(Doc, Task_Node);
      Insert(Data.Users, User);

      Task_Node := Next_Sibling(Doc, Task_Node);
   end loop;

   --  Compute derived metrics
   Avg_Priority := Data.Priority_Sum / Data.Task_Count;
   User_Count := Size(Data.Users);

   --  Display or save results
end Comprehensive_Analysis;
```

**Benefits:**
- O(n) complexity (single pass)
- Collects multiple metrics
- More efficient than separate queries

### Query with Multiple Criteria

```ada
--  Find tasks matching multiple conditions
function Matches_Criteria(Doc : Document; Task_Node : Node_Id;
                          Min_Priority : Natural;
                          Status_Filter : String) return Boolean is
begin
   --  Check priority
   Priority := Get_Priority(Doc, Task_Node);
   if Priority < Min_Priority then
      return False;
   end if;

   --  Check status
   Status := Get_Status(Doc, Task_Node);
   if Status /= Status_Filter then
      return False;
   end if;

   --  All criteria met
   return True;
end Matches_Criteria;

--  Usage
Task_Node := First_Child(Doc, Tasks);
while Task_Node /= Null_Node loop
   if Matches_Criteria(Doc, Task_Node, Min_Priority => 1,
                       Status_Filter => "in_progress")
   then
      --  Process matching task
      Add_To_Results(Task_Node);
   end if;
   Task_Node := Next_Sibling(Doc, Task_Node);
end loop;
```

### Helper Function Pattern

Build reusable extraction helpers:

```ada
--  Get child element's text content
function Get_Child_Text(Doc : Document; Parent : Node_Id;
                       Child_Name : String) return String is
   Child : Node_Id := First_Child(Doc, Parent);
begin
   while Child /= Null_Node loop
      if Kind(Doc, Child) = Element and then
         Name(Doc, Child) = Child_Name
      then
         declare
            Text_Node : constant Node_Id := First_Child(Doc, Child);
         begin
            if Text_Node /= Null_Node and then
               Kind(Doc, Text_Node) = Text
            then
               return Text_Value(Doc, Text_Node);
            end if;
         end;
      end if;
      Child := Next_Sibling(Doc, Child);
   end loop;
   return "";  --  Not found
end Get_Child_Text;

--  Usage
Title := Get_Child_Text(Doc, Task_Node, "title");
Status := Get_Child_Text(Doc, Task_Node, "status");
Priority_Text := Get_Child_Text(Doc, Task_Node, "priority");
```

### Predicate Pattern

```ada
--  Predicate: Is this task high priority?
function Is_High_Priority(Doc : Document; Task_Node : Node_Id)
   return Boolean is
   Priority_Text : constant String :=
      Get_Child_Text(Doc, Task_Node, "priority");
begin
   if Priority_Text'Length > 0 then
      declare
         Priority : constant Natural := Natural'Value(Priority_Text);
      begin
         return Priority <= 2;  --  1 and 2 are high priority
      end;
   end if;
   return False;
exception
   when Constraint_Error =>
      return False;  --  Invalid priority
end Is_High_Priority;

--  Usage in query
if Is_High_Priority(Doc, Task_Node) then
   High_Priority_Count := High_Priority_Count + 1;
end if;
```

## API Reference

This lesson uses APIs from all previous lessons:

### From Lesson 1: Parsing and Navigation
- `Parse_File(Path)` → `Parse_Result`
- `Root(Doc)` → `Node_Id`
- `First_Child(Doc, Node)` → `Node_Id`
- `Next_Sibling(Doc, Node)` → `Node_Id`
- `Kind(Doc, Node)` → `Node_Kind`
- `Name(Doc, Node)` → `String`
- `Text_Value(Doc, Node)` → `String`

### From Lesson 3: Building and Writing
- `Create_Document(Root_Name)` → `Document`
- `Add_Child_Element(Doc, Parent, Name, New_Node)`
- `Add_Text_Node(Doc, Parent, Text, Text_Node)`
- `Write_Document(Path, Doc, Formatted)` → `Write_Result`

### Analysis-Specific Patterns

**No new API**, but advanced usage patterns:

1. **Statistics Collection** - Aggregate during traversal
2. **Query Predicates** - Filter elements by criteria
3. **Helper Functions** - Reusable extraction utilities
4. **Report Building** - Structure analysis results

## Troubleshooting

### Performance Issues with Multiple Queries

**Problem:** Slow performance when running many queries

**Solution:** Combine into single-pass analysis:

```ada
--  ✗ Bad - multiple traversals
Todo_Count := Count_By_Status(Doc, "todo");
In_Progress_Count := Count_By_Status(Doc, "in_progress");
Done_Count := Count_By_Status(Doc, "done");

--  ✓ Good - single traversal
(Todo_Count, In_Progress_Count, Done_Count) := Count_All_Statuses(Doc);
```

### String Comparison Issues

**Problem:** Status comparisons failing unexpectedly

**Solution:** Handle leading/trailing whitespace:

```ada
--  Helper to trim whitespace
function Trim(S : String) return String is
   First : Natural := S'First;
   Last : Natural := S'Last;
begin
   --  Trim leading spaces
   while First <= Last and then S(First) = ' ' loop
      First := First + 1;
   end loop;

   --  Trim trailing spaces
   while Last >= First and then S(Last) = ' ' loop
      Last := Last - 1;
   end loop;

   return S(First .. Last);
end Trim;

--  Usage
Status := Trim(Get_Child_Text(Doc, Task_Node, "status"));
if Status = "todo" then  --  Now works reliably
   ...
end if;
```

### Missing Elements

**Problem:** Queries fail when expected elements are missing

**Solution:** Always check for Null_Node:

```ada
--  ✓ Safe helper
function Get_Child_Text(Doc : Document; Parent : Node_Id;
                       Child_Name : String) return String is
begin
   if Parent = Null_Node then
      return "";  --  No parent
   end if;

   Child := First_Child(Doc, Parent);
   while Child /= Null_Node loop
      if Kind(Doc, Child) = Element and then
         Name(Doc, Child) = Child_Name
      then
         Text_Node := First_Child(Doc, Child);
         if Text_Node /= Null_Node and then
            Kind(Doc, Text_Node) = Text
         then
            return Text_Value(Doc, Text_Node);
         end if;
      end if;
      Child := Next_Sibling(Doc, Child);
   end loop;

   return "";  --  Not found
end Get_Child_Text;
```

## Important Notes

### Read-Only Analysis

All analysis operations are read-only:

```ada
--  ✓ Analysis (read-only)
Stats := Analyze_Document(Doc);

--  ✗ Cannot modify during analysis
--  Add_Child_Element(Doc, Root, "new", Child);  --  ERROR!
```

**Why read-only:**
- Ensures data integrity
- Enables parallel analysis
- Supports formal verification
- Prevents accidental corruption

### Building Analysis Reports

Analysis results are new documents:

```ada
--  Workflow:
--  1. Parse source (read-only)
--  2. Analyze and extract stats
--  3. Build report document (new, mutable)
--  4. Save report

Source → Analyze → Stats → Build Report → Save Report
```

### Combining with Validation

Validate source documents before analysis:

```ada
--  1. Parse
Source := Parse_File("tasks.sml");

--  2. Validate
Result := Validate_Document(Schema, Source.Doc);
if Result.Status /= Valid then
   Put_Line("Source validation failed");
   return;
end if;

--  3. Analyze (know data is valid)
Stats := Analyze_Document(Source.Doc);
```

## Exercise Ideas

Try extending this lesson:

1. **Completion percentage** - Calculate % of done tasks
2. **Priority distribution** - Count tasks by priority level (1-5)
3. **User workload analysis** - Count tasks per assigned user
4. **Overdue task detector** - Find tasks past due date
5. **Multi-criteria search** - Find tasks matching multiple filters
6. **Trend analysis** - Compare two snapshots, detect changes
7. **Export to CSV** - Build CSV report from analysis
8. **Dashboard document** - Create comprehensive status dashboard

## Tutorial Complete!

Congratulations! You've completed all 5 lessons and mastered the SML library.

### What You've Learned

✅ **Lesson 1**: Parsing documents and navigating the DOM
✅ **Lesson 2**: Validating documents against schemas
✅ **Lesson 3**: Building documents programmatically
✅ **Lesson 4**: Transforming documents (parse → build pattern)
✅ **Lesson 5**: Analyzing and querying documents

### Complete Workflow

You now understand the complete SML document processing workflow:

```
Input File
   ↓
Parse (L1) → Validate (L2) → Analyze (L5)
   ↓            ↓                ↓
Extract      Check          Collect Stats
   ↓            ↓                ↓
Transform (L4) ← Build (L3) ← Generate Report
   ↓                             ↓
Output File                  Report File
```

### Next Steps

**Apply what you've learned:**
1. Build your own domain-specific documents (configurations, data, reports)
2. Create validation schemas for your data
3. Implement transformations and analysis for your use case
4. Leverage formal verification for safety-critical applications

**Explore advanced topics:**
- Performance optimization for large documents
- Streaming processing for very large files
- Custom schema types and validation rules
- Integration with other Ada/SPARK systems

## Resources

- **SML Library Documentation**: Check the sml package documentation
- **Ada/SPARK Resources**: [learn.adacore.com](https://learn.adacore.com)
- **Tutorial Source**: Review the lesson source code
- **Community**: Ask questions in Ada forums and communities

---

**Lesson 5 of 5 - Tutorial Complete!** | [← Previous: Lesson 4](../lesson-4-transformation/README.md) | [🏠 Back to Main](../README.md)
