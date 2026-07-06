> Nguồn: https://code.claude.com/docs/en/agent-sdk/sessions.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Làm việc với session

> Cách session lưu giữ lịch sử hội thoại của agent, và khi nào nên dùng continue, resume và fork để quay lại một lần chạy trước đó.

Một session là lịch sử hội thoại mà SDK tích lũy trong khi agent của bạn làm việc. Nó chứa prompt của bạn, mọi lời gọi công cụ (tool call) mà agent thực hiện, mọi kết quả công cụ, và mọi phản hồi. SDK tự động ghi nó ra đĩa để bạn có thể quay lại sau này.

Quay lại một session nghĩa là agent có đầy đủ ngữ cảnh từ trước đó: các file mà nó đã đọc, phân tích mà nó đã thực hiện, các quyết định mà nó đã đưa ra. Bạn có thể đặt câu hỏi tiếp nối, phục hồi sau khi bị gián đoạn, hoặc rẽ nhánh để thử một hướng tiếp cận khác.

<Note>
  Session lưu giữ **cuộc hội thoại**, không phải hệ thống file. Để chụp ảnh (snapshot) và hoàn tác các thay đổi file mà agent thực hiện, hãy dùng [file checkpointing](/en/agent-sdk/file-checkpointing).
</Note>

Hướng dẫn này bao gồm cách chọn hướng tiếp cận phù hợp cho ứng dụng của bạn, các interface của SDK theo dõi session một cách tự động, cách nắm bắt session ID và sử dụng `resume` và `fork` thủ công, và những điều cần biết khi resume session xuyên các host.

## Chọn một hướng tiếp cận

Mức độ xử lý session bạn cần phụ thuộc vào hình thái ứng dụng của bạn. Quản lý session trở nên quan trọng khi bạn gửi nhiều prompt cần chia sẻ chung ngữ cảnh. Trong một lời gọi `query()` đơn lẻ, agent đã tự thực hiện bao nhiêu lượt (turn) mà nó cần, và các prompt xin phép quyền cùng `AskUserQuestion` được [xử lý ngay trong vòng lặp](/en/agent-sdk/user-input) (chúng không kết thúc lời gọi).

