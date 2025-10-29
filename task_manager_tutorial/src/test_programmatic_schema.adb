--  Test Programmatic Schema Construction
--  ======================================
--  Tests validation with programmatically constructed schemas
--  to isolate whether the issue is in validation or schema loading

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;

procedure Test_Programmatic_Schema is

   function Create_Test_Schema return Schema_Document is
      Schema : Schema_Document;

      --  Define priorityType (1-5)
      Priority_Type : Simple_Type_Definition;

      --  Define taskType complexType
      Task_Type : Complex_Type_Definition;
      Task_Seq : Element_Sequence (1 .. 2);

      --  Define root element
      Root_Element : Element_Definition;
   begin
      --  Create priorityType with range 1-5
      Priority_Type.Name := To_Bounded_String ("priorityType");
      Priority_Type.Base_Type := Integer_Type;
      Priority_Type.Min_Value := 1;
      Priority_Type.Max_Value := 5;
      Priority_Type.Has_Min := True;
      Priority_Type.Has_Max := True;

      --  Add to schema's simple types
      Schema.Simple_Type_Count := 1;
      Schema.Simple_Types (1) := Priority_Type;

      --  Create taskType complexType with sequence
      Task_Type.Name := To_Bounded_String ("taskType");
      Task_Type.Content_Type := Sequence;

      --  First element: title (string)
      Task_Seq (1).Name := To_Bounded_String ("title");
      Task_Seq (1).Type_Name := To_Bounded_String ("string");
      Task_Seq (1).Min_Occurs := 1;
      Task_Seq (1).Max_Occurs := 1;

      --  Second element: priority (priorityType)
      Task_Seq (2).Name := To_Bounded_String ("priority");
      Task_Seq (2).Type_Name := To_Bounded_String ("priorityType");
      Task_Seq (2).Min_Occurs := 1;
      Task_Seq (2).Max_Occurs := 1;

      Task_Type.Sequence_Count := 2;
      Task_Type.Sequence := Task_Seq;

      --  Add to schema's complex types
      Schema.Complex_Type_Count := 1;
      Schema.Complex_Types (1) := Task_Type;

      --  Create root element using taskType
      Root_Element.Name := To_Bounded_String ("task");
      Root_Element.Type_Name := To_Bounded_String ("taskType");
      Root_Element.Min_Occurs := 1;
      Root_Element.Max_Occurs := 1;

      Schema.Root_Element := Root_Element;
      Schema.Has_Root := True;

      return Schema;
   end Create_Test_Schema;

begin
   Put_Line ("PROGRAMMATIC SCHEMA TEST");
   Put_Line ("========================");
   Put_Line ("Testing validation with programmatically constructed schema");
   Put_Line ("(bypassing schema loader)");
   New_Line;

   declare
      Schema : constant Schema_Document := Create_Test_Schema;
   begin
      Put_Line ("Schema created programmatically with:");
      Put_Line ("  - priorityType: integer 1-5");
      Put_Line ("  - taskType: complexType with title and priority");
      Put_Line ("  - task: root element of taskType");
      New_Line;

      --  Test 1: Valid document
      Put_Line ("Test 1: Valid priority (3)");
      declare
         Doc_Text : constant String :=
            "<task>" &
            "  <title>Test Task</title>" &
            "  <priority>3</priority>" &
            "</task>";
         Doc : constant Parse_Result := Parse (Doc_Text);
         Result : constant Validation_Result :=
            Validate_Document (Schema, Doc.Doc);
      begin
         Put ("  Result: ");
         case Result.Status is
            when Valid =>
               Put_Line ("VALID [OK]");
            when Invalid =>
               Put_Line ("INVALID [WRONG] - " & To_String (Result.Error_Message));
         end case;
      end;

      --  Test 2: Invalid document (priority > 5)
      Put_Line ("Test 2: Invalid priority (10)");
      declare
         Doc_Text : constant String :=
            "<task>" &
            "  <title>Test Task</title>" &
            "  <priority>10</priority>" &
            "</task>";
         Doc : constant Parse_Result := Parse (Doc_Text);
         Result : constant Validation_Result :=
            Validate_Document (Schema, Doc.Doc);
      begin
         Put ("  Result: ");
         case Result.Status is
            when Valid =>
               Put_Line ("VALID [WRONG - Should fail!]");
            when Invalid =>
               Put_Line ("INVALID [OK] - " & To_String (Result.Error_Message));
         end case;
      end;

      --  Test 3: Invalid document (priority < 1)
      Put_Line ("Test 3: Invalid priority (0)");
      declare
         Doc_Text : constant String :=
            "<task>" &
            "  <title>Test Task</title>" &
            "  <priority>0</priority>" &
            "</task>";
         Doc : constant Parse_Result := Parse (Doc_Text);
         Result : constant Validation_Result :=
            Validate_Document (Schema, Doc.Doc);
      begin
         Put ("  Result: ");
         case Result.Status is
            when Valid =>
               Put_Line ("VALID [WRONG - Should fail!]");
            when Invalid =>
               Put_Line ("INVALID [OK] - " & To_String (Result.Error_Message));
         end case;
      end;
   end;

   New_Line;
   Put_Line ("CONCLUSION:");
   Put_Line ("-----------");
   Put_Line ("If validation works here but not with loaded schemas,");
   Put_Line ("the issue is in the schema loader (sml-schema-loader.adb)");
   Put_Line ("not properly setting Type_Name for complexType elements.");

exception
   when others =>
      Put_Line ("ERROR: Exception during test");
end Test_Programmatic_Schema;