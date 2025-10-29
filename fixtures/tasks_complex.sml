<task_database>
  <metadata>
    <version>1.0</version>
    <last_updated>2025-01-23</last_updated>
  </metadata>

  <projects>
    <project id="proj_ada">
      <name>SML Parser Development</name>
      <description>Build formally verified SML parser in Ada/SPARK</description>
      <status>active</status>
      <created>2025-01-01</created>
      <owner>rebecca</owner>
      <deadline>2025-03-01</deadline>
    </project>

    <project id="proj_docs">
      <name>Documentation</name>
      <description>Create comprehensive documentation</description>
      <status>planning</status>
      <created>2025-01-15</created>
      <owner>alex</owner>
    </project>
  </projects>

  <tasks>
    <task id="task_parser" project_id="proj_ada">
      <title>Implement core parser</title>
      <description>Build the main SML parsing engine with error recovery</description>
      <priority>1</priority>
      <status>done</status>
      <assigned_to>rebecca</assigned_to>
      <estimated_hours>40.0</estimated_hours>
      <due_date>2025-01-15</due_date>
      <completed_date>2025-01-14</completed_date>
      <tags>
        <tag>core</tag>
        <tag>parser</tag>
        <tag>critical</tag>
      </tags>
      <subtasks>
        <subtask id="st_001" completed="true">Lexical analysis</subtask>
        <subtask id="st_002" completed="true">Parse tree construction</subtask>
        <subtask id="st_003" completed="true">Error recovery mechanism</subtask>
        <subtask id="st_004" completed="true">UTF-8 validation</subtask>
      </subtasks>
    </task>

    <task id="task_schema" project_id="proj_ada">
      <title>Schema validation engine</title>
      <description>Implement XSD-like schema validation for SML documents</description>
      <priority>1</priority>
      <status>in_progress</status>
      <assigned_to>bob</assigned_to>
      <estimated_hours>60.0</estimated_hours>
      <due_date>2025-02-01</due_date>
      <tags>
        <tag>schema</tag>
        <tag>validation</tag>
        <tag>core</tag>
      </tags>
      <dependencies>
        <depends_on>task_parser</depends_on>
      </dependencies>
      <subtasks>
        <subtask id="st_101" completed="true">Type system design</subtask>
        <subtask id="st_102" completed="true">Element validators</subtask>
        <subtask id="st_103" completed="false">Cardinality constraints</subtask>
        <subtask id="st_104" completed="false">Complex type validation</subtask>
        <subtask id="st_105" completed="false">Error reporting</subtask>
      </subtasks>
    </task>

    <task id="task_io" project_id="proj_ada">
      <title>File I/O utilities</title>
      <description>Create file reading and writing utilities</description>
      <priority>2</priority>
      <status>review</status>
      <assigned_to>carol</assigned_to>
      <estimated_hours>16.0</estimated_hours>
      <due_date>2025-01-25</due_date>
      <tags>
        <tag>io</tag>
        <tag>utility</tag>
      </tags>
      <dependencies>
        <depends_on>task_parser</depends_on>
      </dependencies>
      <subtasks>
        <subtask id="st_201" completed="true">File reading with size limits</subtask>
        <subtask id="st_202" completed="true">Safe file writing</subtask>
        <subtask id="st_203" completed="true">Error handling</subtask>
      </subtasks>
    </task>

    <task id="task_spark" project_id="proj_ada">
      <title>SPARK proofs</title>
      <description>Complete formal verification proofs</description>
      <priority>1</priority>
      <status>in_progress</status>
      <assigned_to>david</assigned_to>
      <estimated_hours>80.0</estimated_hours>
      <due_date>2025-02-15</due_date>
      <tags>
        <tag>spark</tag>
        <tag>verification</tag>
        <tag>critical</tag>
      </tags>
      <dependencies>
        <depends_on>task_parser</depends_on>
        <depends_on>task_schema</depends_on>
      </dependencies>
      <subtasks>
        <subtask id="st_301" completed="true">Memory safety proofs</subtask>
        <subtask id="st_302" completed="false">Functional correctness</subtask>
        <subtask id="st_303" completed="false">Loop termination</subtask>
        <subtask id="st_304" completed="false">Overflow checks</subtask>
      </subtasks>
    </task>

    <task id="task_perf" project_id="proj_ada">
      <title>Performance optimization</title>
      <description>Optimize parser performance for large documents</description>
      <priority>3</priority>
      <status>todo</status>
      <estimated_hours>24.0</estimated_hours>
      <due_date>2025-02-20</due_date>
      <tags>
        <tag>performance</tag>
        <tag>optimization</tag>
      </tags>
      <dependencies>
        <depends_on>task_parser</depends_on>
        <depends_on>task_spark</depends_on>
      </dependencies>
    </task>

    <task id="task_tutorial" project_id="proj_docs">
      <title>Write tutorial</title>
      <description>Create step-by-step tutorial for task management system</description>
      <priority>2</priority>
      <status>todo</status>
      <assigned_to>alex</assigned_to>
      <estimated_hours>20.0</estimated_hours>
      <due_date>2025-02-10</due_date>
      <tags>
        <tag>documentation</tag>
        <tag>tutorial</tag>
      </tags>
      <subtasks>
        <subtask id="st_401" completed="false">Basic parsing examples</subtask>
        <subtask id="st_402" completed="false">Schema validation examples</subtask>
        <subtask id="st_403" completed="false">DOM building examples</subtask>
        <subtask id="st_404" completed="false">File I/O examples</subtask>
        <subtask id="st_405" completed="false">Complete application</subtask>
      </subtasks>
    </task>

    <task id="task_api_docs" project_id="proj_docs">
      <title>API documentation</title>
      <description>Document all public APIs</description>
      <priority>2</priority>
      <status>blocked</status>
      <assigned_to>alex</assigned_to>
      <estimated_hours>30.0</estimated_hours>
      <due_date>2025-02-05</due_date>
      <tags>
        <tag>documentation</tag>
        <tag>api</tag>
      </tags>
      <dependencies>
        <depends_on>task_schema</depends_on>
        <depends_on>task_io</depends_on>
      </dependencies>
    </task>
  </tasks>

  <time_entries>
    <entry task_id="task_parser">
      <date>2025-01-10</date>
      <hours>8.0</hours>
      <description>Initial parser structure</description>
      <user>rebecca</user>
    </entry>
    <entry task_id="task_parser">
      <date>2025-01-11</date>
      <hours>7.5</hours>
      <description>Lexical analysis implementation</description>
      <user>rebecca</user>
    </entry>
    <entry task_id="task_parser">
      <date>2025-01-12</date>
      <hours>6.0</hours>
      <description>Parse tree construction</description>
      <user>rebecca</user>
    </entry>
    <entry task_id="task_parser">
      <date>2025-01-13</date>
      <hours>8.0</hours>
      <description>Error recovery and UTF-8</description>
      <user>rebecca</user>
    </entry>
    <entry task_id="task_parser">
      <date>2025-01-14</date>
      <hours>9.5</hours>
      <description>Testing and bug fixes</description>
      <user>rebecca</user>
    </entry>
    <entry task_id="task_schema">
      <date>2025-01-15</date>
      <hours>4.0</hours>
      <description>Type system design</description>
      <user>bob</user>
    </entry>
    <entry task_id="task_schema">
      <date>2025-01-16</date>
      <hours>6.5</hours>
      <description>Element validator implementation</description>
      <user>bob</user>
    </entry>
    <entry task_id="task_schema">
      <date>2025-01-17</date>
      <hours>5.0</hours>
      <description>Simple type validators</description>
      <user>bob</user>
    </entry>
    <entry task_id="task_io">
      <date>2025-01-18</date>
      <hours>3.5</hours>
      <description>File reading implementation</description>
      <user>carol</user>
    </entry>
    <entry task_id="task_io">
      <date>2025-01-19</date>
      <hours>4.0</hours>
      <description>File writing and error handling</description>
      <user>carol</user>
    </entry>
    <entry task_id="task_spark">
      <date>2025-01-20</date>
      <hours>8.0</hours>
      <description>Memory safety proof setup</description>
      <user>david</user>
    </entry>
    <entry task_id="task_spark">
      <date>2025-01-21</date>
      <hours>7.5</hours>
      <description>Proving array bounds</description>
      <user>david</user>
    </entry>
    <entry task_id="task_spark">
      <date>2025-01-22</date>
      <hours>6.0</hours>
      <description>UTF-8 validation proofs</description>
      <user>david</user>
    </entry>
  </time_entries>
</task_database>