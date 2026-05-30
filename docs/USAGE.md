# 🛠️ RISC-V Log Analyzer Toolchain

An automated, single-pass parsing pipeline designed to audit RISC-V simulation traces. This toolchain extracts test execution statuses, calculates latency telemetry, registers pipeline failures, and compiles analytical summaries in both human-readable and structured data formats.

---

## 📂 Project Architecture

```text
riscv-log-analyzer/
├── .gitignore              # Prevents tracking of generated report artifacts
├── Makefile                # Central automation management hub
├── docs/
│   └── USAGE.md            # System documentation manual (This file)
├── output/                 # Destination repository folder for built reports
├── scripts/
│   ├── analyze.sh          # Single-pass log parsing core engine
│   ├── generate_report.sh  # Orchestration pipeline wrapper
│   └── setup_env.sh        # Dependency validator & environment checker
└── test_data/
    ├── sample_fail.log     # Test trace containing explicit regression errors
    ├── sample_pass.log     # Idealized, clean verification trace
    └── sample_sim.log      # Variable timing system simulation baseline
```

> ⚠️ **Note:** The `output/` directory and its contents are tracked by `.gitignore` and will not be pushed to your remote repository, keeping your version control history clean.

---

## ⚡ Automation Quick Start

The project features a root-level `Makefile` to handle workflows seamlessly. 

| Command | Operational Purpose | Expected Workspace Behavior |
| :--- | :--- | :--- |
| `make setup` | Environment Verification | Audits `bash`, `grep`, `awk`, and `sed`. Configures permissions. |
| `make test` | Simulation Diagnostics | Scans all files in `test_data/` and flags execution faults. |
| `make report` | Report Compilation | Builds performance reports in `output/` (`.txt` and `.csv`). |
| `make all` | Full Execution Pipeline | Executes `setup`, `test`, and `report` sequentially. |
| `make clean` | Workspace Purge | Safely removes generated files from the `output/` folder. |

---

## 🧪 Interactive Testing Workbook

Use these explicit code blocks and inline command scripts to verify that the parser core and pipeline orchestration wrappers are running correctly.

### 1. Test Scenario A: Clean Pass Logs
Validate how the engine handles a perfect simulation run with zero structural hazards.
* **Execution Code:**
  ```bash
  ./scripts/analyze.sh test_data/sample_pass.log --format text
  ```
* **Expected Terminal Behavior:** The script returns exit status code `0` (Success) and outputs a summary showing 100% pass status with no failure registry block visible.

### 2. Test Scenario B: Expected Failures & Custom Exits
Validate that the engine explicitly catches instruction mismatch faults and exits with code `1`.
* **Execution Code:**
  ```bash
  ./scripts/analyze.sh test_data/sample_fail.log --format text; echo "Exit Code: $?"
  ```
* **Expected Terminal Behavior:** The output screen will list `rv32i-xori` directly under the **FAILED TEST REGISTRY** section. The trailing terminal string will explicitly print **`Exit Code: 1`**.

### 3. Test Scenario C: Inline CSV Transformation Pipeline
Test the structural data pipeline matrix generation.
* **Execution Code:**
  ```bash
  ./scripts/analyze.sh test_data/sample_sim.log --format csv --output output/test_matrix.csv
  cat output/test_matrix.csv
  ```
* **Expected Terminal Behavior:** No output dumps directly to the console during generation. The `cat` command should print out a single-row comma-delimited string:
  ```csv
  Total_Tests,Passed,Failed,Skipped,Pass_Rate,Min_Time,Max_Time,Avg_Time
  3,2,1,0,66.7%,1.35s,3.42s,2.24s
  ```

### 4. Test Scenario D: Multi-Format Automation Wrapper
Verify that the orchestration wrapper creates two distinct file formats simultaneously.
* **Execution Code:**
  ```bash
  ./scripts/generate_report.sh test_data/sample_sim.log output/test_run
  ls -l output/test_run/
  ```
* **Expected Terminal Behavior:** The directory contents display two verified items: `report.txt` and `report.csv`.

---

## ⚙️ Core Script Reference Manual

If you need to bypass the automation framework, interact directly with the script utilities using the interface rules below.

### 1. Environment Initializer
```bash
./scripts/setup_env.sh
```

### 2. Analytical Core Parsing Engine
```bash
./scripts/analyze.sh <path_to_log_file> [OPTIONS]
```
* `--format text|csv` — Presentation matrix flag. (Default: `text`)
* `--output <file_path>` — Redirects results to a specific target file path.
* `--verbose` — Streams telemetry milestones during runtime scanning.

---

## 📊 Evaluation Output Specs

### 📄 Text Report Summary (`report.txt`)
```text
====================================================
        RISC-V SIMULATION EXECUTION REPORT          
====================================================
Target Log Asset : test_data/sample_sim.log
----------------------------------------------------
Total Evaluated  : 3
Passed Status    : 2 (66.7%)
Failed Status    : 1 (33.3%)
...
```

### 📊 Structural Data Sheet (`report.csv`)
```csv
Total_Tests,Passed,Failed,Skipped,Pass_Rate,Min_Time,Max_Time,Avg_Time
3,2,1,0,66.7%,1.35s,3.42s,2.24s
```
