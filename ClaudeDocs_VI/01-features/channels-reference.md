> Nguồn: https://code.claude.com/docs/en/channels-reference.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tài liệu tham chiếu channel

> Xây dựng một MCP server đẩy webhook, cảnh báo, và tin nhắn chat vào một phiên Claude Code. Tài liệu tham chiếu cho hợp đồng channel: khai báo khả năng (capability), sự kiện thông báo, công cụ trả lời, kiểm soát người gửi, và chuyển tiếp lời nhắc quyền.

<Note>
  Channel đang trong [bản xem trước nghiên cứu (research preview)](/en/channels#research-preview) và yêu cầu Claude Code v2.1.80 trở lên. Các tổ chức Team và Enterprise phải [bật chúng một cách rõ ràng](/en/channels#enterprise-controls).
</Note>

Một channel là một MCP server đẩy các sự kiện vào một phiên Claude Code để Claude có thể phản ứng với những điều xảy ra bên ngoài terminal.

Bạn có thể xây dựng một channel một chiều hoặc hai chiều. Channel một chiều chuyển tiếp cảnh báo, webhook, hoặc sự kiện giám sát để Claude hành động. Channel hai chiều như cầu nối chat cũng [phơi bày một công cụ trả lời](#expose-a-reply-tool) để Claude có thể gửi tin nhắn lại. Một channel có đường dẫn người gửi đáng tin cậy cũng có thể chọn bật [chuyển tiếp lời nhắc quyền (permission relay)](#relay-permission-prompts) để bạn có thể phê duyệt hoặc từ chối việc dùng công cụ từ xa.

Trang này bao gồm:

* [Tổng quan](#overview): channel hoạt động như thế nào
* [Bạn cần gì](#what-you-need): các yêu cầu và các bước chung
* [Ví dụ: xây dựng một bộ nhận webhook](#example-build-a-webhook-receiver): một hướng dẫn một chiều tối giản
* [Tùy chọn server](#server-options): các trường của hàm khởi tạo (constructor)
* [Định dạng thông báo](#notification-format): payload sự kiện và hành vi chuyển giao
* [Phơi bày một công cụ trả lời](#expose-a-reply-tool): cho phép Claude gửi tin nhắn lại
* [Kiểm soát tin nhắn đến](#gate-inbound-messages): kiểm tra người gửi để ngăn chặn prompt injection
* [Chuyển tiếp lời nhắc quyền](#relay-permission-prompts): chuyển tiếp các lời nhắc phê duyệt công cụ tới các channel từ xa

Để dùng một channel hiện có thay vì xây dựng một cái, xem [Channel](/en/channels). Telegram, Discord, iMessage, và fakechat được bao gồm trong bản xem trước nghiên cứu.

## Tổng quan

Một channel là một server [MCP](https://modelcontextprotocol.io) chạy trên cùng máy với Claude Code. Claude Code sinh ra nó như một tiến trình con (subprocess) và giao tiếp qua stdio. Channel server của bạn là cầu nối giữa các hệ thống bên ngoài và phiên Claude Code:

* **Nền tảng chat** (Telegram, Discord): plugin của bạn chạy cục bộ và thăm dò (poll) API của nền tảng để lấy tin nhắn mới. Khi ai đó DM cho bot của bạn, plugin nhận tin nhắn và chuyển tiếp nó tới Claude. Không có URL nào để phơi bày ra ngoài.
* **Webhook** (CI, giám sát): server của bạn lắng nghe trên một cổng HTTP cục bộ. Các hệ thống bên ngoài POST tới cổng đó, và server của bạn đẩy payload tới Claude.

<img src="https://mintcdn.com/claude-code/zbUxPYi8065L3Y_P/en/images/channel-architecture.svg?fit=max&auto=format&n=zbUxPYi8065L3Y_P&q=85&s=fd6b6b949eab38264043d2a96285a57c" alt="Sơ đồ kiến trúc cho thấy các hệ thống bên ngoài kết nối tới channel server cục bộ của bạn, giao tiếp với Claude Code qua stdio" width="600" height="220" data-path="en/images/channel-architecture.svg" />

## Bạn cần gì

Yêu cầu bắt buộc duy nhất là gói [`@modelcontextprotocol/sdk`](https://www.npmjs.com/package/@modelcontextprotocol/sdk) và một runtime tương thích Node.js. [Bun](https://bun.sh), [Node](https://nodejs.org), và [Deno](https://deno.com) đều hoạt động. Các plugin dựng sẵn trong bản xem trước nghiên cứu dùng Bun, nhưng channel của bạn không nhất thiết phải dùng.

Server của bạn cần:

1. Khai báo khả năng `claude/channel` để Claude Code đăng ký một trình lắng nghe thông báo (notification listener)
2. Phát ra các sự kiện `notifications/claude/channel` khi có điều gì đó xảy ra
3. Kết nối qua [stdio transport](https://modelcontextprotocol.io/docs/concepts/transports#standard-io) (Claude Code sinh ra server của bạn như một tiến trình con)

Các phần [Tùy chọn server](#server-options) và [Định dạng thông báo](#notification-format) trình bày chi tiết từng phần trong số này. Xem [Ví dụ: xây dựng một bộ nhận webhook](#example-build-a-webhook-receiver) để có hướng dẫn đầy đủ.

Trong thời gian xem trước nghiên cứu, các channel tùy chỉnh không nằm trong [danh sách cho phép đã phê duyệt](/en/channels#supported-channels). Dùng `--dangerously-load-development-channels` để thử nghiệm cục bộ. Xem [Thử nghiệm trong thời gian xem trước nghiên cứu](#test-during-the-research-preview) để biết chi tiết.

## Ví dụ: xây dựng một bộ nhận webhook

Hướng dẫn này xây dựng một server một file lắng nghe các yêu cầu HTTP và chuyển tiếp chúng vào phiên Claude Code của bạn. Đến cuối, bất cứ thứ gì có thể gửi một HTTP POST, như một pipeline CI, một cảnh báo giám sát, hoặc một lệnh `curl`, đều có thể đẩy sự kiện tới Claude.

Ví dụ này dùng [Bun](https://bun.sh) làm runtime vì nó có server HTTP tích hợp sẵn và hỗ trợ TypeScript. Bạn có thể dùng [Node](https://nodejs.org) hoặc [Deno](https://deno.com) thay thế; yêu cầu duy nhất là [MCP SDK](https://www.npmjs.com/package/@modelcontextprotocol/sdk).

<Steps>
  <Step title="Tạo dự án">
    Tạo một thư mục mới và cài đặt MCP SDK:

    ```bash theme={null}
    mkdir webhook-channel && cd webhook-channel
    bun add @modelcontextprotocol/sdk
    ```
  </Step>

  <Step title="Viết channel server">
    Tạo một file tên `webhook.ts`. Đây là toàn bộ channel server của bạn: nó kết nối tới Claude Code qua stdio, và lắng nghe các HTTP POST trên cổng 8788. Khi một yêu cầu đến, nó đẩy phần thân (body) tới Claude như một sự kiện channel.

    ```ts title="webhook.ts" theme={null}
    #!/usr/bin/env bun
    import { Server } from '@modelcontextprotocol/sdk/server/index.js'
    import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'

    // Create the MCP server and declare it as a channel
    const mcp = new Server(
      { name: 'webhook', version: '0.0.1' },
      {
        // this key is what makes it a channel — Claude Code registers a listener for it
        capabilities: { experimental: { 'claude/channel': {} } },
        // added to Claude's system prompt so it knows how to handle these events
        instructions: 'Events from the webhook channel arrive as <channel source="webhook" ...>. They are one-way: read them and act, no reply expected.',
      },
    )

    // Connect to Claude Code over stdio (Claude Code spawns this process)
    await mcp.connect(new StdioServerTransport())

    // Start an HTTP server that forwards every POST to Claude
    Bun.serve({
      port: 8788,  // any open port works
      // localhost-only: nothing outside this machine can POST
      hostname: '127.0.0.1',
      async fetch(req) {
        const body = await req.text()
        await mcp.notification({
          method: 'notifications/claude/channel',
          params: {
            content: body,  // becomes the body of the <channel> tag
            // each key becomes a tag attribute, e.g. <channel path="/" method="POST">
            meta: { path: new URL(req.url).pathname, method: req.method },
          },
        })
        return new Response('ok')
      },
    })
    ```

    File này làm ba việc theo thứ tự:

    * **Cấu hình server**: tạo MCP server với `claude/channel` trong các capabilities của nó, đây chính là thứ cho Claude Code biết đây là một channel. Chuỗi [`instructions`](#server-options) đi vào system prompt của Claude: hãy nói cho Claude biết những sự kiện nào cần mong đợi, có trả lời hay không, và cách định tuyến các câu trả lời nếu nên trả lời.
    * **Kết nối stdio**: kết nối tới Claude Code qua stdin/stdout. Đây là chuẩn cho bất kỳ [MCP server](https://modelcontextprotocol.io/docs/concepts/transports#standard-io) nào: Claude Code sinh ra nó như một tiến trình con.
    * **Bộ lắng nghe HTTP**: khởi động một web server cục bộ trên cổng 8788. Mọi phần thân POST được chuyển tiếp tới Claude như một sự kiện channel qua `mcp.notification()`. `content` trở thành phần thân sự kiện, và mỗi mục `meta` trở thành một thuộc tính trên thẻ `<channel>`. Bộ lắng nghe cần truy cập tới instance `mcp`, nên nó chạy trong cùng tiến trình. Bạn có thể tách nó thành các module riêng cho một dự án lớn hơn.
  </Step>

  <Step title="Đăng ký server của bạn với Claude Code">
    Thêm server vào cấu hình MCP của bạn để Claude Code biết cách khởi động nó. Đối với một `.mcp.json` cấp dự án trong cùng thư mục, dùng đường dẫn tương đối. Đối với cấu hình cấp người dùng trong `~/.claude.json`, dùng đường dẫn tuyệt đối đầy đủ để server có thể được tìm thấy từ bất kỳ dự án nào:

    ```json title=".mcp.json" theme={null}
    {
      "mcpServers": {
        "webhook": { "command": "bun", "args": ["./webhook.ts"] }
      }
    }
    ```

    Claude Code đọc cấu hình MCP của bạn lúc khởi động và sinh ra mỗi server như một tiến trình con.
  </Step>

  <Step title="Thử nghiệm nó">
    Trong thời gian xem trước nghiên cứu, các channel tùy chỉnh không nằm trong danh sách cho phép, nên hãy khởi động Claude Code với cờ phát triển:

    ```bash theme={null}
    claude --dangerously-load-development-channels server:webhook
    ```

    Lần đầu tiên bạn bắt đầu một phiên trong dự án này, Claude Code hỏi sự đồng ý trước khi dùng server mới từ `.mcp.json`. Hộp thoại báo "New MCP server found in this project: webhook". Chọn **Use this MCP server** để tiếp tục.

    Khi Claude Code khởi động, nó đọc cấu hình MCP của bạn, sinh ra `webhook.ts` của bạn như một tiến trình con, và bộ lắng nghe HTTP khởi động tự động trên cổng bạn đã cấu hình (8788 trong ví dụ này). Bạn không cần tự chạy server.

    Một thông báo mờ bên dưới banner khởi động xác nhận channel đã đăng ký: `Channels (experimental) messages from server:webhook inject directly in this session · restart without --dangerously-load-development-channels to stop`.

    Nếu bạn thấy "blocked by org policy," admin tổ chức của bạn cần [bật channel](/en/channels#enterprise-controls) trước.

    Trong một terminal riêng, mô phỏng một webhook bằng cách gửi một HTTP POST với một tin nhắn tới server của bạn. Ví dụ này gửi một cảnh báo lỗi CI tới cổng 8788 (hoặc cổng nào bạn đã cấu hình):

    ```bash theme={null}
    curl -X POST localhost:8788 -d "build failed on main: https://ci.example.com/run/1234"
    ```

    Payload đến phiên Claude Code của bạn dưới dạng một thẻ `<channel>`:

    ```text theme={null}
    <channel source="webhook" path="/" method="POST">build failed on main: https://ci.example.com/run/1234</channel>
    ```

    Trong terminal Claude Code của bạn, bạn sẽ thấy Claude nhận tin nhắn và bắt đầu phản hồi: đọc file, chạy lệnh, hoặc bất cứ điều gì tin nhắn yêu cầu. Đây là một channel một chiều, nên Claude hành động trong phiên của bạn nhưng không gửi lại gì qua webhook. Để thêm trả lời, xem [Phơi bày một công cụ trả lời](#expose-a-reply-tool).

    Nếu sự kiện không đến, việc chẩn đoán phụ thuộc vào những gì `curl` trả về:

    * **`curl` thành công nhưng không có gì đến Claude**: chạy `/mcp` trong phiên của bạn để kiểm tra trạng thái server. "Failed to connect" thường có nghĩa là lỗi phụ thuộc (dependency) hoặc lỗi import trong file server của bạn; kiểm tra nhật ký gỡ lỗi tại `~/.claude/debug/<session-id>.txt` để xem trace stderr.
    * **`curl` thất bại với "connection refused"**: cổng chưa được bind hoặc một tiến trình cũ từ lần chạy trước đang giữ nó. `lsof -i :<port>` cho thấy cái gì đang lắng nghe; `kill` tiến trình cũ trước khi khởi động lại phiên của bạn.
  </Step>
</Steps>

[Server fakechat](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/fakechat) mở rộng khuôn mẫu này với một giao diện web, tệp đính kèm, và một công cụ trả lời cho chat hai chiều.

## Thử nghiệm trong thời gian xem trước nghiên cứu

Trong thời gian xem trước nghiên cứu, mọi channel phải nằm trong [danh sách cho phép đã phê duyệt](/en/channels#research-preview) để đăng ký. Cờ phát triển bỏ qua danh sách cho phép cho các mục cụ thể sau một lời nhắc xác nhận. Ví dụ này cho thấy cả hai loại mục:

```bash theme={null}
# Testing a plugin you're developing
claude --dangerously-load-development-channels plugin:yourplugin@yourmarketplace

# Testing a bare .mcp.json server (no plugin wrapper yet)
claude --dangerously-load-development-channels server:webhook
```

Việc bỏ qua là theo từng mục. Kết hợp cờ này với `--channels` không mở rộng việc bỏ qua tới các mục `--channels`. Trong thời gian xem trước nghiên cứu, danh sách cho phép đã phê duyệt do Anthropic quản lý, nên channel của bạn vẫn ở trên cờ phát triển trong khi bạn xây dựng và thử nghiệm.

<Note>
  Cờ này chỉ bỏ qua danh sách cho phép. Chính sách tổ chức `channelsEnabled` vẫn áp dụng. Đừng dùng nó để chạy channel từ các nguồn không đáng tin cậy.
</Note>

## Tùy chọn server

Một channel đặt các tùy chọn này trong hàm khởi tạo [`Server`](https://modelcontextprotocol.io/docs/concepts/servers). Các trường `instructions` và `capabilities.tools` là [MCP tiêu chuẩn](https://modelcontextprotocol.io/docs/concepts/servers); `capabilities.experimental['claude/channel']` và `capabilities.experimental['claude/channel/permission']` là các bổ sung đặc thù của channel:

| Trường                                                   | Loại     | Mô tả                                                                                                                                                                                                                                                                  |
| :------------------------------------------------------- | :------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `capabilities.experimental['claude/channel']`            | `object` | Bắt buộc. Luôn là `{}`. Sự hiện diện của nó đăng ký trình lắng nghe thông báo.                                                                                                                                                                                        |
| `capabilities.experimental['claude/channel/permission']` | `object` | Tùy chọn. Luôn là `{}`. Khai báo rằng channel này có thể nhận các yêu cầu chuyển tiếp quyền. Khi được khai báo, Claude Code chuyển tiếp các lời nhắc phê duyệt công cụ tới channel của bạn để bạn có thể phê duyệt hoặc từ chối chúng từ xa. Xem [Chuyển tiếp lời nhắc quyền](#relay-permission-prompts). |
| `capabilities.tools`                                     | `object` | Chỉ hai chiều. Luôn là `{}`. Khả năng công cụ MCP tiêu chuẩn. Xem [Phơi bày một công cụ trả lời](#expose-a-reply-tool).                                                                                                                                                |
| `instructions`                                           | `string` | Khuyến nghị. Được thêm vào system prompt của Claude. Hãy nói cho Claude biết những sự kiện nào cần mong đợi, các thuộc tính của thẻ `<channel>` nghĩa là gì, có trả lời hay không, và nếu có thì dùng công cụ nào và truyền lại thuộc tính nào (như `chat_id`).       |

Để tạo một channel một chiều, bỏ qua `capabilities.tools`. Ví dụ này cho thấy một thiết lập hai chiều với capability channel, tools, và instructions được đặt:

```ts theme={null}
import { Server } from '@modelcontextprotocol/sdk/server/index.js'

const mcp = new Server(
  { name: 'your-channel', version: '0.0.1' },
  {
    capabilities: {
      experimental: { 'claude/channel': {} },  // registers the channel listener
      tools: {},  // omit for one-way channels
    },
    // added to Claude's system prompt so it knows how to handle your events
    instructions: 'Messages arrive as <channel source="your-channel" ...>. Reply with the reply tool.',
  },
)
```

Để đẩy một sự kiện, gọi `mcp.notification()` với method `notifications/claude/channel`. Các params nằm trong phần tiếp theo.

## Định dạng thông báo

Server của bạn phát ra `notifications/claude/channel` với hai params:

| Trường    | Loại                     | Mô tả                                                                                                                                                                                                                                                                 |
| :-------- | :----------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `content` | `string`                 | Phần thân sự kiện. Được chuyển giao như phần thân của thẻ `<channel>`.                                                                                                                                                                                                 |
| `meta`    | `Record<string, string>` | Tùy chọn. Mỗi mục trở thành một thuộc tính trên thẻ `<channel>` cho ngữ cảnh định tuyến như ID chat, tên người gửi, hoặc mức độ nghiêm trọng của cảnh báo. Các key phải là định danh: chỉ chữ cái, chữ số, và dấu gạch dưới. Các key chứa dấu gạch nối hoặc ký tự khác bị âm thầm bỏ. |

Server của bạn đẩy các sự kiện bằng cách gọi `mcp.notification()` trên instance `Server`. Ví dụ này đẩy một cảnh báo lỗi CI với hai key meta:

```ts theme={null}
await mcp.notification({
  method: 'notifications/claude/channel',
  params: {
    content: 'build failed on main: https://ci.example.com/run/1234',
    meta: { severity: 'high', run_id: '1234' },
  },
})
```

Sự kiện đến ngữ cảnh của Claude được gói trong một thẻ `<channel>`. Thuộc tính `source` được đặt tự động từ tên đã cấu hình của server:

```text theme={null}
<channel source="your-channel" severity="high" run_id="1234">
build failed on main: https://ci.example.com/run/1234
</channel>
```

Thông báo không được xác nhận (acknowledge). `await` trên `mcp.notification()` được giải quyết khi tin nhắn được ghi vào transport, không phải khi Claude đã xử lý nó. Nếu phiên chưa nạp server của bạn như một channel, hoặc chính sách tổ chức chặn nó, các sự kiện bị bỏ âm thầm mà không có lỗi nào trả về cho server của bạn.

Nếu bạn cần xác nhận chuyển giao, hãy theo dõi trạng thái sự kiện trong server của bạn và phơi bày một [công cụ trả lời](#expose-a-reply-tool) mà Claude có thể gọi để báo cáo trạng thái lại.

Các sự kiện xếp hàng vào phiên và được xử lý theo thứ tự. Nếu nhiều thông báo đến trong khi Claude đang bận, chúng được chuyển giao cùng nhau ở lượt tiếp theo và Claude xử lý chúng như một nhóm. Để xử lý các luồng sự kiện độc lập đồng thời, hãy chạy các phiên riêng biệt.

## Phơi bày một công cụ trả lời

Nếu channel của bạn là hai chiều, như một cầu nối chat chứ không phải một bộ chuyển tiếp cảnh báo, hãy phơi bày một [công cụ MCP](https://modelcontextprotocol.io/docs/concepts/tools) tiêu chuẩn mà Claude có thể gọi để gửi tin nhắn lại. Không có gì về việc đăng ký công cụ là đặc thù của channel. Một công cụ trả lời có ba thành phần:

1. Một mục `tools: {}` trong các capabilities của hàm khởi tạo `Server` để Claude Code phát hiện ra công cụ
2. Các trình xử lý công cụ định nghĩa schema của công cụ và triển khai logic gửi
3. Một chuỗi `instructions` trong hàm khởi tạo `Server` cho Claude biết khi nào và cách gọi công cụ

Để thêm những thứ này vào [bộ nhận webhook ở trên](#example-build-a-webhook-receiver):

<Steps>
  <Step title="Bật việc phát hiện công cụ">
    Trong hàm khởi tạo `Server` trong `webhook.ts`, thêm `tools: {}` vào capabilities để Claude Code biết server của bạn cung cấp công cụ:

    ```ts theme={null}
    capabilities: {
      experimental: { 'claude/channel': {} },
      tools: {},  // enables tool discovery
    },
    ```
  </Step>

  <Step title="Đăng ký công cụ trả lời">
    Thêm nội dung sau vào `webhook.ts`. Câu lệnh `import` đặt ở đầu file cùng với các import khác của bạn; hai trình xử lý (handler) đặt giữa hàm khởi tạo `Server` và `mcp.connect()`. Việc này đăng ký một công cụ `reply` mà Claude có thể gọi với một `chat_id` và `text`:

    ```ts theme={null}
    // Add this import at the top of webhook.ts
    import { ListToolsRequestSchema, CallToolRequestSchema } from '@modelcontextprotocol/sdk/types.js'

    // Claude queries this at startup to discover what tools your server offers
    mcp.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [{
        name: 'reply',
        description: 'Send a message back over this channel',
        // inputSchema tells Claude what arguments to pass
        inputSchema: {
          type: 'object',
          properties: {
            chat_id: { type: 'string', description: 'The conversation to reply in' },
            text: { type: 'string', description: 'The message to send' },
          },
          required: ['chat_id', 'text'],
        },
      }],
    }))

    // Claude calls this when it wants to invoke a tool
    mcp.setRequestHandler(CallToolRequestSchema, async req => {
      if (req.params.name === 'reply') {
        const { chat_id, text } = req.params.arguments as { chat_id: string; text: string }
        // send() is your outbound: POST to your chat platform, or for local
        // testing the SSE broadcast shown in the full example below.
        send(`Reply to ${chat_id}: ${text}`)
        return { content: [{ type: 'text', text: 'sent' }] }
      }
      throw new Error(`unknown tool: ${req.params.name}`)
    })
    ```
  </Step>

  <Step title="Cập nhật instructions">
    Cập nhật chuỗi `instructions` trong hàm khởi tạo `Server` của bạn để Claude biết định tuyến các câu trả lời qua công cụ. Ví dụ này bảo Claude truyền `chat_id` từ thẻ đến:

    ```ts theme={null}
    instructions: 'Messages arrive as <channel source="webhook" chat_id="...">. Reply with the reply tool, passing the chat_id from the tag.'
    ```
  </Step>
</Steps>

Đây là `webhook.ts` hoàn chỉnh với hỗ trợ hai chiều. Các câu trả lời đi ra streaming qua `GET /events` bằng [Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) (SSE), nên `curl -N localhost:8788/events` có thể theo dõi chúng trực tiếp; chat đến đi vào trên `POST /`:

```ts title="Full webhook.ts with reply tool" expandable theme={null}
#!/usr/bin/env bun
import { Server } from '@modelcontextprotocol/sdk/server/index.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'
import { ListToolsRequestSchema, CallToolRequestSchema } from '@modelcontextprotocol/sdk/types.js'

// --- Outbound: write to any curl -N listeners on /events --------------------
// A real bridge would POST to your chat platform instead.
const listeners = new Set<(chunk: string) => void>()
function send(text: string) {
  const chunk = text.split('\n').map(l => `data: ${l}\n`).join('') + '\n'
  for (const emit of listeners) emit(chunk)
}

const mcp = new Server(
  { name: 'webhook', version: '0.0.1' },
  {
    capabilities: {
      experimental: { 'claude/channel': {} },
      tools: {},
    },
    instructions: 'Messages arrive as <channel source="webhook" chat_id="...">. Reply with the reply tool, passing the chat_id from the tag.',
  },
)

mcp.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [{
    name: 'reply',
    description: 'Send a message back over this channel',
    inputSchema: {
      type: 'object',
      properties: {
        chat_id: { type: 'string', description: 'The conversation to reply in' },
        text: { type: 'string', description: 'The message to send' },
      },
      required: ['chat_id', 'text'],
    },
  }],
}))

mcp.setRequestHandler(CallToolRequestSchema, async req => {
  if (req.params.name === 'reply') {
    const { chat_id, text } = req.params.arguments as { chat_id: string; text: string }
    send(`Reply to ${chat_id}: ${text}`)
    return { content: [{ type: 'text', text: 'sent' }] }
  }
  throw new Error(`unknown tool: ${req.params.name}`)
})

await mcp.connect(new StdioServerTransport())

let nextId = 1
Bun.serve({
  port: 8788,
  hostname: '127.0.0.1',
  idleTimeout: 0,  // don't close idle SSE streams
  async fetch(req) {
    const url = new URL(req.url)

    // GET /events: SSE stream so curl -N can watch Claude's replies live
    if (req.method === 'GET' && url.pathname === '/events') {
      const stream = new ReadableStream({
        start(ctrl) {
          ctrl.enqueue(': connected\n\n')  // so curl shows something immediately
          const emit = (chunk: string) => ctrl.enqueue(chunk)
          listeners.add(emit)
          req.signal.addEventListener('abort', () => listeners.delete(emit))
        },
      })
      return new Response(stream, {
        headers: { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache' },
      })
    }

    // POST: forward to Claude as a channel event
    const body = await req.text()
    const chat_id = String(nextId++)
    await mcp.notification({
      method: 'notifications/claude/channel',
      params: {
        content: body,
        meta: { chat_id, path: url.pathname, method: req.method },
      },
    })
    return new Response('ok')
  },
})
```

[Server fakechat](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/fakechat) cho thấy một ví dụ đầy đủ hơn với tệp đính kèm và chỉnh sửa tin nhắn.

## Kiểm soát tin nhắn đến

Một channel không được kiểm soát là một vector prompt injection. Bất kỳ ai có thể tiếp cận endpoint của bạn đều có thể đặt văn bản trước mặt Claude. Một channel lắng nghe một nền tảng chat hoặc một endpoint công khai cần một kiểm tra người gửi thực sự trước khi nó phát ra bất cứ thứ gì.

Kiểm tra người gửi so với một danh sách cho phép trước khi gọi `mcp.notification()`. Ví dụ này bỏ bất kỳ tin nhắn nào từ một người gửi không nằm trong tập:

```ts theme={null}
const allowed = new Set(loadAllowlist())  // from your access.json or equivalent

// inside your message handler, before emitting:
if (!allowed.has(message.from.id)) {  // sender, not room
  return  // drop silently
}
await mcp.notification({ ... })
```

Kiểm soát dựa trên danh tính của người gửi, không phải danh tính của chat hoặc phòng: `message.from.id` trong ví dụ, không phải `message.chat.id`. Trong các chat nhóm, hai cái này khác nhau, và kiểm soát dựa trên phòng sẽ cho phép bất kỳ ai trong một nhóm được cho phép chèn tin nhắn vào phiên.

Các channel [Telegram](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/telegram) và [Discord](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/discord) kiểm soát dựa trên một danh sách cho phép người gửi theo cùng cách. Chúng khởi tạo danh sách bằng cách ghép nối: người dùng DM cho bot, bot trả lời với một mã ghép nối, người dùng phê duyệt nó trong phiên Claude Code của họ, và ID nền tảng của họ được thêm vào. Xem một trong hai triển khai để biết luồng ghép nối đầy đủ. Channel [iMessage](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/imessage) áp dụng cách tiếp cận khác: nó phát hiện các địa chỉ của chính người dùng từ cơ sở dữ liệu Messages lúc khởi động và cho họ đi qua tự động, với những người gửi khác được thêm bằng handle.

## Chuyển tiếp lời nhắc quyền

<Note>
  Chuyển tiếp quyền yêu cầu Claude Code v2.1.81 trở lên. Các phiên bản cũ hơn bỏ qua khả năng `claude/channel/permission`.
</Note>

Khi Claude gọi một công cụ cần phê duyệt, hộp thoại terminal cục bộ mở ra và phiên chờ. Một channel hai chiều có thể chọn bật nhận cùng lời nhắc đó song song và chuyển tiếp nó tới bạn trên một thiết bị khác. Cả hai vẫn hoạt động: bạn có thể trả lời trong terminal hoặc trên điện thoại, và Claude Code áp dụng câu trả lời nào đến trước và đóng câu còn lại.

Chuyển tiếp bao trùm các phê duyệt sử dụng công cụ như `Bash`, `Write`, và `Edit`. Các hộp thoại tin cậy dự án (project trust) và đồng ý MCP server không được chuyển tiếp; những cái đó chỉ xuất hiện trong terminal cục bộ.

### Chuyển tiếp hoạt động thế nào

Khi một lời nhắc quyền mở ra, vòng lặp chuyển tiếp có bốn bước:

1. Claude Code sinh ra một ID yêu cầu ngắn và thông báo cho server của bạn
2. Server của bạn chuyển tiếp lời nhắc và ID tới ứng dụng chat của bạn
3. Người dùng từ xa trả lời với một yes hoặc no cùng với ID đó
4. Trình xử lý tin đến của bạn phân tích câu trả lời thành một phán quyết (verdict), và Claude Code chỉ áp dụng nó nếu ID khớp với một yêu cầu đang mở

Hộp thoại terminal cục bộ vẫn mở suốt quá trình này. Nếu ai đó tại terminal trả lời trước khi phán quyết từ xa đến, câu trả lời đó được áp dụng thay thế và yêu cầu từ xa đang chờ bị bỏ.

<img src="https://mintcdn.com/claude-code/DsZvsJII1OmzIjIs/en/images/channel-permission-relay.svg?fit=max&auto=format&n=DsZvsJII1OmzIjIs&q=85&s=c1d75f6ee34c2757983e2cca899b90d1" alt="Sơ đồ trình tự: Claude Code gửi một thông báo permission_request tới channel server, server định dạng và gửi lời nhắc tới ứng dụng chat, con người trả lời với một phán quyết, và server phân tích câu trả lời đó thành một thông báo permission trở lại Claude Code" width="600" height="230" data-path="en/images/channel-permission-relay.svg" />

### Các trường của yêu cầu quyền

Thông báo đi ra từ Claude Code là `notifications/claude/channel/permission_request`. Giống như [thông báo channel](#notification-format), transport là MCP tiêu chuẩn nhưng method và schema là các phần mở rộng của Claude Code. Đối tượng `params` có bốn trường chuỗi mà server của bạn định dạng vào lời nhắc đi ra:

| Trường          | Mô tả                                                                                                                                                                                                                                                                                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `request_id`    | Năm chữ cái thường lấy từ `a`-`z` không có `l`, nên nó không bao giờ đọc thành `1` hoặc `I` khi gõ trên điện thoại. Bao gồm nó trong lời nhắc đi ra của bạn để nó có thể được lặp lại trong câu trả lời. Claude Code chỉ chấp nhận một phán quyết mang một ID mà nó đã cấp. Hộp thoại terminal cục bộ không hiển thị ID này, nên trình xử lý đi ra của bạn là cách duy nhất để biết nó. |
| `tool_name`     | Tên của công cụ Claude muốn dùng, ví dụ `Bash` hoặc `Write`.                                                                                                                                                                                                                                                                                                    |
| `description`   | Tóm tắt dễ đọc về những gì lệnh gọi công cụ cụ thể này làm, cùng văn bản mà hộp thoại terminal cục bộ hiển thị. Đối với một lệnh gọi Bash đây là mô tả của Claude về lệnh, hoặc chính lệnh đó nếu không có mô tả nào được đưa ra.                                                                                                                                    |
| `input_preview` | Các đối số của công cụ dưới dạng một chuỗi JSON, cắt ngắn còn 200 ký tự. Đối với Bash đây là lệnh; đối với Write là đường dẫn file và một phần tiền tố của nội dung. Bỏ nó khỏi lời nhắc của bạn nếu bạn chỉ có chỗ cho một tin nhắn một dòng. Server của bạn quyết định hiển thị gì.                                                                              |

Phán quyết mà server của bạn gửi lại là `notifications/claude/channel/permission` với hai trường: `request_id` lặp lại ID ở trên, và `behavior` được đặt thành `'allow'` hoặc `'deny'`. Allow cho phép lệnh gọi công cụ tiếp tục; deny từ chối nó, giống như trả lời No trong hộp thoại cục bộ. Không phán quyết nào ảnh hưởng tới các lệnh gọi trong tương lai.

### Thêm chuyển tiếp vào một cầu nối chat

Việc thêm chuyển tiếp quyền vào một channel hai chiều cần ba thành phần:

1. Một mục `claude/channel/permission: {}` dưới capabilities `experimental` trong hàm khởi tạo `Server` của bạn để Claude Code biết chuyển tiếp các lời nhắc
2. Một trình xử lý thông báo cho `notifications/claude/channel/permission_request` định dạng lời nhắc và gửi nó ra qua API nền tảng của bạn
3. Một kiểm tra trong trình xử lý tin đến của bạn nhận diện `yes <id>` hoặc `no <id>` và phát ra một phán quyết `notifications/claude/channel/permission` thay vì chuyển tiếp văn bản tới Claude

Chỉ khai báo khả năng này nếu channel của bạn [xác thực người gửi](#gate-inbound-messages), vì bất kỳ ai có thể trả lời qua channel của bạn đều có thể phê duyệt hoặc từ chối việc dùng công cụ trong phiên của bạn.

Để thêm những thứ này vào một cầu nối chat hai chiều như cái được lắp ráp trong [Phơi bày một công cụ trả lời](#expose-a-reply-tool):

<Steps>
  <Step title="Khai báo khả năng quyền">
    Trong hàm khởi tạo `Server` của bạn, thêm `claude/channel/permission: {}` bên cạnh `claude/channel` dưới `experimental`:

    ```ts theme={null}
    capabilities: {
      experimental: {
        'claude/channel': {},
        'claude/channel/permission': {},  // opt in to permission relay
      },
      tools: {},
    },
    ```
  </Step>

  <Step title="Xử lý yêu cầu đến">
    Đăng ký một trình xử lý thông báo giữa hàm khởi tạo `Server` và `mcp.connect()`. Claude Code gọi nó với [bốn trường yêu cầu](#permission-request-fields) khi một hộp thoại quyền mở ra. Trình xử lý của bạn định dạng lời nhắc cho nền tảng của bạn và bao gồm hướng dẫn trả lời với ID:

    ```ts theme={null}
    import { z } from 'zod'

    // setNotificationHandler routes by z.literal on the method field,
    // so this schema is both the validator and the dispatch key
    const PermissionRequestSchema = z.object({
      method: z.literal('notifications/claude/channel/permission_request'),
      params: z.object({
        request_id: z.string(),     // five lowercase letters, include verbatim in your prompt
        tool_name: z.string(),      // e.g. "Bash", "Write"
        description: z.string(),    // human-readable summary of this call
        input_preview: z.string(),  // tool args as JSON, truncated to ~200 chars
      }),
    })

    mcp.setNotificationHandler(PermissionRequestSchema, async ({ params }) => {
      // send() is your outbound: POST to your chat platform, or for local
      // testing the SSE broadcast shown in the full example below.
      send(
        `Claude wants to run ${params.tool_name}: ${params.description}\n\n` +
        // the ID in the instruction is what your inbound handler parses in Step 3
        `Reply "yes ${params.request_id}" or "no ${params.request_id}"`,
      )
    })
    ```
  </Step>

  <Step title="Chặn phán quyết trong trình xử lý tin đến của bạn">
    Trình xử lý tin đến của bạn là vòng lặp hoặc callback nhận tin nhắn từ nền tảng của bạn: cùng nơi bạn [kiểm soát người gửi](#gate-inbound-messages) và phát ra `notifications/claude/channel` để chuyển tiếp chat tới Claude. Thêm một kiểm tra trước lệnh gọi chuyển tiếp chat, nhận diện định dạng phán quyết và phát ra thông báo quyền thay thế.

    Regex khớp định dạng ID mà Claude Code sinh ra: năm chữ cái, không bao giờ `l`. Cờ `/i` chấp nhận việc tự động sửa (autocorrect) của điện thoại viết hoa câu trả lời; hãy chuyển ID đã bắt được về chữ thường trước khi gửi lại.

    ```ts theme={null}
    // matches "y abcde", "yes abcde", "n abcde", "no abcde"
    // [a-km-z] is the ID alphabet Claude Code uses (lowercase, skips 'l')
    // /i tolerates phone autocorrect; lowercase the capture before sending
    const PERMISSION_REPLY_RE = /^\s*(y|yes|n|no)\s+([a-km-z]{5})\s*$/i

    async function onInbound(message: PlatformMessage) {
      if (!allowed.has(message.from.id)) return  // gate on sender first

      const m = PERMISSION_REPLY_RE.exec(message.text)
      if (m) {
        // m[1] is the verdict word, m[2] is the request ID
        // emit the verdict notification back to Claude Code instead of chat
        await mcp.notification({
          method: 'notifications/claude/channel/permission',
          params: {
            request_id: m[2].toLowerCase(),  // normalize in case of autocorrect caps
            behavior: m[1].toLowerCase().startsWith('y') ? 'allow' : 'deny',
          },
        })
        return  // handled as verdict, don't also forward as chat
      }

      // didn't match verdict format: fall through to the normal chat path
      await mcp.notification({
        method: 'notifications/claude/channel',
        params: { content: message.text, meta: { chat_id: String(message.chat.id) } },
      })
    }
    ```
  </Step>
</Steps>

Claude Code cũng giữ hộp thoại terminal cục bộ mở, nên bạn có thể trả lời ở một trong hai nơi, và câu trả lời đầu tiên đến được áp dụng. Một câu trả lời từ xa không khớp chính xác định dạng mong đợi sẽ thất bại theo một trong hai cách, và trong cả hai trường hợp hộp thoại vẫn mở:

* **Định dạng khác**: regex trong trình xử lý tin đến của bạn không khớp, nên văn bản như `approve it` hoặc `yes` không có ID rơi xuống như một tin nhắn thường tới Claude.
* **Đúng định dạng, sai ID**: server của bạn phát ra một phán quyết, nhưng Claude Code không tìm thấy yêu cầu đang mở nào với ID đó và bỏ nó âm thầm.

### Ví dụ đầy đủ

`webhook.ts` được lắp ráp bên dưới kết hợp cả ba phần mở rộng từ trang này: công cụ trả lời, kiểm soát người gửi, và chuyển tiếp quyền. Nếu bạn bắt đầu từ đây, bạn cũng cần [thiết lập dự án và mục `.mcp.json`](#example-build-a-webhook-receiver) từ hướng dẫn ban đầu.

Để làm cho cả hai chiều có thể thử nghiệm được từ curl, bộ lắng nghe HTTP phục vụ hai đường dẫn:

* **`GET /events`**: giữ một luồng SSE mở và đẩy mỗi tin nhắn đi ra như một dòng `data:`, nên `curl -N` có thể theo dõi các câu trả lời và lời nhắc quyền của Claude đến trực tiếp.
* **`POST /`**: phía đến, cùng trình xử lý như trước, giờ có kiểm tra định dạng phán quyết được chèn vào trước nhánh chuyển tiếp chat.

```ts title="Full webhook.ts with permission relay" expandable theme={null}
#!/usr/bin/env bun
import { Server } from '@modelcontextprotocol/sdk/server/index.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'
import { ListToolsRequestSchema, CallToolRequestSchema } from '@modelcontextprotocol/sdk/types.js'
import { z } from 'zod'

// --- Outbound: write to any curl -N listeners on /events --------------------
// A real bridge would POST to your chat platform instead.
const listeners = new Set<(chunk: string) => void>()
function send(text: string) {
  const chunk = text.split('\n').map(l => `data: ${l}\n`).join('') + '\n'
  for (const emit of listeners) emit(chunk)
}

// Sender allowlist. For the local walkthrough we trust the single X-Sender
// header value "dev"; a real bridge would check the platform's user ID.
const allowed = new Set(['dev'])

const mcp = new Server(
  { name: 'webhook', version: '0.0.1' },
  {
    capabilities: {
      experimental: {
        'claude/channel': {},
        'claude/channel/permission': {},  // opt in to permission relay
      },
      tools: {},
    },
    instructions:
      'Messages arrive as <channel source="webhook" chat_id="...">. ' +
      'Reply with the reply tool, passing the chat_id from the tag.',
  },
)

// --- reply tool: Claude calls this to send a message back -------------------
mcp.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [{
    name: 'reply',
    description: 'Send a message back over this channel',
    inputSchema: {
      type: 'object',
      properties: {
        chat_id: { type: 'string', description: 'The conversation to reply in' },
        text: { type: 'string', description: 'The message to send' },
      },
      required: ['chat_id', 'text'],
    },
  }],
}))

mcp.setRequestHandler(CallToolRequestSchema, async req => {
  if (req.params.name === 'reply') {
    const { chat_id, text } = req.params.arguments as { chat_id: string; text: string }
    send(`Reply to ${chat_id}: ${text}`)
    return { content: [{ type: 'text', text: 'sent' }] }
  }
  throw new Error(`unknown tool: ${req.params.name}`)
})

// --- permission relay: Claude Code (not Claude) calls this when a dialog opens
const PermissionRequestSchema = z.object({
  method: z.literal('notifications/claude/channel/permission_request'),
  params: z.object({
    request_id: z.string(),
    tool_name: z.string(),
    description: z.string(),
    input_preview: z.string(),
  }),
})

mcp.setNotificationHandler(PermissionRequestSchema, async ({ params }) => {
  send(
    `Claude wants to run ${params.tool_name}: ${params.description}\n\n` +
    `Reply "yes ${params.request_id}" or "no ${params.request_id}"`,
  )
})

await mcp.connect(new StdioServerTransport())

// --- HTTP on :8788: GET /events streams outbound, POST routes inbound -------
const PERMISSION_REPLY_RE = /^\s*(y|yes|n|no)\s+([a-km-z]{5})\s*$/i
let nextId = 1

Bun.serve({
  port: 8788,
  hostname: '127.0.0.1',
  idleTimeout: 0,  // don't close idle SSE streams
  async fetch(req) {
    const url = new URL(req.url)

    // GET /events: SSE stream so curl -N can watch replies and prompts live
    if (req.method === 'GET' && url.pathname === '/events') {
      const stream = new ReadableStream({
        start(ctrl) {
          ctrl.enqueue(': connected\n\n')  // so curl shows something immediately
          const emit = (chunk: string) => ctrl.enqueue(chunk)
          listeners.add(emit)
          req.signal.addEventListener('abort', () => listeners.delete(emit))
        },
      })
      return new Response(stream, {
        headers: { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache' },
      })
    }

    // everything else is inbound: gate on sender first
    const body = await req.text()
    const sender = req.headers.get('X-Sender') ?? ''
    if (!allowed.has(sender)) return new Response('forbidden', { status: 403 })

    // check for verdict format before treating as chat
    const m = PERMISSION_REPLY_RE.exec(body)
    if (m) {
      await mcp.notification({
        method: 'notifications/claude/channel/permission',
        params: {
          request_id: m[2].toLowerCase(),
          behavior: m[1].toLowerCase().startsWith('y') ? 'allow' : 'deny',
        },
      })
      return new Response('verdict recorded')
    }

    // normal chat: forward to Claude as a channel event
    const chat_id = String(nextId++)
    await mcp.notification({
      method: 'notifications/claude/channel',
      params: { content: body, meta: { chat_id, path: url.pathname } },
    })
    return new Response('ok')
  },
})
```

Thử nghiệm đường dẫn phán quyết trong ba terminal. Cái đầu tiên là phiên Claude Code của bạn, được khởi động với [cờ phát triển](#test-during-the-research-preview) để nó sinh ra `webhook.ts`:

```bash theme={null}
claude --dangerously-load-development-channels server:webhook
```

Trong cái thứ hai, stream phía đi ra để bạn có thể thấy các câu trả lời của Claude và bất kỳ lời nhắc quyền nào khi chúng kích hoạt:

```bash theme={null}
curl -N localhost:8788/events
```

Trong cái thứ ba, gửi một tin nhắn khiến Claude thử chạy một lệnh:

```bash theme={null}
curl -d "list the files in this directory" -H "X-Sender: dev" localhost:8788
```

Liệt kê file là chỉ-đọc (read-only), nên Claude chạy nó mà không cần phê duyệt. Hộp thoại quyền mở ra khi Claude gọi công cụ `reply` để gửi câu trả lời của nó lại. Hộp thoại cục bộ mở trong terminal Claude Code của bạn, và một lúc sau lời nhắc cho `mcp__webhook__reply` xuất hiện trong luồng `/events`, bao gồm ID năm chữ cái. Phê duyệt nó từ phía từ xa:

```bash theme={null}
curl -d "yes <id>" -H "X-Sender: dev" localhost:8788
```

Hộp thoại cục bộ đóng lại, công cụ `reply` chạy, và câu trả lời của Claude rơi vào luồng.

Ba phần đặc thù của channel trong file này:

* **Capabilities** trong hàm khởi tạo `Server`: `claude/channel` đăng ký trình lắng nghe thông báo, `claude/channel/permission` chọn bật chuyển tiếp quyền, `tools` cho phép Claude phát hiện công cụ trả lời.
* **Các đường đi ra**: trình xử lý công cụ `reply` là thứ Claude gọi cho các phản hồi hội thoại; trình xử lý thông báo `PermissionRequestSchema` là thứ Claude Code gọi khi một hộp thoại quyền mở ra. Cả hai đều gọi `send()` để phát qua `/events`, nhưng chúng được kích hoạt bởi các phần khác nhau của hệ thống.
* **Trình xử lý HTTP**: `GET /events` giữ một luồng SSE mở để curl có thể theo dõi đi ra trực tiếp; `POST` là đến, được kiểm soát dựa trên header `X-Sender`. Một phần thân `yes <id>` hoặc `no <id>` đi tới Claude Code như một thông báo phán quyết và không bao giờ tới Claude; bất cứ thứ gì khác được chuyển tiếp tới Claude như một sự kiện channel.

## Đóng gói thành một plugin

Để làm cho channel của bạn có thể cài đặt và chia sẻ được, hãy gói nó trong một [plugin](/en/plugins) và xuất bản nó lên một [marketplace](/en/plugin-marketplaces). Người dùng cài đặt nó bằng `/plugin install`, sau đó bật nó theo từng phiên với `--channels plugin:<name>@<marketplace>`.

Một channel được xuất bản lên marketplace của riêng bạn vẫn cần `--dangerously-load-development-channels` để chạy, vì nó không nằm trong [danh sách cho phép đã phê duyệt](/en/channels#supported-channels). Danh sách cho phép mặc định là các plugin channel trong `claude-plugins-official`, mà Anthropic quản lý theo quyết định của mình. Các [biểu mẫu nộp trong ứng dụng](/en/plugins#submit-your-plugin-to-the-community-marketplace) thêm plugin vào marketplace cộng đồng, mà không nằm trong danh sách cho phép channel.

Nếu bạn đang làm việc với một liên hệ đối tác của Anthropic, hãy liên hệ với họ để phối hợp một danh sách trên marketplace chính thức. Trên các gói Team và Enterprise, một admin có thể thay vào đó bao gồm plugin của bạn trong danh sách [`allowedChannelPlugins`](/en/channels#restrict-which-channel-plugins-can-run) của riêng tổ chức, thay thế danh sách cho phép mặc định của Anthropic.

## Xem thêm

* [Channel](/en/channels) để cài đặt và dùng Telegram, Discord, iMessage, hoặc demo fakechat, và để bật channel cho một tổ chức Team hoặc Enterprise
* [Các triển khai channel đang hoạt động](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins) để có mã server đầy đủ với các luồng ghép nối, công cụ trả lời, và tệp đính kèm
* [MCP](/en/mcp) để biết giao thức nền tảng mà các channel server triển khai
* [Plugin](/en/plugins) để đóng gói channel của bạn để người dùng có thể cài đặt nó bằng `/plugin install`
