---
name: repo-digest
description: Tạo hoặc cập nhật docs/DIGEST.md (tối đa 150 dòng) mô tả cấu trúc repo, vai trò module, chữ ký public, phụ thuộc, lệnh build/test và vùng nóng, để gửi cho kiến trúc sư không thấy code. Dùng khi người dùng yêu cầu digest, tóm tắt repo, cập nhật bản đồ kiến trúc, hoặc khi mở hay đóng milestone. Không dùng để giải thích một đoạn code cụ thể.
---

# Repo Digest

## Mục tiêu
Sinh docs/DIGEST.md tối đa 150 dòng, đủ để người không thấy code hiểu cấu trúc và biết chỗ nào rủi ro.

## Đầu vào
Repo hiện tại. Nếu docs/DIGEST.md đã tồn tại, đọc dòng "Commit cơ sở" của nó.

## Các bước
1. Ghi tiêu đề: nhánh, commit ngắn (git rev-parse --short HEAD), ngày, và dòng "Commit cơ sở: <hash>".
2. Cây thư mục 2 cấp. Bỏ qua node_modules, dist, build, vendor, .git và file sinh tự động.
3. Bảng module: Module | Vai trò (1 dòng) | Public API (tên, chữ ký, kiểu) | Phụ thuộc | Test (có / một phần / không). Không dán thân hàm.
4. Phụ thuộc giữa module, dạng văn bản "A -> B", mỗi dòng một cặp. Không liệt kê thư viện ngoài (trừ thư viện lõi).
5. Lệnh build, test, lint: chạy thử bằng skill test-and-summarize, ghi trạng thái pass / fail / chưa chạy.
6. Vùng nóng: file trên 500 dòng; module không có test; số TODO/FIXME (đếm bằng grep); nợ kỹ thuật đã biết trong DECISIONS hoặc comment.
7. Biến môi trường và cấu hình: chỉ ghi tên, không ghi giá trị.
8. Nếu là cập nhật: chạy git diff --stat <commit cơ sở cũ>..HEAD, chỉ sửa mục của module đã đổi, thêm mục "Thay đổi từ digest trước" (tối đa 10 dòng).

## Điều kiện dừng
Dừng khi file đã ghi và không quá 150 dòng. Vượt thì cắt chi tiết module phụ, giữ bảng.

## Ràng buộc
- Không bịa. Chỗ chưa chắc ghi "chưa xác minh".
- Không đưa secret, giá trị trong .env, URL kèm token.
- Không viết lại toàn bộ khi chỉ cần cập nhật.

## Đầu ra
docs/DIGEST.md và 5 dòng tóm tắt: số module, mục đã đổi, mục chưa xác minh, vùng nóng nặng nhất, lệnh nào không chạy được.
