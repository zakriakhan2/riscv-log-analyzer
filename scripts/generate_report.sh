#!/bin/bash

INPUT=""
OUTPUT="report.html"

while getopts "i:o:" opt; do
  case $opt in
    i) INPUT="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    *) exit 1 ;;
  esac
done

[ -z "$INPUT" ] && exit 1

TOTAL=$(grep -c '"status"' "$INPUT")
PASS=$(grep -c '"PASS"' "$INPUT")
FAIL=$(grep -c '"FAIL"' "$INPUT")

RATE=$(awk "BEGIN {printf \"%.2f\", ($PASS/($PASS+$FAIL))*100}")

cat > "$OUTPUT" <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Test Report</title>

<style>
body { font-family: Arial; background:#f4f4f4; margin:40px; }

.card {
  background:white;
  padding:15px;
  margin-bottom:20px;
  border-radius:10px;
  box-shadow:0 2px 8px rgba(0,0,0,0.1);
}

table {
  width:100%;
  border-collapse:collapse;
  background:white;
  border-radius:10px;
  overflow:hidden;
}

th {
  background:#222;
  color:white;
  padding:10px;
}

td {
  padding:10px;
  border-bottom:1px solid #eee;
}

.pass { color:green; font-weight:bold; }
.fail { color:red; font-weight:bold; }

small { color:#666; }

</style>
</head>

<body>

<h1>Test Dashboard</h1>

<div class="card">
  <p><b>Total:</b> $TOTAL</p>
  <p><b>Passed:</b> $PASS</p>
  <p><b>Failed:</b> $FAIL</p>
  <p><b>Pass Rate:</b> $RATE%</p>
</div>

<table>
<tr>
<th>Test</th>
<th>Status</th>
<th>Message</th>
</tr>
EOF

while read -r line; do
  name=$(echo "$line" | jq -r '.test')
  status=$(echo "$line" | jq -r '.status')
  msg=$(echo "$line" | jq -r '.msg')

  class="fail"
  [ "$status" = "PASS" ] && class="pass"

  echo "<tr><td>$name</td><td class='$class'>$status</td><td><small>$msg</small></td></tr>" >> "$OUTPUT"

done < <(grep '{' "$INPUT")

cat >> "$OUTPUT" <<EOF
</table>

</body>
</html>
EOF
