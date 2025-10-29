--  Lesson 1: Basic SML Parsing
--  ============================
--  This lesson teaches you how to:
--  - Parse SML documents from files
--  - Handle Parse_Result (success/error)
--  - Navigate the DOM tree (First_Child, Next_Sibling)
--  - Extract element names and text values
--  - Count and analyze document content
--
--  Key Concepts:
--  - Parse_Result: Contains either a parsed Document or a Parse_Error
--  - Document: Immutable, read-only representation of parsed SML
--  - Node_Id: Reference to nodes in the document tree
--  - Node_Kind: Element, Text, or other node types

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.IO; use SML.IO;

procedure Lesson_1_Basic_Parsing is

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

   --  Helper to get text content from an element
   --  Returns the text of the first Text node child, or empty string
   function Get_Element_Text (Doc : Document; Element : Node_Id) return String is
      Text_Node : constant Node_Id := First_Child (Doc, Element);
   begin
      if Text_Node /= Null_Node and then Kind (Doc, Text_Node) = Text then
         return Text_Value (Doc, Text_Node);
      end if;
      return "";
   end Get_Element_Text;

   --  Helper to find a child element by name
   function Find_Child_Element (Doc : Document; Parent : Node_Id; Element_Name : String) return Node_Id is
      Child : Node_Id := First_Child (Doc, Parent);
   begin
      while Child /= Null_Node loop
         if Kind (Doc, Child) = Element and then Name (Doc, Child) = Element_Name then
            return Child;
         end if;
         Child := Next_Sibling (Doc, Child);
      end loop;
      return Null_Node;
   end Find_Child_Element;

   --  Count tasks by status
   procedure Count_Tasks_By_Status (Doc : Document) is
      Root : constant Node_Id := SML.DOM.Root (Doc);
      Tasks_Node : Node_Id;
      Task_Node : Node_Id;
      Status_Node : Node_Id;
      Todo_Count : Natural := 0;
      In_Progress_Count : Natural := 0;
      Done_Count : Natural := 0;
      Blocked_Count : Natural := 0;
      Review_Count : Natural := 0;
      Other_Count : Natural := 0;
   begin
      --  Find the <tasks> element
      Tasks_Node := Find_Child_Element (Doc, Root, "tasks");

      if Tasks_Node = Null_Node then
         Put_Line ("  Warning: No <tasks> element found in document");
         return;
      end if;

      --  Iterate over all <task> elements
      Task_Node := First_Child (Doc, Tasks_Node);
      while Task_Node /= Null_Node loop
         if Kind (Doc, Task_Node) = Element and then Name (Doc, Task_Node) = "task" then
            --  Find the <status> element within this task
            Status_Node := Find_Child_Element (Doc, Task_Node, "status");

            if Status_Node /= Null_Node then
               declare
                  Status_Text : constant String := Get_Element_Text (Doc, Status_Node);
               begin
                  --  Count by status
                  if Status_Text = "todo" then
                     Todo_Count := Todo_Count + 1;
                  elsif Status_Text = "in_progress" then
                     In_Progress_Count := In_Progress_Count + 1;
                  elsif Status_Text = "done" then
                     Done_Count := Done_Count + 1;
                  elsif Status_Text = "blocked" then
                     Blocked_Count := Blocked_Count + 1;
                  elsif Status_Text = "review" then
                     Review_Count := Review_Count + 1;
                  else
                     Other_Count := Other_Count + 1;
                  end if;
               end;
            end if;
         end if;
         Task_Node := Next_Sibling (Doc, Task_Node);
      end loop;

      --  Display results
      New_Line;
      Put_Line ("Task Summary by Status:");
      Put_Line ("  Todo:        " & Natural'Image (Todo_Count));
      Put_Line ("  In Progress: " & Natural'Image (In_Progress_Count));
      Put_Line ("  Done:        " & Natural'Image (Done_Count));
      Put_Line ("  Blocked:     " & Natural'Image (Blocked_Count));
      Put_Line ("  Review:      " & Natural'Image (Review_Count));
      if Other_Count > 0 then
         Put_Line ("  Other:       " & Natural'Image (Other_Count));
      end if;
      Put_Line ("  -----------");
      Put_Line ("  Total Tasks: " & Natural'Image (
         Todo_Count + In_Progress_Count + Done_Count + Blocked_Count + Review_Count + Other_Count));
   end Count_Tasks_By_Status;

   --  Display basic information about tasks
   procedure Display_Task_List (Doc : Document) is
      Root : constant Node_Id := SML.DOM.Root (Doc);
      Tasks_Node : Node_Id;
      Task_Node : Node_Id;
      Task_Count : Natural := 0;
   begin
      --  Find the <tasks> element
      Tasks_Node := Find_Child_Element (Doc, Root, "tasks");

      if Tasks_Node = Null_Node then
         Put_Line ("  No tasks found");
         return;
      end if;

      New_Line;
      Put_Line ("Task List:");
      Put_Line ("----------");

      --  Iterate over all <task> elements
      Task_Node := First_Child (Doc, Tasks_Node);
      while Task_Node /= Null_Node loop
         if Kind (Doc, Task_Node) = Element and then Name (Doc, Task_Node) = "task" then
            Task_Count := Task_Count + 1;

            --  Get task details
            declare
               Title_Node : constant Node_Id := Find_Child_Element (Doc, Task_Node, "title");
               Status_Node : constant Node_Id := Find_Child_Element (Doc, Task_Node, "status");
               Priority_Node : constant Node_Id := Find_Child_Element (Doc, Task_Node, "priority");
               Title : constant String := (if Title_Node /= Null_Node then Get_Element_Text (Doc, Title_Node) else "(no title)");
               Status : constant String := (if Status_Node /= Null_Node then Get_Element_Text (Doc, Status_Node) else "unknown");
               Priority : constant String := (if Priority_Node /= Null_Node then Get_Element_Text (Doc, Priority_Node) else "?");
            begin
               Put_Line (Natural'Image (Task_Count) & ". [Priority " & Priority & "] " & Title);
               Put_Line ("   Status: " & Status);
            end;
         end if;
         Task_Node := Next_Sibling (Doc, Task_Node);
      end loop;

      if Task_Count = 0 then
         Put_Line ("  (no tasks found)");
      end if;
   end Display_Task_List;

   --  Test parsing with error handling
   procedure Test_Parse_Error is
   begin
      Print_Header ("Testing Error Handling");
      Put_Line ("Attempting to parse an invalid document...");
      New_Line;

      declare
         Parse_Res : constant Parse_Result := Parse_File ("fixtures/tasks_invalid.sml");
      begin
         if Parse_Res.Success then
            Put_Line ("  [UNEXPECTED] Document parsed successfully");
            Put_Line ("  This document should have parse errors!");
         else
            Put_Line ("  [EXPECTED] Parse error detected:");
            Put_Line ("  Error: " & Parse_Res.Error.Message (1 .. Parse_Res.Error.Msg_Length));
            Put_Line ("  Location: Line" & Natural'Image (Parse_Res.Error.Line) &
                      ", Column" & Natural'Image (Parse_Res.Error.Column));
         end if;
      end;
   end Test_Parse_Error;

begin
   Print_Header ("Lesson 1: Basic SML Parsing");

   Put_Line ("This lesson demonstrates:");
   Put_Line ("  1. Parsing SML documents from files");
   Put_Line ("  2. Navigating the DOM tree");
   Put_Line ("  3. Extracting text content from elements");
   Put_Line ("  4. Handling parse errors gracefully");
   New_Line;

   --  Part 1: Parse a valid document
   Print_Header ("Part 1: Parsing a Valid Document");
   Put_Line ("Loading fixtures/tasks_simple_sml.sml...");
   New_Line;

   declare
      Parse_Res : constant Parse_Result := Parse_File ("fixtures/tasks_simple_sml.sml");
   begin
      if Parse_Res.Success then
         Put_Line ("[OK] Document parsed successfully!");

         --  Display task information
         Display_Task_List (Parse_Res.Doc);

         --  Count tasks by status
         Count_Tasks_By_Status (Parse_Res.Doc);
      else
         Put_Line ("[ERROR] Failed to parse document:");
         Put_Line ("  " & Parse_Res.Error.Message (1 .. Parse_Res.Error.Msg_Length));
         Put_Line ("  At line" & Natural'Image (Parse_Res.Error.Line) &
                   ", column" & Natural'Image (Parse_Res.Error.Column));
      end if;
   end;

   New_Line;

   --  Part 2: Test error handling
   Test_Parse_Error;

   --  Summary
   New_Line;
   Print_Header ("Lesson 1 Complete!");
   Put_Line ("You've learned how to:");
   Put_Line ("  - Use Parse_File to load SML documents");
   Put_Line ("  - Check Parse_Result.Success for parse errors");
   Put_Line ("  - Navigate the DOM using First_Child and Next_Sibling");
   Put_Line ("  - Extract text content from elements");
   Put_Line ("  - Handle parse errors with detailed error messages");
   New_Line;
   Put_Line ("Next: Lesson 2 will teach you schema validation!");
   New_Line;

end Lesson_1_Basic_Parsing;
