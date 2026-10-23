#!/usr/bin/env bash
# check_scope.sh <docs/tasks/T-xxx.md> [base_ref]
# Mã thoát: 0 CLEAN | 1 VI_PHAM | 2 lỗi đầu vào | 3 CLEAN có cảnh báo
# Quy ước trong front matter: mục trỏ tới thư mục kết thúc bằng /, còn lại là file chính xác.
# Không bọc đường dẫn trong dấu nháy.
set -u
TASK="${1:-}"; BASE="${2:-HEAD}"
[ -f "$TASK" ] || { echo "ERROR: không thấy file task: $TASK"; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: không phải git repo"; exit 2; }
ID=$(basename "$TASK" .md)

# tr -d '\r': file task có thể lưu CRLF trên Windows
ALLOWED=$(tr -d '\r' < "$TASK" | awk '
  /^---[[:space:]]*$/ { n++; next }
  n==1 && /^files_allowed:/ { f=1; next }
  n==1 && /^[A-Za-z_]+:/ { f=0 }
  n==1 && f && /^[[:space:]]*-[[:space:]]*/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); sub(/[[:space:]]+$/, ""); print }
')
[ -n "$ALLOWED" ] || { echo "ERROR: files_allowed rỗng hoặc thiếu"; exit 2; }
ALLOWED="$ALLOWED
docs/reports/$ID.md
.agents/.logs/"

CHANGED=$( { git diff --name-only "$BASE"; git ls-files --others --exclude-standard; } | sort -u )

BAD=(); WARN=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  ok=0
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    case "$a" in
      */) case "$f" in "$a"*) ok=1 ;; esac ;;
      *)  [ "$f" = "$a" ] && ok=1 ;;
    esac
  done <<< "$ALLOWED"
  [ "$ok" -eq 0 ] && BAD+=("$f")
done <<< "$CHANGED"

# Dấu hiệu làm yếu test
DEL=$(git diff --name-status "$BASE" | awk '$1=="D" {print $2}' | grep -Ei 'test|spec' || true)
[ -n "$DEL" ] && WARN+=("Test bị xoá: $(echo "$DEL" | paste -sd' ' -)")

TESTS=$(echo "$CHANGED" | grep -Ei 'test|spec' || true)
if [ -n "$TESTS" ]; then
  # Chỉ quét file test, và khớp theo ranh giới từ để `process.exit(` không bị tính nhầm là `xit(`
  SKIP=$(echo "$TESTS" | while IFS= read -r t; do
      [ -e "$t" ] || continue
      git diff -U0 "$BASE" -- "$t"
    done | grep -E '^[+][^+]' \
         | grep -E '[.]skip[(]|(^|[^[:alnum:]_])(xit|xdescribe|xtest)[(]|pytest[.]mark[.](skip|xfail)|t[.]Skip[(]|@Ignore|@Disabled|#\[ignore\]' || true)
  [ -n "$SKIP" ] && WARN+=("Có dòng thêm mới làm test bị skip/xfail: $(echo "$SKIP" | head -3 | paste -sd' ' -)")

  RM=0; AD=0
  while IFS= read -r t; do
    [ -e "$t" ] || continue
    r=$(git diff -U0 "$BASE" -- "$t" | grep -cE '^-[^-].*(assert|expect[(])' || true)
    a=$(git diff -U0 "$BASE" -- "$t" | grep -cE '^[+][^+].*(assert|expect[(])' || true)
    RM=$((RM + ${r:-0})); AD=$((AD + ${a:-0}))
  done <<< "$TESTS"
  [ "$RM" -gt "$AD" ] && WARN+=("Số assertion giảm trong test: -$RM +$AD")
fi

if [ "${#BAD[@]}" -gt 0 ]; then
  echo "SCOPE: VI_PHAM"
  echo "File ngoài phạm vi (files_allowed):"
  for f in "${BAD[@]}"; do echo "  - $f"; done
fi
if [ "${#WARN[@]}" -gt 0 ]; then
  for w in "${WARN[@]}"; do echo "[CANH_BAO] $w"; done
fi
[ "${#BAD[@]}" -gt 0 ] && exit 1
if [ "${#WARN[@]}" -gt 0 ]; then echo "SCOPE: CLEAN_CO_CANH_BAO"; exit 3; fi
echo "SCOPE: CLEAN"
