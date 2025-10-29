--  Test Inline Schema Validation
--  ==============================
--  Tests if validation works better with inline type definitions

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;
with SML.IO; use SML.IO;

procedure Test_Inline_Schema is

   procedure Test_File (Schema : Schema_Document; File_Name : String;
                        Should_Pass : Boolean) is
      Doc_Parse : constant Parse_Result := Parse_File (File_Name);
   begin
      Put ("Testing " & File_Name & "... ");

      if not Doc_Parse.Success then
         Put_Line ("PARSE FAILED: " &
            Doc_Parse.Error.Message (1 .. Doc_Parse.Error.Msg_Length));
         return;
      end if;

      declare
         Result : constant Validation_Result :=
            Validate_Document (Schema, Doc_Parse.Doc);
      begin
         case Result.Status is
            when Valid =>
               if Should_Pass then
                  Put_Line ("[OK] Valid as expected");
               else
                  Put_Line ("[FAIL] Should have failed but passed!");
               end if;

            when Invalid =>
               if Should_Pass then
                  Put_Line ("[FAIL] Should have passed but failed:");
                  Put_Line ("  Error: " & To_String (Result.Error_Message));
               else
                  Put_Line ("[OK] Failed as expected:");
                  Put_Line ("  Error: " & To_String (Result.Error_Message));
               end if;
         end case;
      end;
   end Test_File;

begin
   Put_Line ("===========================================");
   Put_Line ("  Testing Inline Schema Validation");
   Put_Line ("===========================================");
   New_Line;

   --  Load the inline schema
   Put_Line ("Loading inline schema...");
   declare
      Schema_Parse : constant Parse_Result :=
         Parse_File ("fixtures/fixed_inline.schema.sml");
   begin
      if not Schema_Parse.Success then
         Put_Line ("Failed to parse schema: " &
            Schema_Parse.Error.Message (1 .. Schema_Parse.Error.Msg_Length));
         return;
      end if;

      Put_Line ("Schema parsed successfully");
      New_Line;

      --  Load schema
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
         New_Line;

         --  Run tests
         Put_Line ("Running validation tests:");
         Put_Line ("--------------------------");

         Test_File (Schema_Load.Schema,
                    "fixtures/task_valid.sml",
                    Should_Pass => True);

         Test_File (Schema_Load.Schema,
                    "fixtures/task_invalid_priority.sml",
                    Should_Pass => False);

         Test_File (Schema_Load.Schema,
                    "fixtures/task_invalid_status.sml",
                    Should_Pass => False);

         New_Line;
         Put_Line ("Test complete!");
      end;
   end;

end Test_Inline_Schema;