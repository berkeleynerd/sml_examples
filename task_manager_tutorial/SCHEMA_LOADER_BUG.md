# Schema Loader Bug: Inline ComplexTypes Not Handled

## Executive Summary

The schema validation issue is **NOT** with the SML library's validation engine (which has been fixed), but with the **tutorial's local schema loader** (`sml-schema-loader.adb`). The loader doesn't handle inline/anonymous complexTypes correctly.

## The Specific Bug

The schema loader fails to process elements that contain inline complexType definitions. It only looks for `<type>` children, not `<complexType>` children.

### Pattern That Works ✅
```xml
<!-- Named complexType referenced by element -->
<schema>
  <simpleType name="priorityType">...</simpleType>

  <complexType name="taskType">  <!-- Named type -->
    <sequence>
      <element name="priority" type="priorityType"/>
    </sequence>
  </complexType>

  <element name="task" type="taskType"/>  <!-- Reference to named type -->
</schema>
```

### Pattern That Fails ❌ (Used in Tutorial)
```xml
<!-- Inline/anonymous complexType -->
<schema>
  <simpleType name="priorityType">...</simpleType>

  <element name="task">
    <complexType>  <!-- Inline/anonymous - NOT PROCESSED! -->
      <sequence>
        <element name="priority" type="priorityType"/>
      </sequence>
    </complexType>
  </element>
</schema>
```

## Test Evidence

From `test_loader_vs_direct`:
```
Test 1: Direct element with custom type       ✅ WORKS
Test 2: Inline complexType with custom type   ❌ FAILS
Test 3: Named complexType referenced          ✅ WORKS
```

This proves:
1. SML validation engine works correctly (Tests 1 & 3 pass)
2. Schema loader handles named types correctly (Test 3 passes)
3. Schema loader fails with inline complexTypes (Test 2 fails)

## Root Cause in Code

In `sml-schema-loader.adb`:

### Parse_Element_Definition (lines 636-660)
```ada
function Parse_Element_Definition
  (Doc : DOM.Document; Elem_Node : DOM.Node_Id) return Parse_Elem_Result
is
   ...
   T : constant DOM.Node_Id := Find_Child_Element (Doc, Elem_Node, "type");
   ...
begin
   if T /= DOM.Null_Node then
      Elem_Def.Type_Name := To_Bounded_String (Get_Element_Text (Doc, T));
   end if;
   -- NO CHECK FOR <complexType> CHILD!
```

The function only checks for a `<type>` child element, not a `<complexType>` child.

### Build_Schema_From_DOM (lines 666-800)
Processes top-level elements:
- Line 704: Handles `<complexType>` elements (as named types)
- Line 725: Handles `<element>` elements (assumes type reference)
- **Missing**: Logic to handle `<element>` with inline `<complexType>`

## Why This Affects the Tutorial

All tutorial lessons use the inline complexType pattern:
- `fixtures/fixed_inline.schema.sml` - Uses inline complexType
- `fixtures/tasks_simple.schema.sml` - Uses inline complexType
- All lesson examples follow this pattern

## The Fix Required

The schema loader needs to be modified to:

1. **In Parse_Element_Definition**: Check for both `<type>` and `<complexType>` children
2. **If inline complexType found**:
   - Parse the complexType
   - Generate a unique name for it (e.g., `_element_name_complexType`)
   - Add it to the schema's complex types
   - Set the element's Type_Name to reference it

## Workaround Options

### Option 1: Fix the Schema Loader (Recommended)
Modify `sml-schema-loader.adb` to handle inline complexTypes.

### Option 2: Modify Schema Files (Not Ideal)
Convert all inline complexTypes to named types:
```xml
<!-- Instead of inline... -->
<element name="task">
  <complexType>...</complexType>
</element>

<!-- Use named types -->
<complexType name="taskType">...</complexType>
<element name="task" type="taskType"/>
```

### Option 3: Use a Different Schema Loader
The SML library's own tests construct schemas programmatically and work correctly.

## Verification

To verify this is the issue:
1. Run `./bin/test_loader_vs_direct` - Test 2 fails (inline complexType)
2. Run `./bin/test_fix_verification` - Test 1 works (direct), Test 2 fails (inline)
3. Modify a schema to use named types - it will work

## Conclusion

The SML library validation is **working correctly**. The issue is that the tutorial's schema loader doesn't handle the standard XML Schema pattern of inline complexTypes. This is why validation appears broken even though the underlying engine has been fixed.