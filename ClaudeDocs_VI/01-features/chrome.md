> Nguồn: https://code.claude.com/docs/en/chrome.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Sử dụng Claude Code với Chrome

> Kết nối Claude Code với trình duyệt Chrome của bạn để kiểm thử ứng dụng web, gỡ lỗi bằng console log, tự động điền biểu mẫu, và trích xuất dữ liệu từ các trang web.

Claude Code tích hợp với [tiện ích mở rộng trình duyệt Claude in Chrome](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) để cung cấp cho bạn các khả năng tự động hóa trình duyệt từ CLI hoặc từ [tiện ích mở rộng VS Code](/en/vs-code#automate-browser-tasks-with-chrome). Build code của bạn, sau đó kiểm thử và gỡ lỗi trong trình duyệt mà không cần chuyển đổi ngữ cảnh.

Claude mở các tab mới cho các tác vụ trình duyệt và chia sẻ trạng thái đăng nhập của trình duyệt bạn, vì vậy nó có thể truy cập bất kỳ trang web nào bạn đã đăng nhập. Các hành động trên trình duyệt chạy trong một cửa sổ Chrome hiển thị theo thời gian thực. Khi Claude gặp trang đăng nhập hoặc CAPTCHA, nó tạm dừng và yêu cầu bạn xử lý thủ công.

<Note>
  Tích hợp Chrome hoạt động với Google Chrome và Microsoft Edge. Hiện tại chưa được hỗ trợ trên Brave, Arc, hay các trình duyệt dựa trên Chromium khác. Nó cũng không được hỗ trợ trong Windows Subsystem for Linux (WSL).
</Note>

## Các khả năng

Với Chrome được kết nối, bạn có thể nối chuỗi các hành động trên trình duyệt với các tác vụ lập trình trong một quy trình làm việc duy nhất:

* **Gỡ lỗi trực tiếp (live debugging)**: đọc trực tiếp lỗi console và trạng thái DOM, sau đó sửa đoạn code đã gây ra chúng
* **Xác minh thiết kế**: build một giao diện UI từ bản mockup Figma, sau đó mở nó trong trình duyệt để xác minh nó khớp với thiết kế
* **Kiểm thử ứng dụng web**: kiểm thử việc xác thực biểu mẫu, kiểm tra hồi quy giao diện, hoặc xác minh các luồng người dùng
* **Ứng dụng web đã xác thực**: tương tác với Google Docs, Gmail, Notion, hoặc bất kỳ ứng dụng nào bạn đã đăng nhập mà không cần trình kết nối API
* **Trích xuất dữ liệu**: rút thông tin có cấu trúc từ các trang web và lưu nó cục bộ
* **Tự động hóa tác vụ**: tự động hóa các tác vụ trình duyệt lặp đi lặp lại như nhập liệu, điền biểu mẫu, hoặc các quy trình làm việc đa trang
* **Ghi lại phiên (session recording)**: ghi lại các tương tác trên trình duyệt dưới dạng GIF để tài liệu hóa hoặc chia sẻ những gì đã xảy ra

## Điều kiện tiên quyết

Trước khi sử dụng Claude Code với Chrome, bạn cần:

* Trình duyệt [Google Chrome](https://www.google.com/chrome/) hoặc [Microsoft Edge](https://www.microsoft.com/edge)
* [Tiện ích mở rộng Claude in Chrome](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) phiên bản 1.0.36 trở lên, có sẵn trong Chrome Web Store cho cả hai trình duyệt
* [Claude Code](/en/quickstart#step-1-install-claude-code) phiên bản 2.0.73 trở lên
* Một gói dịch vụ Anthropic trực tiếp (Pro, Max, Team, hoặc Enterprise)

<Note>
  Tích hợp Chrome không khả dụng thông qua các nhà cung cấp bên thứ ba như Amazon Bedrock, Agent Platform của Google Cloud, hay Microsoft Foundry. Nếu bạn truy cập Claude chỉ thông qua nhà cung cấp bên thứ ba, bạn cần một tài khoản claude.ai riêng để sử dụng tính năng này.
</Note>

## Bắt đầu trong CLI

<Steps>
  <Step title="Khởi chạy Claude Code với Chrome">
    Khởi động Claude Code với flag `--chrome`:

    ```bash theme={null}
    claude --chrome
    ```

    Bạn cũng có thể bật Chrome từ trong một phiên đang có sẵn bằng cách chạy `/chrome`.
  </Step>

  <Step title="Yêu cầu Claude sử dụng trình duyệt">
    Ví dụ này điều hướng đến một trang, tương tác với nó, và báo cáo những gì nó tìm thấy, tất cả từ terminal hoặc trình soạn thảo của bạn:

    ```text theme={null}
    Go to code.claude.com/docs, click on the search box,
    type "hooks", and tell me what results appear
    ```
  </Step>
</Steps>

Chạy `/chrome` bất kỳ lúc nào để kiểm tra trạng thái kết nối, quản lý quyền, kết nối lại tiện ích mở rộng, hoặc chọn trình duyệt được kết nối nào để sử dụng. Nếu có nhiều trình duyệt được kết nối khi một hành động trình duyệt bắt đầu, Claude nhắc bạn chọn một.

Đối với VS Code, xem [tự động hóa tác vụ trình duyệt trong VS Code](/en/vs-code#automate-browser-tasks-with-chrome).

### Bật Chrome mặc định

Để tránh phải truyền `--chrome` mỗi phiên, chạy `/chrome` và chọn "Enabled by default".

Trong [tiện ích mở rộng VS Code](/en/vs-code#automate-browser-tasks-with-chrome), Chrome khả dụng bất cứ khi nào tiện ích mở rộng Chrome được cài đặt. Không cần flag bổ sung.

<Note>
  Bật Chrome mặc định trong CLI làm tăng mức sử dụng context (ngữ cảnh) vì các công cụ trình duyệt luôn được nạp. Nếu bạn nhận thấy mức tiêu thụ context tăng lên, hãy tắt cài đặt này và chỉ dùng `--chrome` khi cần.
</Note>

### Quản lý quyền theo trang web

Quyền cấp độ trang web được kế thừa từ tiện ích mở rộng Chrome. Quản lý quyền trong cài đặt tiện ích mở rộng Chrome để kiểm soát những trang web nào Claude có thể duyệt, nhấp chuột, và gõ chữ.

### Các công cụ trình duyệt trong plan mode

Trong [plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode), các lệnh gọi công cụ trình duyệt chỉ đọc trang hoặc trạng thái trình duyệt chạy mà không có lời nhắc xin quyền, còn các lệnh gọi làm thay đổi trạng thái sẽ nhắc phê duyệt.

* **Các lệnh gọi chỉ đọc**: `read_page`, `get_page_text`, `find`, đọc các thông báo console hoặc yêu cầu mạng, và chụp ảnh màn hình
* **Các lệnh gọi làm thay đổi trạng thái**: nhấp chuột, gõ chữ, điều hướng, quản lý tab và cửa sổ, và ghi GIF

Kể từ v2.1.199, một lệnh gọi vốn chỉ đọc nhưng đặt một cờ đầu vào làm thay đổi trạng thái, chẳng hạn như `createIfEmpty` trên `tabs_context_mcp`, `clear` trên trình đọc console và mạng, hoặc `save_to_disk` trên ảnh chụp màn hình, cũng sẽ nhắc phê duyệt. Một lệnh gọi `browser_batch` chỉ chạy không cần lời nhắc khi mọi hành động bên trong nó đều là chỉ đọc.

## Các quy trình làm việc ví dụ

Các ví dụ này cho thấy những cách phổ biến để kết hợp các hành động trình duyệt với các tác vụ lập trình. Chạy `/mcp` và chọn `claude-in-chrome` để xem danh sách đầy đủ các công cụ trình duyệt khả dụng.

### Kiểm thử một ứng dụng web cục bộ

Khi phát triển một ứng dụng web, hãy yêu cầu Claude xác minh rằng các thay đổi của bạn hoạt động đúng:

```text theme={null}
I just updated the login form validation. Can you open localhost:3000,
try submitting the form with invalid data, and check if the error
messages appear correctly?
```

Claude điều hướng đến máy chủ cục bộ của bạn, tương tác với biểu mẫu, và báo cáo những gì nó quan sát được.

### Gỡ lỗi bằng console log

Claude có thể đọc đầu ra console để giúp chẩn đoán vấn đề. Hãy cho Claude biết cần tìm những mẫu nào thay vì yêu cầu toàn bộ đầu ra console, vì log có thể rất dài dòng:

```text theme={null}
Open the dashboard page and check the console for any errors when
the page loads.
```

Claude đọc các thông báo console và có thể lọc theo các mẫu cụ thể hoặc loại lỗi.

### Tự động điền biểu mẫu

Tăng tốc các tác vụ nhập liệu lặp đi lặp lại:

```text theme={null}
I have a spreadsheet of customer contacts in contacts.csv. For each row,
go to the CRM at crm.example.com, click "Add Contact", and fill in the
name, email, and phone fields.
```

Claude đọc tệp cục bộ của bạn, điều hướng giao diện web, và nhập dữ liệu cho từng bản ghi.

### Soạn thảo nội dung trong Google Docs

Sử dụng Claude để viết trực tiếp trong tài liệu của bạn mà không cần thiết lập API:

```text theme={null}
Draft a project update based on the recent commits and add it to my
Google Doc at docs.google.com/document/d/abc123
```

Claude mở tài liệu, nhấp vào trình soạn thảo, và gõ nội dung. Điều này hoạt động với bất kỳ ứng dụng web nào bạn đã đăng nhập: Gmail, Notion, Sheets, và nhiều hơn nữa.

### Trích xuất dữ liệu từ các trang web

Rút thông tin có cấu trúc từ các trang web:

```text theme={null}
Go to the product listings page and extract the name, price, and
availability for each item. Save the results as a CSV file.
```

Claude điều hướng đến trang, đọc nội dung, và biên soạn dữ liệu thành một định dạng có cấu trúc.

### Chạy các quy trình làm việc đa trang

Điều phối các tác vụ trên nhiều trang web:

```text theme={null}
Check my calendar for meetings tomorrow, then for each meeting with
an external attendee, look up their company website and add a note
about what they do.
```

Claude làm việc trên nhiều tab để thu thập thông tin và hoàn thành quy trình làm việc.

### Ghi một GIF demo

Tạo các bản ghi có thể chia sẻ của các tương tác trên trình duyệt:

```text theme={null}
Record a GIF showing how to complete the checkout flow, from adding
an item to the cart through to the confirmation page.
```

Claude ghi lại chuỗi tương tác và lưu nó dưới dạng tệp GIF.

## Xử lý sự cố

### Không phát hiện được tiện ích mở rộng

Nếu Claude Code không thể phát hiện tiện ích mở rộng Chrome:

1. Xác minh tiện ích mở rộng Chrome đã được cài đặt và bật trong `chrome://extensions`
2. Xác minh Claude Code là bản mới nhất bằng cách chạy `claude --version`
3. Kiểm tra rằng Chrome đang chạy
4. Chạy `/chrome` và chọn "Reconnect extension" để thiết lập lại kết nối
5. Nếu vấn đề vẫn còn, khởi động lại cả Claude Code và Chrome

Lần đầu tiên bạn bật tích hợp Chrome, Claude Code cài đặt một tệp cấu hình native messaging host. Chrome đọc tệp này khi khởi động, vì vậy nếu tiện ích mở rộng không được phát hiện trong lần thử đầu tiên của bạn, hãy khởi động lại Chrome để nhận cấu hình mới.

Kể từ v2.1.199, Claude Code mở một tab trình duyệt nhắc bạn kết nối tiện ích mở rộng chỉ trong lần cài đặt đầu tiên đó. Các phiên sau này ghi lại tệp cấu hình, ví dụ sau khi chuyển đổi các build của Claude Code hoặc các thư mục cấu hình, sẽ không mở lại nó.

Nếu kết nối vẫn thất bại, hãy xác minh tệp cấu hình host tồn tại tại:

Đối với Chrome:

* **macOS**: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
* **Linux**: `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
* **Windows**: kiểm tra `HKCU\Software\Google\Chrome\NativeMessagingHosts\` trong Windows Registry

Đối với Edge:

* **macOS**: `~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
* **Linux**: `~/.config/microsoft-edge/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`
* **Windows**: kiểm tra `HKCU\Software\Microsoft\Edge\NativeMessagingHosts\` trong Windows Registry

### Trình duyệt không phản hồi

Nếu các lệnh trình duyệt của Claude ngừng hoạt động:

1. Kiểm tra xem có hộp thoại modal (alert, confirm, prompt) đang chặn trang hay không. Các hộp thoại JavaScript chặn các sự kiện trình duyệt và ngăn Claude nhận lệnh. Đóng hộp thoại thủ công, sau đó bảo Claude tiếp tục.
2. Yêu cầu Claude tạo một tab mới và thử lại
3. Khởi động lại tiện ích mở rộng Chrome bằng cách tắt và bật lại nó trong `chrome://extensions`

### Kết nối bị ngắt trong các phiên dài

Service worker của tiện ích mở rộng Chrome có thể chuyển sang trạng thái nhàn rỗi trong các phiên kéo dài, làm gián đoạn kết nối. Nếu các công cụ trình duyệt ngừng hoạt động sau một khoảng thời gian không hoạt động, hãy chạy `/chrome` và chọn "Reconnect extension".

### Các vấn đề riêng của Windows

Trên Windows, bạn có thể gặp:

* **Xung đột named pipe (EADDRINUSE)**: nếu một tiến trình khác đang sử dụng cùng named pipe, hãy khởi động lại Claude Code. Đóng bất kỳ phiên Claude Code nào khác có thể đang sử dụng Chrome.
* **Lỗi native messaging host**: nếu native messaging host bị crash khi khởi động, hãy thử cài đặt lại Claude Code để tạo lại tệp cấu hình host.

### Các thông báo lỗi phổ biến

Đây là những lỗi thường gặp nhất và cách khắc phục:

| Lỗi                                  | Nguyên nhân                                       | Cách khắc phục                                                  |
| ------------------------------------ | ------------------------------------------------ | --------------------------------------------------------------- |
| "Browser extension is not connected" | Native messaging host không thể tiếp cận tiện ích mở rộng | Khởi động lại Chrome và Claude Code, sau đó chạy `/chrome` để kết nối lại |
| "Extension not detected"             | Tiện ích mở rộng Chrome chưa được cài đặt hoặc bị tắt | Cài đặt hoặc bật tiện ích mở rộng trong `chrome://extensions`   |
| "No tab available"                   | Claude đã cố hành động trước khi một tab sẵn sàng | Yêu cầu Claude tạo một tab mới và thử lại                        |
| "Receiving end does not exist"       | Service worker của tiện ích mở rộng chuyển sang nhàn rỗi | Chạy `/chrome` và chọn "Reconnect extension"                    |

## Xem thêm

* [Computer use](/en/computer-use): điều khiển các ứng dụng macOS native khi một tác vụ không thể thực hiện trong trình duyệt
* [Sử dụng Claude Code trong VS Code](/en/vs-code#automate-browser-tasks-with-chrome): tự động hóa trình duyệt trong tiện ích mở rộng VS Code
* [Tham chiếu CLI](/en/cli-reference): các flag dòng lệnh bao gồm `--chrome`
* [Các quy trình làm việc phổ biến](/en/common-workflows): thêm nhiều cách sử dụng Claude Code
* [Dữ liệu và quyền riêng tư](/en/data-usage): cách Claude Code xử lý dữ liệu của bạn
* [Bắt đầu với Claude in Chrome](https://support.claude.com/en/articles/12012173-getting-started-with-claude-in-chrome): tài liệu đầy đủ cho tiện ích mở rộng Chrome, bao gồm phím tắt, lập lịch, và quyền
