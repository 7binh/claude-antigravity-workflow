---
name: workflow-bootstrap
description: Khởi tạo bộ khung quy trình Claude x Antigravity trong dự án hiện tại, gồm AGENTS.md, .agents/workflows/, docs/templates/, docs/PLAN.md, docs/DECISIONS.md và bộ prompt phía Claude. Dùng khi người dùng vừa cài bộ skill này, nói thiết lập quy trình, khởi tạo workflow, setup dự án lớn, hoặc thiếu docs/tasks và .agents/workflows. Không dùng để thi công task hay viết đặc tả task.
---

# Workflow Bootstrap

## Mục tiêu
`npx skills add` chỉ cài thư mục skill, không cài AGENTS.md, workflows hay mẫu tài liệu. Skill này đặt các phần còn lại vào dự án, không ghi đè thứ đã có.

## Quy ước đường dẫn
`<SKILL_DIR>` là thư mục chứa SKILL.md này. Chạy từ thư mục gốc repo của dự án. Cần bash (Linux, macOS, Git Bash hoặc WSL).

## Đầu vào
Thư mục gốc dự án (mặc định là thư mục hiện tại).

## Các bước
1. Chạy thử không ghi: `bash <SKILL_DIR>/scripts/bootstrap.sh . --dry-run`
2. Đọc danh sách TẠO / BỎ QUA. Nếu hợp lý, chạy thật: `bash <SKILL_DIR>/scripts/bootstrap.sh .`
3. Nếu AGENTS.md đã tồn tại, script ghi AGENTS.proposed.md thay vì ghi đè. Gộp tay các mục còn thiếu rồi xoá file proposed.
4. Mở AGENTS.md, điền các chỗ `<điền>`: tên dự án, lệnh cài, build, test, lint, framework test. Hỏi người dùng nếu chưa biết.
5. Kiểm tra skill có nạp: hỏi "What skills are available?". Nếu thiếu, thử thư mục `.agent/skills/` hoặc `~/.gemini/antigravity/skills/`.
6. Nhắc người dùng commit phần khung vừa tạo (AGENTS.md, .agents/, docs/) trước khi giao task đầu tiên: preflight yêu cầu git status sạch và scope-guard coi file chưa commit là thay đổi. Không tự commit.
7. In danh sách bước tiếp theo cho người dùng (xem Đầu ra).

## Điều kiện dừng
Script báo xong và AGENTS.md không còn chỗ `<điền>` nào bỏ trống mà người dùng đã biết giá trị. Không tự tạo task hay chạy workflow khác.

## Ràng buộc
- Không ghi đè file đã có. Chỉ dùng `--force` khi người dùng yêu cầu rõ.
- Không sửa nội dung mẫu để "cải tiến" quy trình.
- Workflows gọi script theo đường dẫn `.agents/skills/...`, nên bộ skill phải cài ở phạm vi dự án (không dùng `-g`).

## Đầu ra
Dự án có AGENTS.md, .agents/workflows/ (6 file), docs/templates/ (TASK, REPORT, DECISION, VERDICT), docs/ARCHITECTURE.md, docs/PLAN.md, docs/DECISIONS.md, docs/claude-side/ và dòng `.agents/.logs/` trong .gitignore. Bước tiếp theo cho người dùng:
1. Dán docs/claude-side/PROJECT_INSTRUCTIONS.md vào Project instructions trên Claude.
2. Chạy /digest, gửi docs/DIGEST.md cho Claude, rồi dùng prompt mở milestone trong docs/claude-side/PROMPTS.md.
3. Lưu task Claude viết vào docs/tasks/ rồi chạy /preflight và /run-task.
