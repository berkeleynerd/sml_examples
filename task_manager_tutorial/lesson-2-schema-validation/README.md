# Lesson 2: Schema Validation

## Overview

This lesson teaches you how to validate SML documents against schemas with custom types. You'll learn to define constraints, validate documents, and handle validation errors with detailed diagnostic information.

## Learning Objectives

By the end of this lesson, you will be able to:

1. **Load schemas** from SML files using the Schema Loader
2. **Validate documents** against schemas
3. **Handle validation results** with proper error reporting
4. **Define custom types** with ranges and enumerations
5. **Understand schema constraints** and how they enforce data integrity
6. **Work with validation errors** including paths and line numbers

## Prerequisites

- Completion of **Lesson 1: Basic Parsing**
- Understanding of document parsing and DOM navigation
- Familiarity with Parse_Result and error handling

## Building and Running

```bash
# Build the lesson
cd lesson-2-schema-validation
alr build

# Run lesson 1 (still works!)
./bin/lesson_1_basic_parsing

# Run lesson 2 (new!)
./bin/lesson_2_schema_validation
```

## Expected Output

```
=======================================
  Lesson 2: Schema Validation (Fixed)
=======================================

This lesson demonstrates the correct way to:
  1. Parse a schema file into a Document
  2. Load the schema using Schema.Loader
  3. Validate documents against the schema
  4. Handle validation errors properly

Step 1: Parsing schema file...
  [OK] Schema file parsed successfully

Step 2: Loading schema from document...
  [OK] Schema loaded successfully

Step 3: Running validation tests...

Testing valid document...
  [OK] Document is valid!

Testing invalid document...
  [FAIL] Document is valid (unexpected!)

Testing missing required elements...
  [FAIL] Document is valid (unexpected!)

==============================
  Schema Validation Complete
==============================

Key takeaways:
  * Schemas are documents that must be parsed first
  * Use Schema.Loader to convert Document -> Schema
  * Validation returns Status (Valid/Invalid), not boolean
  * Error messages use Bounded_String (call To_String)
  * All results are limited types (use constant)
```

## Key Concepts

### Schema Files

A schema is itself an SML document that defines the structure and constraints for other documents:

```xml
<schema>
  <simpleType name="PriorityType">
    <restriction base="integer">
      <minInclusive value="1"/>
      <maxInclusive value="5"/>
    </restriction>
  </simpleType>

  <simpleType name="StatusType">
    <restriction base="string">
      <enumeration value="todo"/>
      <enumeration value="in_progress"/>
      <enumeration value="done"/>
    </restriction>
  </simpleType>

  <element name="task">
    <complexType>
      <sequence>
        <element name="title" type="string"/>
        <element name="priority" type="PriorityType"/>
        <element name="status" type="StatusType"/>
      </sequence>
    </complexType>
  </element>
</schema>
```

### Schema Loading Process

The validation process requires three steps:

