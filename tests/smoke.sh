#!/usr/bin/env bash
# smoke.sh — chạy thử các script trong một repo git tạm. Cần bash, git.
# Chạy: bash tests/smoke.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$ROOT/skills"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "  ✓ $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  ✗ $1"; }
expect_code() { # expect_code <mong đợi> <thực tế> <tên>
  if [ "$1" = "$2" ]; then ok "$3 (exit $2)"; else bad "$3: mong đợi exit $1, thực tế $2"; fi
}
expect_grep() { # expect_grep <regex> <văn bản> <tên>
  if printf '%s' "$2" | grep -qE "$1"; then ok "$3"; else bad "$3: không thấy /$1/ trong: $(printf '%s' "$2" | head -3)"; fi
}

cd "$TMP" && git init -q -b main . && git config user.email t@t && git config user.name t
mkdir -p src tests docs/tasks docs/reports
printf 'a = 1\n' > src/a.txt
printf 'def test_AC1_ok():\n    assert 1 == 1\n    assert 2 == 2\n' > tests/a_test.py
printf 'x\n' > other.txt
# task có CRLF để kiểm tra xử lý Windows
printf -- '---\r\nid: T-001\r\nstatus: READY\r\nrisk: low\r\nfiles_allowed:\r\n  - src/a.txt\r\n  - tests/\r\n---\r\n# T-001\r\nTiêu chí nghiệm thu:\r\n- AC-1: chạy được | CMD: echo hello | EXPECT: exit 0\r\n- AC-2: lệnh lỗi | CMD: exit 3 | EXPECT: exit 0\r\n- AC-3: thủ công, không có CMD\r\n' > docs/tasks/T-001.md
git add -A && git commit -qm init

echo "check_scope.sh"
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 0 $? "không đổi gì -> CLEAN"
printf 'a = 2\n' > src/a.txt
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 0 $? "sửa file được phép -> CLEAN"
printf 'y\n' >> other.txt
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 1 $? "sửa file ngoài phạm vi -> VI_PHAM"
expect_grep 'other.txt' "$out" "liệt kê other.txt"
git checkout -q -- other.txt
printf 'out\n' > docs/reports/T-001.md
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 0 $? "báo cáo của chính task được phép"
rm docs/reports/T-001.md
printf 'import sys\ndef test_AC1_ok():\n    sys.exit(0)\n    assert 1 == 1\n' > tests/a_test.py
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); code=$?
expect_code 3 $code "giảm assertion -> cảnh báo"; expect_grep 'assertion giảm' "$out" "báo số assertion giảm"
printf 'import pytest\n@pytest.mark.skip\ndef test_AC1_ok():\n    assert 1 == 1\n    assert 2 == 2\n' > tests/a_test.py
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 3 $? "pytest skip -> cảnh báo"
printf 'function f(){ process.exit(0) }\n' > tests/b.test.js
git checkout -q -- tests/a_test.py && git add -A && git commit -qm t2
printf 'function f(){ process.exit(1) }\n' > tests/b.test.js
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 0 $? "process.exit( không bị tính nhầm là xit("
git checkout -q -- tests/b.test.js
git rm -q tests/b.test.js
out=$(bash "$S/scope-guard/scripts/check_scope.sh" docs/tasks/T-001.md); expect_code 3 $? "xoá test -> cảnh báo"
git reset -q --hard
out=$(bash "$S/scope-guard/scripts/check_scope.sh" nope.md); expect_code 2 $? "thiếu file task -> lỗi đầu vào"

echo "verify_task.sh"
out=$(bash "$S/test-and-summarize/scripts/verify_task.sh" docs/tasks/T-001.md); code=$?
expect_code 1 $code "có AC fail -> exit 1"
expect_grep 'AC-1 \| exit=0' "$out" "AC-1 pass"
expect_grep 'AC-2 \| exit=3' "$out" "AC-2 fail với exit=3"
expect_grep 'AC-3 \| MANUAL' "$out" "AC-3 là MANUAL"
expect_grep 'TỔNG: 3 AC, 1 AC' "$out" "dòng TỔNG đúng"
printf -- '---\nid: T-002\n---\nkhông có AC\n' > docs/tasks/T-002.md
out=$(bash "$S/test-and-summarize/scripts/verify_task.sh" docs/tasks/T-002.md); expect_code 2 $? "task không có AC -> lỗi đầu vào"

echo "run_tests.sh"
out=$(bash "$S/test-and-summarize/scripts/run_tests.sh" -- 'echo "3 passed"; exit 0'); expect_code 0 $? "lệnh thành công"
expect_grep 'exit_code=0' "$out" "in exit_code"; expect_grep '3 passed' "$out" "trích dòng tổng kết"
out=$(bash "$S/test-and-summarize/scripts/run_tests.sh" -- 'echo "Error: boom"; exit 5'); expect_code 5 $? "giữ nguyên mã thoát của lệnh"
[ -d .agents/.logs ] && ok "tạo .agents/.logs" || bad "không tạo .agents/.logs"

