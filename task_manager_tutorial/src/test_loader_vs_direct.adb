--  Test Schema Loader vs Direct Schema
--  ====================================
--  Compares validation between loaded schemas and the working pattern

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Test_Loader_Vs_Direct is

   procedure Test_Separator (Title : String) is
   begin
      New_Line;
      Put_Line ("=== " & Title & " ===");
   end Test_Separator;

begin
   Put_Line ("SCHEMA LOADER VS DIRECT TEST");
   Put_Line ("============================");
   New_Line;

   Test_Separator ("Test 1: Direct Schema (Working Pattern from debug_schema_loader)");

   --  This is the pattern that WORKS in debug_schema_loader
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
            Put ("Value 50: ");
            case Valid_Result.Status is
               when Valid => Put_Line ("VALID");
               when Invalid => Put_Line ("INVALID - " &
                  To_String (Valid_Result.Error_Message));
            end case;

            Put ("Value 200: ");
            case Invalid_Result.Status is
               when Valid => Put_Line ("VALID [BUG]");
               when Invalid => Put_Line ("INVALID [OK] - " &
                  To_String (Invalid_Result.Error_Message));
            end case;
         end;
      else
         Put_Line ("Schema failed to load");
      end if;
   end;

   Test_Separator ("Test 2: ComplexType with Custom Type (Tutorial Pattern)");

   --  This is the pattern used in the tutorial that FAILS
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
            Put ("Priority 3: ");
            case Valid_Result.Status is
               when Valid => Put_Line ("VALID");
               when Invalid => Put_Line ("INVALID - " &
                  To_String (Valid_Result.Error_Message));
            end case;

            Put ("Priority 10: ");
            case Invalid_Result.Status is
               when Valid => Put_Line ("VALID [BUG - Should fail]");
               when Invalid => Put_Line ("INVALID [OK] - " &
                  To_String (Invalid_Result.Error_Message));
            end case;
         end;
      else
         Put_Line ("Schema failed to load: " &
            To_String (Schema_Load.Error_Message));
      end if;
   end;

   Test_Separator ("Test 3: Named ComplexType Referenced by Element");

   --  Test with a named complexType (like in tasks_simple.schema.sml)
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
         "  <complexType>" &
         "    <name>taskType</name>" &
         "    <sequence>" &
         "      <element>" &
         "        <name>id</name>" &
         "        <type>string</type>" &
         "      </element>" &
         "      <element>" &
         "        <name>priority</name>" &
         "        <type>priorityType</type>" &
         "      </element>" &
         "    </sequence>" &
         "  </complexType>" &
         "  <element>" &
         "    <name>task</name>" &
         "    <type>taskType</type>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
      Schema_Load : constant Schema_Load_Result :=
         Load_Schema (Schema_Parse.Doc);
   begin
      if Schema_Load.Success then
         declare
            Valid_Doc : constant Parse_Result :=
               Parse ("<task><id>001</id><priority>3</priority></task>");
            Invalid_Doc : constant Parse_Result :=
               Parse ("<task><id>002</id><priority>10</priority></task>");

            Valid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
            Invalid_Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("Priority 3: ");
            case Valid_Result.Status is
               when Valid => Put_Line ("VALID");
               when Invalid => Put_Line ("INVALID - " &
                  To_String (Valid_Result.Error_Message));
            end case;

            Put ("Priority 10: ");
            case Invalid_Result.Status is
               when Valid => Put_Line ("VALID [BUG - Should fail]");
               when Invalid => Put_Line ("INVALID [OK] - " &
                  To_String (Invalid_Result.Error_Message));
            end case;
         end;
      else
         Put_Line ("Schema failed to load: " &
            To_String (Schema_Load.Error_Message));
      end if;
   end;

   Test_Separator ("CONCLUSION");
   Put_Line ("If Test 1 works but Tests 2-3 fail, the schema loader");
   Put_Line ("isn't properly handling complexType element type references.");
   Put_Line ("");
   Put_Line ("If all tests fail, the SML library update isn't present.");
   Put_Line ("");
   Put_Line ("If all tests work, the issue is with specific schema files.");

end Test_Loader_Vs_Direct;