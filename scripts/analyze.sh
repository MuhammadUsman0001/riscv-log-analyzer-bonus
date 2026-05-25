#!/bin/bash
set -euo pipefail

FORMAT="text"
OUTPUT=""
VERBOSE=0
COMPARE_FILE=""

if [ -t 1 ] && [ "${NO_COLOR:-0}" -eq 0 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    BLUE=''
    NC=''
fi

print_usage() {
    cat << EOF
Usage:
    ./scripts/analyze.sh <log_file> [OPTIONS]

OPTIONS:
    -f <text|csv>     Output format
    -o <file>         Save report to file
    -c <log_file>     Compare with another log
    -v                Enable verbose output
    -h                Show help
EOF
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[INFO] $1"
    fi
}

extract_results() {
    local file="$1"

    grep -E "TEST PASS|TEST FAIL" "$file" | while read -r line; do
        status=$(echo "$line" | awk '{print $3}' | tr -d ':')
        test_name=$(echo "$line" | awk '{print $4}')
        echo "$test_name=$status"
    done
}

compare_logs() {
    local current_log="$1"
    local old_log="$2"

    declare -A OLD_RESULTS
    declare -A CURRENT_RESULTS

    while IFS='=' read -r test status; do
        OLD_RESULTS["$test"]="$status"
    done < <(extract_results "$old_log")

    while IFS='=' read -r test status; do
        CURRENT_RESULTS["$test"]="$status"
    done < <(extract_results "$current_log")

    echo
    echo "=== Regression Analysis ==="

    regressions=0
    fixes=0

    for test in "${!CURRENT_RESULTS[@]}"; do
        old="${OLD_RESULTS[$test]:-UNKNOWN}"
        current="${CURRENT_RESULTS[$test]}"

        if [ "$old" = "PASS" ] && [ "$current" = "FAIL" ]; then
            echo -e "${RED}REGRESSION:${NC} $test"
            regressions=1
        fi

        if [ "$old" = "FAIL" ] && [ "$current" = "PASS" ]; then
            echo -e "${GREEN}FIXED:${NC} $test"
            fixes=1
        fi
    done

    if [ "$regressions" -eq 0 ] && [ "$fixes" -eq 0 ]; then
        echo "No changes detected"
    fi
}

while getopts ":f:o:c:vh" opt; do
    case "$opt" in
        f)
            FORMAT="$OPTARG"
            ;;
        o)
            OUTPUT="$OPTARG"
            ;;
        c)
            COMPARE_FILE="$OPTARG"
            ;;
        v)
            VERBOSE=1
            ;;
        h)
            print_usage
            exit 0
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

LOG_FILE="${1:-}"

if [ -z "$LOG_FILE" ]; then
    echo "Error: Missing log file"
    print_usage
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File not found: $LOG_FILE"
    exit 1
fi

if [ -n "$COMPARE_FILE" ] && [ ! -f "$COMPARE_FILE" ]; then
    echo "Error: Compare file not found: $COMPARE_FILE"
    exit 1
fi

log_verbose "Analyzing $LOG_FILE"

TOTAL=$(grep -c "TEST START" "$LOG_FILE" || true)
PASS=$(grep -c "TEST PASS" "$LOG_FILE" || true)
FAIL=$(grep -c "TEST FAIL" "$LOG_FILE" || true)
SKIP=$(grep -c "TEST SKIP" "$LOG_FILE" || true)

if [ "$TOTAL" -eq 0 ]; then
    echo "Warning: No tests found"
    exit 1
fi

PASS_RATE=$(awk "BEGIN {printf \"%.2f\", ($PASS/$TOTAL)*100}")

FAILED_TESTS=$(grep "TEST FAIL" "$LOG_FILE" | awk '{print $4}' || true)

if [ -z "$FAILED_TESTS" ]; then
    FAILED_TESTS="None"
fi

TIMES=$(awk '
/TEST PASS|TEST FAIL/ {
    match($0, /\(([0-9.]+)s\)/)
    value=substr($0, RSTART + 1, RLENGTH - 2)
    print value
}
' "$LOG_FILE")

if [ -n "$TIMES" ]; then
    MIN_TIME=$(echo "$TIMES" | sort -n | head -1)
    MAX_TIME=$(echo "$TIMES" | sort -n | tail -1)
    AVG_TIME=$(echo "$TIMES" | awk '{sum+=$1} END {printf "%.2f", sum/NR}')
else
    MIN_TIME="N/A"
    MAX_TIME="N/A"
    AVG_TIME="N/A"
fi

if [ "$FORMAT" = "csv" ]; then
    REPORT="total,pass,fail,skip,pass_rate\n$TOTAL,$PASS,$FAIL,$SKIP,$PASS_RATE"
else
    REPORT=$(cat << EOF
=== RISC-V Simulation Log Analysis ===

Log file: $LOG_FILE
Analysis date: $(date '+%Y-%m-%d %H:%M:%S')

--- Results Summary ---
Passed: ${GREEN}$PASS${NC}
Failed: ${RED}$FAIL${NC}
Skipped: ${YELLOW}$SKIP${NC}
Total tests: $TOTAL
Pass rate: ${PASS_RATE}%

--- Failed Tests ---
$FAILED_TESTS

--- Timing Statistics ---
Min time: ${MIN_TIME}s
Max time: ${MAX_TIME}s
Avg time: ${AVG_TIME}s
EOF
)
fi

if [ -n "$OUTPUT" ]; then
    mkdir -p "$(dirname "$OUTPUT")"
    echo -e "$REPORT" > "$OUTPUT"
else
    echo -e "$REPORT"
fi

if [ -n "$COMPARE_FILE" ]; then
    compare_logs "$LOG_FILE" "$COMPARE_FILE"
fi

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0