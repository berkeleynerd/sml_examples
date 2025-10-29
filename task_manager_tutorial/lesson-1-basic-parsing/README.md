# Lesson 1: Basic SML Parsing

## Overview

This lesson introduces the fundamentals of parsing SML documents using the SML library. You'll learn how to load documents from files, navigate the DOM tree, and extract information.

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Parse SML documents** from files using `Parse_File`
2. **Handle parse results** by checking for success or errors
3. **Navigate the DOM tree** using `First_Child`, `Next_Sibling`, and `Root`
4. **Identify node types** using the `Kind` function
5. **Extract text content** from elements
6. **Handle parse errors** with detailed error messages

## Prerequisites

- Ada 2022 compiler (GNAT)
- Alire package manager
- SML library (automatically fetched by Alire)

## Building and Running

```bash
# Build the lesson
cd lesson-1-basic-parsing
alr build

# Run the lesson
./bin/lesson_1_basic_parsing
```

## Expected Output

```
============================
  Lesson 1: Basic SML Parsing
============================

This lesson demonstrates:
  1. Parsing SML documents from files
  2. Navigating the DOM tree
  3. Extracting text content from elements
  4. Handling parse errors gracefully

=============================
  Part 1: Parsing a Valid Document
=============================

Loading fixtures/tasks_simple_sml.sml...

[OK] Document parsed successfully!

Task List:
----------
 1. [Priority 5] Implement login feature
   Status: todo
 2. [Priority 3] Write unit tests
   Status: in_progress
 3. [Priority 1] Update documentation
   Status: done

Task Summary by Status:
  Todo:         1
  In Progress:  1
  Done:         1
  -----------
  Total Tasks:  3

==========================
  Testing Error Handling
==========================

Attempting to parse an invalid document...

  [EXPECTED] Parse error detected:
  Error: Expected closing tag for 'task'
  Location: Line 8, Column 5

============================
  Lesson 1 Complete!
============================

You've learned how to:
  - Use Parse_File to load SML documents
  - Check Parse_Result.Success for parse errors
  - Navigate the DOM using First_Child and Next_Sibling
  - Extract text content from elements
  - Handle parse errors with detailed error messages

Next: Lesson 2 will teach you schema validation!
```

## Key Concepts

### Parse_Result

The `Parse_Result` type contains either a successfully parsed document or an error:

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

**Structure:**
```ada
type Parse_Result is record
   Success : Boolean;
   Doc : Document;        -- Valid only if Success = True
   Error : Parse_Error;   -- Valid only if Success = False
end record;
```

### Parse_Error

When parsing fails, the error contains diagnostic information:

```ada
type Parse_Error is record
   Message : String(1..256);  -- Error description
   Msg_Length : Natural;      -- Actual message length
   Line : Natural;            -- Line number where error occurred
   Column : Natural;          -- Column number where error occurred
end record;
```

**Accessing error information:**
```ada
if not Parse_Res.Success then
   Put_Line(Parse_Res.Error.Message(1 .. Parse_Res.Error.Msg_Length));
   Put_Line("Line:" & Natural'Image(Parse_Res.Error.Line));
   Put_Line("Column:" & Natural'Image(Parse_Res.Error.Column));
end if;
```

### Document Navigation

Documents are trees of nodes. Navigate using:

- `Root(Doc)` - Get the root element
- `First_Child(Doc, Node)` - Get first child of a node
- `Next_Sibling(Doc, Node)` - Get next sibling
- `Kind(Doc, Node)` - Get node type (Element, Text, etc.)
- `Name(Doc, Node)` - Get element name
- `Text_Value(Doc, Node)` - Get text content

### Node Types

The `Node_Kind` enumeration defines node types:

```ada
type Node_Kind is (Element, Text, Comment, Processing_Instruction);
```

**Most common types:**
- **Element** - Tags like `<task>`, `<title>`, etc.
- **Text** - Text content between tags
- **Comment** - XML comments `<!-- ... -->`

### Node References

**Node_Id** - Reference to a node in the document tree

```ada
type Node_Id is private;
Null_Node : constant Node_Id;  -- Represents no node
```

**Always check before using:**
```ada
if Node /= Null_Node then
   -- Safe to use Node
end if;
```

### Immutable Documents

Important: Parsed documents are **immutable** (read-only). They use Ada's limited types:
- Cannot be assigned or copied
- Can only be used within their declaration scope
- This ensures memory safety and prevents corruption

