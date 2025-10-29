# Schema Validation Investigation Report

## Executive Summary

After thorough investigation, the schema validation issue is **NOT** in the example code but in the **SML library's Validate_Document implementation**. The validation fails specifically when using **custom simpleTypes with restrictions**, which is the pattern used in all lesson examples.

## Key Finding

**Validation works** when constraints are directly in element definitions.
**Validation fails** when constraints are in separate simpleType definitions referenced by elements.

## Test Results Summary

| Test | Schema Type | Result |
|------|------------|--------|
| Direct integer constraints in element | Works ✅ | Correctly rejects out-of-range values |
| Direct enumeration in element | Works ✅ | Correctly rejects invalid enum values |
| Custom simpleType with integer range | **FAILS ❌** | Accepts any integer value |
| Custom simpleType with enumeration | **FAILS ❌** | Accepts any string value |
| Missing required elements | **FAILS ❌** | Doesn't enforce required fields |

## Detailed Investigation

### 1. Existing Test Results

All three existing tests confirm validation always passes when using custom types:

```
test_validation_final:
  Test 2 - Invalid priority (10): [PASS] - ERROR: Should have failed!
  Test 3 - Invalid status (working): [PASS] - ERROR: Should have failed!

test_validation_diagnostic:
  Invalid doc (10): PASS (WRONG!)
  Invalid doc (working): PASS (WRONG!)

lesson_2_fixed:
  Testing invalid document... [FAIL] Document is valid (unexpected!)
  Testing missing required elements... [FAIL] Document is valid (unexpected!)
```

### 2. Minimal Test Case Results

Created `test_minimal_validation` with simplest possible schemas:

```
Test 1: Integer with minValue=1, maxValue=5
  Testing value=10 (should FAIL): PASS [BUG: Should have failed!]
  Testing value=0 (should FAIL): PASS [BUG: Should have failed!]

Test 2: String enumeration [yes, no]
  Testing value='maybe' (should FAIL): PASS [BUG: Should have failed!]

Test 3: Missing required element
  Testing missing 'age' (should FAIL): PASS [BUG: Should have failed!]
```

### 3. Schema Loader Debug Results

The breakthrough came with `debug_schema_loader`:

```
Test 1: Parse schema with integer constraints
  Schema structure correctly parsed (minValue=1, maxValue=100)
  Testing value 200 (should fail): INVALID - Integer too large: maximum 100 ✅

Test 2: Parse schema with enumeration
  Schema structure correctly parsed (red, green, blue)
  Testing 'yellow' (should fail): INVALID - Value not in enumeration: yellow ✅
```

## The Critical Difference

### Schema That Works ✅
```xml
<schema>
  <element>
    <name>score</name>
    <type>integer</type>
    <minValue>1</minValue>
    <maxValue>100</maxValue>
  </element>
</schema>
```

### Schema That Fails ❌ (Used in Lessons)
```xml
<schema>
  <simpleType>
    <name>scoreType</name>
    <restriction>
      <base>integer</base>
      <minValue>1</minValue>
      <maxValue>100</maxValue>
    </restriction>
  </simpleType>
  <element>
    <name>score</name>
    <type>scoreType</type>  <!-- Reference to custom type -->
  </element>
</schema>
```

## Root Cause Analysis

The issue is in the **SML.Schema.Validate_Document** function (external library):

1. **Schema Loading Phase**: ✅ Working
   - `sml-schema-loader.adb` correctly parses custom types
   - Constraints are properly extracted from simpleType definitions
   - Type definitions are stored in the schema structure

2. **Validation Phase**: ❌ Broken
   - `Validate_Document` doesn't resolve custom type references
   - When it sees `<type>priorityType</type>`, it doesn't look up the type definition
   - Falls back to accepting any value that matches the base type

## Evidence

1. **Schema loader works**: The debug test shows constraints are correctly parsed from the schema
2. **Direct validation works**: When constraints are inline, validation correctly enforces them
3. **Type resolution fails**: Custom types like `priorityType` and `statusType` are not resolved during validation

## Impact on Tutorial

All 5 lessons are affected because they all use the standard XML Schema pattern of defining reusable types:
- Lesson 2: Uses `priorityType` (1-5) and `statusType` (enum)
- Lesson 3: References same types when building
- Lesson 4: Transforms documents with these types
- Lesson 5: Analyzes documents assuming validation works

## Workaround Options

### Option 1: Fix the Library
The `Validate_Document` function needs to:
1. Resolve custom type references
2. Apply constraints from the type definition
3. Properly validate against the resolved type

### Option 2: Modify Examples (Not Recommended)
Change all schemas to use inline constraints instead of custom types.
This would make schemas non-reusable and defeat the purpose of teaching proper schema design.

### Option 3: Document the Limitation
Add a warning to the tutorial that validation of custom types is not currently working.
Focus lessons on other aspects (parsing, building, transformation).

## Conclusion

The validation issue is **definitively in the SML library**, not the examples. The library's `Validate_Document` function fails to resolve and apply constraints from custom simpleType definitions, which is a fundamental feature of XML Schema.

The lesson code is correct and follows XML Schema best practices. The issue needs to be fixed in the SML library itself.

## Test Files Created

1. `test_minimal_validation.adb` - Tests simplest validation cases
2. `debug_schema_loader.adb` - Isolates schema loading vs validation
3. This report: `VALIDATION_INVESTIGATION.md`

## Recommendation

**Fix the SML.Schema.Validate_Document implementation** to properly resolve custom type references and apply their constraints during validation. This is essential for the tutorial to function as intended.