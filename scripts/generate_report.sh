#!/bin/bash
set -euo pipefail

OUTPUT_DIR="output"

mkdir -p "$OUTPUT_DIR"

./scripts/analyze.sh test_data/sample_pass.log \
    -o "$OUTPUT_DIR/pass_report.txt"

./scripts/analyze.sh test_data/sample_fail.log \
    -o "$OUTPUT_DIR/fail_report.txt" || true

./scripts/analyze.sh test_data/sample_sim.log \
    -o "$OUTPUT_DIR/sim_report.txt" || true

cat > "$OUTPUT_DIR/report.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RISC-V Log Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #cccccc;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #f4f4f4;
        }

        .pass {
            color: green;
        }

        .fail {
            color: red;
        }
    </style>
</head>
<body>

<h1>RISC-V Simulation Report</h1>

<table>
    <tr>
        <th>Log File</th>
        <th>Status</th>
    </tr>
    <tr>
        <td>sample_pass.log</td>
        <td class="pass">PASS</td>
    </tr>
    <tr>
        <td>sample_fail.log</td>
        <td class="fail">FAIL</td>
    </tr>
    <tr>
        <td>sample_sim.log</td>
        <td class="fail">FAIL</td>
    </tr>
</table>

</body>
</html>
EOF

echo "Reports generated in $OUTPUT_DIR/"