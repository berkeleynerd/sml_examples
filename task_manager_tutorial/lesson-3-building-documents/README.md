# Lesson 3: Building Documents Programmatically

## Overview

This lesson teaches you how to create SML documents from scratch using the Builder API. You'll learn to construct hierarchical structures programmatically, serialize them for display, and save them to files.

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Create documents** from scratch using `Create_Document`
2. **Add elements** to build hierarchical structures with `Add_Child_Element`
3. **Add text content** using `Add_Text_Node`
4. **Understand OUT parameters** and why they're used instead of return values
5. **Serialize documents** for display with `Serialize_Formatted`
6. **Write documents to files** using `Write_Document`
7. **Build complex nested structures** efficiently

## Prerequisites

- Completion of **Lesson 1: Basic Parsing** and **Lesson 2: Schema Validation**
- Understanding of document structure and DOM navigation
- Familiarity with limited types and immutability

## Building and Running

```bash
# Build the lesson
cd lesson-3-building-documents
alr build

# Run previous lessons (still work!)
./bin/lesson_1_basic_parsing
./bin/lesson_2_schema_validation

# Run lesson 3 (new!)
./bin/lesson_3_building
```

## Expected Output

```
================================
  Lesson 3: Building Documents Programmatically
================================

This lesson demonstrates how to:
  1. Create new documents from scratch
  2. Add elements and text content
  3. Build hierarchical structures
  4. Serialize and save documents

Key API patterns:
  * Add_Child_Element uses OUT parameter for new node
  * Add_Text_Node also uses OUT parameter
  * Reuse a Temp_Node variable for efficiency
  * Build structure top-down

================================
  Example 1: Configuration Document
================================

Building a configuration document...
Generated configuration:
<configuration>
  <database>
    <host>localhost</host>
    <port>5432</port>
    <name>task_db</name>
  </database>
  <server>
    <port>8080</port>
    <threads>4</threads>
  </server>
</configuration>

[OK] Configuration saved to config.sml

================================
  Example 2: Task Database
================================

Building a complete task database...
Document structure built:
  - 1 metadata section
  - 1 project
  - 2 tasks

[OK] Task database saved to tasks_built.sml
     Size:  892 bytes

================================
  Example 3: Nested Structures
================================

Building a document with nested structure...
Generated nested structure:
<report>
  <section>
    <title>Main Section</title>
    <subsection>
      <title>Subsection A</title>
      <content>This demonstrates nesting</content>
    </subsection>
    <list>
      <item>First item</item>
      <item>Second item</item>
      <item>Third item</item>
    </list>
  </section>
</report>

================================
  Building Documents Summary
================================

Key takeaways:
  * Create_Document starts with root element
  * Build structure using Add_Child_Element
  * Add content using Add_Text_Node
  * Both use OUT parameters (not return values)
  * Serialize_Formatted for pretty output
  * Write_Document to save to file

This approach ensures memory safety and allows
formal verification of document construction.
```

## Key Concepts

### Mutable vs Immutable Documents

This is a critical distinction in the SML library:

**Parsed Documents (Lessons 1-2):**
- Created by `Parse_File`
- **Immutable** - Cannot be modified
- Limited type - Cannot be assigned
- Read-only DOM access

**Built Documents (Lesson 3):**
- Created by `Create_Document`
- **Mutable** - Can be modified during construction
- Still limited type - Cannot be assigned
- Write operations available during building

```ada
--  ✓ Mutable document (can add to it)
declare
   Doc : Document := Create_Document("root");
   Root : constant Node_Id := SML.DOM.Root(Doc);
   Child : Node_Id;
begin
   Add_Child_Element(Doc, Root, "child", Child);  -- OK!
end;

--  ✗ Immutable document (cannot modify)
declare
   Parse_Res : constant Parse_Result := Parse_File("doc.sml");
begin
   if Parse_Res.Success then
      Add_Child_Element(Parse_Res.Doc, Root, "child", Child);  -- ERROR!
   end if;
end;
```

