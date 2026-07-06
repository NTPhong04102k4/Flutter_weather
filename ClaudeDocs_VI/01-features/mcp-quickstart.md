> Nguồn: https://code.claude.com/docs/en/mcp-quickstart.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Kết nối tới máy chủ MCP

> Thêm một máy chủ MCP vào Claude Code, xác minh kết nối, và tìm cấu hình trên đĩa.

[Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) cho phép Claude Code dùng các công cụ ngoài bộ tích hợp sẵn của nó, chẳng hạn tìm kiếm trong một issue tracker, truy vấn cơ sở dữ liệu, hoặc điều khiển một trình duyệt web. Những công cụ này đến từ các máy chủ MCP, chạy trên máy của bạn hoặc như các dịch vụ được lưu trữ (hosted).

Hướng dẫn này dẫn bạn qua việc kết nối một máy chủ MCP từ đầu đến cuối với Claude Code CLI. Đến cuối, bạn sẽ có một máy chủ đã kết nối và phản hồi, biết cấu hình của nó nằm ở đâu trên đĩa, và biết cách khắc phục các lỗi kết nối phổ biến nhất.

<Note>
  Bạn cũng có thể thêm máy chủ MCP từ các bề mặt (surface) khác, bao gồm ứng dụng desktop, VS Code, và web. Xem [Kết nối từ các bề mặt khác](#connect-from-other-surfaces).
</Note>

Để biết mọi cách kết nối và cấu hình máy chủ MCP trong Claude Code, xem [tài liệu tham khảo MCP](/en/mcp).

## Trước khi bắt đầu

Đảm bảo bạn có:

* [Claude Code đã được cài đặt](/en/quickstart) và đã xác thực
* Một terminal đang mở trong một thư mục dự án. Thư mục nào cũng được, kể cả thư mục trống.

## Thêm và xác minh một máy chủ

Ví dụ dưới đây kết nối tới [máy chủ MCP tài liệu Claude Code](https://code.claude.com/docs/mcp), một máy chủ được lưu trữ với khả năng tìm kiếm toàn văn (full-text search) trên tài liệu Claude Code. Nó không yêu cầu xác thực hay cấu hình đặc biệt nào, nên rất phù hợp làm máy chủ đầu tiên để kiểm thử luồng thiết lập.

Các bước là như nhau cho mọi máy chủ: thêm nó, kiểm tra trạng thái kết nối, rồi dùng nó trong một phiên, với một bước dọn dẹp tùy chọn ở cuối. Một số máy chủ có thêm một bước, như đăng nhập qua trình duyệt, được minh họa trong [Các ví dụ máy chủ MCP bổ sung](#additional-mcp-server-examples). Để tìm thêm máy chủ để kết nối, duyệt [Anthropic Directory](/en/mcp#find-and-build-mcp-servers).

<Steps>
  <Step title="Thêm máy chủ MCP">
    Đăng ký máy chủ với Claude Code. Chạy cái này trong terminal của bạn, không phải bên trong một phiên `claude`: bạn đang cấu hình máy chủ trước khi bắt đầu một cuộc trò chuyện.

    ```bash theme={null}
    claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp
    ```

    Các phần của lệnh:

    * `claude mcp add`: đăng ký một máy chủ với Claude Code.
    * `--transport http`: máy chủ được lưu trữ tại một URL thay vì chạy như một tiến trình cục bộ.
    * `claude-code-docs`: một tên bạn tự đặt. Gọi cùng máy chủ đó là `docs` sẽ hoạt động y hệt. Claude Code dùng bất kỳ tên nào bạn chọn để gắn nhãn cho các công cụ của máy chủ trong đầu ra của Claude và để tham chiếu tới máy chủ trong các lệnh như `claude mcp remove`.
    * `https://code.claude.com/docs/mcp`: URL nơi máy chủ được lưu trữ.

    Lệnh in ra một xác nhận như `Added HTTP MCP server claude-code-docs with URL: https://code.claude.com/docs/mcp to local config`. Phần `local config` nghĩa là máy chủ được đăng ký cho bạn, trong dự án này: nếu bạn khởi động Claude Code trong một dự án khác, máy chủ này không hoạt động ở đó. Để đăng ký một máy chủ một lần cho tất cả các dự án của bạn, thêm nó ở phạm vi user, được nói tới trong [Thay đổi phạm vi máy chủ](#change-server-scope).
  </Step>

  <Step title="Kiểm tra trạng thái kết nối">
    Xác nhận máy chủ xuất hiện trong danh sách máy chủ của bạn và kiểm tra trạng thái của nó:

    ```bash theme={null}
    claude mcp list
    ```

    Máy chủ xuất hiện với một chỉ báo trạng thái:

    | Trạng thái                             | Ý nghĩa                                                                                                                                                                       |
    | :--------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `✓ Connected`                      | Sẵn sàng dùng. Đây là điều bạn nên thấy cho `claude-code-docs`                                                                                                              |
    | `! Connected · tools fetch failed` | Máy chủ đã kết nối nhưng không thể liệt kê các công cụ của nó. Chạy `claude mcp get <name>` để xem chi tiết lỗi                                                                            |
    | `! Needs authentication`           | Máy chủ tiếp cận được nhưng cần đăng nhập qua trình duyệt, hoặc một token được truyền với `--header`. Xem [Kết nối một máy chủ yêu cầu đăng nhập](#connect-a-server-that-requires-sign-in) |
    | `✗ Failed to connect`              | Máy chủ không phản hồi. Xem [Khắc phục sự cố](#troubleshooting)                                                                                                                |
    | `✗ Connection error`               | Lần thử kết nối gặp lỗi. Xem [Khắc phục sự cố](#troubleshooting)                                                                                |
    | `⏸ Pending approval`               | Một máy chủ phạm vi project mà bạn chưa phê duyệt. Xem [Chỉnh sửa .mcp.json trực tiếp](#edit-mcp-json-directly)                                                                      |
  </Step>

  <Step title="Dùng máy chủ">
    Bắt đầu một phiên và yêu cầu Claude dùng máy chủ mới theo tên:

    ```bash theme={null}
    claude
    ```

    ```text theme={null}
    Use the claude-code-docs server to look up what MCP_TIMEOUT does
    ```

    <Info>
      Bạn thường không cần nêu tên một máy chủ trong prompt của mình, vì Claude tự chọn các công cụ liên quan. Việc nêu tên nó ở đây đảm bảo phần minh họa đi qua máy chủ mới thay vì một công cụ khác, chẳng hạn web fetch, vốn cũng có thể trả lời cùng câu hỏi.
    </Info>

    Lần đầu Claude gọi máy chủ, nó xin phép để dùng công cụ mới. Phê duyệt để tiếp tục. Lời gọi công cụ trong đầu ra của Claude được gắn nhãn với tên máy chủ, đó là cách bạn xác nhận rằng câu trả lời đến từ máy chủ MCP thay vì từ kiến thức tích hợp sẵn của Claude.
  </Step>

  <Step title="Gỡ máy chủ">
    Bước này là tùy chọn. Khi bạn xong việc thử nghiệm, bạn có thể gỡ máy chủ:

    ```bash theme={null}
    claude mcp remove claude-code-docs
    ```

    <Note>
      Mỗi máy chủ đã kết nối chiếm một phần trong [cửa sổ ngữ cảnh của Claude](/en/how-claude-code-works#the-context-window) vì tên công cụ và hướng dẫn máy chủ của nó được nạp vào mọi phiên. Việc gỡ những máy chủ bạn không còn dùng giúp giữ phần không gian đó được trống.
    </Note>
  </Step>
</Steps>

## Nơi các máy chủ được lưu

Lệnh `claude mcp add` ghi thông tin chi tiết của máy chủ vào một file cấu hình. Theo mặc định, nó đăng ký máy chủ ở phạm vi `local`: riêng tư với bạn, chỉ hoạt động trong dự án hiện tại. Truyền `--scope user` để đăng ký nó một lần cho tất cả các dự án của bạn, hoặc `--scope project` để chia sẻ với đồng đội. [Thay đổi phạm vi máy chủ](#change-server-scope) sẽ hướng dẫn qua cả hai.

<Note>
  `claude mcp add` hoạt động giống nhau trong mọi shell, bao gồm PowerShell và Command Prompt. Bên trong một phiên `claude`, dùng lệnh `/mcp` để kiểm tra và quản lý các máy chủ bạn đã thêm.
</Note>

Có những cách khác để thêm một máy chủ, mỗi cách được nói tới ở phần sau của trang này:

* [Thêm máy chủ cục bộ](#add-a-local-server): chạy một chương trình trên máy của bạn thay vì kết nối tới một URL.
* [Chỉnh sửa `.mcp.json` trực tiếp](#edit-mcp-json-directly): tự viết mục JSON thay vì dùng lệnh.
* [Kết nối một máy chủ yêu cầu đăng nhập](#connect-a-server-that-requires-sign-in): thêm một máy chủ được lưu trữ cần đăng nhập qua trình duyệt trước khi các công cụ của nó hoạt động.

### Tìm cấu hình của bạn trên đĩa

Lệnh `claude mcp add` ghi máy chủ vào một trong ba phạm vi, được lưu trải trên hai file, tùy theo flag `--scope`. Bạn không cần chỉnh sửa các file này trực tiếp, nhưng biết chúng ở đâu sẽ giúp ích cho việc gỡ lỗi và quản lý phiên bản (version control).

| Phạm vi     | File                                                   | Khả dụng với                             |
| :-------- | :----------------------------------------------------- | :--------------------------------------- |
| `local`   | `~/.claude.json`, dưới mục dành cho dự án này     | Chỉ bạn, chỉ dự án này. Mặc định |
| `project` | `.mcp.json` ở gốc dự án của bạn                       | Mọi người clone dự án          |
| `user`    | `~/.claude.json`, dưới khóa `mcpServers` ở cấp cao nhất | Chỉ bạn, tất cả dự án                   |

Trên Windows, `~/.claude.json` phân giải thành `%USERPROFILE%\.claude.json`, thường là `C:\Users\YourName\.claude.json`. Nếu bạn đã đặt [`CLAUDE_CONFIG_DIR`](/en/env-vars), Claude Code đọc `.claude.json` từ bên trong thư mục đó thay vào đó.

Chạy `claude mcp get claude-code-docs` để xem phạm vi nào chứa định nghĩa của một máy chủ. Để biết các phạm vi tương tác thế nào khi cùng một máy chủ được định nghĩa ở nhiều hơn một nơi, xem [Phạm vi cài đặt MCP](/en/mcp#mcp-installation-scopes).

## Thay đổi phạm vi máy chủ

Phạm vi của một máy chủ được cố định khi bạn thêm nó, nên thay đổi phạm vi nghĩa là gỡ mục đó và thêm lại ở phạm vi mới. Cả hai trường hợp dưới đây đều bắt đầu bằng việc gỡ mục local từ phần hướng dẫn đầu tiên, để máy chủ chỉ có một định nghĩa. Nếu bạn đã gỡ nó ở cuối phần hướng dẫn đó, bỏ qua lệnh này:

```bash theme={null}
claude mcp remove claude-code-docs --scope local
```

### Dùng một máy chủ trong tất cả các dự án của bạn

Thêm lại máy chủ ở phạm vi `user` để làm nó hoạt động trong mọi dự án bạn mở, vẫn riêng tư với bạn:

```bash theme={null}
claude mcp add --scope user --transport http claude-code-docs https://code.claude.com/docs/mcp
```

### Chia sẻ một máy chủ với nhóm của bạn

Thêm lại máy chủ ở phạm vi `project`, ghi vào `.mcp.json` ở gốc dự án:

```bash theme={null}
claude mcp add --scope project --transport http claude-code-docs https://code.claude.com/docs/mcp
```

Commit `.mcp.json` vào version control. Đồng đội clone repository và khởi động Claude Code sẽ thấy một dấu nhắc để phê duyệt máy chủ, rồi nó kết nối cho họ nữa.

## Các ví dụ máy chủ MCP bổ sung

Phần hướng dẫn đầu tiên dùng một máy chủ được lưu trữ kết nối mà không cần đăng nhập. Các ví dụ dưới đây bao quát hai hình thái phổ biến còn lại, với cùng luồng thêm, kiểm tra, dùng.

### Thêm máy chủ cục bộ

Một máy chủ stdio cục bộ là một chương trình mà Claude Code khởi động như một tiến trình con (subprocess) trên máy của bạn, thay vì một dịch vụ nó tiếp cận qua một URL. Dùng một cái cho các công cụ cần truy cập vào tài nguyên cục bộ như trình duyệt, hệ thống file của bạn, hoặc một socket cơ sở dữ liệu.

[Máy chủ MCP Playwright](https://github.com/microsoft/playwright-mcp) là một cái tốt để thử: nó cung cấp cho Claude một trình duyệt mà nó có thể điều hướng, nhấp, và đọc, và nó không cần tài khoản. Nó chạy qua `npx`, nên yêu cầu [Node.js](https://nodejs.org/en/download) 18 trở lên.

<Steps>
  <Step title="Thêm máy chủ Playwright">
    Đăng ký máy chủ với lệnh mà Claude Code nên chạy để khởi động nó:

    ```bash theme={null}
    claude mcp add playwright -- npx -y @playwright/mcp@latest
    ```

    Lệnh này khác với ví dụ được lưu trữ ở ba điểm:

    * Không có flag `--transport`, vì máy chủ cục bộ dùng transport `stdio` mặc định.
    * Mọi thứ sau dấu phân tách `--` là lệnh mà Claude Code chạy để khởi động máy chủ.
    * `-y` bảo `npx` cài đặt package mà không hỏi.

    Playwright điều khiển bản Chrome đã được cài trên máy của bạn. Để dùng một trình duyệt khác, thêm `--browser` với tên trình duyệt, ví dụ `--browser firefox`, sau `@playwright/mcp@latest`.
  </Step>

  <Step title="Kiểm tra kết nối">
    Xác nhận `Added` nghĩa là mục đã được lưu, không phải là lệnh chạy được. Kiểm tra kết nối:

    ```bash theme={null}
    claude mcp list
    ```

    Lần kiểm tra đầu tiên có thể hiển thị `✗ Failed to connect` trong khi `npx` tải package, nên hãy chờ một lát và chạy lại.
  </Step>

  <Step title="Dùng trình duyệt">
    Giao cho Claude một tác vụ cần trình duyệt:

    ```text theme={null}
    Use playwright to open https://example.com and tell me the page title
    ```

    Một cửa sổ trình duyệt mở ra để bạn có thể xem nó làm việc, và các lời gọi công cụ trong đầu ra của Claude được gắn nhãn với tên máy chủ `playwright` và hành động, như `browser_navigate`.

    Thử trỏ nó tới dev server cục bộ của bạn để kiểm tra rằng một trang vẫn render được sau một thay đổi, hoặc để nó đi qua một báo cáo lỗi từng bước.
  </Step>
</Steps>

### Kết nối một máy chủ yêu cầu đăng nhập

Các dịch vụ được lưu trữ như Sentry, Linear, và Notion chạy máy chủ MCP của họ phía sau OAuth: bạn thêm URL của máy chủ, rồi đăng nhập qua trình duyệt của bạn.

Các bước dưới đây dùng Sentry làm ví dụ. Để kết nối một dịch vụ khác, thay bằng URL của nó, mà bạn có thể tìm trong [Anthropic Directory](/en/mcp#find-and-build-mcp-servers) hoặc tài liệu của dịch vụ.

<Steps>
  <Step title="Thêm máy chủ">
    Lệnh `add` giống như với máy chủ docs, với URL của Sentry:

    ```bash theme={null}
    claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
    ```

    Sau khi thêm, `claude mcp list` hiển thị máy chủ với `! Needs authentication`. Đó là điều được mong đợi: bước tiếp theo hoàn thành việc đăng nhập.
  </Step>

  <Step title="Xác thực trong trình duyệt của bạn">
    Bắt đầu một phiên Claude Code và mở panel MCP:

    ```text theme={null}
    /mcp
    ```

    Chọn `sentry` từ danh sách, nhấn Enter, và chọn `Authenticate`. Trình duyệt của bạn mở tới trang đăng nhập của Sentry. Phê duyệt kết nối ở đó.

    Trở lại Claude Code, trạng thái của máy chủ chuyển thành đã kết nối. Nếu đăng nhập thất bại hoặc trình duyệt không mở, xem [Khắc phục sự cố](#troubleshooting).
  </Step>

  <Step title="Dùng máy chủ">
    Yêu cầu Claude điều gì đó cần dịch vụ, như `What Sentry projects do I have access to?`, và tìm các lời gọi công cụ được gắn nhãn với tên máy chủ `sentry` trong đầu ra của nó.
  </Step>
</Steps>

Các máy chủ xác thực bằng một token tĩnh thay vì OAuth thì nhận token tại thời điểm thêm với `--header "Authorization: Bearer <token>"`. Xem [ví dụ GitHub](/en/mcp#example-connect-to-github-for-code-reviews) để có một phiên bản đã được thực hiện.

## Chỉnh sửa .mcp.json trực tiếp

Mọi file trong [bảng phạm vi](#find-your-configuration-on-disk) đều dùng cùng định dạng JSON cho các mục máy chủ. Phần này chỉnh sửa `.mcp.json`, file phạm vi project. Đây là file đáng viết tay nhất vì nó được check vào repository, nơi nó kiêm luôn vai trò cấu hình dưới dạng mã (configuration-as-code) cho nhóm của bạn.

Tạo `.mcp.json` ở gốc dự án của bạn. Ví dụ dưới đây định nghĩa cả hai máy chủ từ hướng dẫn này, máy chủ docs được lưu trữ tiếp cận qua HTTP và máy chủ Playwright như một tiến trình `stdio` cục bộ:

```json theme={null}
{
  "mcpServers": {
    "claude-code-docs": {
      "type": "http",
      "url": "https://code.claude.com/docs/mcp"
    },
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

Các trường khác nhau theo loại máy chủ:

* Đối với máy chủ HTTP, `url` là endpoint mà Claude Code kết nối tới.
* Đối với máy chủ stdio, `command` và `args` là chương trình nó chạy.

Sau khi lưu file, khởi động một phiên Claude Code mới trong dự án. Claude Code đọc `.mcp.json` khi khởi động.

Lần đầu Claude Code thấy một máy chủ phạm vi project, nó yêu cầu bạn phê duyệt nó. Dấu nhắc này tồn tại để một repository bạn clone không thể khởi chạy tiến trình trên máy của bạn mà không có sự đồng ý của bạn. Phê duyệt dấu nhắc, hoặc chạy `/mcp` để phê duyệt sau nếu bạn bỏ lỡ nó.

Sau khi bạn đã phê duyệt, chạy `/mcp` và kiểm tra rằng các máy chủ hiển thị là đã kết nối. Nếu một cái hiển thị lỗi thay vào đó, xem [Khắc phục sự cố](#troubleshooting).

## Kết nối từ các bề mặt khác

Hướng dẫn này dùng các lệnh CLI `claude mcp`, nhưng mọi bề mặt Claude Code đều có thể kết nối tới máy chủ MCP:

* **Ứng dụng desktop Claude Code**: thêm máy chủ qua [giao diện Connectors](/en/desktop#connect-external-tools).
* **Ứng dụng chat Claude Desktop**: một ứng dụng riêng biệt với Claude Code. Để sao chép máy chủ từ `claude_desktop_config.json` của nó vào CLI, chạy `claude mcp add-from-claude-desktop` trên macOS hoặc WSL.
* **VS Code**: xem [Kết nối tới công cụ bên ngoài với MCP](/en/vs-code#connect-to-external-tools-with-mcp).
* **Claude Code trên web**: đọc `.mcp.json` từ repository của bạn. Xem [Chỉnh sửa .mcp.json trực tiếp](#edit-mcp-json-directly).
* **Claude.ai**: các connector bạn thêm tại [claude.ai/customize/connectors](https://claude.ai/customize/connectors) sẽ tự động nạp trong CLI khi bạn đăng nhập với tài khoản đó. Xem [Dùng máy chủ MCP từ Claude.ai](/en/mcp#use-mcp-servers-from-claude-ai).

## Khắc phục sự cố

Nếu một máy chủ không kết nối, kiểm tra trạng thái của nó với `/mcp` bên trong một phiên hoặc `claude mcp list` từ shell của bạn, rồi so khớp triệu chứng dưới đây. Panel `/mcp` cũng cho phép bạn kết nối lại hoặc xác thực mà không cần rời khỏi phiên.

<AccordionGroup>
  <Accordion title="/mcp hiển thị No MCP servers configured">
    Claude Code không tìm thấy máy chủ nào cho thư mục hiện tại. Các nguyên nhân phổ biến nhất:

    * Bạn đã chạy `claude mcp add` từ một dự án khác. Máy chủ phạm vi local được gắn với dự án nơi bạn thêm chúng: thư mục gốc của repository, hoặc chính xác thư mục nếu bạn không ở trong một git repository. Thêm lại máy chủ từ dự án bạn đang ở bây giờ, hoặc thêm nó với `--scope user` để nó không bị gắn với một dự án.
    * Bạn đã chỉnh sửa một file cấu hình ở đường dẫn sai. Các file đúng là `~/.claude.json` và `<project>/.mcp.json`. Claude Code không đọc các đường dẫn như `~/.claude/config/mcp.json`, `~/.claude/mcp.json`, hoặc `%APPDATA%\Claude\mcp.json`.
  </Accordion>

  <Accordion title="Trạng thái hiển thị Failed to connect hoặc Connection error">
    Cả hai trạng thái đều nghĩa là máy chủ không khởi động hoặc URL không phản hồi. Chúng cũng có thể xuất hiện với các máy chủ HTTP mong đợi một token thay vì đăng nhập qua trình duyệt được nói tới trong [Kết nối một máy chủ yêu cầu đăng nhập](#connect-a-server-that-requires-sign-in).

    Kể từ v2.1.191, một máy chủ HTTP trả về `404 Not Found` hiển thị `MCP endpoint not found at <url>. Check the URL in your MCP config.` khi bạn chọn máy chủ trong `/mcp`, với URL mà Claude Code đã thử. Các phiên bản cũ hơn hiển thị một thông báo `Error POSTing to endpoint` chung chung mà không có URL. So sánh URL với đường dẫn endpoint MCP được ghi trong tài liệu của máy chủ, rồi chạy `claude mcp remove <name>` và thêm lại với URL đúng.

    Đối với máy chủ HTTP, xác nhận URL tiếp cận được từ máy của bạn:

    ```bash theme={null}
    curl -I https://mcp.sentry.dev/mcp
    ```

    Trong PowerShell, dùng `curl.exe` thay vì `curl` để request đi tới binary curl thật thay vì bí danh `Invoke-WebRequest`.

    Phản hồi cho bạn biết bạn đang gặp loại vấn đề nào:

    * Một `404` hoặc `405`: máy chủ đang hoạt động. Nhiều endpoint MCP chỉ trả lời request POST, nên điều này vẫn xác nhận URL tiếp cận được từ máy của bạn.
    * Một `401` hoặc `403`: máy chủ đang hoạt động và bạn cần xác thực. Dùng đăng nhập qua trình duyệt trong [Kết nối một máy chủ yêu cầu đăng nhập](#connect-a-server-that-requires-sign-in), hoặc với các máy chủ nhận một token thay vào đó, như của GitHub, truyền nó với `--header "Authorization: Bearer <token>"` trong lệnh `claude mcp add`.
    * Không có phản hồi nào cả: kiểm tra URL và mạng của bạn.

    Đối với máy chủ stdio, chạy lệnh đã cấu hình trực tiếp trong terminal của bạn để thấy lỗi bên dưới. Với máy chủ Playwright từ hướng dẫn này, chạy:

    ```bash theme={null}
    npx -y @playwright/mcp@latest
    ```

    Điều xảy ra tiếp theo cho bạn biết vấn đề ở đâu:

    * Lệnh khởi động và chờ đầu vào: bản thân máy chủ hoạt động. Chạy `claude mcp get <name>` và xác nhận lệnh hiển thị ở đó khớp với cái bạn vừa chạy. Nếu lệnh hiển thị khác với cái bạn đã gõ, có khả năng bạn đã bỏ dấu phân tách `--` trước lệnh máy chủ. Gỡ máy chủ và thêm lại với `--` ở đúng chỗ. Nếu bạn viết `.mcp.json` bằng tay, kiểm tra cú pháp và vị trí của nó.
    * Lệnh báo lỗi: thông báo nêu cái gì đang thiếu, chẳng hạn Node.js hoặc một trình duyệt.
  </Accordion>

  <Accordion title="Connection timed out at startup">
    Máy chủ mất nhiều thời gian hơn thời gian chờ khởi động mặc định 30 giây. Lần chạy đầu của một máy chủ stdio có thể chậm trong khi `npx` tải package. Tăng giới hạn với biến môi trường [`MCP_TIMEOUT`](/en/env-vars), tính bằng mili-giây:

    ```bash theme={null}
    MCP_TIMEOUT=60000 claude
    ```

    Trong PowerShell, đặt biến trước lệnh trên cùng một dòng:

    ```powershell theme={null}
    $env:MCP_TIMEOUT = "60000"; claude
    ```
  </Accordion>

  <Accordion title="Server already exists">
    Bạn đã thêm một máy chủ với tên đó ở cùng phạm vi. Hoặc gỡ mục hiện có trước hoặc chọn một tên khác:

    ```bash theme={null}
    claude mcp remove claude-code-docs
    ```

    Nếu tên tồn tại ở nhiều hơn một phạm vi, `remove` báo `exists in multiple scopes`. Truyền `--scope` để chọn bản nào để xóa, ví dụ `claude mcp remove claude-code-docs --scope local`.
  </Accordion>

  <Accordion title="Máy chủ kết nối nhưng không có công cụ nào xuất hiện">
    Chạy `/mcp` bên trong một phiên và chọn máy chủ để thấy danh sách công cụ của nó. Nếu danh sách trống, máy chủ đã khởi động nhưng không đăng ký công cụ nào, thường có nghĩa là nó thiếu một biến môi trường bắt buộc như một API key.

    Truyền biến với `--env KEY=value` trong `claude mcp add`, hoặc trong trường `env` của mục `.mcp.json` của máy chủ. Tài liệu của máy chủ liệt kê các biến nó cần.
  </Accordion>

  <Accordion title="Các thay đổi trong .mcp.json không có hiệu lực">
    Claude Code đọc `.mcp.json` khi bắt đầu phiên. Thoát và khởi động lại phiên sau khi chỉnh sửa file.

    Nếu các máy chủ của bạn vẫn không xuất hiện, chạy `/mcp` và tìm một cảnh báo phân tích (parse warning). Claude Code bỏ qua các mục bị lỗi định dạng và hiển thị trường gây lỗi ở đó.

    Nếu trước đó bạn đã từ chối máy chủ khi được hỏi, đặt lại các phê duyệt của dự án:

    ```bash theme={null}
    claude mcp reset-project-choices
    ```
  </Accordion>

  <Accordion title="Đăng nhập OAuth thất bại hoặc trình duyệt không mở">
    Chạy `/mcp`, chọn máy chủ, và chọn `Authenticate` lại. Nếu trình duyệt không tự động mở, sao chép URL hiển thị trong terminal và mở nó thủ công. Xem [Xác thực với máy chủ MCP từ xa](/en/mcp#authenticate-with-remote-mcp-servers) để biết về các cổng callback cố định và thông tin xác thực được cấu hình sẵn.
  </Accordion>
</AccordionGroup>

## Các bước tiếp theo

Với một máy chủ đã kết nối, khám phá phần còn lại của những gì MCP cho phép:

* [Tìm thêm máy chủ MCP](/en/mcp#find-and-build-mcp-servers) trong Anthropic Directory
* [Chia sẻ máy chủ với nhóm của bạn](/en/mcp#mcp-installation-scopes) bằng các phạm vi cài đặt
* [Quản lý truy cập MCP cho một tổ chức](/en/managed-mcp) với các cài đặt được quản lý và kiểm soát chính sách
* [Tham chiếu tài nguyên MCP](/en/mcp#use-mcp-resources) trong prompt với @ mention
* [Chạy prompt MCP như lệnh](/en/mcp#use-mcp-prompts-as-commands) từ menu `/`
* [Xây dựng máy chủ của riêng bạn](https://modelcontextprotocol.io/quickstart/server) với MCP SDK
