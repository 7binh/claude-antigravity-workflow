# Thiết lập Antigravity

## Ba lớp cấu hình

Đặt nhầm lớp là nguyên nhân phổ biến nhất khiến cấu hình không chạy như mong muốn.

| Lớp | Vị trí | Nạp khi nào | Dùng cho |
| --- | --- | --- | --- |
| Rule | `AGENTS.md`; `.agents/rules/*.md`; toàn cục `~/.gemini/GEMINI.md` | Luôn nạp | Ràng buộc chung, lệnh build/test |
| Skill | Dự án: `.agents/skills/<tên>/SKILL.md`. Toàn cục: `~/.gemini/antigravity/skills/<tên>/` | Khi mô tả khớp việc đang làm | Kỹ năng có điều kiện kích hoạt, kèm script và mẫu |
| Workflow | `.agents/workflows/*.md` | Khi bạn gõ `/tên` | Chuỗi bước cố định bạn muốn tự bấm |

Workflow gọi skill; skill không gọi workflow; skill có thể gọi skill khác bằng tên.

## Đường dẫn: những điểm không thống nhất

CLI `skills` ghi nhận Antigravity dùng `.agents/skills/` (dự án) và `~/.gemini/antigravity/skills/` (toàn cục), nên `npx skills add ... -a antigravity` đặt vào đó. Tuy vậy, nguồn khác ghi nhận:

- Codelab của Google dùng `.agent/skills/` (số ít); bản mới vẫn hỗ trợ ngược.
- Một số bài viết bên thứ ba ghi `~/.gemini/config/skills/` cho toàn cục.
- Một nguồn bên thứ ba cho biết `AGENTS.md` được đọc như Rule từ IDE bản 1.20.5 trở đi; bản cũ hơn chỉ đọc `GEMINI.md`.

Vì vậy, sau khi cài:

1. Mở Antigravity trong dự án, hỏi: *"What skills are available?"*.
2. Thiếu skill: copy thư mục sang `.agent/skills/` (số ít) và hỏi lại.
3. Không thấy rule trong `AGENTS.md`: đặt cùng nội dung vào `.agents/rules/project.md`.

## Giới hạn nên nhớ

- Rules và Workflows có giới hạn khoảng 12.000 ký tự mỗi file (theo một nguồn bên thứ ba). Repo này giữ workflow dưới 4.000 ký tự (CI kiểm) và `AGENTS.md` dưới 60 dòng; chi tiết nằm trong skill.
- Chú thích `// turbo` đặt trước một bước cho phép bước đó chạy lệnh không cần xác nhận. Chỉ dùng cho lệnh chỉ đọc hoặc không có tác dụng phụ. Kiểm tra cú pháp này trên bản Antigravity bạn đang dùng.

## Không nên làm

- Cài hàng loạt skill cộng đồng. Có báo cáo chưa kiểm chứng rằng cài hơn 1.000 skill làm lần khởi tạo đầu chậm hàng chục phút. Chỉ cài skill bạn đã đọc.
- Dùng nguyên các bộ skill orchestrator bên thứ ba; phần lập kế hoạch đã do Claude làm.
- Nhồi quy trình vào `AGENTS.md`; phần đó tốn token ở mọi lượt.
- Viết một skill "làm mọi thứ"; tách theo từng việc riêng.

## Dùng với Claude Code

Các skill là SKILL.md chuẩn nên cũng cài được cho Claude Code: `npx skills add 7binh/claude-antigravity-workflow -a claude-code`. Workflow (`/tên`) chỉ có ở Antigravity.
