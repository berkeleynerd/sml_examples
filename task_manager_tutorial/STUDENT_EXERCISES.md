# SML Task Manager Tutorial - Student Exercises

## Exercise Overview

These exercises build on the lessons you've completed. Each exercise tests different aspects of the SML library and increases in complexity. Solutions are provided in the `solutions/` directory.

---

## Exercise 1: Parse and Count (Beginner)
**Skills**: Parsing, Basic Traversal

Create a program that:
1. Parses `fixtures/tasks_simple_sml.sml`
2. Counts the total number of task elements
3. Prints the count to the console

**Hint**: Use `First_Child` and `Next_Sibling` to traverse the document tree.

**Expected Output**:
```
Total tasks found: 3
```

---

## Exercise 2: Build a Shopping List (Intermediate)
**Skills**: Document Building, File I/O

Create a program that builds a shopping list document with:
- A metadata section with creation date
- At least 5 items with:
  - Item name
  - Quantity
  - Priority (high/medium/low)
- Save to `shopping_list.sml`

**Structure Example**:
```xml
<shopping_list>
  <metadata>
    <created>2025-01-24</created>
  </metadata>
  <items>
    <item>
      <name>Milk</name>
      <quantity>2</quantity>
      <priority>high</priority>
    </item>
    ...
  </items>
</shopping_list>
```

---

## Exercise 3: Task Filter (Intermediate)
**Skills**: Parsing, Filtering, Building

Create a program that:
1. Parses the task database
2. Filters only high-priority tasks (priority = "1")
3. Creates a new document with just those tasks
4. Saves to `high_priority_tasks.sml`

**Transformation Pattern**:
- Parse source → Filter tasks → Build new document → Save

---

## Exercise 4: Schema Validator (Advanced)
**Skills**: Schema Definition, Validation

Create a schema for a contact list with:
- Required fields: name, email
- Optional fields: phone, address
- Email must contain "@"
- Phone must be 10 digits

Then:
1. Create the schema file `contacts.schema.sml`
2. Create a valid contact list `contacts_valid.sml`
3. Create an invalid contact list `contacts_invalid.sml`
4. Write a validator that tests both files

**Note**: Remember to define custom types in your schema!

---

## Exercise 5: Task Manager CLI (Expert)
**Skills**: All concepts combined

Create a simple command-line task manager that:
1. Loads tasks from `my_tasks.sml` (create if doesn't exist)
2. Provides a menu with options:
   - [L]ist all tasks
   - [A]dd new task
   - [F]ilter by status
   - [S]tatistics report
   - [Q]uit
3. Saves changes back to `my_tasks.sml`

**Implementation Notes**:
- Use Ada.Text_IO.Get_Line for user input
- Remember: parsed documents are immutable, so rebuild for changes
- Keep the task structure simple (id, title, status, priority)

**Sample Interaction**:
```
=== Task Manager ===
[L]ist [A]dd [F]ilter [S]tats [Q]uit: L

Tasks:
1. Complete tutorial (done)
2. Review exercises (in_progress)
3. Submit project (todo)

[L]ist [A]dd [F]ilter [S]tats [Q]uit: S

Statistics:
Total: 3
Todo: 1
In Progress: 1
Done: 1
```

---

## Solution Guidelines

### Exercise 1 Solution Pattern
```ada
-- Parse file
-- Get root, find tasks element
-- Count children with name = "task"
-- Print count
```

### Exercise 2 Solution Pattern
```ada
-- Create_Document("shopping_list")
-- Add_Child_Element for metadata
-- Loop to add items
-- Write_Document with formatting
```

### Exercise 3 Solution Pattern
```ada
-- Parse source
-- Create new document
-- Traverse source, check priority
-- If priority = "1", add to new document
-- Save new document
```

### Exercise 4 Solution Pattern
```ada
-- Define simpleTypes with restrictions
-- Use custom types in element definitions
-- Test validation with both files
-- Check error messages
```

### Exercise 5 Solution Pattern
```ada
-- Main loop with menu
-- Parse at start, save at end
-- For modifications: rebuild entire document
-- Use records to track task data
-- Separate procedures for each operation
```

---

## Submission Checklist

For each exercise, ensure you:
- [ ] Follow Ada naming conventions
- [ ] Handle parse/write errors gracefully
- [ ] Use meaningful variable names
- [ ] Comment complex logic
- [ ] Test with edge cases
- [ ] Verify output files are valid SML

---

## Bonus Challenges

1. **Exercise 1+**: Also count tasks by status
2. **Exercise 2+**: Add validation for quantity (must be positive integer)
3. **Exercise 3+**: Allow filtering by multiple criteria
4. **Exercise 4+**: Add pattern validation for phone numbers
5. **Exercise 5+**: Add task editing and deletion features

---

## Resources

- Main Tutorial: Run `./bin/task_tutorial_test`
- Lesson Examples:
  - `./bin/lesson_2_fixed` - Schema validation
  - `./bin/lesson_3_building` - Document building
  - `./bin/lesson_4_transformation` - Transformation patterns
  - `./bin/lesson_5_analysis` - Analysis and queries
- Test Files: Check `fixtures/` directory
- API Documentation: See package specifications in `../sml/src/`

Good luck with your exercises! Remember: The SML library enforces memory safety through its limited types - work WITH this constraint, not against it.