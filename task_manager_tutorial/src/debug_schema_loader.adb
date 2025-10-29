--  Debug Schema Loader Test
--  ========================
--  Tests if schema loader correctly parses constraints

with Ada.Text_IO; use Ada.Text_IO;
with SML.DOM; use SML.DOM;
with SML.DOM.Parser; use SML.DOM.Parser;
with SML.Schema; use SML.Schema;
with SML.Schema.Loader; use SML.Schema.Loader;

procedure Debug_Schema_Loader is

   procedure Separator (Title : String) is
   begin
      New_Line;
      Put_Line ("=== " & Title & " ===");
   end Separator;

   --  Helper to display child elements
   procedure Show_Children (Doc : Document; Parent : Node_Id; Indent : String := "  ") is
      Child : Node_Id := First_Child (Doc, Parent);
   begin
      while Child /= Null_Node loop
         if Kind (Doc, Child) = Element then
            Put_Line (Indent & Name (Doc, Child));

            --  Check for text content
            declare
               Text_Child : constant Node_Id := First_Child (Doc, Child);
            begin
               if Text_Child /= Null_Node and then Kind (Doc, Text_Child) = Text then
                  Put_Line (Indent & "  = " & Text_Value (Doc, Text_Child));
               end if;
            end;

            --  Recurse for nested elements
            Show_Children (Doc, Child, Indent & "  ");
         end if;
         Child := Next_Sibling (Doc, Child);
      end loop;
   end Show_Children;

begin
   Put_Line ("SCHEMA LOADER DEBUG TEST");
   Put_Line ("========================");

   Separator ("Test 1: Parse schema with integer constraints");

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

      Schema_Parse_Result : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse_Result.Success then
         Put_Line ("Failed to parse schema");
         return;
      end if;

      Put_Line ("Schema structure after parsing:");
      Show_Children (Schema_Parse_Result.Doc, Root (Schema_Parse_Result.Doc));

      declare
         Schema_Load : constant Schema_Load_Result := Load_Schema (Schema_Parse_Result.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("Failed to load schema: " & To_String (Schema_Load.Error_Message));
         else
            Put_Line ("Schema loaded successfully!");

            --  Test if validation works with this schema
            declare
               Valid_Doc : constant Parse_Result := Parse ("<score>50</score>");
               Invalid_Doc : constant Parse_Result := Parse ("<score>200</score>");

               Valid_Result : constant Validation_Result :=
                  Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
               Invalid_Result : constant Validation_Result :=
                  Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
            begin
               Put ("Testing value 50 (should pass): ");
               case Valid_Result.Status is
                  when Valid => Put_Line ("VALID");
                  when Invalid =>
                     Put_Line ("INVALID - " &
                        To_String (Valid_Result.Error_Message));
               end case;

               Put ("Testing value 200 (should fail): ");
               case Invalid_Result.Status is
                  when Valid => Put_Line ("VALID [WRONG!]");
                  when Invalid =>
                     Put_Line ("INVALID - " &
                        To_String (Invalid_Result.Error_Message));
               end case;
            end;
         end if;
      end;
   end;

   Separator ("Test 2: Parse schema with enumeration");

   declare
      Schema_Text : constant String :=
         "<schema>" &
         "  <simpleType>" &
         "    <name>colorType</name>" &
         "    <restriction>" &
         "      <base>string</base>" &
         "      <enumeration>" &
         "        <value>red</value>" &
         "        <value>green</value>" &
         "        <value>blue</value>" &
         "      </enumeration>" &
         "    </restriction>" &
         "  </simpleType>" &
         "  <element>" &
         "    <name>color</name>" &
         "    <type>colorType</type>" &
         "  </element>" &
         "</schema>";

      Schema_Parse_Result : constant Parse_Result := Parse (Schema_Text);
   begin
      if not Schema_Parse_Result.Success then
         Put_Line ("Failed to parse schema");
         return;
      end if;

      Put_Line ("Schema structure after parsing:");
      Show_Children (Schema_Parse_Result.Doc, Root (Schema_Parse_Result.Doc));

      declare
         Schema_Load : constant Schema_Load_Result := Load_Schema (Schema_Parse_Result.Doc);
      begin
         if not Schema_Load.Success then
            Put_Line ("Failed to load schema: " & To_String (Schema_Load.Error_Message));
         else
            Put_Line ("Schema loaded successfully!");

            --  Test if validation works with this schema
            declare
               Valid_Doc : constant Parse_Result := Parse ("<color>blue</color>");
               Invalid_Doc : constant Parse_Result := Parse ("<color>yellow</color>");

               Valid_Result : constant Validation_Result :=
                  Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
               Invalid_Result : constant Validation_Result :=
                  Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
            begin
               Put ("Testing 'blue' (should pass): ");
               case Valid_Result.Status is
                  when Valid => Put_Line ("VALID");
                  when Invalid =>
                     Put_Line ("INVALID - " &
                        To_String (Valid_Result.Error_Message));
               end case;

               Put ("Testing 'yellow' (should fail): ");
               case Invalid_Result.Status is
                  when Valid => Put_Line ("VALID [WRONG!]");
                  when Invalid =>
                     Put_Line ("INVALID - " &
                        To_String (Invalid_Result.Error_Message));
               end case;
            end;
         end if;
      end;
   end;

   Separator ("CONCLUSION");

   Put_Line ("If the schema loader parses the structure correctly but");
   Put_Line ("validation still passes invalid values, then the issue");
   Put_Line ("is in the Validate_Document function, not the loader.");
   Put_Line ("");
   Put_Line ("The schema loader appears to be reading the constraints");
   Put_Line ("(minValue, maxValue, enumeration) from the schema files,");
   Put_Line ("but the Validate_Document function is not enforcing them.");

end Debug_Schema_Loader;