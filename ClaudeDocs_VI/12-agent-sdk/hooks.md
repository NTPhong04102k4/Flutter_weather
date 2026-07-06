> Nguồn: https://code.claude.com/docs/en/agent-sdk/hooks.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Chặn và kiểm soát hành vi của agent bằng hook

> Chặn và tùy biến hành vi của agent tại các điểm thực thi quan trọng bằng hook

Hook là các hàm callback chạy code của bạn để phản hồi các sự kiện của agent, chẳng hạn khi một tool được gọi, một phiên bắt đầu, hay khi quá trình thực thi dừng lại. Với hook, bạn có thể:

* **Chặn các thao tác nguy hiểm** trước khi chúng thực thi, như các lệnh shell có tính phá hủy hoặc truy cập file trái phép
* **Ghi log và kiểm toán (audit)** mọi lời gọi tool phục vụ tuân thủ, gỡ lỗi hay phân tích
* **Biến đổi đầu vào và đầu ra** để làm sạch dữ liệu, chèn thông tin xác thực (credentials), hoặc chuyển hướng đường dẫn file
* **Yêu cầu phê duyệt của con người** cho các hành động nhạy cảm như ghi vào cơ sở dữ liệu hay gọi API
* **Theo dõi vòng đời phiên (session lifecycle)** để quản lý trạng thái, dọn dẹp tài nguyên, hoặc gửi thông báo

Hướng dẫn này bao gồm cách hook hoạt động và cách cấu hình chúng, kèm ví dụ cho các mẫu phổ biến như chặn tool, sửa đổi đầu vào, và chuyển tiếp thông báo.

## Cách hook hoạt động

