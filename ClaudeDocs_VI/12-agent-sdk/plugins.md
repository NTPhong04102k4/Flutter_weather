> Nguồn: https://code.claude.com/docs/en/agent-sdk/plugins.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Plugin trong SDK

> Tải các plugin tùy chỉnh để mở rộng Claude Code với skill, agent, hook và MCP server thông qua Agent SDK

Plugin cho phép bạn mở rộng Claude Code với chức năng tùy chỉnh có thể chia sẻ giữa các dự án. Thông qua Agent SDK, bạn có thể tải plugin từ các thư mục cục bộ theo cách lập trình để bổ sung skill, agent, hook và MCP server vào các phiên làm việc của agent.

## Plugin là gì?

Plugin là các gói mở rộng của Claude Code, có thể bao gồm:

* **Skill**: Các năng lực do model tự gọi mà Claude sử dụng một cách tự chủ (cũng có thể được gọi bằng `/skill-name`)
* **Agent**: Các subagent chuyên biệt cho các tác vụ cụ thể
* **Hook**: Các trình xử lý sự kiện phản hồi khi có việc sử dụng công cụ và các sự kiện khác
* **MCP server**: Các tích hợp công cụ bên ngoài thông qua Model Context Protocol

<Note>
  Thư mục `commands/` là định dạng cũ (legacy). Hãy dùng `skills/` cho các plugin mới. Claude Code vẫn tiếp tục hỗ trợ cả hai định dạng để tương thích ngược.
</Note>

Để biết đầy đủ thông tin về cấu trúc plugin và cách tạo plugin, xem [Plugins](/en/plugins).

## Tải plugin