```ada
--  ✓ Correct - use constant with initialization
declare
   Parse_Res : constant Parse_Result := Parse_File("doc.sml");
begin
   if Parse_Res.Success then
      -- Work with Parse_Res.Doc here
   end if;
end;

--  ✗ Wrong - cannot assign limited types
Doc := Parse_Res.Doc;  -- Won't compile!
```

## Code Structure

The lesson program includes three main procedures:

1. **Display_Task_List** - Shows basic task information (title, status, priority)
2. **Count_Tasks_By_Status** - Aggregates tasks by their status field
3. **Test_Parse_Error** - Demonstrates error handling

These procedures demonstrate common DOM traversal patterns you'll use throughout the tutorial.

## Fixtures

### tasks_simple_sml.sml

A simple, well-formed task database with 3 tasks:

```xml
<task_database>
  <tasks>
    <task>
      <title>Create wireframes</title>
      <priority>1</priority>
      <status>done</status>
    </task>
    <task>
      <title>Implement responsive navigation</title>
      <priority>2</priority>
      <status>in_progress</status>
    </task>
    <task>
      <title>Design color scheme</title>
      <priority>3</priority>
      <status>todo</status>
    </task>
  </tasks>
</task_database>
```

**Purpose:** Demonstrates successful parsing and DOM navigation

### tasks_invalid.sml

An intentionally malformed document for testing error handling:

```xml
<task_database>
  <tasks>
    <task id="invalid"  <!-- Missing closing >
      <title>Broken task</title>
    </task>
  </tasks>
</task_database>
```

**Purpose:** Demonstrates parse error detection and reporting

## Common Patterns

### Finding a Named Child Element

```ada
function Find_Child_Element (Doc : Document;
                             Parent : Node_Id;
                             Element_Name : String) return Node_Id is
   Child : Node_Id := First_Child (Doc, Parent);
begin
   while Child /= Null_Node loop
      if Kind (Doc, Child) = Element and then
         Name (Doc, Child) = Element_Name then
         return Child;
      end if;
      Child := Next_Sibling (Doc, Child);
   end loop;
   return Null_Node;
end Find_Child_Element;
```

### Extracting Text Content

```ada
function Get_Element_Text (Doc : Document; Element : Node_Id) return String is
   Text_Node : constant Node_Id := First_Child (Doc, Element);
begin
   if Text_Node /= Null_Node and then Kind (Doc, Text_Node) = Text then
      return Text_Value (Doc, Text_Node);
   end if;
   return "";
end Get_Element_Text;
```

### Iterating Over Child Elements

```ada
declare
   Child : Node_Id := First_Child (Doc, Parent);
begin
   while Child /= Null_Node loop
      if Kind (Doc, Child) = Element then
         -- Process element
      end if;
      Child := Next_Sibling (Doc, Child);
   end loop;
end;
```

### Safe Node Access Pattern

Always check for `Null_Node` and verify node kind:

```ada
if Node /= Null_Node and then Kind(Doc, Node) = Element then
   Name_Str : constant String := Name(Doc, Node);
   -- Safe to use Node as an element
end if;
```

## API Reference

### SML.DOM.Parser Package

**Parse_File Function:**
```ada
function Parse_File(Path : String) return Parse_Result;
```

Parses an SML document from a file.

**Returns:** `Parse_Result` containing:
- `Success : Boolean` - Whether parsing succeeded
- `Doc : Document` - The parsed document (if successful)
- `Error : Parse_Error` - Error details (if failed)

### SML.DOM Package

**Root Function:**
```ada
function Root(Doc : Document) return Node_Id;
```

Returns the root element of the document.

**First_Child Function:**
```ada
function First_Child(Doc : Document; Node : Node_Id) return Node_Id;
```

Returns the first child of a node, or `Null_Node` if no children.

**Next_Sibling Function:**
```ada
function Next_Sibling(Doc : Document; Node : Node_Id) return Node_Id;
```

Returns the next sibling of a node, or `Null_Node` if no more siblings.

**Kind Function:**
```ada
function Kind(Doc : Document; Node : Node_Id) return Node_Kind;
```

Returns the type of node (Element, Text, Comment, etc.).

**Name Function:**
```ada
function Name(Doc : Document; Node : Node_Id) return String;
```

Returns the element name (tag name). Only valid for Element nodes.

