pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__sml_example.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__sml_example.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E016 : Short_Integer; pragma Import (Ada, E016, "ada__exceptions_E");
   E012 : Short_Integer; pragma Import (Ada, E012, "system__soft_links_E");
   E010 : Short_Integer; pragma Import (Ada, E010, "system__exception_table_E");
   E025 : Short_Integer; pragma Import (Ada, E025, "ada__numerics_E");
   E019 : Short_Integer; pragma Import (Ada, E019, "system__exceptions_E");
   E053 : Short_Integer; pragma Import (Ada, E053, "system__soft_links__initialize_E");
   E082 : Short_Integer; pragma Import (Ada, E082, "ada__io_exceptions_E");
   E007 : Short_Integer; pragma Import (Ada, E007, "ada__strings_E");
   E057 : Short_Integer; pragma Import (Ada, E057, "ada__strings__utf_encoding_E");
   E099 : Short_Integer; pragma Import (Ada, E099, "interfaces__c_E");
   E102 : Short_Integer; pragma Import (Ada, E102, "system__os_lib_E");
   E065 : Short_Integer; pragma Import (Ada, E065, "ada__tags_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__strings__text_buffers_E");
   E081 : Short_Integer; pragma Import (Ada, E081, "ada__streams_E");
   E110 : Short_Integer; pragma Import (Ada, E110, "system__file_control_block_E");
   E094 : Short_Integer; pragma Import (Ada, E094, "system__finalization_root_E");
   E092 : Short_Integer; pragma Import (Ada, E092, "ada__finalization_E");
   E091 : Short_Integer; pragma Import (Ada, E091, "system__file_io_E");
   E079 : Short_Integer; pragma Import (Ada, E079, "ada__text_io_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E079 := E079 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "ada__text_io__finalize_spec");
      begin
         if E079 = 0 then
            F1;
         end if;
      end;
      declare
         procedure F2;
         pragma Import (Ada, F2, "system__file_io__finalize_body");
      begin
         E091 := E091 - 1;
         if E091 = 0 then
            F2;
         end if;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (Ada, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;
   pragma Favor_Top_Level (No_Param_Proc);

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");
      Interrupts_Default_To_System : Integer;
      pragma Import (C, Interrupts_Default_To_System, "__gl_interrupts_default_to_system");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      if E016 = 0 then
         Ada.Exceptions'Elab_Spec;
      end if;
      if E012 = 0 then
         System.Soft_Links'Elab_Spec;
      end if;
      if E010 = 0 then
         System.Exception_Table'Elab_Body;
      end if;
      E010 := E010 + 1;
      if E025 = 0 then
         Ada.Numerics'Elab_Spec;
      end if;
      E025 := E025 + 1;
      if E019 = 0 then
         System.Exceptions'Elab_Spec;
      end if;
      E019 := E019 + 1;
      if E053 = 0 then
         System.Soft_Links.Initialize'Elab_Body;
      end if;
      E053 := E053 + 1;
      E012 := E012 + 1;
      E016 := E016 + 1;
      if E082 = 0 then
         Ada.Io_Exceptions'Elab_Spec;
      end if;
      E082 := E082 + 1;
      if E007 = 0 then
         Ada.Strings'Elab_Spec;
      end if;
      E007 := E007 + 1;
      if E057 = 0 then
         Ada.Strings.Utf_Encoding'Elab_Spec;
      end if;
      E057 := E057 + 1;
      if E099 = 0 then
         Interfaces.C'Elab_Spec;
      end if;
      E099 := E099 + 1;
      if E102 = 0 then
         System.Os_Lib'Elab_Body;
      end if;
      E102 := E102 + 1;
      if E065 = 0 then
         Ada.Tags'Elab_Spec;
      end if;
      if E065 = 0 then
         Ada.Tags'Elab_Body;
      end if;
      E065 := E065 + 1;
      if E006 = 0 then
         Ada.Strings.Text_Buffers'Elab_Spec;
      end if;
      E006 := E006 + 1;
      if E081 = 0 then
         Ada.Streams'Elab_Spec;
      end if;
      E081 := E081 + 1;
      if E110 = 0 then
         System.File_Control_Block'Elab_Spec;
      end if;
      E110 := E110 + 1;
      if E094 = 0 then
         System.Finalization_Root'Elab_Spec;
      end if;
      E094 := E094 + 1;
      if E092 = 0 then
         Ada.Finalization'Elab_Spec;
      end if;
      E092 := E092 + 1;
      if E091 = 0 then
         System.File_Io'Elab_Body;
      end if;
      E091 := E091 + 1;
      if E079 = 0 then
         Ada.Text_Io'Elab_Spec;
      end if;
      if E079 = 0 then
         Ada.Text_Io'Elab_Body;
      end if;
      E079 := E079 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_sml_example");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      if gnat_argc = 0 then
         gnat_argc := argc;
         gnat_argv := argv;
      end if;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   /Users/rebecca/src/github.com/berkeleynerd/sml/crates/sml-examples/obj/examples/sml_example.o
   --   -L/Users/rebecca/src/github.com/berkeleynerd/sml/crates/sml-examples/obj/examples/
   --   -L/Users/rebecca/src/github.com/berkeleynerd/sml/crates/sml-examples/obj/examples/
   --   -L/Users/rebecca/src/github.com/berkeleynerd/sml/lib/
   --   -L/Users/rebecca/src/github.com/berkeleynerd/sml/crates/sml-io/lib/io/
   --   -L/private/tmp/.local/share/alire/toolchains/gnat_native_15.1.2_60748c54/lib/gcc/aarch64-apple-darwin23.6.0/15.0.1/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
