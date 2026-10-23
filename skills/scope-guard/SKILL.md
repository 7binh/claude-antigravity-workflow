---
name: scope-guard
description: Kiểm tra mọi file đã sửa hoặc tạo nằm trong files_allowed của task bằng script, và phát hiện dấu hiệu làm yếu test (xoá, skip, giảm assertion). Dùng trước khi báo cáo, sau mỗi cụm thay đổi lớn, hoặc khi nghi ngờ đã chạm file ngoài danh sách. Không dùng để review chất lượng code (dùng self-review).
---

# Scope Guard

## Mục tiêu
Biến nguyên tắc "báo cáo là lời khai" thành kiểm tra máy móc: so file thật sự đã đổi với files_allowed và quét dấu hiệu làm yếu test.

## Quy ước đường dẫn
`<SKILL_DIR>` là thư mục chứa SKILL.md này. Chạy từ thư mục gốc repo (cần git và bash).

## Các bước
1. Chạy: `bash <SKILL_DIR>/scripts/check_scope.sh docs/tasks/T-xxx.md [base_ref]`
   base_ref mặc định là HEAD (chưa commit gì). Nếu đã commit trên nhánh, truyền nhánh gốc (ví dụ main).
   Mã thoát: 0 CLEAN, 1 VI_PHAM, 2 lỗi đầu vào, 3 CLEAN có cảnh báo.
2. Đọc dòng SCOPE ở đầu ra:
   - CLEAN: tiếp tục.
   - CLEAN_CO_CANH_BAO: từng cảnh báo phải được giải quyết hoặc nêu trong báo cáo mục Lệch so với đặc tả.
   - VI_PHAM: với mỗi file, chọn một trong hai: hoàn tác thay đổi (git checkout -- <file> hoặc xoá file mới), hoặc dừng và ghi Câu hỏi mở xin mở rộng phạm vi.
3. Chạy lại đến khi CLEAN hoặc đến khi chỉ còn ngoại lệ đã ghi Câu hỏi mở.

## Quy ước files_allowed
Mỗi mục một dòng bắt đầu bằng `  - `, không bọc dấu nháy. Mục kết thúc bằng `/` là cả thư mục; còn lại là file chính xác. docs/reports/T-xxx.md của chính task và .agents/.logs/ được tự động cho phép.

## Điều kiện dừng
Kết quả CLEAN, hoặc mọi ngoại lệ đã ghi vào Câu hỏi mở và báo trạng thái PARTIAL/BLOCKED.

## Ràng buộc
- Không sửa files_allowed trong file task để cho script qua.
- Không bỏ qua cảnh báo test bị skip hay xoá.
- Lockfile và file sinh tự động bị đổi cũng là vi phạm, trừ khi nằm trong files_allowed.

## Đầu ra
Dán nguyên dòng SCOPE và các dòng cảnh báo vào báo cáo.
