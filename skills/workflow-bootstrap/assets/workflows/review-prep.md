---
description: Đóng gói gói duyệt để dán cho Claude (báo cáo, kiểm chứng độc lập, phạm vi)
---
Chạy trong một phiên mới (không phải phiên đã thi công) hoặc chạy hai script trực tiếp ở terminal.
1. Hỏi mã task nếu người dùng chưa nêu.
// turbo
2. Chạy bash .agents/skills/test-and-summarize/scripts/verify_task.sh docs/tasks/T-xxx.md
// turbo
3. Chạy bash .agents/skills/scope-guard/scripts/check_scope.sh docs/tasks/T-xxx.md rồi git diff --stat
4. Ghi .agents/.logs/packet_T-xxx.md gồm 4 phần theo thứ tự: nội dung docs/reports/T-xxx.md; đầu ra bước 2; đầu ra bước 3; danh sách chỗ báo cáo khác với kết quả thật (nếu có).
5. Dừng. In đường dẫn file gói duyệt. Không sửa báo cáo.
