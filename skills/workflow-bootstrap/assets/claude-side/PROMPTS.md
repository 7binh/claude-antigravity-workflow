# Bộ prompt dùng sẵn phía Claude chat

## 1. Mở milestone

```
Milestone: M-nn — <tên>. Mục tiêu và tiêu chí hoàn thành: <...>.
Ràng buộc: <thời hạn, công nghệ, hiệu năng, bảo mật>.
Tài liệu đính kèm bên dưới: DIGEST.md, ARCHITECTURE.md, DECISIONS.md (bản nén), PLAN.md.
Yêu cầu:
1. Liệt kê rủi ro kiến trúc và câu hỏi mở (tối đa 7), xếp theo mức ảnh hưởng.
2. Đề xuất thiết kế, nêu ít nhất một phương án thay thế và lý do không chọn.
3. Xuất: phần ARCHITECTURE.md cần sửa; các mục D-nnn mới.
Chưa chia task. Chờ tôi trả lời câu hỏi mở.
```

## 2. Chia task

```
Chia milestone M-nn thành task theo mẫu TASK.
- Mỗi task một mục tiêu, tối đa 5 file, đặc tả không quá 40 dòng, có trường risk.
- Sắp theo phụ thuộc; đánh dấu task nào chạy song song được (không chung file).
- Mỗi AC có CMD chạy được bằng công cụ trong AGENTS.md. Nếu cần hạ tầng test chưa có, tạo task riêng ở đầu danh sách.
- Cuối cùng xuất bảng PLAN.md và kiểm tra Definition of Ready cho từng task (đạt / chưa, lý do).
```

## 3. Duyệt task (dán kèm gói duyệt)

Gói duyệt gồm: báo cáo, kết quả verify_task.sh chạy độc lập, check_scope.sh, git diff --stat.

```
Duyệt T-xxx. Bên dưới là gói duyệt: báo cáo, kết quả verify_task.sh chạy độc lập, check_scope.sh, git diff --stat.
Chạy rubric 8 điểm rồi trả theo mẫu:
Rubric: 1 đến 8, mỗi mục OK hoặc NOT OK kèm một dòng.
Verdict T-xxx: ACCEPT | REVISE | NEED-DIFF | REPLAN
Lý do (tối đa 5 dòng):
Yêu cầu tiếp theo: <lệnh hoặc diff cụ thể, hoặc đặc tả sửa đổi>
Cập nhật tài liệu: <PLAN / DECISIONS cần ghi, nếu có>
```

## 4. REPLAN

```
REPLAN M-nn. Lý do: <...>. Tài liệu kèm: PLAN.md, các task bị ảnh hưởng, BUG hoặc báo cáo liên quan.
Yêu cầu:
1. Nêu nguyên nhân gốc ở mức kiến trúc hoặc đặc tả (không dừng ở triệu chứng).
2. Liệt kê task giữ nguyên, sửa, huỷ, thêm.
3. Xuất mục D-nnn mới và bản PLAN.md mới.
4. Nói rõ phần code đã merge có phải hoàn tác không, và task nào.
```

## 5. Nén DECISIONS

```
Nén DECISIONS.md. Giữ nguyên đầy đủ các quyết định còn hiệu lực và đang chi phối thiết kế. Gộp quyết định cũ hoặc đã bị thay thế thành bảng: ID | Quyết định | Lý do (1 dòng) | Trạng thái. Không làm mất ID. Xuất bản nén và danh sách mục chuyển vào docs/archive/.
```
