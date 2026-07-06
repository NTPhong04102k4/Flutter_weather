> Nguồn: https://code.claude.com/docs/en/mcp.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Kết nối Claude Code với công cụ qua MCP

> Tìm hiểu cách kết nối Claude Code với các công cụ của bạn bằng Model Context Protocol.

Claude Code có thể kết nối tới hàng trăm công cụ và nguồn dữ liệu bên ngoài thông qua [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction), một tiêu chuẩn mã nguồn mở cho việc tích hợp AI với công cụ. Các máy chủ MCP cung cấp cho Claude Code quyền truy cập vào công cụ, cơ sở dữ liệu và API của bạn.

Hãy kết nối một máy chủ khi bạn thấy mình đang sao chép dữ liệu vào cửa sổ chat từ một công cụ khác, chẳng hạn như một trình theo dõi issue (issue tracker) hay một bảng giám sát (monitoring dashboard). Sau khi kết nối, Claude có thể đọc và thao tác trực tiếp trên hệ thống đó thay vì làm việc dựa trên nội dung bạn dán vào.

Nếu bạn đang kết nối máy chủ đầu tiên của mình, hãy bắt đầu với [MCP quickstart](/en/mcp-quickstart) để có hướng dẫn từng bước. Trang này là tài liệu tham khảo đầy đủ.

## Bạn có thể làm gì với MCP

Với các máy chủ MCP đã kết nối, bạn có thể yêu cầu Claude Code:

* **Triển khai tính năng từ issue tracker**: "Add the feature described in JIRA issue ENG-4521 and create a PR on GitHub."
* **Phân tích dữ liệu giám sát**: "Check Sentry and Statsig to check the usage of the feature described in ENG-4521."
* **Truy vấn cơ sở dữ liệu**: "Find emails of 10 random users who used feature ENG-4521, based on our PostgreSQL database."
* **Tích hợp thiết kế**: "Update our standard email template based on the new Figma designs that were posted in Slack"
* **Tự động hóa quy trình làm việc**: "Create Gmail drafts inviting these 10 users to a feedback session about the new feature."
* **Phản ứng với sự kiện bên ngoài**: một máy chủ MCP cũng có thể hoạt động như một [channel](/en/channels) đẩy tin nhắn vào phiên (session) của bạn, để Claude phản ứng với tin nhắn Telegram, cuộc trò chuyện Discord, hoặc sự kiện webhook trong khi bạn vắng mặt.

## Tìm và xây dựng máy chủ MCP

