SCRIPT_DIR := scripts
TEST_DIR := test_data
OUTPUT_DIR := output

ANALYZER := $(SCRIPT_DIR)/analyze.sh
REPORTER := $(SCRIPT_DIR)/generate_report.sh
SETUP := $(SCRIPT_DIR)/setup_env.sh

LOGS := $(wildcard $(TEST_DIR)/*.log)

.PHONY: all test report clean help setup

all:
	@for log in $(LOGS); do \
		$(ANALYZER) $$log; \
		echo; \
	done

test:
	@echo "Running validation tests..."
	@$(ANALYZER) $(TEST_DIR)/sample_pass.log > /dev/null
	@$(ANALYZER) $(TEST_DIR)/sample_fail.log > /dev/null || true
	@$(ANALYZER) $(TEST_DIR)/sample_sim.log > /dev/null || true
	@echo "All validation tests completed"

report:
	@$(REPORTER)

clean:
	rm -rf $(OUTPUT_DIR)

setup:
	@$(SETUP)

help:
	@echo "Available targets:"
	@echo "  make all     - Analyze all log files"
	@echo "  make test    - Run validation tests"
	@echo "  make report  - Generate text and HTML reports"
	@echo "  make clean   - Remove generated outputs"
	@echo "  make setup   - Verify required tools"
	@echo "  make help    - Show available targets"