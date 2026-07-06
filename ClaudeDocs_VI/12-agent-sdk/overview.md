> Nguồn: https://code.claude.com/docs/en/agent-sdk/overview.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tổng quan Agent SDK

> Xây dựng các AI agent sản xuất thực tế với Claude Code dưới dạng thư viện

Xây dựng các AI agent có khả năng tự động đọc file, chạy lệnh, tìm kiếm web, chỉnh sửa mã nguồn và nhiều hơn nữa. Agent SDK cung cấp cho bạn cùng bộ công cụ, agent loop (vòng lặp agent) và quản lý ngữ cảnh vốn vận hành Claude Code, có thể lập trình được bằng Python và TypeScript.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions


  async def main():
      async for message in query(
          prompt="Find and fix the bug in auth.py",
          options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
      ):
          print(message)  # Claude reads the file, finds the bug, edits it


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Find and fix the bug in auth.ts",
    options: { allowedTools: ["Read", "Edit", "Bash"] }
  })) {
    console.log(message); // Claude reads the file, finds the bug, edits it
  }
  ```
</CodeGroup>

Agent SDK đi kèm các công cụ dựng sẵn để đọc file, chạy lệnh và chỉnh sửa mã nguồn, nên agent của bạn có thể bắt đầu làm việc ngay lập tức mà không cần bạn tự triển khai việc thực thi công cụ. Hãy đi sâu vào phần quickstart hoặc khám phá các agent thực tế được xây dựng với SDK:

<CardGroup cols={2}>
  <Card title="Quickstart" icon="play" href="/en/agent-sdk/quickstart">
    Xây dựng một agent sửa lỗi trong vài phút
  </Card>

  <Card title="Agent ví dụ" icon="star" href="https://github.com/anthropics/claude-agent-sdk-demos">
    Trợ lý email, agent nghiên cứu, và nhiều hơn nữa
  </Card>
</CardGroup>

## Bắt đầu

<Steps>
  <Step title="Cài đặt SDK">
    <Tabs>
      <Tab title="TypeScript">
        ```bash theme={null}
        npm install @anthropic-ai/claude-agent-sdk
        ```
      </Tab>

      <Tab title="Python">
        ```bash theme={null}
        pip install claude-agent-sdk
        ```

        Gói Python yêu cầu Python 3.10 trở lên. Nếu pip báo `No matching distribution found for claude-agent-sdk`, trình thông dịch của bạn cũ hơn 3.10. Chạy `python3 --version` trên macOS hoặc Linux, hoặc `py --version` trên Windows để kiểm tra.
      </Tab>
    </Tabs>

    <Note>
      TypeScript SDK đóng gói sẵn một binary Claude Code gốc cho nền tảng của bạn dưới dạng phụ thuộc tùy chọn, nên bạn không cần cài đặt Claude Code riêng.
    </Note>
  </Step>

  <Step title="Thiết lập API key của bạn">
    Lấy API key từ [Console](https://platform.claude.com/), sau đó đặt nó làm biến môi trường:

    ```bash theme={null}
    export ANTHROPIC_API_KEY=your-api-key
    ```

    SDK cũng hỗ trợ xác thực qua các nhà cung cấp API bên thứ ba:

    * **Amazon Bedrock**: đặt biến môi trường `CLAUDE_CODE_USE_BEDROCK=1` và cấu hình thông tin đăng nhập AWS
    * **Claude Platform on AWS**: đặt `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` và `ANTHROPIC_AWS_WORKSPACE_ID`, sau đó cấu hình thông tin đăng nhập AWS
    * **Google Cloud's Agent Platform**: đặt biến môi trường `CLAUDE_CODE_USE_VERTEX=1` và cấu hình thông tin đăng nhập Google Cloud
    * **Microsoft Azure**: đặt biến môi trường `CLAUDE_CODE_USE_FOUNDRY=1` và cấu hình thông tin đăng nhập Azure

    Xem các hướng dẫn thiết lập cho [Amazon Bedrock](/en/amazon-bedrock), [Claude Platform on AWS](/en/claude-platform-on-aws), [Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [Microsoft Foundry](/en/microsoft-foundry) để biết chi tiết.

    <Note>
      Trừ khi được phê duyệt trước, Anthropic không cho phép các nhà phát triển bên thứ ba cung cấp đăng nhập claude.ai hoặc giới hạn tần suất (rate limit) cho sản phẩm của họ, bao gồm cả các agent được xây dựng trên Claude Agent SDK. Vui lòng sử dụng các phương thức xác thực bằng API key được mô tả trong tài liệu này thay thế.
    </Note>
  </Step>

  <Step title="Chạy agent đầu tiên của bạn">
    Ví dụ này tạo một agent liệt kê các file trong thư mục hiện tại của bạn bằng các công cụ dựng sẵn.

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions


      async def main():
          async for message in query(
              prompt="What files are in this directory?",
              options=ClaudeAgentOptions(allowed_tools=["Bash", "Glob"]),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      for await (const message of query({
        prompt: "What files are in this directory?",
        options: { allowedTools: ["Bash", "Glob"] }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>
  </Step>
</Steps>

**Sẵn sàng xây dựng?** Làm theo [Quickstart](/en/agent-sdk/quickstart) để tạo một agent tìm và sửa lỗi trong vài phút.

## Khả năng

Mọi thứ khiến Claude Code mạnh mẽ đều có sẵn trong SDK:

<Tabs>
  <Tab title="Công cụ dựng sẵn">
    Agent của bạn có thể đọc file, chạy lệnh và tìm kiếm codebase ngay từ đầu. Các công cụ chính bao gồm:

    | Công cụ                                                                      | Chức năng                                                            |
    | --------------------------------------------------------------------------- | ------------------------------------------------------------------- |
    | **Read**                                                                    | Đọc bất kỳ file nào trong thư mục làm việc                           |
    | **Write**                                                                   | Tạo file mới                                                         |
    | **Edit**                                                                    | Chỉnh sửa chính xác các file hiện có                                 |
    | **Bash**                                                                    | Chạy lệnh terminal, script, thao tác git                            |
    | **Monitor**                                                                 | Theo dõi một script chạy nền và phản ứng với mỗi dòng output như một sự kiện |
    | **Glob**                                                                    | Tìm file theo mẫu (`**/*.ts`, `src/**/*.py`)                        |
    | **Grep**                                                                    | Tìm kiếm nội dung file bằng regex                                    |
    | **WebSearch**                                                               | Tìm kiếm web để lấy thông tin cập nhật                               |
    | **WebFetch**                                                                | Tải về và phân tích nội dung trang web                              |
    | **[AskUserQuestion](/en/agent-sdk/user-input#handle-clarifying-questions)** | Hỏi người dùng các câu hỏi làm rõ với nhiều lựa chọn trắc nghiệm     |

    Ví dụ này tạo một agent tìm kiếm các comment TODO trong codebase của bạn:

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions


      async def main():
          async for message in query(
              prompt="Find all TODO comments and create a summary",
              options=ClaudeAgentOptions(allowed_tools=["Read", "Glob", "Grep"]),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      for await (const message of query({
        prompt: "Find all TODO comments and create a summary",
        options: { allowedTools: ["Read", "Glob", "Grep"] }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Hooks">
    Chạy mã tùy chỉnh tại các điểm quan trọng trong vòng đời của agent. Các hook trong SDK sử dụng hàm callback để xác thực, ghi log, chặn hoặc biến đổi hành vi của agent.

    **Các hook có sẵn:** `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, và nhiều hơn nữa.

    Ví dụ này ghi log tất cả thay đổi file vào một file kiểm toán (audit):

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from datetime import datetime
      from claude_agent_sdk import query, ClaudeAgentOptions, HookMatcher


      async def log_file_change(input_data, tool_use_id, context):
          file_path = input_data.get("tool_input", {}).get("file_path", "unknown")
          with open("./audit.log", "a") as f:
              f.write(f"{datetime.now()}: modified {file_path}\n")
          return {}


      async def main():
          async for message in query(
              prompt="Refactor utils.py to improve readability",
              options=ClaudeAgentOptions(
                  permission_mode="acceptEdits",
                  hooks={
                      "PostToolUse": [
                          HookMatcher(matcher="Edit|Write", hooks=[log_file_change])
                      ]
                  },
              ),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query, HookCallback } from "@anthropic-ai/claude-agent-sdk";
      import { appendFile } from "fs/promises";

      const logFileChange: HookCallback = async (input) => {
        const filePath = (input as any).tool_input?.file_path ?? "unknown";
        await appendFile("./audit.log", `${new Date().toISOString()}: modified ${filePath}\n`);
        return {};
      };

      for await (const message of query({
        prompt: "Refactor utils.py to improve readability",
        options: {
          permissionMode: "acceptEdits",
          hooks: {
            PostToolUse: [{ matcher: "Edit|Write", hooks: [logFileChange] }]
          }
        }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>

    [Tìm hiểu thêm về hooks →](/en/agent-sdk/hooks)
  </Tab>

  <Tab title="Subagents">
    Sinh ra các agent chuyên biệt để xử lý các tác vụ con tập trung. Agent chính của bạn giao việc, và các subagent báo cáo lại kết quả.

    Định nghĩa các agent tùy chỉnh với hướng dẫn chuyên biệt. Subagent được gọi qua công cụ Agent, vì vậy hãy đưa `Agent` vào `allowedTools` để tự động phê duyệt các lần gọi đó:

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition


      async def main():
          async for message in query(
              prompt="Use the code-reviewer agent to review this codebase",
              options=ClaudeAgentOptions(
                  allowed_tools=["Read", "Glob", "Grep", "Agent"],
                  agents={
                      "code-reviewer": AgentDefinition(
                          description="Expert code reviewer for quality and security reviews.",
                          prompt="Analyze code quality and suggest improvements.",
                          tools=["Read", "Glob", "Grep"],
                      )
                  },
              ),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      for await (const message of query({
        prompt: "Use the code-reviewer agent to review this codebase",
        options: {
          allowedTools: ["Read", "Glob", "Grep", "Agent"],
          agents: {
            "code-reviewer": {
              description: "Expert code reviewer for quality and security reviews.",
              prompt: "Analyze code quality and suggest improvements.",
              tools: ["Read", "Glob", "Grep"]
            }
          }
        }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>

    Các thông điệp (message) từ bên trong ngữ cảnh của một subagent bao gồm trường `parent_tool_use_id`, cho phép bạn theo dõi thông điệp nào thuộc về lần thực thi subagent nào.

    [Tìm hiểu thêm về subagents →](/en/agent-sdk/subagents)
  </Tab>

  <Tab title="MCP">
    Kết nối với các hệ thống bên ngoài qua Model Context Protocol: cơ sở dữ liệu, trình duyệt, API, và [hàng trăm hệ thống khác](https://github.com/modelcontextprotocol/servers).

    Ví dụ này kết nối [Playwright MCP server](https://github.com/microsoft/playwright-mcp) để cung cấp cho agent của bạn khả năng tự động hóa trình duyệt:

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions


      async def main():
          async for message in query(
              prompt="Open example.com and describe what you see",
              options=ClaudeAgentOptions(
                  mcp_servers={
                      "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
                  }
              ),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      for await (const message of query({
        prompt: "Open example.com and describe what you see",
        options: {
          mcpServers: {
            playwright: { command: "npx", args: ["@playwright/mcp@latest"] }
          }
        }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>

    [Tìm hiểu thêm về MCP →](/en/agent-sdk/mcp)
  </Tab>

  <Tab title="Permissions">
    Kiểm soát chính xác những công cụ nào agent của bạn có thể sử dụng. Cho phép các thao tác an toàn, chặn các thao tác nguy hiểm, hoặc yêu cầu phê duyệt cho các hành động nhạy cảm.

    <Note>
      Về các lời nhắc phê duyệt tương tác và công cụ `AskUserQuestion`, xem [Xử lý phê duyệt và đầu vào người dùng](/en/agent-sdk/user-input).
    </Note>

    Ví dụ này tạo một agent chỉ đọc, có thể phân tích nhưng không thể chỉnh sửa mã. `allowed_tools` phê duyệt trước `Read`, `Glob`, và `Grep`.

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions


      async def main():
          async for message in query(
              prompt="Review this code for best practices",
              options=ClaudeAgentOptions(
                  allowed_tools=["Read", "Glob", "Grep"],
              ),
          ):
              if hasattr(message, "result"):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      for await (const message of query({
        prompt: "Review this code for best practices",
        options: {
          allowedTools: ["Read", "Glob", "Grep"]
        }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>

    [Tìm hiểu thêm về permissions →](/en/agent-sdk/permissions)
  </Tab>

  <Tab title="Sessions">
    Duy trì ngữ cảnh qua nhiều lượt trao đổi. Claude ghi nhớ các file đã đọc, phân tích đã thực hiện và lịch sử hội thoại. Tiếp tục lại các phiên (session) sau đó, hoặc phân nhánh (fork) chúng để khám phá các hướng tiếp cận khác nhau.

    Ví dụ này lấy session ID từ truy vấn đầu tiên, sau đó tiếp tục lại để làm việc tiếp với đầy đủ ngữ cảnh:

    <CodeGroup>
      ```python Python theme={null}
      import asyncio
      from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage, ResultMessage


      async def main():
          session_id = None

          # First query: capture the session ID
          async for message in query(
              prompt="Read the authentication module",
              options=ClaudeAgentOptions(allowed_tools=["Read", "Glob"]),
          ):
              if isinstance(message, SystemMessage) and message.subtype == "init":
                  session_id = message.data["session_id"]

          # Resume with full context from the first query
          async for message in query(
              prompt="Now find all places that call it",  # "it" = auth module
              options=ClaudeAgentOptions(resume=session_id),
          ):
              if isinstance(message, ResultMessage):
                  print(message.result)


      asyncio.run(main())
      ```

      ```typescript TypeScript theme={null}
      import { query } from "@anthropic-ai/claude-agent-sdk";

      let sessionId: string | undefined;

      // First query: capture the session ID
      for await (const message of query({
        prompt: "Read the authentication module",
        options: { allowedTools: ["Read", "Glob"] }
      })) {
        if (message.type === "system" && message.subtype === "init") {
          sessionId = message.session_id;
        }
      }

      // Resume with full context from the first query
      for await (const message of query({
        prompt: "Now find all places that call it", // "it" = auth module
        options: { resume: sessionId }
      })) {
        if ("result" in message) console.log(message.result);
      }
      ```
    </CodeGroup>

    [Tìm hiểu thêm về sessions →](/en/agent-sdk/sessions)
  </Tab>
</Tabs>

### Các tính năng Claude Code

SDK cũng hỗ trợ cấu hình dựa trên hệ thống file của Claude Code. Với các tùy chọn mặc định, SDK tải các cấu hình này từ `.claude/` trong thư mục làm việc của bạn và `~/.claude/`. Để giới hạn nguồn nào được tải, hãy đặt `setting_sources` (Python) hoặc `settingSources` (TypeScript) trong các tùy chọn của bạn.

| Tính năng                                        | Mô tả                                                                          | Vị trí                             |
| ------------------------------------------------ | ----------------------------------------------------------------------------- | ---------------------------------- |
| [Skills](/en/agent-sdk/skills)                   | Các khả năng chuyên biệt mà Claude dùng tự động hoặc bạn gọi bằng `/name`      | `.claude/skills/*/SKILL.md`        |
| [Commands](/en/agent-sdk/slash-commands)         | Lệnh tùy chỉnh theo định dạng cũ. Dùng skill cho các lệnh tùy chỉnh mới        | `.claude/commands/*.md`            |
| [Memory](/en/agent-sdk/modifying-system-prompts) | Ngữ cảnh và hướng dẫn của dự án                                                | `CLAUDE.md` hoặc `.claude/CLAUDE.md` |
| [Plugins](/en/agent-sdk/plugins)                 | Mở rộng bằng skill, agent, hook, và MCP server                                | Lập trình qua tùy chọn `plugins`   |

## So sánh Agent SDK với các công cụ Claude khác

Claude Platform cung cấp nhiều cách để xây dựng với Claude. Đây là cách Agent SDK phù hợp:

<Tabs>
  <Tab title="Agent SDK so với Client SDK">
    [Anthropic Client SDK](https://platform.claude.com/docs/en/api/client-sdks) cung cấp cho bạn quyền truy cập API trực tiếp: bạn gửi prompt và tự triển khai việc thực thi công cụ. **Agent SDK** cung cấp cho bạn Claude với việc thực thi công cụ dựng sẵn.

    Với Client SDK, bạn triển khai một vòng lặp công cụ (tool loop). Với Agent SDK, Claude xử lý điều đó:

    <CodeGroup>
      ```python Python theme={null}
      # Client SDK: You implement the tool loop
      response = client.messages.create(...)
      while response.stop_reason == "tool_use":
          result = your_tool_executor(response.tool_use)
          response = client.messages.create(tool_result=result, **params)

      # Agent SDK: Claude handles tools autonomously
      async for message in query(prompt="Fix the bug in auth.py"):
          print(message)
      ```

      ```typescript TypeScript theme={null}
      // Client SDK: You implement the tool loop
      let response = await client.messages.create({ ...params });
      while (response.stop_reason === "tool_use") {
        const result = yourToolExecutor(response.tool_use);
        response = await client.messages.create({ tool_result: result, ...params });
      }

      // Agent SDK: Claude handles tools autonomously
      for await (const message of query({ prompt: "Fix the bug in auth.ts" })) {
        console.log(message);
      }
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Agent SDK so với Claude Code CLI">
    Cùng khả năng, khác giao diện:

    | Trường hợp sử dụng      | Lựa chọn tốt nhất |
    | ----------------------- | ----------- |
    | Phát triển tương tác    | CLI         |
    | Pipeline CI/CD          | SDK         |
    | Ứng dụng tùy chỉnh      | SDK         |
    | Tác vụ dùng một lần     | CLI         |
    | Tự động hóa sản xuất    | SDK         |

    Nhiều nhóm sử dụng cả hai: CLI cho phát triển hằng ngày, SDK cho sản xuất. Các luồng công việc chuyển đổi trực tiếp giữa chúng.
  </Tab>

  <Tab title="Agent SDK so với Managed Agents">
    [Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) là một REST API được lưu trữ (hosted): Anthropic chạy agent và sandbox, còn ứng dụng của bạn gửi sự kiện và nhận kết quả trả về theo luồng (stream). **Agent SDK** là một thư viện chạy agent loop bên trong tiến trình của chính bạn.

    |                    | Agent SDK                                                                    | Managed Agents                                                                                                |
    | ------------------ | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
    | **Chạy trong**     | Tiến trình của bạn, hạ tầng của bạn                                          | Hạ tầng do Anthropic quản lý                                                                                  |
    | **Giao diện**      | Thư viện Python hoặc TypeScript                                               | REST API                                                                                                      |
    | **Agent làm việc trên** | File trên hạ tầng của bạn                                               | Một sandbox được quản lý cho mỗi phiên                                                                        |
    | **Trạng thái phiên**  | JSONL trên hệ thống file của bạn                                          | Nhật ký sự kiện do Anthropic lưu trữ                                                                          |
    | **Công cụ tùy chỉnh** | Hàm Python hoặc TypeScript trong tiến trình                              | Claude kích hoạt công cụ; bạn thực thi và trả về kết quả                                                      |
    | **Phù hợp nhất cho** | Tạo mẫu cục bộ, các agent làm việc trực tiếp trên hệ thống file và dịch vụ của bạn | Các agent sản xuất mà không cần vận hành hạ tầng sandbox hoặc phiên, các phiên chạy dài và bất đồng bộ |

    Một hướng đi phổ biến là tạo mẫu (prototype) với Agent SDK cục bộ, sau đó chuyển sang Managed Agents cho sản xuất.
  </Tab>
</Tabs>

## Changelog

Xem toàn bộ changelog về các cập nhật SDK, sửa lỗi và tính năng mới:

* **TypeScript SDK**: [xem CHANGELOG.md](https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md)
* **Python SDK**: [xem CHANGELOG.md](https://github.com/anthropics/claude-agent-sdk-python/blob/main/CHANGELOG.md)

## Báo cáo lỗi

Nếu bạn gặp lỗi hoặc vấn đề với Agent SDK:

* **TypeScript SDK**: [báo cáo vấn đề trên GitHub](https://github.com/anthropics/claude-agent-sdk-typescript/issues)
* **Python SDK**: [báo cáo vấn đề trên GitHub](https://github.com/anthropics/claude-agent-sdk-python/issues)

## Hướng dẫn về thương hiệu

Đối với các đối tác tích hợp Claude Agent SDK, việc sử dụng thương hiệu Claude là tùy chọn. Khi tham chiếu đến Claude trong sản phẩm của bạn:

**Được phép:**

* "Claude Agent" (ưu tiên cho menu thả xuống)
* "Claude" (khi ở trong một menu đã được gán nhãn "Agents")
* "{YourAgentName} Powered by Claude" (nếu bạn đã có tên agent hiện có)

**Không được phép:**

* "Claude Code" hoặc "Claude Code Agent"
* ASCII art mang thương hiệu Claude Code hoặc các yếu tố hình ảnh mô phỏng Claude Code

Sản phẩm của bạn nên duy trì thương hiệu riêng và không được tỏ ra là Claude Code hoặc bất kỳ sản phẩm nào của Anthropic. Với các câu hỏi về việc tuân thủ thương hiệu, hãy liên hệ [đội ngũ bán hàng](https://www.anthropic.com/contact-sales) của Anthropic.

## Giấy phép và điều khoản

Việc sử dụng Claude Agent SDK được điều chỉnh bởi [Điều khoản Dịch vụ Thương mại của Anthropic](https://www.anthropic.com/legal/commercial-terms), bao gồm cả khi bạn sử dụng nó để vận hành các sản phẩm và dịch vụ mà bạn cung cấp cho khách hàng và người dùng cuối của riêng mình, ngoại trừ trong phạm vi mà một thành phần hoặc phụ thuộc cụ thể được điều chỉnh bởi một giấy phép khác như được chỉ ra trong file LICENSE của thành phần đó.

## Các bước tiếp theo

<CardGroup cols={2}>
  <Card title="Quickstart" icon="play" href="/en/agent-sdk/quickstart">
    Xây dựng một agent tìm và sửa lỗi trong vài phút
  </Card>

  <Card title="Agent ví dụ" icon="star" href="https://github.com/anthropics/claude-agent-sdk-demos">
    Trợ lý email, agent nghiên cứu, và nhiều hơn nữa
  </Card>

  <Card title="TypeScript SDK" icon="code" href="/en/agent-sdk/typescript">
    Tham chiếu API TypeScript đầy đủ và ví dụ
  </Card>

  <Card title="Python SDK" icon="code" href="/en/agent-sdk/python">
    Tham chiếu API Python đầy đủ và ví dụ
  </Card>
</CardGroup>