**Text_Value Function:**
```ada
function Text_Value(Doc : Document; Node : Node_Id) return String;
```

Returns the text content. Only valid for Text nodes.

### SML.IO Package

**Parse_File Function:**
```ada
function Parse_File(Path : String) return Parse_Result;
```

Convenience function that reads a file and parses it. Same as `SML.DOM.Parser.Parse_File`.

## Troubleshooting

### Parse Error: File Not Found

**Problem:** `Parse_File` fails with file not found error

**Solution:**
- Run the program from the `lesson-1-basic-parsing` directory
- Or use absolute paths to the fixtures
- Check that `fixtures/` directory exists

```bash
cd lesson-1-basic-parsing
./bin/lesson_1_basic_parsing  # Correct
```

### Parse Error: Unexpected Token

**Problem:** Document fails to parse with unexpected token error

**Solution:** Check that your SML document is well-formed:
- All tags are properly closed
- Tags are properly nested
- No special characters are unescaped
- Attributes are not used (SML doesn't support attributes currently)

**Example of invalid SML:**
```xml
<task>
  <title>Broken</title>
  <!-- Missing closing tag -->
```

### Segmentation Fault / Access Error

**Problem:** Program crashes with segmentation fault or access violation

**Solution:** Ensure you're checking for `Null_Node` before accessing nodes:

```ada
--  ✓ Correct
if Node /= Null_Node then
   Text := Name(Doc, Node);
end if;

--  ✗ Wrong - may crash if Node is Null_Node
Text := Name(Doc, Node);  -- Dangerous!
```

### Empty String Returned

**Problem:** `Text_Value` or `Name` returns empty string

**Solution:**
- For `Name`: Ensure the node is an Element, not Text
- For `Text_Value`: Ensure the node is Text, not Element
- Check that the element actually has text content

```ada
--  Common mistake
if Kind(Doc, Node) = Element then
   Text := Text_Value(Doc, Node);  -- Wrong! Element has no text value
end if;

--  Correct
if Kind(Doc, Node) = Element then
   Text_Node := First_Child(Doc, Node);
   if Text_Node /= Null_Node and then Kind(Doc, Text_Node) = Text then
      Text := Text_Value(Doc, Text_Node);  -- Correct!
   end if;
end if;
```

## Important Notes

### Limited Types and Scope

Documents use Ada's limited types, which means:

1. **No Assignment**: Cannot copy or assign documents
2. **Scope-Bound**: Documents are only valid within their declaration scope
3. **Constant Only**: Must use `constant` when declaring with initialization

```ada
--  ✓ Correct
declare
   Parse_Res : constant Parse_Result := Parse_File("doc.sml");
begin
   if Parse_Res.Success then
      -- Use Parse_Res.Doc here
      Process_Document(Parse_Res.Doc);
   end if;
end;  -- Document is destroyed here

--  ✗ Wrong - cannot pass across scopes
Global_Doc : Document;  -- Not allowed

procedure Load_Doc is
   Parse_Res : constant Parse_Result := Parse_File("doc.sml");
begin
   Global_Doc := Parse_Res.Doc;  -- Won't compile!
end Load_Doc;
```

### Memory Management

SML uses bounded memory allocation:
- **Max Nodes**: Default 2,000 nodes per document
- **Max String Storage**: Default 200KB for all text content
- **Predictable**: No dynamic allocation, all memory pre-allocated

**For larger documents**, adjust in SML library configuration:
```ada
Max_Document_Nodes : constant := 10_000;
Max_String_Storage : constant := 1_000_000;
```

### Parse Performance

- **Speed**: Typically 100KB/sec on modern hardware
- **Linear**: O(n) in document size
- **Memory**: Fixed allocation, no garbage collection
- **Suitable For**: Documents up to several MB

## Exercise Ideas

Try modifying the program to:

1. **Count tasks by priority level** (1-5)
2. **Find and display all high-priority (4-5) tasks**
3. **List tasks that are blocked**
4. **Calculate the percentage of completed tasks**
5. **Find tasks with specific keywords in titles**
6. **Build a helper to count all Element nodes**
7. **Display the document structure as a tree**

## Next Steps

Proceed to **Lesson 2: Schema Validation** to learn how to validate documents against schemas with custom types and constraints.

---

**Lesson 1 of 5** | [Next: Lesson 2 →](../lesson-2-schema-validation/README.md)
