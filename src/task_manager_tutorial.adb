--  Task Manager Tutorial
--  =====================
--  This tutorial demonstrates building a complete task management
--  system using the SML library, exercising:
--  - Parsing SML documents
--  - Schema validation
--  - DOM manipulation
--  - File I/O operations
--  - Querying and reporting

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.DOM.Builder; use SML.DOM.Builder;
with SML.DOM.Writer; use SML.DOM.Writer;
with SML.Schema; use SML.Schema;
with SML.IO; use SML.IO;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Task_Manager_Tutorial is

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

   --  Helper procedure to print task details
   procedure Print_Task (Doc : Document; Task_Node : Node_Id) is
      Title_Node : Node_Id;
      Status_Node : Node_Id;
      Priority_Node : Node_Id;
      Assigned_Node : Node_Id;
   begin
      if Kind (Doc, Task_Node) = Element and then
         Name (Doc, Task_Node) = "task"
      then
         --  Get task title
         Title_Node := First_Child (Doc, Task_Node);
         while Is_Valid_Node (Doc, Title_Node) loop
            if Kind (Doc, Title_Node) = Element and then
               Name (Doc, Title_Node) = "title"
            then
               Put ("  Task: ");
               declare
                  Text_Node : constant Node_Id := First_Child (Doc, Title_Node);
               begin
                  if Is_Valid_Node (Doc, Text_Node) and then
                     Kind (Doc, Text_Node) = Text
                  then
                     Put (Text_Value (Doc, Text_Node));
                  end if;
               end;
               exit;
            end if;
            Title_Node := Next_Sibling (Doc, Title_Node);
         end loop;

         --  Get status
         Status_Node := First_Child (Doc, Task_Node);
         while Is_Valid_Node (Doc, Status_Node) loop
            if Kind (Doc, Status_Node) = Element and then
               Name (Doc, Status_Node) = "status"
            then
               Put (" [");
               declare
                  Text_Node : constant Node_Id := First_Child (Doc, Status_Node);
               begin
                  if Is_Valid_Node (Doc, Text_Node) and then
                     Kind (Doc, Text_Node) = Text
                  then
                     Put (Text_Value (Doc, Text_Node));
                  end if;
               end;
               Put ("]");
               exit;
            end if;
            Status_Node := Next_Sibling (Doc, Status_Node);
         end loop;

         --  Get priority
         Priority_Node := First_Child (Doc, Task_Node);
         while Is_Valid_Node (Doc, Priority_Node) loop
            if Kind (Doc, Priority_Node) = Element and then
               Name (Doc, Priority_Node) = "priority"
            then
               Put (" Priority: ");
               declare
                  Text_Node : constant Node_Id := First_Child (Doc, Priority_Node);
               begin
                  if Is_Valid_Node (Doc, Text_Node) and then
                     Kind (Doc, Text_Node) = Text
                  then
                     Put (Text_Value (Doc, Text_Node));
                  end if;
               end;
               exit;
            end if;
            Priority_Node := Next_Sibling (Doc, Priority_Node);
         end loop;

         New_Line;
      end if;
   end Print_Task;

   --  Count tasks by status
   procedure Count_Tasks_By_Status (Doc : Document) is
      Tasks_Node : Node_Id;
      Task_Node : Node_Id;
      Status_Node : Node_Id;
      Todo_Count : Natural := 0;
      In_Progress_Count : Natural := 0;
      Done_Count : Natural := 0;
      Other_Count : Natural := 0;
   begin
      --  Find tasks element
      declare
         Root : constant Node_Id := SML.DOM.Root (Doc);
         Child : Node_Id := First_Child (Doc, Root);
      begin
         while Is_Valid_Node (Doc, Child) loop
            if Kind (Doc, Child) = Element and then
               Name (Doc, Child) = "tasks"
            then
               Tasks_Node := Child;
               exit;
            end if;
            Child := Next_Sibling (Doc, Child);
         end loop;
      end;

      if Is_Valid_Node (Doc, Tasks_Node) then
         Task_Node := First_Child (Doc, Tasks_Node);
         while Is_Valid_Node (Doc, Task_Node) loop
            if Kind (Doc, Task_Node) = Element and then
               Name (Doc, Task_Node) = "task"
            then
               --  Find status element
               Status_Node := First_Child (Doc, Task_Node);
               while Is_Valid_Node (Doc, Status_Node) loop
                  if Kind (Doc, Status_Node) = Element and then
                     Name (Doc, Status_Node) = "status"
                  then
                     declare
                        Text_Node : constant Node_Id := First_Child (Doc, Status_Node);
                        Status_Text : String (1 .. 20);
                        Status_Len : Natural := 0;
                     begin
                        if Is_Valid_Node (Doc, Text_Node) and then
                           Kind (Doc, Text_Node) = Text
                        then
                           declare
                              Full_Text : constant String := Text_Value (Doc, Text_Node);
                           begin
                              Status_Len := Natural'Min (Full_Text'Length, Status_Text'Length);
                              Status_Text (1 .. Status_Len) := Full_Text (Full_Text'First .. Full_Text'First + Status_Len - 1);

                              if Status_Len >= 4 and then Status_Text (1 .. 4) = "todo" then
                                 Todo_Count := Todo_Count + 1;
                              elsif Status_Len >= 11 and then Status_Text (1 .. 11) = "in_progress" then
                                 In_Progress_Count := In_Progress_Count + 1;
                              elsif Status_Len >= 4 and then Status_Text (1 .. 4) = "done" then
                                 Done_Count := Done_Count + 1;
                              else
                                 Other_Count := Other_Count + 1;
                              end if;
                           end;
                        end if;
                     end;
                     exit;
                  end if;
                  Status_Node := Next_Sibling (Doc, Status_Node);
               end loop;
            end if;
            Task_Node := Next_Sibling (Doc, Task_Node);
         end loop;
      end if;

      Put_Line ("Task Summary:");
      Put_Line ("  Todo:        " & Natural'Image (Todo_Count));
      Put_Line ("  In Progress: " & Natural'Image (In_Progress_Count));
      Put_Line ("  Done:        " & Natural'Image (Done_Count));
      Put_Line ("  Other:       " & Natural'Image (Other_Count));
      Put_Line ("  Total:       " & Natural'Image (Todo_Count + In_Progress_Count + Done_Count + Other_Count));
   end Count_Tasks_By_Status;

   --  Tutorial lessons
   procedure Lesson_1_Basic_Parsing is
      Parse_Res : Parse_Result;
   begin
      Print_Header ("Lesson 1: Basic Parsing");
      Put_Line ("Loading and parsing a simple task list...");

      --  Load and parse the simple task file
      Parse_Res := Parse_File ("fixtures/tasks_simple.sml");

      if Parse_Res.Success then
         Put_Line ("Successfully parsed task database!");
         Put_Line ("Document is well-formed: " &
                   Boolean'Image (Is_Well_Formed (Parse_Res.Document)));
         New_Line;

         --  Count and display tasks
         Count_Tasks_By_Status (Parse_Res.Document);
      else
         Put_Line ("Parse error: " & Parse_Res.Error.Message);
         Put_Line ("At line" & Natural'Image (Parse_Res.Error.Line) &
                   ", column" & Natural'Image (Parse_Res.Error.Column));
      end if;
   end Lesson_1_Basic_Parsing;

   procedure Lesson_2_Schema_Validation is
      Schema_Res : Schema_Load_Result;
      Parse_Res : Parse_Result;
      Valid_Res : Validation_Result;
   begin
      Print_Header ("Lesson 2: Schema Validation");

      --  Load the schema
      Put_Line ("Loading task schema...");
      Schema_Res := Load_Schema_From_File ("fixtures/tasks.schema.sml");

      if not Schema_Res.Success then
         Put_Line ("Failed to load schema: " & Schema_Res.Error_Message);
         return;
      end if;

      Put_Line ("Schema loaded successfully!");
      New_Line;

      --  Try to validate a valid document
      Put_Line ("Validating a valid task document...");
      Parse_Res := Parse_File ("fixtures/tasks_simple.sml");

      if Parse_Res.Success then
         Valid_Res := Validate (Parse_Res.Document, Schema_Res.Schema);
         if Valid_Res.Is_Valid then
            Put_Line ("Document is valid according to schema!");
         else
            Put_Line ("Validation failed: " & Valid_Res.Error_Message);
            Put_Line ("At location: " & Valid_Res.Error_Location);
         end if;
      else
         Put_Line ("Parse error: " & Parse_Res.Error.Message);
      end if;

      New_Line;

      --  Try to validate an invalid document
      Put_Line ("Validating an invalid task document...");
      Parse_Res := Parse_File ("fixtures/tasks_invalid.sml");

      if Parse_Res.Success then
         Valid_Res := Validate (Parse_Res.Document, Schema_Res.Schema);
         if Valid_Res.Is_Valid then
            Put_Line ("Document is valid (unexpected!)");
         else
            Put_Line ("Validation correctly failed!");
            Put_Line ("Error: " & Valid_Res.Error_Message);
            Put_Line ("Location: " & Valid_Res.Error_Location);
         end if;
      else
         Put_Line ("Parse error (document malformed): " & Parse_Res.Error.Message);
      end if;
   end Lesson_2_Schema_Validation;

   procedure Lesson_3_Building_Documents is
      Doc : Document;
      Root : Node_Id;
      Metadata : Node_Id;
      Projects : Node_Id;
      Tasks : Node_Id;
      Project : Node_Id;
      Task_Node : Node_Id;
      Write_Res : Write_Result;
   begin
      Print_Header ("Lesson 3: Building Documents Programmatically");

      Put_Line ("Creating a new task database from scratch...");

      --  Create root element
      Doc := Create_Document ("task_database");
      Root := SML.DOM.Root (Doc);

      --  Add metadata section
      Metadata := Add_Child_Element (Doc, Root, "metadata");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Metadata, "version"), "1.0");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Metadata, "last_updated"), "2025-01-23");

      --  Add projects section
      Projects := Add_Child_Element (Doc, Root, "projects");
      Project := Add_Child_Element (Doc, Projects, "project");
      --  Note: SML doesn't support attributes, so we'd need to use child elements for IDs
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "id"), "proj_new");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "name"), "New Tutorial Project");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "description"),
                     "Project created via tutorial");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "status"), "active");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "created"), "2025-01-23");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Project, "owner"), "tutorial_user");

      --  Add tasks section with one task
      Tasks := Add_Child_Element (Doc, Root, "tasks");
      Task_Node := Add_Child_Element (Doc, Tasks, "task");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "id"), "task_new");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "project_id"), "proj_new");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "title"),
                     "Complete SML tutorial");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "description"),
                     "Work through all tutorial lessons");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "priority"), "1");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "status"), "in_progress");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "assigned_to"), "student");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "estimated_hours"), "4.0");
      Add_Text_Node (Doc, Add_Child_Element (Doc, Task_Node, "due_date"), "2025-01-25");

      Put_Line ("Document created successfully!");
      New_Line;

      --  Serialize and display
      Put_Line ("Serialized document (formatted):");
      Put_Line ("--------------------------------");
      declare
         Serialized : constant String := Serialize_Formatted (Doc, 2);
      begin
         Put_Line (Serialized);
      end;

      --  Save to file
      Put_Line ("Saving to file...");
      Write_Res := Write_Document ("tasks_generated.sml", Doc, Formatted => True);

      if Write_Res.Success then
         Put_Line ("Document saved to tasks_generated.sml");
      else
         Put_Line ("Failed to save: " &
                   IO_Status'Image (Write_Res.Status));
      end if;
   end Lesson_3_Building_Documents;

   procedure Lesson_4_Modifying_Documents is
      Parse_Res : Parse_Result;
      Doc : Document;
      Root : Node_Id;
      Tasks_Node : Node_Id;
      Task_Node : Node_Id;
      Status_Node : Node_Id;
      Write_Res : Write_Result;
      Modified_Count : Natural := 0;
   begin
      Print_Header ("Lesson 4: Modifying Existing Documents");

      Put_Line ("Loading task document...");
      Parse_Res := Parse_File ("fixtures/tasks_simple.sml");

      if not Parse_Res.Success then
         Put_Line ("Failed to load document: " & Parse_Res.Error.Message);
         return;
      end if;

      Doc := Parse_Res.Document;
      Put_Line ("Document loaded successfully!");
      New_Line;

      Put_Line ("Before modifications:");
      Count_Tasks_By_Status (Doc);
      New_Line;

      --  Find and modify all "todo" tasks to "in_progress"
      Put_Line ("Updating all 'todo' tasks to 'in_progress'...");

      Root := SML.DOM.Root (Doc);

      --  Find tasks element
      declare
         Child : Node_Id := First_Child (Doc, Root);
      begin
         while Is_Valid_Node (Doc, Child) loop
            if Kind (Doc, Child) = Element and then
               Name (Doc, Child) = "tasks"
            then
               Tasks_Node := Child;
               exit;
            end if;
            Child := Next_Sibling (Doc, Child);
         end loop;
      end;

      if Is_Valid_Node (Doc, Tasks_Node) then
         Task_Node := First_Child (Doc, Tasks_Node);
         while Is_Valid_Node (Doc, Task_Node) loop
            if Kind (Doc, Task_Node) = Element and then
               Name (Doc, Task_Node) = "task"
            then
               --  Find status element
               Status_Node := First_Child (Doc, Task_Node);
               while Is_Valid_Node (Doc, Status_Node) loop
                  if Kind (Doc, Status_Node) = Element and then
                     Name (Doc, Status_Node) = "status"
                  then
                     declare
                        Text_Node : constant Node_Id := First_Child (Doc, Status_Node);
                     begin
                        if Is_Valid_Node (Doc, Text_Node) and then
                           Kind (Doc, Text_Node) = Text
                        then
                           declare
                              Current_Status : constant String := Text_Value (Doc, Text_Node);
                           begin
                              if Current_Status = "todo" then
                                 Set_Text_Content (Doc, Status_Node, "in_progress");
                                 Modified_Count := Modified_Count + 1;
                              end if;
                           end;
                        end if;
                     end;
                     exit;
                  end if;
                  Status_Node := Next_Sibling (Doc, Status_Node);
               end loop;
            end if;
            Task_Node := Next_Sibling (Doc, Task_Node);
         end loop;
      end if;

      Put_Line ("Modified" & Natural'Image (Modified_Count) & " task(s)");
      New_Line;

      Put_Line ("After modifications:");
      Count_Tasks_By_Status (Doc);
      New_Line;

      --  Save modified document
      Put_Line ("Saving modified document...");
      Write_Res := Write_Document ("tasks_modified.sml", Doc, Formatted => True);

      if Write_Res.Success then
         Put_Line ("Modified document saved to tasks_modified.sml");
      else
         Put_Line ("Failed to save: " & IO_Status'Image (Write_Res.Status));
      end if;
   end Lesson_4_Modifying_Documents;

   procedure Lesson_5_Complex_Queries is
      Parse_Res : Parse_Result;
      Doc : Document;
      Root : Node_Id;
      Tasks_Node : Node_Id;
      Task_Node : Node_Id;
      High_Priority_Count : Natural := 0;
      Overdue_Count : Natural := 0;
   begin
      Print_Header ("Lesson 5: Complex Queries and Reports");

      Put_Line ("Loading complex task document...");
      Parse_Res := Parse_File ("fixtures/tasks_complex.sml");

      if not Parse_Res.Success then
         Put_Line ("Failed to load document: " & Parse_Res.Error.Message);
         return;
      end if;

      Doc := Parse_Res.Document;
      Root := SML.DOM.Root (Doc);

      Put_Line ("Analyzing task database...");
      New_Line;

      --  Overall statistics
      Count_Tasks_By_Status (Doc);
      New_Line;

      --  Find high-priority tasks (priority = 1)
      Put_Line ("High Priority Tasks (Priority = 1):");
      Put_Line ("-----------------------------------");

      --  Find tasks element
      declare
         Child : Node_Id := First_Child (Doc, Root);
      begin
         while Is_Valid_Node (Doc, Child) loop
            if Kind (Doc, Child) = Element and then
               Name (Doc, Child) = "tasks"
            then
               Tasks_Node := Child;
               exit;
            end if;
            Child := Next_Sibling (Doc, Child);
         end loop;
      end;

      if Is_Valid_Node (Doc, Tasks_Node) then
         Task_Node := First_Child (Doc, Tasks_Node);
         while Is_Valid_Node (Doc, Task_Node) loop
            if Kind (Doc, Task_Node) = Element and then
               Name (Doc, Task_Node) = "task"
            then
               --  Check priority
               declare
                  Child : Node_Id := First_Child (Doc, Task_Node);
                  Is_High_Priority : Boolean := False;
               begin
                  while Is_Valid_Node (Doc, Child) loop
                     if Kind (Doc, Child) = Element and then
                        Name (Doc, Child) = "priority"
                     then
                        declare
                           Text_Node : constant Node_Id := First_Child (Doc, Child);
                        begin
                           if Is_Valid_Node (Doc, Text_Node) and then
                              Kind (Doc, Text_Node) = Text and then
                              Text_Value (Doc, Text_Node) = "1"
                           then
                              Is_High_Priority := True;
                              High_Priority_Count := High_Priority_Count + 1;
                           end if;
                        end;
                        exit;
                     end if;
                     Child := Next_Sibling (Doc, Child);
                  end loop;

                  if Is_High_Priority then
                     Print_Task (Doc, Task_Node);
                  end if;
               end;
            end if;
            Task_Node := Next_Sibling (Doc, Task_Node);
         end loop;
      end if;

      Put_Line ("Total high-priority tasks:" & Natural'Image (High_Priority_Count));
      New_Line;

      --  Find tasks with dependencies
      Put_Line ("Tasks with Dependencies:");
      Put_Line ("------------------------");

      if Is_Valid_Node (Doc, Tasks_Node) then
         Task_Node := First_Child (Doc, Tasks_Node);
         while Is_Valid_Node (Doc, Task_Node) loop
            if Kind (Doc, Task_Node) = Element and then
               Name (Doc, Task_Node) = "task"
            then
               --  Check for dependencies
               declare
                  Child : Node_Id := First_Child (Doc, Task_Node);
                  Has_Dependencies : Boolean := False;
               begin
                  while Is_Valid_Node (Doc, Child) loop
                     if Kind (Doc, Child) = Element and then
                        Name (Doc, Child) = "dependencies"
                     then
                        Has_Dependencies := True;
                        exit;
                     end if;
                     Child := Next_Sibling (Doc, Child);
                  end loop;

                  if Has_Dependencies then
                     Print_Task (Doc, Task_Node);
                  end if;
               end;
            end if;
            Task_Node := Next_Sibling (Doc, Task_Node);
         end loop;
      end if;
   end Lesson_5_Complex_Queries;

begin
   Put_Line ("====================================================");
   Put_Line ("    SML Task Manager Tutorial");
   Put_Line ("====================================================");
   Put_Line;
   Put_Line ("This tutorial demonstrates building a complete");
   Put_Line ("task management system using the SML library.");
   Put_Line;

   --  Run all lessons
   Lesson_1_Basic_Parsing;
   Lesson_2_Schema_Validation;
   Lesson_3_Building_Documents;
   Lesson_4_Modifying_Documents;
   Lesson_5_Complex_Queries;

   Print_Header ("Tutorial Complete!");
   Put_Line ("You've successfully learned how to:");
   Put_Line ("  - Parse SML documents");
   Put_Line ("  - Validate against schemas");
   Put_Line ("  - Build documents programmatically");
   Put_Line ("  - Modify existing documents");
   Put_Line ("  - Query and analyze data");
   Put_Line;
   Put_Line ("The SML library provides a formally verified foundation");
   Put_Line ("for building reliable XML-based applications in Ada/SPARK.");

exception
   when others =>
      Put_Line ("An unexpected error occurred during the tutorial.");
      Put_Line ("Please check the error messages above.");
end Task_Manager_Tutorial;