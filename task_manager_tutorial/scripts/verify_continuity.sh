#!/bin/bash
# Verify Continuity Script
# Ensures each lesson contains all previous lesson executables

set -e

echo "========================================="
echo "  Verifying Lesson Continuity"
echo "========================================="
echo ""

ERRORS=0

# Function to check executable in alire.toml
check_executable_in_toml() {
    local lesson_dir=$1
    local exe_name=$2

    if ! grep -q "\"$exe_name\"" "$lesson_dir/alire.toml"; then
        echo "  ❌ [FAIL] $lesson_dir missing executable: $exe_name"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    return 0
}

# Function to check source file exists
check_source_file() {
    local lesson_dir=$1
    local src_file=$2

    if [ ! -f "$lesson_dir/src/$src_file" ]; then
        echo "  ❌ [FAIL] $lesson_dir missing source file: $src_file"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    return 0
}

# Validate Lesson 1
echo "Checking Lesson 1 (baseline)..."
check_executable_in_toml "lesson-1-basic-parsing" "lesson_1_basic_parsing"
check_source_file "lesson-1-basic-parsing" "lesson_1_basic_parsing.adb"
echo "  ✅ Lesson 1 OK"
echo ""

# Validate Lesson 2 contains Lesson 1
echo "Checking Lesson 2 contains Lesson 1..."
check_executable_in_toml "lesson-2-schema-validation" "lesson_1_basic_parsing"
check_executable_in_toml "lesson-2-schema-validation" "lesson_2_schema_validation"
check_source_file "lesson-2-schema-validation" "lesson_1_basic_parsing.adb"
check_source_file "lesson-2-schema-validation" "lesson_2_schema_validation.adb"
echo "  ✅ Lesson 2 contains Lesson 1"
echo ""

# Validate Lesson 3 contains Lessons 1-2
echo "Checking Lesson 3 contains Lessons 1-2..."
check_executable_in_toml "lesson-3-building-documents" "lesson_1_basic_parsing"
check_executable_in_toml "lesson-3-building-documents" "lesson_2_schema_validation"
check_executable_in_toml "lesson-3-building-documents" "lesson_3_building"
check_source_file "lesson-3-building-documents" "lesson_1_basic_parsing.adb"
check_source_file "lesson-3-building-documents" "lesson_2_schema_validation.adb"
check_source_file "lesson-3-building-documents" "lesson_3_building.adb"
echo "  ✅ Lesson 3 contains Lessons 1-2"
echo ""

# Validate Lesson 4 contains Lessons 1-3
echo "Checking Lesson 4 contains Lessons 1-3..."
check_executable_in_toml "lesson-4-transformation" "lesson_1_basic_parsing"
check_executable_in_toml "lesson-4-transformation" "lesson_2_schema_validation"
check_executable_in_toml "lesson-4-transformation" "lesson_3_building"
check_executable_in_toml "lesson-4-transformation" "lesson_4_transformation"
check_source_file "lesson-4-transformation" "lesson_1_basic_parsing.adb"
check_source_file "lesson-4-transformation" "lesson_2_schema_validation.adb"
check_source_file "lesson-4-transformation" "lesson_3_building.adb"
check_source_file "lesson-4-transformation" "lesson_4_transformation.adb"
echo "  ✅ Lesson 4 contains Lessons 1-3"
echo ""

# Validate Lesson 5 contains Lessons 1-4
echo "Checking Lesson 5 contains Lessons 1-4..."
check_executable_in_toml "lesson-5-analysis" "lesson_1_basic_parsing"
check_executable_in_toml "lesson-5-analysis" "lesson_2_schema_validation"
check_executable_in_toml "lesson-5-analysis" "lesson_3_building"
check_executable_in_toml "lesson-5-analysis" "lesson_4_transformation"
check_executable_in_toml "lesson-5-analysis" "lesson_5_analysis"
check_source_file "lesson-5-analysis" "lesson_1_basic_parsing.adb"
check_source_file "lesson-5-analysis" "lesson_2_schema_validation.adb"
check_source_file "lesson-5-analysis" "lesson_3_building.adb"
check_source_file "lesson-5-analysis" "lesson_4_transformation.adb"
check_source_file "lesson-5-analysis" "lesson_5_analysis.adb"
echo "  ✅ Lesson 5 contains Lessons 1-4"
echo ""

# Summary
echo "========================================="
echo "  Continuity Verification Summary"
echo "========================================="
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅  CONTINUITY VERIFIED"
    echo ""
    echo "Each lesson contains all previous lessons:"
    echo "  • Lesson 1: 1 executable  (baseline)"
    echo "  • Lesson 2: 2 executables (contains L1)"
    echo "  • Lesson 3: 3 executables (contains L1-2)"
    echo "  • Lesson 4: 4 executables (contains L1-3)"
    echo "  • Lesson 5: 5 executables (contains L1-4)"
    echo ""
    echo "This proves each lesson provides a complete"
    echo "foundation for the next lesson."
    echo ""
    exit 0
else
    echo "❌  CONTINUITY CHECK FAILED"
    echo ""
    echo "Found $ERRORS error(s)"
    echo "See messages above for details"
    echo ""
    exit 1
fi
