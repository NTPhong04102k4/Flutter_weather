> Nguồn: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Stream phản hồi theo thời gian thực

> Nhận phản hồi theo thời gian thực từ Agent SDK khi văn bản và các lệnh gọi tool được stream về

Theo mặc định, Agent SDK trả về các đối tượng `AssistantMessage` hoàn chỉnh sau khi Claude hoàn tất việc tạo mỗi phản hồi. Để nhận các cập nhật tăng dần (incremental) khi văn bản và các lệnh gọi tool được sinh ra, hãy bật chế độ stream tin nhắn từng phần (partial message streaming) bằng cách đặt `include_partial_messages` (Python) hoặc `includePartialMessages` (TypeScript) thành `true` trong options của bạn.

<Tip>
  Trang này đề cập đến việc stream đầu ra (nhận token theo thời gian thực). Về các chế độ đầu vào (cách bạn gửi tin nhắn), xem [Gửi tin nhắn đến agent](/en/agent-sdk/streaming-vs-single-mode). Bạn cũng có thể [stream phản hồi bằng Agent SDK thông qua CLI](/en/headless).
</Tip>

## Bật stream đầu ra

Để bật stream, hãy đặt `include_partial_messages` (Python) hoặc `includePartialMessages` (TypeScript) thành `true` trong options của bạn. Điều này khiến SDK trả về các tin nhắn `StreamEvent` chứa các sự kiện API thô ngay khi chúng đến, bên cạnh các `AssistantMessage` và `ResultMessage` thông thường.

Khi đó, code của bạn cần:

1. Kiểm tra kiểu (type) của mỗi tin nhắn để phân biệt `StreamEvent` với các kiểu tin nhắn khác
2. Với `StreamEvent`, trích xuất trường `event` và kiểm tra `type` của nó
3. Tìm các sự kiện `content_block_delta` mà `delta.type` là `text_delta`, chứa những đoạn văn bản thực tế

Ví dụ dưới đây bật stream và in các đoạn văn bản ngay khi chúng đến. Lưu ý các bước kiểm tra kiểu lồng nhau: trước tiên với `StreamEvent`, rồi đến `content_block_delta`, rồi đến `text_delta`:

