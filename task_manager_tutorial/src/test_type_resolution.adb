--  Test Type Resolution in Schema
--  ================================
--  Tests if custom types are being resolved

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Test_Type_Resolution is
begin
   Put_Line ("===================================");
   Put_Line ("  Type Resolution Test");
   Put_Line ("===================================");
   New_Line;

   --  Test with a custom simple type
   Put_Line ("Testing custom type definition...");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <simpleType>" &
         "    <name>priorityType</name>" &
         "    <restriction>" &
         "      <base>integer</base>" &
         "      <minValue>1</minValue>" &
         "      <maxValue>5</maxValue>" &
         "    </restriction>" &
         "  </simpleType>" &
         "  <element>" &
         "    <name>priority</name>" &
         "    <type>priorityType</type>" &  -- References custom type
         "  </element>" &
         "</schema>";

      Valid_Doc : constant String := "<priority>3</priority>";
      Invalid_Doc : constant String := "<priority>10</priority>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse.Success then
         Put_Line ("Failed to parse schema");
         return;
      end if;

      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("Failed to load schema: " &
               To_String (Schema_Load.Error_Message));
            return;
         end if;

         Put_Line ("Schema loaded successfully");

         --  Test if custom type fails validation
         declare
            Doc : constant Parse_Result := Parse (Invalid_Doc);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("Invalid doc with custom type: ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS - Custom type NOT working!");
               when Invalid =>
                  Put_Line ("FAIL - " & To_String (Result.Error_Message));
                  Put_Line ("       This means custom types ARE being resolved!");
            end case;
         end;
      end;
   end;
   New_Line;

   --  Test with undefined type reference
   Put_Line ("Testing undefined type reference...");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>test</name>" &
         "    <type>undefinedType</type>" &  -- Type doesn't exist
         "  </element>" &
         "</schema>";

      Doc_Text : constant String := "<test>anything</test>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse.Success then
         Put_Line ("Failed to parse schema");
         return;
      end if;

      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("Failed to load schema: " &
               To_String (Schema_Load.Error_Message));
            Put_Line ("Good! Schema loader caught undefined type");
            return;
         end if;

         Put_Line ("Schema loaded (shouldn't happen with undefined type!)");

         --  Test validation with undefined type
         declare
            Doc : constant Parse_Result := Parse (Doc_Text);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("Doc with undefined type: ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS - BUG: Should fail for undefined type!");
               when Invalid =>
                  Put_Line ("FAIL - " & To_String (Result.Error_Message));
                  if To_String (Result.Error_Message) = "Unknown type: undefinedType" or
                     To_String (Result.Error_Message) = "Simple type not found: undefinedType"
                  then
                     Put_Line ("       GOOD! Our fix is working!");
                  end if;
            end case;
         end;
      end;
   end;

   New_Line;
   Put_Line ("Test complete!");

end Test_Type_Resolution;