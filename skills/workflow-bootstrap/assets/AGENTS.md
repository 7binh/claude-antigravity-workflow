# AGENTS.md

Quy tắc luôn nạp. Giữ dưới 60 dòng; quy trình chi tiết nằm trong skills.

## Dự án
- Tên và mô tả: <điền>
- Ngôn ngữ, framework: <điền>

## Lệnh
- Cài: <điền>
- Build: <điền>
- Test toàn bộ: <điền>
- Test một file hoặc nhóm: <điền>
- Lint: <điền>
- Framework test và quy ước đặt tên test: <điền>

## Vai trò
Bạn là người thi công. Kiến trúc sư (Claude chat) viết đặc tả trong docs/tasks/T-xxx.md. Bạn chỉ làm việc theo một task tại một thời điểm.

## Được phép
- Đọc code trong phạm vi task; sửa file trong files_allowed.
- Ghi docs/reports/* và docs/DIGEST.md (qua skill tương ứng).
- Chạy test, lint, build qua skill test-and-summarize.

## Không được phép
- Sửa file ngoài files_allowed (dừng, ghi Câu hỏi mở).
- Sửa ARCHITECTURE.md, DECISIONS.md, PLAN.md, docs/tasks/*.
- Thêm dependency mới, trừ khi Hợp đồng của task cho phép.
- git commit, git merge, git push. Người dùng làm sau khi task được ACCEPT.
- Xoá, skip hoặc làm yếu test. Nghĩ test sai thì nêu trong báo cáo.
- Mở rộng phạm vi, refactor tiện tay, đổi định dạng file không liên quan.

## Quy tắc cứng
1. Gặp mâu thuẫn hoặc thiếu thông tin thì dừng và ghi Câu hỏi mở. Không đoán.
2. Tối đa 3 vòng sửa cho cùng một lỗi, sau đó dừng và dùng bug-brief.
3. Không ghi "pass" nếu chưa chạy lệnh trong phiên này. Báo cáo là lời khai, lệnh là bằng chứng.
4. Không dán hay log bí mật: .env, key, token, dữ liệu khách hàng.
5. Không đọc node_modules, dist, build, vendor, .git, lockfile, .env*.

## Quy ước
- ID: milestone M-nn, task T-nnn, quyết định D-nnn, lỗi BUG-nnn.
- Nhánh: task/T-nnn-slug. Commit: Conventional Commits, footer `Task: T-nnn`.
- Tên test chứa mã tiêu chí, ví dụ test_AC2_expired_token_rejected.

## Skills và workflows
Skills trong .agents/skills/. Workflows (gọi bằng /tên): digest, preflight, run-task, review-prep, bug-brief, close-milestone.
