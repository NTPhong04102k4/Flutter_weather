> Nguồn: https://code.claude.com/docs/en/troubleshooting.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Xử lý sự cố

> Khắc phục tình trạng dùng CPU hoặc bộ nhớ cao, treo máy, auto-compact liên tục lặp (thrashing) và các vấn đề tìm kiếm trong Claude Code, đồng thời tìm đúng trang cho các sự cố khác.

Trang này bao quát các vấn đề về hiệu năng, độ ổn định và tìm kiếm sau khi Claude Code đã chạy. Với các vấn đề khác, hãy bắt đầu từ trang phù hợp với chỗ bạn đang gặp trở ngại:

| Triệu chứng                                                                                                                                              | Đến trang                                                                                    |
| :--------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------- |
| `command not found`, cài đặt thất bại, vấn đề PATH, `EACCES`, lỗi TLS                                                                                | [Xử lý sự cố cài đặt và đăng nhập](/en/troubleshoot-install)                          |
| Vòng lặp đăng nhập, lỗi OAuth, `403 Forbidden`, "organization disabled", thông tin xác thực Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry | [Xử lý sự cố cài đặt và đăng nhập](/en/troubleshoot-install#login-and-authentication) |
| Cấu hình (settings) không áp dụng, hook không kích hoạt, MCP server không tải được                                                                     | [Gỡ lỗi cấu hình của bạn](/en/debug-your-config)                                        |
| `API Error: 5xx`, `529 Overloaded`, `429`, lỗi xác thực request                                                                            | [Tham chiếu lỗi](/en/errors)                                                            |
| `model not found` hoặc `you may not have access to it`                                                                                                | [Tham chiếu lỗi](/en/errors#there%E2%80%99s-an-issue-with-the-selected-model)           |
| Tiện ích mở rộng VS Code không kết nối hoặc không nhận diện được Claude                                                                                 | [Tích hợp VS Code](/en/vs-code#fix-common-issues)                                     |
| Không phát hiện plugin JetBrains hoặc IDE                                                                                                   | [Tích hợp JetBrains](/en/jetbrains#troubleshooting)                                   |
| CPU hoặc bộ nhớ cao, phản hồi chậm, treo, tìm kiếm không thấy file                                                              | [Hiệu năng và độ ổn định](#performance-and-stability) bên dưới                            |

Nếu bạn không chắc trường hợp nào áp dụng, hãy chạy `/doctor` trong Claude Code để kiểm tra tự động phần cài đặt, cấu hình, MCP server và mức sử dụng context của bạn. Nếu `claude` hoàn toàn không khởi động được, hãy chạy `claude doctor` từ shell của bạn thay thế.

## Hiệu năng và độ ổn định

Các phần này bao quát các vấn đề liên quan đến việc sử dụng tài nguyên, khả năng phản hồi và hành vi tìm kiếm.

### Sử dụng CPU hoặc bộ nhớ cao

Claude Code được thiết kế để hoạt động với hầu hết các môi trường phát triển, nhưng có thể tiêu tốn tài nguyên đáng kể khi xử lý các codebase lớn. Nếu bạn đang gặp vấn đề về hiệu năng:

1. Dùng `/compact` thường xuyên để giảm kích thước context
2. Đóng và khởi động lại Claude Code giữa các tác vụ lớn
3. Cân nhắc thêm các thư mục build lớn vào file `.gitignore`
4. Khởi động lại với [`claude --safe-mode`](/en/cli-reference#cli-flags) để kiểm tra xem plugin, MCP server hay hook có phải là nguồn gốc hay không. Nó vô hiệu hóa toàn bộ tùy chỉnh cho phiên đó; nếu mức sử dụng giảm, xem [Gỡ lỗi cấu hình của bạn](/en/debug-your-config#test-against-a-clean-configuration) để tìm ra thủ phạm

Nếu mức sử dụng bộ nhớ vẫn cao sau các bước này, hãy chạy `/heapdump` để ghi một ảnh chụp (snapshot) heap JavaScript và bảng phân tích bộ nhớ ra `~/Desktop`. Trên Linux không có thư mục Desktop, các file được ghi vào thư mục home của bạn.

Bảng phân tích hiển thị resident set size, JS heap, array buffers và bộ nhớ native không rõ nguồn, giúp xác định xem sự tăng trưởng nằm ở các đối tượng JavaScript hay ở mã native. Để kiểm tra các retainer, mở file `.heapsnapshot` trong Chrome DevTools tại Memory → Load. Đính kèm cả hai file khi báo cáo vấn đề bộ nhớ trên [GitHub](https://github.com/anthropics/claude-code/issues).

### Auto-compaction dừng lại với lỗi thrashing

Nếu bạn thấy `Autocompact is thrashing: the context refilled to the limit...`, nghĩa là việc nén (compaction) tự động đã thành công nhưng một file hoặc output của tool ngay lập tức lấp đầy lại context window vài lần liên tiếp. Claude Code dừng thử lại để tránh lãng phí các lệnh gọi API vào một vòng lặp không tiến triển.

Để khắc phục:

1. Yêu cầu Claude đọc file quá lớn theo từng phần nhỏ hơn, chẳng hạn một khoảng dòng cụ thể hoặc một hàm, thay vì cả file
2. Chạy `/compact` với trọng tâm loại bỏ output lớn, ví dụ `/compact keep only the plan and the diff`
3. Chuyển công việc với file lớn sang một [subagent](/en/sub-agents) để nó chạy trong một context window riêng
4. Chạy `/clear` nếu không còn cần đến cuộc hội thoại trước đó

### Lệnh bị treo hoặc đóng băng

Nếu Claude Code có vẻ không phản hồi:

1. Nhấn Ctrl+C để thử hủy thao tác hiện tại
2. Nếu vẫn không phản hồi, bạn có thể cần đóng terminal và khởi động lại

Việc khởi động lại không làm mất cuộc hội thoại của bạn. Chạy `claude --resume` trong cùng thư mục để tiếp tục lại phiên làm việc.

### Văn bản bị lỗi hoặc hỏng trong terminal tích hợp của trình soạn thảo

Nếu các ký tự hiển thị thành ô vuông, vệt nhòe hoặc glyph sai khi chạy Claude Code trong terminal tích hợp của VS Code, Cursor hoặc Devin Desktop, nguyên nhân nhiều khả năng là bộ kết xuất (renderer) GPU của terminal. Chạy `/terminal-setup` trong Claude Code để đặt `terminal.integrated.gpuAcceleration` thành `"off"`, hoặc đặt thủ công trong phần cài đặt trình soạn thảo của bạn rồi tải lại cửa sổ. Xem [Cấu hình terminal](/en/terminal-config) để biết các cài đặt khác mà `/terminal-setup` ghi vào.

### Vấn đề tìm kiếm và phát hiện

Nếu tool Search, các trích dẫn `@file`, agent tùy chỉnh hoặc skill tùy chỉnh không tìm được file, có thể binary `ripgrep` đi kèm không chạy được trên hệ thống của bạn. Hãy cài gói `ripgrep` phù hợp với nền tảng của bạn và bảo Claude Code dùng nó thay thế:

<Tabs>
  <Tab title="macOS">
    ```bash theme={null}
    brew install ripgrep
    ```
  </Tab>

  <Tab title="Ubuntu/Debian">
    ```bash theme={null}
    sudo apt install ripgrep
    ```
  </Tab>

  <Tab title="Alpine">
    ```bash theme={null}
    apk add ripgrep
    ```
  </Tab>

  <Tab title="Arch">
    ```bash theme={null}
    pacman -S ripgrep
    ```
  </Tab>

  <Tab title="Windows">
    ```powershell theme={null}
    winget install BurntSushi.ripgrep.MSVC
    ```
  </Tab>
</Tabs>

Sau đó đặt `USE_BUILTIN_RIPGREP=0` trong [môi trường](/en/env-vars) của bạn.

### Kết quả tìm kiếm chậm hoặc không đầy đủ trên WSL

Việc suy giảm hiệu năng đọc đĩa khi [làm việc xuyên các hệ thống file trên WSL](https://learn.microsoft.com/en-us/windows/wsl/filesystems) có thể dẫn đến số kết quả khớp ít hơn dự kiến khi dùng Claude Code trên WSL. Tìm kiếm vẫn hoạt động, nhưng trả về ít kết quả hơn so với trên một hệ thống file native.

<Note>
  `/doctor` sẽ hiển thị Search là OK trong trường hợp này.
</Note>

**Giải pháp:**

1. **Gửi các truy vấn tìm kiếm cụ thể hơn**: giảm số lượng file cần tìm bằng cách chỉ định thư mục hoặc loại file: "Search for JWT validation logic in the auth-service package" hoặc "Find use of md5 hash in JS files".

2. **Chuyển dự án sang hệ thống file Linux**: nếu có thể, hãy đảm bảo dự án của bạn nằm trên hệ thống file Linux (`/home/`) thay vì hệ thống file Windows (`/mnt/c/`).

3. **Dùng Windows native thay thế**: cân nhắc chạy Claude Code trực tiếp trên Windows thay vì qua WSL, để có hiệu năng hệ thống file tốt hơn.

## Nhận thêm trợ giúp

Nếu bạn gặp các vấn đề không được đề cập ở đây:

1. Chạy `/doctor` để kiểm tra tình trạng cài đặt, tính hợp lệ của cấu hình, cấu hình MCP và mức sử dụng context trong một lượt
2. Dùng lệnh `/feedback` trong Claude Code để báo cáo vấn đề trực tiếp cho Anthropic
3. Kiểm tra [kho GitHub](https://github.com/anthropics/claude-code) để tìm các vấn đề đã biết
4. Hỏi Claude trực tiếp về các khả năng và tính năng của nó. Claude có sẵn quyền truy cập vào tài liệu của chính mình.