Duyệt các connector đã được kiểm duyệt trong [Anthropic Directory](https://claude.ai/directory). Các connector trong Directory sử dụng cùng hạ tầng MCP như Claude Code, nên bạn có thể thêm bất kỳ máy chủ từ xa nào được liệt kê ở đó với `claude mcp add`.

<Warning>
  Hãy xác minh rằng bạn tin tưởng mỗi máy chủ trước khi kết nối. Các máy chủ tải nội dung bên ngoài có thể khiến bạn gặp [rủi ro prompt injection](/en/security#protect-against-prompt-injection).
</Warning>

Để tự xây dựng máy chủ của mình, xem [hướng dẫn xây dựng máy chủ MCP](https://modelcontextprotocol.io/docs/develop/build-server) để nắm những nguyên tắc cơ bản về giao thức và [tài liệu xây dựng connector của Claude](https://claude.com/docs/connectors/building) về xác thực, kiểm thử và nộp lên Directory.

Bạn cũng có thể để Claude tạo khung (scaffold) máy chủ cho bạn với plugin chính thức [`mcp-server-dev`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev).

<Steps>
  <Step title="Cài đặt plugin">
    Trong một phiên Claude Code, chạy:

    ```
    /plugin install mcp-server-dev@claude-plugins-official
    ```

    Nếu Claude Code báo rằng không tìm thấy marketplace, hãy chạy `/plugin marketplace add anthropics/claude-plugins-official` trước, rồi thử cài lại. Sau khi cài xong, chạy `/reload-plugins` để kích hoạt nó trong phiên hiện tại.
  </Step>

  <Step title="Chạy skill build">
    ```
    /mcp-server-dev:build-mcp-server
    ```

    Claude hỏi về trường hợp sử dụng của bạn và tạo khung một máy chủ HTTP từ xa hoặc máy chủ stdio cục bộ.
  </Step>
</Steps>

## Cài đặt máy chủ MCP

Máy chủ MCP có thể được cấu hình theo nhiều cách tùy theo nhu cầu của bạn:

### Tùy chọn 1: Thêm máy chủ HTTP từ xa

Máy chủ HTTP là tùy chọn được khuyến nghị để kết nối tới các máy chủ MCP từ xa. Đây là transport được hỗ trợ rộng rãi nhất cho các dịch vụ trên nền tảng đám mây.

```bash theme={null}
# Basic syntax
claude mcp add --transport http <name> <url>

# Real example: Connect to Notion
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Example with Bearer token
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

Khi cấu hình máy chủ MCP qua JSON trong `.mcp.json`, `~/.claude.json`, hoặc `claude mcp add-json`, trường `type` chấp nhận `streamable-http` như một bí danh (alias) của `http`. Đặc tả MCP dùng tên `streamable-http` cho transport này, nên các cấu hình sao chép từ tài liệu máy chủ vẫn hoạt động mà không cần chỉnh sửa.

### Tùy chọn 2: Thêm máy chủ SSE từ xa

<Warning>
  Transport SSE (Server-Sent Events) đã bị deprecated (không còn được khuyến khích). Hãy dùng máy chủ HTTP thay thế khi có thể.
</Warning>

```bash theme={null}
# Basic syntax
claude mcp add --transport sse <name> <url>

# Real example: Connect to Asana
claude mcp add --transport sse asana https://mcp.asana.com/sse

# Example with authentication header
claude mcp add --transport sse private-api https://api.company.com/sse \
  --header "X-API-Key: your-key-here"
```

### Tùy chọn 3: Thêm máy chủ stdio cục bộ

Máy chủ stdio chạy như các tiến trình cục bộ trên máy của bạn. Chúng lý tưởng cho các công cụ cần truy cập trực tiếp vào hệ thống hoặc các script tùy chỉnh.

Claude Code đặt biến `CLAUDE_PROJECT_DIR` trong môi trường của máy chủ được sinh ra bằng đường dẫn tới thư mục gốc dự án, nên máy chủ của bạn có thể phân giải các đường dẫn tương đối với dự án mà không phụ thuộc vào thư mục làm việc. Đây cũng là thư mục mà hook nhận được trong biến `CLAUDE_PROJECT_DIR` của chúng. Đọc nó từ bên trong tiến trình máy chủ của bạn, ví dụ `process.env.CLAUDE_PROJECT_DIR` trong Node hoặc `os.environ["CLAUDE_PROJECT_DIR"]` trong Python.

Máy chủ của bạn cũng có thể gọi request MCP `roots/list`, trả về thư mục nơi Claude Code được khởi chạy.

Biến này được đặt trong môi trường của máy chủ, không phải trong môi trường của chính Claude Code, nên khi tham chiếu nó qua phép mở rộng `${VAR}` trong `command` hoặc `args` của một `.mcp.json` ở phạm vi project hoặc user, cần có một giá trị mặc định như `${CLAUDE_PROJECT_DIR:-.}`. Các cấu hình MCP do plugin cung cấp thay thế `${CLAUDE_PROJECT_DIR}` trực tiếp và không cần giá trị mặc định.

```bash theme={null}
# Basic syntax
claude mcp add [options] <name> -- <command> [args...]

# Real example: Add Airtable server
claude mcp add --env AIRTABLE_API_KEY=YOUR_KEY --transport stdio airtable \
  -- npx -y airtable-mcp-server
```

<Note>
  **Quan trọng: Phân tách các đối số của máy chủ bằng `--`**

  Đối với máy chủ stdio, `--` (hai dấu gạch ngang) phân tách các tùy chọn riêng của Claude, chẳng hạn `--transport`, `--env`, và `--scope`, khỏi câu lệnh và đối số dùng để chạy máy chủ. Mọi thứ sau `--` được truyền tới máy chủ nguyên vẹn.

  Ví dụ:

  * `claude mcp add --transport stdio myserver -- npx server` → chạy `npx server`
  * `claude mcp add --env KEY=value --transport stdio myserver -- python server.py --port 8080` → chạy `python server.py --port 8080` với `KEY=value` trong môi trường

  Không có `--`, Claude Code sẽ cố diễn giải các flag của máy chủ, như `--port` ở trên, thành tùy chọn của chính nó.

  `--env` chấp nhận nhiều cặp `KEY=value`. Nếu tên máy chủ đứng ngay sau `--env`, CLI sẽ đọc tên đó như một cặp khác và từ chối, vì vậy hãy đặt ít nhất một tùy chọn khác giữa `--env` và tên máy chủ, như trong các ví dụ ở trên.
</Note>

### Tùy chọn 4: Thêm máy chủ WebSocket từ xa

Máy chủ WebSocket giữ một kết nối hai chiều liên tục, phù hợp với các máy chủ MCP từ xa đẩy sự kiện tới Claude mà không cần được yêu cầu. Hãy dùng HTTP thay thế khi máy chủ của bạn chỉ phản hồi các request, vì HTTP hỗ trợ OAuth và flag `claude mcp add --transport`, còn WebSocket không hỗ trợ cả hai.

Cấu hình máy chủ WebSocket trong `.mcp.json` hoặc với `claude mcp add-json`:

```bash theme={null}
claude mcp add-json events-server \
  '{"type":"ws","url":"wss://mcp.example.com/socket","headers":{"Authorization":"Bearer YOUR_TOKEN"}}'
```

Mục `type: "ws"` chấp nhận cùng các trường `url`, `headers`, `headersHelper`, `timeout`, và `alwaysLoad` như `http`. Xác thực chỉ qua header, nên hãy truyền một token tĩnh trong `headers` hoặc sinh ra một token tại thời điểm kết nối bằng [`headersHelper`](#use-dynamic-headers-for-custom-authentication). Flag `claude mcp add --transport` không chấp nhận `ws`.

### Quản lý các máy chủ của bạn

Sau khi đã cấu hình, bạn có thể quản lý các máy chủ MCP của mình với những lệnh sau:

```bash theme={null}
# List all configured servers
claude mcp list

# Get details for a specific server
claude mcp get github

# Remove a server
claude mcp remove github

# (within Claude Code) Check server status
/mcp
```

Các máy chủ phạm vi project từ `.mcp.json` đang chờ bạn phê duyệt sẽ xuất hiện trong `claude mcp list` với trạng thái `⏸ Pending approval`. Chạy `claude` ở chế độ tương tác để xem xét và phê duyệt chúng. `claude mcp get <name>` hiển thị máy chủ đang chờ là `⏸ Pending approval` và máy chủ bị từ chối là `✗ Rejected`.

Kể từ v2.1.196, `claude mcp list` và `claude mcp get` chỉ đọc các phê duyệt `.mcp.json` từ những file cấu hình không được check vào repository cho tới khi bạn tin tưởng workspace bằng cách chạy `claude` trong đó và chấp nhận hộp thoại tin tưởng workspace (workspace trust dialog). Một repository đã được clone không thể tự phê duyệt máy chủ của chính nó: [`enableAllProjectMcpServers` hoặc `enabledMcpjsonServers`](/en/settings#available-settings) được commit vào `.claude/settings.json` của dự án sẽ bị bỏ qua trong một thư mục không được tin tưởng, và máy chủ vẫn ở trạng thái `⏸ Pending approval` thay vì được kết nối và kiểm tra tình trạng (health-check).

Các phê duyệt từ những nguồn sau vẫn áp dụng trong một thư mục không được tin tưởng:

* file `~/.claude/settings.json` của bạn (user)
* managed settings (cài đặt được quản lý)
* các cài đặt được truyền bằng `--settings`
* `.claude/settings.local.json`, miễn là git không theo dõi nó

Một mục `disabledMcpjsonServers` trong bất kỳ file cài đặt nào vẫn từ chối máy chủ.

Panel `/mcp` hiển thị số lượng công cụ bên cạnh mỗi máy chủ đã kết nối và đánh dấu những máy chủ khai báo có khả năng cung cấp công cụ nhưng lại không cung cấp công cụ nào.

Nếu request của bạn cần công cụ từ một máy chủ vẫn đang kết nối ở chế độ nền, Claude sẽ chờ máy chủ đó trước khi tiếp tục. Với [tool search](#scale-with-mcp-tool-search) được bật, vốn là mặc định, việc chờ diễn ra bên trong lời gọi `ToolSearch`. Trong các cấu hình không có tool search, chẳng hạn Google Cloud's Agent Platform, một `ANTHROPIC_BASE_URL` tùy chỉnh, hoặc `ENABLE_TOOL_SEARCH=false`, Claude dùng công cụ `WaitForMcpServers` thay thế.

Tên máy chủ `workspace` được dành riêng cho mục đích nội bộ. Nếu cấu hình của bạn định nghĩa một máy chủ với tên đó, Claude Code sẽ bỏ qua nó khi tải và hiển thị cảnh báo yêu cầu bạn đổi tên.

### Cập nhật công cụ động

Claude Code hỗ trợ thông báo `list_changed` của MCP, cho phép các máy chủ MCP cập nhật động những công cụ, prompt và tài nguyên khả dụng của chúng mà không cần bạn ngắt và kết nối lại. Khi một máy chủ MCP gửi thông báo `list_changed`, Claude Code tự động làm mới các năng lực khả dụng từ máy chủ đó.

### Tự động kết nối lại

Nếu một máy chủ HTTP hoặc SSE ngắt kết nối giữa phiên, Claude Code tự động kết nối lại với exponential backoff: tối đa năm lần thử, bắt đầu với độ trễ một giây và tăng gấp đôi mỗi lần. Máy chủ xuất hiện ở trạng thái đang chờ (pending) trong `/mcp` trong khi việc kết nối lại đang diễn ra. Sau năm lần thử thất bại, máy chủ được đánh dấu là failed và bạn có thể thử lại thủ công từ `/mcp`. Máy chủ stdio là các tiến trình cục bộ và không được kết nối lại tự động.

Cùng cơ chế backoff áp dụng khi một máy chủ HTTP hoặc SSE thất bại ở lần kết nối ban đầu lúc khởi động. Kể từ v2.1.121, Claude Code thử lại kết nối ban đầu tối đa ba lần với các lỗi tạm thời như phản hồi 5xx, kết nối bị từ chối, hoặc timeout, rồi đánh dấu máy chủ là failed nếu vẫn không kết nối được. Lỗi xác thực và lỗi không tìm thấy không được thử lại vì chúng cần thay đổi cấu hình để giải quyết.

Kể từ v2.1.191, các request khám phá năng lực chạy sau khi kết nối thành công, chẳng hạn `tools/list`, `prompts/list`, và `resources/list`, cũng thử lại các lỗi mạng và lỗi máy chủ tạm thời tối đa ba lần với backoff ngắn. Lỗi xác thực, phản hồi 4xx, và timeout request không được thử lại.

### Đẩy tin nhắn với channels

Một máy chủ MCP cũng có thể đẩy tin nhắn trực tiếp vào phiên của bạn để Claude có thể phản ứng với các sự kiện bên ngoài như kết quả CI, cảnh báo giám sát, hoặc tin nhắn chat. Để bật điều này, máy chủ của bạn khai báo năng lực `claude/channel` và bạn chọn tham gia (opt in) với flag `--channels` khi khởi động. Xem [Channels](/en/channels) để dùng một channel được hỗ trợ chính thức, hoặc [Channels reference](/en/channels-reference) để tự xây dựng channel của riêng bạn.

<Tip>
  Mẹo:

  * Dùng flag `--scope` để chỉ định nơi lưu cấu hình:
    * `local` (mặc định): chỉ khả dụng với bạn trong dự án hiện tại. Các phiên bản cũ gọi phạm vi này là `project`
    * `project`: được chia sẻ với mọi người trong dự án qua file `.mcp.json`
    * `user`: khả dụng với bạn trên tất cả các dự án. Các phiên bản cũ gọi phạm vi này là `global`
  * Đặt biến môi trường với các flag `--env` (ví dụ, `--env KEY=value`)
  * Cấu hình thời gian chờ khởi động máy chủ MCP bằng biến môi trường `MCP_TIMEOUT` (ví dụ, `MCP_TIMEOUT=10000 claude` đặt thời gian chờ 10 giây)
  * Đặt thời gian chờ thực thi công cụ riêng cho từng máy chủ bằng cách thêm trường `timeout` tính bằng mili-giây vào mục `.mcp.json` của máy chủ đó, ví dụ `"timeout": 600000` cho mười phút. Điều này ghi đè biến môi trường `MCP_TOOL_TIMEOUT` chỉ cho máy chủ đó
  * Claude Code hiển thị cảnh báo khi đầu ra công cụ MCP vượt quá 10.000 token. Để tăng giới hạn này, đặt biến môi trường `MAX_MCP_OUTPUT_TOKENS` (ví dụ, `MAX_MCP_OUTPUT_TOKENS=50000`)
  * Dùng `/mcp` để xác thực với các máy chủ từ xa yêu cầu xác thực OAuth 2.0
</Tip>

`timeout` theo từng máy chủ là một giới hạn thời gian thực (wall-clock) cứng cho mỗi lời gọi công cụ, và các thông báo tiến độ từ máy chủ không kéo dài nó. Các giá trị dưới 1000 bị bỏ qua và rơi xuống dùng `MCP_TOOL_TIMEOUT`, hoặc mặc định của nó khoảng 28 giờ khi biến đó không được đặt. {/* min-version: 2.1.162 */}Trước v2.1.162, các giá trị dưới 1000 được ép sàn thành một giây thay vì như vậy.

Đối với máy chủ HTTP và SSE, ngân sách byte đầu tiên (first-byte) cho mỗi request fetch có mức tối thiểu 60 giây.

Kể từ v2.1.187, một lời gọi công cụ tới máy chủ HTTP từ xa, SSE, WebSocket, hoặc [claude.ai connector](#use-mcp-servers-from-claude-ai) mà không gửi phản hồi và không có thông báo tiến độ trong 5 phút sẽ hủy bỏ với một lỗi thay vì chờ hết giới hạn thời gian thực. Đặt biến môi trường [`CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT`](/en/env-vars) tính bằng mili-giây để thay đổi cửa sổ nhàn rỗi (idle window), hoặc đặt thành `0` để tắt việc kiểm tra. Máy chủ stdio là các tiến trình cục bộ và không chịu ảnh hưởng của idle timeout.

### Máy chủ MCP do plugin cung cấp

[Plugin](/en/plugins) có thể đóng gói kèm máy chủ MCP, tự động cung cấp công cụ và tích hợp khi plugin được bật. Máy chủ MCP của plugin hoạt động y hệt các máy chủ do người dùng cấu hình.

**Cách máy chủ MCP của plugin hoạt động**:

* Plugin định nghĩa máy chủ MCP trong `.mcp.json` ở thư mục gốc của plugin hoặc nội tuyến (inline) trong `plugin.json`
* Khi một plugin được bật, các máy chủ MCP của nó khởi động tự động
* Công cụ MCP của plugin xuất hiện bên cạnh các công cụ MCP được cấu hình thủ công
* Máy chủ của plugin được quản lý thông qua việc cài đặt plugin, không phải qua các lệnh `/mcp`

**Ví dụ cấu hình MCP của plugin**:

Trong `.mcp.json` ở thư mục gốc của plugin:

```json theme={null}
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "DB_URL": "${DB_URL}"
      }
    }
  }
}
```

Hoặc nội tuyến trong `plugin.json`:

```json theme={null}
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

