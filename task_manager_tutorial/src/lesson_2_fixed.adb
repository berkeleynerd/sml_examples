--  Lesson 2: Schema Validation (Fixed Version)
--  ============================================
--  This demonstrates the correct way to use the SML Schema API

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;
with SML.IO; use SML.IO;

procedure Lesson_2_Fixed is

   --  Helper procedure to print a section header
   procedure Print_Header (Title : String) is
      Line : constant String (1 .. Title'Length + 4) := (others => '=');
   begin
      New_Line;
      Put_Line (Line);
      Put_Line ("  " & Title);
      Put_Line (Line);
      New_Line;
   end Print_Header;

   --  Test validation with a valid document
   procedure Test_Valid_Document (Schema : Schema_Document) is
   begin
      Put_Line ("Testing valid document...");

      declare
         Doc_Parse : constant Parse_Result :=
            Parse_File ("fixtures/tasks_simple_sml.sml");
      begin
         if not Doc_Parse.Success then
            Put_Line ("  Failed to parse document:");
            Put_Line ("  " & Doc_Parse.Error.Message (1 .. Doc_Parse.Error.Msg_Length));
            Put_Line ("  Line " & Natural'Image (Doc_Parse.Error.Line) &
                      ", Column " & Natural'Image (Doc_Parse.Error.Column));
            return;
         end if;

         declare
            Result : constant Validation_Result :=
               Validate_Document (Schema, Doc_Parse.Doc);
         begin
            case Result.Status is
               when Valid =>
                  Put_Line ("  [OK] Document is valid!");

               when Invalid =>
                  Put_Line ("  [FAIL] Validation failed (unexpected):");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
                  Put_Line ("    Path: " & To_String (Result.Error_Path));
                  if Result.Line > 0 then
                     Put_Line ("    Line: " & Natural'Image (Result.Line));
                  end if;
            end case;
         end;
      end;
      New_Line;
   end Test_Valid_Document;

   --  Test validation with an invalid document
   procedure Test_Invalid_Document (Schema : Schema_Document) is
   begin
      Put_Line ("Testing invalid document...");

      --  Create an invalid document with priority out of range
      declare
         Invalid_SML : constant String :=
            "<task_database>" &
            "  <metadata>" &
            "    <version>1.0</version>" &
            "    <last_updated>2025-01-23</last_updated>" &
            "  </metadata>" &
            "  <projects>" &
            "    <project>" &
            "      <id>proj_001</id>" &
            "      <name>Test Project</name>" &
            "      <status>active</status>" &
            "      <created>2025-01-01</created>" &
            "      <owner>test</owner>" &
            "    </project>" &
            "  </projects>" &
            "  <tasks>" &
            "    <task>" &
            "      <id>task_001</id>" &
            "      <project_id>proj_001</project_id>" &
            "      <title>Invalid Task</title>" &
            "      <priority>10</priority>" &  -- Invalid: should be 1-5
            "      <status>invalid_status</status>" &  -- Invalid enum value
            "    </task>" &
            "  </tasks>" &
            "</task_database>";

         Doc_Parse : constant Parse_Result := Parse (Invalid_SML);
      begin
         if not Doc_Parse.Success then
            Put_Line ("  Failed to parse test document:");
            Put_Line ("  " & Doc_Parse.Error.Message (1 .. Doc_Parse.Error.Msg_Length));
            return;
         end if;

         declare
            Result : constant Validation_Result :=
               Validate_Document (Schema, Doc_Parse.Doc);
         begin
            case Result.Status is
               when Valid =>
                  Put_Line ("  [FAIL] Document is valid (unexpected!)");

               when Invalid =>
                  Put_Line ("  [OK] Validation correctly failed:");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
                  Put_Line ("    Path: " & To_String (Result.Error_Path));
                  if Result.Line > 0 then
                     Put_Line ("    Line: " & Natural'Image (Result.Line));
                  end if;
            end case;
         end;
      end;
      New_Line;
   end Test_Invalid_Document;

   --  Test missing required elements
   procedure Test_Missing_Elements (Schema : Schema_Document) is
   begin
      Put_Line ("Testing missing required elements...");

      declare
         Incomplete_SML : constant String :=
            "<task_database>" &
            "  <metadata>" &
            "    <version>1.0</version>" &
            "    <last_updated>2025-01-23</last_updated>" &
            "  </metadata>" &
            "  <projects>" &
            "  </projects>" &
            "  <tasks>" &
            "    <task>" &
            "      <id>task_001</id>" &
            "      <project_id>proj_001</project_id>" &
            "      <title>Task without priority/status</title>" &
            "    </task>" &
            "  </tasks>" &
            "</task_database>";

         Doc_Parse : constant Parse_Result := Parse (Incomplete_SML);
      begin
         if not Doc_Parse.Success then
            Put_Line ("  Failed to parse test document:");
            Put_Line ("  " & Doc_Parse.Error.Message (1 .. Doc_Parse.Error.Msg_Length));
            return;
         end if;

         declare
            Result : constant Validation_Result :=
               Validate_Document (Schema, Doc_Parse.Doc);
         begin
            case Result.Status is
               when Valid =>
                  Put_Line ("  [FAIL] Document is valid (unexpected!)");

               when Invalid =>
                  Put_Line ("  [OK] Validation correctly failed:");
                  Put_Line ("    Error: " & To_String (Result.Error_Message));
                  Put_Line ("    Path: " & To_String (Result.Error_Path));
            end case;
         end;
      end;
      New_Line;
   end Test_Missing_Elements;

begin
   Print_Header ("Lesson 2: Schema Validation (Fixed)");

   Put_Line ("This lesson demonstrates the correct way to:");
   Put_Line ("  1. Parse a schema file into a Document");
   Put_Line ("  2. Load the schema using Schema.Loader");
   Put_Line ("  3. Validate documents against the schema");
   Put_Line ("  4. Handle validation errors properly");
   New_Line;

   --  Step 1: Parse the schema file
   Put_Line ("Step 1: Parsing schema file...");
   declare
      Schema_Parse : constant Parse_Result :=
         Parse_File ("fixtures/tasks_simple.schema.sml");
   begin
      if not Schema_Parse.Success then
         Put_Line ("Failed to parse schema file:");
         Put_Line ("  " & Schema_Parse.Error.Message (1 .. Schema_Parse.Error.Msg_Length));
         Put_Line ("  At line " & Natural'Image (Schema_Parse.Error.Line) &
                   ", column " & Natural'Image (Schema_Parse.Error.Column));
         return;
      end if;

      Put_Line ("  [OK] Schema file parsed successfully");
      New_Line;

      --  Step 2: Load the schema from the parsed document
      Put_Line ("Step 2: Loading schema from document...");
      declare
         Schema_Load : constant Schema_Load_Result :=
            Load_Schema (Schema_Parse.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("Failed to load schema:");
            Put_Line ("  " & To_String (Schema_Load.Error_Message));
            if Schema_Load.Error_Line > 0 then
               Put_Line ("  Line: " & Natural'Image (Schema_Load.Error_Line));
            end if;
            return;
         end if;

         Put_Line ("  [OK] Schema loaded successfully");
         New_Line;

         --  Step 3: Run validation tests
         Put_Line ("Step 3: Running validation tests...");
         New_Line;

         Test_Valid_Document (Schema_Load.Schema);
         Test_Invalid_Document (Schema_Load.Schema);
         Test_Missing_Elements (Schema_Load.Schema);

         --  Summary
         Print_Header ("Schema Validation Complete");
         Put_Line ("Key takeaways:");
         Put_Line ("  * Schemas are documents that must be parsed first");
         Put_Line ("  * Use Schema.Loader to convert Document -> Schema");
         Put_Line ("  * Validation returns Status (Valid/Invalid), not boolean");
         Put_Line ("  * Error messages use Bounded_String (call To_String)");
         Put_Line ("  * All results are limited types (use constant)");
      end;
   end;

exception
   when others =>
      Put_Line ("Unexpected error in schema validation lesson");
      Put_Line ("This may indicate a bug in the implementation");
end Lesson_2_Fixed;