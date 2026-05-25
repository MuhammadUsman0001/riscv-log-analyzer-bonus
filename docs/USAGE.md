# RISC-V Log Analyzer - Usage

## Command

```bash
./scripts/analyze.sh <log_file> [OPTIONS]
```

## Options

| Option | Description |
|--------|-------------|
| `--format text\|csv` | Output format (default: text) |
| `--output <file>` | Save to file |
| `--verbose` | Debug output |
| `--help` | Show help |

## Examples

```bash
# Basic analysis
./scripts/analyze.sh test_data/sample_pass.log

# CSV output
./scripts/analyze.sh test_data/sample_fail.log --format csv

# Save to file
./scripts/analyze.sh test_data/sample_fail.log --output result.txt

# Verbose mode
./scripts/analyze.sh test_data/sample_fail.log --verbose
```

## Sample Output

```
=== RISC-V Simulation Log Analysis ===

--- Results Summary ---
Total tests: 2
Passed: 1
Failed: 1
Pass rate: 50.00%

--- Failed Tests ---
rv32i-sll

--- Timing Statistics ---
Min time: 0.82s  Max time: 1.02s  Avg time: 0.92s
```

## Compare Mode

```bash
./scripts/analyze.sh current.log -c previous.log
```

Displays:

- Regressions
- Fixed tests
- Result differences

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | Tests failed or error |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Permission denied | `chmod +x scripts/*.sh` |
| No tests found | Check log contains `TEST START` |
| Command not found | Run from repository root |
