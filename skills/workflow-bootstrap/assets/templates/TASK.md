---
id: T-xxx
title: <tên ngắn>
milestone: M-nn
status: READY
risk: low
depends_on: [T-yyy]
files_allowed:
  - src/module/file.ext
  - tests/module/file_test.ext
---
# T-xxx: <tên>
Mục tiêu: <1-2 câu>
Hợp đồng: <interface phải giữ hoặc phải tạo, kèm chữ ký, kiểu, mã lỗi>
Ràng buộc: <quy ước, thư viện được hoặc không được dùng>
Tiêu chí nghiệm thu:
- AC-1: <mô tả> | CMD: <lệnh> | EXPECT: <kết quả định lượng>
- AC-2: <mô tả> | CMD: <lệnh> | EXPECT: <kết quả định lượng>
Ngoài phạm vi: <việc KHÔNG làm>
Kết thúc: ghi docs/reports/T-xxx.md bằng report-writer
