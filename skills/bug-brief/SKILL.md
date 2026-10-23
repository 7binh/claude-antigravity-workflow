---
name: bug-brief
description: Đóng gói một lỗi khó hoặc task bị kẹt thành brief ngắn docs/reports/BUG-xxx.md để gửi cho kiến trúc sư. Dùng khi một task fail sau 3 vòng sửa, khi bị BLOCKED không rõ nguyên nhân, hoặc khi người dùng nói đóng gói lỗi. Không dùng để sửa lỗi và không dùng cho lỗi đã biết cách sửa.
---

# Bug Brief

## Mục tiêu
Brief giúp kiến trúc sư suy luận mà không cần đọc code. Phần quan trọng nhất là "Đã thử": thử nghiệm thất bại loại bỏ giả thuyết và tránh lặp lại.

## Đầu vào
Task hiện tại; log đã lưu từ test-and-summarize; các thử nghiệm đã làm.

## Các bước
1. Sao chép references/BUG_TEMPLATE.md (cạnh SKILL.md này) thành docs/reports/BUG-xxx.md (số kế tiếp).
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

## Đầu ra
docs/reports/BUG-xxx.md.