### Creating Documents

The `Create_Document` function starts a new document with a root element:

```ada
Doc : Document := Create_Document("root_element_name");
```

**Important:**
- The document variable must be mutable (no `constant` keyword)
- The root element name is required
- Returns a Document that can be modified

### Adding Elements

Elements are added as children of existing nodes:

```ada
Add_Child_Element(Doc, Parent_Node, "element_name", New_Node);
```

**Parameters:**
- `Doc : in out Document` - The document being built (modified in place)
- `Parent_Node : Node_Id` - Where to attach the new element
- `"element_name" : String` - Tag name for the new element
- `New_Node : out Node_Id` - Receives the ID of the newly created node

**Why OUT parameter?**
- Allows chaining: immediately add children to the new node
- Efficient: No copying of node IDs
- Safe: Cannot forget to receive the new node reference

### Adding Text Content

Text nodes are added as children of element nodes:

```ada
Add_Text_Node(Doc, Parent_Element, "text content", Text_Node);
```

**Parameters:**
- `Doc : in out Document` - The document being built
- `Parent_Element : Node_Id` - Element to receive the text
- `"text content" : String` - The actual text content
- `Text_Node : out Node_Id` - Receives ID of the text node

**Pattern:**
```ada
--  Add an element with text content
declare
   Title_Node, Text_Node : Node_Id;
begin
   Add_Child_Element(Doc, Parent, "title", Title_Node);
   Add_Text_Node(Doc, Title_Node, "My Title", Text_Node);
end;
```

### Reusing Temp Variables

For efficiency, reuse a temporary Node_Id variable:

```ada
declare
   Temp : Node_Id;
begin
   --  Add multiple elements with text
   Add_Child_Element(Doc, Parent, "name", Temp);
   Add_Text_Node(Doc, Temp, "John", Temp);

   Add_Child_Element(Doc, Parent, "age", Temp);
   Add_Text_Node(Doc, Temp, "30", Temp);

   Add_Child_Element(Doc, Parent, "city", Temp);
   Add_Text_Node(Doc, Temp, "Boston", Temp);
end;
```

**Why this works:**
- Node IDs are just references (typically integers)
- The document stores the actual nodes
- Safe to overwrite the reference after use
- Reduces variable declaration clutter

### Serializing Documents

Convert a document to a string representation:

```ada
--  Compact output (no formatting)
Compact_Str : constant String := Serialize(Doc);

--  Formatted output (indented with specified spaces)
Formatted_Str : constant String := Serialize_Formatted(Doc, Indent => 2);
```

**Serialize_Formatted Parameters:**
- `Doc : Document` - The document to serialize
- `Indent : Natural` - Number of spaces per indentation level (typically 2 or 4)

**Returns:** String containing the complete XML representation

### Writing to Files

Save a document to a file:

```ada
Result : constant Write_Result :=
   Write_Document("output.sml", Doc, Formatted => True);
```

**Parameters:**
- `Path : String` - File path to write
- `Doc : Document` - Document to save
- `Formatted : Boolean` - Whether to indent (default: False)

**Returns:** `Write_Result` containing:
```ada
type Write_Result is record
   Status : Write_Status;      -- Success or Error
   Bytes_Written : Natural;    -- Number of bytes written
   Error_Message : Bounded_String;  -- Error description if failed
end record;

type Write_Status is (Success, Error);
```

**Checking results:**
```ada
if Result.Status = Success then
   Put_Line("Wrote" & Natural'Image(Result.Bytes_Written) & " bytes");
else
   Put_Line("Error: " & To_String(Result.Error_Message));
end if;
```

## Code Structure

The lesson demonstrates three building patterns:

### 1. Simple Configuration Document

Shows the basic pattern of building a two-level hierarchy:

