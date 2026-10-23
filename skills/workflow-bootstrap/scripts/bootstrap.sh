#!/usr/bin/env bash
# bootstrap.sh [thư_mục_đích] [--dry-run] [--force]
# Đặt bộ khung quy trình vào dự án. Không ghi đè file đã có trừ khi có --force.
# AGENTS.md đã có thì ghi AGENTS.proposed.md để bạn gộp tay.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$HERE/../assets"
TARGET="."; DRY=0; FORCE=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,4p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *)         TARGET="$a" ;;
  esac
done
[ -d "$ASSETS" ] || { echo "ERROR: không thấy thư mục assets: $ASSETS"; exit 2; }
[ -d "$TARGET" ] || { echo "ERROR: thư mục đích không tồn tại: $TARGET"; exit 2; }

CREATED=0; SKIPPED=0
put() { # put <nguồn> <đích tương đối>
  local src="$1" rel="$2" dst="$TARGET/$2"
  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    echo "BỎ QUA (đã có): $rel"; SKIPPED=$((SKIPPED+1)); return
  fi
  echo "TẠO: $rel"; CREATED=$((CREATED+1))
  [ "$DRY" -eq 1 ] && return
  mkdir -p "$(dirname "$dst")" && cp "$src" "$dst"
}

# AGENTS.md: không ghi đè
if [ -e "$TARGET/AGENTS.md" ] && [ "$FORCE" -eq 0 ]; then
  echo "AGENTS.md đã có -> ghi AGENTS.proposed.md để gộp tay"
  put "$ASSETS/AGENTS.md" "AGENTS.proposed.md"
else
  put "$ASSETS/AGENTS.md" "AGENTS.md"
fi

for f in "$ASSETS"/workflows/*.md;   do put "$f" ".agents/workflows/$(basename "$f")"; done
for f in "$ASSETS"/templates/*.md;   do put "$f" "docs/templates/$(basename "$f")"; done
for f in "$ASSETS"/docs/*.md;        do put "$f" "docs/$(basename "$f")"; done
for f in "$ASSETS"/claude-side/*.md; do put "$f" "docs/claude-side/$(basename "$f")"; done

for d in docs/tasks docs/reports docs/archive .agents/.logs; do
  if [ ! -d "$TARGET/$d" ]; then
    echo "TẠO THƯ MỤC: $d"
    [ "$DRY" -eq 0 ] && mkdir -p "$TARGET/$d" && { [ "$d" = ".agents/.logs" ] || : > "$TARGET/$d/.gitkeep"; }
  fi
done

# .gitignore: thêm .agents/.logs/ nếu chưa có
if ! grep -qxF '.agents/.logs/' "$TARGET/.gitignore" 2>/dev/null; then
  echo "THÊM vào .gitignore: .agents/.logs/"
  [ "$DRY" -eq 0 ] && printf '\n# Claude x Antigravity workflow\n.agents/.logs/\n' >> "$TARGET/.gitignore"
fi

echo "---"
[ "$DRY" -eq 1 ] && echo "(dry-run: chưa ghi gì)"
echo "Tạo: $CREATED file, bỏ qua: $SKIPPED file"
echo "Việc tiếp theo: điền các chỗ <điền> trong AGENTS.md; dán docs/claude-side/PROJECT_INSTRUCTIONS.md vào Claude Project."
