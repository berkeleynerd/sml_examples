--  Lesson 3: Building Documents Programmatically (Improved)
--  ==========================================================
--  This lesson demonstrates how to build structured documents
--  from scratch using the SML.DOM.Builder API

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Builder; use SML.DOM.Builder;
with SML.DOM.Writer; use SML.DOM.Writer;
with SML.IO; use SML.IO;

procedure Lesson_3_Building is

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

   --  Build a simple configuration document
   procedure Build_Config_Document is
      Doc : Document := Create_Document ("configuration");
      Root : constant Node_Id := SML.DOM.Root (Doc);
      Database_Node, Server_Node, Temp_Node : Node_Id;
   begin
      Put_Line ("Building a configuration document...");

      --  Add database configuration
      Add_Child_Element (Doc, Root, "database", Database_Node);

      Add_Child_Element (Doc, Database_Node, "host", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "localhost", Temp_Node);

      Add_Child_Element (Doc, Database_Node, "port", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "5432", Temp_Node);

      Add_Child_Element (Doc, Database_Node, "name", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "task_db", Temp_Node);

      --  Add server configuration
      Add_Child_Element (Doc, Root, "server", Server_Node);

      Add_Child_Element (Doc, Server_Node, "port", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "8080", Temp_Node);

      Add_Child_Element (Doc, Server_Node, "threads", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "4", Temp_Node);

      --  Serialize and display
      declare
         Serialized : constant String := Serialize_Formatted (Doc, 2);
      begin
         Put_Line ("Generated configuration:");
         Put_Line (Serialized);
      end;

      --  Save to file
      declare
         Result : constant Write_Result :=
            Write_Document ("config.sml", Doc, Formatted => True);
      begin
         if Result.Status = Success then
            Put_Line ("[OK] Configuration saved to config.sml");
         else
            Put_Line ("[FAIL] Could not save configuration");
         end if;
      end;
   end Build_Config_Document;

   --  Build a complete task database document
   procedure Build_Task_Database is
      Doc : Document := Create_Document ("task_database");
      Root : constant Node_Id := SML.DOM.Root (Doc);

      --  Node references we'll need
      Metadata_Node, Version_Node, Updated_Node : Node_Id;
      Projects_Node, Project_Node : Node_Id;
      Tasks_Node, Task_Node : Node_Id;
      Temp_Node : Node_Id;  --  Reusable for text nodes
   begin
      Put_Line ("Building a complete task database...");

      --  Build metadata section
      Add_Child_Element (Doc, Root, "metadata", Metadata_Node);

      Add_Child_Element (Doc, Metadata_Node, "version", Version_Node);
      Add_Text_Node (Doc, Version_Node, "1.0", Temp_Node);

      Add_Child_Element (Doc, Metadata_Node, "last_updated", Updated_Node);
      Add_Text_Node (Doc, Updated_Node, "2025-01-23", Temp_Node);

      --  Build projects section
      Add_Child_Element (Doc, Root, "projects", Projects_Node);

      --  Add first project
      Add_Child_Element (Doc, Projects_Node, "project", Project_Node);

      Add_Child_Element (Doc, Project_Node, "id", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "proj_001", Temp_Node);

      Add_Child_Element (Doc, Project_Node, "name", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "SML Tutorial", Temp_Node);

      Add_Child_Element (Doc, Project_Node, "description", Temp_Node);
      Add_Text_Node (Doc, Temp_Node,
         "Learn to use the SML library", Temp_Node);

      Add_Child_Element (Doc, Project_Node, "status", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "active", Temp_Node);

      Add_Child_Element (Doc, Project_Node, "created", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "2025-01-20", Temp_Node);

      Add_Child_Element (Doc, Project_Node, "owner", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "student", Temp_Node);

      --  Build tasks section
      Add_Child_Element (Doc, Root, "tasks", Tasks_Node);

      --  Add first task
      Add_Child_Element (Doc, Tasks_Node, "task", Task_Node);

      Add_Child_Element (Doc, Task_Node, "id", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "task_001", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "project_id", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "proj_001", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "title", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "Complete Lesson 3", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "description", Temp_Node);
      Add_Text_Node (Doc, Temp_Node,
         "Learn to build documents programmatically", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "priority", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "1", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "status", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "in_progress", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "assigned_to", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "student", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "estimated_hours", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "2.0", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "due_date", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "2025-01-25", Temp_Node);

      --  Add second task
      Add_Child_Element (Doc, Tasks_Node, "task", Task_Node);

      Add_Child_Element (Doc, Task_Node, "id", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "task_002", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "project_id", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "proj_001", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "title", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "Review Lesson 4", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "priority", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "2", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "status", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "todo", Temp_Node);

      Add_Child_Element (Doc, Task_Node, "due_date", Temp_Node);
      Add_Text_Node (Doc, Temp_Node, "2025-01-26", Temp_Node);

      --  Display statistics
      Put_Line ("Document structure built:");
      Put_Line ("  - 1 metadata section");
      Put_Line ("  - 1 project");
      Put_Line ("  - 2 tasks");
      New_Line;

      --  Serialize and save
      declare
         Result : constant Write_Result :=
            Write_Document ("tasks_built.sml", Doc, Formatted => True);
      begin
         if Result.Status = Success then
            Put_Line ("[OK] Task database saved to tasks_built.sml");
            Put_Line ("     Size: " & Natural'Image (Result.Bytes_Written) &
                      " bytes");
         else
            Put_Line ("[FAIL] Could not save task database");
         end if;
      end;
   end Build_Task_Database;

   --  Build a document with nested structures
   procedure Build_Nested_Document is
      Doc : Document := Create_Document ("report");
      Root : constant Node_Id := SML.DOM.Root (Doc);
      Section_Node, Subsection_Node, Item_Node, Temp : Node_Id;
   begin
      Put_Line ("Building a document with nested structure...");

      --  Create nested sections
      Add_Child_Element (Doc, Root, "section", Section_Node);

      Add_Child_Element (Doc, Section_Node, "title", Temp);
      Add_Text_Node (Doc, Temp, "Main Section", Temp);

      Add_Child_Element (Doc, Section_Node, "subsection", Subsection_Node);

      Add_Child_Element (Doc, Subsection_Node, "title", Temp);
      Add_Text_Node (Doc, Temp, "Subsection A", Temp);

      Add_Child_Element (Doc, Subsection_Node, "content", Temp);
      Add_Text_Node (Doc, Temp, "This demonstrates nesting", Temp);

      --  Add a list structure
      Add_Child_Element (Doc, Section_Node, "list", Item_Node);

      Add_Child_Element (Doc, Item_Node, "item", Temp);
      Add_Text_Node (Doc, Temp, "First item", Temp);

      Add_Child_Element (Doc, Item_Node, "item", Temp);
      Add_Text_Node (Doc, Temp, "Second item", Temp);

      Add_Child_Element (Doc, Item_Node, "item", Temp);
      Add_Text_Node (Doc, Temp, "Third item", Temp);

      --  Display the nested structure
      declare
         Serialized : constant String := Serialize_Formatted (Doc, 2);
      begin
         Put_Line ("Generated nested structure:");
         Put_Line (Serialized);
      end;
   end Build_Nested_Document;

