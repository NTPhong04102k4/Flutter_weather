> Nguồn: https://code.claude.com/docs/en/overview.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Tổng quan

> Claude Code là công cụ lập trình dạng agent (tác tử), có khả năng đọc codebase của bạn, chỉnh sửa file, chạy lệnh, và tích hợp với các công cụ phát triển của bạn. Có sẵn trong terminal, IDE, ứng dụng desktop và trình duyệt.

Claude Code là một trợ lý lập trình được hỗ trợ bởi AI, giúp bạn xây dựng tính năng, sửa lỗi và tự động hóa các tác vụ phát triển. Nó hiểu toàn bộ codebase của bạn và có thể làm việc trên nhiều file và công cụ khác nhau để hoàn thành công việc.

## Bắt đầu

Chọn môi trường của bạn để bắt đầu. Hầu hết các bề mặt (surface) đều yêu cầu tài khoản [Claude subscription](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=overview_pricing) hoặc [Anthropic Console](https://console.anthropic.com/). Terminal CLI và VS Code cũng hỗ trợ [third-party providers (nhà cung cấp bên thứ ba)](/en/third-party-integrations).

<Tabs>
  <Tab title="Terminal">
    CLI đầy đủ tính năng để làm việc với Claude Code trực tiếp trong terminal của bạn. Chỉnh sửa file, chạy lệnh và quản lý toàn bộ dự án từ dòng lệnh.

    Để cài đặt Claude Code, hãy dùng một trong các phương pháp sau:

    <Tabs>
      <Tab title="Native Install (Recommended)">
        **macOS, Linux, WSL:**

        ```bash theme={null}
        curl -fsSL https://claude.ai/install.sh | bash
        ```

        **Windows PowerShell:**

        ```powershell theme={null}
        irm https://claude.ai/install.ps1 | iex
        ```

        **Windows CMD:**

        ```batch theme={null}
        curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
        ```

        Nếu bạn thấy `The token '&&' is not a valid statement separator`, thì bạn đang ở trong PowerShell, không phải CMD. Nếu bạn thấy `'irm' is not recognized as an internal or external command`, thì bạn đang ở trong CMD, không phải PowerShell. Dấu nhắc lệnh của bạn hiển thị `PS C:\` khi bạn ở trong PowerShell và `C:\` không có `PS` khi bạn ở trong CMD.

        Nếu lệnh cài đặt thất bại với `syntax error near unexpected token '<'`, một lỗi `403`, hoặc lỗi curl khác, xem [Troubleshoot installation](/en/troubleshoot-install#find-your-error) để đối chiếu lỗi với cách khắc phục và tìm các phương pháp cài đặt thay thế.

        [Git for Windows](https://git-scm.com/downloads/win) được khuyến nghị trên Windows gốc để Claude Code có thể dùng công cụ Bash. Nếu Git for Windows chưa được cài, Claude Code sẽ dùng PowerShell làm công cụ shell thay thế. Các thiết lập WSL không cần Git for Windows.

        <Info>
          Các bản cài đặt native tự động cập nhật ở nền để giữ bạn luôn ở phiên bản mới nhất.
        </Info>
      </Tab>

      <Tab title="Homebrew">
        ```bash theme={null}
        brew install --cask claude-code
        ```

        Homebrew cung cấp hai cask. `claude-code` bám theo kênh phát hành ổn định (stable), thường chậm khoảng một tuần và bỏ qua các bản phát hành có lỗi hồi quy nghiêm trọng. `claude-code@latest` bám theo kênh mới nhất và nhận các phiên bản mới ngay khi chúng ra mắt.

        <Info>
          Các bản cài đặt Homebrew không tự động cập nhật. Chạy `brew upgrade claude-code` hoặc `brew upgrade claude-code@latest`, tùy vào cask bạn đã cài, để nhận các tính năng mới nhất và bản vá bảo mật.
        </Info>
      </Tab>

      <Tab title="WinGet">
        ```powershell theme={null}
        winget install Anthropic.ClaudeCode
        ```

        <Info>
          Các bản cài đặt WinGet không tự động cập nhật. Chạy `winget upgrade Anthropic.ClaudeCode` định kỳ để nhận các tính năng mới nhất và bản vá bảo mật.
        </Info>
      </Tab>
    </Tabs>

    Bạn cũng có thể cài đặt bằng [apt, dnf, hoặc apk](/en/setup#install-with-linux-package-managers) trên Debian, Fedora, RHEL và Alpine.

    Sau đó khởi động Claude Code trong bất kỳ dự án nào:

    ```bash theme={null}
    cd your-project
    claude
    ```

    Bạn sẽ được nhắc đăng nhập ở lần dùng đầu tiên. Vậy là xong! [Tiếp tục với Quickstart →](/en/quickstart)

    <Tip>
      Xem [advanced setup](/en/setup) để biết các tùy chọn cài đặt, cập nhật thủ công, hoặc hướng dẫn gỡ cài đặt. Truy cập [installation troubleshooting](/en/troubleshoot-install) nếu bạn gặp sự cố.
    </Tip>
  </Tab>

  <Tab title="VS Code">
    Tiện ích mở rộng VS Code cung cấp inline diff, @-mention, xem xét kế hoạch (plan review), và lịch sử hội thoại ngay trong trình soạn thảo của bạn.

    * [Install for VS Code](vscode:extension/anthropic.claude-code)
    * [Install for Cursor](cursor:extension/anthropic.claude-code)

    Hoặc tìm kiếm "Claude Code" trong khung Extensions (`Cmd+Shift+X` trên Mac, `Ctrl+Shift+X` trên Windows/Linux). Sau khi cài, mở Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`), gõ "Claude Code", và chọn **Open in New Tab**.

    [Bắt đầu với VS Code →](/en/vs-code#get-started)
  </Tab>

  <Tab title="Desktop app">
    Một ứng dụng độc lập để chạy Claude Code bên ngoài IDE hoặc terminal của bạn. Xem xét diff một cách trực quan, chạy nhiều phiên (session) song song, lên lịch các tác vụ lặp lại, và khởi động các phiên trên cloud.

    Tải về và cài đặt:

    * [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect?utm_source=claude_code\&utm_medium=docs) (Intel và Apple Silicon)
    * [Windows](https://claude.ai/api/desktop/win32/x64/setup/latest/redirect?utm_source=claude_code\&utm_medium=docs) (x64)
    * [Windows ARM64](https://claude.ai/api/desktop/win32/arm64/setup/latest/redirect?utm_source=claude_code\&utm_medium=docs)

    Sau khi cài, khởi chạy Claude, đăng nhập, và nhấn vào tab **Code** để bắt đầu lập trình. Cần có [gói đăng ký trả phí](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=overview_desktop_pricing).

    [Tìm hiểu thêm về ứng dụng desktop →](/en/desktop-quickstart)
  </Tab>

  <Tab title="Web">
    Chạy Claude Code trong trình duyệt của bạn mà không cần thiết lập cục bộ. Khởi động các tác vụ chạy lâu và quay lại kiểm tra khi chúng xong, làm việc trên các repo bạn không có sẵn cục bộ, hoặc chạy nhiều tác vụ song song. Có sẵn trên trình duyệt desktop và ứng dụng Claude iOS.

    Bắt đầu lập trình tại [claude.ai/code](https://claude.ai/code).

    [Bắt đầu trên web →](/en/web-quickstart)
  </Tab>

  <Tab title="JetBrains">
    Một plugin cho IntelliJ IDEA, PyCharm, WebStorm, và các JetBrains IDE khác với khả năng xem diff tương tác và chia sẻ ngữ cảnh từ vùng chọn.

    Cài [Claude Code plugin](https://plugins.jetbrains.com/plugin/27310-claude-code-beta-) từ JetBrains Marketplace và khởi động lại IDE của bạn. Plugin yêu cầu Claude Code CLI, được cài đặt riêng; xem [các bước thiết lập JetBrains](/en/jetbrains#installation).

    [Bắt đầu với JetBrains →](/en/jetbrains)
  </Tab>
</Tabs>

## Những gì bạn có thể làm

Dưới đây là một số cách bạn có thể dùng Claude Code:

<AccordionGroup>
  <Accordion title="Tự động hóa công việc bạn cứ trì hoãn" icon="wand-magic-sparkles">
    Claude Code xử lý những tác vụ nhàm chán ngốn thời gian trong ngày của bạn: viết test cho code chưa được kiểm thử, sửa lỗi lint trên toàn dự án, giải quyết xung đột merge, cập nhật dependency, và viết release note.

    ```bash theme={null}
    claude "write tests for the auth module, run them, and fix any failures"
    ```
  </Accordion>

  <Accordion title="Xây dựng tính năng và sửa lỗi" icon="hammer">
    Mô tả những gì bạn muốn bằng ngôn ngữ tự nhiên. Claude Code lên kế hoạch tiếp cận, viết code trên nhiều file, và xác minh nó hoạt động.

    Với các lỗi, hãy dán một thông báo lỗi hoặc mô tả triệu chứng. Claude Code truy vết vấn đề xuyên suốt codebase của bạn, xác định nguyên nhân gốc rễ, và triển khai bản sửa. Xem [common workflows](/en/common-workflows) để có thêm ví dụ.
  </Accordion>

  <Accordion title="Tạo commit và pull request" icon="code-branch">
    Claude Code làm việc trực tiếp với git. Nó stage các thay đổi, viết commit message, tạo nhánh, và mở pull request.

    ```bash theme={null}
    claude "commit my changes with a descriptive message"
    ```

    Trong CI, bạn có thể tự động hóa việc review code và phân loại issue với [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd).
  </Accordion>

  <Accordion title="Kết nối công cụ của bạn với MCP" icon="plug">
    [Model Context Protocol (MCP)](/en/mcp) là một tiêu chuẩn mở để kết nối các công cụ AI với nguồn dữ liệu bên ngoài. Với MCP, Claude Code có thể đọc tài liệu thiết kế của bạn trong Google Drive, cập nhật ticket trong Jira, lấy dữ liệu từ Slack, hoặc dùng công cụ tùy chỉnh của riêng bạn. [MCP quickstart](/en/mcp-quickstart) kết nối server đầu tiên của bạn từ đầu đến cuối.
  </Accordion>

  <Accordion title="Tùy chỉnh với chỉ dẫn, skill và hook" icon="sliders">
    [`CLAUDE.md`](/en/memory) là một file markdown bạn thêm vào thư mục gốc của dự án mà Claude Code đọc ở đầu mỗi phiên. Dùng nó để thiết lập tiêu chuẩn lập trình, các quyết định kiến trúc, thư viện ưu tiên, và checklist review. Claude cũng xây dựng [auto memory](/en/memory#auto-memory) khi làm việc, lưu lại những điều học được như lệnh build và các phát hiện khi gỡ lỗi xuyên suốt các phiên mà bạn không cần viết gì.

    Tạo [skill](/en/skills) để đóng gói các quy trình lặp lại mà nhóm bạn có thể chia sẻ, như `/review-pr` hoặc `/deploy-staging`.

    [Hook](/en/hooks) cho phép bạn chạy các lệnh shell trước hoặc sau các hành động của Claude Code, như tự động định dạng sau mỗi lần chỉnh sửa file hoặc chạy lint trước khi commit.
  </Accordion>

  <Accordion title="Chạy các nhóm agent và xây dựng agent tùy chỉnh" icon="users">
    Sinh ra [nhiều Claude Code agent](/en/sub-agents) cùng làm việc trên các phần khác nhau của một tác vụ đồng thời. Một agent chính điều phối công việc, giao các tác vụ con, và hợp nhất kết quả.

    Để chạy nhiều phiên đầy đủ song song và theo dõi chúng từ một màn hình, dùng [background agent](/en/agent-view). Với các quy trình hoàn toàn tùy chỉnh, [Agent SDK](/en/agent-sdk/overview) cho phép bạn xây dựng agent của riêng mình dựa trên các công cụ và khả năng của Claude Code, với toàn quyền kiểm soát việc điều phối, quyền truy cập công cụ và permission (quyền hạn).
  </Accordion>

  <Accordion title="Pipe, viết script, và tự động hóa với CLI" icon="terminal">
    Claude Code có tính kết hợp (composable) và tuân theo triết lý Unix. Pipe log vào nó, chạy nó trong CI, hoặc kết chuỗi nó với các công cụ khác:

    ```bash theme={null}
    # Analyze recent log output
    tail -200 app.log | claude -p "Slack me if you see any anomalies"

    # Automate translations in CI
    claude -p "translate new strings into French and raise a PR for review"

    # Bulk operations across files
    git diff main --name-only | claude -p "review these changed files for security issues"
    ```

    Xem [CLI reference](/en/cli-reference) để biết toàn bộ tập lệnh và flag.
  </Accordion>

  <Accordion title="Lên lịch các tác vụ lặp lại" icon="clock">
    Chạy Claude theo lịch để tự động hóa công việc lặp lại: review PR buổi sáng, phân tích lỗi CI qua đêm, kiểm toán dependency hàng tuần, hoặc đồng bộ tài liệu sau khi PR được merge.

    * [Routines](/en/routines) chạy trên hạ tầng do Anthropic quản lý, nên chúng vẫn tiếp tục chạy ngay cả khi máy tính của bạn tắt. Chúng cũng có thể được kích hoạt bởi các lệnh gọi API hoặc sự kiện GitHub. Tạo chúng từ web, ứng dụng Desktop, hoặc bằng cách chạy `/schedule` trong CLI.
    * [Desktop scheduled tasks](/en/desktop-scheduled-tasks) chạy trên máy của bạn, với quyền truy cập trực tiếp vào file và công cụ cục bộ
    * [`/loop`](/en/scheduled-tasks) lặp lại một prompt trong một phiên CLI để thăm dò nhanh
  </Accordion>

  <Accordion title="Làm việc từ bất cứ đâu" icon="globe">
    Các phiên không bị gắn với một bề mặt duy nhất. Di chuyển công việc giữa các môi trường khi ngữ cảnh của bạn thay đổi:

    * Rời khỏi bàn làm việc và tiếp tục làm việc từ điện thoại hoặc bất kỳ trình duyệt nào với [Remote Control](/en/remote-control)
    * Nhắn một tác vụ cho [Dispatch](/en/desktop#sessions-from-dispatch) từ điện thoại và mở phiên Desktop mà nó tạo ra
    * Khởi động một tác vụ chạy lâu trên [web](/en/claude-code-on-the-web) hoặc [ứng dụng iOS](https://apps.apple.com/app/claude-by-anthropic/id6473753684), rồi kéo nó vào terminal của bạn bằng `claude --teleport`. Teleport yêu cầu một gói đăng ký claude.ai.
    * Bàn giao một phiên terminal cho [ứng dụng Desktop](/en/desktop) bằng `/desktop` để xem diff trực quan
    * Định tuyến các tác vụ từ chat của nhóm: nhắc `@Claude` trong [Slack](/en/slack) kèm một báo cáo lỗi và nhận lại một pull request
  </Accordion>
</AccordionGroup>

## Dùng Claude Code ở mọi nơi

Mỗi bề mặt kết nối tới cùng một engine Claude Code nền tảng, nên các file CLAUDE.md, settings, và MCP server của bạn hoạt động trên tất cả chúng.

Ngoài các môi trường [Terminal](/en/quickstart), [VS Code](/en/vs-code), [JetBrains](/en/jetbrains), [Desktop](/en/desktop), và [Web](/en/claude-code-on-the-web) ở trên, Claude Code tích hợp với các quy trình CI/CD, chat và trình duyệt:

| Tôi muốn...                                                                       | Lựa chọn tốt nhất                                                                                                  |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Tiếp tục một phiên cục bộ từ điện thoại hoặc thiết bị khác của tôi                | [Remote Control](/en/remote-control)                                                                               |
| Đẩy sự kiện từ Telegram, Discord, iMessage, hoặc webhook của riêng tôi vào một phiên | [Channels](/en/channels)                                                                                           |
| Bắt đầu một tác vụ cục bộ, tiếp tục trên di động                                  | [Web](/en/claude-code-on-the-web) hoặc [ứng dụng Claude iOS](https://apps.apple.com/app/claude-by-anthropic/id6473753684) |
| Chạy Claude theo lịch lặp lại                                                     | [Routines](/en/routines) hoặc [Desktop scheduled tasks](/en/desktop-scheduled-tasks)                              |
| Tự động hóa review PR và phân loại issue                                          | [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd)                                        |
| Nhận review code tự động trên mỗi PR                                              | [GitHub Code Review](/en/code-review)                                                                              |
| Định tuyến báo cáo lỗi từ Slack tới pull request                                 | [Slack](/en/slack)                                                                                                 |
| Gỡ lỗi ứng dụng web trực tiếp (live)                                             | [Chrome](/en/chrome)                                                                                              |
| Xây dựng agent tùy chỉnh cho quy trình của riêng tôi                             | [Agent SDK](/en/agent-sdk/overview)                                                                                |

## Các bước tiếp theo

Sau khi bạn đã cài đặt Claude Code, các hướng dẫn này giúp bạn tìm hiểu sâu hơn.

* [Quickstart](/en/quickstart): hướng dẫn qua tác vụ thực tế đầu tiên của bạn, từ khám phá codebase đến commit một bản sửa
* [Store instructions and memories](/en/memory): cung cấp cho Claude các chỉ dẫn bền vững với các file CLAUDE.md và auto memory
* [Common workflows](/en/common-workflows) và [best practices](/en/best-practices): các mẫu (pattern) để tận dụng tối đa Claude Code
* [Settings](/en/settings): tùy chỉnh Claude Code cho quy trình của bạn
* [Troubleshooting](/en/troubleshooting): giải pháp cho các vấn đề thường gặp
* [code.claude.com](https://code.claude.com/): demo, giá cả, và thông tin chi tiết về sản phẩm
