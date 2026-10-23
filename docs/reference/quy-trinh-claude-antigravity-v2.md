# Quy trình Claude × Antigravity cho dự án lớn — Bản vận hành v2

*Phiên bản 2.0 · 23/10/2026 · Mở rộng từ bản v1: chuẩn hoá ID và vòng đời task, cổng chất lượng cho từng phase, 11 skill có script kiểm tra máy móc, bộ prompt phía Claude, xử lý sự cố, đo lường và bảo trì.*

## 0. Tổng quan và cách dùng

**Mô hình một câu:** Claude chat là kiến trúc sư và người duyệt; Antigravity là người thi công; repo (`docs/`) là bộ nhớ chung; lệnh chạy được là trọng tài.

**Vòng đời một task:** Chia task (Claude) → Preflight → Test-first → Cài đặt → Scope-guard → Self-review → Báo cáo (Antigravity) → Kiểm chứng độc lập (bạn) → Duyệt và ra verdict (Claude) → Commit/merge (bạn).

**Đọc gì, khi nào**

| Bạn đang… | Đọc mục |
| --- | --- |
| Thiết lập lần đầu | 3, 4, 5, 6, 12 |
| Mở milestone mới | 7, 8 (Phase 1–2) |
| Giao và duyệt một task | 8 (Phase 3–4), 7.4–7.5, Phụ lục A |
| Gặp sự cố | 9 |
| Muốn cải tiến quy trình | 11, 12.4 |

**Khác biệt so với v1**

1. Task có front matter máy đọc được (`files_allowed`, `risk`, `depends_on`) và tiêu chí nghiệm thu dạng `AC-n` kèm lệnh kiểm chứng và kết quả kỳ vọng.
2. Bộ skill tăng từ 5 lên 11: thêm `task-preflight`, `test-first`, `scope-guard`, `self-review`, `bug-brief`, `diff-packager`. Mỗi skill có `description` theo công thức cố định, điều kiện dừng và cách kiểm thử.
3. Hai script thay lời khai bằng bằng chứng: `check_scope.sh` (file đổi có nằm trong phạm vi không) và `verify_task.sh` (chạy toàn bộ lệnh nghiệm thu của task).
4. Có vòng đời trạng thái task, Definition of Ready, Definition of Done.
5. Có rubric duyệt 8 điểm, bảng quy đổi sang verdict và bộ prompt dùng sẵn phía Claude.
6. Có mục sự cố, chạy song song, chỉ số đo lường và bảo trì skill.
7. Đính chính đường dẫn skill so với v1 (xem mục 4).

## 1. Nguyên tắc vận hành

| # | Nguyên tắc | Cơ chế thực thi |
| --- | --- | --- |
| 1 | Claude không đọc code. Claude chỉ đọc digest, báo cáo và diff nhỏ do chính Claude chỉ định. | Giới hạn dòng ở mục 11; skill `diff-packager` |
| 2 | Quyết định nằm trong file, không nằm trong hội thoại. Chat có thể bỏ bất cứ lúc nào. | `DECISIONS.md`, `PLAN.md` |
| 3 | Task nhỏ, phạm vi file rõ, nghiệm thu bằng lệnh. | Definition of Ready; skill `task-preflight` |
| 4 | Báo cáo là lời khai, lệnh là bằng chứng. | `verify_task.sh` do bạn chạy; `check_scope.sh` |
| 5 | Một chat Claude cho mỗi milestone, một phiên Antigravity cho mỗi task. | Phase 1 và Phase 3 |
| 6 | Gặp mâu thuẫn hoặc thiếu thông tin thì dừng và ghi Câu hỏi mở, không đoán. | Bảng điều kiện dừng trong `task-executor` |
| 7 | Không sửa thước đo để vượt qua thước đo: không sửa, xoá hay skip test; không đổi tiêu chí nghiệm thu. | `scope-guard` quét test bị làm yếu |
| 8 | Tối đa 3 vòng sửa cho cùng một lỗi, sau đó leo thang. | `bug-brief`, mục 9 |
| 9 | Bí mật không đi qua chat: không dán `.env`, key, token, dữ liệu khách hàng. | `repo-digest`, `diff-packager` có bước lọc |
| 10 | Mọi thứ truy vết được: task ↔ nhánh ↔ commit ↔ báo cáo ↔ quyết định. | Quy ước ID ở mục 3.2 |
| 11 | Con người giữ quyền commit, merge, push. | Ma trận quyền ở mục 2 |
| 12 | Cải tiến theo dữ liệu, không theo cảm giác. | Chỉ số ở mục 11 |

## 2. Vai trò, trách nhiệm và ranh giới quyền

### 2.1 Ai làm gì

| Việc | Thực hiện | Quyết định / phê duyệt | Đầu ra |
| --- | --- | --- | --- |
| Thiết lập repo và cấu hình agent | Bạn | Bạn | `.agents/`, `AGENTS.md` |
| Khảo sát repo, tạo digest | Antigravity | Bạn kiểm tra nhanh | `docs/DIGEST.md` |
| Thiết kế kiến trúc, ghi quyết định | Claude chat | Bạn | `ARCHITECTURE.md`, `DECISIONS.md` |
| Chia task, xếp thứ tự | Claude chat | Bạn | `docs/tasks/T-xxx.md`, `PLAN.md` |
| Preflight, test-first, thi công | Antigravity | — | Code, test |
| Scope-guard, self-review, báo cáo | Antigravity | — | `docs/reports/T-xxx.md` |
| Kiểm chứng độc lập | Bạn | Bạn | Kết quả `verify_task.sh` |
| Duyệt, ra verdict | Claude chat | Bạn quyết định merge | Verdict |
| Commit, merge | Bạn | Bạn | Commit Conventional Commits |
| Lỗi khó, thiết kế lại | Antigravity (`bug-brief`) → Claude | Bạn | `BUG-xxx.md`, mục DECISIONS mới |
| Review sâu một module (hiếm) | Claude Code trên `git diff` hẹp | Bạn | Nhận xét, rồi `/clear` |

### 2.2 Ma trận quyền của Antigravity

| Hành động | Được phép | Ghi chú |
| --- | --- | --- |
| Đọc code trong phạm vi task | Có | Không quét toàn repo |
| Sửa file trong `files_allowed` | Có |  |
| Sửa file ngoài `files_allowed` | Không | Dừng, ghi Câu hỏi mở |
| Sửa `ARCHITECTURE.md`, `DECISIONS.md`, `PLAN.md`, `docs/tasks/*` | Không | Chỉ Claude và bạn |
| Ghi `docs/reports/*`, `docs/DIGEST.md` | Có | Qua skill tương ứng |
| Chạy test, lint, build | Có | Qua `test-and-summarize` |
| Thêm dependency mới | Không | Trừ khi Hợp đồng của task cho phép |
| `git commit`, `git merge`, `git push` | Không | Bạn làm sau ACCEPT |
| Xoá hoặc skip test | Không | Nghĩ test sai thì nêu trong báo cáo |

## 3. Cấu trúc repo, quy ước ID và vòng đời task

### 3.1 Cây thư mục

```
.agents/                         (bản cũ dùng .agent/, vẫn được hỗ trợ ngược)
  skills/
    repo-digest/SKILL.md
    task-preflight/SKILL.md
    task-executor/SKILL.md
    test-first/SKILL.md
    test-and-summarize/SKILL.md
    test-and-summarize/scripts/run_tests.sh
    test-and-summarize/scripts/verify_task.sh
    scope-guard/SKILL.md
    scope-guard/scripts/check_scope.sh
    self-review/SKILL.md
    report-writer/SKILL.md
    report-writer/references/REPORT_TEMPLATE.md
    bug-brief/SKILL.md
    bug-brief/references/BUG_TEMPLATE.md
    diff-packager/SKILL.md
    diff-packager/scripts/package_diff.sh
    git-commit-formatter/SKILL.md
  workflows/
    digest.md  preflight.md  run-task.md
    review-prep.md  bug-brief.md  close-milestone.md
  .logs/                         (log chạy test; thêm vào .gitignore)
AGENTS.md                        (quy tắc luôn nạp, dưới 60 dòng)
docs/
  DIGEST.md  ARCHITECTURE.md  DECISIONS.md  PLAN.md
  tasks/T-001.md ...
  reports/T-001.md ...  BUG-001.md ...
  templates/TASK.md  REPORT.md  DECISION.md  VERDICT.md
  archive/M-01/            (task, báo cáo, DECISIONS bản đầy đủ của milestone đã đóng)
```

### 3.2 Quy ước đặt tên

