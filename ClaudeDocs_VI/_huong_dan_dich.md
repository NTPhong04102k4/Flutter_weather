# Hướng dẫn dịch (dành cho agent dịch thuật)

Bạn đang dịch tài liệu chính thức của **Claude Code** sang tiếng Việt. Với MỖI URL được giao:

## Bước 1 — Tải nội dung gốc
Dùng công cụ `WebFetch` với prompt:
> "Return the complete raw markdown content of this page verbatim, including all headings, tables, code blocks, notes/callouts, tabs, images and lists. Do not summarize, do not omit anything."

## Bước 2 — Dịch sang tiếng Việt (SÁT NGUYÊN VĂN)
Quy tắc bắt buộc:
- **Giữ nguyên 100% cấu trúc markdown**: heading, bảng, list, blockquote, ảnh (`<img>`), tab.
- **KHÔNG dịch** nội dung bên trong: code block, câu lệnh CLI, đường dẫn file, tên flag/tham số, key cấu hình (settings.json), URL, tên biến/hàm/định danh code.
- **Giữ nguyên các thuật ngữ kỹ thuật** (không dịch, có thể chú thích tiếng Việt trong ngoặc ở lần xuất hiện đầu): `skill`, `subagent`, `hook`, `plugin`, `MCP`, `CLAUDE.md`, `context window` (cửa sổ ngữ cảnh), `prompt`, `token`, `agent`, `worktree`, `checkpoint`, `slash command`, `marketplace`.
- Dịch phần văn xuôi, mô tả, tiêu đề cột bảng, chú thích thành tiếng Việt kỹ thuật tự nhiên, dễ hiểu.
- Giữ nguyên các link nội bộ tài liệu (ví dụ `/en/skills`) đúng như bản gốc.
- Dịch nội dung trong các callout/Note/Tip/Warning nhưng giữ nguyên loại callout.

## Bước 3 — Thêm header nguồn
Ở đầu mỗi file dịch, thêm 2 dòng:
```
> Nguồn: <URL gốc>
> Tài liệu Claude Code — bản dịch tiếng Việt
```
Sau đó cách 1 dòng trống rồi tới nội dung dịch.

## Bước 4 — Ghi file
Dùng công cụ `Write` ghi kết quả vào đúng đường dẫn đích được giao.

## Trả về
Chỉ trả về TÓM TẮT ngắn: danh sách file đã ghi + trang nào tải/dịch lỗi (nếu có).
**KHÔNG dán lại toàn bộ nội dung đã dịch** vào câu trả lời.
