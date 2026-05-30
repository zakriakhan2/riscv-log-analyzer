#!/bin/bash

# Enforce strict error handling: exit on error, unset variables, or pipeline failures
set -euo pipefail

# Default configuration values
FORMAT="text"
OUTPUT="/dev/stdout"
VERBOSE=0
LOG_FILE=""

# Function 1: Display usage information
print_usage() {
    echo "Usage: $0 <log_file> [--format text|csv] [--output <path>] [--verbose] [--help]"
    echo ""
    echo "Arguments:"
    echo "  <log_file>            Path to the RISC-V simulation log file (Required)"
    echo "  --format [text|csv]   Set output format (default: text)"
    echo "  --output <path>       Redirect output to a file (default: stdout)"
    echo "  --verbose             Enable verbose debugging output"
    echo "  --help                Print this help menu"
}

# Function 2: Parse and validate command-line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        echo "Error: Missing required log file argument." >&2
        print_usage
        exit 1
    fi

    LOG_FILE="$1"
    shift

    # Loop through remaining options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --format)
                if [[ "${2:-}" != "text" && "${2:-}" != "csv" ]]; then
                    echo "Error: Invalid format '${2:-}'. Must be 'text' or 'csv'." >&2
                    exit 1
                fi
                FORMAT="$2"
                shift 2
                ;;
            --output)
                if [ -z "${2:-}" ]; then
                    echo "Error: --output requires a file path argument." >&2
                    exit 1
                fi
                OUTPUT="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=1
                shift 1
                ;;
            --help)
                print_usage
                exit 0
                ;;
            *)
                echo "Error: Unknown argument '$1'" >&2
                print_usage
                exit 1
                ;;
        esac
    done
}

# Invoke the argument parsing function
parse_args "$@"

# Error handling: Check if the file actually exists and is readable
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' does not exist or is not a regular file." >&2
    exit 1
fi

if [ "$VERBOSE" -eq 1 ]; then
    echo "[VERBOSE] Starting analysis on file: $LOG_FILE"
    echo "[VERBOSE] Format: $FORMAT | Output Target: $OUTPUT"
fi

# Function 3: Core parsing and statistical analysis engine
analyze_log() {
    # Using awk to process the file in a single pass for performance efficiency
    awk -v fmt="$FORMAT" -v log_path="$LOG_FILE" -v run_date="$(date '+%Y-%m-%d %H:%M:%S')" '
    BEGIN {
        total = 0; pass = 0; fail = 0; skip = 0;
        min_time = 999999; max_time = 0; total_time = 0; time_count = 0;
    }
    
    # Matching logs containing test status lines
    /TEST PASS:/ { pass++; total++; handle_timing($0); }
    /TEST FAIL:/ { fail++; total++; failed_names[fail] = $5; handle_timing($0); }
    /TEST SKIP:/ { skip++; total++; }
    
    # Inline Helper: Extract execution timing data via regex tracking
    function handle_timing(line) {
        match(line, /\([0-9.]+s\)/)
        if (RSTART > 0) {
            # Substring strips away the outer bounding parentheses and the trailing "s"
            t_str = substr(line, RSTART + 1, RLENGTH - 2)
            t_val = t_str + 0 # Coerces string explicitly into a numeric float
            t_name = $5
            
            total_time += t_val
            time_count++
            
            if (t_val < min_time) { min_time = t_val; min_test = t_name }
            if (t_val > max_time) { max_time = t_val; max_test = t_name }
        }
    }
    
    END {
        pass_p = (total > 0) ? (pass / total) * 100 : 0
        fail_p = (total > 0) ? (fail / total) * 100 : 0
        skip_p = (total > 0) ? (skip / total) * 100 : 0
        avg_time = (time_count > 0) ? (total_time / time_count) : 0
        
        if (fmt == "csv") {
            print "Total,Passed,Failed,Skipped,PassRate,MinTime,MaxTime,AvgTime"
            printf "%d,%d,%d,%d,%.1f%%,%.2fs,%.2fs,%.2fs\n", 
                total, pass, fail, skip, pass_p, (min_time == 999999 ? 0 : min_time), max_time, avg_time
        } else {
            print "=== RISC-V Simulation Log Analysis ==="
            print "Log file: " log_path
            print "Analysis date: " run_date
            print "\n--- Results Summary ---"
            printf "Total tests: %d\n", total
            printf "Passed: %d (%5.1f%%)\n", pass, pass_p
            printf "Failed: %d (%5.1f%%)\n", fail, fail_p
            printf "Skipped: %d (%5.1f%%)\n", skip, skip_p
            
            if (fail > 0) {
                print "\n--- Failed Tests ---"
                for (i = 1; i <= fail; i++) {
                    printf "%d. %s\n", i, failed_names[i]
                }
            }
            
            if (time_count > 0) {
                print "\n--- Timing Statistics ---"
                printf "Min time: %.2fs (%s)\n", min_time, min_test
                printf "Max time: %.2fs (%s)\n", max_time, max_test
                printf "Avg time: %.2fs\n", avg_time
            }
            
            print "\n--- Verdict: " (fail > 0 ? "FAIL" : "PASS") " ---"
            print "Exit code: " (fail > 0 ? "1" : "0")
        }
        
        if (fail > 0) exit 1;
        exit 0;
    }' "$LOG_FILE"
}

analyze_log > "$OUTPUT"
