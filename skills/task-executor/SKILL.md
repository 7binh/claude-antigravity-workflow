---
name: task-executor
description: Thi công đúng một task đã đặc tả trong docs/tasks/T-xxx.md theo thứ tự preflight, test-first, cài đặt, kiểm tra phạm vi, tự rà soát, báo cáo, rồi dừng. Dùng khi người dùng nói làm task T-xxx, chạy task, hoặc dán prompt thi công. Không dùng khi chưa có file task hoặc khi chỉ cần sửa một lỗi nhỏ ngoài kế hoạch.
---

# Task Executor

## Mục tiêu
Điều phối thi công đúng một task, đúng phạm vi, dừng đúng chỗ. Skill này không tự chứa chi tiết các bước con: nó gọi lần lượt các skill khác.

## Đầu vào
docs/tasks/T-xxx.md; các mục liên quan trong docs/ARCHITECTURE.md và docs/DECISIONS.md. Không đọc thêm.

## Các bước
1. Gọi skill task-preflight. NOT_READY thì in kết quả và dừng.
2. Lập kế hoạch tối đa 8 dòng: các bước nhỏ và file sẽ sửa ở mỗi bước. File nào ngoài files_allowed thì áp dụng bảng Điều kiện dừng.
3. Gọi skill test-first: biến AC thành test, xác nhận test đỏ đúng lý do.
4. Cài đặt từng bước nhỏ. Sau mỗi bước chạy test liên quan bằng test-and-summarize. Đếm số vòng sửa cho từng lỗi.
5. Khi test của task pass, chạy nhóm test bị ảnh hưởng để so với baseline và phát hiện hồi quy.
6. Gọi skill scope-guard. Nếu VI_PHAM: hoàn tác phần ngoài phạm vi hoặc dừng và hỏi.
7. Gọi skill self-review.
8. Chạy git diff --stat và giữ nguyên kết quả cho báo cáo.
9. Gọi skill report-writer. Kết thúc. Không commit, không bắt đầu task khác.

## Điều kiện dừng (ghi vào Câu hỏi mở, không tự quyết)

| Tình huống | Hành động |
| --- | --- |
| Cần sửa file ngoài files_allowed | Dừng, nêu file và lý do |
| Cần đổi interface ngoài mục Hợp đồng | Dừng |
| Đặc tả mâu thuẫn ARCHITECTURE hoặc DECISIONS | Dừng |
| Cần dependency mới | Dừng |
| Test đỏ có sẵn trong baseline và chặn task | Dừng, báo BLOCKED |
| Cùng một lỗi sau 3 vòng sửa | Dừng, báo BLOCKED, chạy bug-brief |

## Ràng buộc
- Không mở rộng phạm vi, không refactor tiện tay, không đổi định dạng file không liên quan.
- Không sửa, xoá hay skip test có sẵn để làm nó pass. Nghĩ test sai thì nêu trong báo cáo.
- Cấm các cách làm cho pass giả: try/catch rỗng nuốt lỗi, hardcode giá trị kỳ vọng của test, tắt lint, ghi đè kết quả test.
- Không ghi "pass" nếu chưa chạy lệnh trong phiên này.
- Không git commit, merge, push.

## Đầu ra
docs/reports/T-xxx.md (qua report-writer). Trạng thái cuối là DONE, PARTIAL hoặc BLOCKED.