```ada
Doc : Document := Create_Document("configuration");
Root : constant Node_Id := SML.DOM.Root(Doc);
Database_Node, Server_Node, Temp_Node : Node_Id;

--  Add sections
Add_Child_Element(Doc, Root, "database", Database_Node);
Add_Child_Element(Doc, Root, "server", Server_Node);

--  Add database fields
Add_Child_Element(Doc, Database_Node, "host", Temp_Node);
Add_Text_Node(Doc, Temp_Node, "localhost", Temp_Node);
```

**Purpose:** Learn the basic building blocks

### 2. Complete Task Database

Demonstrates building a complex, real-world document structure:

```ada
--  Build metadata
Add_Child_Element(Doc, Root, "metadata", Metadata_Node);
Add_Child_Element(Doc, Metadata_Node, "version", Version_Node);
Add_Text_Node(Doc, Version_Node, "1.0", Temp);

--  Build projects
Add_Child_Element(Doc, Root, "projects", Projects_Node);
Add_Child_Element(Doc, Projects_Node, "project", Project_Node);
--  ... add project fields

--  Build tasks
Add_Child_Element(Doc, Root, "tasks", Tasks_Node);
Add_Child_Element(Doc, Tasks_Node, "task", Task_Node);
--  ... add task fields
```

**Purpose:** Practice building multi-level structures with repeated elements

### 3. Nested Structures

Shows deep nesting and list-like patterns:

```ada
--  Create nested sections
Add_Child_Element(Doc, Root, "section", Section_Node);
Add_Child_Element(Doc, Section_Node, "subsection", Subsection_Node);

--  Add list structure
Add_Child_Element(Doc, Section_Node, "list", List_Node);
Add_Child_Element(Doc, List_Node, "item", Temp);
Add_Text_Node(Doc, Temp, "First item", Temp);
--  ... more items
```

**Purpose:** Understand nesting and repeated sibling elements

## Common Patterns

### Building an Element with Text Content

```ada
--  Pattern 1: Using separate variables
declare
   Element_Node, Text_Node : Node_Id;
begin
   Add_Child_Element(Doc, Parent, "title", Element_Node);
   Add_Text_Node(Doc, Element_Node, "Title text", Text_Node);
end;

--  Pattern 2: Using a single Temp variable (preferred)
declare
   Temp : Node_Id;
begin
   Add_Child_Element(Doc, Parent, "title", Temp);
   Add_Text_Node(Doc, Temp, "Title text", Temp);
end;
```

### Building Multiple Sibling Elements

```ada
declare
   Sibling, Temp : Node_Id;
begin
   --  First sibling
   Add_Child_Element(Doc, Parent, "field1", Sibling);
   Add_Text_Node(Doc, Sibling, "Value 1", Temp);

   --  Second sibling
   Add_Child_Element(Doc, Parent, "field2", Sibling);
   Add_Text_Node(Doc, Sibling, "Value 2", Temp);

   --  Third sibling
   Add_Child_Element(Doc, Parent, "field3", Sibling);
   Add_Text_Node(Doc, Sibling, "Value 3", Temp);
end;
```

### Building a Repeating Structure

```ada
--  Build multiple tasks in a loop
declare
   Task_Node, Temp : Node_Id;
   Task_Data : array (1 .. 3) of Task_Record := ...;
begin
   for I in Task_Data'Range loop
      Add_Child_Element(Doc, Tasks_Node, "task", Task_Node);

      Add_Child_Element(Doc, Task_Node, "title", Temp);
      Add_Text_Node(Doc, Temp, Task_Data(I).Title, Temp);

      Add_Child_Element(Doc, Task_Node, "priority", Temp);
      Add_Text_Node(Doc, Temp, Natural'Image(Task_Data(I).Priority), Temp);
   end loop;
end;
```

### Top-Down Building Strategy

Always build from root to leaves:

