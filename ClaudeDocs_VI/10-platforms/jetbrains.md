> Nguồn: https://code.claude.com/docs/en/jetbrains.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Các IDE JetBrains

> Dùng Claude Code với các IDE JetBrains bao gồm IntelliJ, PyCharm, WebStorm, và nhiều hơn nữa

Claude Code tích hợp với các IDE JetBrains thông qua một plugin chuyên dụng, cung cấp các tính năng như xem diff tương tác, chia sẻ ngữ cảnh vùng chọn, và nhiều hơn nữa.

## Các IDE được hỗ trợ

Plugin Claude Code hoạt động với hầu hết các IDE JetBrains, bao gồm:

* IntelliJ IDEA
* PyCharm
* Android Studio
* WebStorm
* PhpStorm
* GoLand

## Tính năng

* **Khởi chạy nhanh**: dùng `Cmd+Esc` (Mac) hoặc `Ctrl+Esc` (Windows/Linux) để mở Claude Code trực tiếp từ editor của bạn, hoặc nhấp nút Claude Code trong giao diện
* **Xem diff**: các thay đổi mã có thể được hiển thị trực tiếp trong trình xem diff của IDE thay vì trong terminal
* **Ngữ cảnh vùng chọn**: vùng chọn hoặc tab hiện tại trong IDE được tự động chia sẻ với Claude Code. [Quy tắc từ chối `Read`](/en/permissions#read-and-edit) chặn việc chia sẻ này cho các tệp khớp
* **Phím tắt tham chiếu tệp**: dùng `Cmd+Option+K` (Mac) hoặc `Alt+Ctrl+K` (Linux/Windows) để chèn tham chiếu tệp như `@src/auth.ts#L1-99`
* **Chia sẻ chẩn đoán**: các lỗi chẩn đoán từ IDE, chẳng hạn như lỗi lint và lỗi cú pháp, được tự động chia sẻ với Claude khi bạn làm việc

## Cài đặt

Plugin chạy lệnh `claude` trong terminal tích hợp của IDE và kết nối với nó. Nó không đóng gói bản sao CLI riêng, nên hãy cài đặt cả hai phần:

<Steps>
  <Step title="Cài đặt Claude Code CLI">
    Theo [quickstart](/en/quickstart) để cài đặt CLI nếu bạn chưa có. Plugin hiển thị thông báo "Cannot launch Claude Code" khi `claude` không có trên PATH của bạn.
  </Step>

  <Step title="Cài đặt plugin JetBrains">
    Cài đặt [plugin Claude Code](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) từ JetBrains Marketplace và khởi động lại IDE của bạn.
  </Step>
</Steps>

Nếu `claude` được cài đặt ở nơi mà IDE của bạn không tìm thấy, hãy đặt đường dẫn đầy đủ trong [thiết lập Claude command](#general-settings) của plugin.

Claude Code hoạt động với bất kỳ gói đăng ký Claude trả phí nào (Pro, Max, Team, hoặc Enterprise) hoặc một tài khoản Claude Console, và không cần API key. Bạn sẽ được nhắc [đăng nhập](/en/authentication#log-in-to-claude-code) lần đầu tiên chạy `claude`.

<Note>
  Sau khi cài đặt plugin, bạn có thể cần khởi động lại hoàn toàn IDE để nó có hiệu lực.
</Note>

## Sử dụng

### Từ IDE của bạn

Chạy `claude` từ terminal tích hợp của IDE, và tất cả các tính năng tích hợp sẽ được kích hoạt.

### Từ các terminal bên ngoài

Dùng lệnh `/ide` trong bất kỳ terminal bên ngoài nào để kết nối Claude Code với IDE JetBrains của bạn và kích hoạt tất cả các tính năng:

```bash theme={null}
claude
```

```text theme={null}
/ide
```

Nếu bạn muốn Claude có quyền truy cập cùng các tệp như IDE của bạn, hãy khởi động Claude Code từ cùng thư mục với gốc dự án của IDE.

## Cấu hình

### Thiết lập Claude Code

Cấu hình tích hợp IDE thông qua thiết lập của Claude Code:

1. Chạy `claude`
2. Nhập lệnh `/config`
3. Đặt công cụ diff thành `auto` để hiển thị diff trong IDE, hoặc `terminal` để giữ chúng trong terminal

### Thiết lập plugin

Cấu hình plugin Claude Code bằng cách vào **Settings → Tools → Claude Code \[Beta]**:

#### Thiết lập chung

* **Claude command**: chỉ định một lệnh tùy chỉnh để chạy Claude, ví dụ `claude`, `/usr/local/bin/claude`, hoặc `npx @anthropic-ai/claude-code`
* **Suppress notification for Claude command not found**: bỏ qua các thông báo về việc không tìm thấy lệnh Claude
* **Enable using Option+Enter for multi-line prompts**: chỉ trên macOS. Khi được bật, Option+Enter chèn dòng mới trong các prompt Claude Code. Tắt nếu phím Option bị chiếm bất ngờ. Yêu cầu khởi động lại terminal.
* **Enable automatic updates**: tự động kiểm tra và cài đặt các bản cập nhật plugin, áp dụng khi khởi động lại

<Tip>
  Đối với người dùng WSL: Đặt `wsl -d Ubuntu -- bash -lic "claude"` làm lệnh Claude của bạn (thay `Ubuntu` bằng tên bản phân phối WSL của bạn)
</Tip>

#### Cấu hình phím ESC

Nếu phím ESC không ngắt các thao tác Claude Code trong terminal JetBrains:

1. Vào **Settings → Tools → Terminal**
2. Hoặc:
   * Bỏ chọn "Move focus to the editor with Escape", hoặc
   * Nhấp "Configure terminal keybindings" và xóa phím tắt "Switch focus to Editor"
3. Áp dụng các thay đổi

Điều này cho phép phím ESC ngắt đúng cách các thao tác Claude Code.

## Cấu hình đặc biệt

### Phát triển từ xa (Remote development)

<Warning>
  Khi dùng JetBrains Remote Development, bạn phải cài đặt plugin trên máy chủ từ xa qua **Settings → Plugin (Host)**.
</Warning>

Plugin phải được cài đặt trên máy chủ từ xa, không phải trên máy client cục bộ của bạn.

### Cấu hình WSL

Nếu bạn đang dùng Claude Code trên WSL2 với một IDE JetBrains và thấy "No available IDEs detected", nguyên nhân thường là mạng NAT của WSL2 hoặc Windows Firewall chặn kết nối giữa WSL2 và IDE chạy trên máy chủ Windows. WSL1 dùng mạng của máy chủ trực tiếp và không bị ảnh hưởng.

#### Cho phép lưu lượng WSL2 qua Windows Firewall

Đây là cách khắc phục được khuyến nghị vì nó giữ nguyên chế độ mạng WSL2 hiện có của bạn.

<Steps>
  <Step title="Tìm địa chỉ IP WSL2 của bạn">
    Từ bên trong shell WSL của bạn, chạy:

    ```bash theme={null}
    hostname -I
    ```

    Lưu ý subnet, ví dụ `172.21.123.45` nằm trong `172.21.0.0/16`.
  </Step>

  <Step title="Tạo một quy tắc tường lửa">
    Mở PowerShell với quyền Administrator và chạy lệnh sau, điều chỉnh dải IP để khớp với subnet của bạn:

    ```powershell theme={null}
    New-NetFirewallRule -DisplayName "Allow WSL2 Internal Traffic" -Direction Inbound -Protocol TCP -Action Allow -RemoteAddress 172.21.0.0/16 -LocalAddress 172.21.0.0/16
    ```
  </Step>

  <Step title="Khởi động lại IDE và Claude Code của bạn">
    Đóng và mở lại cả hai để quy tắc mới có hiệu lực.
  </Step>
</Steps>

#### Chuyển WSL2 sang mạng mirrored

Mạng mirrored yêu cầu Windows 11 22H2 trở lên. Nếu bạn đang dùng Windows 10, hãy dùng quy tắc tường lửa ở trên thay thế.

Thêm điều này vào `.wslconfig` trong thư mục người dùng Windows của bạn:

```ini theme={null}
[wsl2]
networkingMode=mirrored
```

Sau đó khởi động lại WSL với `wsl --shutdown` từ PowerShell.

## Khắc phục sự cố

### Plugin không hoạt động

Nếu plugin đã được cài đặt nhưng các tính năng Claude Code không xuất hiện trong IDE của bạn:

* Đảm bảo bạn đang chạy Claude Code từ thư mục gốc của dự án
* Kiểm tra rằng plugin JetBrains được bật trong thiết lập IDE
* Khởi động lại hoàn toàn IDE (bạn có thể cần làm điều này nhiều lần)
* Đối với Remote Development, đảm bảo plugin được cài đặt trên máy chủ từ xa

### Không phát hiện được IDE

Nếu chạy `claude` hiển thị "No available IDEs detected":

* Xác minh plugin đã được cài đặt và bật
* Khởi động lại hoàn toàn IDE
* Kiểm tra rằng bạn đang chạy Claude Code từ terminal tích hợp
* Đối với người dùng WSL, xem [Cấu hình WSL](#wsl-configuration) ở trên

### Không tìm thấy lệnh (Command not found)

Nếu nhấp vào biểu tượng Claude hiển thị "command not found":

1. Xác minh Claude Code đã được cài đặt bằng cách chạy `claude --version` trong terminal
2. Cấu hình đường dẫn lệnh Claude trong thiết lập plugin
3. Đối với người dùng WSL, dùng định dạng lệnh WSL được đề cập trong phần cấu hình

## Cân nhắc về bảo mật

Khi Claude Code chạy trong một IDE JetBrains ở [chế độ quyền `acceptEdits`](/en/permission-modes#auto-approve-file-edits-with-acceptedits-mode), nó có thể có khả năng sửa đổi các tệp cấu hình IDE mà có thể được IDE của bạn tự động thực thi. Điều này có thể làm tăng rủi ro khi chạy Claude Code ở chế độ `acceptEdits` và cho phép vượt qua các lời nhắc quyền của Claude Code đối với việc thực thi bash.

Khi chạy trong các IDE JetBrains, hãy cân nhắc:

* Dùng chế độ phê duyệt thủ công cho các chỉnh sửa
* Đặc biệt cẩn thận để đảm bảo Claude chỉ được dùng với các prompt đáng tin cậy
* Nhận thức được những tệp nào Claude Code có quyền sửa đổi

Đối với các vấn đề cài đặt hoặc đăng nhập Claude Code bên ngoài IDE, xem [Khắc phục sự cố cài đặt và đăng nhập](/en/troubleshoot-install).
