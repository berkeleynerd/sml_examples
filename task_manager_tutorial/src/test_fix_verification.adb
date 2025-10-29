--  Fix Verification Test
--  =====================
--  Tests the specific patterns that should be fixed

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Test_Fix_Verification is
begin
   Put_Line ("FIX VERIFICATION TEST");
   Put_Line ("=====================");
   New_Line;

   --  Test 1: Top-level element with custom simpleType (SHOULD BE FIXED)
   Put_Line ("Test 1: Top-level element with custom simpleType");
   Put_Line ("-------------------------------------------------");
   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <simpleType>" &
         "    <name>scoreType</name>" &
         "    <restriction>" &
         "      <base>integer</base>" &
         "      <minValue>1</minValue>" &
         "      <maxValue>100</maxValue>" &
         "    </restriction>" &
         "  </simpleType>" &
         "  <element>" &
         "    <name>score</name>" &
         "    <type>scoreType</type>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
      Schema_Load : constant Schema_Load_Result :=
         Load_Schema (Schema_Parse.Doc);
   begin
      if Schema_Load.Success then
         declare
            Valid_Doc : constant Parse_Result := Parse ("<score>50</score>");
            Invalid_Doc : constant Parse_Result := Parse ("<score>200</score>");

            Valid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
            Invalid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Value 50: ");
            case Valid_Result.Status is
               when Valid => Put_Line ("VALID [OK]");
               when Invalid => Put_Line ("INVALID [WRONG]");
            end case;

            Put ("  Value 200: ");
            case Invalid_Result.Status is
               when Valid => Put_Line ("VALID [WRONG - Fix not applied]");
               when Invalid => Put_Line ("INVALID [OK - Fix is working!]");
            end case;
         end;
      else
         Put_Line ("  Schema failed to load");
      end if;
   end;

   New_Line;
   Put_Line ("Test 2: Element in complexType with custom simpleType");
   Put_Line ("------------------------------------------------------");
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
         "    <name>task</name>" &
         "    <complexType>" &
         "      <sequence>" &
         "        <element>" &
         "          <name>priority</name>" &
         "          <type>priorityType</type>" &
         "        </element>" &
         "      </sequence>" &
         "    </complexType>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
      Schema_Load : constant Schema_Load_Result :=
         Load_Schema (Schema_Parse.Doc);
   begin
      if Schema_Load.Success then
         declare
            Valid_Doc : constant Parse_Result :=
               Parse ("<task><priority>3</priority></task>");
            Invalid_Doc : constant Parse_Result :=
               Parse ("<task><priority>10</priority></task>");

            Valid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
            Invalid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Priority 3: ");
            case Valid_Result.Status is
               when Valid => Put_Line ("VALID [OK]");
               when Invalid => Put_Line ("INVALID [WRONG]");
            end case;

            Put ("  Priority 10: ");
            case Invalid_Result.Status is
               when Valid => Put_Line ("VALID [WRONG - Fix not applied]");
               when Invalid => Put_Line ("INVALID [OK - Fix is working!]");
            end case;
         end;
      else
         Put_Line ("  Schema failed to load");
      end if;
   end;

   New_Line;
   Put_Line ("SUMMARY");
   Put_Line ("-------");
   Put_Line ("If Test 1 shows 'Fix is working!' - top-level elements are fixed");
   Put_Line ("If Test 2 shows 'Fix is working!' - complexType elements are fixed");
   Put_Line ("If both show 'Fix not applied' - the fix isn't in the current build");

end Test_Fix_Verification;