```ada
--  ✓ Correct: Top-down
Root := SML.DOM.Root(Doc);
Add_Child_Element(Doc, Root, "parent", Parent);
Add_Child_Element(Doc, Parent, "child", Child);
Add_Text_Node(Doc, Child, "text", Temp);

--  ✗ Wrong: Cannot add to a node that doesn't exist yet
Add_Child_Element(Doc, Child, "text", Temp);  -- Child not created yet!
Add_Child_Element(Doc, Parent, "child", Child);
Add_Child_Element(Doc, Root, "parent", Parent);
```

## API Reference

### SML.DOM.Builder Package

**Create_Document Function:**
```ada
function Create_Document(Root_Name : String) return Document;
```

Creates a new empty document with a root element.

**Parameters:**
- `Root_Name : String` - Name of the root element

**Returns:** A new mutable `Document`

**Example:**
```ada
Doc : Document := Create_Document("task_database");
```

---

**Add_Child_Element Procedure:**
```ada
procedure Add_Child_Element(
   Doc : in out Document;
   Parent : Node_Id;
   Name : String;
   New_Node : out Node_Id
);
```

Adds a new element as a child of the parent node.

**Parameters:**
- `Doc : in out Document` - Document being modified
- `Parent : Node_Id` - Parent node to attach to
- `Name : String` - Tag name for new element
- `New_Node : out Node_Id` - Receives ID of created element

**Example:**
```ada
Add_Child_Element(Doc, Parent, "task", Task_Node);
```

---

**Add_Text_Node Procedure:**
```ada
procedure Add_Text_Node(
   Doc : in out Document;
   Parent : Node_Id;
   Text : String;
   New_Node : out Node_Id
);
```

Adds a text node as a child of an element.

**Parameters:**
- `Doc : in out Document` - Document being modified
- `Parent : Node_Id` - Element to receive text content
- `Text : String` - Text content
- `New_Node : out Node_Id` - Receives ID of text node

**Example:**
```ada
Add_Text_Node(Doc, Title_Node, "My Task", Text_Node);
```

### SML.DOM.Writer Package

**Serialize Function:**
```ada
function Serialize(Doc : Document) return String;
```

Converts document to compact string representation.

**Parameters:**
- `Doc : Document` - Document to serialize

**Returns:** String containing complete XML (no whitespace formatting)

---

**Serialize_Formatted Function:**
```ada
function Serialize_Formatted(
   Doc : Document;
   Indent : Natural := 2
) return String;
```

Converts document to formatted string with indentation.

**Parameters:**
- `Doc : Document` - Document to serialize
- `Indent : Natural` - Spaces per indentation level (default: 2)

**Returns:** String containing formatted XML

**Example:**
```ada
Pretty_XML : constant String := Serialize_Formatted(Doc, 4);
```

---

**Write_Document Function:**
```ada
function Write_Document(
   Path : String;
   Doc : Document;
   Formatted : Boolean := False
) return Write_Result;
```

Writes document to a file.

**Parameters:**
- `Path : String` - File path to write
- `Doc : Document` - Document to save
- `Formatted : Boolean` - Whether to indent (default: False)

**Returns:** `Write_Result` with status and byte count

**Example:**
```ada
Result : constant Write_Result :=
   Write_Document("output.sml", Doc, Formatted => True);

if Result.Status = Success then
   Put_Line("Saved" & Natural'Image(Result.Bytes_Written) & " bytes");
end if;
```

### Write_Result Type

```ada
type Write_Status is (Success, Error);

type Write_Result is record
   Status : Write_Status;
   Bytes_Written : Natural;
   Error_Message : Bounded_String;
end record;
```

**Fields:**
- `Status` - Whether write succeeded
- `Bytes_Written` - Number of bytes written to file
- `Error_Message` - Description of error (if Status = Error)

## Troubleshooting

### Cannot Modify Document Error

**Problem:** Compilation error when trying to add elements