| Đối tượng | Mẫu | Ví dụ |
| --- | --- | --- |
| Milestone | `M-nn` | `M-02` |
| Task | `T-nnn`, đánh số toàn dự án, không reset | `T-007` |
| Quyết định | `D-nnn` | `D-012` |
| Lỗi cần leo thang | `BUG-nnn` | `BUG-003` |
| Nhánh | `task/T-nnn-slug-ngắn` | `task/T-007-refresh-token-expiry` |
| Commit | `type(scope): mô tả` + footer `Task: T-nnn` | `feat(auth): expire refresh tokens` |
| Tên test | Chứa mã tiêu chí để truy vết | `test_AC2_expired_token_rejected` |

### 3.3 Vòng đời trạng thái task

`PLAN.md` là nguồn sự thật duy nhất về trạng thái. Chỉ Claude và bạn sửa `PLAN.md`; Antigravity không sửa.

| Trạng thái | Ý nghĩa | Ai chuyển | Điều kiện chuyển |
| --- | --- | --- | --- |
| TODO | Đã có trong kế hoạch, chưa đủ điều kiện thi công | Claude | Task được tạo |
| READY | Đạt Definition of Ready | Bạn | Qua checklist DoR |
| IN\_PROGRESS | Đang thi công | Bạn | Đã tạo nhánh, preflight báo READY |
| REPORTED | Đã có báo cáo | Bạn | `docs/reports/T-xxx.md` tồn tại |
| REVISE | Cần làm lại | Bạn, theo verdict | Verdict REVISE |
| BLOCKED | Chờ quyết định hoặc đầu vào | Antigravity báo, bạn ghi | Có Câu hỏi mở, hoặc fail quá 3 vòng |
| DONE | Đã merge | Bạn | ACCEPT + kiểm chứng độc lập pass + merge |
| CANCELLED | Bỏ | Claude và bạn | REPLAN |

### 3.4 Definition of Ready (trước khi giao task)

- [ ] Mục tiêu 1–2 câu, chỉ một việc.
- [ ] `files_allowed` liệt kê cụ thể, tối đa khoảng 5 file; file đã có hoặc ghi rõ “tạo mới”.
- [ ] Hợp đồng có chữ ký, kiểu dữ liệu, mã lỗi.
- [ ] Mỗi tiêu chí nghiệm thu có lệnh kiểm chứng và kết quả kỳ vọng định lượng (ví dụ `exit 0`, `6 test pass`).
- [ ] Mục Ngoài phạm vi được ghi rõ.
- [ ] Mọi task phụ thuộc đã DONE.
- [ ] Đặc tả không quá 40 dòng; có gán `risk: low | medium | high`.
- [ ] Nhánh sạch, baseline test hiện tại đã biết.

### 3.5 Definition of Done (trước khi đổi sang DONE)

- [ ] Mọi `AC-n` có bằng chứng là lệnh và kết quả.
- [ ] Bạn tự chạy `verify_task.sh` và kết quả khớp báo cáo.
- [ ] `check_scope.sh` báo CLEAN (ngoại lệ phải được Claude chấp nhận và ghi trong báo cáo).
- [ ] Không có test bị xoá, skip hoặc làm yếu.
- [ ] `self-review` đạt PASS, hoặc mọi cờ đã được xử lý.
- [ ] Verdict ACCEPT.
- [ ] Commit theo Conventional Commits, có footer `Task: T-xxx`.
- [ ] `PLAN.md` đổi sang DONE; `DECISIONS.md` cập nhật nếu có quyết định mới.

## 4. Ba lớp cấu hình của Antigravity

Antigravity có ba lớp: **Rules** (quy tắc luôn nạp), **Skills** (gói hướng dẫn nạp theo nhu cầu) và **Workflows** (quy trình do bạn gọi chủ động bằng `/tên`). Đặt nhầm lớp là nguyên nhân phổ biến nhất khiến cấu hình không chạy như mong muốn.

| Lớp | Vị trí | Nạp khi nào | Dùng cho | Không dùng cho |
| --- | --- | --- | --- | --- |
| Rule | `AGENTS.md`; `.agents/rules/*.md`; toàn cục `~/.gemini/GEMINI.md` | Luôn nạp | Ràng buộc chung, lệnh build/test | Quy trình dài, mẫu, script |
| Skill | Dự án: `.agents/skills/<tên>/SKILL.md`. Toàn cục: `~/.gemini/antigravity/skills/<tên>/` | Khi agent thấy mô tả khớp với việc đang làm, rồi đọc toàn bộ `SKILL.md` | Kỹ năng có điều kiện kích hoạt, kèm script và mẫu | Ràng buộc phải luôn đúng |
| Workflow | `.agents/workflows/*.md` | Khi bạn gõ `/tên` | Chuỗi bước cố định, bạn muốn bấm chủ động | Tri thức dùng lại ở nhiều nơi |

**Đính chính đường dẫn so với v1.** Tài liệu chính thức của Antigravity nêu thư mục dự án mặc định là `.agents/skills/` (vẫn hỗ trợ ngược `.agent/skills/`) và thư mục toàn cục là `~/.gemini/antigravity/skills/`. Codelab của Google dùng `.agent/skills/`. Một số bài viết bên thứ ba ghi `~/.gemini/config/skills/` cho toàn cục. Vì tài liệu không thống nhất, cách chắc chắn là copy xong thì hỏi Antigravity “What skills are available?” và thử thư mục còn lại nếu thiếu.

**`AGENTS.md`.** Một nguồn bên thứ ba cho biết Antigravity đọc `AGENTS.md` như Rule từ IDE bản 1.20.5 trở đi, trước đó chỉ đọc `GEMINI.md`. Nếu bản bạn dùng cũ hơn hoặc không thấy rule được nạp, đặt nội dung vào `.agents/rules/project.md`. Cũng theo nguồn đó, Rules và Workflows có giới hạn khoảng 12.000 ký tự mỗi file; hãy giữ workflow dưới 4.000 ký tự và đẩy chi tiết sang skill.

### 4.1 Chọn lớp nào

| Nội dung | Lớp |
| --- | --- |
| Ràng buộc luôn đúng, ngắn gọn (lệnh build, “không đọc `node_modules`”) | Rule |
| Kỹ năng có điều kiện kích hoạt, cần script hoặc mẫu đi kèm | Skill |
| Chuỗi bước cố định bạn muốn tự bấm | Workflow |
| Quy trình dài, chi tiết | Skill (không nhồi vào `AGENTS.md`) |

Quan hệ gọi: workflow gọi skill; skill không gọi workflow; skill có thể gọi skill khác bằng tên.

### 4.2 Công thức viết `description`

Agent chọn skill bằng cách so khớp ngữ nghĩa với trường `description`, nên mô tả quyết định skill có chạy hay không. Dùng công thức:

> **\<Làm gì, tạo ra gì>. Dùng khi <điều kiện kích hoạt cụ thể, kèm các cách người dùng hay diễn đạt>. Không dùng khi \<loại trừ gần nhất>.**

- Tốt: “Chạy lệnh test, lint hoặc build và chỉ trả tóm tắt gọn. Dùng mỗi khi cần chạy test trong lúc thi công. Không dùng để viết hay sửa test.”
- Xấu: “Hỗ trợ kiểm thử.” (quá mơ hồ, chồng lấn với `test-first`).

Mỗi skill một trách nhiệm. Hai skill có vùng gần nhau (`test-first` và `test-and-summarize`) phải có câu loại trừ trỏ sang nhau.

### 4.3 Không nên làm

- Cài hàng loạt skill cộng đồng. Có báo cáo (chưa kiểm chứng) rằng cài hơn 1.000 skill làm lần khởi tạo đầu chậm hàng chục phút vì phải lập chỉ mục metadata. Chỉ cài skill bạn đã đọc và hiểu.
- Dùng nguyên các bộ skill orchestrator bên thứ ba (kiểu product-manager, team-lead-orchestrator). Phần lập kế hoạch đã do Claude làm; nếu muốn tham khảo thì đọc và rút gọn.
- Nhồi quy trình vào `AGENTS.md`. Phần đó tốn token ở mọi lượt.
- Viết một skill “làm mọi thứ”. Tài liệu Antigravity khuyên tách skill theo từng việc riêng.

## 5. Danh mục skill chi tiết

### 5.0 Tổng quan

