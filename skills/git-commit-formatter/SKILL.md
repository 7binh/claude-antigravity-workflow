---
name: git-commit-formatter
description: Viết commit message theo Conventional Commits cho thay đổi của một task đã được ACCEPT, kèm footer mã task. Dùng khi người dùng yêu cầu commit sau khi duyệt xong hoặc hỏi cách viết commit message. Không dùng khi task chưa ACCEPT và không bao giờ tự push.
---

# Git Commit Formatter

## Mục tiêu
Commit chuẩn Conventional Commits, truy vết được về task và quyết định.

## Đầu vào
Task đã ACCEPT (T-xxx); thay đổi trong working tree.

## Các bước
1. Chạy git status --short và git diff --stat. Xác nhận chỉ có file thuộc files_allowed (chạy scope-guard nếu chưa).
2. Chọn type: feat, fix, refactor, test, docs, chore, perf, build, ci. Chọn scope là module chính (ví dụ auth).
3. Dòng tiêu đề: type(scope): mô tả mệnh lệnh, chữ thường, tối đa 72 ký tự, không dấu chấm cuối.
4. Thân (nếu cần): giải thích vì sao, không giải thích cách làm. Ngắt dòng ở 72 ký tự.
5. Footer: dòng "Task: T-xxx"; thêm "Refs: D-nnn" nếu có quyết định liên quan; thêm "BREAKING CHANGE:" nếu đổi interface công khai.
6. In message cho người dùng xem. Chỉ chạy git commit khi người dùng xác nhận. Không chạy git push.

Ví dụ:

```
feat(auth): expire refresh tokens after 30 days

Giảm rủi ro token bị lộ kéo dài.

Task: T-007
Refs: D-012
```

## Điều kiện dừng
Message đã in; commit chỉ chạy sau xác nhận.

## Ràng buộc
- Một task, một commit (hoặc một chuỗi commit nhỏ cùng mã Task).
- Không gộp thay đổi của task khác.
- Không tự chạy sau khi thi công; chỉ chạy khi người dùng yêu cầu sau ACCEPT.
