> Nguồn: https://code.claude.com/docs/en/deep-links.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Khởi chạy phiên từ liên kết

> Mở một phiên terminal của Claude Code từ một URL. Nhúng các liên kết `claude-cli://` vào runbook, cảnh báo và dashboard để một cú nhấp chuột mở Claude Code trong đúng repo với đúng prompt.

Một deep link là một URL `claude-cli://` mở Claude Code trong một cửa sổ terminal mới. URL này có thể mang theo một thư mục làm việc và một prompt để điền sẵn.

Điều này cho phép bạn chia sẻ một điểm khởi đầu chỉ với một cú nhấp cho một tác vụ: bất kỳ ai đã cài Claude Code và nhấp vào liên kết sẽ thấy một phiên mở ra với prompt đã được gõ sẵn. Prompt được điền sẵn nhưng chưa được gửi cho đến khi bạn nhấn Enter.

Vì deep link là một URL, bạn có thể đặt nó ở bất cứ đâu một liên kết có thể đặt:

* Một bước trong runbook xử lý sự cố mở repo của dịch vụ bị ảnh hưởng với một prompt chẩn đoán
* Một cảnh báo giám sát hoặc dashboard liên kết đến một prompt điều tra cho một chỉ số cụ thể
* Một trang README hoặc wiki mở dự án với một prompt onboarding
* Một thông báo lỗi CI điền sẵn tên của job đang thất bại

