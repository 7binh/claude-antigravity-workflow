---
description: Thi công trọn một task từ docs/tasks và ghi báo cáo
---
1. Hỏi mã task nếu người dùng chưa nêu (ví dụ T-007).
2. Xác nhận đang ở nhánh task/T-xxx-*. Nếu không, dừng và nhắc người dùng tạo nhánh.
3. Dùng skill task-executor (gồm preflight, test-first, cài đặt, scope-guard, self-review, report-writer).
// turbo
4. Chạy git diff --stat rồi đối chiếu với mục Phạm vi trong báo cáo.
5. Dừng. Không commit, không push, không làm task khác.
