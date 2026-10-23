---
name: task-preflight
description: Kiểm tra một task đã đặc tả có đạt Definition of Ready trước khi viết code, và ghi baseline test hiện tại. Dùng ngay khi nhận task T-xxx, trước task-executor, hoặc khi người dùng nói kiểm tra task trước khi làm. Không dùng để thi công hay sửa đặc tả.
---

# Task Preflight

## Mục tiêu
Chặn sớm task thiếu điều kiện, để không tốn một phiên thi công vào đặc tả hỏng.

## Đầu vào
Mã task T-xxx; docs/tasks/T-xxx.md; docs/PLAN.md.

## Các bước
1. Đọc front matter và thân của docs/tasks/T-xxx.md.
2. Kiểm từng mục, ghi PASS hoặc FAIL kèm một dòng lý do:
   a. status là READY.
   b. Mọi task trong depends_on có trạng thái DONE trong PLAN.md.
   c. files_allowed không rỗng, không quá 7 mục; mỗi file tồn tại hoặc được ghi "tạo mới".
   d. Mục Hợp đồng có chữ ký đầy đủ.
   e. Mọi AC có CMD và EXPECT; không AC nào chỉ ghi "hoạt động đúng".
   f. Có mục Ngoài phạm vi.
   g. Đặc tả không quá 40 dòng; có trường risk.
   h. git status --short rỗng; đang ở nhánh task/T-xxx-*.
3. Chạy baseline: chạy test của dự án (hoặc nhóm test liên quan) bằng test-and-summarize. Ghi số pass/fail hiện có. Test đã đỏ từ trước phải được ghi lại.
4. Chạy thử từng CMD của AC. Chấp nhận kết quả đỏ nếu lý do là chưa cài đặt. Không chấp nhận nếu lệnh không tồn tại hoặc sai cú pháp.

## Điều kiện dừng
Bất kỳ mục nào ở bước 2 FAIL, hoặc lệnh ở bước 4 không chạy được: kết luận NOT_READY và dừng. Không sửa đặc tả, không bắt đầu code.

## Ràng buộc
- Chỉ đọc và chạy lệnh. Không sửa file nào.

## Đầu ra
In đúng một khối:

```
PREFLIGHT T-xxx: READY | NOT_READY
Lỗi (mỗi dòng một lỗi, ghi mã mục a-h):
Baseline: <N pass, M fail có sẵn, lệnh đã chạy>
```
