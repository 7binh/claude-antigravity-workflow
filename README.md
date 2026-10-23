# Claude × Antigravity Workflow

> Bộ skills và quy trình để chạy **dự án lớn** với hai AI phối hợp: **Claude là kiến trúc sư và người duyệt**, **Antigravity là người thi công**, repo (`docs/`) là bộ nhớ chung, và **lệnh chạy được là trọng tài**.
>
> *English: a set of 12 agent skills (SKILL.md) plus scripts and templates that split a large project between Claude (architect/reviewer) and Google Antigravity (implementer), with machine-checkable scope and acceptance gates. Install with `npx skills add`.*

## Cài đặt

```bash
# Xem trước danh sách skill, chưa cài gì
npx skills add 7binh/claude-antigravity-workflow --list

# Cài cho Antigravity, phạm vi dự án (vào .agents/skills/)
cd duong-dan-toi-du-an
npx skills add 7binh/claude-antigravity-workflow -a antigravity

# Chỉ cài một skill
npx skills add 7binh/claude-antigravity-workflow --skill task-executor
# hoặc dạng rút gọn
npx skills add 7binh/claude-antigravity-workflow@scope-guard

# Cài toàn cục, dùng cho mọi dự án (vào ~/.gemini/antigravity/skills/)
npx skills add 7binh/claude-antigravity-workflow -a antigravity -g
```

Thay `OWNER` bằng tên GitHub của bạn (hoặc chạy `bash scripts/set-owner.sh <tên>` để thay hàng loạt trong README).

> **Nên cài ở phạm vi dự án (không dùng `-g`).** Các workflow gọi script theo đường dẫn `.agents/skills/...`.