| Bạn đang xây dựng gì                                                     | Nên dùng gì                                                                                                                                                      |
| :---------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tác vụ một lần: một prompt duy nhất, không có tiếp nối                   | Không cần gì thêm. Một lời gọi `query()` là đủ.                                                                                                                  |
| Chat nhiều lượt trong một tiến trình                                     | [`ClaudeSDKClient` (Python) hoặc `continue: true` (TypeScript)](#automatic-session-management). SDK tự theo dõi session cho bạn mà không cần xử lý ID.           |
| Tiếp tục từ chỗ bạn dừng lại sau khi tiến trình khởi động lại            | `continue_conversation=True` (Python) / `continue: true` (TypeScript). Resume session gần đây nhất trong thư mục, không cần ID.                                   |
| Resume một session cụ thể trong quá khứ (không phải cái gần đây nhất)    | Nắm bắt session ID và truyền nó vào `resume`.                                                                                                                    |
| Thử một hướng thay thế mà không mất bản gốc                              | Fork session.                                                                                                                                                    |
| Tác vụ không trạng thái (stateless), không muốn ghi gì ra đĩa (chỉ TypeScript) | Đặt [`persistSession: false`](/en/agent-sdk/typescript#options). Session chỉ tồn tại trong bộ nhớ trong suốt thời gian lời gọi. Python luôn ghi ra đĩa. |

### Continue, resume và fork

Continue, resume và fork là các trường tùy chọn (option) bạn đặt trên `query()` ([`ClaudeAgentOptions`](/en/agent-sdk/python#claudeagentoptions) trong Python, [`Options`](/en/agent-sdk/typescript#options) trong TypeScript).

**Continue** và **resume** đều lấy một session đang tồn tại và bổ sung thêm vào nó. Khác biệt là ở cách chúng tìm session đó:

* **Continue** tìm session gần đây nhất trong thư mục hiện tại. Bạn không cần theo dõi gì cả. Hoạt động tốt khi ứng dụng của bạn chạy mỗi lần một cuộc hội thoại.
* **Resume** nhận một session ID cụ thể. Bạn theo dõi ID đó. Bắt buộc khi bạn có nhiều session (ví dụ, mỗi user một session trong ứng dụng đa người dùng) hoặc muốn quay lại một session không phải cái gần đây nhất.

**Fork** thì khác: nó tạo ra một session mới bắt đầu bằng một bản sao lịch sử của session gốc. Session gốc giữ nguyên không đổi. Dùng fork để thử một hướng khác trong khi vẫn giữ được lựa chọn quay lại.

## Quản lý session tự động

Cả hai SDK đều cung cấp một interface theo dõi trạng thái session giùm bạn xuyên các lời gọi, để bạn không phải truyền ID thủ công. Dùng chúng cho các cuộc hội thoại nhiều lượt trong một tiến trình đơn.

### Python: `ClaudeSDKClient`

[`ClaudeSDKClient`](/en/agent-sdk/python#claudesdkclient) xử lý session ID nội bộ. Mỗi lời gọi `client.query()` tự động tiếp tục cùng một session. Gọi [`client.receive_response()`](/en/agent-sdk/python#claudesdkclient) để lặp qua các message của query hiện tại. Dùng client như một async context manager để việc thiết lập và dọn dẹp kết nối được xử lý giùm bạn, hoặc gọi `connect()` và `disconnect()` thủ công.

Ví dụ này chạy hai query trên cùng một `client`. Query đầu tiên yêu cầu agent phân tích một module; query thứ hai yêu cầu nó tái cấu trúc (refactor) module đó. Vì cả hai lời gọi đều đi qua cùng một instance client, query thứ hai có đầy đủ ngữ cảnh từ query đầu tiên mà không cần `resume` hay session ID rõ ràng nào:

```python Python theme={null}
import asyncio
from claude_agent_sdk import (
    ClaudeSDKClient,
    ClaudeAgentOptions,
    AssistantMessage,
    ResultMessage,
    TextBlock,
)


def print_response(message):
    """Print only the human-readable parts of a message."""
    if isinstance(message, AssistantMessage):
        for block in message.content:
            if isinstance(block, TextBlock):
                print(block.text)
    elif isinstance(message, ResultMessage):
        cost = (
            f"${message.total_cost_usd:.4f}"
            if message.total_cost_usd is not None
            else "N/A"
        )
        print(f"[done: {message.subtype}, cost: {cost}]")


async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Glob", "Grep"],
    )

    async with ClaudeSDKClient(options=options) as client:
        # First query: client captures the session ID internally
        await client.query("Analyze the auth module")
        async for message in client.receive_response():
            print_response(message)

        # Second query: automatically continues the same session
        await client.query("Now refactor it to use JWT")
        async for message in client.receive_response():
            print_response(message)


asyncio.run(main())
```

Xem [tài liệu tham khảo Python SDK](/en/agent-sdk/python#choosing-between-query-and-claudesdkclient) để biết chi tiết khi nào nên dùng `ClaudeSDKClient` so với hàm `query()` độc lập.

### TypeScript: `continue: true`

TypeScript SDK không có đối tượng client giữ session như `ClaudeSDKClient` của Python. Thay vào đó, truyền `continue: true` trên mỗi lời gọi `query()` tiếp theo và SDK sẽ lấy session gần đây nhất trong thư mục hiện tại. Không cần theo dõi ID.

Ví dụ này thực hiện hai lời gọi `query()` riêng biệt. Lời gọi đầu tiên tạo một session mới; lời gọi thứ hai đặt `continue: true`, báo cho SDK tìm và resume session gần đây nhất trên đĩa. Agent có đầy đủ ngữ cảnh từ lời gọi đầu tiên:

```typescript TypeScript theme={null}
import { query } from "@anthropic-ai/claude-agent-sdk";

// First query: creates a new session
for await (const message of query({
  prompt: "Analyze the auth module",
  options: { allowedTools: ["Read", "Glob", "Grep"] }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}

// Second query: continue: true resumes the most recent session
for await (const message of query({
  prompt: "Now refactor it to use JWT",
  options: {
    continue: true,
    allowedTools: ["Read", "Edit", "Write", "Glob", "Grep"]
  }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

<Note>
  API session V2 thử nghiệm ([V2 session API](/en/agent-sdk/typescript-v2-preview)), vốn cung cấp `createSession()` với mẫu `send` / `stream`, đã bị loại bỏ trong TypeScript Agent SDK 0.3.142. Hãy dùng hàm `query()` và các tùy chọn session mô tả trên trang này thay thế.
</Note>

## Dùng các tùy chọn session với `query()`

### Nắm bắt session ID

Resume và fork yêu cầu một session ID. Đọc nó từ trường `session_id` trên result message ([`ResultMessage`](/en/agent-sdk/python#resultmessage) trong Python, [`SDKResultMessage`](/en/agent-sdk/typescript#sdkresultmessage) trong TypeScript), trường này hiện diện trên mọi result bất kể thành công hay lỗi. Trong TypeScript, ID cũng có sẵn sớm hơn dưới dạng một trường trực tiếp trên `SystemMessage` init; trong Python nó được lồng bên trong `SystemMessage.data`.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


  async def main():
      session_id = None

      async for message in query(
          prompt="Analyze the auth module and suggest improvements",
          options=ClaudeAgentOptions(
              allowed_tools=["Read", "Glob", "Grep"],
          ),
      ):
          if isinstance(message, ResultMessage):
              session_id = message.session_id
              if message.subtype == "success":
                  print(message.result)

      print(f"Session ID: {session_id}")
      return session_id


  session_id = asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  let sessionId: string | undefined;

  for await (const message of query({
    prompt: "Analyze the auth module and suggest improvements",
    options: { allowedTools: ["Read", "Glob", "Grep"] }
  })) {
    if (message.type === "result") {
      sessionId = message.session_id;
      if (message.subtype === "success") {
        console.log(message.result);
      }
    }
  }

  console.log(`Session ID: ${sessionId}`);
  ```
</CodeGroup>

### Resume theo ID

Truyền một session ID vào `resume` để quay lại session cụ thể đó. Agent tiếp tục với đầy đủ ngữ cảnh từ nơi session dừng lại. Các lý do thường gặp để resume:

* **Tiếp nối một tác vụ đã hoàn thành.** Agent đã phân tích một thứ gì đó; bây giờ bạn muốn nó hành động dựa trên phân tích đó mà không cần đọc lại file.
* **Phục hồi sau khi chạm giới hạn.** Lần chạy đầu kết thúc với `error_max_turns` hoặc `error_max_budget_usd` (xem [Xử lý kết quả](/en/agent-sdk/agent-loop#handle-the-result)); resume với một giới hạn cao hơn.
* **Khởi động lại tiến trình của bạn.** Bạn đã nắm bắt ID trước khi tắt và muốn khôi phục cuộc hội thoại.

Ví dụ này resume session từ [Nắm bắt session ID](#capture-the-session-id) với một prompt tiếp nối. Vì bạn đang resume, agent đã có sẵn phân tích trước đó trong ngữ cảnh:

<CodeGroup>
  ```python Python theme={null}
  # Earlier session analyzed the code; now build on that analysis
  async for message in query(
      prompt="Now implement the refactoring you suggested",
      options=ClaudeAgentOptions(
          resume=session_id,
          allowed_tools=["Read", "Edit", "Write", "Glob", "Grep"],
      ),
  ):
      if isinstance(message, ResultMessage) and message.subtype == "success":
          print(message.result)
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  const sessionId = "..."; // The ID you captured in the previous example

  // Earlier session analyzed the code; now build on that analysis
  for await (const message of query({
    prompt: "Now implement the refactoring you suggested",
    options: {
      resume: sessionId,
      allowedTools: ["Read", "Edit", "Write", "Glob", "Grep"]
    }
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
  ```
</CodeGroup>

Bạn sẽ thấy một phản hồi được xây dựng dựa trên phân tích trước đó thay vì bắt đầu lại từ đầu. Điều đó xác nhận agent đã resume session với ngữ cảnh trước đó còn nguyên vẹn.

<Tip>
  Nếu một lời gọi `resume` trả về một session mới thay vì lịch sử như mong đợi, nguyên nhân phổ biến nhất là `cwd` không khớp. Session được lưu tại `~/.claude/projects/<encoded-cwd>/*.jsonl`, hoặc tại `$CLAUDE_CONFIG_DIR/projects/<encoded-cwd>/*.jsonl` nếu bạn đặt biến môi trường `CLAUDE_CONFIG_DIR`, trong đó `<encoded-cwd>` là thư mục làm việc tuyệt đối với mọi ký tự không phải chữ-số được thay bằng `-` (nên `/Users/me/proj` trở thành `-Users-me-proj`). Nếu lời gọi resume của bạn chạy từ một thư mục khác, SDK sẽ tìm sai chỗ. File session cũng cần tồn tại trên máy hiện tại.
</Tip>

Để resume session xuyên các máy hoặc trong môi trường serverless, hãy nhân bản (mirror) transcript sang bộ lưu trữ dùng chung bằng một [adapter `SessionStore`](/en/agent-sdk/session-storage).

### Fork để khám phá các hướng thay thế

Fork tạo ra một session mới bắt đầu bằng một bản sao lịch sử của session gốc nhưng rẽ nhánh từ điểm đó. Fork nhận session ID riêng của nó; ID và lịch sử của session gốc giữ nguyên không đổi. Kết quả bạn có hai session độc lập mà bạn có thể resume riêng lẻ.

<Note>
  Fork rẽ nhánh lịch sử hội thoại, không phải hệ thống file. Nếu một agent đã fork chỉnh sửa file, những thay đổi đó là thật và hiện hữu với bất kỳ session nào đang làm việc trong cùng thư mục. Để rẽ nhánh và hoàn tác các thay đổi file, hãy dùng [file checkpointing](/en/agent-sdk/file-checkpointing).
</Note>

Ví dụ này xây dựng dựa trên [Nắm bắt session ID](#capture-the-session-id): bạn đã phân tích một module auth trong `session_id` và muốn khám phá OAuth2 mà không mất luồng tập trung vào JWT. Khối đầu tiên fork session và nắm bắt ID của fork (`forked_id`); khối thứ hai resume `session_id` gốc để tiếp tục theo hướng JWT. Bây giờ bạn có hai session ID trỏ tới hai lịch sử riêng biệt:

<CodeGroup>
  ```python Python theme={null}
  # Fork: branch from session_id into a new session
  forked_id = None
  async for message in query(
      prompt="Instead of JWT, outline how OAuth2 would work for the auth module",
      options=ClaudeAgentOptions(
          resume=session_id,
          fork_session=True,
          max_turns=5,
      ),
  ):
      if isinstance(message, ResultMessage):
          forked_id = message.session_id  # The fork's ID, distinct from session_id
          if message.subtype == "success":
              print(message.result)

  print(f"Forked session: {forked_id}")

  # Original session is untouched; resuming it continues the JWT thread
  async for message in query(
      prompt="Continue with the JWT approach",
      options=ClaudeAgentOptions(resume=session_id),
  ):
      if isinstance(message, ResultMessage) and message.subtype == "success":
          print(message.result)
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  const sessionId = "..."; // The ID you captured in the previous example

  // Fork: branch from sessionId into a new session
  let forkedId: string | undefined;

  for await (const message of query({
    prompt: "Instead of JWT, outline how OAuth2 would work for the auth module",
    options: {
      resume: sessionId,
      forkSession: true,
      maxTurns: 5
    }
  })) {
    if (message.type === "system" && message.subtype === "init") {
      forkedId = message.session_id; // The fork's ID, distinct from sessionId
    }
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }

  console.log(`Forked session: ${forkedId}`);

  // Original session is untouched; resuming it continues the JWT thread
  for await (const message of query({
    prompt: "Continue with the JWT approach",
    options: { resume: sessionId }
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
  ```
</CodeGroup>

Bạn sẽ thấy rằng `forkedId` khác với session ID gốc. Resume session gốc vẫn tiếp tục luồng JWT, điều đó xác nhận fork không sửa đổi lịch sử gốc.

## Resume xuyên các host

File session là cục bộ trên máy đã tạo ra chúng. Để resume một session trên một host khác (CI worker, container tạm thời, serverless), bạn có hai lựa chọn:

* **Di chuyển file session.** Lưu giữ `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl` từ lần chạy đầu tiên và khôi phục nó vào đúng đường dẫn đó trên host mới trước khi gọi `resume`. `cwd` phải khớp.
* **Đừng phụ thuộc vào việc resume session.** Nắm bắt các kết quả bạn cần (kết quả phân tích, quyết định, diff file) dưới dạng trạng thái ứng dụng và truyền chúng vào prompt của một session mới. Cách này thường vững chắc hơn việc vận chuyển các file transcript qua lại.

Cả hai SDK đều cung cấp các hàm để liệt kê các session trên đĩa và đọc message của chúng: [`listSessions()`](/en/agent-sdk/typescript#listsessions) và [`getSessionMessages()`](/en/agent-sdk/typescript#getsessionmessages) trong TypeScript, [`list_sessions()`](/en/agent-sdk/python#list_sessions) và [`get_session_messages()`](/en/agent-sdk/python#get_session_messages) trong Python. Dùng chúng để xây dựng bộ chọn session tùy chỉnh, logic dọn dẹp, hoặc trình xem transcript.

Cả hai SDK cũng cung cấp các hàm để tra cứu và thay đổi (mutate) từng session riêng lẻ: [`get_session_info()`](/en/agent-sdk/python#get_session_info), [`rename_session()`](/en/agent-sdk/python#rename_session), và [`tag_session()`](/en/agent-sdk/python#tag_session) trong Python, và [`getSessionInfo()`](/en/agent-sdk/typescript#getsessioninfo), [`renameSession()`](/en/agent-sdk/typescript#renamesession), và [`tagSession()`](/en/agent-sdk/typescript#tagsession) trong TypeScript. Dùng chúng để tổ chức session theo tag hoặc đặt cho chúng những tiêu đề dễ đọc.

## Tài nguyên liên quan

* [Cách vòng lặp agent hoạt động](/en/agent-sdk/agent-loop): Hiểu về lượt (turn), message, và sự tích lũy ngữ cảnh trong một session
* [File checkpointing](/en/agent-sdk/file-checkpointing): Chụp ảnh và hoàn tác các thay đổi file mà agent thực hiện trong một session
* [`ClaudeAgentOptions` của Python](/en/agent-sdk/python#claudeagentoptions): Tài liệu tham khảo đầy đủ các tùy chọn session cho Python
* [`Options` của TypeScript](/en/agent-sdk/typescript#options): Tài liệu tham khảo đầy đủ các tùy chọn session cho TypeScript