**Solution:** Ensure document is declared without `constant`:

```ada
--  ✓ Correct - mutable
Doc : Document := Create_Document("root");

--  ✗ Wrong - immutable
Doc : constant Document := Create_Document("root");
```

### OUT Parameter Warning

**Problem:** Compiler warns about unused OUT parameter

**Solution:** Either use the returned Node_Id or explicitly indicate reuse:

```ada
--  Use a temp variable that you reuse
Temp : Node_Id;
Add_Child_Element(Doc, Parent, "child", Temp);
```

### Write Error: Permission Denied

**Problem:** `Write_Document` returns Error status with permission error

**Solution:**
- Check that the output directory exists
- Verify write permissions on the target directory
- Use absolute paths or run from the correct directory

### Segmentation Fault During Build

**Problem:** Runtime error when adding nodes

**Solution:** Ensure parent node is valid before adding children:

```ada
--  ✓ Correct
Root : constant Node_Id := SML.DOM.Root(Doc);
Add_Child_Element(Doc, Root, "child", Child);

--  ✗ Wrong - uninitialized parent
Parent : Node_Id;  -- Never assigned!
Add_Child_Element(Doc, Parent, "child", Child);  -- Crash!
```

## Important Notes

### Documents are Still Limited Types

Even though built documents are mutable during construction, they remain limited types:

```ada
--  ✓ Correct - build in place
declare
   Doc : Document := Create_Document("root");
begin
   Add_Child_Element(Doc, SML.DOM.Root(Doc), "child", Temp);
   --  Use Doc here
end;

--  ✗ Wrong - cannot assign
Doc1 := Create_Document("root");  -- Won't compile
Doc2 := Doc1;  -- Won't compile
```

### Memory Limits Still Apply

Built documents use the same bounded allocation as parsed documents:

- **Max Nodes**: Default 2,000 nodes
- **Max String Storage**: Default 200KB
- **Predictable**: No dynamic allocation

If building very large documents, adjust limits in SML configuration.

### Building vs Parsing Trade-offs

**Building:**
- ✅ Full control over structure
- ✅ Can create any valid document
- ✅ No parsing overhead
- ❌ More verbose code
- ❌ No validation during construction

**Parsing:**
- ✅ Concise (just read file)
- ✅ Validates syntax automatically
- ❌ Cannot modify after parsing
- ❌ Parse time overhead

**Best Practice:** Build documents when you need to generate them programmatically. Parse documents when you have existing files.

### Validation After Building

Documents built programmatically are not automatically validated:

```ada
--  Build a document
Doc : Document := Create_Document("task");
--  ... build structure

--  Validate it
declare
   Schema_Parse : constant Parse_Result := Parse_File("schema.sml");
   Schema_Load : constant Schema_Load_Result := Load_Schema(Schema_Parse.Doc);

   --  Convert built document to immutable for validation
   --  (This requires serializing then re-parsing)
   Serialized : constant String := Serialize(Doc);
   --  Write to temp file then parse it
   --  ... then validate
end;
```

**Note:** This is covered more in Lesson 4 on transformation patterns.

## Exercise Ideas

Try extending this lesson:

1. **Build a personal contact database** with people, addresses, phone numbers
2. **Create a configuration builder** that takes command-line arguments
3. **Build a simple HTML-like document** with nested div elements
4. **Generate a report document** from computed statistics
5. **Create a document builder helper** that simplifies common patterns
6. **Build a document from CSV data** (read CSV, build SML)
7. **Create a template system** that fills in placeholders

## Next Steps

Proceed to **Lesson 4: Document Transformation** to learn how to combine parsing and building to transform existing documents into new ones, which is the key pattern for "modifying" the immutable parsed documents.

---

**Lesson 3 of 5** | [← Previous: Lesson 2](../lesson-2-schema-validation/README.md) | [Next: Lesson 4 →](../lesson-4-transformation/README.md)
