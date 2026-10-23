---
description: Đóng milestone, chạy kiểm tra cuối, digest cuối và chuẩn bị lưu trữ
---
1. Đọc docs/PLAN.md, liệt kê task của milestone chưa DONE. Còn task thì dừng và in danh sách.
// turbo
2. Chạy toàn bộ test của dự án bằng skill test-and-summarize. Fail thì dừng.
3. Dùng skill repo-digest để cập nhật docs/DIGEST.md.
4. Đếm số mục trong docs/DECISIONS.md; in số lượng và các mục thuộc milestone này. Không sửa file.
5. In danh sách file cần chuyển vào docs/archive/M-nn/ (tasks và reports của milestone). Không tự di chuyển; chờ người dùng xác nhận.
6. Nhắc người dùng tạo tag git milestone-M-nn sau khi merge.