Tải plugin bằng cách cung cấp đường dẫn hệ thống tệp cục bộ của chúng trong cấu hình options của bạn. Trường `type` phải là `"local"`, giá trị duy nhất mà SDK chấp nhận. Để dùng một plugin được phân phối qua [marketplace](/en/plugin-marketplaces) hoặc kho lưu trữ từ xa, hãy tải nó về trước rồi cung cấp đường dẫn thư mục cục bộ. SDK hỗ trợ tải nhiều plugin từ các vị trí khác nhau.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Hello",
    options: {
      plugins: [
        { type: "local", path: "./my-plugin" },
        { type: "local", path: "/absolute/path/to/another-plugin" }
      ]
    }
  })) {
    // Plugin commands, agents, and other features are now available
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions


  async def main():
      async for message in query(
          prompt="Hello",
          options=ClaudeAgentOptions(
              plugins=[
                  {"type": "local", "path": "./my-plugin"},
                  {"type": "local", "path": "/absolute/path/to/another-plugin"},
              ]
          ),
      ):
          # Plugin commands, agents, and other features are now available
          pass


  asyncio.run(main())
  ```
</CodeGroup>

### Đặc tả đường dẫn

Đường dẫn plugin có thể là:

* **Đường dẫn tương đối**: Được phân giải tương đối so với thư mục làm việc hiện tại của bạn (ví dụ: `"./plugins/my-plugin"`)
* **Đường dẫn tuyệt đối**: Đường dẫn hệ thống tệp đầy đủ (ví dụ: `"/home/user/plugins/my-plugin"`)

<Note>
  Đường dẫn phải trỏ tới thư mục gốc của plugin: thư mục cha của `skills/`, `agents/`, `hooks/`, `commands/` (legacy), hoặc `.claude-plugin/`, chứ không phải một thư mục con.
</Note>

## Xác minh việc cài đặt plugin

Khi các plugin được tải thành công, chúng sẽ xuất hiện trong thông điệp khởi tạo hệ thống. Bạn có thể xác minh rằng plugin của mình đã sẵn sàng:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Hello",
    options: {
      plugins: [{ type: "local", path: "./my-plugin" }]
    }
  })) {
    if (message.type === "system" && message.subtype === "init") {
      // Check loaded plugins
      console.log("Plugins:", message.plugins);
      // Example: [{ name: "my-plugin", path: "./my-plugin" }]

      // Plugin skills appear with the plugin name as a prefix
      console.log("Skills:", message.skills);
      // Example: ["my-plugin:greet"]

      // Plugin commands use the same prefix, and skills appear here too
      console.log("Commands:", message.slash_commands);
      // Example: ["compact", "context", "my-plugin:custom-command", "my-plugin:greet"]
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage


  async def main():
      async for message in query(
          prompt="Hello",
          options=ClaudeAgentOptions(
              plugins=[{"type": "local", "path": "./my-plugin"}]
          ),
      ):
          if isinstance(message, SystemMessage) and message.subtype == "init":
              # Check loaded plugins
              print("Plugins:", message.data.get("plugins"))
              # Example: [{"name": "my-plugin", "path": "./my-plugin"}]

              # Plugin skills appear with the plugin name as a prefix
              print("Skills:", message.data.get("skills"))
              # Example: ["my-plugin:greet"]

              # Plugin commands use the same prefix, and skills appear here too
              print("Commands:", message.data.get("slash_commands"))
              # Example: ["compact", "context", "my-plugin:custom-command", "my-plugin:greet"]


  asyncio.run(main())
  ```
</CodeGroup>

## Sử dụng skill của plugin

Skill từ plugin sẽ tự động được đặt trong không gian tên (namespace) với tên plugin để tránh xung đột. Để gọi trực tiếp một skill, hãy gửi `/plugin-name:skill-name` làm prompt.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Load a plugin with a custom /greet skill
  for await (const message of query({
    prompt: "/my-plugin:greet", // Use plugin skill with namespace
    options: {
      plugins: [{ type: "local", path: "./my-plugin" }]
    }
  })) {
    // Claude executes the custom greeting skill from the plugin
    if (message.type === "assistant") {
      console.log(message.message.content);
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock


  async def main():
      # Load a plugin with a custom /greet skill
      async for message in query(
          prompt="/demo-plugin:greet",  # Use plugin skill with namespace
          options=ClaudeAgentOptions(
              plugins=[{"type": "local", "path": "./plugins/demo-plugin"}]
          ),
      ):
          # Claude executes the custom greeting skill from the plugin
          if isinstance(message, AssistantMessage):
              for block in message.content:
                  if isinstance(block, TextBlock):
                      print(f"Claude: {block.text}")


  asyncio.run(main())
  ```
</CodeGroup>

<Note>
  Nếu bạn đã cài một plugin qua CLI (ví dụ: `/plugin install my-plugin@marketplace`), bạn vẫn có thể dùng nó trong SDK bằng cách cung cấp đường dẫn cài đặt của nó. Kiểm tra `~/.claude/plugins/` để tìm các plugin được cài qua CLI.
</Note>

## Ví dụ hoàn chỉnh

Dưới đây là một ví dụ đầy đủ minh họa việc tải và sử dụng plugin:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";
  import * as path from "path";

  async function runWithPlugin() {
    const pluginPath = path.join(__dirname, "plugins", "my-plugin");

    console.log("Loading plugin from:", pluginPath);

    for await (const message of query({
      prompt: "What custom commands do you have available?",
      options: {
        plugins: [{ type: "local", path: pluginPath }],
        maxTurns: 3
      }
    })) {
      if (message.type === "system" && message.subtype === "init") {
        console.log("Loaded plugins:", message.plugins);
        console.log("Available skills:", message.skills);
        console.log("Available commands:", message.slash_commands);
      }

      if (message.type === "assistant") {
        console.log("Assistant:", message.message.content);
      }
    }
  }

  runWithPlugin().catch(console.error);
  ```

  ```python Python theme={null}
  #!/usr/bin/env python3
  """Example demonstrating how to use plugins with the Agent SDK."""

  from pathlib import Path
  import anyio
  from claude_agent_sdk import (
      AssistantMessage,
      ClaudeAgentOptions,
      SystemMessage,
      TextBlock,
      query,
  )


  async def run_with_plugin():
      """Example using a custom plugin."""
      plugin_path = Path(__file__).parent / "plugins" / "demo-plugin"

      print(f"Loading plugin from: {plugin_path}")

      options = ClaudeAgentOptions(
          plugins=[{"type": "local", "path": str(plugin_path)}],
          max_turns=3,
      )

      async for message in query(
          prompt="What custom commands do you have available?", options=options
      ):
          if isinstance(message, SystemMessage) and message.subtype == "init":
              print(f"Loaded plugins: {message.data.get('plugins')}")
              print(f"Available skills: {message.data.get('skills')}")
              print(f"Available commands: {message.data.get('slash_commands')}")

          if isinstance(message, AssistantMessage):
              for block in message.content:
                  if isinstance(block, TextBlock):
                      print(f"Assistant: {block.text}")


  if __name__ == "__main__":
      anyio.run(run_with_plugin)
  ```
</CodeGroup>

## Tài liệu tham chiếu cấu trúc plugin

Một thư mục plugin thường chứa tệp manifest `.claude-plugin/plugin.json`. Manifest là tùy chọn. Khi bỏ qua, Claude Code sẽ tự động khám phá các thành phần từ bố cục thư mục. Thư mục có thể bao gồm:

```text theme={null}
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (optional, components auto-discovered without it)
├── skills/                   # Agent Skills (invoked autonomously or via /skill-name)
│   └── my-skill/
│       └── SKILL.md
├── commands/                 # Legacy: use skills/ instead
│   └── custom-cmd.md
├── agents/                   # Custom agents
│   └── specialist.md
├── hooks/                    # Event handlers
│   └── hooks.json
└── .mcp.json                # MCP server definitions
```

Để biết thông tin chi tiết về cách tạo plugin, xem:

* [Plugins](/en/plugins) - Hướng dẫn phát triển plugin đầy đủ
* [Plugins reference](/en/plugins-reference) - Đặc tả kỹ thuật và schema

## Các trường hợp sử dụng phổ biến

### Phát triển và kiểm thử

Tải plugin trong quá trình phát triển mà không cần cài đặt chúng ở phạm vi toàn cục:

```typescript theme={null}
plugins: [{ type: "local", path: "./dev-plugins/my-plugin" }];
```

### Các phần mở rộng dành riêng cho dự án

Đưa plugin vào kho lưu trữ dự án của bạn để đảm bảo tính nhất quán trong toàn nhóm:

```typescript theme={null}
plugins: [{ type: "local", path: "./project-plugins/team-workflows" }];
```

### Nhiều nguồn plugin

Kết hợp plugin từ nhiều vị trí khác nhau:

```typescript theme={null}
plugins: [
  { type: "local", path: "./local-plugin" },
  { type: "local", path: "~/.claude/custom-plugins/shared-plugin" }
];
```

## Xử lý sự cố

### Plugin không tải được

Nếu plugin của bạn không xuất hiện trong thông điệp init:

1. **Kiểm tra đường dẫn**: đảm bảo đường dẫn trỏ tới thư mục gốc của plugin, thư mục cha của `skills/`, `agents/`, `hooks/`, `commands/` (legacy), hoặc `.claude-plugin/`
2. **Kiểm tra tính hợp lệ của plugin.json**: nếu plugin của bạn có manifest, đảm bảo cú pháp JSON hợp lệ
3. **Kiểm tra quyền tệp**: đảm bảo thư mục plugin có thể đọc được

### Skill không xuất hiện

Nếu skill của plugin không hoạt động:

1. **Sử dụng namespace**: gọi skill của plugin dưới dạng `/plugin-name:skill-name`
2. **Kiểm tra thông điệp init**: xác minh rằng skill xuất hiện trong danh sách `skills` với đúng namespace
3. **Kiểm tra tính hợp lệ của tệp skill**: đảm bảo mỗi skill có một tệp `SKILL.md` trong thư mục con riêng của nó dưới `skills/`, ví dụ `skills/my-skill/SKILL.md`

### Vấn đề phân giải đường dẫn

Nếu đường dẫn tương đối không hoạt động:

1. **Kiểm tra thư mục làm việc**: Đường dẫn tương đối được phân giải từ thư mục làm việc hiện tại của bạn
2. **Sử dụng đường dẫn tuyệt đối**: Để đảm bảo độ tin cậy, cân nhắc dùng đường dẫn tuyệt đối
3. **Chuẩn hóa đường dẫn**: Dùng các tiện ích đường dẫn để tạo đường dẫn chính xác

## Xem thêm

* [Plugins](/en/plugins) - Hướng dẫn phát triển plugin đầy đủ
* [Plugins reference](/en/plugins-reference) - Đặc tả kỹ thuật
* [Commands](/en/agent-sdk/slash-commands) - Sử dụng lệnh trong SDK
* [Subagents](/en/agent-sdk/subagents) - Làm việc với các agent chuyên biệt
* [Skills](/en/agent-sdk/skills) - Sử dụng Agent Skills
