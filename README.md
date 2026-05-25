# RISC-V Log Analyzer

A command-line tool for parsing RISC-V simulation logs, extracting test results, and generating summary reports.

## Features

- Parse simulation logs with PASS/FAIL/SKIP results
- Calculate pass rates and timing statistics
- Output in text or CSV format
- Save reports to files or print to stdout
- Proper exit codes for CI/CD integration
- Verbose mode for debugging

## Repository Structure

```
riscv-log-analyzer/
├── Makefile
├── README.md
├── USAGE.md
├── scripts/
│   ├── analyze.sh          # Main analysis script
│   ├── generate_report.sh  # Batch report generator
│   └── setup_env.sh        # Dependency checker
├── test_data/
│   ├── sample_pass.log     # Sample log with all passing
│   ├── sample_fail.log     # Sample log with failures
│   └── sample_sim.log      # Additional sample
└── output/                 # Generated reports (created at runtime)
```

## Installation

```bash
# Clone the repository
git clone git@github.com:MuhammadUsman0001/riscv-log-analyzer-bonus.git
cd riscv-log-analyzer

# Verify dependencies
make setup

# Make scripts executable (if needed)
chmod +x scripts/*.sh
```

## Usage

```bash
./scripts/analyze.sh <log_file> [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--format text\|csv` | Output format (default: text) |
| `--output <file>` | Save report to file |
| `--verbose` | Show debug information |
| `--help` | Display help message |

## Example Commands

```bash
# Basic analysis
./scripts/analyze.sh test_data/sample_pass.log

# Save CSV report to file
./scripts/analyze.sh test_data/sample_fail.log --format csv --output results.csv

# Verbose analysis
./scripts/analyze.sh test_data/sample_fail.log --verbose

# Generate all reports
make report

# Run tests
make test
```

## Sample Output

### Text Format

```
=== RISC-V Simulation Log Analysis ===

Log file: test_data/sample_fail.log

--- Results Summary ---
Total tests: 2
Passed: 1
Failed: 1
Skipped: 0
Pass rate: 50.00%

--- Failed Tests ---
rv32i-sll

--- Timing Statistics ---
Min time: 0.82s
Max time: 1.02s
Avg time: 0.92s
```

### CSV Format

```
total,pass,fail,skip,pass_rate
2,1,1,0,50.00
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make all` | Analyze all sample logs |
| `make test` | Run validation tests (fails if any test fails) |
| `make report` | Generate full reports in output/ directory |
| `make clean` | Remove output directory |
| `make setup` | Verify required tools (bash, grep, awk, sed) |
| `make help` | Show available targets |

## Compare Two Logs

```bash
./scripts/analyze.sh test_data/sample_sim.log -c test_data/sample_pass.log
```

## Generate Reports

```bash
make report
```

This generates:

- Text reports
- HTML report (`output/report.html`)

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed or error occurred |

## Requirements

- Bash 4.0+
- grep, awk, sed (standard Unix tools)

## License

MEDS Summer Training Programme 2026 • Cohort 4
