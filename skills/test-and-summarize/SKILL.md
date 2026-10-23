---
name: test-and-summarize
description: Chạy lệnh test, lint hoặc build của dự án và chỉ trả về tóm tắt gọn (mã thoát, dòng lỗi, phần cuối log), hoặc chạy toàn bộ lệnh nghiệm thu của một task. Dùng mỗi khi cần chạy test trong lúc thi công, trước khi báo cáo, hoặc khi người dùng yêu cầu kiểm chứng task. Không dùng để viết hay sửa test.
---

# Test and Summarize

## Mục tiêu
Log đầy đủ nằm trên đĩa; hội thoại chỉ nhận tóm tắt. Báo cáo là lời khai, lệnh chạy là bằng chứng.

## Quy ước đường dẫn
`<SKILL_DIR>` là thư mục chứa SKILL.md này. Luôn chạy script từ thư mục gốc repo của dự án (log ghi vào .agents/.logs/). Script cần bash (Linux, macOS, Git Bash hoặc WSL).

## Các bước
1. Chạy một lệnh: `bash <SKILL_DIR>/scripts/run_tests.sh -- <lệnh>`
   Có thể thêm `--timeout <giây>` trước dấu `--` (mặc định 900).
2. Chạy toàn bộ AC của task: `bash <SKILL_DIR>/scripts/verify_task.sh docs/tasks/T-xxx.md`
   Script đọc các dòng `- AC-n: ... | CMD: ... | EXPECT: ...`, chạy từng CMD và in một dòng cho mỗi AC. Chỉ kiểm mã thoát; cột EXPECT để đối chiếu bằng mắt. CMD không được chứa dấu `|`; cần pipe thì gói vào một script riêng.
3. Chỉ đọc phần tóm tắt script in ra. Không dán toàn bộ log vào hội thoại hay báo cáo.
4. Nếu fail: nêu tên test fail và tối đa 30 dòng liên quan. Nếu cần thêm, mở log_file bằng grep hoặc tail, đừng cat.

## Điều kiện dừng
Có exit_code và dòng tổng kết. Không chạy lại vô tận: cùng một lệnh, cùng một lỗi, tối đa 3 vòng sửa.

## Ràng buộc
- Không dùng kết quả cũ thay cho lần chạy mới.
- Khi báo cáo, ghi nguyên lệnh và exit_code.
- Không sửa script để làm kết quả đẹp hơn.

## Đầu ra
Dòng `exit_code=... log_file=...` cùng phần tóm tắt; với verify_task là bảng AC kèm dòng `TỔNG`.
