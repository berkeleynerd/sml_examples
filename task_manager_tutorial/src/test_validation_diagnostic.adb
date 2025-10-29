--  Diagnostic Test for Schema Validation
--  =======================================
--  This test helps diagnose why validation isn't working

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;
with SML.IO; use SML.IO;

procedure Test_Validation_Diagnostic is
begin
   Put_Line ("========================================");
   Put_Line ("  Schema Validation Diagnostic Test");
   Put_Line ("========================================");
   New_Line;

   --  Test 1: Most basic integer validation
   Put_Line ("Test 1: Direct integer type with constraints");
   Put_Line ("---------------------------------------------");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>test</name>" &
         "    <type>integer</type>" &
         "    <minValue>1</minValue>" &
         "    <maxValue>5</maxValue>" &
         "  </element>" &
         "</schema>";

      Valid_Doc : constant String := "<test>3</test>";
      Invalid_Doc : constant String := "<test>10</test>";

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

         --  Test valid document
         declare
            Doc : constant Parse_Result := Parse (Valid_Doc);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("  Valid doc (3): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS");
               when Invalid =>
                  Put_Line ("FAIL - " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test invalid document
         declare
            Doc : constant Parse_Result := Parse (Invalid_Doc);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("  Invalid doc (10): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS (WRONG!)");
               when Invalid =>
                  Put_Line ("FAIL (CORRECT) - " &
                           To_String (Result.Error_Message));
            end case;
         end;
      end;
   end;
   New_Line;

   --  Test 2: String enumeration
   Put_Line ("Test 2: String enumeration");
   Put_Line ("--------------------------");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>status</name>" &
         "    <type>string</type>" &
         "    <enumeration>" &
         "      <value>todo</value>" &
         "      <value>done</value>" &
         "    </enumeration>" &
         "  </element>" &
         "</schema>";

      Valid_Doc : constant String := "<status>todo</status>";
      Invalid_Doc : constant String := "<status>working</status>";

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
            Put_Line ("Failed to load schema");
            return;
         end if;

         --  Test valid document
         declare
            Doc : constant Parse_Result := Parse (Valid_Doc);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("  Valid doc (todo): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS");
               when Invalid =>
                  Put_Line ("FAIL - " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test invalid document
         declare
            Doc : constant Parse_Result := Parse (Invalid_Doc);
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Doc.Doc);
         begin
            Put ("  Invalid doc (working): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS (WRONG!)");
               when Invalid =>
                  Put_Line ("FAIL (CORRECT) - " &
                           To_String (Result.Error_Message));
            end case;
         end;
      end;
   end;
   New_Line;

   Put_Line ("Diagnostic complete!");

end Test_Validation_Diagnostic;