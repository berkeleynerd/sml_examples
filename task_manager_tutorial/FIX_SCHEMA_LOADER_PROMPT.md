# Fix Schema Loader for Inline ComplexTypes

## Problem Statement
The schema loader in `sml-schema-loader.adb` doesn't handle elements with inline/anonymous complexType definitions. It only processes elements with type references, not elements containing direct complexType children.

## Current Behavior (Broken)
When loading this schema:
```xml
<schema>
  <simpleType name="priorityType">
    <restriction base="integer">
      <minValue>1</minValue>
      <maxValue>5</maxValue>
    </restriction>
  </simpleType>

  <element name="task">
    <complexType>  <!-- INLINE: Not processed! -->
      <sequence>
        <element name="priority" type="priorityType"/>
      </sequence>
    </complexType>
  </element>
</schema>
```

The loader:
- ✅ Correctly loads the priorityType simpleType
- ❌ Fails to process the inline complexType within the task element
- ❌ Validation doesn't enforce priorityType constraints on priority element

## Expected Behavior
The loader should handle both patterns:
1. Elements with type references: `<element name="x" type="someType"/>`
2. Elements with inline complexTypes: `<element name="x"><complexType>...</complexType></element>`

## Root Cause
In `Parse_Element_Definition` (lines 636-660), the function only looks for a `<type>` child, not a `<complexType>` child:
```ada
T : constant DOM.Node_Id := Find_Child_Element (Doc, Elem_Node, "type");
-- Missing: check for <complexType> child
```

## Required Changes

### 1. Modify Parse_Element_Definition
```ada
function Parse_Element_Definition
  (Doc : DOM.Document; Elem_Node : DOM.Node_Id) return Parse_Elem_Result
is
   Elem_Def : Element_Definition;
   N : constant DOM.Node_Id := Find_Child_Element (Doc, Elem_Node, "name");
   T : constant DOM.Node_Id := Find_Child_Element (Doc, Elem_Node, "type");
   CT : constant DOM.Node_Id := Find_Child_Element (Doc, Elem_Node, "complexType");  -- ADD THIS
   ...
begin
   ...
   if T /= DOM.Null_Node then
      -- Element has type reference
      Elem_Def.Type_Name := To_Bounded_String (Get_Element_Text (Doc, T));
   elsif CT /= DOM.Null_Node then
      -- Element has inline complexType - need to handle this
      -- Option 1: Generate a unique type name
      declare
         Type_Name : constant String := "_" & Get_Element_Text (Doc, N) & "_Type";
         Complex_Parse : constant Parse_Complex_Result := Parse_Complex_Type (Doc, CT);
      begin
         if Complex_Parse.Success then
            -- Set the generated name on both the type and element
            Complex_Parse.Complex_Def.Name := To_Bounded_String (Type_Name);
            Elem_Def.Type_Name := To_Bounded_String (Type_Name);
            Elem_Def.Has_Inline_Type := True;  -- May need to add this flag
            Elem_Def.Inline_Complex_Type := Complex_Parse.Complex_Def;  -- Store for later
         else
            return (Success => False, Error_Msg => Complex_Parse.Error_Msg);
         end if;
      end;
   end if;
```

### 2. Modify Build_Schema_From_DOM
When processing elements, if they have inline types, add those types to the schema:
```ada
elsif Child_Name = "element" then
   declare
      Parse_Result : constant Parse_Elem_Result :=
         Parse_Element_Definition (Doc, Child);
   begin
      if Parse_Result.Success then
         -- If element has inline complexType, add it first
         if Parse_Result.Elem_Def.Has_Inline_Type then
            Add_Complex_Type (Schema, Parse_Result.Elem_Def.Inline_Complex_Type, Success);
            if not Success then
               Had_Error := True;
               Error_Info.Message := To_Bounded_String ("Failed to add inline complexType");
               return;
            end if;
         end if;

         -- Then add the element
         Add_Element (Schema, Parse_Result.Elem_Def, Success);
         ...
```

### 3. Alternative Simpler Approach
Instead of modifying the Parse_Element_Definition signature, handle inline complexTypes during the main parsing loop:

```ada
elsif Child_Name = "element" then
   -- First check if element has inline complexType
   declare
      CT_Node : constant DOM.Node_Id := Find_Child_Element (Doc, Child, "complexType");
      Elem_Name_Node : constant DOM.Node_Id := Find_Child_Element (Doc, Child, "name");
   begin
      if CT_Node /= DOM.Null_Node and then Elem_Name_Node /= DOM.Null_Node then
         -- Process inline complexType first
         declare
            Elem_Name : constant String := Get_Element_Text (Doc, Elem_Name_Node);
            Generated_Type_Name : constant String := "_" & Elem_Name & "_Type";
            Complex_Parse : constant Parse_Complex_Result := Parse_Complex_Type (Doc, CT_Node);
         begin
            if Complex_Parse.Success then
               -- Set generated name and add to schema
               Complex_Parse.Complex_Def.Name := To_Bounded_String (Generated_Type_Name);
               Add_Complex_Type (Schema, Complex_Parse.Complex_Def, Success);

               -- Now parse element with type reference to generated name
               -- Temporarily modify the DOM or create synthetic type reference
               -- Then proceed with normal element parsing
            end if;
         end;
      else
         -- Normal element processing (existing code)
      end if;
   end;
```

## Test Cases to Verify Fix

### Test 1: Inline ComplexType with Custom Types
```xml
<schema>
  <simpleType name="scoreType">
    <restriction base="integer">
      <minValue>1</minValue>
      <maxValue>10</maxValue>
    </restriction>
  </simpleType>

  <element name="game">
    <complexType>
      <sequence>
        <element name="score" type="scoreType"/>
      </sequence>
    </complexType>
  </element>
</schema>

<!-- Should reject: -->
<game><score>20</score></game>  <!-- 20 > max of 10 -->
```

### Test 2: Nested Inline ComplexTypes
```xml
<element name="outer">
  <complexType>
    <sequence>
      <element name="inner">
        <complexType>
          <sequence>
            <element name="value" type="priorityType"/>
          </sequence>
        </complexType>
      </element>
    </sequence>
  </complexType>
</element>
```

## Success Criteria
After the fix:
1. `./bin/test_loader_vs_direct` - All 3 tests should pass
2. `./bin/lesson_2_fixed` - Should correctly reject invalid priorities/status
3. `./bin/test_validation_final` - Should show proper validation errors

## Files to Modify
- `src/sml-schema-loader.adb` - Main file requiring changes
- Possibly `src/sml-schema-loader.ads` - If new fields are added to types

## Important Notes
1. Generated type names must be unique (consider using element path or counter)
2. The inline complexType must be added to the schema BEFORE the element that references it
3. Preserve all existing functionality for named types
4. Handle nested inline complexTypes recursively