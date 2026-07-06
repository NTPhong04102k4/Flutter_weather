> Nguồn: https://code.claude.com/docs/en/platforms.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Nền tảng và tích hợp

> Chọn nơi chạy Claude Code và những gì để kết nối với nó. So sánh CLI, Desktop, VS Code, JetBrains, web, mobile, và các tích hợp như Chrome, Slack, và CI/CD.

Claude Code chạy cùng một engine nền tảng ở mọi nơi, nhưng mỗi bề mặt (surface) được tinh chỉnh cho một cách làm việc khác nhau. Trang này giúp bạn chọn nền tảng phù hợp với quy trình làm việc của mình và kết nối các công cụ bạn đang dùng.

## Nơi chạy Claude Code

Chọn nền tảng dựa trên cách bạn thích làm việc và nơi dự án của bạn tồn tại.

| Nền tảng                          | Phù hợp nhất cho                                                                                           | Những gì bạn nhận được                                                                                                                                                                              |
| :-------------------------------- | :------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [CLI](/en/quickstart)             | Quy trình làm việc trên terminal, viết script, máy chủ từ xa                                                                      | Bộ tính năng đầy đủ, [Agent SDK](/en/headless), [computer use](/en/computer-use) trên macOS (Pro và Max), nhà cung cấp bên thứ ba                                                               |
| [Desktop](/en/desktop)            | Xem xét trực quan, phiên song song, thiết lập được quản lý                                                    | Trình xem diff, xem trước ứng dụng, [computer use](/en/desktop#let-claude-use-your-computer) và [Dispatch](/en/desktop#sessions-from-dispatch) trên Pro và Max                                      |
| [VS Code](/en/vs-code)            | Làm việc bên trong VS Code mà không cần chuyển sang terminal                                             | Diff nội tuyến, terminal tích hợp, ngữ cảnh tệp                                                                                                                                           |
| [JetBrains](/en/jetbrains)        | Làm việc bên trong IntelliJ, PyCharm, WebStorm, hoặc các IDE JetBrains khác                                | Trình xem diff, chia sẻ vùng chọn, phiên terminal                                                                                                                                       |
| [Web](/en/claude-code-on-the-web) | Các tác vụ chạy lâu không cần nhiều điều hướng, hoặc công việc cần tiếp tục khi bạn ngoại tuyến | Đám mây do Anthropic quản lý, tiếp tục sau khi bạn ngắt kết nối                                                                                                                                   |
| Mobile                            | Khởi động và giám sát các tác vụ khi rời khỏi máy tính                                             | Phiên đám mây từ ứng dụng Claude cho iOS và Android, [Remote Control](/en/remote-control) cho các phiên cục bộ, [Dispatch](/en/desktop#sessions-from-dispatch) tới Desktop trên Pro và Max |

CLI là bề mặt hoàn chỉnh nhất cho công việc gốc trên terminal: viết script và Agent SDK chỉ có trên CLI. Nhà cung cấp bên thứ ba cũng hoạt động trong [VS Code](/en/vs-code#use-third-party-providers). Các triển khai [Desktop](/en/desktop) cho doanh nghiệp hỗ trợ Agent Platform của Google Cloud và nhà cung cấp gateway; đối với Amazon Bedrock hoặc Microsoft Foundry, hãy dùng CLI hoặc VS Code, hoặc [bản xem trước nghiên cứu Cowork on 3P](https://claude.com/docs/cowork/3p/overview), vốn chạy tab Code trên các nhà cung cấp đó. Desktop và các extension IDE đánh đổi một số tính năng chỉ có trên CLI để lấy khả năng xem xét trực quan và tích hợp editor chặt chẽ hơn. Web chạy trong đám mây của Anthropic, nên các tác vụ vẫn tiếp tục sau khi bạn ngắt kết nối. Mobile là một client mỏng vào cùng những phiên đám mây đó hoặc vào một phiên cục bộ thông qua Remote Control, và có thể gửi tác vụ tới Desktop bằng Dispatch.

Bạn có thể kết hợp các bề mặt trên cùng một dự án. Cấu hình, bộ nhớ dự án, và các máy chủ MCP được chia sẻ giữa các bề mặt cục bộ.

## Kết nối các công cụ của bạn

Các tích hợp cho phép Claude làm việc với các dịch vụ bên ngoài codebase của bạn.

| Tích hợp                          | Chức năng của nó                                       | Dùng cho                                                       |
| :----------------------------------- | :------------------------------------------------- | :--------------------------------------------------------------- |
| [Chrome](/en/chrome)                 | Điều khiển trình duyệt của bạn với các phiên đã đăng nhập | Kiểm thử ứng dụng web, điền biểu mẫu, tự động hóa các trang không có API |
| [GitHub Actions](/en/github-actions) | Chạy Claude trong pipeline CI của bạn                     | Đánh giá PR tự động, phân loại issue, bảo trì theo lịch        |
| [GitLab CI/CD](/en/gitlab-ci-cd)     | Tương tự GitHub Actions cho GitLab                 | Tự động hóa dựa trên CI trên GitLab                             |
| [Code Review](/en/code-review)       | Đánh giá mọi PR tự động                     | Bắt lỗi trước khi con người xem xét                              |
| [Slack](/en/slack)                   | Phản hồi các lời nhắc `@Claude` trong các kênh của bạn    | Biến báo cáo lỗi thành pull request từ chat của nhóm            |

Đối với các tích hợp không được liệt kê ở đây, [các máy chủ MCP](/en/mcp) và [connector](/en/desktop#connect-external-tools) cho phép bạn kết nối gần như bất cứ thứ gì: Linear, Notion, Google Drive, hoặc các API nội bộ của riêng bạn.

## Làm việc khi bạn ở xa terminal

Claude Code cung cấp nhiều cách để làm việc khi bạn không ngồi ở terminal. Chúng khác nhau về điều gì kích hoạt công việc, nơi Claude chạy, và bạn cần thiết lập bao nhiêu.

|                                                | Kích hoạt                                                                                        | Claude chạy trên                                                                               | Thiết lập                                                                                                                                | Phù hợp nhất cho                                                      |
| :--------------------------------------------- | :--------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------ |
| [Dispatch](/en/desktop#sessions-from-dispatch) | Nhắn một tác vụ từ ứng dụng Claude di động                                                      | Máy của bạn (Desktop)                                                                       | [Ghép nối ứng dụng di động với Desktop](https://support.claude.com/en/articles/13947068)                                                  | Ủy thác công việc khi bạn đi vắng, thiết lập tối thiểu              |
| [Remote Control](/en/remote-control)           | Điều khiển một phiên đang chạy từ [claude.ai/code](https://claude.ai/code) hoặc ứng dụng Claude di động | Máy của bạn (CLI hoặc VS Code)                                                                | Chạy `claude remote-control`                                                                                                          | Điều hướng công việc đang thực hiện từ một thiết bị khác                 |
| [Channels](/en/channels)                       | Đẩy sự kiện từ một ứng dụng chat như Telegram hoặc Discord, hoặc máy chủ của riêng bạn                       | Máy của bạn (CLI)                                                                           | [Cài đặt một plugin channel](/en/channels#quickstart) hoặc [tự xây dựng](/en/channels-reference)                                      | Phản ứng với các sự kiện bên ngoài như lỗi CI hoặc tin nhắn chat |
| [Slack](/en/slack)                             | Nhắc `@Claude` trong một kênh của nhóm                                                            | Đám mây Anthropic                                                                              | [Cài đặt ứng dụng Slack](/en/slack#setting-up-claude-code-in-slack) với [Claude Code trên web](/en/claude-code-on-the-web) được bật | PR và đánh giá từ chat của nhóm                             |
| [Scheduled tasks](/en/scheduled-tasks)         | Đặt một lịch                                                                                 | [CLI](/en/scheduled-tasks), [Desktop](/en/desktop-scheduled-tasks), hoặc [đám mây](/en/routines) | Chọn tần suất                                                                                                                         | Tự động hóa lặp lại như đánh giá hàng ngày                     |

Nếu bạn không chắc bắt đầu từ đâu, [cài đặt CLI](/en/quickstart) và chạy nó trong một thư mục dự án. Nếu bạn không muốn dùng terminal, [Desktop](/en/desktop-quickstart) mang lại cho bạn cùng engine với giao diện đồ họa.

## Tài nguyên liên quan

### Nền tảng

* [Bắt đầu nhanh với CLI](/en/quickstart): cài đặt và chạy lệnh đầu tiên trong terminal
* [Desktop](/en/desktop): xem xét diff trực quan, phiên song song, computer use, và Dispatch
* [VS Code](/en/vs-code): extension Claude Code bên trong editor của bạn
* [JetBrains](/en/jetbrains): extension cho IntelliJ, PyCharm, và các IDE JetBrains khác
* [Claude Code trên web](/en/claude-code-on-the-web): các phiên đám mây tiếp tục chạy khi bạn ngắt kết nối
* Mobile: ứng dụng Claude cho [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) và [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude) để khởi động và giám sát tác vụ khi rời khỏi máy tính

### Tích hợp

* [Chrome](/en/chrome): tự động hóa các tác vụ trình duyệt với các phiên đã đăng nhập của bạn
* [Computer use](/en/computer-use): cho Claude mở ứng dụng và điều khiển màn hình của bạn trên macOS
* [GitHub Actions](/en/github-actions): chạy Claude trong pipeline CI của bạn
* [GitLab CI/CD](/en/gitlab-ci-cd): tương tự cho GitLab
* [Code Review](/en/code-review): đánh giá tự động trên mọi pull request
* [Slack](/en/slack): gửi tác vụ từ chat của nhóm, nhận lại PR

### Truy cập từ xa

* [Dispatch](/en/desktop#sessions-from-dispatch): nhắn một tác vụ từ điện thoại và nó có thể tạo ra một phiên Desktop
* [Remote Control](/en/remote-control): điều khiển một phiên đang chạy từ điện thoại hoặc trình duyệt của bạn
* [Channels](/en/channels): đẩy sự kiện từ các ứng dụng chat hoặc máy chủ của riêng bạn vào một phiên
* [Scheduled tasks](/en/scheduled-tasks): chạy prompt theo lịch lặp lại