| # | Skill | Trách nhiệm | Kích hoạt | Đầu ra | Script |
| --- | --- | --- | --- | --- | --- |
| 1 | `repo-digest` | Tóm tắt repo cho kiến trúc sư | Yêu cầu digest; đầu và cuối milestone | `docs/DIGEST.md` | — |
| 2 | `task-preflight` | Kiểm tra task đạt Definition of Ready, ghi baseline | Nhận task T-xxx | READY / NOT\_READY | dùng `run_tests.sh` |
| 3 | `task-executor` | Điều phối thi công đúng phạm vi, dừng đúng chỗ | Làm task T-xxx | Code + gọi các skill sau | — |
| 4 | `test-first` | Biến từng AC thành test, xác nhận test đỏ đúng lý do | Sau preflight, trước khi code | Test + bảng AC ↔ test | — |
| 5 | `test-and-summarize` | Chạy lệnh, chỉ trả tóm tắt; chạy toàn bộ lệnh nghiệm thu | Mỗi lần chạy test | Tóm tắt + đường dẫn log | `run_tests.sh`, `verify_task.sh` |
| 6 | `scope-guard` | Kiểm tra file đổi nằm trong phạm vi; phát hiện test bị làm yếu | Trước báo cáo | CLEAN / VI PHẠM | `check_scope.sh` |
| 7 | `self-review` | Tự rà soát theo checklist trước bàn giao | Sau khi test pass và scope sạch | PASS / FLAGS | — |
| 8 | `report-writer` | Viết báo cáo theo mẫu cố định | Cuối task | `docs/reports/T-xxx.md` | — |
| 9 | `bug-brief` | Đóng gói lỗi khó để leo thang | Fail 3 vòng; BLOCKED | `docs/reports/BUG-xxx.md` | — |
| 10 | `diff-packager` | Trích đúng đoạn diff Claude yêu cầu, lọc secret | Verdict NEED-DIFF | Khối diff ≤ 40 dòng | `package_diff.sh` |
| 11 | `git-commit-formatter` | Commit chuẩn Conventional Commits | Sau ACCEPT, khi bạn yêu cầu | Commit message | — |

### 5.1 Quy ước chung cho mọi `SKILL.md`

- Front matter chỉ có `name` (trùng tên thư mục, chữ thường, gạch ngang) và `description` theo công thức mục 4.2.
- Thân gồm các mục theo thứ tự: **Mục tiêu**, **Đầu vào**, **Các bước** (đánh số), **Điều kiện dừng**, **Ràng buộc**, **Đầu ra**. Tối đa khoảng 80 dòng.
- Logic cần chính xác (đếm, so khớp, quét) đặt vào `scripts/`; mẫu đặt vào `references/`. `SKILL.md` chỉ tham chiếu bằng đường dẫn tương đối. Cách tách này giữ phần lập luận của agent ở chỗ cần phán đoán, phần máy móc ở chỗ cần chắc chắn.
- Luôn có “Điều kiện dừng” rõ ràng. Skill không có điều kiện dừng sẽ kéo agent làm lan sang việc khác.
- Mọi con số giới hạn (dòng, từ, vòng) ghi trực tiếp trong skill, không để agent tự chọn.

### 5.2 Skill 1 — `repo-digest`

**Kích hoạt:** đầu milestone, cuối milestone, hoặc khi bạn cần gửi bản đồ repo cho Claude. **Điểm thiết kế:** digest có cấu trúc cố định và ghi *commit cơ sở* để lần sau chỉ cập nhật phần đã đổi thay vì quét lại toàn repo.

```markdown
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
```

### 5.3 Skill 2 — `task-preflight`

**Kích hoạt:** ngay khi nhận task. **Điểm thiết kế:** đây là cổng chặn rẻ nhất trong quy trình. Một đặc tả hỏng bị chặn ở đây tốn vài giây; để lọt sang thi công sẽ tốn cả phiên. Skill cũng ghi *baseline* để phân biệt test đỏ có sẵn với hồi quy do task gây ra.

```markdown
---
name: task-preflight
description: Kiểm tra một task đã đặc tả có đạt Definition of Ready trước khi viết code, và ghi baseline test hiện tại. Dùng ngay khi nhận task T-xxx, trước task-executor, hoặc khi người dùng nói kiểm tra task trước khi làm. Không dùng để thi công hay sửa đặc tả.
---

# Task Preflight

## Mục tiêu
Chặn sớm task thiếu điều kiện, để không tốn một phiên thi công vào đặc tả hỏng.

## Đầu vào
Mã task T-xxx; docs/tasks/T-xxx.md; docs/PLAN.md.

## Các bước
1. Đọc front matter và thân của docs/tasks/T-xxx.md.
2. Kiểm từng mục, ghi PASS hoặc FAIL kèm một dòng lý do:
   a. status là READY.
   b. Mọi task trong depends_on có trạng thái DONE trong PLAN.md.
   c. files_allowed không rỗng, không quá 7 mục; mỗi file tồn tại hoặc được ghi "tạo mới".
   d. Mục Hợp đồng có chữ ký đầy đủ.
   e. Mọi AC có CMD và EXPECT; không AC nào chỉ ghi "hoạt động đúng".
   f. Có mục Ngoài phạm vi.
   g. Đặc tả không quá 40 dòng; có trường risk.
   h. git status --short rỗng; đang ở nhánh task/T-xxx-*.
3. Chạy baseline: chạy test của dự án (hoặc nhóm test liên quan) bằng test-and-summarize. Ghi số pass/fail hiện có. Test đã đỏ từ trước phải được ghi lại.
4. Chạy thử từng CMD của AC. Chấp nhận kết quả đỏ nếu lý do là chưa cài đặt. Không chấp nhận nếu lệnh không tồn tại hoặc sai cú pháp.

## Điều kiện dừng
Bất kỳ mục nào ở bước 2 FAIL, hoặc lệnh ở bước 4 không chạy được: kết luận NOT_READY và dừng. Không sửa đặc tả, không bắt đầu code.

## Ràng buộc
- Chỉ đọc và chạy lệnh. Không sửa file nào.

## Đầu ra
In đúng một khối:
PREFLIGHT T-xxx: READY | NOT_READY
Lỗi (mỗi dòng một lỗi, ghi mã mục a-h):
Baseline: <N pass, M fail có sẵn, lệnh đã chạy>
```

### 5.4 Skill 3 — `task-executor`

**Kích hoạt:** khi bạn nói “làm task T-xxx” hoặc gọi `/run-task`. **Điểm thiết kế:** skill này là *bộ điều phối*, không tự chứa chi tiết của các bước con. Nó gọi lần lượt các skill khác, nhờ vậy mỗi skill giữ nhỏ và kiểm thử riêng được. Điểm quan trọng nhất là bảng điều kiện dừng: agent được phép dừng, và bị cấm đoán.

```markdown
---
name: task-executor
description: Thi công đúng một task đã đặc tả trong docs/tasks/T-xxx.md theo thứ tự preflight, test-first, cài đặt, kiểm tra phạm vi, tự rà soát, báo cáo, rồi dừng. Dùng khi người dùng nói làm task T-xxx, chạy task, hoặc dán prompt thi công. Không dùng khi chưa có file task hoặc khi chỉ cần sửa một lỗi nhỏ ngoài kế hoạch.
---

# Task Executor

## Đầu vào
docs/tasks/T-xxx.md; các mục liên quan trong docs/ARCHITECTURE.md và docs/DECISIONS.md. Không đọc thêm.

## Các bước
1. Gọi skill task-preflight. NOT_READY thì in kết quả và dừng.
2. Lập kế hoạch tối đa 8 dòng: các bước nhỏ và file sẽ sửa ở mỗi bước. File nào ngoài files_allowed thì áp dụng bảng Điều kiện dừng.
3. Gọi skill test-first: biến AC thành test, xác nhận test đỏ đúng lý do.
4. Cài đặt từng bước nhỏ. Sau mỗi bước chạy test liên quan bằng test-and-summarize. Đếm số vòng sửa cho từng lỗi.
5. Khi test của task pass, chạy nhóm test bị ảnh hưởng để so với baseline và phát hiện hồi quy.
6. Gọi skill scope-guard. Nếu VI_PHAM: hoàn tác phần ngoài phạm vi hoặc dừng và hỏi.
7. Gọi skill self-review.
8. Chạy git diff --stat và giữ nguyên kết quả cho báo cáo.
9. Gọi skill report-writer. Kết thúc. Không commit, không bắt đầu task khác.

## Điều kiện dừng (ghi vào Câu hỏi mở, không tự quyết)
| Tình huống | Hành động |
| --- | --- |
| Cần sửa file ngoài files_allowed | Dừng, nêu file và lý do |
| Cần đổi interface ngoài mục Hợp đồng | Dừng |
| Đặc tả mâu thuẫn ARCHITECTURE hoặc DECISIONS | Dừng |
| Cần dependency mới | Dừng |
| Test đỏ có sẵn trong baseline và chặn task | Dừng, báo BLOCKED |
| Cùng một lỗi sau 3 vòng sửa | Dừng, báo BLOCKED, chạy bug-brief |

## Ràng buộc
- Không mở rộng phạm vi, không refactor tiện tay, không đổi định dạng file không liên quan.
- Không sửa, xoá hay skip test có sẵn để làm nó pass. Nghĩ test sai thì nêu trong báo cáo.
- Cấm các cách làm cho pass giả: try/catch rỗng nuốt lỗi, hardcode giá trị kỳ vọng của test, tắt lint, ghi đè kết quả test.
- Không ghi "pass" nếu chưa chạy lệnh trong phiên này.

## Đầu ra
docs/reports/T-xxx.md (qua report-writer). Trạng thái cuối là DONE, PARTIAL hoặc BLOCKED.
```

