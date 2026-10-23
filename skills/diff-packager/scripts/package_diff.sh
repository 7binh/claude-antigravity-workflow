#!/usr/bin/env bash
# package_diff.sh <file> [base_ref] [max_lines] [START,END]
# Che các mẫu secret phổ biến (perl nếu có, nếu không thì GNU sed).
# Che secret là best-effort: luôn tự đọc lại trước khi dán.
set -u
FILE="${1:?Cách dùng: package_diff.sh <file> [base_ref] [max_lines] [START,END]}"
BASE="${2:-HEAD}"; MAX="${3:-40}"; RANGE="${4:-}"
git rev-parse --git-dir >/dev/null 2>&1 || { echo "ERROR: không phải git repo"; exit 2; }

RAW=$(git diff -U3 --ignore-all-space --ignore-blank-lines "$BASE" -- "$FILE" | grep -v -E '^(index |diff --git)' || true)

if [ -n "$RANGE" ] && [ -n "$RAW" ]; then
  RAW=$(printf '%s\n' "$RAW" | awk -v rng="$RANGE" '
    BEGIN { split(rng, r, ","); s = r[1] + 0; e = (r[2] == "" ? r[1] : r[2]) + 0; keep = 1; hdr = 1 }
    /^@@/ {
      hdr = 0
      match($0, /\+[0-9]+(,[0-9]+)?/)
      t = substr($0, RSTART + 1, RLENGTH - 1)
      n = split(t, p, ",")
      c = p[1] + 0; d = (n > 1) ? p[2] + 0 : 1
      last = (d > 0) ? c + d - 1 : c
      keep = (c <= e && last >= s)
    }
    hdr || keep { print }')
fi

redact() {
  if command -v perl >/dev/null 2>&1; then
    perl -pe '
      s/\bbearer\s+[A-Za-z0-9._~+\/=-]+/Bearer ***REDACTED***/gi;
      s/\b(api[_-]?key|secret|token|password|passwd|authorization)(["\x27]?\s*[=:]\s*["\x27]?)[^\s,;"\x27]+/$1$2***REDACTED***/gi;
      s/\b(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16})\b/***REDACTED***/g;
      s/-----BEGIN [A-Z ]*PRIVATE KEY-----.*/-----BEGIN PRIVATE KEY----- ***REDACTED***/g;
    '
  else
    sed -E \
      -e 's/[Bb][Ee][Aa][Rr][Ee][Rr][[:space:]]+[A-Za-z0-9._~+\/=-]+/Bearer ***REDACTED***/g' \
      -e "s/(api[_-]?key|secret|token|password|passwd|authorization)([\"']?[[:space:]]*[=:][[:space:]]*[\"']?)[^[:space:],;\"']+/\1\2***REDACTED***/Ig" \
      -e 's/(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16})/***REDACTED***/g'
  fi
}

echo "# diff: $FILE (so với $BASE)${RANGE:+ dòng $RANGE}"
if [ -z "$RAW" ]; then
  echo "# (không có thay đổi trong phạm vi được yêu cầu)"
  exit 0
fi
OUT=$(printf '%s\n' "$RAW" | redact)
TOTAL=$(printf '%s\n' "$OUT" | wc -l | tr -d ' ')
printf '%s\n' "$OUT" | head -n "$MAX"
[ "$TOTAL" -gt "$MAX" ] && echo "# CẮT: còn $((TOTAL-MAX)) dòng nữa. Chỉ định dải dòng hẹp hơn."
exit 0