<CodeGroup>
  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions
  from claude_agent_sdk.types import StreamEvent
  import asyncio


  async def stream_response():
      options = ClaudeAgentOptions(
          include_partial_messages=True,
          allowed_tools=["Bash", "Read"],
      )

      async for message in query(prompt="List the files in my project", options=options):
          if isinstance(message, StreamEvent):
              event = message.event
              if event.get("type") == "content_block_delta":
                  delta = event.get("delta", {})
                  if delta.get("type") == "text_delta":
                      print(delta.get("text", ""), end="", flush=True)


  asyncio.run(stream_response())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "List the files in my project",
    options: {
      includePartialMessages: true,
      allowedTools: ["Bash", "Read"]
    }
  })) {
    if (message.type === "stream_event") {
      const event = message.event;
      if (event.type === "content_block_delta") {
        if (event.delta.type === "text_delta") {
          process.stdout.write(event.delta.text);
        }
      }
    }
  }
  ```
</CodeGroup>

## Tham chiếu StreamEvent

Khi bật tin nhắn từng phần, bạn nhận được các sự kiện stream thô của Claude API được đóng gói trong một đối tượng. Kiểu này có tên khác nhau trong mỗi SDK:

* **Python**: `StreamEvent` (import từ `claude_agent_sdk.types`)
* **TypeScript**: `SDKPartialAssistantMessage` với `type: 'stream_event'`

Cả hai đều chứa các sự kiện Claude API thô, không phải văn bản đã tích lũy. Bạn cần tự trích xuất và tích lũy các delta văn bản. Dưới đây là cấu trúc của mỗi kiểu:

<CodeGroup>
  ```python Python theme={null}
  @dataclass
  class StreamEvent:
      uuid: str  # Unique identifier for this event
      session_id: str  # Session identifier
      event: dict[str, Any]  # The raw Claude API stream event
      parent_tool_use_id: str | None  # Always None
  ```

  ```typescript TypeScript theme={null}
  type SDKPartialAssistantMessage = {
    type: "stream_event";
    event: BetaRawMessageStreamEvent; // From Anthropic SDK
    parent_tool_use_id: string | null;
    uuid: UUID;
    session_id: string;
    ttft_ms?: number; // Time to first token in ms, present only on message_start events
  };
  ```
</CodeGroup>

Trường `parent_tool_use_id` luôn là `None` trong Python và `null` trong TypeScript. Các sự kiện stream chỉ được phát ra cho phiên (session) chính; các delta ở cấp độ token từ các subagent không được chuyển tiếp. Để gán đầu ra cho một subagent, hãy dùng các tin nhắn hoàn chỉnh, vốn mang theo `parent_tool_use_id`. Xem [Phát hiện việc gọi subagent](/en/agent-sdk/subagents#detect-subagent-invocation).

Trường `event` chứa sự kiện stream thô từ [Claude API](https://platform.claude.com/docs/en/build-with-claude/streaming#event-types). Các kiểu sự kiện phổ biến bao gồm:

| Kiểu sự kiện          | Mô tả                                              |
| :-------------------- | :------------------------------------------------ |
| `message_start`       | Bắt đầu một tin nhắn mới                           |
| `content_block_start` | Bắt đầu một khối nội dung mới (văn bản hoặc tool use) |
| `content_block_delta` | Cập nhật tăng dần cho nội dung                     |
| `content_block_stop`  | Kết thúc một khối nội dung                         |
| `message_delta`       | Cập nhật ở cấp tin nhắn (lý do dừng, usage)        |
| `message_stop`        | Kết thúc tin nhắn                                  |

## Luồng tin nhắn

Khi bật tin nhắn từng phần, bạn nhận được các tin nhắn theo thứ tự sau:

```text theme={null}
StreamEvent (message_start)
StreamEvent (content_block_start) - text block
StreamEvent (content_block_delta) - text chunks...
StreamEvent (content_block_stop)
StreamEvent (content_block_start) - tool_use block
StreamEvent (content_block_delta) - tool input chunks...
StreamEvent (content_block_stop)
StreamEvent (message_delta)
StreamEvent (message_stop)
AssistantMessage - complete message with all content
... tool executes ...
... more streaming events for next turn ...
ResultMessage - final result
```

Khi không bật tin nhắn từng phần (`include_partial_messages` trong Python, `includePartialMessages` trong TypeScript), bạn nhận được tất cả các kiểu tin nhắn ngoại trừ `StreamEvent`. Các kiểu phổ biến bao gồm `SystemMessage` (khởi tạo phiên), `AssistantMessage` (phản hồi hoàn chỉnh), `ResultMessage` (kết quả cuối) và một tin nhắn ranh giới compact cho biết khi nào lịch sử hội thoại được nén lại (`SDKCompactBoundaryMessage` trong TypeScript; `SystemMessage` với subtype `"compact_boundary"` trong Python).

## Stream phản hồi văn bản

Để hiển thị văn bản ngay khi nó được sinh ra, hãy tìm các sự kiện `content_block_delta` mà `delta.type` là `text_delta`. Chúng chứa các đoạn văn bản tăng dần. Ví dụ dưới đây in mỗi đoạn ngay khi nó đến:

<CodeGroup>
  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions
  from claude_agent_sdk.types import StreamEvent
  import asyncio


  async def stream_text():
      options = ClaudeAgentOptions(include_partial_messages=True)

      async for message in query(prompt="Explain how databases work", options=options):
          if isinstance(message, StreamEvent):
              event = message.event
              if event.get("type") == "content_block_delta":
                  delta = event.get("delta", {})
                  if delta.get("type") == "text_delta":
                      # Print each text chunk as it arrives
                      print(delta.get("text", ""), end="", flush=True)

      print()  # Final newline


  asyncio.run(stream_text())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Explain how databases work",
    options: { includePartialMessages: true }
  })) {
    if (message.type === "stream_event") {
      const event = message.event;
      if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
        process.stdout.write(event.delta.text);
      }
    }
  }

  console.log(); // Final newline
  ```
</CodeGroup>

## Stream các lệnh gọi tool

Các lệnh gọi tool cũng được stream tăng dần. Bạn có thể theo dõi khi nào tool bắt đầu, nhận đầu vào của chúng ngay khi được sinh ra, và thấy khi nào chúng hoàn tất. Ví dụ dưới đây theo dõi tool hiện đang được gọi và tích lũy đầu vào JSON khi nó được stream về. Nó sử dụng ba kiểu sự kiện:

* `content_block_start`: tool bắt đầu
* `content_block_delta` với `input_json_delta`: các đoạn đầu vào đến
* `content_block_stop`: lệnh gọi tool hoàn tất