echo "package_diff.sh"
git reset -q --hard; git clean -qfd
printf 'line1\nline2\nline3\nline4\nline5\nline6\nline7\nline8\nline9\nline10\n' > src/long.txt
git add -A && git commit -qm base
printf 'line1\nline2 changed\nline3\nline4\nline5\nline6\nline7\nline8\nline9\nline10 token = abcdef123\n' > src/long.txt
printf 'Authorization: Bearer abc.def.ghi\n"password": "hunter2"\n' >> src/long.txt
out=$(bash "$S/diff-packager/scripts/package_diff.sh" src/long.txt); expect_code 0 $? "chạy được"
expect_grep 'REDACTED' "$out" "che secret"
if printf '%s' "$out" | grep -qE 'abcdef123|abc\.def\.ghi|hunter2'; then bad "còn lộ secret"; else ok "không còn lộ secret"; fi
out=$(bash "$S/diff-packager/scripts/package_diff.sh" src/long.txt HEAD 5); expect_grep 'CẮT' "$out" "cắt khi vượt max_lines"
out=$(bash "$S/diff-packager/scripts/package_diff.sh" src/long.txt HEAD 40 1,3)
expect_grep 'line2 changed' "$out" "dải 1,3 giữ hunk đầu"
if printf '%s' "$out" | grep -q 'line10'; then bad "dải 1,3 vẫn chứa hunk ở dòng 10"; else ok "dải 1,3 loại hunk ở dòng 10"; fi
out=$(bash "$S/diff-packager/scripts/package_diff.sh" src/long.txt HEAD 40 10,12)
expect_grep 'line10' "$out" "dải 10,12 giữ hunk cuối"
if printf '%s' "$out" | grep -q 'line2 changed'; then bad "dải 10,12 vẫn chứa hunk đầu"; else ok "dải 10,12 loại hunk đầu"; fi
# nhánh dự phòng khi không có perl: tạo PATH chỉ chứa các lệnh cần thiết, không có perl
NP="$TMP/noperl"; mkdir -p "$NP"
for c in bash git sed grep awk head tail wc tr cat mktemp date mkdir cp rm printf dirname basename sort paste; do p=$(command -v $c) && ln -sf "$p" "$NP/$c"; done
out=$(PATH="$NP" bash "$S/diff-packager/scripts/package_diff.sh" src/long.txt); expect_code 0 $? "chạy không có perl (dùng sed)"
expect_grep 'REDACTED' "$out" "sed fallback che secret"
if printf '%s' "$out" | grep -qE 'abcdef123|abc\.def\.ghi|hunter2'; then bad "sed fallback còn lộ secret"; else ok "sed fallback không lộ secret"; fi

echo "bootstrap.sh"
B="$TMP/proj"; mkdir -p "$B"
out=$(bash "$S/workflow-bootstrap/scripts/bootstrap.sh" "$B" --dry-run); expect_code 0 $? "dry-run"
[ ! -e "$B/AGENTS.md" ] && ok "dry-run không ghi file" || bad "dry-run đã ghi file"
out=$(bash "$S/workflow-bootstrap/scripts/bootstrap.sh" "$B"); expect_code 0 $? "chạy thật"
for f in AGENTS.md .agents/workflows/run-task.md docs/templates/TASK.md docs/templates/REPORT.md docs/PLAN.md docs/DECISIONS.md docs/claude-side/PROMPTS.md docs/tasks/.gitkeep; do
  [ -e "$B/$f" ] && ok "có $f" || bad "thiếu $f"
done
grep -qxF '.agents/.logs/' "$B/.gitignore" && ok ".gitignore có .agents/.logs/" || bad ".gitignore thiếu dòng"
printf 'custom\n' > "$B/docs/PLAN.md"
out=$(bash "$S/workflow-bootstrap/scripts/bootstrap.sh" "$B"); expect_code 0 $? "chạy lại (idempotent)"
[ "$(cat "$B/docs/PLAN.md")" = "custom" ] && ok "không ghi đè file đã sửa" || bad "đã ghi đè PLAN.md"
[ -e "$B/AGENTS.proposed.md" ] && ok "AGENTS.md đã có -> ghi AGENTS.proposed.md" || bad "thiếu AGENTS.proposed.md"
[ "$(grep -c '.agents/.logs/' "$B/.gitignore")" = "1" ] && ok ".gitignore không bị thêm trùng" || bad ".gitignore bị thêm trùng"

echo; echo "Kết quả: $PASS đạt, $FAIL lỗi"
[ "$FAIL" -eq 0 ]
