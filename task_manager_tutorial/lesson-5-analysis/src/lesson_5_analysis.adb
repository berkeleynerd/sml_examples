--  Lesson 5: Document Analysis and Queries
--  ========================================
--  This lesson demonstrates how to analyze and query SML documents
--  using read-only traversal patterns that work with limited types

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.DOM.Builder; use SML.DOM.Builder;
with SML.IO; use SML.IO;

procedure Lesson_5_Analysis is

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

   --  Analysis record to collect statistics
   type Task_Stats is record
      Total_Count : Natural := 0;
      Todo_Count : Natural := 0;
      In_Progress_Count : Natural := 0;
      Done_Count : Natural := 0;
      High_Priority_Count : Natural := 0;
      Overdue_Count : Natural := 0;
   end record;

   --  Analyze a task node and update statistics
   procedure Analyze_Task (Doc : Document; Task_Node : Node_Id;
                           Stats : in out Task_Stats) is
      Child : Node_Id;
   begin
      if Kind (Doc, Task_Node) = Element and then
         Name (Doc, Task_Node) = "task"
      then
         Stats.Total_Count := Stats.Total_Count + 1;

         --  Analyze status
         Child := First_Child (Doc, Task_Node);
         while Child /= Null_Node loop
            if Kind (Doc, Child) = Element then
               if Name (Doc, Child) = "status" then
                  declare
                     Text_Node : constant Node_Id := First_Child (Doc, Child);
                     Status : String (1 .. 20);
                     Len : Natural := 0;
                  begin
                     if Text_Node /= Null_Node and then
                        Kind (Doc, Text_Node) = Text
                     then
                        declare
                           Full_Text : constant String :=
                              Text_Value (Doc, Text_Node);
                        begin
                           Len := Natural'Min (Full_Text'Length, Status'Length);
                           Status (1 .. Len) :=
                              Full_Text (Full_Text'First ..
                                        Full_Text'First + Len - 1);

                           if Len >= 4 and then Status (1 .. 4) = "todo" then
                              Stats.Todo_Count := Stats.Todo_Count + 1;
                           elsif Len >= 11 and then
                                 Status (1 .. 11) = "in_progress" then
                              Stats.In_Progress_Count :=
                                 Stats.In_Progress_Count + 1;
                           elsif Len >= 4 and then Status (1 .. 4) = "done" then
                              Stats.Done_Count := Stats.Done_Count + 1;
                           end if;
                        end;
                     end if;
                  end;
               elsif Name (Doc, Child) = "priority" then
                  declare
                     Text_Node : constant Node_Id := First_Child (Doc, Child);
                  begin
                     if Text_Node /= Null_Node and then
                        Kind (Doc, Text_Node) = Text
                     then
                        declare
                           Priority_Text : constant String :=
                              Text_Value (Doc, Text_Node);
                        begin
                           if Priority_Text'Length > 0 and then
                              Priority_Text (Priority_Text'First) = '1'
                           then
                              Stats.High_Priority_Count :=
                                 Stats.High_Priority_Count + 1;
                           end if;
                        end;
                     end if;
                  end;
               end if;
            end if;
            Child := Next_Sibling (Doc, Child);
         end loop;
      end if;
   end Analyze_Task;

   --  Find tasks matching specific criteria
   procedure Find_Tasks_By_Status (Doc : Document; Status_Filter : String) is
      Tasks_Node, Task_Node, Child_Node, Text_Node : Node_Id;
      Found_Count : Natural := 0;
   begin
      Put_Line ("Finding tasks with status: " & Status_Filter);
      Put_Line ("----------------------------------------");

      --  Find tasks element
      declare
         Root : constant Node_Id := SML.DOM.Root (Doc);
         Node : Node_Id := First_Child (Doc, Root);
      begin
         while Node /= Null_Node loop
            if Kind (Doc, Node) = Element and then
               Name (Doc, Node) = "tasks"
            then
               Tasks_Node := Node;
               exit;
            end if;
            Node := Next_Sibling (Doc, Node);
         end loop;
      end;

      if Tasks_Node = Null_Node then
         Put_Line ("No tasks element found");
         return;
      end if;

      --  Iterate through tasks
      Task_Node := First_Child (Doc, Tasks_Node);
      while Task_Node /= Null_Node loop
         if Kind (Doc, Task_Node) = Element and then
            Name (Doc, Task_Node) = "task"
         then
            --  Check status
            Child_Node := First_Child (Doc, Task_Node);
            while Child_Node /= Null_Node loop
               if Kind (Doc, Child_Node) = Element and then
                  Name (Doc, Child_Node) = "status"
               then
                  Text_Node := First_Child (Doc, Child_Node);
                  if Text_Node /= Null_Node and then
                     Kind (Doc, Text_Node) = Text
                  then
                     declare
                        Status : constant String :=
                           Text_Value (Doc, Text_Node);
                     begin
                        if Status = Status_Filter then
                           Found_Count := Found_Count + 1;
                           --  Print task title
                           declare
                              Title_Node : Node_Id :=
                                 First_Child (Doc, Task_Node);
                           begin
                              while Title_Node /= Null_Node loop
                                 if Kind (Doc, Title_Node) = Element and then
                                    Name (Doc, Title_Node) = "title"
                                 then
                                    Text_Node := First_Child (Doc, Title_Node);
                                    if Text_Node /= Null_Node and then
                                       Kind (Doc, Text_Node) = Text
                                    then
                                       Put_Line ("  - " &
                                          Text_Value (Doc, Text_Node));
                                    end if;
                                    exit;
                                 end if;
                                 Title_Node := Next_Sibling (Doc, Title_Node);
                              end loop;
                           end;
                        end if;
                     end;
                  end if;
               end if;
               Child_Node := Next_Sibling (Doc, Child_Node);
            end loop;
         end if;
         Task_Node := Next_Sibling (Doc, Task_Node);
      end loop;

      Put_Line ("Found" & Natural'Image (Found_Count) & " task(s)");
   end Find_Tasks_By_Status;

   --  Generate analysis report as new document
   procedure Generate_Analysis_Report (Stats : Task_Stats) is
      Report : Document := Create_Document ("analysis_report");
      Root : constant Node_Id := SML.DOM.Root (Report);
      Summary_Node, Stat_Node, Breakdown_Node, Temp : Node_Id;
   begin
      --  Add summary section
      Add_Child_Element (Report, Root, "summary", Summary_Node);

      Add_Child_Element (Report, Summary_Node, "total_tasks", Stat_Node);
      Add_Text_Node (Report, Stat_Node,
                     Natural'Image (Stats.Total_Count), Temp);

      Add_Child_Element (Report, Summary_Node,
                        "high_priority_tasks", Stat_Node);
      Add_Text_Node (Report, Stat_Node,
                     Natural'Image (Stats.High_Priority_Count), Temp);

      --  Add status breakdown
      Add_Child_Element (Report, Root, "status_breakdown", Breakdown_Node);

      Add_Child_Element (Report, Breakdown_Node, "todo", Stat_Node);
      Add_Text_Node (Report, Stat_Node,
                     Natural'Image (Stats.Todo_Count), Temp);

      Add_Child_Element (Report, Breakdown_Node, "in_progress", Stat_Node);
      Add_Text_Node (Report, Stat_Node,
                     Natural'Image (Stats.In_Progress_Count), Temp);

      Add_Child_Element (Report, Breakdown_Node, "done", Stat_Node);
      Add_Text_Node (Report, Stat_Node,
                     Natural'Image (Stats.Done_Count), Temp);

      --  Save report
      declare
         Result : constant Write_Result :=
            Write_Document ("analysis_report.sml", Report, Formatted => True);
      begin
         if Result.Status = Success then
            Put_Line ("[OK] Analysis report saved to analysis_report.sml");
         else
            Put_Line ("[FAIL] Could not save report");
         end if;
      end;
   end Generate_Analysis_Report;

begin
   Print_Header ("Lesson 5: Document Analysis and Queries");

   Put_Line ("This lesson demonstrates how to:");
   Put_Line ("  1. Traverse documents to collect statistics");
   Put_Line ("  2. Find elements matching specific criteria");
   Put_Line ("  3. Generate analysis reports");
   Put_Line ("  4. Work with read-only document queries");
   New_Line;

   Put_Line ("Key patterns:");
   Put_Line ("  * Documents are read-only after parsing");
   Put_Line ("  * Use traversal to collect information");
   Put_Line ("  * Build new documents for reports");
   Put_Line ("  * Never modify parsed documents");
   New_Line;

   --  Example 1: Collect Statistics
   Print_Header ("Example 1: Collecting Task Statistics");

   declare
      Doc_Parse : constant Parse_Result :=
         Parse_File ("fixtures/tasks_simple_sml.sml");
      Stats : Task_Stats;
   begin
      if not Doc_Parse.Success then
         Put_Line ("Failed to parse tasks file");
         return;
      end if;

      Put_Line ("Analyzing task database...");

      --  Traverse and analyze all tasks
      declare
         Root : constant Node_Id := SML.DOM.Root (Doc_Parse.Doc);
         Tasks_Node : Node_Id := First_Child (Doc_Parse.Doc, Root);
      begin
         while Tasks_Node /= Null_Node loop
            if Kind (Doc_Parse.Doc, Tasks_Node) = Element and then
               Name (Doc_Parse.Doc, Tasks_Node) = "tasks"
            then
               --  Found tasks element, analyze children
               declare
                  Task_Node : Node_Id :=
                     First_Child (Doc_Parse.Doc, Tasks_Node);
               begin
                  while Task_Node /= Null_Node loop
                     Analyze_Task (Doc_Parse.Doc, Task_Node, Stats);
                     Task_Node := Next_Sibling (Doc_Parse.Doc, Task_Node);
                  end loop;
               end;
            end if;
            Tasks_Node := Next_Sibling (Doc_Parse.Doc, Tasks_Node);
         end loop;
      end;

      --  Display statistics
      Put_Line ("Analysis Results:");
      Put_Line ("  Total Tasks:      " &
                Natural'Image (Stats.Total_Count));
      Put_Line ("  Todo:            " &
                Natural'Image (Stats.Todo_Count));
      Put_Line ("  In Progress:     " &
                Natural'Image (Stats.In_Progress_Count));
      Put_Line ("  Done:            " &
                Natural'Image (Stats.Done_Count));
      Put_Line ("  High Priority:   " &
                Natural'Image (Stats.High_Priority_Count));
      New_Line;

      --  Example 2: Find specific tasks
      Print_Header ("Example 2: Finding Tasks by Status");
      Find_Tasks_By_Status (Doc_Parse.Doc, "todo");
      New_Line;
      Find_Tasks_By_Status (Doc_Parse.Doc, "done");

      --  Example 3: Generate report document
      Print_Header ("Example 3: Generating Analysis Report");
      Put_Line ("Creating analysis report document...");
      Generate_Analysis_Report (Stats);
   end;

   --  Summary
   Print_Header ("Document Analysis Summary");
   Put_Line ("Key takeaways:");
   Put_Line ("  * Parse documents are immutable (limited types)");
   Put_Line ("  * Traverse using First_Child/Next_Sibling pattern");
   Put_Line ("  * Collect data into records or variables");
   Put_Line ("  * Generate new documents for output");
   Put_Line ("  * This pattern ensures memory safety");
   New_Line;
   Put_Line ("The read-only traversal pattern is:");
   Put_Line ("  1. Parse source document");
   Put_Line ("  2. Traverse nodes collecting data");
   Put_Line ("  3. Analyze collected information");
   Put_Line ("  4. Build new documents for results");

exception
   when others =>
      Put_Line ("Unexpected error in analysis lesson");
end Lesson_5_Analysis;