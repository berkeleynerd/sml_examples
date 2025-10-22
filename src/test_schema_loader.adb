-- copied from examples/test_schema_loader.adb
------------------------------------------------------------------------------
with Ada.Text_IO;
with SML.DOM;
with SML.DOM.Parser;
with SML.Schema;
with SML.Schema.Loader;
with SML.IO;

procedure Test_Schema_Loader is
   use Ada.Text_IO;
   use SML.Schema;
   use SML.Schema.Loader;

   procedure Test_Integer_Simple_Type;
   procedure Test_String_Enum_Type;
   procedure Test_Complex_Sequence_Type;
   procedure Test_Complex_Choice_Type;
   procedure Test_Element_Definition;
   procedure Test_Full_Schema;
   procedure Test_Missing_Name_Error;
   procedure Test_Unknown_Base_Type_Error;
   procedure Test_File_Based_Validation;

   procedure Test_Integer_Simple_Type is
      Schema_SML : constant String :=
        "<schema>" &
        "  <simpleType>" &
        "    <name>portType</name>" &
        "    <restriction>" &
        "      <base>integer</base>" &
        "      <minValue>1</minValue>" &
        "      <maxValue>65535</maxValue>" &
        "    </restriction>" &
        "  </simpleType>" &
        "</schema>";
   begin
      Put ("Test: Integer Simple Type... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Integer_Simple_Type;

   procedure Test_String_Enum_Type is
      Schema_SML : constant String :=
        "<schema>" &
        "  <simpleType>" &
        "    <name>logLevel</name>" &
        "    <restriction>" &
        "      <base>string</base>" &
        "      <enumeration>" &
        "        <value>DEBUG</value>" &
        "        <value>INFO</value>" &
        "        <value>WARNING</value>" &
        "        <value>ERROR</value>" &
        "      </enumeration>" &
        "    </restriction>" &
        "  </simpleType>" &
        "</schema>";
   begin
      Put ("Test: String Enumeration Type... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_String_Enum_Type;

   procedure Test_Complex_Sequence_Type is
      Schema_SML : constant String :=
        "<schema>" &
        "  <complexType>" &
        "    <name>databaseType</name>" &
        "    <sequence>" &
        "      <element>" &
        "        <name>host</name>" &
        "        <minOccurs>1</minOccurs>" &
        "        <maxOccurs>1</maxOccurs>" &
        "      </element>" &
        "      <element>" &
        "        <name>port</name>" &
        "        <minOccurs>1</minOccurs>" &
        "        <maxOccurs>1</maxOccurs>" &
        "      </element>" &
        "    </sequence>" &
        "  </complexType>" &
        "</schema>";
   begin
      Put ("Test: Complex Sequence Type... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Complex_Sequence_Type;

   procedure Test_Complex_Choice_Type is
      Schema_SML : constant String :=
        "<schema>" &
        "  <complexType>" &
        "    <name>contactType</name>" &
        "    <choice>" &
        "      <element>" &
        "        <name>email</name>" &
        "        <minOccurs>1</minOccurs>" &
        "        <maxOccurs>1</maxOccurs>" &
        "      </element>" &
        "      <element>" &
        "        <name>phone</name>" &
        "        <minOccurs>1</minOccurs>" &
        "        <maxOccurs>1</maxOccurs>" &
        "      </element>" &
        "    </choice>" &
        "  </complexType>" &
        "</schema>";
   begin
      Put ("Test: Complex Choice Type... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Complex_Choice_Type;

   procedure Test_Element_Definition is
      Schema_SML : constant String :=
        "<schema>" &
        "  <element>" &
        "    <name>config</name>" &
        "    <type>configType</type>" &
        "    <minOccurs>1</minOccurs>" &
        "    <maxOccurs>1</maxOccurs>" &
        "  </element>" &
        "</schema>";
   begin
      Put ("Test: Element Definition... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Element_Definition;

   procedure Test_Full_Schema is
      Schema_SML : constant String :=
        "<schema>" &
        "  <simpleType>" &
        "    <name>portType</name>" &
        "    <restriction>" &
        "      <base>integer</base>" &
        "      <minValue>1</minValue>" &
        "      <maxValue>65535</maxValue>" &
        "    </restriction>" &
        "  </simpleType>" &
        "  <complexType>" &
        "    <name>databaseType</name>" &
        "    <sequence>" &
        "      <element>" &
        "        <name>host</name>" &
        "      </element>" &
        "      <element>" &
        "        <name>port</name>" &
        "      </element>" &
        "    </sequence>" &
        "  </complexType>" &
        "  <element>" &
        "    <name>config</name>" &
        "    <type>configType</type>" &
        "  </element>" &
        "</schema>";
   begin
      Put ("Test: Full Schema... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if not Load_Result.Success then
               Put_Line ("FAILED: " & To_String (Load_Result.Error_Message));
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Full_Schema;

   procedure Test_Missing_Name_Error is
      Schema_SML : constant String :=
        "<schema>" &
        "  <simpleType>" &
        "    <restriction><base>string</base></restriction>" &
        "  </simpleType>" &
        "</schema>";
   begin
      Put ("Test: Missing <name> Error... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if Load_Result.Success then
               Put_Line ("FAILED: Should have failed to load schema");
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Missing_Name_Error;

   procedure Test_Unknown_Base_Type_Error is
      Schema_SML : constant String :=
        "<schema>" &
        "  <simpleType>" &
        "    <name>x</name>" &
        "    <restriction><base>unknown</base></restriction>" &
        "  </simpleType>" &
        "</schema>";
   begin
      Put ("Test: Unknown Base Type Error... ");
      declare
         Parse_Result : constant SML.DOM.Parser.Parse_Result := SML.DOM.Parser.Parse (Schema_SML);
      begin
         if not Parse_Result.Success then
            Put_Line ("FAILED: Could not parse schema");
            return;
         end if;
         declare
            Load_Result : constant Schema_Load_Result := Load_Schema (Parse_Result.Doc);
         begin
            if Load_Result.Success then
               Put_Line ("FAILED: Should have failed to load schema");
               return;
            end if;
         end;
      end;
      Put_Line ("✓ PASSED");
   end Test_Unknown_Base_Type_Error;

   procedure Test_File_Based_Validation is
   begin
      Put ("Test: File-based validation... ");

      declare
         Schema_Parse : constant SML.DOM.Parser.Parse_Result :=
           SML.IO.Parse_File ("fixtures/config.schema.sml");
      begin
         if not Schema_Parse.Success then
            Put_Line ("FAILED: Could not load schema file");
            return;
         end if;
         declare
            Schema_Load : constant Schema_Load_Result := Load_Schema (Schema_Parse.Doc);
         begin
            if not Schema_Load.Success then
               Put_Line ("FAILED: Could not load schema: " & To_String (Schema_Load.Error_Message));
               return;
            end if;
            declare
               Valid_Doc : constant SML.DOM.Parser.Parse_Result :=
                 SML.IO.Parse_File ("fixtures/config_valid.sml");
               Invalid_Doc : constant SML.DOM.Parser.Parse_Result :=
                 SML.IO.Parse_File ("fixtures/config_invalid.sml");
            begin
               if not Valid_Doc.Success or else not Invalid_Doc.Success then
                  Put_Line ("FAILED: Could not load instance files");
                  return;
               end if;
               declare
                  V1 : constant Validation_Result := Validate_Document (Schema_Load.Schema, Valid_Doc.Doc);
                  V2 : constant Validation_Result := Validate_Document (Schema_Load.Schema, Invalid_Doc.Doc);
               begin
                  if V1.Status = Valid and then V2.Status = Invalid then
                     Put_Line ("✓ PASSED");
                  else
                     Put_Line ("FAILED: Unexpected validation results");
                  end if;
               end;
            end;
         end;
      end;
   end Test_File_Based_Validation;

begin
   Put_Line ("SML.Schema.Loader Test Suite");
   Test_Integer_Simple_Type;
   Test_String_Enum_Type;
   Test_Complex_Sequence_Type;
   Test_Complex_Choice_Type;
   Test_Element_Definition;
   Test_Full_Schema;
   Test_Missing_Name_Error;
   Test_Unknown_Base_Type_Error;
   Test_File_Based_Validation;
   Put_Line ("Done.");
end Test_Schema_Loader;