### 5.5 Skill 4 — `test-first`

**Kích hoạt:** sau preflight, trước khi viết code. **Điểm thiết kế:** ép mỗi tiêu chí nghiệm thu thành một test có *mã AC trong tên*, nên báo cáo và verdict truy vết được từng tiêu chí. Bước “đỏ đúng lý do” loại bỏ test chưa bao giờ thất bại (vô nghĩa) và test hỏng vì lỗi dựng.

```markdown
---
name: test-first
description: Chuyển từng tiêu chí nghiệm thu AC-n của task thành test tự động trước khi cài đặt, rồi chạy để xác nhận test đỏ đúng lý do. Dùng sau preflight và trước khi viết code cài đặt của task. Không dùng để chạy test (dùng test-and-summarize) và không dùng để sửa test có sẵn.
---

# Test First

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
```

### 5.6 Skill 5 — `test-and-summarize` (kèm hai script)

**Kích hoạt:** mỗi lần chạy test, lint, build. **Điểm thiết kế:** log đầy đủ nằm trên đĩa; hội thoại chỉ nhận tóm tắt. `verify_task.sh` đọc các dòng `AC-n` trong file task và chạy từng `CMD`, để bạn kiểm chứng độc lập bằng **một lệnh**. Script chạy trên bash (Linux, macOS, Git Bash hoặc WSL trên Windows).

```markdown
---
name: test-and-summarize
description: Chạy lệnh test, lint hoặc build của dự án và chỉ trả về tóm tắt gọn (mã thoát, dòng lỗi, phần cuối log), hoặc chạy toàn bộ lệnh nghiệm thu của một task. Dùng mỗi khi cần chạy test trong lúc thi công, trước khi báo cáo, hoặc khi người dùng yêu cầu kiểm chứng task. Không dùng để viết hay sửa test.
---

# Test and Summarize

## Các bước
1. Chạy một lệnh: bash scripts/run_tests.sh -- <lệnh>
   Có thể thêm --timeout <giây> (mặc định 900).
2. Chạy toàn bộ AC của task: bash scripts/verify_task.sh docs/tasks/T-xxx.md
3. Chỉ đọc phần tóm tắt script in ra. Không dán toàn bộ log vào hội thoại hay báo cáo.
4. Nếu fail: nêu tên test fail và tối đa 30 dòng liên quan. Nếu cần thêm, mở log_file bằng grep hoặc tail, đừng cat.

## Điều kiện dừng
Có exit_code và dòng tổng kết. Không chạy lại vô tận: cùng một lệnh, cùng một lỗi, tối đa 3 vòng sửa.

## Ràng buộc
- Không dùng kết quả cũ thay cho lần chạy mới.
- Khi báo cáo, ghi nguyên lệnh và exit_code.
```

**`scripts/run_tests.sh`**

```bash
#!/usr/bin/env bash
# run_tests.sh [--timeout GIÂY] -- <lệnh...>
# Chạy lệnh, lưu log đầy đủ ra file, chỉ in tóm tắt. Trả về mã thoát của lệnh.
set -u
TIMEOUT=900
if [ "${1:-}" = "--timeout" ]; then TIMEOUT="${2:?thiếu số giây}"; shift 2; fi
[ "${1:-}" = "--" ] && shift
[ $# -gt 0 ] || { echo "Cách dùng: run_tests.sh [--timeout S] -- <lệnh>"; exit 2; }

mkdir -p .agents/.logs
LOG=".agents/.logs/run_$(date +%Y%m%d_%H%M%S)_$$.log"
START=$(date +%s)
if command -v timeout >/dev/null 2>&1; then
  timeout "$TIMEOUT" bash -c "$*" >"$LOG" 2>&1
else
  bash -c "$*" >"$LOG" 2>&1
fi
CODE=$?
DUR=$(( $(date +%s) - START ))

echo "cmd=$*"
echo "exit_code=$CODE duration_s=$DUR log_file=$LOG"
[ "$CODE" -eq 124 ] && echo "TIMEOUT sau ${TIMEOUT}s"
echo "--- dòng tổng kết ---"
grep -E -i '[0-9]+ (passed|failed)|Tests:|Test Suites:|^ok |^FAIL' "$LOG" | tail -5
echo "--- dòng lỗi (tối đa 40) ---"
grep -n -E 'FAIL|ERROR|Error:|AssertionError|panic|Traceback' "$LOG" | head -40
echo "--- 15 dòng cuối ---"
tail -15 "$LOG"
exit "$CODE"
```

**`scripts/verify_task.sh`**

```bash
#!/usr/bin/env bash
# verify_task.sh <docs/tasks/T-xxx.md>
# Dòng AC trong task:  - AC-1: <mô tả> | CMD: <lệnh> | EXPECT: <kỳ vọng>
# Script chỉ kiểm mã thoát (0 = đạt). Cột EXPECT để bạn đối chiếu bằng mắt.
# CMD không được chứa dấu |; cần pipe thì gói vào một script riêng.
set -u
TASK="${1:?Cách dùng: verify_task.sh docs/tasks/T-xxx.md}"
HERE="$(cd "$(dirname "$0")" && pwd)"
RE_AC='^[[:space:]]*-[[:space:]]*(AC-[0-9]+):'
RE_CMD='[|] CMD: (.*) [|] EXPECT: (.*)$'
FAILS=0; TOTAL=0
while IFS= read -r line; do
  [[ $line =~ $RE_AC ]] && AC="${BASH_REMATCH[1]}" || continue
  TOTAL=$((TOTAL+1))
  if [[ $line =~ $RE_CMD ]]; then
    CMD="${BASH_REMATCH[1]}"; EXP="${BASH_REMATCH[2]}"
  else
    echo "$AC | MANUAL (không có CMD), kiểm bằng tay"; continue
  fi
  OUT=$(bash "$HERE/run_tests.sh" -- "$CMD" 2>&1); CODE=$?
  SUM=$(echo "$OUT" | awk '/^--- dòng tổng kết/{f=1;next} /^---/{f=0} f' | tail -1)
  echo "$AC | exit=$CODE | kỳ vọng: $EXP | thực tế: ${SUM:-không có dòng tổng kết}"
  [ "$CODE" -ne 0 ] && FAILS=$((FAILS+1))
done < <(grep -E "$RE_AC" "$TASK")
echo "TỔNG: $TOTAL AC, $FAILS AC có exit khác 0"
[ "$FAILS" -eq 0 ]
```

### 5.7 Skill 6 — `scope-guard` (kèm script)

**Kích hoạt:** trước khi báo cáo, và bất cứ lúc nào nghi ngờ đã chạm file ngoài danh sách. **Điểm thiết kế:** đây là cơ chế biến nguyên tắc “báo cáo là lời khai” thành kiểm tra máy móc. Script so file thật sự đã đổi với `files_allowed` và quét ba dấu hiệu làm yếu test: test bị xoá, test bị skip, số assertion giảm. Mã thoát: `0` CLEAN, `1` VI\_PHAM, `2` lỗi đầu vào, `3` CLEAN nhưng có cảnh báo.

```markdown
---
name: scope-guard
description: Kiểm tra mọi file đã sửa hoặc tạo nằm trong files_allowed của task bằng script, và phát hiện dấu hiệu làm yếu test (xoá, skip, giảm assertion). Dùng trước khi báo cáo, sau mỗi cụm thay đổi lớn, hoặc khi nghi ngờ đã chạm file ngoài danh sách. Không dùng để review chất lượng code (dùng self-review).
---

# Scope Guard

## Các bước
1. Chạy: bash scripts/check_scope.sh docs/tasks/T-xxx.md [base_ref]
   base_ref mặc định là HEAD (chưa commit gì). Nếu đã commit trên nhánh, truyền nhánh gốc (ví dụ main).
2. Đọc dòng SCOPE ở đầu ra:
   - CLEAN: tiếp tục.
   - CLEAN_CO_CANH_BAO: từng cảnh báo phải được giải quyết hoặc nêu trong báo cáo mục Lệch so với đặc tả.
   - VI_PHAM: với mỗi file, chọn một trong hai: hoàn tác thay đổi (git checkout -- <file> hoặc xoá file mới), hoặc dừng và ghi Câu hỏi mở xin mở rộng phạm vi.
3. Chạy lại đến khi CLEAN hoặc đến khi chỉ còn ngoại lệ đã ghi Câu hỏi mở.

## Điều kiện dừng
Kết quả CLEAN, hoặc mọi ngoại lệ đã ghi vào Câu hỏi mở và báo trạng thái PARTIAL/BLOCKED.

## Ràng buộc
- Không sửa files_allowed trong file task để cho script qua.
- Không bỏ qua cảnh báo test bị skip hay xoá.
- Lockfile và file sinh tự động bị đổi cũng là vi phạm, trừ khi nằm trong files_allowed.

## Đầu ra
Dán nguyên dòng SCOPE và các dòng cảnh báo vào báo cáo.
```