**Tính năng MCP của plugin**:

* **Vòng đời tự động**: khi khởi động phiên, các máy chủ cho những plugin đã bật sẽ tự động kết nối. Nếu bạn bật hoặc tắt một plugin trong một phiên, chạy `/reload-plugins` để kết nối hoặc ngắt các máy chủ MCP của nó
* **Biến môi trường**: dùng `${CLAUDE_PLUGIN_ROOT}` cho các file plugin được đóng gói, `${CLAUDE_PLUGIN_DATA}` cho [trạng thái bền vững](/en/plugins-reference#persistent-data-directory) tồn tại qua các lần cập nhật plugin, và `${CLAUDE_PROJECT_DIR}` cho thư mục gốc dự án ổn định
* **Truy cập môi trường người dùng**: truy cập cùng các biến môi trường như những máy chủ được cấu hình thủ công
* **Nhiều loại transport**: hỗ trợ transport stdio, SSE, HTTP, và WebSocket, mặc dù mức độ hỗ trợ transport có thể khác nhau tùy máy chủ

**Xem các máy chủ MCP của plugin**:

```bash theme={null}
# Within Claude Code, see all MCP servers including plugin ones
/mcp
```

Máy chủ của plugin xuất hiện trong danh sách với các chỉ báo cho thấy chúng đến từ plugin.

**Tên công cụ MCP của plugin**:

Công cụ từ một máy chủ MCP được đóng gói trong plugin bao gồm cả tên plugin và khóa (key) máy chủ trong tên có thể gọi của chúng. Dạng đầy đủ là `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`, trong đó bất kỳ ký tự nào ngoài `A-Z`, `a-z`, `0-9`, `_`, và `-` được thay bằng `_`. Đối với máy chủ `database-tools` được đóng gói trong một plugin tên `my-plugin`, công cụ `query` có thể được gọi là:

```
mcp__plugin_my-plugin_database-tools__query
```

Dùng tên đầy đủ này khi tham chiếu công cụ trong [permission rules](/en/permissions), danh sách `allowed-tools` của một skill, hoặc [trường `tools` của subagent](/en/sub-agents#available-tools).

**Lợi ích của máy chủ MCP do plugin cung cấp**:

* **Phân phối đóng gói**: công cụ và máy chủ được đóng gói cùng nhau
* **Thiết lập tự động**: không cần cấu hình MCP thủ công
* **Nhất quán cho nhóm**: mọi người đều nhận được cùng bộ công cụ khi plugin được cài đặt

Xem [tài liệu tham khảo thành phần plugin](/en/plugins-reference#mcp-servers) để biết chi tiết về việc đóng gói máy chủ MCP với plugin.

## Phạm vi cài đặt MCP

Máy chủ MCP có thể được cấu hình ở ba phạm vi. Phạm vi bạn chọn quyết định máy chủ tải trong những dự án nào và liệu cấu hình có được chia sẻ với nhóm của bạn hay không. Quản trị viên cũng có thể triển khai máy chủ ở cấp doanh nghiệp thông qua [cấu hình được quản lý](#managed-mcp-configuration).

| Phạm vi                     | Tải trong             | Chia sẻ với nhóm         | Lưu tại                     |
| ------------------------- | -------------------- | ------------------------ | --------------------------- |
| [Local](#local-scope)     | Chỉ dự án hiện tại | Không                       | `~/.claude.json`            |
| [Project](#project-scope) | Chỉ dự án hiện tại | Có, qua version control | `.mcp.json` ở gốc dự án |
| [User](#user-scope)       | Tất cả dự án của bạn    | Không                       | `~/.claude.json`            |

### Phạm vi local

Phạm vi local là mặc định. Một máy chủ phạm vi local chỉ tải trong dự án nơi bạn thêm nó và giữ riêng tư với bạn. Claude Code lưu nó trong `~/.claude.json` dưới đường dẫn của dự án đó, nên cùng máy chủ đó sẽ không xuất hiện trong các dự án khác của bạn. Dùng phạm vi local cho các máy chủ phát triển cá nhân, cấu hình thử nghiệm, hoặc các máy chủ có thông tin xác thực (credentials) mà bạn không muốn đưa vào version control.

<Note>
  Thuật ngữ "local scope" cho máy chủ MCP khác với cài đặt local nói chung. Máy chủ phạm vi local của MCP được lưu trong `~/.claude.json` (thư mục home của bạn), trong khi cài đặt local nói chung dùng `.claude/settings.local.json` (trong thư mục dự án). Xem [Settings](/en/settings#settings-files) để biết chi tiết về vị trí file cài đặt.
</Note>

```bash theme={null}
# Add a local-scoped server (default)
claude mcp add --transport http stripe https://mcp.stripe.com

# Explicitly specify local scope
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
```

Lệnh này ghi máy chủ vào mục dành cho dự án hiện tại của bạn bên trong `~/.claude.json`. Ví dụ dưới đây hiển thị kết quả khi bạn chạy nó từ `/path/to/your/project`:

```json theme={null}
{
  "projects": {
    "/path/to/your/project": {
      "mcpServers": {
        "stripe": {
          "type": "http",
          "url": "https://mcp.stripe.com"
        }
      }
    }
  }
}
```

### Phạm vi project

Máy chủ phạm vi project cho phép cộng tác nhóm bằng cách lưu cấu hình trong file `.mcp.json` ở thư mục gốc của dự án. File này được thiết kế để check vào version control, đảm bảo tất cả thành viên nhóm đều có quyền truy cập vào cùng các công cụ và dịch vụ MCP. Khi bạn thêm một máy chủ phạm vi project, Claude Code tự động tạo hoặc cập nhật file này với cấu trúc cấu hình phù hợp.

```bash theme={null}
# Add a project-scoped server
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
```

File `.mcp.json` kết quả tuân theo một định dạng chuẩn hóa:

```json theme={null}
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

Vì lý do bảo mật, Claude Code sẽ hỏi phê duyệt trước khi dùng các máy chủ phạm vi project từ file `.mcp.json`. Nếu bạn cần đặt lại những lựa chọn phê duyệt này, dùng lệnh `claude mcp reset-project-choices`.

### Phạm vi user

Máy chủ phạm vi user được lưu trong `~/.claude.json` và cung cấp khả năng truy cập xuyên dự án, làm cho chúng khả dụng trên tất cả các dự án trên máy của bạn trong khi vẫn giữ riêng tư với tài khoản người dùng của bạn. Phạm vi này phù hợp với các máy chủ tiện ích cá nhân, công cụ phát triển, hoặc các dịch vụ bạn thường dùng trên nhiều dự án khác nhau.

```bash theme={null}
# Add a user server
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

### Thứ bậc phạm vi và thứ tự ưu tiên

Khi cùng một máy chủ được định nghĩa ở nhiều nơi, Claude Code kết nối tới nó một lần, dùng định nghĩa từ nguồn có mức ưu tiên cao nhất. Toàn bộ mục máy chủ từ nguồn đó được sử dụng; các trường không được gộp (merge) giữa các phạm vi.

1. Phạm vi local
2. Phạm vi project
3. Phạm vi user
4. [Máy chủ do plugin cung cấp](/en/plugins)
5. [claude.ai connector](#use-mcp-servers-from-claude-ai)

Ba phạm vi khớp trùng lặp theo tên. Plugin và connector khớp theo endpoint, nên một cái trỏ tới cùng URL hoặc lệnh như một máy chủ ở trên được coi là trùng lặp.

### Mở rộng biến môi trường trong `.mcp.json`

Claude Code hỗ trợ mở rộng biến môi trường trong file `.mcp.json`, cho phép các nhóm chia sẻ cấu hình trong khi vẫn giữ được linh hoạt cho các đường dẫn riêng theo máy và các giá trị nhạy cảm như API key.

**Cú pháp được hỗ trợ:**

* `${VAR}`: mở rộng thành giá trị của biến môi trường `VAR`
* `${VAR:-default}`: mở rộng thành `VAR` nếu được đặt, ngược lại dùng `default`

**Vị trí mở rộng:**
Biến môi trường có thể được mở rộng trong:

* `command`: đường dẫn thực thi của máy chủ
* `args`: các đối số dòng lệnh
* `env`: các biến môi trường được truyền tới máy chủ
* `url`: cho các loại máy chủ HTTP
* `headers`: cho việc xác thực máy chủ HTTP

**Ví dụ với mở rộng biến:**

```json theme={null}
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Nếu một biến môi trường bắt buộc không được đặt và không có giá trị mặc định, Claude Code sẽ thất bại khi phân tích cú pháp cấu hình.

## Ví dụ thực tế

### Ví dụ: Giám sát lỗi với Sentry

```bash theme={null}
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

Xác thực với tài khoản Sentry của bạn:

```text theme={null}
/mcp
```

Sau đó gỡ lỗi các vấn đề trong môi trường production:

```text theme={null}
What are the most common errors in the last 24 hours?
```

```text theme={null}
Show me the stack trace for error ID abc123
```

```text theme={null}
Which deployment introduced these new errors?
```

### Ví dụ: Kết nối tới GitHub để review code

Máy chủ MCP từ xa của GitHub xác thực bằng một GitHub personal access token được truyền dưới dạng header. Để lấy một token, mở [cài đặt token GitHub của bạn](https://github.com/settings/personal-access-tokens), tạo một fine-grained token mới có quyền truy cập vào các repository bạn muốn Claude làm việc cùng, rồi thêm máy chủ:

```bash theme={null}
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

Sau đó làm việc với GitHub:

```text theme={null}
Review PR #456 and suggest improvements
```

```text theme={null}
Create a new issue for the bug we just found
```

```text theme={null}
Show me all open PRs assigned to me
```

### Ví dụ: Truy vấn cơ sở dữ liệu PostgreSQL của bạn

```bash theme={null}
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

Sau đó truy vấn cơ sở dữ liệu của bạn một cách tự nhiên:

```text theme={null}
What's our total revenue this month?
```

```text theme={null}
Show me the schema for the orders table
```

```text theme={null}
Find customers who haven't made a purchase in 90 days
```

## Xác thực với máy chủ MCP từ xa

Nhiều máy chủ MCP trên nền tảng đám mây yêu cầu xác thực. Claude Code hỗ trợ OAuth 2.0 cho các kết nối an toàn.

Claude Code đánh dấu một máy chủ từ xa là cần xác thực khi máy chủ phản hồi với `401 Unauthorized` hoặc `403 Forbidden`. Cả hai mã trạng thái này đều đánh dấu máy chủ trong `/mcp` để bạn có thể hoàn thành luồng OAuth.

Kể từ v2.1.195, khi việc làm mới token thất bại vì máy chủ từ chối refresh token đã lưu, Claude Code lập tức hiển thị một thông báo chỉ tới `/mcp`. Menu của máy chủ đã kết nối tại đó cung cấp tùy chọn Re-authenticate, để bạn có thể đăng nhập lại trước khi lời gọi công cụ tiếp theo thất bại.

Một máy chủ tùy chỉnh trả về header `WWW-Authenticate` trỏ tới máy chủ ủy quyền (authorization server) của nó sẽ nhận được cùng cơ chế khám phá tự động như bất kỳ máy chủ từ xa nào khác.

Kể từ v2.1.193, Claude Code cũng hiển thị một thông báo khi khởi động khi một hoặc nhiều máy chủ đã cấu hình cần xác thực, nên bạn không phải mở `/mcp` để phát hiện máy chủ nào cần đăng nhập.

Ở chế độ non-interactive không có panel `/mcp`, nên Claude Code không thể chạy luồng OAuth cho bạn. Kể từ v2.1.196, khi một máy chủ đã cấu hình cần xác thực trong một lần chạy `claude -p` hoặc Agent SDK với [tool search](#scale-with-mcp-tool-search) được bật, vốn là mặc định, Claude Code cho Claude biết rằng công cụ của máy chủ đó không khả dụng cho tới khi bạn ủy quyền. Khi đó Claude có thể nêu tên máy chủ cần đăng nhập thay vì phản hồi như thể máy chủ chưa được cấu hình. Hoàn thành đăng nhập từ một phiên tương tác với `/mcp` hoặc `claude mcp login <name>`.

Nếu bạn đã cấu hình `headers.Authorization` cho máy chủ và máy chủ từ chối header đó, Claude Code báo cáo kết nối là thất bại thay vì quay lại dùng OAuth. Hãy kiểm tra rằng token hợp lệ với endpoint MCP, hoặc xóa header để dùng luồng OAuth.

<Steps>
  <Step title="Thêm máy chủ yêu cầu xác thực">
    Ví dụ:

    ```bash theme={null}
    claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
    ```
  </Step>

  <Step title="Dùng lệnh /mcp trong Claude Code">
    Trong Claude Code, dùng lệnh:

    ```text theme={null}
    /mcp
    ```

    Sau đó làm theo các bước trong trình duyệt của bạn để đăng nhập.
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Token xác thực được lưu an toàn và tự động làm mới
  * Dùng "Clear authentication" trong menu `/mcp` để thu hồi quyền truy cập
  * Nếu trình duyệt của bạn không tự động mở, sao chép URL được cung cấp và mở nó thủ công
  * Nếu chuyển hướng trình duyệt thất bại với lỗi kết nối sau khi xác thực, dán URL callback đầy đủ từ thanh địa chỉ của trình duyệt vào ô nhập URL xuất hiện trong Claude Code
  * Xác thực OAuth hoạt động với máy chủ HTTP
</Tip>

### Xác thực từ dòng lệnh

Kể từ v2.1.186, `claude mcp login <name>` chạy luồng OAuth của một máy chủ đã cấu hình trực tiếp từ shell của bạn, nên bạn không cần mở panel `/mcp` bên trong một phiên.

```bash theme={null}
claude mcp login sentry
```

Để xóa thông tin xác thực đã lưu sau này, chạy `claude mcp logout <name>`.

Kể từ v2.1.191, lệnh này phát hiện khi không có trình duyệt cục bộ nào khả dụng, chẳng hạn trong một phiên SSH hoặc trên Linux không có display server, và in URL ủy quyền thay vì cố mở trình duyệt. Mở URL trên máy cục bộ của bạn, rồi dán URL chuyển hướng đầy đủ từ thanh địa chỉ trình duyệt trở lại vào dấu nhắc. Lệnh cần một terminal tương tác cho bước dán, vì vậy hãy kết nối bằng `ssh -t`. Truyền `--no-browser` để buộc hiển thị dấu nhắc URL ngay cả khi phát hiện có trình duyệt cục bộ.

```bash theme={null}
claude mcp login sentry --no-browser
```

### Dùng cổng callback OAuth cố định

Một số máy chủ MCP yêu cầu một redirect URI cụ thể được đăng ký trước. Theo mặc định, Claude Code chọn ngẫu nhiên một cổng khả dụng cho callback OAuth. Dùng `--callback-port` để cố định cổng sao cho nó khớp với một redirect URI đã đăng ký trước dưới dạng `http://localhost:PORT/callback`.

Bạn có thể dùng `--callback-port` một mình (với dynamic client registration) hoặc cùng với `--client-id` (với thông tin xác thực được cấu hình sẵn).

```bash theme={null}
# Fixed callback port with dynamic client registration
claude mcp add --transport http \
  --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

### Dùng thông tin xác thực OAuth được cấu hình sẵn

Một số máy chủ MCP không hỗ trợ thiết lập OAuth tự động qua Dynamic Client Registration. Nếu bạn thấy lỗi như "Incompatible auth server: does not support dynamic client registration," máy chủ yêu cầu thông tin xác thực được cấu hình sẵn. Claude Code cũng hỗ trợ các máy chủ dùng Client ID Metadata Document (CIMD) thay cho Dynamic Client Registration, và khám phá chúng tự động. Nếu việc khám phá tự động thất bại, hãy đăng ký một ứng dụng OAuth qua cổng thông tin dành cho nhà phát triển của máy chủ trước, rồi cung cấp thông tin xác thực khi thêm máy chủ.

<Steps>
  <Step title="Đăng ký một ứng dụng OAuth với máy chủ">
    Tạo một ứng dụng qua cổng thông tin dành cho nhà phát triển của máy chủ và ghi lại client ID và client secret của bạn.

    Nhiều máy chủ cũng yêu cầu một redirect URI. Nếu vậy, chọn một cổng và đăng ký một redirect URI theo định dạng `http://localhost:PORT/callback`. Dùng chính cổng đó với `--callback-port` trong bước tiếp theo.
  </Step>

  <Step title="Thêm máy chủ với thông tin xác thực của bạn">
    Chọn một trong các phương pháp sau. Cổng dùng cho `--callback-port` có thể là bất kỳ cổng khả dụng nào. Nó cần khớp với redirect URI bạn đã đăng ký ở bước trước.

    <Tabs>
      <Tab title="claude mcp add">
        Dùng `--client-id` để truyền client ID của ứng dụng. Flag `--client-secret` sẽ hỏi secret với đầu vào được che (masked):

        ```bash theme={null}
        claude mcp add --transport http \
          --client-id your-client-id --client-secret --callback-port 8080 \
          my-server https://mcp.example.com/mcp
        ```
      </Tab>

      <Tab title="claude mcp add-json">
        Bao gồm đối tượng `oauth` trong cấu hình JSON và truyền `--client-secret` như một flag riêng:

        ```bash theme={null}
        claude mcp add-json my-server \
          '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"clientId":"your-client-id","callbackPort":8080}}' \
          --client-secret
        ```
      </Tab>

      <Tab title="claude mcp add-json (chỉ callback port)">
        Dùng `--callback-port` không có client ID để cố định cổng trong khi dùng dynamic client registration:

        ```bash theme={null}
        claude mcp add-json my-server \
          '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"callbackPort":8080}}'
        ```
      </Tab>

      <Tab title="CI / biến env">
        Đặt secret qua biến môi trường để bỏ qua dấu nhắc tương tác:

        ```bash theme={null}
        MCP_CLIENT_SECRET=your-secret claude mcp add --transport http \
          --client-id your-client-id --client-secret --callback-port 8080 \
          my-server https://mcp.example.com/mcp
        ```
      </Tab>
    </Tabs>
  </Step>

  <Step title="Xác thực trong Claude Code">
    Chạy `/mcp` trong Claude Code và làm theo luồng đăng nhập trong trình duyệt.
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Client secret được lưu an toàn trong keychain hệ thống (macOS) hoặc một file thông tin xác thực, không phải trong cấu hình của bạn
  * Nếu máy chủ dùng một OAuth client công khai không có secret, chỉ dùng `--client-id` mà không dùng `--client-secret`
  * `--callback-port` có thể được dùng có hoặc không có `--client-id`
  * Các flag này chỉ áp dụng cho transport HTTP và SSE. Chúng không có tác dụng với máy chủ stdio
  * Dùng `claude mcp get <name>` để xác minh rằng thông tin xác thực OAuth đã được cấu hình cho một máy chủ
</Tip>

### Ghi đè việc khám phá metadata OAuth

Trỏ Claude Code tới một URL metadata cụ thể của máy chủ ủy quyền OAuth để bỏ qua chuỗi khám phá mặc định. Đặt `authServerMetadataUrl` khi các endpoint tiêu chuẩn của máy chủ MCP báo lỗi, hoặc khi bạn muốn định tuyến việc khám phá qua một proxy nội bộ. Theo mặc định, Claude Code trước tiên kiểm tra RFC 9728 Protected Resource Metadata tại `/.well-known/oauth-protected-resource`, rồi quay lại RFC 8414 authorization server metadata tại `/.well-known/oauth-authorization-server`.

Đặt `authServerMetadataUrl` trong đối tượng `oauth` của cấu hình máy chủ trong `.mcp.json`:

```json theme={null}
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      }
    }
  }
}
```

URL phải dùng `https://`. `authServerMetadataUrl` yêu cầu Claude Code v2.1.64 trở lên. Trường `scopes_supported` của URL metadata ghi đè các scope mà máy chủ upstream khai báo.

### Giới hạn scope OAuth

Đặt `oauth.scopes` để cố định các scope Claude Code yêu cầu trong luồng ủy quyền. Đây là cách được hỗ trợ để giới hạn một máy chủ MCP xuống một tập con đã được đội bảo mật phê duyệt khi máy chủ ủy quyền upstream khai báo nhiều scope hơn mức bạn muốn cấp. Giá trị là một chuỗi đơn phân tách bằng khoảng trắng, khớp định dạng tham số `scope` trong RFC 6749 §3.3.

```json theme={null}
{
  "mcpServers": {
    "slack": {
      "type": "http",
      "url": "https://mcp.slack.com/mcp",
      "oauth": {
        "scopes": "channels:read chat:write search:read"
      }
    }
  }
}
```

`oauth.scopes` được ưu tiên hơn cả `authServerMetadataUrl` và các scope mà máy chủ khám phá tại `/.well-known`. Để trống nó để máy chủ MCP tự quyết định tập scope được yêu cầu.

Kể từ v2.1.196, khi `oauth.scopes` không được đặt, Claude Code yêu cầu scope được cung cấp bởi header `WWW-Authenticate` của máy chủ hoặc protected resource metadata của nó, và không gửi tham số `scope` khi không cái nào cung cấp. Nó không còn yêu cầu toàn bộ danh mục `scopes_supported` từ metadata máy chủ ủy quyền được khám phá tự động. Việc yêu cầu danh mục đó đã khiến các identity provider khai báo các scope chỉ dành cho admin hoặc scope mẫu (template) từ chối request ủy quyền với lỗi `invalid_scope`. Metadata được lấy từ một `authServerMetadataUrl` đã cấu hình vẫn cung cấp `scopes_supported` của nó làm các scope được yêu cầu.

Nếu máy chủ ủy quyền khai báo `offline_access` trong `scopes_supported`, Claude Code thêm nó vào các scope đã cố định để access token có thể được làm mới mà không cần đăng nhập lại qua trình duyệt.

Nếu sau đó máy chủ trả về 403 `insufficient_scope` cho một lời gọi công cụ, Claude Code xác thực lại với cùng các scope đã cố định. Hãy mở rộng `oauth.scopes` khi một công cụ bạn cần đòi hỏi một scope nằm ngoài tập đã cố định.

### Dùng header động cho xác thực tùy chỉnh

Nếu máy chủ MCP của bạn dùng một cơ chế xác thực khác OAuth, chẳng hạn Kerberos, token ngắn hạn, hoặc một SSO nội bộ, dùng `headersHelper` để sinh ra các header request tại thời điểm kết nối. Claude Code chạy lệnh và gộp đầu ra của nó vào các header kết nối.

```json theme={null}
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

Lệnh cũng có thể nội tuyến:

```json theme={null}
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "echo '{\"Authorization\": \"Bearer '\"$(get-token)\"'\"}'"
    }
  }
}
```

**Yêu cầu:**

* Lệnh phải ghi ra stdout một đối tượng JSON gồm các cặp khóa-giá trị dạng chuỗi
* Lệnh chạy trong một shell với thời gian chờ 10 giây
* Header động ghi đè bất kỳ `headers` tĩnh nào có cùng tên

Helper chạy mới trên mỗi lần kết nối, khi bắt đầu phiên và khi kết nối lại. Không có bộ nhớ đệm (caching), nên script của bạn chịu trách nhiệm tái sử dụng token nếu có.

Kể từ v2.1.193, nếu một lời gọi công cụ trả về `401 Unauthorized` hoặc `403 Forbidden`, Claude Code tự động chạy lại helper, kết nối lại với các header mới, và thử lại lời gọi một lần. Claude Code chỉ đánh dấu máy chủ là cần xác thực trong `/mcp` nếu lần thử lại đó cũng thất bại.

Claude Code đặt các biến môi trường sau khi thực thi helper:

| Biến                      | Giá trị                                                                                                        |
| :---------------------------- | :----------------------------------------------------------------------------------------------------------- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | tên của máy chủ MCP                                                                                   |
| `CLAUDE_CODE_MCP_SERVER_URL`  | URL của máy chủ MCP                                                                                    |
| `CLAUDE_PLUGIN_ROOT`          | thư mục gốc của plugin. Chỉ được đặt khi một [plugin](/en/plugins-reference#mcp-servers) cung cấp máy chủ |

Dùng những biến này để viết một script helper duy nhất phục vụ nhiều máy chủ MCP.

Đối với máy chủ do plugin cung cấp, helper cũng chạy với thư mục làm việc được đặt thành thư mục gốc của plugin, nên một đường dẫn `headersHelper` tương đối sẽ phân giải bên trong thư mục plugin thay vì theo thư mục làm việc của phiên. Yêu cầu Claude Code v2.1.195 trở lên.

<Note>
  `headersHelper` thực thi các lệnh shell tùy ý. Khi được định nghĩa ở phạm vi project hoặc local, nó chỉ chạy sau khi bạn chấp nhận hộp thoại tin tưởng workspace.
</Note>

## Thêm máy chủ MCP từ cấu hình JSON

Nếu bạn có một cấu hình JSON cho một máy chủ MCP, bạn có thể thêm nó trực tiếp:

<Steps>
  <Step title="Thêm một máy chủ MCP từ JSON">
    ```bash theme={null}
    # Basic syntax
    claude mcp add-json <name> '<json>'

    # Example: Adding an HTTP server with JSON configuration
    claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'

    # Example: Adding a stdio server with JSON configuration
    claude mcp add-json local-weather '{"type":"stdio","command":"/path/to/weather-cli","args":["--api-key","abc123"],"env":{"CACHE_DIR":"/tmp"}}'

    # Example: Adding an HTTP server with pre-configured OAuth credentials
    claude mcp add-json my-server '{"type":"http","url":"https://mcp.example.com/mcp","oauth":{"clientId":"your-client-id","callbackPort":8080}}' --client-secret
    ```
  </Step>

  <Step title="Xác minh máy chủ đã được thêm">
    ```bash theme={null}
    claude mcp get weather-api
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Đảm bảo JSON được escape đúng cách trong shell của bạn
  * JSON phải tuân theo schema cấu hình máy chủ MCP
  * Bạn có thể dùng `--scope user` để thêm máy chủ vào cấu hình user của bạn thay vì cấu hình riêng theo dự án
</Tip>

## Nhập máy chủ MCP từ Claude Desktop

Nếu bạn đã cấu hình máy chủ MCP trong Claude Desktop, bạn có thể nhập chúng:

<Steps>
  <Step title="Nhập máy chủ từ Claude Desktop">
    ```bash theme={null}
    # Basic syntax 
    claude mcp add-from-claude-desktop 
    ```
  </Step>

  <Step title="Chọn máy chủ nào để nhập">
    Sau khi chạy lệnh, bạn sẽ thấy một hộp thoại tương tác cho phép bạn chọn những máy chủ muốn nhập.
  </Step>

  <Step title="Xác minh các máy chủ đã được nhập">
    ```bash theme={null}
    claude mcp list 
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Tính năng này chỉ hoạt động trên macOS và Windows Subsystem for Linux (WSL)
  * Nó đọc file cấu hình Claude Desktop từ vị trí tiêu chuẩn của nó trên các nền tảng đó
  * Dùng flag `--scope user` để thêm máy chủ vào cấu hình user của bạn
  * Các máy chủ được nhập giữ cùng tên như trong Claude Desktop
  * Nếu các máy chủ có cùng tên đã tồn tại, chúng được thêm hậu tố số (ví dụ, `server_1`)
</Tip>

## Dùng máy chủ MCP từ claude.ai

Nếu bạn đã đăng nhập vào Claude Code bằng tài khoản [claude.ai](https://claude.ai), các máy chủ MCP bạn đã thêm trong claude.ai sẽ tự động khả dụng trong Claude Code:

<Steps>
  <Step title="Cấu hình máy chủ MCP trong claude.ai">
    Thêm máy chủ tại [claude.ai/customize/connectors](https://claude.ai/customize/connectors). Trên gói Team và Enterprise, chỉ admin mới có thể thêm máy chủ.
  </Step>

  <Step title="Xác thực máy chủ MCP">
    Hoàn thành mọi bước xác thực cần thiết trong claude.ai.
  </Step>

  <Step title="Xem và quản lý máy chủ trong Claude Code">
    Trong Claude Code, dùng lệnh:

    ```text theme={null}
    /mcp
    ```

    Các máy chủ từ claude.ai xuất hiện trong danh sách với chỉ báo cho thấy chúng đến từ claude.ai.
  </Step>
</Steps>

Kể từ v2.1.161, các connector bạn chưa từng đăng nhập sẽ được thu gọn phía sau một hàng `Show unused connectors` ở cuối phần claude.ai, nên một danh sách do tổ chức cấp phát sẽ không lấp đầy panel. Chọn hàng đó để mở rộng chúng. Một connector bạn đã đăng nhập trước đó vẫn hiển thị ngay cả khi nó hiện cần xác thực lại.

Connector từ claude.ai chỉ được lấy khi [phương thức xác thực](/en/authentication#authentication-precedence) đang hoạt động của bạn là gói đăng ký claude.ai. Chúng không được tải khi `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `apiKeyHelper`, hoặc một nhà cung cấp bên thứ ba như Amazon Bedrock hay Google Cloud's Agent Platform đang hoạt động, ngay cả khi bạn đã chạy `/login` trước đó.

Nếu `/mcp` không liệt kê một connector bạn đã thêm, chạy `/status` để xác nhận phương thức xác thực nào đang hoạt động, bỏ đặt biến môi trường đó hoặc xóa cài đặt `apiKeyHelper`, rồi chạy `/login` để chọn tài khoản claude.ai của bạn.

Một máy chủ bạn đã thêm trong Claude Code được [ưu tiên](#scope-hierarchy-and-precedence) hơn một claude.ai connector trỏ tới cùng URL. Khi điều này xảy ra, `/mcp` liệt kê connector là ẩn (hidden) và cho biết cách xóa bản trùng lặp nếu bạn muốn dùng connector.

Một số connector do Anthropic lưu trữ, chẳng hạn Microsoft 365, Gmail, và Google Calendar, không hỗ trợ OAuth cục bộ từ Claude Code vì identity provider upstream chỉ chấp nhận redirect URL mà claude.ai đã đăng ký. Kể từ v2.1.162, việc xác thực một trong các host này trong `/mcp` hiển thị một thông báo hướng dẫn bạn kết nối nó tại Settings → Connectors trên claude.ai thay vào đó. Sau khi kết nối ở đó, connector xuất hiện trong Claude Code tự động.

### Tắt claude.ai connector

Để tắt các máy chủ MCP claude.ai trong Claude Code, đặt [`disableClaudeAiConnectors`](/en/settings#available-settings) thành `true` ở bất kỳ phạm vi cài đặt nào:

```json theme={null}
{
  "disableClaudeAiConnectors": true
}
```

Cài đặt này dùng ngữ nghĩa any-source-true: `true` ở bất kỳ nguồn cài đặt nào được ưu tiên. Một `.claude/settings.json` được check-in của dự án có thể loại một repository ra khỏi các cloud connector, nhưng một `false` ở cấp project không thể bật lại các connector mà một `true` ở cấp user hoặc policy đã tắt. Các máy chủ được truyền tường minh qua `--mcp-config` không bị ảnh hưởng.

Bạn cũng có thể đặt biến môi trường `ENABLE_CLAUDEAI_MCP_SERVERS` thành `false`, có cùng tác dụng cho phiên shell hiện tại:

```bash theme={null}
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

Để chặn từng claude.ai connector riêng lẻ thay vì tất cả, thêm chúng vào [`deniedMcpServers`](/en/managed-mcp) theo tên hoặc theo mẫu URL. Ví dụ, một mục `serverName` là `"claude.ai Slack"` sẽ chặn connector Slack. Để bật hoặc tắt một connector chỉ cho dự án hiện tại, dùng panel `/mcp`.

<Note>
  Các cài đặt phía client này chi phối các phiên Claude Code cục bộ. Trong các phiên [Claude Code on the web](/en/claude-code-on-the-web), claude.ai connector được cấp phát bởi host từ xa và đến dưới dạng các mục `--mcp-config` tường minh, nên `disableClaudeAiConnectors` không áp dụng ở đó. URL của connector cũng được viết lại qua proxy của phiên, nên một mẫu `serverUrl` trong `deniedMcpServers` nhắm tới URL của nhà cung cấp sẽ không khớp. Quản lý những connector mà một phiên cloud có thể dùng từ cài đặt tổ chức claude.ai của bạn.
</Note>

## Dùng Claude Code như một máy chủ MCP

Bạn có thể dùng chính Claude Code như một máy chủ MCP mà các ứng dụng khác có thể kết nối tới:

```bash theme={null}
# Start Claude as a stdio MCP server
claude mcp serve
```

Bạn có thể dùng cái này trong Claude Desktop bằng cách thêm cấu hình này vào claude\_desktop\_config.json:

```json theme={null}
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

<Warning>
  **Cấu hình đường dẫn thực thi**: trường `command` phải tham chiếu tới file thực thi của Claude Code. Nếu lệnh `claude` không nằm trong PATH của hệ thống, bạn cần chỉ định đường dẫn đầy đủ tới file thực thi.

  Để tìm đường dẫn đầy đủ:

  ```bash theme={null}
  which claude
  ```

  Rồi dùng đường dẫn đầy đủ trong cấu hình của bạn:

  ```json theme={null}
  {
    "mcpServers": {
      "claude-code": {
        "type": "stdio",
        "command": "/full/path/to/claude",
        "args": ["mcp", "serve"],
        "env": {}
      }
    }
  }
  ```

  Không có đường dẫn thực thi chính xác, bạn sẽ gặp các lỗi như `spawn claude ENOENT`.
</Warning>

<Tip>
  Mẹo:

  * Máy chủ này cung cấp quyền truy cập tới các công cụ của Claude như View, Edit, LS, v.v.
  * Trong Claude Desktop, thử yêu cầu Claude đọc file trong một thư mục, thực hiện chỉnh sửa, và nhiều việc khác.
  * Máy chủ MCP này chỉ phơi bày các công cụ của Claude Code cho MCP client của bạn, nên chính client của bạn chịu trách nhiệm triển khai việc xác nhận của người dùng cho từng lời gọi công cụ.
</Tip>

## Giới hạn và cảnh báo đầu ra MCP

Khi các công cụ MCP tạo ra đầu ra lớn, Claude Code giúp quản lý việc sử dụng token để tránh làm quá tải ngữ cảnh cuộc trò chuyện của bạn:

* **Ngưỡng cảnh báo đầu ra**: Claude Code hiển thị cảnh báo khi bất kỳ đầu ra công cụ MCP nào vượt quá 10.000 token
* **Giới hạn có thể cấu hình**: bạn có thể điều chỉnh số token đầu ra MCP tối đa cho phép bằng biến môi trường `MAX_MCP_OUTPUT_TOKENS`
* **Giới hạn mặc định**: mức tối đa mặc định là 25.000 token
* **Phạm vi**: biến môi trường áp dụng cho các công cụ không khai báo giới hạn riêng. Các công cụ đặt [`anthropic/maxResultSizeChars`](#raise-the-limit-for-a-specific-tool) dùng giá trị đó cho nội dung văn bản, bất kể `MAX_MCP_OUTPUT_TOKENS` được đặt bao nhiêu. Các công cụ trả về dữ liệu hình ảnh vẫn chịu ràng buộc của `MAX_MCP_OUTPUT_TOKENS`

Để tăng giới hạn cho các công cụ tạo ra đầu ra lớn:

```bash theme={null}
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

Điều này đặc biệt hữu ích khi làm việc với các máy chủ MCP:

* Truy vấn các tập dữ liệu hoặc cơ sở dữ liệu lớn
* Sinh ra báo cáo hoặc tài liệu chi tiết
* Xử lý các file log lớn hoặc thông tin gỡ lỗi

### Tăng giới hạn cho một công cụ cụ thể

Nếu bạn đang xây dựng một máy chủ MCP, bạn có thể cho phép từng công cụ trả về kết quả lớn hơn ngưỡng lưu-xuống-đĩa mặc định bằng cách đặt `_meta["anthropic/maxResultSizeChars"]` trong mục phản hồi `tools/list` của công cụ đó. Claude Code nâng ngưỡng của công cụ đó lên giá trị được chú thích, tới trần cứng 500.000 ký tự.

Điều này hữu ích cho các công cụ trả về đầu ra vốn dĩ lớn nhưng cần thiết, chẳng hạn schema cơ sở dữ liệu hoặc toàn bộ cây file. Không có chú thích, các kết quả vượt ngưỡng mặc định được lưu xuống đĩa và được thay bằng một tham chiếu file trong cuộc trò chuyện.

```json theme={null}
{
  "name": "get_schema",
  "description": "Returns the full database schema",
  "_meta": {
    "anthropic/maxResultSizeChars": 200000
  }
}
```

Chú thích áp dụng độc lập với `MAX_MCP_OUTPUT_TOKENS` cho nội dung văn bản, nên người dùng không cần tăng biến môi trường cho các công cụ khai báo nó. Các công cụ trả về dữ liệu hình ảnh vẫn chịu ràng buộc của giới hạn token.

<Warning>
  Nếu bạn thường xuyên gặp cảnh báo đầu ra với các máy chủ MCP cụ thể mà bạn không kiểm soát, hãy cân nhắc tăng giới hạn `MAX_MCP_OUTPUT_TOKENS`. Bạn cũng có thể yêu cầu tác giả máy chủ thêm chú thích `anthropic/maxResultSizeChars` hoặc phân trang (paginate) phản hồi của họ. Chú thích không có tác dụng với các công cụ trả về nội dung hình ảnh; với những công cụ đó, tăng `MAX_MCP_OUTPUT_TOKENS` là lựa chọn duy nhất.
</Warning>

## Schema đầu vào công cụ với một combinator ở cấp gốc

Một số máy chủ MCP khai báo schema đầu vào của một công cụ dưới dạng một hợp (union) JSON Schema, với `anyOf`, `oneOf`, hoặc `allOf` ở cấp cao nhất của schema. Claude API không chấp nhận các từ khóa đó ở gốc schema. Nó chấp nhận các combinator được lồng bên trong `properties`, mà Claude Code gửi đi nguyên vẹn.

Kể từ Claude Code v2.1.195, các công cụ có combinator ở cấp gốc vẫn khả dụng. Trước khi gửi công cụ tới API, Claude Code làm phẳng (flatten) schema thành một đối tượng duy nhất và thêm một câu vào đầu mô tả của công cụ cho Claude biết những nhóm tham số nào thuộc về nhau:

* `allOf`: các thuộc tính từ mọi nhánh được gộp lại, và danh sách `required` của mỗi nhánh vẫn áp dụng
* `anyOf` và `oneOf`: các thuộc tính từ mọi nhánh được gộp lại, và danh sách `required` của mỗi nhánh được mô tả trong phần mô tả công cụ thay vì được schema thực thi

Máy chủ của bạn nhận được bất kỳ đối số nào Claude đã chọn, vì vậy hãy tiếp tục kiểm tra tính hợp lệ của tổ hợp ở phía máy chủ.

Khi Claude Code không thể tạo ra một schema mà API chấp nhận, hoặc trên một triển khai không nhận được cấu hình từ xa cho phép việc viết lại này, chẳng hạn một máy ngoại tuyến, nó bỏ qua đúng một công cụ đó, ghi lại lý do trong log của máy chủ, và để các công cụ khác của máy chủ khả dụng. Các phiên bản trước v2.1.195 bỏ qua mọi công cụ có schema đầu vào chứa `anyOf`, `oneOf`, hoặc `allOf` ở cấp gốc.

## Yêu cầu phê duyệt cho một công cụ cụ thể

Nếu bạn đang xây dựng một máy chủ MCP, bạn có thể đánh dấu một công cụ là yêu cầu phê duyệt tường minh trên mỗi lời gọi bằng cách đặt `_meta["anthropic/requiresUserInteraction"]` thành `true` trong mục phản hồi `tools/list` của công cụ đó. Giá trị phải là boolean JSON `true`; bất kỳ giá trị nào khác đều bị bỏ qua.

Claude Code hiển thị dấu nhắc quyền của công cụ đó trên mỗi lời gọi, ngay cả trong các [permission mode](/en/permissions#permission-modes) `acceptEdits`, `auto`, và `bypassPermissions`, và không cung cấp tùy chọn "don't ask again" cho nó. Các [allow rule](/en/permissions#permission-rule-syntax) khớp với công cụ cũng không bỏ qua dấu nhắc. Ở chế độ `dontAsk`, vốn không bao giờ hỏi, Claude Code từ chối lời gọi thay vào đó.

Dấu nhắc phải đến được một con người. Ở chế độ non-interactive với [`--permission-prompt-tool`](/en/cli-reference#cli-flags), một kết quả `allow` từ công cụ dấu nhắc cho một công cụ được đánh dấu sẽ được chuyển thành từ chối (deny) với thông báo `MCP tool requires user interaction; not supported via --permission-prompt-tool`. [Callback `canUseTool`](/en/agent-sdk/permissions) của Agent SDK thì có nhận các lời gọi này và có thể phê duyệt chúng, vì host của SDK được kỳ vọng hiển thị chúng cho người dùng.

Dùng cái này cho các công cụ mà bản thân dấu nhắc quyền chính là điểm mấu chốt, chẳng hạn một bước đồng ý hoặc cấp quyền truy cập, nơi mà tự động phê duyệt sẽ đồng nghĩa với việc không con người nào từng đồng ý. Các công cụ khác từ cùng máy chủ giữ hành vi quyền bình thường của chúng.

Mục `tools/list` sau đây đánh dấu một công cụ là luôn yêu cầu phê duyệt.

```json theme={null}
{
  "name": "grant_access",
  "description": "Requests access to a protected resource",
  "_meta": {
    "anthropic/requiresUserInteraction": true
  }
}
```

Chú thích `anthropic/requiresUserInteraction` yêu cầu Claude Code v2.1.199 trở lên. Các phiên bản cũ hơn bỏ qua nó và áp dụng luồng quyền tiêu chuẩn.

Khi một phiên được kết nối với [Remote Control](/en/remote-control) hoặc một host SDK, Claude Code đánh dấu request quyền là yêu cầu tương tác người dùng, nên client hiển thị dấu nhắc quyền của công cụ để bạn trả lời thay vì một hành động phê duyệt bằng một chạm.

## Phản hồi các request elicitation của MCP

Máy chủ MCP có thể yêu cầu đầu vào có cấu trúc từ bạn giữa chừng một tác vụ bằng elicitation. Khi một máy chủ cần thông tin mà nó không thể tự lấy, Claude Code hiển thị một hộp thoại tương tác và chuyển phản hồi của bạn trở lại máy chủ. Không cần cấu hình gì ở phía bạn: các hộp thoại elicitation xuất hiện tự động khi một máy chủ yêu cầu chúng.

Máy chủ có thể yêu cầu đầu vào theo hai cách:

* **Chế độ form**: Claude Code hiển thị một hộp thoại với các trường form do máy chủ định nghĩa (ví dụ, một dấu nhắc tên người dùng và mật khẩu). Điền vào các trường và gửi đi.
* **Chế độ URL**: Claude Code mở một URL trình duyệt để xác thực hoặc phê duyệt. Hoàn thành luồng trong trình duyệt, rồi xác nhận trong CLI.

Để tự động phản hồi các request elicitation mà không hiển thị hộp thoại, dùng [hook `Elicitation`](/en/hooks#elicitation).

Nếu bạn đang xây dựng một máy chủ MCP dùng elicitation, xem [đặc tả elicitation của MCP](https://modelcontextprotocol.io/docs/learn/client-concepts#elicitation) để biết chi tiết giao thức và ví dụ schema.

## Dùng tài nguyên MCP

Máy chủ MCP có thể phơi bày tài nguyên mà bạn có thể tham chiếu bằng cách nhắc @ (@ mentions), tương tự cách bạn tham chiếu file.

### Tham chiếu tài nguyên MCP

<Steps>
  <Step title="Liệt kê các tài nguyên khả dụng">
    Gõ `@` trong prompt của bạn để xem các tài nguyên khả dụng từ tất cả các máy chủ MCP đã kết nối. Tài nguyên xuất hiện bên cạnh file trong menu tự động hoàn thành (autocomplete).
  </Step>

  <Step title="Tham chiếu một tài nguyên cụ thể">
    Dùng định dạng `@server:protocol://resource/path` để tham chiếu một tài nguyên:

    ```text theme={null}
    Can you analyze @github:issue://123 and suggest a fix?
    ```

    ```text theme={null}
    Please review the API documentation at @docs:file://api/authentication
    ```
  </Step>

  <Step title="Nhiều tham chiếu tài nguyên">
    Bạn có thể tham chiếu nhiều tài nguyên trong một prompt duy nhất:

    ```text theme={null}
    Compare @postgres:schema://users with @docs:file://database/user-model
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Tài nguyên được tự động lấy về và đưa vào dưới dạng đính kèm khi được tham chiếu
  * Đường dẫn tài nguyên có thể tìm kiếm mờ (fuzzy-searchable) trong autocomplete của @ mention
  * Claude Code tự động cung cấp các công cụ để liệt kê và đọc tài nguyên MCP khi máy chủ hỗ trợ chúng
  * Tài nguyên có thể chứa bất kỳ loại nội dung nào mà máy chủ MCP cung cấp (text, JSON, dữ liệu có cấu trúc, v.v.)
</Tip>

## Mở rộng quy mô với MCP tool search

Tool search giữ mức sử dụng ngữ cảnh MCP thấp bằng cách trì hoãn (defer) các định nghĩa công cụ cho tới khi Claude cần chúng. Chỉ tên công cụ và hướng dẫn máy chủ được tải khi bắt đầu phiên, nên việc thêm nhiều máy chủ MCP có tác động tối thiểu tới cửa sổ ngữ cảnh của bạn. Claude Code không áp một trần công cụ cố định theo mỗi máy chủ; giới hạn thực tế là ngân sách cửa sổ ngữ cảnh của bạn.

### Cách hoạt động

Tool search được bật theo mặc định. Các công cụ MCP được trì hoãn thay vì tải vào ngữ cảnh ngay từ đầu, và Claude dùng một công cụ tìm kiếm để khám phá những công cụ liên quan khi một tác vụ cần chúng. Chỉ những công cụ Claude thực sự dùng mới vào ngữ cảnh. Từ góc nhìn của bạn, các công cụ MCP hoạt động y như trước.

Nếu bạn thích cách tải dựa trên ngưỡng, đặt `ENABLE_TOOL_SEARCH=auto` để tải schema ngay từ đầu khi chúng nằm gọn trong 10% cửa sổ ngữ cảnh và chỉ trì hoãn phần vượt quá. Xem [Cấu hình tool search](#configure-tool-search) để biết tất cả các tùy chọn.

### Dành cho tác giả máy chủ MCP

Nếu bạn đang xây dựng một máy chủ MCP, trường hướng dẫn máy chủ (server instructions) trở nên hữu ích hơn khi tool search được bật. Hướng dẫn máy chủ giúp Claude hiểu khi nào nên tìm kiếm các công cụ của bạn, tương tự cách [skill](/en/skills) hoạt động.

Thêm các hướng dẫn máy chủ rõ ràng, mang tính mô tả, giải thích:

* Loại tác vụ nào mà công cụ của bạn xử lý
* Khi nào Claude nên tìm kiếm các công cụ của bạn
* Các năng lực then chốt mà máy chủ của bạn cung cấp

Claude Code cắt bớt (truncate) mô tả công cụ và hướng dẫn máy chủ ở mức 2KB mỗi cái. Hãy giữ chúng ngắn gọn để tránh bị cắt, và đặt các chi tiết quan trọng gần phần đầu.

### Cấu hình tool search

Tool search được bật theo mặc định: các công cụ MCP được trì hoãn và khám phá theo nhu cầu. Claude Code tắt nó theo mặc định trên Google Cloud's Agent Platform. Nó cũng bị tắt khi `ANTHROPIC_BASE_URL` trỏ tới một host không phải bên thứ nhất (non-first-party), vì hầu hết các proxy không chuyển tiếp các khối `tool_reference`. Đặt `ENABLE_TOOL_SEARCH` một cách tường minh để ghi đè một trong hai cơ chế dự phòng.

Tool search yêu cầu một mô hình hỗ trợ các khối `tool_reference`. Các mô hình Haiku không hỗ trợ nó. Trên Google Cloud's Agent Platform, tool search được hỗ trợ cho Claude Sonnet 4.5 trở lên và Claude Opus 4.5 trở lên.

Điều khiển hành vi tool search với biến môi trường `ENABLE_TOOL_SEARCH`:

| Giá trị    | Hành vi                                                                                                                                                                                                                                                                 |
| :------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| (không đặt)  | Tất cả công cụ MCP được trì hoãn và tải theo nhu cầu. Quay lại tải ngay từ đầu trên Google Cloud's Agent Platform hoặc khi `ANTHROPIC_BASE_URL` là một host không phải bên thứ nhất                                                                                       |
| `true`   | Tất cả công cụ MCP được trì hoãn. Claude Code gửi beta header ngay cả trên Google Cloud's Agent Platform và qua proxy. Request thất bại trên các mô hình Google Cloud's Agent Platform cũ hơn Sonnet 4.5 hoặc Opus 4.5, hoặc trên các proxy không hỗ trợ khối `tool_reference` |
| `auto`   | Chế độ ngưỡng: công cụ tải ngay từ đầu nếu chúng nằm gọn trong 10% cửa sổ ngữ cảnh, trì hoãn nếu không                                                                                                                                                                     |
| `auto:N` | Chế độ ngưỡng với một phần trăm tùy chỉnh, trong đó `N` là 0-100. Ví dụ, `auto:5` cho 5%                                                                                                                                                                                 |
| `false`  | Tất cả công cụ MCP tải ngay từ đầu, không trì hoãn                                                                                                                                                                                                                                |

```bash theme={null}
# Use a custom 5% threshold
ENABLE_TOOL_SEARCH=auto:5 claude

# Disable tool search entirely
ENABLE_TOOL_SEARCH=false claude
```

Hoặc đặt giá trị trong [trường `env` của settings.json](/en/settings#available-settings).

Bạn cũng có thể tắt riêng công cụ `ToolSearch`:

```json theme={null}
{
  "permissions": {
    "deny": ["ToolSearch"]
  }
}
```

### Miễn trừ một máy chủ khỏi việc trì hoãn

Nếu các công cụ của một máy chủ luôn phải hiển thị với Claude mà không cần bước tìm kiếm, đặt `alwaysLoad` thành `true` trong cấu hình của máy chủ đó. Mọi công cụ từ máy chủ đó sẽ tải vào ngữ cảnh khi bắt đầu phiên bất kể cài đặt `ENABLE_TOOL_SEARCH`. Dùng cái này cho một số ít công cụ mà Claude cần trên mọi lượt, vì mỗi công cụ tải sẵn tiêu tốn ngữ cảnh vốn có thể dành cho cuộc trò chuyện của bạn.

Mục `.mcp.json` sau đây miễn trừ một máy chủ HTTP trong khi vẫn để các máy chủ khác được trì hoãn:

```json theme={null}
{
  "mcpServers": {
    "core-tools": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "alwaysLoad": true
    }
  }
}
```

Trường `alwaysLoad` có sẵn trên tất cả các loại máy chủ và yêu cầu Claude Code v2.1.121 trở lên. Một máy chủ MCP cũng có thể đánh dấu từng công cụ là luôn được tải bằng cách thêm `"anthropic/alwaysLoad": true` trong đối tượng `_meta` của công cụ, có cùng tác dụng chỉ cho công cụ đó.

Đặt `alwaysLoad: true` cũng chặn việc khởi động cho tới khi máy chủ kết nối, giới hạn ở mức thời gian chờ kết nối tiêu chuẩn 5 giây. Điều này áp dụng ngay cả khi việc khởi động MCP mặc định là [không chặn](/en/env-vars), vì các công cụ phải hiện diện khi prompt đầu tiên được dựng. Các máy chủ khác tiếp tục kết nối ở chế độ nền.

## Dùng prompt MCP như lệnh

Máy chủ MCP có thể phơi bày các prompt trở thành các lệnh khả dụng trong Claude Code.

### Thực thi prompt MCP

<Steps>
  <Step title="Khám phá các prompt khả dụng">
    Gõ `/` để xem tất cả các lệnh khả dụng, bao gồm cả những lệnh từ máy chủ MCP. Prompt MCP xuất hiện với định dạng `/mcp__servername__promptname`.
  </Step>

  <Step title="Thực thi một prompt không có đối số">
    ```text theme={null}
    /mcp__github__list_prs
    ```
  </Step>

  <Step title="Thực thi một prompt với đối số">
    Nhiều prompt chấp nhận đối số. Truyền chúng phân tách bằng khoảng trắng sau lệnh:

    ```text theme={null}
    /mcp__github__pr_review 456
    ```

    ```text theme={null}
    /mcp__jira__create_issue "Bug in login flow" high
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Prompt MCP được khám phá động từ các máy chủ đã kết nối
  * Đối số được phân tích dựa trên các tham số đã định nghĩa của prompt
  * Kết quả prompt được đưa trực tiếp vào cuộc trò chuyện
  * Tên máy chủ và tên prompt được chuẩn hóa, với khoảng trắng được chuyển thành dấu gạch dưới
</Tip>

## Cấu hình MCP được quản lý

Đối với các tổ chức cần kiểm soát tập trung về việc người dùng có thể kết nối tới những máy chủ MCP nào, xem [Managed MCP configuration](/en/managed-mcp). Nó bao gồm việc triển khai một tập máy chủ cố định với `managed-mcp.json`, giới hạn máy chủ với `allowedMcpServers` và `deniedMcpServers`, và những gì người dùng thấy khi một máy chủ bị chặn.
