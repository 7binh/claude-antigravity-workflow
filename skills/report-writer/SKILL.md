---
name: report-writer
description: Viết báo cáo hoàn thành task theo mẫu cố định vào docs/reports/T-xxx.md, gồm bảng bằng chứng theo từng AC. Dùng khi kết thúc một task hoặc khi người dùng yêu cầu báo cáo. Không dùng để báo cáo lỗi khó (dùng bug-brief).
---

# Report Writer

## Mục tiêu
Báo cáo ngắn, có bằng chứng, để kiến trúc sư duyệt mà không cần đọc code.

## Đầu vào
Bảng AC <-> test từ test-first; kết quả test-and-summarize; đầu ra scope-guard; kết quả self-review; git diff --stat.

## Các bước
1. Sao chép references/REPORT_TEMPLATE.md (cạnh SKILL.md này) thành docs/reports/T-xxx.md.
2. Điền bảng bằng chứng: mỗi AC một hàng, ghi lệnh thật đã chạy trong phiên này và kết quả (exit, số test).
3. Dán nguyên đầu ra git diff --stat và dòng SCOPE từ check_scope.sh.
4. Liệt kê mọi quyết định tự đưa ra và mọi chỗ lệch đặc tả. Không có thì ghi "Không có".
5. Chép kết quả self-review. Chỉ ra tối đa 3 điểm Claude nên xem kỹ, mỗi điểm có file:dòng.
6. Chọn trạng thái: DONE chỉ khi mọi AC có bằng chứng pass và scope không VI_PHAM; ngược lại PARTIAL hoặc BLOCKED.
7. Tự đánh giá độ tin cậy cao / vừa / thấp và nêu lý do một dòng.

## Điều kiện dừng
File báo cáo ghi xong, phần văn xuôi không quá 300 từ. Bảng bằng chứng không tính vào 300 từ nhưng mỗi ô chỉ một dòng.

## Ràng buộc
- Chỉ ghi điều đã kiểm chứng bằng lệnh. Đã test thì phải kèm lệnh và kết quả.
- Không dán code dài. Chỉ trích tối đa 15 dòng cho thay đổi rủi ro cao.
- Không làm tròn: 5/6 test pass là PARTIAL, không phải DONE.
- Chưa xong hoặc chưa chắc thì ghi PARTIAL hoặc BLOCKED.
