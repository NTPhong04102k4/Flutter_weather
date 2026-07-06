> Nguồn: https://code.claude.com/docs/en/agent-sdk/quickstart.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Quickstart

> Bắt đầu với Agent SDK bằng Python hoặc TypeScript để xây dựng các AI agent làm việc tự động

Sử dụng Agent SDK để xây dựng một AI agent có khả năng đọc mã nguồn của bạn, tìm lỗi và sửa chúng, tất cả mà không cần can thiệp thủ công.

**Những gì bạn sẽ làm:**

1. Thiết lập một dự án với Agent SDK
2. Tạo một file với mã lỗi
3. Chạy một agent tự động tìm và sửa lỗi

## Điều kiện tiên quyết

* **Node.js 18+** hoặc **Python 3.10+**
* Một **tài khoản Anthropic** ([đăng ký tại đây](https://platform.claude.com/))

## Thiết lập

<Steps>
  <Step title="Tạo một thư mục dự án">
    Tạo một thư mục mới cho quickstart này:

    ```bash theme={null}
    mkdir my-agent
    cd my-agent
    ```

    Đối với các dự án của riêng bạn, bạn có thể chạy SDK từ bất kỳ thư mục nào; theo mặc định, nó sẽ có quyền truy cập vào các file trong thư mục đó và các thư mục con của nó.
  </Step>

  <Step title="Cài đặt SDK">
    Cài đặt gói Agent SDK cho ngôn ngữ của bạn:

    <Tabs>
      <Tab title="TypeScript (dự án mới)">
        ```bash theme={null}
        npm init -y
        npm pkg set type=module
        npm install @anthropic-ai/claude-agent-sdk
        npm install --save-dev tsx
        ```

        Việc đặt `"type": "module"` trong `package.json` cho phép script agent của bạn sử dụng `await` ở cấp cao nhất (top-level await), và [tsx](https://tsx.is) chạy các file TypeScript trực tiếp.
      </Tab>

      <Tab title="TypeScript (dự án hiện có)">
        ```bash theme={null}
        npm install @anthropic-ai/claude-agent-sdk
        npm install --save-dev tsx
        ```

        [tsx](https://tsx.is) chạy các file TypeScript trực tiếp. Nếu dự án của bạn dùng CommonJS, hãy đặt tên script agent là `agent.mts` thay vì `agent.ts`. Phần mở rộng `.mts` khiến tsx coi file như một ES module, nên top-level `await` hoạt động mà không cần chuyển đổi toàn bộ dự án sang ES module. Sử dụng `agent.mts` thay cho `agent.ts` trong các bước tạo và chạy ở phần sau của quickstart này.
      </Tab>

      <Tab title="Python (uv)">
        [uv](https://docs.astral.sh/uv/) là một trình quản lý gói Python nhanh, tự động xử lý môi trường ảo:

        ```bash theme={null}
        uv init
        uv add claude-agent-sdk
        ```
      </Tab>

      <Tab title="Python (pip)">
        Tạo và kích hoạt một môi trường ảo, sau đó cài đặt gói.

        Trên macOS hoặc Linux:

        ```bash theme={null}
        python3 -m venv .venv
        source .venv/bin/activate
        pip install claude-agent-sdk
        ```

        Trên Windows:

        ```powershell theme={null}
        py -m venv .venv
        .venv\Scripts\Activate.ps1
        pip install claude-agent-sdk
        ```

        Nếu PowerShell chặn `Activate.ps1` với lỗi execution policy, hãy chạy `Set-ExecutionPolicy -Scope Process RemoteSigned` trước.
      </Tab>
    </Tabs>

    <Note>
      TypeScript SDK đóng gói sẵn một binary Claude Code gốc cho nền tảng của bạn dưới dạng phụ thuộc tùy chọn, nên bạn không cần cài đặt Claude Code riêng.
    </Note>
  </Step>

  <Step title="Thiết lập API key của bạn">
    Lấy API key từ [Claude Console](https://platform.claude.com/), sau đó đặt nó làm biến môi trường trong shell nơi bạn sẽ chạy agent:

    <Tabs>
      <Tab title="macOS / Linux">
        ```bash theme={null}
        export ANTHROPIC_API_KEY=your-api-key
        ```
      </Tab>

      <Tab title="Windows (PowerShell)">
        ```powershell theme={null}
        $env:ANTHROPIC_API_KEY = "your-api-key"
        ```
      </Tab>
    </Tabs>

    SDK đọc key từ môi trường của tiến trình chạy agent của bạn; nó không tự động tải các file `.env`. Nếu bạn giữ key trong file `.env`, hãy tự tải nó, ví dụ với gói `dotenv`, trước khi gọi SDK.

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
</Steps>

## Tạo một file có lỗi

Quickstart này hướng dẫn bạn xây dựng một agent có thể tìm và sửa lỗi trong mã nguồn. Trước tiên, bạn cần một file với một số lỗi cố ý để agent sửa. Tạo `utils.py` trong thư mục `my-agent` và dán đoạn mã sau:

```python theme={null}
def calculate_average(numbers):
    total = 0
    for num in numbers:
        total += num
    return total / len(numbers)


def get_user_name(user):
    return user["name"].upper()
```

Đoạn mã này có hai lỗi:

1. `calculate_average([])` bị lỗi chia cho không (division by zero)
2. `get_user_name(None)` bị lỗi với một TypeError

## Xây dựng một agent tìm và sửa lỗi

Tạo `agent.py` nếu bạn dùng Python SDK, hoặc `agent.ts` cho TypeScript. Dùng `agent.mts` thay thế nếu dự án hiện có của bạn dùng CommonJS:

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, ResultMessage


  async def main():
      # Agentic loop: streams messages as Claude works
      async for message in query(
          prompt="Review utils.py for bugs that would cause crashes. Fix any issues you find.",
          options=ClaudeAgentOptions(
              allowed_tools=["Read", "Edit", "Glob"],  # Auto-approve these tools
              permission_mode="acceptEdits",  # Auto-approve file edits
          ),
      ):
          # Print human-readable output
          if isinstance(message, AssistantMessage):
              for block in message.content:
                  if hasattr(block, "text"):
                      print(block.text)  # Claude's reasoning
                  elif hasattr(block, "name"):
                      print(f"Tool: {block.name}")  # Tool being called
          elif isinstance(message, ResultMessage):
              print(f"Done: {message.subtype}")  # Final result


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Agentic loop: streams messages as Claude works
  for await (const message of query({
    prompt: "Review utils.py for bugs that would cause crashes. Fix any issues you find.",
    options: {
      allowedTools: ["Read", "Edit", "Glob"], // Auto-approve these tools
      permissionMode: "acceptEdits" // Auto-approve file edits
    }
  })) {
    // Print human-readable output
    if (message.type === "assistant" && message.message?.content) {
      for (const block of message.message.content) {
        if ("text" in block) {
          console.log(block.text); // Claude's reasoning
        } else if ("name" in block) {
          console.log(`Tool: ${block.name}`); // Tool being called
        }
      }
    } else if (message.type === "result") {
      console.log(`Done: ${message.subtype}`); // Final result
    }
  }
  ```
</CodeGroup>

Đoạn mã này có ba phần chính:

1. **`query`**: điểm vào chính tạo ra agentic loop (vòng lặp agent). Nó trả về một async iterator, nên bạn dùng `async for` để nhận luồng thông điệp khi Claude làm việc. Xem đầy đủ API trong tham chiếu SDK [Python](/en/agent-sdk/python#query) hoặc [TypeScript](/en/agent-sdk/typescript#query).

2. **`prompt`**: những gì bạn muốn Claude làm. Claude tự tìm ra công cụ nào cần dùng dựa trên tác vụ.

3. **`options`**: cấu hình cho agent. Ví dụ này dùng `allowedTools` để phê duyệt trước `Read`, `Edit`, và `Glob`, cùng với `permissionMode: "acceptEdits"` để tự động phê duyệt các thay đổi file. Các tùy chọn khác bao gồm `systemPrompt`, `mcpServers`, và nhiều hơn nữa. Xem tất cả tùy chọn cho [Python](/en/agent-sdk/python#claudeagentoptions) hoặc [TypeScript](/en/agent-sdk/typescript#options).

Vòng lặp `async for` tiếp tục chạy khi Claude suy nghĩ, gọi công cụ, quan sát kết quả và quyết định làm gì tiếp theo. Mỗi lần lặp sinh ra một thông điệp: lập luận của Claude, một lần gọi công cụ, một kết quả công cụ, hoặc kết quả cuối cùng. SDK xử lý việc điều phối (thực thi công cụ, quản lý ngữ cảnh, thử lại) nên bạn chỉ cần tiêu thụ luồng dữ liệu. Vòng lặp kết thúc khi Claude hoàn thành tác vụ hoặc gặp lỗi.

Việc xử lý thông điệp bên trong vòng lặp lọc lấy output dễ đọc cho con người. Không có bộ lọc, bạn sẽ thấy các đối tượng thông điệp thô bao gồm khởi tạo hệ thống và trạng thái nội bộ, hữu ích cho việc gỡ lỗi nhưng gây nhiễu trong các trường hợp khác.

<Note>
  Ví dụ này dùng streaming để hiển thị tiến trình theo thời gian thực. Nếu bạn không cần output trực tiếp (ví dụ: cho các tác vụ chạy nền hoặc pipeline CI), bạn có thể thu thập tất cả thông điệp cùng lúc. Xem [Chế độ streaming so với single-turn](/en/agent-sdk/streaming-vs-single-mode) để biết chi tiết.
</Note>

### Chạy agent của bạn

Agent của bạn đã sẵn sàng. Chạy nó với lệnh sau:

<Tabs>
  <Tab title="TypeScript">
    ```bash theme={null}
    npx tsx agent.ts
    ```

    Nếu bạn đặt tên script là `agent.mts`, hãy chạy `npx tsx agent.mts` thay thế.
  </Tab>

  <Tab title="Python (uv)">
    ```bash theme={null}
    uv run agent.py
    ```
  </Tab>

  <Tab title="Python (pip)">
    Với môi trường ảo của bạn vẫn đang được kích hoạt:

    ```bash theme={null}
    python agent.py
    ```
  </Tab>
</Tabs>

Khi làm việc, agent in ra lập luận của nó và từng công cụ mà nó gọi, kết thúc bằng `Done: success`. Sau khi chạy, hãy kiểm tra `utils.py`. Bạn sẽ thấy mã phòng vệ (defensive code) xử lý các danh sách rỗng và người dùng null. Agent của bạn đã tự động:

1. **Read** `utils.py` để hiểu đoạn mã
2. **Phân tích** logic và xác định các trường hợp biên (edge case) sẽ gây lỗi
3. **Edit** file để thêm xử lý lỗi phù hợp

Đây chính là điều làm cho Agent SDK khác biệt: Claude thực thi công cụ trực tiếp thay vì yêu cầu bạn tự triển khai chúng.

<Note>
  Nếu bạn thấy "API key not found", hãy đảm bảo bạn đã đặt biến môi trường `ANTHROPIC_API_KEY` trong shell nơi bạn chạy agent. SDK không tự động tải các file `.env`. Xem [hướng dẫn khắc phục sự cố đầy đủ](/en/troubleshooting) để được trợ giúp thêm.
</Note>

### Thử các prompt khác

Bây giờ agent của bạn đã được thiết lập, hãy thử một số prompt khác nhau:

* `"Add docstrings to all functions in utils.py"`
* `"Add type hints to all functions in utils.py"`
* `"Create a README.md documenting the functions in utils.py"`

### Tùy chỉnh agent của bạn

Bạn có thể sửa đổi hành vi của agent bằng cách thay đổi các tùy chọn. Dưới đây là một vài ví dụ:

**Thêm khả năng tìm kiếm web:**

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      allowed_tools=["Read", "Edit", "Glob", "WebSearch"], permission_mode="acceptEdits"
  )
  ```

  ```typescript TypeScript hidelines={1,-1} theme={null}
  const _ = {
    options: {
      allowedTools: ["Read", "Edit", "Glob", "WebSearch"],
      permissionMode: "acceptEdits"
    }
  };
  ```
</CodeGroup>

**Cung cấp cho Claude một system prompt tùy chỉnh:**

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      allowed_tools=["Read", "Edit", "Glob"],
      permission_mode="acceptEdits",
      system_prompt="You are a senior Python developer. Always follow PEP 8 style guidelines.",
  )
  ```

  ```typescript TypeScript hidelines={1,-1} theme={null}
  const _ = {
    options: {
      allowedTools: ["Read", "Edit", "Glob"],
      permissionMode: "acceptEdits",
      systemPrompt: "You are a senior Python developer. Always follow PEP 8 style guidelines."
    }
  };
  ```
</CodeGroup>

**Chạy lệnh trong terminal:**

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      allowed_tools=["Read", "Edit", "Glob", "Bash"], permission_mode="acceptEdits"
  )
  ```

  ```typescript TypeScript hidelines={1,-1} theme={null}
  const _ = {
    options: {
      allowedTools: ["Read", "Edit", "Glob", "Bash"],
      permissionMode: "acceptEdits"
    }
  };
  ```
</CodeGroup>

Với `Bash` được bật, hãy thử: `"Write unit tests for utils.py, run them, and fix any failures"`

## Các khái niệm cốt lõi

**Công cụ (Tools)** kiểm soát những gì agent của bạn có thể làm:

| Công cụ                                | Agent có thể làm gì     |
| -------------------------------------- | ----------------------- |
| `Read`, `Glob`, `Grep`                 | Phân tích chỉ đọc        |
| `Read`, `Edit`, `Glob`                 | Phân tích và sửa đổi mã   |
| `Read`, `Edit`, `Bash`, `Glob`, `Grep` | Tự động hóa hoàn toàn    |

**Permission mode (chế độ quyền)** kiểm soát mức độ giám sát của con người mà bạn muốn:

| Chế độ                   | Hành vi                                                                                                                            | Trường hợp sử dụng                        |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `acceptEdits`            | Tự động phê duyệt các chỉnh sửa file và các lệnh hệ thống file thông thường, hỏi các hành động khác                                  | Luồng công việc phát triển đáng tin cậy   |
| `plan`                   | Chạy các công cụ chỉ đọc; chỉnh sửa file không bao giờ được tự động phê duyệt mà chuyển đến callback `canUseTool` của bạn           | Xác định phạm vi tác vụ trước khi phê duyệt thực thi |
| `dontAsk`                | Từ chối mọi thứ không có trong `allowedTools`                                                                                       | Các agent headless bị khóa chặt           |
| `auto` (chỉ TypeScript)  | Một bộ phân loại của model phê duyệt hoặc từ chối từng lần gọi công cụ                                                               | Các agent tự động với rào chắn an toàn     |
| `bypassPermissions`      | Chạy mọi công cụ mà không hỏi, trừ khi có một [quy tắc `ask`](/en/agent-sdk/permissions#how-permissions-are-evaluated) khớp rõ ràng | CI trong sandbox, môi trường hoàn toàn tin cậy |
| `default`                | Yêu cầu một callback `canUseTool` để xử lý việc phê duyệt                                                                            | Các luồng phê duyệt tùy chỉnh             |

Ví dụ trên dùng chế độ `acceptEdits`, tự động phê duyệt các thao tác file để agent có thể chạy mà không có lời nhắc tương tác. Nếu bạn muốn nhắc người dùng phê duyệt, hãy dùng chế độ `default` và cung cấp một [callback `canUseTool`](/en/agent-sdk/user-input) để thu thập đầu vào của người dùng. Để kiểm soát nhiều hơn, xem [Permissions](/en/agent-sdk/permissions).

## Các bước tiếp theo

Bây giờ bạn đã tạo agent đầu tiên của mình, hãy tìm hiểu cách mở rộng khả năng của nó và điều chỉnh cho phù hợp với trường hợp sử dụng của bạn:

* **[Permissions](/en/agent-sdk/permissions)**: kiểm soát những gì agent của bạn có thể làm và khi nào cần phê duyệt
* **[Hooks](/en/agent-sdk/hooks)**: chạy mã tùy chỉnh trước hoặc sau các lần gọi công cụ
* **[Sessions](/en/agent-sdk/sessions)**: xây dựng các agent đa lượt (multi-turn) duy trì ngữ cảnh
* **[MCP servers](/en/agent-sdk/mcp)**: kết nối với cơ sở dữ liệu, trình duyệt, API và các hệ thống bên ngoài khác
* **[Hosting](/en/agent-sdk/hosting)**: triển khai agent lên Docker, cloud, và CI/CD
* **[Agent ví dụ](https://github.com/anthropics/claude-agent-sdk-demos)**: xem các ví dụ hoàn chỉnh: trợ lý email, agent nghiên cứu, và nhiều hơn nữa
