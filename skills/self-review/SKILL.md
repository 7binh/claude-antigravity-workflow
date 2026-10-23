---
name: self-review
description: Tự rà soát thay đổi của task theo checklist (đúng Hợp đồng, trường hợp biên, xử lý lỗi, bảo mật, hiệu năng, log và secret) rồi ghi kết quả PASS hoặc FLAGS cho báo cáo. Dùng sau khi test pass và scope-guard CLEAN, ngay trước report-writer. Không dùng để thêm tính năng và không thay thế việc duyệt của kiến trúc sư.
---

# Self Review

## Mục tiêu
Bắt lỗi mà test không bắt được (xử lý lỗi, bảo mật, rò rỉ log) trước khi bàn giao. Mỗi mục có mã để báo cáo và kiến trúc sư nhắc lại đúng một mã.

## Đầu vào
git diff của task; mục Hợp đồng và trường risk trong docs/tasks/T-xxx.md.

## Các bước
1. Đọc git diff của task. Không đọc lại toàn bộ file.
2. Chạy checklist chung. Mỗi mục trả lời OK, FLAG hoặc N/A; FLAG phải kèm file:dòng.
   - C1 Hành vi khớp từng dòng trong Hợp đồng (tên, chữ ký, kiểu trả về, mã lỗi).
   - C2 Trường hợp biên: rỗng, null, âm, quá lớn, trùng lặp, đồng thời.
   - C3 Xử lý lỗi: không nuốt lỗi; thông điệp lỗi hữu ích; tài nguyên được giải phóng.
   - C4 Không còn code debug, print, TODO mới, code chết, import thừa.
   - C5 Không log hay ghi ra bí mật, token, dữ liệu cá nhân.
   - C6 Không thêm phụ thuộc, không đổi cấu hình dùng chung ngoài đặc tả.
   - C7 Mỗi AC có test; không có test phụ thuộc thứ tự chạy hoặc thời gian thực.
   - C8 Tên gọi và comment theo quy ước trong AGENTS.md.
3. Nếu risk là medium hoặc high, chạy thêm (bắt buộc):
   - H1 Đầu vào từ ngoài được kiểm tra và làm sạch trước khi dùng (SQL, đường dẫn, lệnh, HTML).
   - H2 Kiểm tra quyền ở đúng tầng; không tin dữ liệu do client gửi.
   - H3 Thao tác ghi (thanh toán, trừ kho, di chuyển dữ liệu) có tính nguyên tử và idempotent.
   - H4 Đường nóng không tệ hơn về độ phức tạp; không thêm truy vấn trong vòng lặp.
   - H5 Có đường hoàn tác (rollback, migration có bước lùi).
4. Với mỗi FLAG: nếu sửa được trong phạm vi thì sửa, chạy lại test-and-summarize và scope-guard (tính là một vòng sửa). Không sửa được thì giữ FLAG cho báo cáo.

## Điều kiện dừng
Mọi mục đã trả lời; mọi FLAG hoặc đã sửa hoặc đã ghi.

## Ràng buộc
- Không bịa FLAG cho có vẻ kỹ. Không sửa ngoài phạm vi. Không bỏ qua nhóm H khi risk từ medium.

## Đầu ra
Self-review: PASS | FLAGS. Mỗi FLAG một dòng: mã, file:dòng, mô tả, đã sửa hay chưa.
