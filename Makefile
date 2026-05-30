# ==============================================================================
# Makefile: RISC-V Log Analyzer Build & Run Automation
# ==============================================================================

.PHONY: all setup test report clean help

# Target 1: Run setup, tests, and report generation sequentially
all: setup test report

# Target 2: Verify all required system utilities are installed
setup:
	@echo "=== Target: Setup ==="
	@chmod +x scripts/*.sh
	@./scripts/setup_env.sh

# Target 3: Run the analyzer on each test data file
test:
	@echo "=== Target: Test ==="
	@echo "Testing sample_pass.log (Expected: PASS)..."
	@./scripts/analyze.sh test_data/sample_pass.log
	@echo ""
	@echo "Testing sample_fail.log (Expected: FAIL)..."
	@./scripts/analyze.sh test_data/sample_fail.log || echo "[Note] Script exited with code 1 as expected for failures."
	@echo ""
	@echo "Testing sample_sim.log (Expected: FAIL)..."
	@./scripts/analyze.sh test_data/sample_sim.log || echo "[Note] Script exited with code 1 as expected for failures."

# Target 4: Generate text and CSV summary reports in the output/ directory
report:
	@echo "=== Target: Report ==="
	@./scripts/generate_report.sh test_data/sample_sim.log output

# Target 5: Purge all generated report files
clean:
	@echo "=== Target: Clean ==="
	@echo "Removing generated report artifacts from output/ directory..."
	rm -f output/report.txt output/report.csv

# Target 6: Display all available targets with descriptions
help:
	@echo "========================================================================"
	@echo " Available Automation Targets"
	@echo "========================================================================"
	@echo "  make setup   : Validates that tools (bash, grep, awk, sed) are present"
	@echo "  make test    : Runs the analyzer script across all log files in test_data/"
	@echo "  make report  : Generates summary text and CSV reports inside output/"
	@echo "  make clean   : Removes all generated output report files"
	@echo "  make all     : Executes setup, test, and report targets in order"
	@echo "  make help    : Prints this command usage guide"
	@echo "========================================================================"