begin
   Print_Header ("Lesson 3: Building Documents Programmatically");

   Put_Line ("This lesson demonstrates how to:");
   Put_Line ("  1. Create new documents from scratch");
   Put_Line ("  2. Add elements and text content");
   Put_Line ("  3. Build hierarchical structures");
   Put_Line ("  4. Serialize and save documents");
   New_Line;

   Put_Line ("Key API patterns:");
   Put_Line ("  * Add_Child_Element uses OUT parameter for new node");
   Put_Line ("  * Add_Text_Node also uses OUT parameter");
   Put_Line ("  * Reuse a Temp_Node variable for efficiency");
   Put_Line ("  * Build structure top-down");
   New_Line;

   --  Example 1: Simple Configuration
   Print_Header ("Example 1: Configuration Document");
   Build_Config_Document;

   --  Example 2: Complete Task Database
   Print_Header ("Example 2: Task Database");
   Build_Task_Database;

   --  Example 3: Nested Structures
   Print_Header ("Example 3: Nested Structures");
   Build_Nested_Document;

   --  Summary
   Print_Header ("Building Documents Summary");
   Put_Line ("Key takeaways:");
   Put_Line ("  * Create_Document starts with root element");
   Put_Line ("  * Build structure using Add_Child_Element");
   Put_Line ("  * Add content using Add_Text_Node");
   Put_Line ("  * Both use OUT parameters (not return values)");
   Put_Line ("  * Serialize_Formatted for pretty output");
   Put_Line ("  * Write_Document to save to file");
   New_Line;
   Put_Line ("This approach ensures memory safety and allows");
   Put_Line ("formal verification of document construction.");

exception
   when others =>
      Put_Line ("Unexpected error in building lesson");
end Lesson_3_Building;