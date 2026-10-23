#!/usr/bin/env bash
# run_tests.sh [--timeout GIÂY] -- <lệnh...>
# Chạy lệnh, lưu log đầy đủ ra file, chỉ in tóm tắt. Trả về mã thoát của lệnh.
# Chạy từ thư mục gốc repo; log nằm ở .agents/.logs/.
set -u
TIMEOUT=900
if [ "${1:-}" = "--timeout" ]; then TIMEOUT="${2:?thiếu số giây}"; shift 2; fi
[ "${1:-}" = "--" ] && shift
[ $# -gt 0 ] || { echo "Cách dùng: run_tests.sh [--timeout S] -- <lệnh>"; exit 2; }

mkdir -p .agents/.logs
LOG=".agents/.logs/run_$(date +%Y%m%d_%H%M%S)_$$.log"
START=$(date +%s)
if command -v timeout >/dev/null 2>&1; then
  timeout "$TIMEOUT" bash -c "$*" >"$LOG" 2>&1
else
  bash -c "$*" >"$LOG" 2>&1
fi
CODE=$?
DUR=$(( $(date +%s) - START ))

echo "cmd=$*"
echo "exit_code=$CODE duration_s=$DUR log_file=$LOG"
[ "$CODE" -eq 124 ] && echo "TIMEOUT sau ${TIMEOUT}s"
echo "--- dòng tổng kết ---"
grep -E -i '[0-9]+ (passed|failed)|Tests:|Test Suites:|^ok |^FAIL' "$LOG" | tail -5
echo "--- dòng lỗi (tối đa 40) ---"
grep -n -E 'FAIL|ERROR|Error:|AssertionError|panic|Traceback' "$LOG" | head -40
echo "--- 15 dòng cuối ---"
tail -15 "$LOG"
exit "$CODE"
