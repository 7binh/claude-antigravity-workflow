---
name: diff-packager
description: Trích đúng đoạn diff mà kiến trúc sư yêu cầu (một file, một hàm hoặc dải dòng), tối đa 40 dòng, bỏ nhiễu khoảng trắng và che secret, để người dùng dán vào chat Claude. Dùng khi nhận verdict NEED-DIFF hoặc khi người dùng cần gửi diff cho Claude. Không dùng để gửi toàn bộ diff của task.
---

# Diff Packager

## Mục tiêu
Thay vì cắt diff bằng tay (dễ dán thừa hoặc lộ secret), script in đúng một file, bỏ nhiễu khoảng trắng, che các mẫu secret phổ biến và cắt ở 40 dòng.

## Quy ước đường dẫn
`<SKILL_DIR>` là thư mục chứa SKILL.md này. Chạy từ thư mục gốc repo.

## Đầu vào
Tên file (và hàm hoặc dải dòng) do kiến trúc sư chỉ định; commit cơ sở của task.

## Các bước
1. Chạy: `bash <SKILL_DIR>/scripts/package_diff.sh <file> [base_ref] [max_lines] [START,END]`
   START,END là dải dòng trong file mới; chỉ giữ các hunk giao với dải đó.
2. Nếu đầu ra báo CẮT, thu hẹp bằng dải dòng được yêu cầu thay vì tăng max_lines.
3. Đọc lại đầu ra, xác nhận không còn secret hay dữ liệu cá nhân. Việc che secret là best-effort, không thay cho việc người dùng tự nhìn lại trước khi dán.
4. In khối diff kèm một dòng tiêu đề file:dòng.

## Điều kiện dừng
Có khối diff không quá 40 dòng cho đúng phần được yêu cầu.

## Ràng buộc
- Mỗi lần chỉ một file hoặc một phần được chỉ định.
- Không thêm bình luận hay giải thích vào diff.
- Không tăng max_lines quá 40 trừ khi người dùng yêu cầu rõ.

## Đầu ra
Khối diff đã che secret, kèm tiêu đề `# diff: <file> (so với <base>)`.
