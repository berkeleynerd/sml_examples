<task_database>
  <metadata>
    <version>2.0</version>
    <last_updated>2025-01-23</last_updated>
  </metadata>

  <projects>
    <project id="proj_001">
      <name>This project name is way too long and exceeds the 100 character maximum limit that was defined in the schema validation rules</name>
      <description>Test project</description>
      <status>invalid_status</status>
      <created>2025-01-10</created>
      <owner>alice</owner>
    </project>
  </projects>

  <tasks>
    <task id="task_001" project_id="proj_001">
      <title></title>
      <description>Task with empty title (violates minLength)</description>
      <priority>10</priority>
      <status>working</status>
      <assigned_to>bob</assigned_to>
      <estimated_hours>-5.0</estimated_hours>
      <due_date>not-a-date</due_date>
    </task>

    <task id="task_002">
      <title>Task without project_id attribute</title>
      <priority>0</priority>
      <status>todo</status>
    </task>

    <task id="task_003" project_id="proj_001">
      <title>Task with too many subtasks</title>
      <priority>1</priority>
      <status>todo</status>
      <subtasks>
        <subtask id="st_01" completed="true">Subtask 1</subtask>
        <subtask id="st_02" completed="false">Subtask 2</subtask>
        <subtask id="st_03" completed="false">Subtask 3</subtask>
        <subtask id="st_04" completed="false">Subtask 4</subtask>
        <subtask id="st_05" completed="false">Subtask 5</subtask>
        <subtask id="st_06" completed="false">Subtask 6</subtask>
        <subtask id="st_07" completed="false">Subtask 7</subtask>
        <subtask id="st_08" completed="false">Subtask 8</subtask>
        <subtask id="st_09" completed="false">Subtask 9</subtask>
        <subtask id="st_10" completed="false">Subtask 10</subtask>
        <subtask id="st_11" completed="false">Subtask 11</subtask>
        <subtask id="st_12" completed="false">Subtask 12</subtask>
        <subtask id="st_13" completed="false">Subtask 13</subtask>
        <subtask id="st_14" completed="false">Subtask 14</subtask>
        <subtask id="st_15" completed="false">Subtask 15</subtask>
        <subtask id="st_16" completed="false">Subtask 16</subtask>
        <subtask id="st_17" completed="false">Subtask 17</subtask>
        <subtask id="st_18" completed="false">Subtask 18</subtask>
        <subtask id="st_19" completed="false">Subtask 19</subtask>
        <subtask id="st_20" completed="false">Subtask 20</subtask>
        <subtask id="st_21" completed="false">Subtask 21 - exceeds max</subtask>
      </subtasks>
    </task>

    <task id="task_004" project_id="proj_001">
      <priority>3</priority>
      <status>todo</status>
    </task>

    <task id="task_005" project_id="proj_001">
      <title>Task with missing priority and status</title>
    </task>
  </tasks>

  <time_entries>
    <entry>
      <date>2025-01-20</date>
      <hours>25.0</hours>
      <description>Entry without task_id attribute</description>
      <user>carol</user>
    </entry>

    <entry task_id="task_001">
      <date>2025-01-21</date>
      <hours>0.1</hours>
      <description>Hours too small (below 0.25 minimum)</description>
      <user>david</user>
    </entry>
  </time_entries>
</task_database>