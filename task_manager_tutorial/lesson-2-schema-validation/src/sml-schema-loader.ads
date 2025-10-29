-- copied from examples/sml-schema-loader.ads
------------------------------------------------------------------------------
with SML.DOM;

package SML.Schema.Loader
  with SPARK_Mode => On
is
   use SML.DOM;

   type Schema_Load_Result (Success : Boolean := False) is limited record
      case Success is
         when True  => Schema : Schema_Document;
         when False =>
            Error_Message : Bounded_String;
            Error_Line    : Natural := 0;
      end case;
   end record;

   function Load_Schema (Doc : DOM.Document) return Schema_Load_Result
   with Pre => DOM.Is_Well_Formed (Doc);

   function Find_Child_Element
     (Doc    : DOM.Document;
      Parent : DOM.Node_Id;
      Name   : String) return DOM.Node_Id
   with Pre => DOM.Is_Well_Formed (Doc)
                and then Parent /= DOM.Null_Node
                and then Name'Length > 0
                and then Name'Length <= Max_Name_Length;

   function Get_Element_Text
     (Doc     : DOM.Document;
      Element : DOM.Node_Id) return String
   with Pre => DOM.Is_Well_Formed (Doc)
                and then Element /= DOM.Null_Node,
        Post => Get_Element_Text'Result'Length <= Max_Name_Length;

   function Get_Integer_Value
     (Doc           : DOM.Document;
      Parent        : DOM.Node_Id;
      Child_Name    : String;
      Default_Value : Integer) return Integer
   with Pre => DOM.Is_Well_Formed (Doc)
                and then Parent /= DOM.Null_Node
                and then Child_Name'Length > 0
                and then Child_Name'Length <= Max_Name_Length;

   function Get_Natural_Value
     (Doc           : DOM.Document;
      Parent        : DOM.Node_Id;
      Child_Name    : String;
      Default_Value : Natural) return Natural
   with Pre => DOM.Is_Well_Formed (Doc)
                and then Parent /= DOM.Null_Node
                and then Child_Name'Length > 0
                and then Child_Name'Length <= Max_Name_Length;

end SML.Schema.Loader;