**`scripts/check_scope.sh`**

```bash
#!/usr/bin/env bash
# check_scope.sh <docs/tasks/T-xxx.md> [base_ref]
# Mã thoát: 0 CLEAN | 1 VI_PHAM | 2 lỗi đầu vào | 3 CLEAN có cảnh báo
# Quy ước trong front matter: mục trỏ tới thư mục kết thúc bằng /, còn lại là file chính xác.
# Không bọc đường dẫn trong dấu nháy.
set -u
TASK="${1:-}"; BASE="${2:-HEAD}"
[ -f "$TASK" ] || { echo "ERROR: không thấy file task: $TASK"; exit 2; }
ID=$(basename "$TASK" .md)

ALLOWED=$(awk '
  /^---[[:space:]]*$/ { n++; next }
  n==1 && /^files_allowed:/ { f=1; next }
  n==1 && /^[A-Za-z_]+:/ { f=0 }
  n==1 && f && /^[[:space:]]*-[[:space:]]*/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); print }
' "$TASK")
[ -n "$ALLOWED" ] || { echo "ERROR: files_allowed rỗng hoặc thiếu"; exit 2; }
ALLOWED="$ALLOWED
docs/reports/$ID.md"

CHANGED=$( { git diff --name-only "$BASE"; git ls-files --others --exclude-standard; } | sort -u )

BAD=(); WARN=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  ok=0
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    case "$a" in
      */) case "$f" in "$a"*) ok=1 ;; esac ;;
      *)  [ "$f" = "$a" ] && ok=1 ;;
    esac
  done <<< "$ALLOWED"
  [ "$ok" -eq 0 ] && BAD+=("$f")
done <<< "$CHANGED"

# Dấu hiệu làm yếu test
DEL=$(git diff --name-status "$BASE" | awk '$1=="D" {print $2}' | grep -Ei 'test|spec' || true)
[ -n "$DEL" ] && WARN+=("Test bị xoá: $(echo "$DEL" | paste -sd' ' -)")
SKIP=$(git diff -U0 "$BASE" | grep -E '^[+][^+]' | grep -E '[.]skip[(]|xit[(]|xdescribe[(]|pytest[.]mark[.](skip|xfail)|t[.]Skip[(]|@Ignore|@Disabled|#[[]ignore[]]' || true)
[ -n "$SKIP" ] && WARN+=("Có dòng thêm mới làm test bị skip/xfail: $(echo "$SKIP" | head -3 | paste -sd' ' -)")
TESTS=$(echo "$CHANGED" | grep -Ei 'test|spec' || true)
if [ -n "$TESTS" ]; then
  RM=$(git diff -U0 "$BASE" -- $TESTS | grep -cE '^-[^-].*(assert|expect[(])' || true)
  AD=$(git diff -U0 "$BASE" -- $TESTS | grep -cE '^[+][^+].*(assert|expect[(])' || true)
  [ "${RM:-0}" -gt "${AD:-0}" ] && WARN+=("Số assertion giảm trong test: -$RM +$AD")
fi

if [ "${#BAD[@]}" -gt 0 ]; then
  echo "SCOPE: VI_PHAM"
  echo "File ngoài phạm vi (files_allowed):"
  for f in "${BAD[@]}"; do echo "  - $f"; done
fi
if [ "${#WARN[@]}" -gt 0 ]; then
  for w in "${WARN[@]}"; do echo "[CANH_BAO] $w"; done
fi
[ "${#BAD[@]}" -gt 0 ] && exit 1
if [ "${#WARN[@]}" -gt 0 ]; then echo "SCOPE: CLEAN_CO_CANH_BAO"; exit 3; fi
echo "SCOPE: CLEAN"
```

### 5.8 Skill 7 — `self-review`

**Kích hoạt:** sau khi test pass và scope-guard sạch. **Điểm thiết kế:** bắt lỗi mà test không bắt được (xử lý lỗi, bảo mật, rò rỉ log). Checklist có mã mục (`C1`–`C8`, `H1`–`H5`) để báo cáo và Claude nhắc lại đúng một mã. Với task rủi ro trung bình hoặc cao, nhóm `H` là bắt buộc.

```markdown
---
name: self-review
description: Tự rà soát thay đổi của task theo checklist (đúng Hợp đồng, trường hợp biên, xử lý lỗi, bảo mật, hiệu năng, log và secret) rồi ghi kết quả PASS hoặc FLAGS cho báo cáo. Dùng sau khi test pass và scope-guard CLEAN, ngay trước report-writer. Không dùng để thêm tính năng và không thay thế việc duyệt của kiến trúc sư.
---

# Self Review

## Đầu vào
git diff của task; mục Hợp đồng và trường risk trong docs/tasks/T-xxx.md.

## Các bước
1. Đọc git diff của task. Không đọc lại toàn bộ file.
2. Chạy checklist chung. Mỗi mục trả lời OK, FLAG hoặc N/A; FLAG phải kèm file:dòng.
   C1 Hành vi khớp từng dòng trong Hợp đồng (tên, chữ ký, kiểu trả về, mã lỗi).
   C2 Trường hợp biên: rỗng, null, âm, quá lớn, trùng lặp, đồng thời.
   C3 Xử lý lỗi: không nuốt lỗi; thông điệp lỗi hữu ích; tài nguyên được giải phóng.
   C4 Không còn code debug, print, TODO mới, code chết, import thừa.
   C5 Không log hay ghi ra bí mật, token, dữ liệu cá nhân.
   C6 Không thêm phụ thuộc, không đổi cấu hình dùng chung ngoài đặc tả.
   C7 Mỗi AC có test; không có test phụ thuộc thứ tự chạy hoặc thời gian thực.
   C8 Tên gọi và comment theo quy ước trong AGENTS.md.
3. Nếu risk là medium hoặc high, chạy thêm:
   H1 Đầu vào từ ngoài được kiểm tra và làm sạch trước khi dùng (SQL, đường dẫn, lệnh, HTML).
   H2 Kiểm tra quyền ở đúng tầng; không tin dữ liệu do client gửi.
   H3 Thao tác ghi (thanh toán, trừ kho, di chuyển dữ liệu) có tính nguyên tử và idempotent.
   H4 Đường nóng không tệ hơn về độ phức tạp; không thêm truy vấn trong vòng lặp.
   H5 Có đường hoàn tác (rollback, migration có bước lùi).
4. Với mỗi FLAG: nếu sửa được trong phạm vi thì sửa, chạy lại test-and-summarize và scope-guard (tính là một vòng sửa). Không sửa được thì giữ FLAG cho báo cáo.

## Điều kiện dừng
Mọi mục đã trả lời; mọi FLAG hoặc đã sửa hoặc đã ghi.

## Ràng buộc
- Không bịa FLAG cho có vẻ kỹ. Không sửa ngoài phạm vi. Không bỏ qua nhóm H khi risk từ medium.

## Đầu ra
Self-review: PASS | FLAGS. Mỗi FLAG một dòng: mã, file:dòng, mô tả, đã sửa hay chưa.
```

### 5.9 Skill 8 — `report-writer` (kèm mẫu)

**Kích hoạt:** cuối task. **Điểm thiết kế:** nâng cấp so với v1 ở ba chỗ. Có *bảng bằng chứng theo AC*, có *độ tin cậy tự đánh giá*, và bắt buộc dán nguyên đầu ra của `git diff --stat` và `check_scope.sh`. Giới hạn 300 từ áp dụng cho phần văn xuôi; bảng bằng chứng không tính nhưng mỗi ô chỉ một dòng.

