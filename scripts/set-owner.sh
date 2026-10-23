#!/usr/bin/env bash
# set-owner.sh <github-user-hoặc-org>
# Thay chữ OWNER trong README.md và docs/ bằng tên GitHub của bạn.
set -eu
OWNER="${1:?Cách dùng: set-owner.sh <github-user-hoặc-org>}"
case "$OWNER" in *[!A-Za-z0-9-]*|"") echo "Tên không hợp lệ: $OWNER"; exit 2 ;; esac
cd "$(dirname "${BASH_SOURCE[0]}")/.."
FILES=$(grep -rl 'OWNER/claude-antigravity-workflow' README.md docs --include='*.md' || true)
[ -n "$FILES" ] || { echo "Không còn chỗ nào cần thay."; exit 0; }
for f in $FILES; do
  sed "s#OWNER/claude-antigravity-workflow#${OWNER}/claude-antigravity-workflow#g" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  echo "đã cập nhật $f"
done
echo "Xong. Kiểm tra: git diff"
