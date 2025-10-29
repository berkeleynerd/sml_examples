--  Lesson 4: Document Transformation (Replacement)
--  ================================================
--  Since we cannot modify parsed documents in place due to limited types,
--  this lesson teaches the transformation pattern: parse, extract, rebuild.

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.DOM.Builder; use SML.DOM.Builder;
with SML.DOM.Writer; use SML.DOM.Writer;
with SML.IO; use SML.IO;

procedure Lesson_4_Transformation is

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

   --  Transform tasks to a summary report document
   procedure Create_Summary_Report is
      Task_Count : Natural := 0;
      Done_Count : Natural := 0;
   begin
      Put_Line ("Creating task summary report...");

      --  Step 1: Parse the source document
      declare
         Source : constant Parse_Result :=
            Parse_File ("fixtures/tasks_simple_sml.sml");
      begin
         if not Source.Success then
            Put_Line ("Failed to parse source: " &
               Source.Error.Message (1 .. Source.Error.Msg_Length));
            return;
         end if;

         --  Step 2: Analyze the source (read-only traversal)
         declare
            Root : constant Node_Id := SML.DOM.Root (Source.Doc);
            Tasks_Node, Task_Node, Status_Node : Node_Id;
            Child : Node_Id;
         begin
            --  Find tasks element
            Child := First_Child (Source.Doc, Root);
            while Child /= Null_Node loop
               if Kind (Source.Doc, Child) = Element and then
                  Name (Source.Doc, Child) = "tasks"
               then
                  Tasks_Node := Child;
                  exit;
               end if;
               Child := Next_Sibling (Source.Doc, Child);
            end loop;

            --  Count tasks and statuses
            if Tasks_Node /= Null_Node then
               Task_Node := First_Child (Source.Doc, Tasks_Node);
               while Task_Node /= Null_Node loop
                  if Kind (Source.Doc, Task_Node) = Element and then
                     Name (Source.Doc, Task_Node) = "task"
                  then
                     Task_Count := Task_Count + 1;

                     --  Check if done
                     Status_Node := First_Child (Source.Doc, Task_Node);
                     while Status_Node /= Null_Node loop
                        if Kind (Source.Doc, Status_Node) = Element and then
                           Name (Source.Doc, Status_Node) = "status"
                        then
                           declare
                              Text_Node : constant Node_Id :=
                                 First_Child (Source.Doc, Status_Node);
                           begin
                              if Text_Node /= Null_Node and then
                                 Kind (Source.Doc, Text_Node) = Text and then
                                 Text_Value (Source.Doc, Text_Node) = "done"
                              then
                                 Done_Count := Done_Count + 1;
                              end if;
                           end;
                           exit;
                        end if;
                        Status_Node := Next_Sibling (Source.Doc, Status_Node);
                     end loop;
                  end if;
                  Task_Node := Next_Sibling (Source.Doc, Task_Node);
               end loop;
            end if;
         end;

         --  Step 3: Build new summary document
         declare
            Report : Document := Create_Document ("task_summary");
            Root : constant Node_Id := SML.DOM.Root (Report);
            Stats_Node, Count_Node, Done_Node, Pending_Node : Node_Id;
            Text_Node : Node_Id;
         begin
            --  Add statistics section
            Add_Child_Element (Report, Root, "statistics", Stats_Node);

            --  Total tasks
            Add_Child_Element (Report, Stats_Node, "total_tasks", Count_Node);
            Add_Text_Node (Report, Count_Node,
               Natural'Image (Task_Count), Text_Node);

            --  Completed tasks
            Add_Child_Element (Report, Stats_Node, "completed_tasks", Done_Node);
            Add_Text_Node (Report, Done_Node,
               Natural'Image (Done_Count), Text_Node);

            --  Pending tasks
            Add_Child_Element (Report, Stats_Node, "pending_tasks", Pending_Node);
            Add_Text_Node (Report, Pending_Node,
               Natural'Image (Task_Count - Done_Count), Text_Node);

            --  Step 4: Save the transformed document
            declare
               Write_Res : constant Write_Result :=
                  Write_Document ("task_summary.sml", Report, Formatted => True);
            begin
               if Write_Res.Status = Success then
                  Put_Line ("[OK] Summary report saved to task_summary.sml");
                  Put_Line ("  Total tasks: " & Natural'Image (Task_Count));
                  Put_Line ("  Completed: " & Natural'Image (Done_Count));
                  Put_Line ("  Pending: " & Natural'Image (Task_Count - Done_Count));
               else
                  Put_Line ("Failed to save report");
               end if;
            end;
         end;
      end;
   end Create_Summary_Report;

   --  Filter and transform tasks to create an active tasks document
   procedure Create_Active_Tasks_Document is
      Active_Count : Natural := 0;
   begin
      Put_Line ("Creating active tasks document...");

      --  Parse source
      declare
         Source : constant Parse_Result :=
            Parse_File ("fixtures/tasks_simple_sml.sml");
      begin
         if not Source.Success then
            Put_Line ("Failed to parse source");
            return;
         end if;

         --  Build filtered document
         declare
            Filtered : Document := Create_Document ("active_tasks");
            Root : constant Node_Id := SML.DOM.Root (Filtered);
            Tasks_Node, New_Task : Node_Id;
            Unused : Node_Id;
         begin
            Add_Child_Element (Filtered, Root, "tasks", Tasks_Node);

            --  Traverse source and copy only active tasks
            declare
               Source_Root : constant Node_Id := SML.DOM.Root (Source.Doc);
               Source_Tasks, Task_Node : Node_Id;
               Child : Node_Id;
            begin
               --  Find source tasks
               Child := First_Child (Source.Doc, Source_Root);
               while Child /= Null_Node loop
                  if Kind (Source.Doc, Child) = Element and then
                     Name (Source.Doc, Child) = "tasks"
                  then
                     Source_Tasks := Child;
                     exit;
                  end if;
                  Child := Next_Sibling (Source.Doc, Child);
               end loop;

               --  Filter tasks
               if Source_Tasks /= Null_Node then
                  Task_Node := First_Child (Source.Doc, Source_Tasks);
                  while Task_Node /= Null_Node loop
                     if Kind (Source.Doc, Task_Node) = Element and then
                        Name (Source.Doc, Task_Node) = "task"
                     then
                        --  Check status
                        declare
                           Status_Node : Node_Id :=
                              First_Child (Source.Doc, Task_Node);
                           Is_Active : Boolean := False;
                        begin
                           while Status_Node /= Null_Node loop
                              if Kind (Source.Doc, Status_Node) = Element and then
                                 Name (Source.Doc, Status_Node) = "status"
                              then
                                 declare
                                    Text : constant Node_Id :=
                                       First_Child (Source.Doc, Status_Node);
                                    Status_Text : String (1 .. 20);
                                    Len : Natural := 0;
                                 begin
                                    if Text /= Null_Node and then
                                       Kind (Source.Doc, Text) = SML.DOM.Text
                                    then
                                       declare
                                          Val : constant String :=
                                             Text_Value (Source.Doc, Text);
                                       begin
                                          if Val = "todo" or else
                                             Val = "in_progress"
                                          then
                                             Is_Active := True;
                                          end if;
                                       end;
                                    end if;
                                 end;
                                 exit;
                              end if;
                              Status_Node := Next_Sibling (Source.Doc, Status_Node);
                           end loop;

                           if Is_Active then
                              Active_Count := Active_Count + 1;
                              --  Copy task structure (simplified)
                              Add_Child_Element (Filtered, Tasks_Node,
                                 "task", New_Task);
                              Add_Text_Node (Filtered, New_Task,
                                 "Active task " & Natural'Image (Active_Count),
                                 Unused);
                           end if;
                        end;
                     end if;
                     Task_Node := Next_Sibling (Source.Doc, Task_Node);
                  end loop;
               end if;
            end;

            --  Save filtered document
            declare
               Write_Res : constant Write_Result :=
                  Write_Document ("active_tasks.sml", Filtered, Formatted => True);
            begin
               if Write_Res.Status = Success then
                  Put_Line ("[OK] Filtered document saved");
                  Put_Line ("  Active tasks: " & Natural'Image (Active_Count));
               else
                  Put_Line ("Failed to save filtered document");
               end if;
            end;
         end;
      end;
   end Create_Active_Tasks_Document;

begin
   Print_Header ("Lesson 4: Document Transformation");

   Put_Line ("This lesson demonstrates the transformation pattern:");
   Put_Line ("  1. Parse source document (read-only)");
   Put_Line ("  2. Analyze/traverse to extract data");
   Put_Line ("  3. Build new transformed document");
   Put_Line ("  4. Save the result");
   New_Line;

   Put_Line ("This pattern works WITH the limited type system,");
   Put_Line ("not against it. We never try to modify parsed documents.");
   New_Line;

   --  Example 1: Summary Report
   Print_Header ("Example 1: Summary Report Generation");
   Create_Summary_Report;

   --  Example 2: Filtered Document
   Print_Header ("Example 2: Active Tasks Filter");
   Create_Active_Tasks_Document;

   --  Summary
   Print_Header ("Transformation Pattern Summary");
   Put_Line ("Key takeaways:");
   Put_Line ("  * Never modify parsed documents (they're limited/immutable)");
   Put_Line ("  * Use read-only traversal to extract data");
   Put_Line ("  * Build fresh documents for output");
   Put_Line ("  * This pattern is safer and more functional");
   Put_Line ("  * Works perfectly with formal verification");

exception
   when others =>
      Put_Line ("Unexpected error in transformation lesson");
end Lesson_4_Transformation;