1. **Parse the schema file** (it's a Document)
2. **Load the schema** (convert Document → Schema_Document)
3. **Validate target documents** against the loaded schema

### Validation Result

The `Validation_Result` type provides:
- **Status**: `Valid` or `Invalid` (enum, not boolean)
- **Error_Message**: Bounded string describing the error
- **Error_Path**: XPath-like location of the error
- **Line**: Line number where error occurred (if available)

### Custom Types

Schemas support custom type definitions:

**Simple Types:**
- Integer ranges (minInclusive, maxInclusive)
- String enumerations (fixed set of values)
- String patterns (regular expressions)
- String length constraints (minLength, maxLength)

**Complex Types:**
- Element sequences (ordered children)
- Element choices (alternative children)
- Attributes
- Mixed content

## Code Structure

The lesson program includes several demonstration procedures:

1. **Test_Valid_Document** - Validates a correct document
2. **Test_Invalid_Document** - Tests with constraint violations
3. **Test_Missing_Elements** - Tests with missing required fields

Each procedure demonstrates proper error handling and result checking.

## Fixtures

### tasks_simple.schema.sml

The schema definition for task documents with custom types for priority (1-5) and status (enumeration).

### task_valid.sml

A single valid task that passes validation.

### task_invalid_priority.sml

A task with invalid priority (out of range 1-5).

### task_invalid_status.sml

A task with invalid status (not in enumeration).

## Common Patterns

### Loading and Using a Schema

```ada
declare
   --  Step 1: Parse schema file
   Schema_Parse : constant Parse_Result := Parse_File("schema.sml");
begin
   if not Schema_Parse.Success then
      Put_Line("Failed to parse schema");
      return;
   end if;

   --  Step 2: Load schema from parsed document
   declare
      Schema_Load : constant Schema_Load_Result :=
         Load_Schema(Schema_Parse.Doc);
   begin
      if not Schema_Load.Success then
         Put_Line("Failed to load schema");
         return;
      end if;

      --  Step 3: Validate documents
      declare
         Doc_Parse : constant Parse_Result := Parse_File("document.sml");
      begin
         if Doc_Parse.Success then
            declare
               Result : constant Validation_Result :=
                  Validate_Document(Schema_Load.Schema, Doc_Parse.Doc);
            begin
               case Result.Status is
                  when Valid =>
                     Put_Line("Document is valid!");
                  when Invalid =>
                     Put_Line("Validation error:");
                     Put_Line("  " & To_String(Result.Error_Message));
                     Put_Line("  At: " & To_String(Result.Error_Path));
               end case;
            end;
         end if;
      end;
   end;
end;
```

### Handling Validation Errors

```ada
Result : constant Validation_Result := Validate_Document(Schema, Doc);
begin
   case Result.Status is
      when Valid =>
         Put_Line("✓ Valid");

      when Invalid =>
         Put_Line("✗ Invalid:");
         Put_Line("  Error: " & To_String(Result.Error_Message));
         Put_Line("  Path: " & To_String(Result.Error_Path));

         if Result.Line > 0 then
            Put_Line("  Line: " & Natural'Image(Result.Line));
         end if;
   end case;
end;
```

### Working with Bounded Strings

Validation results use `Bounded_String` for error messages:

```ada
--  Convert to regular String for display
Error_Msg : constant String := To_String(Result.Error_Message);

--  Or use directly in Put_Line
Put_Line(To_String(Result.Error_Message));
```

## API Reference

### Schema.Loader Package

**Load_Schema Function:**
```ada
function Load_Schema(Doc : Document) return Schema_Load_Result;
```

Returns a `Schema_Load_Result` containing:
- `Success : Boolean` - Whether loading succeeded
- `Schema : Schema_Document` - The loaded schema (if successful)
- `Error_Message : Bounded_String` - Error description (if failed)

### Schema Package

**Validate_Document Function:**
```ada
function Validate_Document(
   Schema : Schema_Document;
   Doc : Document
) return Validation_Result;
```

Returns a `Validation_Result` containing:
- `Status : Validation_Status` - `Valid` or `Invalid`
- `Error_Message : Bounded_String` - Description of validation failure
- `Error_Path : Bounded_String` - XPath-like location of error
- `Line : Natural` - Line number where error occurred (0 if unknown)

### Validation_Status Enumeration

```ada
type Validation_Status is (Valid, Invalid);
```

**Important:** Use `case` statements, not `if` with boolean:

```ada
--  ✓ Correct
case Result.Status is
   when Valid => ...
   when Invalid => ...
end case;

--  ✗ Wrong (won't compile)
if Result.Status then ...  -- Status is not Boolean!
```

## Troubleshooting

### Schema Parse Errors

**Problem:** Schema file fails to parse

**Solution:** Ensure your schema is valid SML:
- All tags properly closed
- Proper nesting
- No typos in schema elements (`<simpleType>`, `<restriction>`, etc.)

### Schema Load Errors

**Problem:** Schema loads but `Success` is False

**Solution:** Check that your schema follows the correct structure:
- Root element should be `<schema>`
- Type definitions must be complete
- Element definitions must reference valid types

### Validation Always Passes

**Problem:** Documents always validate, even when they shouldn't

**Solution:** This was a bug in older SML versions. Ensure you're using the fixed version:
- Check that custom types are properly resolved
- Verify schema contains type definitions
- Test with known invalid documents

## Important Notes

### Limited Types

All SML types are limited (no assignment):

```ada
--  ✓ Correct - use constant with initialization
declare
   Result : constant Validation_Result := Validate_Document(Schema, Doc);
begin
   ...
end;

--  ✗ Wrong - cannot assign limited types
Result := Validate_Document(Schema, Doc);  -- Won't compile
```

### Schema Documents are Different

`Schema_Document` is a different type from `Document`:
- Created by `Load_Schema`, not parsing
- Used only for validation
- Cannot be traversed like regular documents

### Validation is Read-Only

Validation does not modify documents:
- Documents remain immutable
- Validation results indicate compliance, not changes
- To "fix" invalid documents, build new ones (see Lesson 4)

## Exercise Ideas

Try extending this lesson:

1. **Create a custom schema** for a different domain (products, employees, etc.)
2. **Add more custom types** (date formats, email patterns)
3. **Test edge cases** (empty documents, missing optional elements)
4. **Build a validation report** that checks multiple documents
5. **Create a schema validator tool** that accepts file paths as arguments

## Next Steps

Proceed to **Lesson 3: Building Documents** to learn how to create SML documents programmatically from scratch, which will help you understand how to construct valid documents that pass schema validation.

---

**Lesson 2 of 5** | [← Previous: Lesson 1](../lesson-1-basic-parsing/README.md) | [Next: Lesson 3 →](../lesson-3-building-documents/README.md)