```markdown
---
name: report-writer
description: Viết báo cáo hoàn thành task theo mẫu cố định vào docs/reports/T-xxx.md, gồm bảng bằng chứng theo từng AC. Dùng khi kết thúc một task hoặc khi người dùng yêu cầu báo cáo. Không dùng để báo cáo lỗi khó (dùng bug-brief).
---

# Report Writer

## Đầu vào
Bảng AC <-> test từ test-first; kết quả test-and-summarize; đầu ra scope-guard; kết quả self-review; git diff --stat.

## Các bước
1. Sao chép references/REPORT_TEMPLATE.md thành docs/reports/T-xxx.md.
2. Điền bảng bằng chứng: mỗi AC một hàng, ghi lệnh thật đã chạy trong phiên này và kết quả (exit, số test).
3. Dán nguyên đầu ra git diff --stat và dòng SCOPE từ check_scope.sh.
4. Liệt kê mọi quyết định tự đưa ra và mọi chỗ lệch đặc tả. Không có thì ghi "Không có".
5. Chép kết quả self-review. Chỉ ra tối đa 3 điểm Claude nên xem kỹ, mỗi điểm có file:dòng.
6. Chọn trạng thái: DONE chỉ khi mọi AC có bằng chứng pass và scope không VI_PHAM; ngược lại PARTIAL hoặc BLOCKED.
7. Tự đánh giá độ tin cậy cao / vừa / thấp và nêu lý do một dòng.

## Điều kiện dừng
File báo cáo ghi xong, phần văn xuôi không quá 300 từ.

## Ràng buộc
- Chỉ ghi điều đã kiểm chứng bằng lệnh. Đã test thì phải kèm lệnh và kết quả.
- Không dán code dài. Chỉ trích tối đa 15 dòng cho thay đổi rủi ro cao.
- Không làm tròn: 5/6 test pass là PARTIAL, không phải DONE.
- Chưa xong hoặc chưa chắc thì ghi PARTIAL hoặc BLOCKED.
```

**`references/REPORT_TEMPLATE.md`**

```markdown
# Báo cáo T-xxx: <tên>
Trạng thái: DONE | PARTIAL | BLOCKED
Nhánh / commit cơ sở: <task/T-xxx-slug> / <hash ngắn>
Preflight: READY. Baseline: <N pass, M fail có sẵn>

## Bằng chứng nghiệm thu
| AC | Test hoặc lệnh | Kết quả (exit, số test) | Ghi chú |
| --- | --- | --- | --- |
| AC-1 | | | |

Kiểm tra hồi quy: <lệnh> -> <kết quả so với baseline>

## Phạm vi
git diff --stat: (dán nguyên đầu ra)
check_scope.sh: CLEAN | CLEAN_CO_CANH_BAO | VI_PHAM (kèm giải thích)

## Quyết định tự đưa ra
- <quyết định>: <lý do một dòng>

## Lệch so với đặc tả
- <chỗ lệch>

## Self-review: PASS | FLAGS
- <mã, file:dòng, mô tả, đã sửa hay chưa>

## Điểm Claude nên xem kỹ
- <file:dòng>: <vì sao>

## Câu hỏi mở
- <câu hỏi>

## Độ tin cậy tự đánh giá
cao | vừa | thấp: <lý do một dòng>
```

### 5.10 Skill 9 — `bug-brief` (kèm mẫu)

**Kích hoạt:** task fail sau 3 vòng sửa, hoặc BLOCKED vì lỗi không rõ nguyên nhân. **Điểm thiết kế:** brief giúp Claude suy luận mà không cần đọc code. Phần quan trọng nhất là *Đã thử*: những gì thất bại, vì chính nó loại bỏ giả thuyết và tránh lặp lại.

```markdown
---
name: bug-brief
description: Đóng gói một lỗi khó hoặc task bị kẹt thành brief ngắn docs/reports/BUG-xxx.md để gửi cho kiến trúc sư. Dùng khi một task fail sau 3 vòng sửa, khi bị BLOCKED không rõ nguyên nhân, hoặc khi người dùng nói đóng gói lỗi. Không dùng để sửa lỗi và không dùng cho lỗi đã biết cách sửa.
---

# Bug Brief

## Đầu vào
Task hiện tại; log đã lưu từ test-and-summarize; các thử nghiệm đã làm.

## Các bước
1. Sao chép references/BUG_TEMPLATE.md thành docs/reports/BUG-xxx.md (số kế tiếp).
2. Tìm cách tái hiện nhỏ nhất: một lệnh, một đầu vào. Ghi lệnh và kết quả thật.
3. Ghi tối đa 5 mục Đã thử: giả thuyết -> hành động -> kết quả. Ghi cả mục thất bại.
4. Ghi giả thuyết còn lại, xếp theo khả năng, mỗi giả thuyết kèm cách kiểm.
5. Đính kèm tối đa 40 dòng log liên quan nhất và tối đa 40 dòng code nghi vấn (file:dòng). Che mọi secret.
6. Ghi phạm vi ảnh hưởng: task nào khác có thể bị chặn.

## Điều kiện dừng
Brief ghi xong. Dừng, chờ chỉ đạo. Không tiếp tục sửa.

## Ràng buộc
- Không đề xuất sửa lớn hoặc thiết kế lại.
- Không giấu thử nghiệm thất bại, không tô hồng.
- Không dán log đầy đủ.
```

**`references/BUG_TEMPLATE.md`**

```markdown
# BUG-xxx: <tiêu đề một dòng>
Task liên quan: T-xxx   Mức khẩn: chặn milestone | chặn task khác | không chặn

## Triệu chứng
<kỳ vọng so với thực tế, 2-3 dòng>

## Tái hiện nhỏ nhất
Lệnh: <lệnh>   Kết quả: <exit, thông báo lỗi chính>   Ổn định: luôn | thỉnh thoảng (x/y lần)

## Môi trường
<hệ điều hành, phiên bản runtime, commit cơ sở>

## Đã thử (tối đa 5)
1. Giả thuyết: <...>. Hành động: <...>. Kết quả: <...>.

## Giả thuyết còn lại (xếp theo khả năng)
1. <giả thuyết>. Cách kiểm: <lệnh hoặc quan sát>.

## Log liên quan (tối đa 40 dòng)
<...>

## Code nghi vấn (tối đa 40 dòng, file:dòng)
<...>

## Phạm vi ảnh hưởng
<task hoặc module bị chặn>
```

### 5.11 Skill 10 — `diff-packager` (kèm script)

**Kích hoạt:** khi Claude ra verdict NEED-DIFF. **Điểm thiết kế:** thay vì để bạn tự cắt diff bằng tay (dễ dán thừa hoặc lộ secret), script in đúng một file, bỏ nhiễu khoảng trắng, che các mẫu secret phổ biến và cắt ở 40 dòng. Script che bằng `sed` của GNU; trên macOS cài `gnu-sed` hoặc chạy trong WSL. **Không thay cho việc bạn tự nhìn lại trước khi dán.**

```markdown
---
name: diff-packager
description: Trích đúng đoạn diff mà kiến trúc sư yêu cầu (một file, một hàm hoặc dải dòng), tối đa 40 dòng, bỏ nhiễu khoảng trắng và che secret, để người dùng dán vào chat Claude. Dùng khi nhận verdict NEED-DIFF hoặc khi người dùng cần gửi diff cho Claude. Không dùng để gửi toàn bộ diff của task.
---

# Diff Packager

## Đầu vào
Tên file (và hàm hoặc dải dòng) do kiến trúc sư chỉ định; commit cơ sở của task.

## Các bước
1. Chạy: bash scripts/package_diff.sh <file> [base_ref] [max_lines]
2. Nếu đầu ra báo CẮT, thu hẹp theo hàm hoặc dải dòng được yêu cầu thay vì tăng max_lines.
3. Đọc lại đầu ra, xác nhận không còn secret hay dữ liệu cá nhân.
4. In khối diff kèm một dòng tiêu đề file:dòng.

## Điều kiện dừng
Có khối diff không quá 40 dòng cho đúng phần được yêu cầu.

## Ràng buộc
- Mỗi lần chỉ một file hoặc một phần được chỉ định.
- Không thêm bình luận hay giải thích vào diff.
```

**`scripts/package_diff.sh`**

```bash
#!/usr/bin/env bash
# package_diff.sh <file> [base_ref] [max_lines]
# Cần GNU sed (cờ I). Che các mẫu secret phổ biến; luôn tự đọc lại trước khi dán.
set -u
FILE="${1:?Cách dùng: package_diff.sh <file> [base_ref] [max_lines]}"
BASE="${2:-HEAD}"; MAX="${3:-40}"
OUT=$(git diff -U3 --ignore-all-space --ignore-blank-lines "$BASE" -- "$FILE" \
  | grep -v -E '^(index |diff --git)' \
  | sed -E 's/(api[_-]?key|secret|token|password|passwd|authorization|bearer)([[:space:]]*[=:][[:space:]]*)[^[:space:],;]+/\1\2***REDACTED***/Ig')
TOTAL=$(echo "$OUT" | wc -l)
echo "# diff: $FILE (so với $BASE)"
echo "$OUT" | head -n "$MAX"
[ "$TOTAL" -gt "$MAX" ] && echo "# CẮT: còn $((TOTAL-MAX)) dòng nữa. Chỉ định hàm hoặc dải dòng hẹp hơn."
exit 0
```

### 5.12 Skill 11 — `git-commit-formatter`

