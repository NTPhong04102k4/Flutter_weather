> Nguồn: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Slash Commands trong SDK

> Tìm hiểu cách dùng slash command để điều khiển phiên Claude Code thông qua SDK

Slash command cung cấp một cách để điều khiển phiên Claude Code bằng các lệnh đặc biệt bắt đầu bằng `/`. Những lệnh này có thể được gửi qua SDK để thực hiện các hành động như nén (compact) ngữ cảnh, liệt kê mức sử dụng ngữ cảnh, hoặc gọi các lệnh tùy chỉnh. Chỉ những lệnh hoạt động được mà không cần terminal tương tác mới có thể được điều phối (dispatch) qua SDK; thông điệp `system/init` liệt kê những lệnh có sẵn trong phiên của bạn.

## Khám phá các Slash Command có sẵn

Claude Agent SDK cung cấp thông tin về các slash command có sẵn trong thông điệp khởi tạo hệ thống (system initialization). Hãy truy cập thông tin này khi phiên của bạn bắt đầu:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Hello Claude",
    options: { maxTurns: 1 }
  })) {
    if (message.type === "system" && message.subtype === "init") {
      console.log("Available slash commands:", message.slash_commands);
      // Bao gồm các lệnh dựng sẵn cộng với các skill đóng gói kèm, ví dụ:
      // ["clear", "compact", "context", "usage", "code-review", "verify", ...]
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage


  async def main():
      async for message in query(prompt="Hello Claude", options=ClaudeAgentOptions(max_turns=1)):
          if isinstance(message, SystemMessage) and message.subtype == "init":
              print("Available slash commands:", message.data["slash_commands"])
              # Bao gồm các lệnh dựng sẵn cộng với các skill đóng gói kèm, ví dụ:
              # ["clear", "compact", "context", "usage", "code-review", "verify", ...]


  asyncio.run(main())
  ```
</CodeGroup>

## Gửi Slash Command

Gửi slash command bằng cách đưa chúng vào chuỗi prompt của bạn, giống như văn bản thông thường. Các lệnh tác động lên lịch sử hội thoại, chẳng hạn `/compact`, cần có các thông điệp trước đó để làm việc, nên các ví dụ dưới đây đặt câu hỏi trước rồi mới gửi lệnh như một lượt tiếp nối trong cùng cuộc hội thoại:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Xây dựng lịch sử hội thoại trước
  try {
    for await (const message of query({
      prompt: "What does the README in this directory cover?",
      options: { maxTurns: 2 }
    })) {
      if (message.type === "result" && message.subtype === "success") {
        console.log(message.result);
      }
    }
  } catch (error) {
    // Một query() dạng single-shot sẽ ném lỗi sau khi trả về một result lỗi,
    // nên truy vấn follow-up bên dưới vẫn chạy.
    console.error(`Session ended with an error: ${error}`);
  }

  // Gửi một slash command như lượt tiếp nối của cùng cuộc hội thoại
  for await (const message of query({
    prompt: "/compact",
    options: { continue: true, maxTurns: 1 }
  })) {
    if (message.type === "result") {
      console.log("Command executed, result subtype:", message.subtype);
      // Ví dụ kết quả: Command executed, result subtype: success
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


  async def main():
      # Xây dựng lịch sử hội thoại trước
      try:
          async for message in query(
              prompt="What does the README in this directory cover?",
              options=ClaudeAgentOptions(max_turns=2),
          ):
              if isinstance(message, ResultMessage) and message.subtype == "success":
                  print(message.result)
      except Exception as error:
          # Một query() dạng single-shot sẽ raise lỗi sau khi trả về một result lỗi,
          # nên truy vấn follow-up bên dưới vẫn chạy.
          print(f"Session ended with an error: {error}")

      # Gửi một slash command như lượt tiếp nối của cùng cuộc hội thoại
      async for message in query(
          prompt="/compact",
          options=ClaudeAgentOptions(continue_conversation=True, max_turns=1),
      ):
          if isinstance(message, ResultMessage):
              print("Command executed, result subtype:", message.subtype)
              # Ví dụ kết quả: Command executed, result subtype: success


  asyncio.run(main())
  ```
</CodeGroup>

<Note>
  Một truy vấn có thể kết thúc với một result lỗi, ví dụ khi đạt tới giới hạn `maxTurns` / `max_turns` trước khi công việc hoàn thành. Khi đó, thông điệp result cuối cùng sẽ có `is_error: true` và một subtype lỗi như `error_max_turns` thay vì `success`.

  Sau khi trả về thông điệp result cuối cùng đó, SDK sẽ ném lỗi, vì tiến trình CLI thoát với mã khác 0.

  Hãy bọc vòng lặp trong `try`/`catch` với TypeScript hoặc `try`/`except` với Python nếu lệnh của bạn có thể chạm giới hạn, như trình bày trong [Single Message Input](/en/agent-sdk/streaming-vs-single-mode#single-message-input), hoặc đặt `maxTurns` đủ cao để công việc hoàn thành. Trong Python, hãy bắt `Exception`: SDK phát các result lỗi dưới dạng một `Exception` thông thường.
</Note>

## Các Slash Command thông dụng

### `/compact` - Nén lịch sử hội thoại

Lệnh `/compact` giảm kích thước lịch sử hội thoại của bạn bằng cách tóm tắt các thông điệp cũ hơn trong khi vẫn giữ lại ngữ cảnh quan trọng. Việc nén cần một cuộc hội thoại đã có sẵn với ít nhất hai lượt trao đổi trước đó để tóm tắt. Ví dụ này có một cuộc hội thoại trước, sau đó nén lại và đọc thông điệp hệ thống `compact_boundary` báo cáo kết quả:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Việc nén cần lịch sử có sẵn, nên hãy có một cuộc hội thoại trước
  try {
    for await (const message of query({
      prompt: "Explain what this project does",
      options: { maxTurns: 2 }
    })) {
      if (message.type === "result" && message.subtype === "success") {
        console.log(message.result);
      }
    }
  } catch (error) {
    // Một query() dạng single-shot sẽ ném lỗi sau khi trả về một result lỗi,
    // nên truy vấn follow-up bên dưới vẫn chạy.
    console.error(`Session ended with an error: ${error}`);
  }

  // Nén cùng cuộc hội thoại đó
  for await (const message of query({
    prompt: "/compact",
    options: { continue: true, maxTurns: 1 }
  })) {
    if (message.type === "system" && message.subtype === "compact_boundary") {
      console.log("Compaction completed");
      console.log("Pre-compaction tokens:", message.compact_metadata.pre_tokens);
      console.log("Trigger:", message.compact_metadata.trigger);
      // Ví dụ kết quả:
      // Compaction completed
      // Pre-compaction tokens: 1842
      // Trigger: manual
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage, SystemMessage


  async def main():
      # Việc nén cần lịch sử có sẵn, nên hãy có một cuộc hội thoại trước
      try:
          async for message in query(
              prompt="Explain what this project does",
              options=ClaudeAgentOptions(max_turns=2),
          ):
              if isinstance(message, ResultMessage) and message.subtype == "success":
                  print(message.result)
      except Exception as error:
          # Một query() dạng single-shot sẽ raise lỗi sau khi trả về một result lỗi,
          # nên truy vấn follow-up bên dưới vẫn chạy.
          print(f"Session ended with an error: {error}")

      # Nén cùng cuộc hội thoại đó
      async for message in query(
          prompt="/compact",
          options=ClaudeAgentOptions(continue_conversation=True, max_turns=1),
      ):
          if isinstance(message, SystemMessage) and message.subtype == "compact_boundary":
              print("Compaction completed")
              print("Pre-compaction tokens:", message.data["compact_metadata"]["pre_tokens"])
              print("Trigger:", message.data["compact_metadata"]["trigger"])
              # Ví dụ kết quả:
              # Compaction completed
              # Pre-compaction tokens: 1842
              # Trigger: manual


  asyncio.run(main())
  ```
</CodeGroup>

<Note>
  Một thông điệp `compact_boundary` chỉ xuất hiện khi việc nén đã chạy. Khi không có gì để tóm tắt, `/compact` sẽ báo cáo lý do thay vì ném lỗi: lần chạy vẫn kết thúc với một result `success`, không có thông điệp `compact_boundary` nào được phát ra, và văn bản result mang theo thông báo, ví dụ `Not enough messages to compact.` sau một lượt trao đổi ngắn duy nhất. Một lời gọi `query()` dạng one-shot mới bắt đầu với ngữ cảnh trống, nên hãy dùng mẫu này trong một phiên có các lượt trước đó, ví dụ trong [chế độ streaming input](/en/agent-sdk/streaming-vs-single-mode) hoặc khi tiếp tục (resume) một phiên.
</Note>

### `/clear` - Đặt lại ngữ cảnh hội thoại

Lệnh `/clear` đặt lại cuộc hội thoại về ngữ cảnh trống, nên các prompt tiếp theo bắt đầu mà không có lịch sử hội thoại trước đó. Cuộc hội thoại trước vẫn còn trên đĩa và có thể quay lại bằng cách truyền session ID của nó vào [tùy chọn `resume`](/en/agent-sdk/sessions#resume-by-id).

Điều này hữu ích trong [chế độ streaming input](/en/agent-sdk/streaming-vs-single-mode), nơi bạn gửi nhiều prompt qua một kết nối duy nhất. Với các lời gọi `query()` dạng one-shot, mỗi lời gọi đã bắt đầu với ngữ cảnh trống, nên gửi `/clear` không có tác dụng thực tế; thay vào đó hãy khởi động một `query()` mới.

<Note>
  `/clear` trong SDK yêu cầu Claude Code v2.1.117 trở lên. Ở các phiên bản cũ hơn, nó bị bỏ qua khỏi `slash_commands`.
</Note>

## Tạo Slash Command tùy chỉnh

Ngoài việc dùng các slash command dựng sẵn, bạn có thể tạo các lệnh tùy chỉnh của riêng mình để dùng qua SDK. Các lệnh tùy chỉnh được định nghĩa dưới dạng các file markdown trong những thư mục cụ thể, tương tự cách cấu hình subagent.

<Note>
  Thư mục `.claude/commands/` là định dạng cũ (legacy). Định dạng được khuyến nghị là `.claude/skills/<name>/SKILL.md`, hỗ trợ cùng cách gọi bằng slash command (`/name`) cộng thêm khả năng được Claude gọi tự động. Xem [Skills](/en/agent-sdk/skills) để biết định dạng hiện tại. CLI vẫn tiếp tục hỗ trợ cả hai định dạng, và các ví dụ dưới đây vẫn chính xác cho `.claude/commands/`.
</Note>

### Vị trí file

Các slash command tùy chỉnh được lưu trong các thư mục chỉ định dựa trên phạm vi của chúng:

* **Lệnh cấp dự án (Project commands)**: `.claude/commands/` - Chỉ có sẵn trong dự án hiện tại (legacy; nên ưu tiên `.claude/skills/`)
* **Lệnh cá nhân (Personal commands)**: `~/.claude/commands/` - Có sẵn trên tất cả các dự án của bạn (legacy; nên ưu tiên `~/.claude/skills/`)

### Định dạng file

Mỗi lệnh tùy chỉnh là một file markdown, trong đó:

* Tên file (bỏ phần mở rộng `.md`) trở thành tên lệnh
* Nội dung file định nghĩa lệnh làm gì
* Phần YAML frontmatter tùy chọn cung cấp cấu hình

#### Ví dụ cơ bản

Tạo thư mục `.claude/commands` trong dự án của bạn nếu chưa có, sau đó tạo `.claude/commands/refactor.md`:

```markdown theme={null}
Refactor the selected code to improve readability and maintainability.
Focus on clean code principles and best practices.
```

Điều này tạo ra lệnh `/refactor` mà bạn có thể dùng qua SDK.

#### Có Frontmatter

Tạo `.claude/commands/security-check.md`:

```markdown theme={null}
---
allowed-tools: Read, Grep, Glob
description: Run security vulnerability scan
model: claude-opus-4-8
---

Analyze the codebase for security vulnerabilities including:
- SQL injection risks
- XSS vulnerabilities
- Exposed credentials
- Insecure configurations
```

### Dùng Lệnh tùy chỉnh trong SDK

Sau khi được định nghĩa trong hệ thống file, các lệnh tùy chỉnh tự động có sẵn qua SDK:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Dùng một lệnh tùy chỉnh
  try {
    for await (const message of query({
      prompt: "/refactor src/auth/login.ts",
      options: { maxTurns: 3 }
    })) {
      if (message.type === "assistant") {
        console.log("Refactoring suggestions:", message.message);
      }
    }
  } catch (error) {
    // Một query() dạng single-shot sẽ ném lỗi sau khi trả về một result lỗi,
    // nên truy vấn thứ hai bên dưới vẫn chạy.
    console.error(`Session ended with an error: ${error}`);
  }

  // Các lệnh tùy chỉnh xuất hiện trong danh sách slash_commands
  for await (const message of query({
    prompt: "Hello",
    options: { maxTurns: 1 }
  })) {
    if (message.type === "system" && message.subtype === "init") {
      console.log("Available commands:", message.slash_commands);
      // Bao gồm các lệnh dựng sẵn cộng với các skill đóng gói kèm và các lệnh tùy chỉnh của bạn, ví dụ:
      // ["clear", "compact", "context", "usage", "code-review", "verify", "refactor", "security-check", ...]
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, SystemMessage


  async def main():
      # Dùng một lệnh tùy chỉnh
      try:
          async for message in query(
              prompt="/refactor src/auth/login.py", options=ClaudeAgentOptions(max_turns=3)
          ):
              if isinstance(message, AssistantMessage):
                  for block in message.content:
                      if hasattr(block, "text"):
                          print("Refactoring suggestions:", block.text)
      except Exception as error:
          # Một query() dạng single-shot sẽ raise lỗi sau khi trả về một result lỗi,
          # nên truy vấn thứ hai bên dưới vẫn chạy.
          print(f"Session ended with an error: {error}")

      # Các lệnh tùy chỉnh xuất hiện trong danh sách slash_commands
      async for message in query(prompt="Hello", options=ClaudeAgentOptions(max_turns=1)):
          if isinstance(message, SystemMessage) and message.subtype == "init":
              print("Available commands:", message.data["slash_commands"])
              # Bao gồm các lệnh dựng sẵn cộng với các skill đóng gói kèm và các lệnh tùy chỉnh của bạn, ví dụ:
              # ["clear", "compact", "context", "usage", "code-review", "verify", "refactor", "security-check", ...]


  asyncio.run(main())
  ```
</CodeGroup>

### Tính năng nâng cao

#### Tham số và Placeholder

Các lệnh tùy chỉnh hỗ trợ tham số động (dynamic arguments) bằng placeholder:

Tạo `.claude/commands/fix-issue.md`:

```markdown theme={null}
---
argument-hint: [issue-number] [priority]
description: Fix a GitHub issue
---

Fix issue #$0 with priority $1.
Check the issue description and implement the necessary changes.
```

Dùng trong SDK:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Truyền tham số cho lệnh tùy chỉnh
  for await (const message of query({
    prompt: "/fix-issue 123 high",
    options: { maxTurns: 5 }
  })) {
    // Lệnh sẽ xử lý với $0="123" và $1="high"
    if (message.type === "result" && message.subtype === "success") {
      console.log("Issue fixed:", message.result);
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


  async def main():
      # Truyền tham số cho lệnh tùy chỉnh
      async for message in query(prompt="/fix-issue 123 high", options=ClaudeAgentOptions(max_turns=5)):
          # Lệnh sẽ xử lý với $0="123" và $1="high"
          if isinstance(message, ResultMessage):
              print("Issue fixed:", message.result)


  asyncio.run(main())
  ```
</CodeGroup>

#### Thực thi lệnh Bash

Các lệnh tùy chỉnh có thể thực thi lệnh bash và đưa đầu ra của chúng vào:

Tạo `.claude/commands/git-commit.md`:

```markdown theme={null}
---
allowed-tools: Bash(git add *), Bash(git status *), Bash(git commit *)
description: Create a git commit
---

## Context

- Current status: !`git status`
- Current diff: !`git diff HEAD`

## Task

Create a git commit with appropriate message based on the changes.
```

#### Tham chiếu file

Đưa nội dung file vào bằng tiền tố `@`:

Tạo `.claude/commands/review-config.md`:

```markdown theme={null}
---
description: Review configuration files
---

Review the following configuration files for issues:
- Package config: @package.json
- TypeScript config: @tsconfig.json
- Environment config: @.env

Check for security issues, outdated dependencies, and misconfigurations.
```

### Tổ chức bằng Namespacing

Tổ chức các lệnh trong thư mục con để có cấu trúc tốt hơn:

```bash theme={null}
.claude/commands/
├── frontend/
│   ├── component.md      # Creates /component (project:frontend)
│   └── style-check.md     # Creates /style-check (project:frontend)
├── backend/
│   ├── api-test.md        # Creates /api-test (project:backend)
│   └── db-migrate.md      # Creates /db-migrate (project:backend)
└── review.md              # Creates /review (project)
```

Thư mục con xuất hiện trong phần mô tả lệnh nhưng không ảnh hưởng đến chính tên lệnh.

### Ví dụ thực tế

#### Lệnh Review Pull Request

Tạo `.claude/commands/review-pr.md`:

```markdown theme={null}
---
allowed-tools: Read, Grep, Glob, Bash(git diff *)
description: Comprehensive code review
---

## Changed Files
!`git diff --name-only HEAD~1`

## Detailed Changes
!`git diff HEAD~1`

## Review Checklist

Review the above changes for:
1. Code quality and readability
2. Security vulnerabilities
3. Performance implications
4. Test coverage
5. Documentation completeness

Provide specific, actionable feedback organized by priority.
```

<Note>
  Claude Code có kèm các skill đóng gói sẵn `code-review` và `verify`. Nếu bạn đặt tên một lệnh tùy chỉnh trùng với một trong số đó, ví dụ `.claude/commands/code-review.md`, lệnh của bạn sẽ che khuất (shadow) skill đóng gói và `slash_commands` liệt kê tên đó một lần.
</Note>

#### Lệnh chạy Test

Tạo `.claude/commands/test.md`:

```markdown theme={null}
---
allowed-tools: Bash, Read, Edit
argument-hint: [test-pattern]
description: Run tests with optional pattern
---

Run tests matching pattern: $ARGUMENTS

1. Detect the test framework (Jest, pytest, etc.)
2. Run tests with the provided pattern
3. If tests fail, analyze and fix them
4. Re-run to verify fixes
```

Dùng các lệnh này qua SDK:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Chạy code review
  try {
    for await (const message of query({
      prompt: "/review-pr",
      options: { maxTurns: 3 }
    })) {
      // Xử lý phản hồi review
    }
  } catch (error) {
    // Một query() dạng single-shot sẽ ném lỗi sau khi trả về một result lỗi,
    // nên truy vấn thứ hai bên dưới vẫn chạy.
    console.error(`Session ended with an error: ${error}`);
  }

  // Chạy các test cụ thể
  for await (const message of query({
    prompt: "/test auth",
    options: { maxTurns: 5 }
  })) {
    // Xử lý kết quả test
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions


  async def main():
      # Chạy code review
      try:
          async for message in query(prompt="/review-pr", options=ClaudeAgentOptions(max_turns=3)):
              # Xử lý phản hồi review
              pass
      except Exception as error:
          # Một query() dạng single-shot sẽ raise lỗi sau khi trả về một result lỗi,
          # nên truy vấn thứ hai bên dưới vẫn chạy.
          print(f"Session ended with an error: {error}")

      # Chạy các test cụ thể
      async for message in query(prompt="/test auth", options=ClaudeAgentOptions(max_turns=5)):
          # Xử lý kết quả test
          pass


  asyncio.run(main())
  ```
</CodeGroup>

## Xem thêm

* [Slash Commands](/en/skills) - Tài liệu đầy đủ về slash command
* [Subagents in the SDK](/en/agent-sdk/subagents) - Cấu hình dựa trên hệ thống file tương tự dành cho subagent
* [TypeScript SDK reference](/en/agent-sdk/typescript) - Tài liệu API đầy đủ
* [SDK overview](/en/agent-sdk/overview) - Các khái niệm chung về SDK
* [CLI reference](/en/cli-reference) - Giao diện dòng lệnh