Trang này bao gồm cách [xây dựng một liên kết](#build-a-link), [nhúng một liên kết vào runbook hoặc kích hoạt nó từ shell](#examples), và [quản lý hoặc vô hiệu hóa việc đăng ký handler](#registration-and-supported-platforms) trên mỗi nền tảng.

<Note>
  Deep link yêu cầu Claude Code v2.1.91 trở lên.
</Note>

## Cách hoạt động

Tiền tố `claude-cli://` là một lược đồ URL tùy chỉnh mà Claude Code đăng ký với hệ điều hành của bạn, tương tự cách các liên kết `mailto:` mở ứng dụng email của bạn. Liên kết có thể nằm trên một trang web, trong một wiki, trong một tin nhắn Slack, hoặc trong bất kỳ ứng dụng nào hiển thị liên kết. Khi bạn nhấp vào một liên kết:

1. Trình duyệt hoặc ứng dụng trao URL cho hệ điều hành của bạn.
2. Hệ điều hành nhận ra tiền tố `claude-cli://` và khởi động Claude Code trên máy của bạn.
3. Một cửa sổ terminal mới mở ra với Claude Code đang chạy trong thư mục mà liên kết chỉ định, và văn bản prompt của liên kết đã có sẵn trong ô nhập.
4. Bạn đọc prompt, chỉnh sửa nếu muốn, và nhấn Enter để gửi.

Bản thân liên kết có thể được lưu trữ ở bất cứ đâu, nhưng phiên luôn mở cục bộ trên máy tính nơi bạn đã nhấp. Xem [Đăng ký và các nền tảng được hỗ trợ](#registration-and-supported-platforms) để biết trình giả lập terminal (terminal emulator) nào mở trên mỗi hệ điều hành.

<Note>
  Nền tảng hiển thị liên kết phải cho phép các lược đồ URL tùy chỉnh. Markdown được GitHub kết xuất cho phép `http` và `https` nhưng loại bỏ các lược đồ như `claude-cli://` trong README, issue, pull request và wiki. Chỉ hiển thị phần văn bản của liên kết, không có liên kết phía sau và URL bị ẩn. Xem [Khắc phục sự cố](#the-link-renders-as-plain-text-instead-of-being-clickable) để biết cách xử lý.
</Note>

### Một phiên được khởi chạy sẽ hiển thị gì

Deep link không bao giờ tự thực thi bất cứ điều gì. Liên kết chỉ chọn một thư mục và điền vào ô prompt. Nếu bạn nhấp vào một liên kết từ một trang bạn không tin tưởng, prompt vẫn là bất động: không có gì đến được mô hình cho đến khi bạn đọc những gì đã được điền và nhấn Enter.

Khi phiên mở ra, một dòng cảnh báo dưới ô nhập ghi `Prompt from an external link` và vẫn hiển thị cho đến khi bạn gửi hoặc xóa prompt. Đối với các prompt dài hơn 1.000 ký tự, cảnh báo bao gồm số lượng ký tự và nhắc bạn cuộn xuống và rà soát toàn bộ văn bản trước khi nhấn Enter, vì các prompt dài có thể đẩy các chỉ dẫn ra khỏi màn hình. Các quy tắc quyền, `CLAUDE.md`, và các lời nhắc tin cậy (trust prompt) cho thư mục được chọn áp dụng theo cách giống như với bất kỳ phiên nào khác.

## Xây dựng một liên kết

Mỗi deep link bắt đầu bằng `claude-cli://open`, đây là đường dẫn duy nhất mà handler chấp nhận, theo sau là các tham số truy vấn tùy chọn. Dạng tối thiểu mở Claude Code trong thư mục home của bạn với một prompt trống:

```text theme={null}
claude-cli://open
```

Thêm các tham số để kiểm soát nơi phiên bắt đầu và nội dung ô prompt:

| Tham số   | Mô tả                                                                                                                                                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `q`       | Văn bản để điền sẵn vào ô prompt. Hãy [URL-encode](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) giá trị. Dùng `%0A` cho ngắt dòng trong các prompt nhiều dòng. Tối đa 5.000 ký tự.               |
| `cwd`     | Đường dẫn tuyệt đối để dùng làm thư mục làm việc. Các đường dẫn mạng và UNC bị từ chối, cũng như các đường dẫn chứa ký tự điều khiển vô hình hoặc hai chiều (bidirectional).                                                                            |
| `repo`    | Một slug GitHub dạng `owner/name`. Claude Code phân giải nó thành một bản clone cục bộ mà nó đã thấy trước đó và bắt đầu ở đó. Nếu bạn không có bản clone khớp, phiên sẽ mở trong thư mục home của bạn.                                                  |

`cwd` và `repo` là [hai cách để đặt thư mục làm việc](#choose-between-cwd-and-repo). Nếu bạn truyền cả hai, `cwd` được ưu tiên và `repo` bị bỏ qua, kể cả khi đường dẫn `cwd` không tồn tại.

Liên kết sau đây trỏ đến một repository tên `acme/payments` với một prompt chẩn đoán hai dòng. Hãy thay `acme/payments` bằng slug `owner/name` của repository của bạn khi bạn tự xây dựng liên kết:

```text theme={null}
claude-cli://open?repo=acme/payments&q=Investigate%20the%20failed%20deploy%20of%20payments-api.%0ACheck%20recent%20commits%20to%20main%20and%20the%20last%20successful%20build.
```

Nhấp vào nó sẽ mở một cửa sổ terminal mới, khởi động Claude Code trong bản clone cục bộ của `acme/payments`, và điền vào ô prompt văn bản đã được giải mã:

```text theme={null}
Investigate the failed deploy of payments-api.
Check recent commits to main and the last successful build.
```

Bạn có thể chỉnh sửa prompt trước khi nhấn Enter để gửi. Nếu bạn không có bản clone cục bộ nào của repository, phiên sẽ mở trong thư mục home của bạn. Xem [Chọn giữa `cwd` và `repo`](#choose-between-cwd-and-repo) để biết cách đường dẫn cục bộ được chọn khi bạn có nhiều bản clone hoặc worktree.

### Chọn giữa `cwd` và `repo`

Dùng `cwd` khi tất cả những người nhấp vào liên kết đều có dự án ở cùng một đường dẫn tuyệt đối, chẳng hạn một devcontainer hoặc image VM được chuẩn hóa.

Dùng `repo` khi liên kết được chia sẻ và mỗi người clone về một vị trí khác nhau. Claude Code phân giải slug thành một đường dẫn cục bộ như sau:

* Mỗi lần bạn chạy `claude` trong một repository Git, đường dẫn hệ thống tệp của thư mục đó được ghi lại tương ứng với slug GitHub `owner/name` của repository.
* Khi một deep link đến, `repo` mở đường dẫn khớp mà bạn đã dùng gần đây nhất. Nhiều bản clone và worktree được theo dõi riêng biệt, nên nó chọn cái bạn đã làm việc gần nhất.
* Việc tra cứu chỉ tìm thấy các đường dẫn nơi bạn đã chạy Claude Code ít nhất một lần.
* Liên kết không thay đổi nhánh nào đang được checkout. Phiên mở ra với bất kỳ trạng thái nào mà thư mục đó hiện có.

Tiêu đề chào mừng (welcome header) hiển thị đường dẫn nào đã được chọn để bạn có thể xác nhận đúng bản clone đã mở.

## Ví dụ

Các phần dưới đây cho thấy hai cách phổ biến để dùng deep link: như một liên kết Markdown trong tài liệu và như một lệnh trong script hoặc shell alias.

### Nhúng một liên kết vào runbook

Một deep link trong runbook cho bất kỳ ai đang phân loại sự cố một cách để bắt đầu điều tra chỉ với một cú nhấp trong đúng repository với một prompt đã chuẩn bị sẵn. Nền tảng hiển thị runbook phải cho phép các lược đồ URL tùy chỉnh. Markdown được GitHub kết xuất không cho phép `claude-cli://`, nên một deep link trong README, issue hoặc wiki của GitHub chỉ hiển thị nhãn của nó mà không có liên kết nhấp được. Xem [ghi chú khắc phục sự cố](#the-link-renders-as-plain-text-instead-of-being-clickable) để biết cách xử lý.

Prompt là một phần của URL và phải được URL-encode. Để tạo giá trị đã mã hóa, hãy truyền văn bản prompt của bạn qua `encodeURIComponent` trong console của trình duyệt hoặc bất kỳ công cụ mã hóa URL nào.

Ví dụ dưới đây thêm một điểm khởi đầu điều tra vào runbook sự cố cho một dịch vụ tên là `web-gateway`:

```markdown theme={null}
## High 5xx rate on web-gateway

1. Acknowledge the page in PagerDuty.
2. [Open Claude Code in the gateway repo](claude-cli://open?repo=acme/web-gateway&q=5xx%20rate%20is%20elevated%20on%20web-gateway.%20Check%20recent%20deploys%2C%20error%20logs%20from%20the%20last%2030%20minutes%2C%20and%20open%20incidents%20in%20Linear.)
3. Post initial findings in #incident.
```

Để dùng cái này trong runbook của riêng bạn, hãy thay `acme/web-gateway` bằng slug repository của dịch vụ của bạn. Điều này cho phép các kỹ sư đã cài Claude Code và có một bản clone cục bộ của repository đó nhấp vào bước 2 và bắt đầu điều tra với prompt đã sẵn sàng để gửi.

### Mở một liên kết từ shell

Bạn cũng có thể mở một deep link từ một shell script, alias, hoặc automation thay vì nhấp vào nó. Hãy gọi lệnh mở URL của hệ điều hành của bạn với liên kết làm đối số.

<Tabs>
  <Tab title="macOS">
    Lệnh `open` tích hợp sẵn truyền URL cho handler `claude-cli://` đã đăng ký:

    ```bash theme={null}
    open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
    ```
  </Tab>

  <Tab title="Linux">
    Hầu hết các môi trường desktop cung cấp `xdg-open`, lệnh này truyền URL cho handler đã đăng ký:

    ```bash theme={null}
    xdg-open "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
    ```
  </Tab>

  <Tab title="Windows">
    Trong PowerShell, `Start-Process` truyền URL cho handler đã đăng ký:

    ```powershell theme={null}
    Start-Process "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
    ```

    Trong `cmd.exe`, `start` coi đối số được đặt trong dấu ngoặc kép đầu tiên là tiêu đề cửa sổ, nên hãy truyền một tiêu đề trống trước URL:

    ```cmd theme={null}
    start "" "claude-cli://open?repo=acme/payments&q=review%20open%20PRs"
    ```
  </Tab>
</Tabs>

## Đăng ký và các nền tảng được hỗ trợ

Claude Code đăng ký handler `claude-cli://` với hệ điều hành của bạn trong lần đầu tiên bạn khởi động một phiên tương tác trên macOS, Linux và Windows. Bạn không cần chạy một lệnh cài đặt riêng. Việc đăng ký ghi vào các vị trí cấp người dùng (user-level) mà thôi:

| Nền tảng | Vị trí của handler                                                                                                |
| -------- | ------------------------------------------------------------------------------------------------------------------ |
| macOS    | `~/Applications/Claude Code URL Handler.app`                                                                       |
| Linux    | `claude-code-url-handler.desktop` dưới `$XDG_DATA_HOME/applications`, mặc định là `~/.local/share/applications` |
| Windows  | `HKEY_CURRENT_USER\Software\Classes\claude-cli`                                                                   |

Handler khởi chạy Claude Code trong một trình giả lập terminal được phát hiện. Trên macOS, Claude Code ghi nhớ terminal từ phiên tương tác gần đây nhất của bạn và tái sử dụng nó, hỗ trợ iTerm2, Ghostty, kitty, Alacritty, WezTerm và Terminal.app. Trên Linux, nó tôn trọng biến môi trường `$TERMINAL`, sau đó `x-terminal-emulator`, rồi đến một danh sách các trình giả lập phổ biến. Trên Windows, nó ưu tiên Windows Terminal, rồi PowerShell, rồi `cmd.exe`.

Để ngăn hoàn toàn việc đăng ký, hãy đặt [`disableDeepLinkRegistration`](/en/settings) thành `"disable"` trong `settings.json`. Để cưỡng chế điều này trên toàn tổ chức sao cho người dùng không thể bật lại, hãy đặt nó trong [managed settings](/en/server-managed-settings).

## Mở một tab VS Code thay vì terminal

Tiện ích mở rộng VS Code đăng ký handler riêng của nó tại `vscode://anthropic.claude-code/open`, mở một tab trình soạn thảo của Claude Code thay vì một cửa sổ terminal. Xem [Khởi chạy một tab VS Code từ các công cụ khác](/en/vs-code#launch-a-vs-code-tab-from-other-tools) để biết các tham số của URL đó.

## Khắc phục sự cố

### Nhấp vào liên kết không có gì xảy ra

Handler có lẽ chưa được đăng ký. Hãy khởi động một phiên `claude` tương tác một lần trên máy đó, thoát ra, rồi thử lại liên kết. Nếu bạn đang ở Linux mà không có môi trường desktop, `xdg-open` có thể không có gì để chuyển tiếp đến.

### Liên kết hiển thị dưới dạng văn bản thuần thay vì có thể nhấp

Một số trình kết xuất Markdown chỉ cho phép các liên kết `http` và `https` và loại bỏ các lược đồ URL khác. GitHub làm điều này trong README, issue, pull request và wiki: `[label](claude-cli://...)` được kết xuất chỉ thành `label`, không có liên kết và URL bị loại bỏ. Trên các nền tảng này, hãy đặt deep link trong một code block để người đọc có thể thấy URL và dán nó vào thanh địa chỉ của trình duyệt.

### Phiên mở trong thư mục home của tôi thay vì repo

Tham số `repo` chỉ phân giải thành các bản clone mà Claude Code đã thấy. Hãy chạy `claude` bên trong bản clone một lần để đường dẫn của nó được ghi lại, hoặc chuyển liên kết sang dùng `cwd` với một đường dẫn tuyệt đối.

### Liên kết mở sai terminal

Trên macOS, hãy khởi động `claude` trong terminal ưa thích của bạn một lần và deep link tiếp theo sẽ dùng nó. Trên Linux, đặt biến môi trường `$TERMINAL` thành tên lệnh của trình giả lập ưa thích của bạn. Trên Windows, thứ tự là cố định: hãy cài Windows Terminal nếu bạn muốn các liên kết mở ở đó thay vì cửa sổ PowerShell hoặc `cmd.exe`.

## Tìm hiểu thêm

Các trang này bao gồm các cách liên quan để khởi chạy hoặc mở rộng các phiên Claude Code:

* [Skill](/en/skills): lưu một prompt runbook dài dưới dạng một `/skill` trong repo để tham số `q` của deep link chỉ cần gọi tên nó
* [Chế độ phi tương tác (Non-interactive mode)](/en/headless): chạy Claude từ một script và ghi lại đầu ra mà không cần mở terminal
