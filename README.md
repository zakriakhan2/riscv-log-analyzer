# 📊 RISC-V Log Analyzer & Test Reporting System

## Overview

This project is a lightweight CI-style log analysis and reporting system built using Bash. It processes test logs, highlights results in the terminal, detects regressions between runs, and generates a professional HTML report dashboard.

It simulates core functionality found in CI/CD pipelines such as Jenkins or GitHub Actions.

---

## Features

### Log Analysis
- Parses test logs in the format:

- Displays colored terminal output:
- PASS → Green
- FAIL → Red

---

### Regression Detection
- Compares two test runs
- Detects:
- PASS → FAIL (Regression)
- FAIL → PASS (Fix)
- Helps track performance and stability changes between builds

---

### JSON Output
- Generates structured JSON output per run
- Includes:
- Test name
- Status
- Message
- Timestamp
- Suitable for CI/CD integration

---

### HTML Report
- Generates a clean dashboard-style report
- Includes:
- Total tests
- Passed tests
- Failed tests
- Pass rate
- Styled table with color-coded results

---

### Failure Logging
- Automatically logs failed tests into:

- Useful for debugging

---

## Project Structure


---

## Usage

### Run analysis

```bash
./analyze.sh -f test_log.txt


./analyze.sh -f current_log.txt -c previous_log.txt

./generate_report.sh -i results.json -o report.html
report.html

```
```
input format 

test_login PASS user authenticated successfully
test_api FAIL timeout error
test_db PASS connection stable

test_name STATUS optional_message

```

``` terminal output 

test_login PASS
test_api FAIL
test_db PASS

Summary:
Total: 3 | PASS: 2 | FAIL: 1

```


