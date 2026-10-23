#!/usr/bin/env bash
# verify_task.sh <docs/tasks/T-xxx.md>
# Dòng AC trong task:  - AC-1: <mô tả> | CMD: <lệnh> | EXPECT: <kỳ vọng>
# Script chỉ kiểm mã thoát (0 = đạt). Cột EXPECT để bạn đối chiếu bằng mắt.
# CMD không được chứa dấu |; cần pipe thì gói vào một script riêng.
# Mã thoát: 0 mọi AC có CMD đều exit 0 | 1 có AC fail | 2 lỗi đầu vào
set -u
TASK="${1:?Cách dùng: verify_task.sh docs/tasks/T-xxx.md}"
[ -f "$TASK" ] || { echo "ERROR: không thấy file task: $TASK"; exit 2; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RE_AC='^[[:space:]]*-[[:space:]]*(AC-[0-9]+):'
RE_CMD='[|] CMD: (.*) [|] EXPECT: (.*)$'
FAILS=0; TOTAL=0
while IFS= read -r line; do
  line="${line%$'\r'}"   # file task lưu CRLF trên Windows
  [[ $line =~ $RE_AC ]] && AC="${BASH_REMATCH[1]}" || continue
  TOTAL=$((TOTAL+1))
  if [[ $line =~ $RE_CMD ]]; then
    CMD="${BASH_REMATCH[1]}"; EXP="${BASH_REMATCH[2]}"
  else
    echo "$AC | MANUAL (không có CMD), kiểm bằng tay"; continue
  fi
  OUT=$(bash "$HERE/run_tests.sh" -- "$CMD" 2>&1); CODE=$?
  SUM=$(echo "$OUT" | awk '/^--- dòng tổng kết/{f=1;next} /^---/{f=0} f' | tail -1)
  echo "$AC | exit=$CODE | kỳ vọng: $EXP | thực tế: ${SUM:-không có dòng tổng kết}"
  [ "$CODE" -ne 0 ] && FAILS=$((FAILS+1))
done < <(grep -E "$RE_AC" "$TASK")
if [ "$TOTAL" -eq 0 ]; then echo "ERROR: không tìm thấy dòng AC-n nào trong $TASK"; exit 2; fi
echo "TỔNG: $TOTAL AC, $FAILS AC có exit khác 0"
[ "$FAILS" -eq 0 ]
