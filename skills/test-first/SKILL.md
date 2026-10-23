---
name: test-first
description: Chuyển từng tiêu chí nghiệm thu AC-n của task thành test tự động trước khi cài đặt, rồi chạy để xác nhận test đỏ đúng lý do. Dùng sau preflight và trước khi viết code cài đặt của task. Không dùng để chạy test (dùng test-and-summarize) và không dùng để sửa test có sẵn.
---

# Test First

## Mục tiêu
Mỗi tiêu chí nghiệm thu thành một test có mã AC trong tên, để báo cáo và verdict truy vết được từng tiêu chí. Test phải đỏ đúng lý do trước khi có code.

## Đầu vào
Bảng AC trong task; framework test ghi trong AGENTS.md; test gần nhất cùng module để làm mẫu.

## Các bước
1. Lập bảng AC -> test. Mỗi AC có ít nhất một test; tên test chứa mã AC (ví dụ test_AC2_expired_token_rejected).
2. Với mỗi AC chính, thêm tối thiểu một trường hợp tiêu cực hoặc biên (đầu vào rỗng, quá hạn, sai kiểu, thiếu quyền) nếu Hợp đồng nêu hành vi đó.
3. Theo mẫu test sẵn có của module: cùng thư viện, cùng cách dựng dữ liệu. Không thêm framework.
4. Chỉ mock ở biên hệ thống (mạng, thời gian, ổ đĩa). Không mock chính đơn vị đang kiểm.
5. Chạy bằng test-and-summarize. Mỗi test mới phải đỏ vì lý do chưa cài đặt (hàm chưa có, trả sai giá trị). Đỏ vì lỗi cú pháp, import hoặc dựng dữ liệu thì sửa test rồi chạy lại.
6. AC không tự động hoá được (giao diện, hiệu năng): ghi MANUAL kèm bước kiểm cụ thể.

## Điều kiện dừng
Mọi AC có test đỏ đúng lý do, hoặc được đánh dấu MANUAL. File test mới nằm ngoài files_allowed thì dừng và hỏi.

## Ràng buộc
- Test kiểm hành vi trong Hợp đồng, không kiểm cách cài đặt dự định.
- Không đụng test có sẵn.

## Đầu ra
Bảng: AC | Test | Lý do đỏ. Giữ lại cho báo cáo.
