# Changelog

## 2.0.0 — 2026-10-23

Bản đầu tiên của repo, đóng gói từ "Quy trình Claude × Antigravity cho dự án lớn — Bản vận hành v2".

- 11 skill theo đặc tả v2 và skill thứ 12 `workflow-bootstrap` (đặt AGENTS.md, workflows, mẫu tài liệu và prompt phía Claude vào dự án, vì `npx skills add` chỉ cài thư mục skill).
- Script: `run_tests.sh`, `verify_task.sh`, `check_scope.sh`, `package_diff.sh`, `bootstrap.sh`.
- `scripts/validate.mjs` và `tests/smoke.sh` kiểm cấu trúc và hành vi; CI chạy cả hai.

Khác biệt so với script trong đặc tả:

- `check_scope.sh`: bỏ ký tự CR khi đọc file task (Windows/CRLF); chỉ quét dấu hiệu skip trong file test và khớp theo ranh giới từ, để `process.exit(` không bị tính nhầm là `xit(`; tự cho phép `.agents/.logs/`; kiểm tra có phải git repo.
- `verify_task.sh`: bỏ CR; trả exit 2 khi file task không có dòng AC nào (trước đây báo đạt); tìm `run_tests.sh` qua `BASH_SOURCE`.
- `package_diff.sh`: dùng perl nếu có (BSD sed trên macOS không có cờ `I`); che thêm `Bearer`, JSON `"password": "..."`, khoá `sk-`/`ghp_`/`AKIA`; thêm tham số dải dòng `START,END` như SKILL.md mô tả; xử lý diff rỗng.
- `SKILL.md`: dùng `<SKILL_DIR>` cho đường dẫn script thay vì `scripts/...` mơ hồ, vì thư mục cài đặt khác nhau theo agent.
