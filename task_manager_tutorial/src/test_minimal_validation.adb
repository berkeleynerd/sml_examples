--  Minimal Validation Test
--  =======================
--  Simplest possible test to isolate validation issues

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Test_Minimal_Validation is

   procedure Test_Separator (Name : String) is
   begin
      New_Line;
      Put_Line ("=== " & Name & " ===");
      Put_Line ((1 .. Name'Length + 8 => '-'));
   end Test_Separator;

begin
   Put_Line ("MINIMAL VALIDATION TEST");
   Put_Line ("=======================");
   New_Line;

   --  Test 1: Absolute simplest case - single integer with range
   Test_Separator ("Test 1: Integer with minValue=1, maxValue=5");

   declare
      --  Simplest possible schema
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>number</name>" &
         "    <type>integer</type>" &
         "    <minValue>1</minValue>" &
         "    <maxValue>5</maxValue>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse.Success then
         Put_Line ("ERROR: Failed to parse schema");
         return;
      end if;
      Put_Line ("[OK] Schema parsed");

      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("ERROR: Failed to load schema: " &
                     To_String (Schema_Load.Error_Message));
            return;
         end if;
         Put_Line ("[OK] Schema loaded");

         --  Test valid value (3)
         declare
            Valid_Doc : constant Parse_Result := Parse ("<number>3</number>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
         begin
            Put ("  Testing value=3 (should PASS): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [OK]");
               when Invalid =>
                  Put_Line ("FAIL [ERROR]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test invalid value (10)
         declare
            Invalid_Doc : constant Parse_Result := Parse ("<number>10</number>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Testing value=10 (should FAIL): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [BUG: Should have failed!]");
               when Invalid =>
                  Put_Line ("FAIL [OK - Expected failure]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test invalid value (0)
         declare
            Invalid_Doc : constant Parse_Result := Parse ("<number>0</number>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Testing value=0 (should FAIL): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [BUG: Should have failed!]");
               when Invalid =>
                  Put_Line ("FAIL [OK - Expected failure]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;
      end;
   end;

   --  Test 2: Simple enumeration
   Test_Separator ("Test 2: String enumeration [yes, no]");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>answer</name>" &
         "    <type>string</type>" &
         "    <enumeration>" &
         "      <value>yes</value>" &
         "      <value>no</value>" &
         "    </enumeration>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse.Success then
         Put_Line ("ERROR: Failed to parse schema");
         return;
      end if;
      Put_Line ("[OK] Schema parsed");

      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("ERROR: Failed to load schema: " &
                     To_String (Schema_Load.Error_Message));
            return;
         end if;
         Put_Line ("[OK] Schema loaded");

         --  Test valid value (yes)
         declare
            Valid_Doc : constant Parse_Result := Parse ("<answer>yes</answer>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
         begin
            Put ("  Testing value='yes' (should PASS): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [OK]");
               when Invalid =>
                  Put_Line ("FAIL [ERROR]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test invalid value (maybe)
         declare
            Invalid_Doc : constant Parse_Result := Parse ("<answer>maybe</answer>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Testing value='maybe' (should FAIL): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [BUG: Should have failed!]");
               when Invalid =>
                  Put_Line ("FAIL [OK - Expected failure]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;
      end;
   end;

   --  Test 3: Missing required element
   Test_Separator ("Test 3: Missing required element");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <element>" &
         "    <name>person</name>" &
         "    <complexType>" &
         "      <sequence>" &
         "        <element>" &
         "          <name>name</name>" &
         "          <type>string</type>" &
         "          <minOccurs>1</minOccurs>" &
         "        </element>" &
         "        <element>" &
         "          <name>age</name>" &
         "          <type>integer</type>" &
         "          <minOccurs>1</minOccurs>" &
         "        </element>" &
         "      </sequence>" &
         "    </complexType>" &
         "  </element>" &
         "</schema>";

      Schema_Parse : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse.Success then
         Put_Line ("ERROR: Failed to parse schema");
         return;
      end if;
      Put_Line ("[OK] Schema parsed");

      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("ERROR: Failed to load schema: " &
                     To_String (Schema_Load.Error_Message));
            return;
         end if;
         Put_Line ("[OK] Schema loaded");

         --  Test complete document
         declare
            Valid_Doc : constant Parse_Result :=
               Parse ("<person><name>John</name><age>30</age></person>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
         begin
            Put ("  Testing complete document (should PASS): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [OK]");
               when Invalid =>
                  Put_Line ("FAIL [ERROR]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;

         --  Test missing age element
         declare
            Invalid_Doc : constant Parse_Result :=
               Parse ("<person><name>John</name></person>");
            Result : constant Validation_Result :=
               Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
         begin
            Put ("  Testing missing 'age' (should FAIL): ");
            case Result.Status is
               when Valid =>
                  Put_Line ("PASS [BUG: Should have failed!]");
               when Invalid =>
                  Put_Line ("FAIL [OK - Expected failure]");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
            end case;
         end;
      end;
   end;

   New_Line;
   Put_Line ("=== SUMMARY ===");
   Put_Line ("If you see '[BUG: Should have failed!]' above,");
   Put_Line ("then validation constraints are NOT being enforced.");
   Put_Line ("This indicates the issue is in the Validate_Document");
   Put_Line ("implementation in the SML.Schema package.");

end Test_Minimal_Validation;