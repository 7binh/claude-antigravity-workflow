# Quy trình Claude × Antigravity (tóm tắt vận hành)

Bản tóm tắt để tra nhanh. Đặc tả đầy đủ và nguyên văn các skill nằm ở [reference/quy-trinh-claude-antigravity-v2.md](reference/quy-trinh-claude-antigravity-v2.md).

## Mô hình một câu

Claude chat là kiến trúc sư và người duyệt; Antigravity là người thi công; repo (`docs/`) là bộ nhớ chung; lệnh chạy được là trọng tài.

## Bốn giai đoạn

| Giai đoạn | Ai làm | Việc chính | Đầu ra |
| --- | --- | --- | --- |
| 1. Mở milestone | Antigravity, rồi Claude | `/digest`; gửi DIGEST + ARCHITECTURE + DECISIONS + PLAN cho Claude kèm prompt "Mở milestone" | `ARCHITECTURE.md` cập nhật, các mục `D-nnn` |
| 2. Chia task | Claude, bạn kiểm | Prompt "Chia task"; kiểm Definition of Ready cho từng task | `docs/tasks/T-xxx.md`, `PLAN.md` |
| 3. Thi công | Antigravity (một phiên mỗi task) | `/preflight`, `/run-task`: test-first → cài đặt → scope-guard → self-review → báo cáo | `docs/reports/T-xxx.md` |
| 4. Duyệt và đóng | Bạn kiểm chứng, Claude ra verdict, bạn commit | `/review-prep` ở phiên mới; dán gói duyệt; verdict; `git-commit-formatter` | Commit, `PLAN.md` = DONE |

Một chat Claude cho mỗi milestone; một phiên Antigravity cho mỗi task. Phân chia bốn giai đoạn này được tóm từ vòng đời và bảng vai trò trong bản đặc tả.

## Vai trò

| Việc | Thực hiện | Quyết định |
| --- | --- | --- |
| Thiết lập repo, cấu hình agent | Bạn | Bạn |
| Khảo sát repo, tạo digest | Antigravity | Bạn kiểm nhanh |
| Thiết kế kiến trúc, ghi quyết định | Claude | Bạn |
| Chia task, xếp thứ tự | Claude | Bạn |
| Preflight, test-first, thi công, scope-guard, self-review, báo cáo | Antigravity | — |
| Kiểm chứng độc lập | Bạn | Bạn |
| Duyệt, ra verdict | Claude | Bạn quyết định merge |
| Commit, merge | Bạn | Bạn |

## Ma trận quyền của Antigravity

| Hành động | Được phép |
| --- | --- |
| Đọc code trong phạm vi task | Có |
| Sửa file trong `files_allowed` | Có |
| Sửa file ngoài `files_allowed` | Không (dừng, ghi Câu hỏi mở) |
| Sửa `ARCHITECTURE.md`, `DECISIONS.md`, `PLAN.md`, `docs/tasks/*` | Không |
| Ghi `docs/reports/*`, `docs/DIGEST.md` | Có, qua skill |
| Chạy test, lint, build | Có, qua `test-and-summarize` |
| Thêm dependency | Không, trừ khi Hợp đồng cho phép |
| `git commit`, `merge`, `push` | Không |
| Xoá hoặc skip test | Không |

## ID và đặt tên

| Đối tượng | Mẫu | Ví dụ |
| --- | --- | --- |
| Milestone | `M-nn` | `M-02` |
| Task (đánh số toàn dự án) | `T-nnn` | `T-007` |
| Quyết định | `D-nnn` | `D-012` |
| Lỗi cần leo thang | `BUG-nnn` | `BUG-003` |
| Nhánh | `task/T-nnn-slug` | `task/T-007-refresh-token-expiry` |
| Commit | `type(scope): mô tả` + `Task: T-nnn` | `feat(auth): expire refresh tokens` |
| Tên test | chứa mã AC | `test_AC2_expired_token_rejected` |

## Vòng đời trạng thái task

`PLAN.md` là nguồn sự thật duy nhất; chỉ Claude và bạn sửa.

`TODO` → `READY` (qua DoR) → `IN_PROGRESS` → `REPORTED` → `DONE` (ACCEPT + kiểm chứng pass + merge).
Nhánh phụ: `REVISE` (verdict REVISE), `BLOCKED` (có Câu hỏi mở hoặc fail quá 3 vòng), `CANCELLED` (REPLAN).

## Definition of Ready

- Mục tiêu 1–2 câu, một việc.
- `files_allowed` cụ thể, tối đa khoảng 5 file, ghi "tạo mới" nếu chưa có.
- Hợp đồng có chữ ký, kiểu, mã lỗi.
- Mỗi AC có lệnh kiểm chứng và kết quả kỳ vọng định lượng.
- Có mục Ngoài phạm vi; mọi task phụ thuộc đã DONE.
- Đặc tả ≤ 40 dòng, có `risk: low | medium | high`.
- Nhánh sạch, đã biết baseline test.

## Definition of Done

- Mọi `AC-n` có bằng chứng là lệnh và kết quả.
- Bạn tự chạy `verify_task.sh` và khớp báo cáo.
- `check_scope.sh` báo CLEAN (hoặc ngoại lệ được Claude chấp nhận).
- Không có test bị xoá, skip hay làm yếu; `self-review` PASS hoặc mọi cờ đã xử lý.
- Verdict ACCEPT; commit Conventional Commits có `Task: T-xxx`; `PLAN.md` = DONE.

## Verdict

| Verdict | Dùng khi | Tiếp theo |
| --- | --- | --- |
| ACCEPT | Cả 8 điểm rubric đạt | Bạn commit, merge, PLAN = DONE |
| REVISE | Thiếu/sai bằng chứng, vi phạm phạm vi, test bị làm yếu, đặc tả mơ hồ | Claude nêu đúng lệnh cần chạy hoặc sửa đặc tả |
| NEED-DIFF | Bằng chứng đủ nhưng cần nhìn code | `diff-packager`, ≤40 dòng |
| REPLAN | Đặc tả/kiến trúc sai từ gốc | Ghi `D-nnn`, sửa task bị ảnh hưởng |

Rubric 8 điểm: xem [`PROJECT_INSTRUCTIONS.md`](../skills/workflow-bootstrap/assets/claude-side/PROJECT_INSTRUCTIONS.md).

## 12 nguyên tắc vận hành

1. Claude không đọc code, chỉ đọc digest, báo cáo và diff nhỏ do chính Claude chỉ định.
2. Quyết định nằm trong file, không nằm trong hội thoại.
3. Task nhỏ, phạm vi file rõ, nghiệm thu bằng lệnh.
4. Báo cáo là lời khai, lệnh là bằng chứng.
5. Một chat Claude cho mỗi milestone, một phiên Antigravity cho mỗi task.
6. Mâu thuẫn hoặc thiếu thông tin thì dừng và ghi Câu hỏi mở, không đoán.
7. Không sửa thước đo để vượt qua thước đo: không sửa, xoá, skip test; không đổi tiêu chí nghiệm thu.
8. Tối đa 3 vòng sửa cho cùng một lỗi, sau đó leo thang bằng `bug-brief`.
9. Bí mật không đi qua chat.
10. Mọi thứ truy vết được: task ↔ nhánh ↔ commit ↔ báo cáo ↔ quyết định.
11. Con người giữ quyền commit, merge, push.
12. Cải tiến theo dữ liệu, không theo cảm giác.