**Kích hoạt:** sau ACCEPT, khi bạn yêu cầu commit. **Điểm thiết kế:** bạn có thể lấy bản gốc trong repo `rominirani/antigravity-skills` (nguồn nêu ở v1) rồi sửa theo bản dưới đây để gắn mã task và quy tắc “không push”. Skill này **không** chạy tự động sau khi thi công.

```markdown
---
name: git-commit-formatter
description: Viết commit message theo Conventional Commits cho thay đổi của một task đã được ACCEPT, kèm footer mã task. Dùng khi người dùng yêu cầu commit sau khi duyệt xong hoặc hỏi cách viết commit message. Không dùng khi task chưa ACCEPT và không bao giờ tự push.
---

# Git Commit Formatter

## Các bước
1. Chạy git status --short và git diff --stat. Xác nhận chỉ có file thuộc files_allowed (chạy scope-guard nếu chưa).
2. Chọn type: feat, fix, refactor, test, docs, chore, perf, build, ci. Chọn scope là module chính (ví dụ auth).
3. Dòng tiêu đề: type(scope): mô tả mệnh lệnh, chữ thường, tối đa 72 ký tự, không dấu chấm cuối.
4. Thân (nếu cần): giải thích vì sao, không giải thích cách làm. Ngắt dòng ở 72 ký tự.
5. Footer: dòng Task: T-xxx; thêm Refs: D-nnn nếu có quyết định liên quan; thêm BREAKING CHANGE: nếu đổi interface công khai.
6. In message cho người dùng xem. Chỉ chạy git commit khi người dùng xác nhận. Không chạy git push.

## Điều kiện dừng
Message đã in; commit chỉ chạy sau xác nhận.

## Ràng buộc
- Một task, một commit (hoặc một chuỗi commit nhỏ cùng mã Task).
- Không gộp thay đổi của task khác.
```

Ví dụ commit message đúng chuẩn: tiêu đề `feat(auth): expire refresh tokens after 30 days`, thân một đoạn nêu lý do (giảm rủi ro token bị lộ), footer `Task: T-007` và `Refs: D-012`.

## 6. Workflows

Workflow là chuỗi bước do bạn gọi chủ động bằng `/tên`. Mỗi workflow ngắn (dưới 4.000 ký tự) và chỉ **gọi skill**, không chứa logic. Chú thích `// turbo` đặt trước một bước cho phép bước đó chạy lệnh mà không hỏi xác nhận; chỉ dùng cho lệnh **chỉ đọc** hoặc không có tác dụng phụ (đúng như bản v1). Hãy kiểm tra cú pháp này trong bản Antigravity bạn đang dùng.

| Workflow | Khi nào gọi | Gọi skill | Dừng ở đâu |
| --- | --- | --- | --- |
| `/digest` | Đầu và cuối milestone | `repo-digest` | Sau khi cập nhật `DIGEST.md` |
| `/preflight` | Trước khi giao task, để thử | `task-preflight` | Sau khối PREFLIGHT |
| `/run-task` | Thi công một task | `task-executor` (kéo theo các skill khác) | Sau báo cáo |
| `/review-prep` | Sau thi công, trước khi dán cho Claude | `test-and-summarize`, `scope-guard` | Sau khi ghi gói duyệt |
| `/bug-brief` | Task fail 3 vòng hoặc BLOCKED | `bug-brief` | Sau khi ghi brief |
| `/close-milestone` | Cuối milestone | `repo-digest`, `test-and-summarize` | Sau khi in danh sách lưu trữ |

### 6.1 `.agents/workflows/digest.md`

```markdown
---
description: Cập nhật docs/DIGEST.md để gửi cho kiến trúc sư
---
// turbo
1. Chạy git status --short và git rev-parse --short HEAD để ghi trạng thái hiện tại.
2. Dùng skill repo-digest để tạo hoặc cập nhật docs/DIGEST.md.
3. Báo ngắn gọn: mục đã cập nhật, mục chưa xác minh, vùng nóng nặng nhất. Không dán nội dung digest vào chat.
```

### 6.2 `.agents/workflows/preflight.md`

```markdown
---
description: Kiểm tra một task có đủ điều kiện thi công, không viết code
---
1. Hỏi mã task nếu người dùng chưa nêu.
2. Dùng skill task-preflight.
3. In khối PREFLIGHT. Dừng. Không sửa đặc tả, không bắt đầu thi công.
```

### 6.3 `.agents/workflows/run-task.md`

```markdown
---
description: Thi công trọn một task từ docs/tasks và ghi báo cáo
---
1. Hỏi mã task nếu người dùng chưa nêu (ví dụ T-007).
2. Xác nhận đang ở nhánh task/T-xxx-*. Nếu không, dừng và nhắc người dùng tạo nhánh.
3. Dùng skill task-executor (gồm preflight, test-first, cài đặt, scope-guard, self-review, report-writer).
// turbo
4. Chạy git diff --stat rồi đối chiếu với mục Phạm vi trong báo cáo.
5. Dừng. Không commit, không push, không làm task khác.
```

### 6.4 `.agents/workflows/review-prep.md`

Chạy workflow này trong **một phiên mới** (không phải phiên đã thi công) hoặc chạy hai script trực tiếp ở terminal. Phiên mới không mang theo giả định của phiên thi công, nên kiểm chứng khách quan hơn.

```markdown
---
description: Đóng gói gói duyệt để dán cho Claude (báo cáo, kiểm chứng độc lập, phạm vi)
---
1. Hỏi mã task nếu người dùng chưa nêu.
// turbo
2. Chạy bash .agents/skills/test-and-summarize/scripts/verify_task.sh docs/tasks/T-xxx.md
// turbo
3. Chạy bash .agents/skills/scope-guard/scripts/check_scope.sh docs/tasks/T-xxx.md rồi git diff --stat
4. Ghi .agents/.logs/packet_T-xxx.md gồm 4 phần theo thứ tự: nội dung docs/reports/T-xxx.md; đầu ra bước 2; đầu ra bước 3; danh sách chỗ báo cáo khác với kết quả thật (nếu có).
5. Dừng. In đường dẫn file gói duyệt. Không sửa báo cáo.
```

### 6.5 `.agents/workflows/bug-brief.md`

```markdown
---
description: Đóng gói lỗi khó thành brief ngắn để gửi cho kiến trúc sư
---
1. Dùng skill bug-brief để ghi docs/reports/BUG-xxx.md.
2. Dừng và chờ chỉ đạo. Không đề xuất sửa lớn, không tiếp tục sửa.
```

### 6.6 `.agents/workflows/close-milestone.md`

```markdown
---
description: Đóng milestone, chạy kiểm tra cuối, digest cuối và chuẩn bị lưu trữ
---
1. Đọc docs/PLAN.md, liệt kê task của milestone chưa DONE. Còn task thì dừng và in danh sách.
// turbo
2. Chạy toàn bộ test của dự án bằng skill test-and-summarize. Fail thì dừng.
3. Dùng skill repo-digest để cập nhật docs/DIGEST.md.
4. Đếm số mục trong docs/DECISIONS.md; in số lượng và các mục thuộc milestone này. Không sửa file.
5. In danh sách file cần chuyển vào docs/archive/M-nn/ (tasks và reports của milestone). Không tự di chuyển; chờ người dùng xác nhận.
6. Nhắc người dùng tạo tag git milestone-M-nn sau khi merge.
```

## 7. Bộ mẫu phía Claude chat

### 7.1 Hướng dẫn cho Project (dán vào instructions)

```
Vai trò: kiến trúc sư phần mềm và người duyệt của dự án <tên>. Bạn không viết code triển khai dài. Bạn viết đặc tả task, ghi quyết định kiến trúc và duyệt báo cáo.

Đầu vào bạn nhận: DIGEST, ARCHITECTURE, DECISIONS (có thể bản nén), PLAN, task hiện tại, báo cáo task, gói duyệt, diff do chính bạn chỉ định.

Quy tắc:
1. Chỉ dựa vào tài liệu được dán. Thiếu thông tin thì hỏi một câu cụ thể hoặc ghi rõ giả định. Không đoán tên file hay chữ ký hàm.
2. Mọi quyết định kiến trúc thành một mục DECISIONS (mẫu D-nnn, tối đa 6 dòng) và cập nhật PLAN. Quyết định chỉ nằm trong chat là quyết định chưa tồn tại.
3. Mỗi task tối đa khoảng 5 file, đặc tả tối đa 40 dòng, dùng đúng mẫu TASK. Mỗi tiêu chí viết dạng: - AC-n: <mô tả> | CMD: <lệnh> | EXPECT: <kỳ vọng định lượng>. CMD không chứa dấu |.
4. Task không có AC chạy được bằng lệnh thì viết lại, không giao.
5. Khi duyệt, chạy rubric 8 điểm (mục 7.4) và ra đúng một verdict: ACCEPT, REVISE, NEED-DIFF hoặc REPLAN, kèm lý do tối đa 5 dòng.
6. Không chấp nhận “đã xong” thiếu bằng chứng. Thiếu thì yêu cầu đúng một lệnh cụ thể.
7. Task rủi ro cao (bảo mật, thanh toán, dữ liệu): mặc định NEED-DIFF cho file nhạy cảm, tối đa 40 dòng mỗi lần.
8. Khi REVISE: sửa đặc tả (làm rõ AC, thu hẹp phạm vi). Không viết code hộ.
9. Mỗi lượt có thay đổi tài liệu: xuất sẵn nội dung file đầy đủ hoặc đoạn cần thay, ghi rõ tên file.
10. Giữ phản hồi ngắn. Không nhắc lại nội dung đã dán.
```