Các cờ khác của CLI: `-y` bỏ qua xác nhận, `--all` cài mọi skill cho mọi agent, `--copy` sao chép file thay vì symlink. Xem [vercel-labs/skills](https://github.com/vercel-labs/skills).

## Bắt đầu trong 5 bước

`npx skills add` chỉ cài thư mục skill. Các phần còn lại (AGENTS.md, workflows, mẫu tài liệu) do skill `workflow-bootstrap` đặt vào dự án.

1. **Cài skills** như ở trên.
2. **Khởi tạo khung**: trong Antigravity, gõ *"Dùng skill workflow-bootstrap để khởi tạo quy trình cho dự án này"*. Skill chạy `bootstrap.sh`, không ghi đè file đã có. Rồi điền các chỗ `<điền>` trong `AGENTS.md` và **commit phần khung này** trước task đầu tiên (preflight cần `git status` sạch).
3. **Thiết lập Claude**: dán `docs/claude-side/PROJECT_INSTRUCTIONS.md` vào Instructions của một Claude Project.
4. **Mở milestone**: chạy `/digest` trong Antigravity, gửi `docs/DIGEST.md` cho Claude cùng prompt "Mở milestone" trong `docs/claude-side/PROMPTS.md`. Claude trả về kiến trúc, quyết định và danh sách task (`docs/tasks/T-xxx.md`).
5. **Vòng lặp mỗi task**: `/preflight` → `/run-task` (Antigravity) → bạn chạy `/review-prep` ở phiên mới → dán gói duyệt cho Claude → verdict → bạn commit.

## Mô hình vận hành

```
Chia task (Claude) → Preflight → Test-first → Cài đặt → Scope-guard → Self-review → Báo cáo (Antigravity)
        → Kiểm chứng độc lập (bạn) → Duyệt và ra verdict (Claude) → Commit/merge (bạn)
```

Ba ý chính:

- **Báo cáo là lời khai, lệnh là bằng chứng.** `verify_task.sh` và `check_scope.sh` thay lời tự khai bằng kết quả máy đo.
- **Task nhỏ, phạm vi file rõ, nghiệm thu bằng lệnh.** Mỗi tiêu chí là một dòng `AC-n | CMD | EXPECT`.
- **Con người giữ quyền commit, merge, push.** Antigravity không được tự làm.

Chi tiết: [docs/WORKFLOW.md](docs/WORKFLOW.md). Bản đặc tả đầy đủ gốc: [docs/reference/quy-trinh-claude-antigravity-v2.md](docs/reference/quy-trinh-claude-antigravity-v2.md).

## 12 skills

| Skill | Làm gì | Kích hoạt khi |
| --- | --- | --- |
| [`workflow-bootstrap`](skills/workflow-bootstrap) | Đặt AGENTS.md, workflows, mẫu tài liệu, prompt phía Claude vào dự án | Vừa cài bộ này |
| [`repo-digest`](skills/repo-digest) | Tóm tắt repo thành `docs/DIGEST.md` (≤150 dòng) cho kiến trúc sư | Đầu/cuối milestone |
| [`task-preflight`](skills/task-preflight) | Kiểm Definition of Ready, ghi baseline test | Nhận task |
| [`task-executor`](skills/task-executor) | Điều phối thi công một task, dừng đúng chỗ | "Làm task T-xxx" |
| [`test-first`](skills/test-first) | Biến mỗi AC thành test, xác nhận đỏ đúng lý do | Trước khi code |
| [`test-and-summarize`](skills/test-and-summarize) | Chạy lệnh, chỉ trả tóm tắt; chạy toàn bộ AC của task | Mỗi lần chạy test |
| [`scope-guard`](skills/scope-guard) | Kiểm file đổi nằm trong `files_allowed`, phát hiện test bị làm yếu | Trước báo cáo |
| [`self-review`](skills/self-review) | Rà soát theo checklist C1–C8, H1–H5 | Sau khi test pass |
| [`report-writer`](skills/report-writer) | Báo cáo theo mẫu, có bảng bằng chứng theo AC | Cuối task |
| [`bug-brief`](skills/bug-brief) | Đóng gói lỗi khó để leo thang | Fail 3 vòng / BLOCKED |
| [`diff-packager`](skills/diff-packager) | Trích diff ≤40 dòng, che secret, để dán cho Claude | Verdict NEED-DIFF |
| [`git-commit-formatter`](skills/git-commit-formatter) | Commit Conventional Commits, footer `Task: T-xxx` | Sau ACCEPT |

Workflows (gõ `/tên` trong Antigravity): `/digest`, `/preflight`, `/run-task`, `/review-prep`, `/bug-brief`, `/close-milestone`.

## Cấu trúc repo

```
skills/                    ← CLI quét thư mục này
  <skill>/SKILL.md         ← name + description + hướng dẫn
  <skill>/scripts/         ← logic cần chính xác (đếm, so khớp, quét)
  <skill>/references/      ← mẫu
  workflow-bootstrap/assets/   ← AGENTS.md, workflows, templates, claude-side
docs/                      ← tài liệu quy trình
scripts/validate.mjs       ← kiểm cấu trúc skill (không cần thư viện)
tests/smoke.sh             ← chạy thử các script trong repo git tạm
```

## Yêu cầu và lưu ý

- **bash**: các script chạy trên Linux, macOS, Git Bash hoặc WSL. Trên Windows nên dùng Git Bash; repo có `.gitattributes` ép LF cho file `.sh`.
- **git** cho `scope-guard`, `diff-packager`. `package_diff.sh` dùng `perl` nếu có, nếu không dùng GNU `sed`.
- **Che secret là best-effort**: luôn tự đọc lại diff trước khi dán cho Claude.
- **Đường dẫn skill của Antigravity** được tài liệu nêu không thống nhất (`.agents/skills/` so với `.agent/skills/`). Sau khi cài, hỏi Antigravity *"What skills are available?"*; thiếu thì thử thư mục còn lại. Xem [docs/ANTIGRAVITY-SETUP.md](docs/ANTIGRAVITY-SETUP.md).
- Cú pháp `// turbo` trong workflow cần kiểm tra lại trên bản Antigravity bạn dùng.
- Skills viết bằng tiếng Việt. `description` theo công thức "Làm gì. Dùng khi… Không dùng khi…" để agent chọn đúng skill.

## Phát triển

```bash
node scripts/validate.mjs   # kiểm frontmatter, name, description, cú pháp script
bash tests/smoke.sh         # 49 kiểm tra hành vi script
```

CI (`.github/workflows/validate.yml`) chạy cả hai, rồi `npx skills add . --list` để chắc CLI nhận đủ skill.

## Giấy phép

MIT, xem [LICENSE](LICENSE).