<Steps>
  <Step title="Một sự kiện được kích hoạt">
    Điều gì đó xảy ra trong quá trình thực thi của agent và SDK kích hoạt một sự kiện: một tool sắp được gọi (`PreToolUse`), một tool trả về kết quả (`PostToolUse`), một subagent bắt đầu hoặc dừng, agent ở trạng thái rảnh (idle), hoặc quá trình thực thi kết thúc. Xem [danh sách đầy đủ các sự kiện](#available-hooks).
  </Step>

  <Step title="SDK thu thập các hook đã đăng ký">
    SDK kiểm tra các hook được đăng ký cho loại sự kiện đó. Điều này bao gồm các callback hook bạn truyền vào trong `options.hooks` và các shell command hook từ các file settings khi mục [`settingSources`](/en/agent-sdk/typescript#settingsource) hoặc [`setting_sources`](/en/agent-sdk/python#settingsource) tương ứng được bật, điều này đúng với các tùy chọn `query()` mặc định.
  </Step>

  <Step title="Matcher lọc những hook nào sẽ chạy">
    Nếu một hook có mẫu [`matcher`](#matchers) (như `"Write|Edit"`), SDK sẽ kiểm tra nó với đối tượng đích của sự kiện (ví dụ, tên tool). Các hook không có matcher sẽ chạy cho mọi sự kiện thuộc loại đó.
  </Step>

  <Step title="Các hàm callback thực thi">
    Mỗi hook khớp với matcher sẽ có [hàm callback](#callback-functions) nhận đầu vào về những gì đang xảy ra: tên tool, các đối số của nó, session ID, và các chi tiết khác đặc thù cho từng sự kiện.
  </Step>

  <Step title="Callback của bạn trả về một quyết định">
    Sau khi thực hiện bất kỳ thao tác nào (ghi log, gọi API, kiểm tra hợp lệ), callback của bạn trả về một [đối tượng đầu ra](#outputs) cho agent biết phải làm gì: cho phép thao tác, chặn nó, sửa đổi đầu vào, hoặc chèn ngữ cảnh vào cuộc hội thoại.
  </Step>
</Steps>

Ví dụ sau đây kết hợp các bước này lại với nhau. Nó đăng ký một hook `PreToolUse` (bước 1) với matcher `"Write|Edit"` (bước 3) sao cho callback chỉ kích hoạt cho các tool ghi file. Khi được kích hoạt, callback nhận đầu vào của tool (bước 4), kiểm tra xem đường dẫn file có nhắm tới file `.env` hay không, và trả về `permissionDecision: "deny"` để chặn thao tác (bước 5):

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import (
      AssistantMessage,
      ClaudeSDKClient,
      ClaudeAgentOptions,
      HookMatcher,
      ResultMessage,
  )


  # Define a hook callback that receives tool call details
  async def protect_env_files(input_data, tool_use_id, context):
      # Extract the file path from the tool's input arguments
      file_path = input_data["tool_input"].get("file_path", "")
      file_name = file_path.split("/")[-1]

      # Block the operation if targeting a .env file
      if file_name == ".env":
          return {
              "hookSpecificOutput": {
                  "hookEventName": input_data["hook_event_name"],
                  "permissionDecision": "deny",
                  "permissionDecisionReason": "Cannot modify .env files",
              }
          }

      # Return empty object to allow the operation
      return {}


  async def main():
      options = ClaudeAgentOptions(
          hooks={
              # Register the hook for PreToolUse events
              # The matcher filters to only Write and Edit tool calls
              "PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[protect_env_files])]
          }
      )

      async with ClaudeSDKClient(options=options) as client:
          await client.query("Update the database configuration")
          async for message in client.receive_response():
              # Filter for assistant and result messages
              if isinstance(message, (AssistantMessage, ResultMessage)):
                  print(message)


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query, HookCallback, PreToolUseHookInput } from "@anthropic-ai/claude-agent-sdk";

  // Define a hook callback with the HookCallback type
  const protectEnvFiles: HookCallback = async (input, toolUseID, { signal }) => {
    // Cast input to the specific hook type for type safety
    const preInput = input as PreToolUseHookInput;

    // Cast tool_input to access its properties (typed as unknown in the SDK)
    const toolInput = preInput.tool_input as Record<string, unknown>;
    const filePath = toolInput?.file_path as string;
    const fileName = filePath?.split("/").pop();

    // Block the operation if targeting a .env file
    if (fileName === ".env") {
      return {
        hookSpecificOutput: {
          hookEventName: preInput.hook_event_name,
          permissionDecision: "deny",
          permissionDecisionReason: "Cannot modify .env files"
        }
      };
    }

    // Return empty object to allow the operation
    return {};
  };

  for await (const message of query({
    prompt: "Update the database configuration",
    options: {
      hooks: {
        // Register the hook for PreToolUse events
        // The matcher filters to only Write and Edit tool calls
        PreToolUse: [{ matcher: "Write|Edit", hooks: [protectEnvFiles] }]
      }
    }
  })) {
    // Filter for assistant and result messages
    if (message.type === "assistant" || message.type === "result") {
      console.log(message);
    }
  }
  ```
</CodeGroup>

## Các hook có sẵn

SDK cung cấp các hook cho những giai đoạn khác nhau trong quá trình thực thi của agent. Một số hook có sẵn ở cả hai SDK, trong khi số khác chỉ có ở TypeScript.

| Sự kiện Hook         | Python SDK | TypeScript SDK | Yếu tố kích hoạt                                                                      | Ví dụ trường hợp sử dụng                                              |
| -------------------- | ---------- | -------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `PreToolUse`         | Có         | Có             | Yêu cầu gọi tool (có thể chặn hoặc sửa đổi)                                            | Chặn các lệnh shell nguy hiểm                                         |
| `PostToolUse`        | Có         | Có             | Kết quả thực thi tool                                                                  | Ghi log mọi thay đổi file vào audit trail                            |
| `PostToolUseFailure` | Có         | Có             | Thất bại khi thực thi tool                                                             | Xử lý hoặc ghi log lỗi tool                                          |
| `PostToolBatch`      | Không      | Có             | Một lô (batch) đầy đủ các lời gọi tool hoàn tất, một lần mỗi lô trước lời gọi model kế tiếp | Chèn quy ước một lần cho cả lô                                        |
| `UserPromptSubmit`   | Có         | Có             | Người dùng gửi prompt                                                                  | Chèn ngữ cảnh bổ sung vào prompt                                      |
| `MessageDisplay`     | Không      | Có             | Một thông điệp assistant có văn bản hoàn tất, một lần mỗi thông điệp với toàn bộ văn bản | Che (redact) hoặc định dạng lại văn bản hiển thị mà không thay đổi transcript |
| `Stop`               | Có         | Có             | Dừng thực thi agent                                                                    | Lưu trạng thái phiên trước khi thoát                                 |
| `SubagentStart`      | Có         | Có             | Khởi tạo subagent                                                                      | Theo dõi việc sinh (spawn) task song song                            |
| `SubagentStop`       | Có         | Có             | Subagent hoàn tất                                                                      | Tổng hợp kết quả từ các task song song                               |
| `PreCompact`         | Có         | Có             | Yêu cầu nén (compaction) cuộc hội thoại                                                | Lưu trữ transcript đầy đủ trước khi tóm tắt                          |
| `PermissionRequest`  | Có         | Có             | Hộp thoại xin quyền sắp được hiển thị                                                  | Xử lý quyền tùy chỉnh                                                |
| `SessionStart`       | Không      | Có             | Khởi tạo phiên                                                                         | Khởi tạo logging và telemetry                                        |
| `SessionEnd`         | Không      | Có             | Kết thúc phiên                                                                         | Dọn dẹp tài nguyên tạm thời                                          |
| `Notification`       | Có         | Có             | Các thông điệp trạng thái của agent                                                    | Gửi cập nhật trạng thái agent đến Slack hoặc PagerDuty               |
| `Setup`              | Không      | Có             | Thiết lập/bảo trì phiên                                                                | Chạy các tác vụ khởi tạo                                             |
| `TeammateIdle`       | Không      | Có             | Teammate trở nên rảnh (idle)                                                           | Phân công lại công việc hoặc thông báo                               |
| `TaskCompleted`      | Không      | Có             | Task chạy nền hoàn tất                                                                 | Tổng hợp kết quả từ các task song song                               |
| `ConfigChange`       | Không      | Có             | File cấu hình thay đổi                                                                 | Tải lại cài đặt một cách động                                        |
| `WorktreeCreate`     | Không      | Có             | Git worktree được tạo                                                                  | Theo dõi các không gian làm việc biệt lập                            |
| `WorktreeRemove`     | Không      | Có             | Git worktree bị xóa                                                                    | Dọn dẹp tài nguyên của không gian làm việc                           |

## Cấu hình hook

Để cấu hình một hook, truyền nó vào trường `hooks` của các tùy chọn agent (`ClaudeAgentOptions` trong Python, đối tượng `options` trong TypeScript):

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      hooks={"PreToolUse": [HookMatcher(matcher="Bash", hooks=[my_callback])]}
  )

  async with ClaudeSDKClient(options=options) as client:
      await client.query("Your prompt")
      async for message in client.receive_response():
          print(message)
  ```

  ```typescript TypeScript theme={null}
  for await (const message of query({
    prompt: "Your prompt",
    options: {
      hooks: {
        PreToolUse: [{ matcher: "Bash", hooks: [myCallback] }]
      }
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

Tùy chọn `hooks` là một dictionary trong Python hoặc một đối tượng trong TypeScript, trong đó:

* **Keys**: [tên sự kiện hook](#available-hooks) như `'PreToolUse'`, `'PostToolUse'`, và `'Stop'`
* **Values**: các mảng [matcher](#matchers), mỗi cái chứa một mẫu lọc tùy chọn và các [hàm callback](#callback-functions) của bạn

### Matcher

Dùng matcher để lọc thời điểm callback của bạn kích hoạt. Trường `matcher` khớp với một giá trị khác nhau tùy theo loại sự kiện hook. Ví dụ, các hook dựa trên tool khớp với tên tool, trong khi hook `Notification` khớp với loại thông báo. Xem [tài liệu tham khảo về hook của Claude Code](/en/hooks#matcher-patterns) để biết danh sách đầy đủ các giá trị matcher cho từng loại sự kiện.

Các matcher trong SDK tuân theo cùng quy tắc như [matcher trong file settings](/en/hooks#matcher-patterns). Một matcher chỉ chứa chữ cái, chữ số, `_`, `-`, khoảng trắng, `,`, và `|` sẽ được so sánh như một chuỗi chính xác, với các lựa chọn thay thế được phân tách bởi `|` hoặc `,` và khoảng trắng bao quanh tùy chọn, do đó `Write|Edit` và `Write, Edit` mỗi cái khớp chính xác hai tool đó và `code-reviewer` chỉ khớp với loại agent đó. Một matcher là `*`, một chuỗi rỗng, hoặc bỏ qua matcher hoàn toàn sẽ khớp với mọi lần xuất hiện của sự kiện.

Một matcher chứa bất kỳ ký tự nào khác sẽ được đánh giá như một biểu thức chính quy không neo (unanchored regular expression), do đó `^mcp__` khớp với mọi MCP tool và `Edit.*` khớp với cả `Edit` và `NotebookEdit`. Bao biểu thức chính quy trong `^` và `$` khi bạn cần khớp toàn chuỗi.

Một matcher như `mcp__memory` hoặc `mcp__brave-search` chỉ chứa các ký tự khớp chính xác, nên nó được so sánh như một chuỗi chính xác và không khớp với tool nào; hãy dùng `mcp__memory__.*` để khớp với mọi tool từ server đó.

Dấu gạch nối trong tập ký tự khớp chính xác yêu cầu runtime của Claude Code phiên bản v2.1.195 trở lên. Ở các phiên bản cũ hơn, một tên có dấu gạch nối như `code-reviewer` sẽ được đánh giá như một biểu thức chính quy không neo và phải được neo thành `^code-reviewer$` để khớp chính xác.

| Tùy chọn  | Kiểu             | Mặc định    | Mô tả                                                                                                                                                                                                                                                                                                                                                                              |
| --------- | ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `matcher` | `string`         | `undefined` | Mẫu được khớp với trường lọc của sự kiện, tuân theo các quy tắc so sánh ở trên. Đối với các hook tool, đây là tên tool. Các built-in tool bao gồm `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `WebFetch`, `Agent`, và các tool khác (xem [Tool Input Types](/en/agent-sdk/typescript#tool-input-types) để có danh sách đầy đủ). Các MCP tool dùng mẫu `mcp__<server>__<action>`. |
| `hooks`   | `HookCallback[]` | -           | Bắt buộc. Mảng các hàm callback để thực thi khi mẫu khớp                                                                                                                                                                                                                                                                                                                          |
| `timeout` | `number`         | `60`        | Thời gian chờ (timeout) tính bằng giây                                                                                                                                                                                                                                                                                                                                            |

Hãy dùng mẫu `matcher` để nhắm tới các tool cụ thể bất cứ khi nào có thể. Một matcher với `'Bash'` chỉ chạy cho các lệnh Bash, trong khi bỏ qua mẫu sẽ chạy các callback của bạn cho mọi lần xuất hiện của sự kiện.

Đối với các hook dựa trên tool, matcher chỉ lọc theo tên tool, chứ không theo đường dẫn file hay các đối số khác. Để lọc theo đường dẫn file, hãy kiểm tra `tool_input.file_path` bên trong callback của bạn.

<Tip>
  **Khám phá tên tool:** Xem [Tool Input Types](/en/agent-sdk/typescript#tool-input-types) để có danh sách đầy đủ tên các built-in tool, hoặc thêm một hook không có matcher để ghi log mọi lời gọi tool mà phiên của bạn thực hiện.

  **Cách đặt tên MCP tool:** Các MCP tool luôn bắt đầu bằng `mcp__` theo sau là tên server và hành động: `mcp__<server>__<action>`. Ví dụ, nếu bạn cấu hình một server tên `playwright`, các tool của nó sẽ có tên `mcp__playwright__browser_screenshot`, `mcp__playwright__browser_click`, v.v. Tên server đến từ key mà bạn dùng trong cấu hình `mcpServers`.
</Tip>

### Các hàm callback

#### Đầu vào (Inputs)

Mỗi hook callback nhận ba đối số:

* **Dữ liệu đầu vào:** một đối tượng có kiểu (typed object) chứa chi tiết sự kiện. Mỗi loại hook có hình dạng đầu vào riêng. Ví dụ, `PreToolUseHookInput` bao gồm `tool_name` và `tool_input`, trong khi `NotificationHookInput` bao gồm `message`. Xem định nghĩa kiểu đầy đủ trong tài liệu tham khảo SDK [TypeScript](/en/agent-sdk/typescript#hookinput) và [Python](/en/agent-sdk/python#hookinput).
  * Tất cả đầu vào hook đều chia sẻ `session_id`, `cwd`, và `hook_event_name`.
  * `agent_id` và `agent_type` được điền khi hook kích hoạt bên trong một subagent. Trong TypeScript, chúng nằm trên đầu vào hook cơ sở và có sẵn cho mọi loại hook. Trong Python, chúng chỉ nằm trên `PreToolUse`, `PostToolUse`, và `PostToolUseFailure`.
* **Tool use ID** (`str | None` / `string | undefined`): tương quan các sự kiện `PreToolUse` và `PostToolUse` cho cùng một lời gọi tool.
* **Context:** trong TypeScript, chứa một thuộc tính `signal` (`AbortSignal`) để hủy. Trong Python, đối số này được dành cho sử dụng trong tương lai.

#### Đầu ra (Outputs)

Callback của bạn trả về một đối tượng với hai loại trường:

* **Các trường cấp cao nhất (top-level fields)** hoạt động giống nhau ở mọi sự kiện: `systemMessage` hiển thị một thông điệp cho người dùng, và `continue` (`continue_` trong Python) quyết định liệu agent có tiếp tục chạy sau hook này hay không.
* **`hookSpecificOutput`** kiểm soát thao tác hiện tại. Các trường bên trong phụ thuộc vào loại sự kiện hook. Đối với hook `PreToolUse`, đây là nơi bạn thiết lập `permissionDecision` (`"allow"`, `"deny"`, `"ask"`, hoặc `"defer"`), `permissionDecisionReason`, và `updatedInput`. Trả về `"defer"` sẽ kết thúc query để bạn có thể [tiếp tục nó sau này](/en/hooks#defer-a-tool-call-for-later). Đối với hook `PostToolUse`, bạn có thể thiết lập `additionalContext` để nối thêm thông tin vào kết quả tool. Để thay thế đầu ra của tool trước khi Claude nhìn thấy nó, hãy thiết lập `updatedToolOutput`, cái này hoạt động cho bất kỳ tool nào ở cả hai SDK. Trường cũ hơn `updatedMCPToolOutput` chỉ thay thế đầu ra MCP tool và đã bị deprecated.

Trả về `{}` để cho phép thao tác mà không thay đổi gì. Các callback hook của SDK dùng cùng định dạng đầu ra JSON như [shell command hook của Claude Code](/en/hooks#json-output), tài liệu này ghi rõ mọi trường và tùy chọn đặc thù theo sự kiện. Về định nghĩa kiểu của SDK, xem tài liệu tham khảo SDK [TypeScript](/en/agent-sdk/typescript#synchookjsonoutput) và [Python](/en/agent-sdk/python#synchookjsonoutput).

<Note>
  Khi nhiều hook hoặc quy tắc quyền cùng áp dụng, `deny` được ưu tiên hơn `defer`, `defer` được ưu tiên hơn `ask`, `ask` được ưu tiên hơn `allow`. Nếu bất kỳ hook nào trả về `deny`, thao tác sẽ bị chặn bất kể các hook khác.
</Note>

#### Đầu ra bất đồng bộ (Asynchronous output)

Theo mặc định, agent đợi hook của bạn trả về trước khi tiếp tục. Nếu hook của bạn thực hiện một hiệu ứng phụ (side effect), chẳng hạn ghi log hoặc gửi webhook, và không cần ảnh hưởng đến hành vi của agent, bạn có thể trả về một đầu ra bất đồng bộ thay thế. Điều này báo cho agent tiếp tục ngay lập tức mà không đợi hook hoàn tất:

<CodeGroup>
  ```python Python theme={null}
  async def async_hook(input_data, tool_use_id, context):
      # Start a background task, then return immediately
      asyncio.create_task(send_to_logging_service(input_data))
      return {"async_": True, "asyncTimeout": 30000}
  ```

  ```typescript TypeScript theme={null}
  const asyncHook: HookCallback = async (input, toolUseID, { signal }) => {
    // Start a background task, then return immediately
    sendToLoggingService(input).catch(console.error);
    return { async: true, asyncTimeout: 30000 };
  };
  ```
</CodeGroup>

| Trường         | Kiểu     | Mô tả                                                                                                          |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------------- |
| `async`        | `true`   | Báo hiệu chế độ async. Agent tiếp tục mà không đợi. Trong Python, dùng `async_` để tránh từ khóa dành riêng.  |
| `asyncTimeout` | `number` | Thời gian chờ tùy chọn tính bằng mili giây cho thao tác chạy nền                                              |

<Note>
  Đầu ra async không thể chặn, sửa đổi, hoặc chèn ngữ cảnh vào thao tác vì agent đã tiếp tục. Chỉ dùng chúng cho các hiệu ứng phụ như ghi log, đo lường (metrics), hoặc thông báo.
</Note>

## Ví dụ

### Sửa đổi đầu vào của tool

Ví dụ này chặn các lời gọi tool Write và viết lại đối số `file_path` để thêm tiền tố `/sandbox`, chuyển hướng mọi thao tác ghi file đến một thư mục sandbox. Callback trả về `updatedInput` với đường dẫn đã sửa đổi và `permissionDecision: 'allow'` để tự động phê duyệt thao tác đã viết lại:

<CodeGroup>
  ```python Python theme={null}
  async def redirect_to_sandbox(input_data, tool_use_id, context):
      if input_data["hook_event_name"] != "PreToolUse":
          return {}

      if input_data["tool_name"] == "Write":
          original_path = input_data["tool_input"].get("file_path", "")
          return {
              "hookSpecificOutput": {
                  "hookEventName": input_data["hook_event_name"],
                  "permissionDecision": "allow",
                  "updatedInput": {
                      **input_data["tool_input"],
                      "file_path": f"/sandbox{original_path}",
                  },
              }
          }
      return {}
  ```

  ```typescript TypeScript theme={null}
  const redirectToSandbox: HookCallback = async (input, toolUseID, { signal }) => {
    if (input.hook_event_name !== "PreToolUse") return {};

    const preInput = input as PreToolUseHookInput;
    const toolInput = preInput.tool_input as Record<string, unknown>;
    if (preInput.tool_name === "Write") {
      const originalPath = toolInput.file_path as string;
      return {
        hookSpecificOutput: {
          hookEventName: preInput.hook_event_name,
          permissionDecision: "allow",
          updatedInput: {
            ...toolInput,
            file_path: `/sandbox${originalPath}`
          }
        }
      };
    }
    return {};
  };
  ```
</CodeGroup>

<Note>
  Khi dùng `updatedInput`, bạn cũng phải bao gồm `permissionDecision: 'allow'` để tự động phê duyệt đầu vào đã sửa đổi hoặc `permissionDecision: 'ask'` để hiển thị nó cho người dùng. Với `'defer'`, `updatedInput` sẽ bị bỏ qua. Luôn trả về một đối tượng mới thay vì làm biến đổi `tool_input` gốc.
</Note>

### Thêm ngữ cảnh và chặn một tool

Ví dụ này chặn các thao tác ghi vào thư mục `/etc` và giải thích lý do cho cả model lẫn người dùng:

* `permissionDecision: 'deny'` dừng lời gọi tool.
* `permissionDecisionReason` cho model biết lý do, để nó không thử lại.
* `systemMessage` hiển thị cho người dùng biết điều gì đã xảy ra.

<CodeGroup>
  ```python Python theme={null}
  async def block_etc_writes(input_data, tool_use_id, context):
      file_path = input_data["tool_input"].get("file_path", "")

      if file_path.startswith("/etc"):
          return {
              # Top-level field: message shown to the user
              "systemMessage": "Remember: system directories like /etc are protected.",
              # hookSpecificOutput: block the operation
              "hookSpecificOutput": {
                  "hookEventName": input_data["hook_event_name"],
                  "permissionDecision": "deny",
                  "permissionDecisionReason": "Writing to /etc is not allowed",
              },
          }
      return {}
  ```

  ```typescript TypeScript theme={null}
  const blockEtcWrites: HookCallback = async (input, toolUseID, { signal }) => {
    const preInput = input as PreToolUseHookInput;
    const toolInput = preInput.tool_input as Record<string, unknown>;
    const filePath = toolInput?.file_path as string;

    if (filePath?.startsWith("/etc")) {
      return {
        // Top-level field: message shown to the user
        systemMessage: "Remember: system directories like /etc are protected.",
        // hookSpecificOutput: block the operation
        hookSpecificOutput: {
          hookEventName: preInput.hook_event_name,
          permissionDecision: "deny",
          permissionDecisionReason: "Writing to /etc is not allowed"
        }
      };
    }
    return {};
  };
  ```
</CodeGroup>

### Tự động phê duyệt các tool cụ thể

Theo mặc định, agent có thể hỏi xin quyền trước khi dùng một số tool nhất định. Ví dụ này tự động phê duyệt các tool hệ thống file chỉ đọc (Read, Glob, Grep) bằng cách trả về `permissionDecision: 'allow'`, cho phép chúng chạy mà không cần xác nhận của người dùng trong khi vẫn để tất cả các tool khác chịu các kiểm tra quyền bình thường:

<CodeGroup>
  ```python Python theme={null}
  async def auto_approve_read_only(input_data, tool_use_id, context):
      if input_data["hook_event_name"] != "PreToolUse":
          return {}

      read_only_tools = ["Read", "Glob", "Grep"]
      if input_data["tool_name"] in read_only_tools:
          return {
              "hookSpecificOutput": {
                  "hookEventName": input_data["hook_event_name"],
                  "permissionDecision": "allow",
                  "permissionDecisionReason": "Read-only tool auto-approved",
              }
          }
      return {}
  ```

  ```typescript TypeScript theme={null}
  const autoApproveReadOnly: HookCallback = async (input, toolUseID, { signal }) => {
    if (input.hook_event_name !== "PreToolUse") return {};

    const preInput = input as PreToolUseHookInput;
    const readOnlyTools = ["Read", "Glob", "Grep"];
    if (readOnlyTools.includes(preInput.tool_name)) {
      return {
        hookSpecificOutput: {
          hookEventName: preInput.hook_event_name,
          permissionDecision: "allow",
          permissionDecisionReason: "Read-only tool auto-approved"
        }
      };
    }
    return {};
  };
  ```
</CodeGroup>

### Đăng ký nhiều hook

Khi một sự kiện được kích hoạt, tất cả các hook khớp sẽ chạy song song. Đối với các quyết định về quyền, kết quả hạn chế nhất sẽ được áp dụng: một `deny` duy nhất chặn lời gọi tool bất kể các hook khác trả về gì. Vì thứ tự hoàn tất là không xác định (non-deterministic), hãy viết mỗi hook để hành động độc lập thay vì dựa vào việc một hook khác đã chạy trước.

Ví dụ dưới đây đăng ký ba kiểm tra độc lập cho mọi lời gọi tool:

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      hooks={
          "PreToolUse": [
              HookMatcher(hooks=[authorization_check]),
              HookMatcher(hooks=[input_validator]),
              HookMatcher(hooks=[audit_logger]),
          ]
      }
  )
  ```

  ```typescript TypeScript theme={null}
  const options = {
    hooks: {
      PreToolUse: [
        { hooks: [authorizationCheck] },
        { hooks: [inputValidator] },
        { hooks: [auditLogger] }
      ]
    }
  };
  ```
</CodeGroup>

### Lọc bằng matcher nhiều tool

Dùng matcher nhiều tool để chia sẻ một callback qua các tool liên quan. Ví dụ này đăng ký ba matcher với phạm vi khác nhau:

* Một danh sách khớp chính xác phân tách bằng dấu gạch đứng (`Write|Edit|Delete`) kích hoạt `file_security_hook` chỉ cho các tool sửa đổi file.
* Một regex (`^mcp__`) kích hoạt `mcp_audit_hook` cho bất kỳ MCP tool nào có tên bắt đầu bằng `mcp__`.
* Một matcher bị bỏ qua kích hoạt `global_logger` cho mọi lời gọi tool bất kể tên.

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      hooks={
          "PreToolUse": [
              # Match file modification tools
              HookMatcher(matcher="Write|Edit|Delete", hooks=[file_security_hook]),
              # Match all MCP tools
              HookMatcher(matcher="^mcp__", hooks=[mcp_audit_hook]),
              # Match everything (no matcher)
              HookMatcher(hooks=[global_logger]),
          ]
      }
  )
  ```

  ```typescript TypeScript theme={null}
  const options = {
    hooks: {
      PreToolUse: [
        // Match file modification tools
        { matcher: "Write|Edit|Delete", hooks: [fileSecurityHook] },

        // Match all MCP tools
        { matcher: "^mcp__", hooks: [mcpAuditHook] },

        // Match everything (no matcher)
        { hooks: [globalLogger] }
      ]
    }
  };
  ```
</CodeGroup>

### Theo dõi hoạt động của subagent

Dùng hook `SubagentStop` để giám sát khi các subagent hoàn tất công việc của chúng. Xem kiểu đầu vào đầy đủ trong tài liệu tham khảo SDK [TypeScript](/en/agent-sdk/typescript#hookinput) và [Python](/en/agent-sdk/python#hookinput). Ví dụ này ghi log một bản tóm tắt mỗi khi một subagent hoàn tất:

<CodeGroup>
  ```python Python theme={null}
  async def subagent_tracker(input_data, tool_use_id, context):
      # Log subagent details when it finishes
      print(f"[SUBAGENT] Completed: {input_data['agent_id']}")
      print(f"  Transcript: {input_data['agent_transcript_path']}")
      print(f"  Tool use ID: {tool_use_id}")
      print(f"  Stop hook active: {input_data.get('stop_hook_active')}")
      return {}


  options = ClaudeAgentOptions(
      hooks={"SubagentStop": [HookMatcher(hooks=[subagent_tracker])]}
  )
  ```

  ```typescript TypeScript theme={null}
  import { HookCallback, SubagentStopHookInput } from "@anthropic-ai/claude-agent-sdk";

  const subagentTracker: HookCallback = async (input, toolUseID, { signal }) => {
    // Cast to SubagentStopHookInput to access subagent-specific fields
    const subInput = input as SubagentStopHookInput;

    // Log subagent details when it finishes
    console.log(`[SUBAGENT] Completed: ${subInput.agent_id}`);
    console.log(`  Transcript: ${subInput.agent_transcript_path}`);
    console.log(`  Tool use ID: ${toolUseID}`);
    console.log(`  Stop hook active: ${subInput.stop_hook_active}`);
    return {};
  };

  const options = {
    hooks: {
      SubagentStop: [{ hooks: [subagentTracker] }]
    }
  };
  ```
</CodeGroup>

### Thực hiện các yêu cầu HTTP từ hook

Các hook có thể thực hiện các thao tác bất đồng bộ như yêu cầu HTTP. Hãy bắt lỗi bên trong hook của bạn thay vì để chúng lan truyền ra ngoài, vì một ngoại lệ (exception) không được xử lý có thể làm gián đoạn agent.

Ví dụ này gửi một webhook sau khi mỗi tool hoàn tất, ghi log tool nào đã chạy và khi nào. Hook bắt lỗi để một webhook thất bại không làm gián đoạn agent:

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  import json
  import urllib.request
  from datetime import datetime


  def _send_webhook(tool_name):
      """Synchronous helper that POSTs tool usage data to an external webhook."""
      data = json.dumps(
          {
              "tool": tool_name,
              "timestamp": datetime.now().isoformat(),
          }
      ).encode()
      req = urllib.request.Request(
          "https://api.example.com/webhook",
          data=data,
          headers={"Content-Type": "application/json"},
          method="POST",
      )
      urllib.request.urlopen(req)


  async def webhook_notifier(input_data, tool_use_id, context):
      # Only fire after a tool completes (PostToolUse), not before
      if input_data["hook_event_name"] != "PostToolUse":
          return {}

      try:
          # Run the blocking HTTP call in a thread to avoid blocking the event loop
          await asyncio.to_thread(_send_webhook, input_data["tool_name"])
      except Exception as e:
          # Log the error but don't raise. A failed webhook shouldn't stop the agent
          print(f"Webhook request failed: {e}")

      return {}
  ```

  ```typescript TypeScript theme={null}
  import { query, HookCallback, PostToolUseHookInput } from "@anthropic-ai/claude-agent-sdk";

  const webhookNotifier: HookCallback = async (input, toolUseID, { signal }) => {
    // Only fire after a tool completes (PostToolUse), not before
    if (input.hook_event_name !== "PostToolUse") return {};

    try {
      await fetch("https://api.example.com/webhook", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          tool: (input as PostToolUseHookInput).tool_name,
          timestamp: new Date().toISOString()
        }),
        // Pass signal so the request cancels if the hook times out
        signal
      });
    } catch (error) {
      // Handle cancellation separately from other errors
      if (error instanceof Error && error.name === "AbortError") {
        console.log("Webhook request cancelled");
      }
      // Don't re-throw. A failed webhook shouldn't stop the agent
    }

    return {};
  };

  // Register as a PostToolUse hook
  for await (const message of query({
    prompt: "Refactor the auth module",
    options: {
      hooks: {
        PostToolUse: [{ hooks: [webhookNotifier] }]
      }
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

### Chuyển tiếp thông báo đến Slack

Dùng hook `Notification` để nhận các thông báo hệ thống từ agent và chuyển tiếp chúng đến các dịch vụ bên ngoài. Thông báo được kích hoạt cho các loại sự kiện như:

* `permission_prompt` khi Claude cần quyền
* `idle_prompt` khi Claude đang đợi đầu vào
* `auth_success` khi xác thực hoàn tất
* `elicitation_dialog`, `elicitation_complete`, và `elicitation_response` cho các luồng gợi mở (elicitation) prompt của người dùng

Mỗi thông báo bao gồm một trường `message` với mô tả dễ đọc cho con người và tùy chọn một `title`.

Ví dụ này chuyển tiếp mọi thông báo đến một kênh Slack. Nó yêu cầu một [Slack incoming webhook URL](https://api.slack.com/messaging/webhooks), mà bạn tạo bằng cách thêm một app vào workspace Slack của mình và bật incoming webhooks:

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  import json
  import urllib.request

  from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher


  def _send_slack_notification(message):
      """Synchronous helper that sends a message to Slack via incoming webhook."""
      data = json.dumps({"text": f"Agent status: {message}"}).encode()
      req = urllib.request.Request(
          "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
          data=data,
          headers={"Content-Type": "application/json"},
          method="POST",
      )
      urllib.request.urlopen(req)


  async def notification_handler(input_data, tool_use_id, context):
      try:
          # Run the blocking HTTP call in a thread to avoid blocking the event loop
          await asyncio.to_thread(_send_slack_notification, input_data.get("message", ""))
      except Exception as e:
          print(f"Failed to send notification: {e}")

      # Return empty object. Notification hooks don't modify agent behavior
      return {}


  async def main():
      options = ClaudeAgentOptions(
          hooks={
              # Register the hook for Notification events (no matcher needed)
              "Notification": [HookMatcher(hooks=[notification_handler])],
          },
      )

      async with ClaudeSDKClient(options=options) as client:
          await client.query("Analyze this codebase")
          async for message in client.receive_response():
              print(message)


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query, HookCallback, NotificationHookInput } from "@anthropic-ai/claude-agent-sdk";

  // Define a hook callback that sends notifications to Slack
  const notificationHandler: HookCallback = async (input, toolUseID, { signal }) => {
    // Cast to NotificationHookInput to access the message field
    const notification = input as NotificationHookInput;

    try {
      // POST the notification message to a Slack incoming webhook
      await fetch("https://hooks.slack.com/services/YOUR/WEBHOOK/URL", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text: `Agent status: ${notification.message}`
        }),
        // Pass signal so the request cancels if the hook times out
        signal
      });
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") {
        console.log("Notification cancelled");
      } else {
        console.error("Failed to send notification:", error);
      }
    }

    // Return empty object. Notification hooks don't modify agent behavior
    return {};
  };

  // Register the hook for Notification events (no matcher needed)
  for await (const message of query({
    prompt: "Analyze this codebase",
    options: {
      hooks: {
        Notification: [{ hooks: [notificationHandler] }]
      }
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

## Khắc phục các vấn đề thường gặp

### Hook không kích hoạt

* Xác minh tên sự kiện hook đúng và phân biệt chữ hoa/thường (`PreToolUse`, không phải `preToolUse`)
* Kiểm tra rằng mẫu matcher của bạn khớp chính xác với tên tool
* Đảm bảo hook nằm dưới đúng loại sự kiện trong `options.hooks`
* Đối với các hook không phải tool có hỗ trợ matcher, như `Notification` và `SubagentStop`, matcher khớp với các trường khác nhau, và `Stop` bỏ qua matcher hoàn toàn (xem [mẫu matcher](/en/hooks#matcher-patterns))
* Các hook có thể không kích hoạt khi agent chạm ngưỡng [`max_turns`](/en/agent-sdk/python#claudeagentoptions) vì phiên kết thúc trước khi hook có thể thực thi

### Matcher không lọc như mong đợi

Matcher chỉ khớp với tên tool, không khớp đường dẫn file hay các đối số khác. Để lọc theo đường dẫn file, hãy kiểm tra `tool_input.file_path` bên trong hook của bạn:

```typescript theme={null}
const myHook: HookCallback = async (input, toolUseID, { signal }) => {
  const preInput = input as PreToolUseHookInput;
  const toolInput = preInput.tool_input as Record<string, unknown>;
  const filePath = toolInput?.file_path as string;
  if (!filePath?.endsWith(".md")) return {}; // Skip non-markdown files
  // Process markdown files...
  return {};
};
```

### Hook timeout

* Tăng giá trị `timeout` trong cấu hình `HookMatcher`
* Dùng `AbortSignal` từ đối số callback thứ ba để xử lý việc hủy một cách nhẹ nhàng trong TypeScript

### Tool bị chặn ngoài dự kiến

* Kiểm tra tất cả các hook `PreToolUse` xem có trả về `permissionDecision: 'deny'` không
* Thêm logging vào các hook của bạn để xem chúng đang trả về `permissionDecisionReason` gì
* Xác minh các mẫu matcher không quá rộng: một matcher rỗng khớp với mọi tool

### Đầu vào đã sửa đổi không được áp dụng

* Đảm bảo `updatedInput` nằm bên trong `hookSpecificOutput`, không phải ở cấp cao nhất:

  ```typescript theme={null}
  return {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      updatedInput: { command: "new command" }
    }
  };
  ```

* Trả về `permissionDecision: 'allow'` để tự động phê duyệt đầu vào đã sửa đổi, hoặc `'ask'` để hiển thị nó cho người dùng phê duyệt

* Bao gồm `hookEventName` trong `hookSpecificOutput` để xác định loại hook mà đầu ra dành cho

### Các hook phiên không có sẵn trong Python

`SessionStart` và `SessionEnd` có thể được đăng ký như các callback hook của SDK trong TypeScript, nhưng không có sẵn trong Python SDK vì kiểu `HookEvent` của nó bỏ qua chúng. Trong Python, chúng chỉ có sẵn dưới dạng [shell command hook](/en/hooks#hook-events) được định nghĩa trong các file settings như `.claude/settings.json`. Để tải các shell command hook từ ứng dụng SDK của bạn, hãy bao gồm setting source phù hợp bằng [`setting_sources`](/en/agent-sdk/python#settingsource) hoặc [`settingSources`](/en/agent-sdk/typescript#settingsource):

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      setting_sources=["project"],  # Loads .claude/settings.json including hooks
  )
  ```

  ```typescript TypeScript theme={null}
  const options = {
    settingSources: ["project"] // Loads .claude/settings.json including hooks
  };
  ```
</CodeGroup>

Để chạy logic khởi tạo dưới dạng một callback SDK của Python thay thế, hãy dùng thông điệp đầu tiên từ `client.receive_response()` làm điểm kích hoạt của bạn.

### Prompt xin quyền của subagent nhân lên

Khi sinh (spawn) nhiều subagent, mỗi cái có thể yêu cầu quyền một cách riêng biệt. Subagent không tự động kế thừa quyền của agent cha. Để tránh các prompt lặp lại, hãy dùng hook `PreToolUse` để tự động phê duyệt các tool cụ thể, hoặc cấu hình các quy tắc quyền áp dụng cho các phiên subagent.

### Vòng lặp hook đệ quy với subagent

Một hook `UserPromptSubmit` sinh ra subagent có thể tạo ra vòng lặp vô hạn nếu các subagent đó kích hoạt cùng hook. Để ngăn điều này:

* Kiểm tra một chỉ báo subagent trong đầu vào hook trước khi sinh
* Dùng một biến chia sẻ hoặc trạng thái phiên để theo dõi liệu bạn đã ở bên trong một subagent hay chưa
* Giới hạn phạm vi hook để chỉ chạy cho phiên agent cấp cao nhất

### systemMessage không xuất hiện trong đầu ra

Trường `systemMessage` hiển thị một thông điệp cho người dùng, không phải cho model. Theo mặc định, SDK không đưa đầu ra hook lên luồng thông điệp, nên thông điệp có thể không xuất hiện trừ khi bạn thiết lập `includeHookEvents` (`include_hook_events` trong Python). Để truyền ngữ cảnh cho model thay thế, hãy trả về [`additionalContext`](/en/hooks#add-context-for-claude).

Nếu bạn cần đưa các quyết định hook lên ứng dụng của mình một cách đáng tin cậy, hãy ghi log chúng riêng biệt hoặc dùng một kênh đầu ra chuyên dụng.

## Tài nguyên liên quan

* [Tài liệu tham khảo hook của Claude Code](/en/hooks): schema đầu vào/đầu ra JSON đầy đủ, tài liệu sự kiện, và mẫu matcher
* [Hướng dẫn hook của Claude Code](/en/hooks-guide): các ví dụ và hướng dẫn từng bước về shell command hook
* [Tài liệu tham khảo TypeScript SDK](/en/agent-sdk/typescript): các kiểu hook, định nghĩa đầu vào/đầu ra, và tùy chọn cấu hình
* [Tài liệu tham khảo Python SDK](/en/agent-sdk/python): các kiểu hook, định nghĩa đầu vào/đầu ra, và tùy chọn cấu hình
* [Permissions](/en/agent-sdk/permissions): kiểm soát những gì agent của bạn có thể làm
* [Custom tools](/en/agent-sdk/custom-tools): xây dựng các tool để mở rộng khả năng của agent