<CodeGroup>
  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions
  from claude_agent_sdk.types import StreamEvent
  import asyncio


  async def stream_tool_calls():
      options = ClaudeAgentOptions(
          include_partial_messages=True,
          allowed_tools=["Read", "Bash"],
      )

      # Track the current tool and accumulate its input JSON
      current_tool = None
      tool_input = ""

      async for message in query(prompt="Read the README.md file", options=options):
          if isinstance(message, StreamEvent):
              event = message.event
              event_type = event.get("type")

              if event_type == "content_block_start":
                  # New tool call is starting
                  content_block = event.get("content_block", {})
                  if content_block.get("type") == "tool_use":
                      current_tool = content_block.get("name")
                      tool_input = ""
                      print(f"Starting tool: {current_tool}")

              elif event_type == "content_block_delta":
                  delta = event.get("delta", {})
                  if delta.get("type") == "input_json_delta":
                      # Accumulate JSON input as it streams in
                      chunk = delta.get("partial_json", "")
                      tool_input += chunk
                      print(f"  Input chunk: {chunk}")

              elif event_type == "content_block_stop":
                  # Tool call complete - show final input
                  if current_tool:
                      print(f"Tool {current_tool} called with: {tool_input}")
                      current_tool = None


  asyncio.run(stream_tool_calls())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Track the current tool and accumulate its input JSON
  let currentTool: string | null = null;
  let toolInput = "";

  for await (const message of query({
    prompt: "Read the README.md file",
    options: {
      includePartialMessages: true,
      allowedTools: ["Read", "Bash"]
    }
  })) {
    if (message.type === "stream_event") {
      const event = message.event;

      if (event.type === "content_block_start") {
        // New tool call is starting
        if (event.content_block.type === "tool_use") {
          currentTool = event.content_block.name;
          toolInput = "";
          console.log(`Starting tool: ${currentTool}`);
        }
      } else if (event.type === "content_block_delta") {
        if (event.delta.type === "input_json_delta") {
          // Accumulate JSON input as it streams in
          const chunk = event.delta.partial_json;
          toolInput += chunk;
          console.log(`  Input chunk: ${chunk}`);
        }
      } else if (event.type === "content_block_stop") {
        // Tool call complete - show final input
        if (currentTool) {
          console.log(`Tool ${currentTool} called with: ${toolInput}`);
          currentTool = null;
        }
      }
    }
  }
  ```
</CodeGroup>

## Xây dựng giao diện stream

Ví dụ này kết hợp việc stream văn bản và tool thành một giao diện thống nhất. Nó theo dõi xem agent có đang thực thi một tool hay không (dùng cờ `in_tool`) để hiển thị các chỉ báo trạng thái như `[Using Read...]` trong khi tool chạy. Văn bản được stream bình thường khi không ở trong tool, và việc tool hoàn tất kích hoạt một thông báo "done". Mẫu này hữu ích cho các giao diện chat cần hiển thị tiến độ trong các tác vụ agent nhiều bước.

<CodeGroup>
  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage
  from claude_agent_sdk.types import StreamEvent
  import asyncio
  import sys


  async def streaming_ui():
      options = ClaudeAgentOptions(
          include_partial_messages=True,
          allowed_tools=["Read", "Bash", "Grep"],
      )

      # Track whether we're currently in a tool call
      in_tool = False

      async for message in query(
          prompt="Find all TODO comments in the codebase", options=options
      ):
          if isinstance(message, StreamEvent):
              event = message.event
              event_type = event.get("type")

              if event_type == "content_block_start":
                  content_block = event.get("content_block", {})
                  if content_block.get("type") == "tool_use":
                      # Tool call is starting - show status indicator
                      tool_name = content_block.get("name")
                      print(f"\n[Using {tool_name}...]", end="", flush=True)
                      in_tool = True

              elif event_type == "content_block_delta":
                  delta = event.get("delta", {})
                  # Only stream text when not executing a tool
                  if delta.get("type") == "text_delta" and not in_tool:
                      sys.stdout.write(delta.get("text", ""))
                      sys.stdout.flush()

              elif event_type == "content_block_stop":
                  if in_tool:
                      # Tool call finished
                      print(" done", flush=True)
                      in_tool = False

          elif isinstance(message, ResultMessage):
              # Agent finished all work
              print(f"\n\n--- Complete ---")


  asyncio.run(streaming_ui())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Track whether we're currently in a tool call
  let inTool = false;

  for await (const message of query({
    prompt: "Find all TODO comments in the codebase",
    options: {
      includePartialMessages: true,
      allowedTools: ["Read", "Bash", "Grep"]
    }
  })) {
    if (message.type === "stream_event") {
      const event = message.event;

      if (event.type === "content_block_start") {
        if (event.content_block.type === "tool_use") {
          // Tool call is starting - show status indicator
          process.stdout.write(`\n[Using ${event.content_block.name}...]`);
          inTool = true;
        }
      } else if (event.type === "content_block_delta") {
        // Only stream text when not executing a tool
        if (event.delta.type === "text_delta" && !inTool) {
          process.stdout.write(event.delta.text);
        }
      } else if (event.type === "content_block_stop") {
        if (inTool) {
          // Tool call finished
          console.log(" done");
          inTool = false;
        }
      }
    } else if (message.type === "result") {
      // Agent finished all work
      console.log("\n\n--- Complete ---");
    }
  }
  ```
</CodeGroup>

## Các hạn chế đã biết

* **Structured output**: kết quả JSON chỉ xuất hiện trong `ResultMessage.structured_output` cuối cùng, không phải dưới dạng các delta stream. Xem [structured outputs](/en/agent-sdk/structured-outputs) để biết chi tiết.

## Các bước tiếp theo

Giờ đây khi bạn đã có thể stream văn bản và các lệnh gọi tool theo thời gian thực, hãy khám phá các chủ đề liên quan sau:

* [Truy vấn tương tác so với một lần (one-shot)](/en/agent-sdk/streaming-vs-single-mode): chọn giữa các chế độ đầu vào cho trường hợp sử dụng của bạn
* [Structured outputs](/en/agent-sdk/structured-outputs): nhận phản hồi JSON có kiểu (typed) từ agent
* [Quyền (Permissions)](/en/agent-sdk/permissions): kiểm soát những tool nào agent có thể sử dụng