### 7.2 Prompt mở đầu milestone

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

### 7.3 Prompt chia task

```
Chia milestone M-nn thành task theo mẫu TASK.
- Mỗi task một mục tiêu, tối đa 5 file, đặc tả không quá 40 dòng, có trường risk.
- Sắp theo phụ thuộc; đánh dấu task nào chạy song song được (không chung file).
- Mỗi AC có CMD chạy được bằng công cụ trong AGENTS.md. Nếu cần hạ tầng test chưa có, tạo task riêng ở đầu danh sách.
- Cuối cùng xuất bảng PLAN.md và kiểm tra Definition of Ready cho từng task (đạt / chưa, lý do).
```

### 7.4 Rubric duyệt 8 điểm

Claude chạy đủ 8 điểm cho mọi báo cáo, rồi quy đổi sang verdict bằng bảng ở 7.5.

| # | Điểm kiểm | Đạt khi | Không đạt thì |
| --- | --- | --- | --- |
| 1 | Trạng thái | Báo cáo ghi DONE | PARTIAL hoặc BLOCKED: không ACCEPT |
| 2 | Bằng chứng nghiệm thu | Mỗi AC có lệnh và kết quả khớp EXPECT; kết quả `verify_task.sh` do bạn chạy độc lập khớp báo cáo | Yêu cầu đúng một lệnh bổ sung |
| 3 | Phạm vi | `git diff --stat` chỉ gồm file trong `files_allowed`; dòng `SCOPE: CLEAN` | Ngoại lệ phải có lý do hợp lý, nếu không thì REVISE |
| 4 | Toàn vẹn test | Không xoá, skip hay giảm assertion mà không giải thích | REVISE |
| 5 | Quyết định tự đưa ra và chỗ lệch | Từng mục chấp nhận được | Mục có ảnh hưởng kiến trúc thì ghi D-nnn; ảnh hưởng nhiều task thì REPLAN |
| 6 | Rủi ro | low: không cần xem diff. medium: xem “điểm nên xem kỹ”. high: xem diff file nhạy cảm | NEED-DIFF |
| 7 | Tác động tới task sau | Hợp đồng vừa tạo khớp với phần task phụ thuộc cần | Sửa đặc tả task sau, hoặc REPLAN |
| 8 | Độ tin cậy và câu hỏi mở | Độ tin cậy cao hoặc vừa; không còn câu hỏi mở chưa trả lời | Trả lời câu hỏi mở trước khi ACCEPT |

### 7.5 Quy đổi sang verdict

| Verdict | Dùng khi | Hành động tiếp theo |
| --- | --- | --- |
| **ACCEPT** | Cả 8 điểm đạt | Bạn commit bằng `git-commit-formatter`, merge, `PLAN.md` đổi sang DONE |
| **REVISE** | Thiếu hoặc sai bằng chứng; AC không pass; vi phạm phạm vi; test bị làm yếu; đặc tả mơ hồ gây hiểu sai | Claude nêu đúng lệnh cần chạy thêm hoặc sửa đặc tả; chạy lại Phase 3 |
| **NEED-DIFF** | Bằng chứng đủ nhưng cần nhìn code để quyết (rủi ro cao, vùng nhạy cảm, quyết định tự đưa ra có ảnh hưởng, báo cáo mơ hồ) | Bạn dùng `diff-packager` cho đúng file hoặc hàm Claude chỉ định, tối đa 40 dòng |
| **REPLAN** | Đặc tả hoặc kiến trúc sai từ gốc; hai task xung đột; quyết định tự đưa ra cần thành quyết định kiến trúc | Quay về Phase 1 hoặc 2, ghi D-nnn, sửa các task bị ảnh hưởng |

Prompt dán kèm gói duyệt:

```
Duyệt T-xxx. Bên dưới là gói duyệt: báo cáo, kết quả verify_task.sh chạy độc lập, check_scope.sh, git diff --stat.
Chạy rubric 8 điểm rồi trả theo mẫu:
Rubric: 1 đến 8, mỗi mục OK hoặc NOT OK kèm một dòng.
Verdict T-xxx: ACCEPT | REVISE | NEED-DIFF | REPLAN
Lý do (tối đa 5 dòng):
Yêu cầu tiếp theo: <lệnh hoặc diff cụ thể, hoặc đặc tả sửa đổi>
Cập nhật tài liệu: <PLAN / DECISIONS cần ghi, nếu có>
```

### 7.6 Mẫu tài liệu

**`docs/templates/TASK.md`** (đặc tả tối đa 40 dòng)

```markdown
---
id: T-xxx
title: <tên ngắn>
milestone: M-nn
status: READY
risk: low
depends_on: [T-yyy]
files_allowed:
  - src/module/file.ext
  - tests/module/file_test.ext
---
# T-xxx: <tên>
Mục tiêu: <1-2 câu>
Hợp đồng: <interface phải giữ hoặc phải tạo, kèm chữ ký, kiểu, mã lỗi>
Ràng buộc: <quy ước, thư viện được hoặc không được dùng>
Tiêu chí nghiệm thu:
- AC-1: <mô tả> | CMD: <lệnh> | EXPECT: <kết quả định lượng>
- AC-2: <mô tả> | CMD: <lệnh> | EXPECT: <kết quả định lượng>
Ngoài phạm vi: <việc KHÔNG làm>
Kết thúc: ghi docs/reports/T-xxx.md bằng report-writer
```

Lưu ý: trường `files_allowed` do `check_scope.sh` đọc, nên mỗi mục một dòng, bắt đầu bằng `  - `, không bọc dấu nháy, thư mục kết thúc bằng `/`. Báo cáo của chính task được tự động cho phép.

**`docs/ARCHITECTURE.md`** (tối đa 200 dòng). Khung mục lục:

1. Mục tiêu và phi mục tiêu.
2. Bối cảnh và ràng buộc (công nghệ, vận hành, tuân thủ).
3. Thành phần: bảng Module | Trách nhiệm | Interface chính.
4. Hợp đồng giữa các thành phần: chữ ký, định dạng dữ liệu, mã lỗi.
5. Luồng dữ liệu chính (2–3 luồng quan trọng nhất, dạng bước đánh số).
6. Mô hình dữ liệu (thực thể, quan hệ, ràng buộc).
7. Chất lượng: mục tiêu đo được cho hiệu năng, bảo mật, độ tin cậy.
8. Rủi ro và giả định chưa kiểm chứng.
9. Liên kết tới các mục DECISIONS chi phối.

**`docs/PLAN.md`**

| Task | Tên | Trạng thái | Phụ thuộc | Nhóm song song | Risk | Nhánh | Verdict / commit |
| --- | --- | --- | --- | --- | --- | --- | --- |
| T-001 |  | TODO | — | A | low |  |  |

**`docs/DECISIONS.md`** (mỗi mục tối đa 6 dòng)

```markdown
## D-012: <quyết định>
Bối cảnh: <1 dòng>
Quyết định: <1 dòng>
Phương án đã loại: <1 dòng, kèm lý do>
Hệ quả: <1 dòng>
Ngày / Task: <...>   Trạng thái: hiệu lực | thay thế bởi D-xxx
```

### 7.7 Prompt REPLAN và nén DECISIONS

```
REPLAN M-nn. Lý do: <...>. Tài liệu kèm: PLAN.md, các task bị ảnh hưởng, BUG hoặc báo cáo liên quan.
Yêu cầu:
1. Nêu nguyên nhân gốc ở mức kiến trúc hoặc đặc tả (không dừng ở triệu chứng).
2. Liệt kê task giữ nguyên, sửa, huỷ, thêm.
3. Xuất mục D-nnn mới và bản PLAN.md mới.
4. Nói rõ phần code đã merge có phải hoàn tác không, và task nào.
```

```
Nén DECISIONS.md. Giữ nguyên đầy đủ các quyết định còn hiệu lực và đang chi phối thiết kế. Gộp quyết định cũ hoặc đã bị thay thế thành bảng: ID | Quyết định | Lý do (1 dòng) | Trạng thái. Không làm mất ID. Xuất bản nén và danh sách mục chuyển vào docs/archive/.
```
