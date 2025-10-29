#!/bin/bash
# Validate All Lessons Script
# Builds and tests all 5 lessons to ensure continuity

set -e  # Exit on any error

echo "========================================="
echo "  Tutorial Lesson Validation"
echo "========================================="
echo ""

# Track statistics
TOTAL_LESSONS=5
TOTAL_EXECUTABLES=15
LESSONS_PASSED=0
EXECUTABLES_PASSED=0
FAILED_LESSONS=()

# Lessons array
LESSONS=(
    "lesson-1-basic-parsing:1"
    "lesson-2-schema-validation:2"
    "lesson-3-building-documents:3"
    "lesson-4-transformation:4"
    "lesson-5-analysis:5"
)

# Function to validate a lesson
validate_lesson() {
    local lesson_dir=$1
    local expected_exe_count=$2
    local lesson_num=$(echo $lesson_dir | grep -o '[0-9]' | head -1)

    echo "========================================="
    echo "  Validating: $lesson_dir"
    echo "  Expected executables: $expected_exe_count"
    echo "========================================="

    cd "$lesson_dir"

    # Step 1: Clean
    echo "  [1/4] Cleaning..."
    alr clean 2>&1 > /dev/null || true
    rm -rf bin/ obj/ alire/cache/ 2>/dev/null || true

    # Step 2: Build
    echo "  [2/4] Building..."
    if ! alr build > build.log 2>&1; then
        echo "  ❌ [FAIL] Build failed!"
        echo "  See $lesson_dir/build.log for details"
        cd ..
        return 1
    fi

    # Step 3: Check executable count
    echo "  [3/4] Checking executables..."
    local exe_count=$(ls -1 bin/ 2>/dev/null | wc -l | tr -d ' ')
    if [ "$exe_count" -ne "$expected_exe_count" ]; then
        echo "  ❌ [FAIL] Expected $expected_exe_count executables, found $exe_count"
        cd ..
        return 1
    fi

    # Step 4: Run all executables
    echo "  [4/4] Running executables..."
    local exe_passed=0
    for exe in bin/*; do
        if [ -x "$exe" ]; then
            local exe_name=$(basename "$exe")
            echo "    Testing: $exe_name"
            if ! timeout 10 "$exe" > "${exe_name}.output" 2>&1; then
                echo "    ❌ [FAIL] $exe_name failed or timed out"
                cd ..
                return 1
            fi
            exe_passed=$((exe_passed + 1))
            EXECUTABLES_PASSED=$((EXECUTABLES_PASSED + 1))
        fi
    done

    echo "  ✅ [PASS] All $exe_passed executables ran successfully"
    echo ""

    cd ..
    return 0
}

# Main validation loop
for lesson_spec in "${LESSONS[@]}"; do
    IFS=':' read -r lesson_dir expected_count <<< "$lesson_spec"

    if validate_lesson "$lesson_dir" "$expected_count"; then
        LESSONS_PASSED=$((LESSONS_PASSED + 1))
    else
        FAILED_LESSONS+=("$lesson_dir")
    fi
done

# Summary
echo "========================================="
echo "  Validation Summary"
echo "========================================="
echo ""
echo "Lessons:     $LESSONS_PASSED / $TOTAL_LESSONS passed"
echo "Executables: $EXECUTABLES_PASSED / $TOTAL_EXECUTABLES passed"
echo ""

if [ ${#FAILED_LESSONS[@]} -eq 0 ]; then
    echo "✅ ✅ ✅  ALL LESSONS VALIDATED SUCCESSFULLY  ✅ ✅ ✅"
    echo ""
    exit 0
else
    echo "❌ FAILED LESSONS:"
    for failed in "${FAILED_LESSONS[@]}"; do
        echo "  - $failed"
    done
    echo ""
    exit 1
fi
