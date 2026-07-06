> Nguồn: https://code.claude.com/docs/en/agent-sdk/subagents.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Subagent trong SDK

> Định nghĩa và gọi các subagent để cô lập ngữ cảnh, chạy các tác vụ song song, và áp dụng các chỉ dẫn chuyên biệt trong các ứng dụng Claude Agent SDK của bạn.

Subagent là các thực thể agent riêng biệt mà agent chính của bạn có thể sinh ra (spawn) để xử lý các tác vụ con tập trung.
Dùng chúng để cô lập ngữ cảnh, chạy nhiều phân tích song song, và áp dụng các chỉ dẫn chuyên biệt mà không làm phình prompt của agent chính.

Hướng dẫn này giải thích cách định nghĩa và sử dụng subagent trong SDK bằng tham số `agents`.

## Tổng quan

Bạn có thể tạo subagent theo ba cách:

* **Theo lập trình (Programmatically)**: dùng tham số `agents` trong options của `query()` của bạn. Xem tham chiếu [TypeScript](/en/agent-sdk/typescript#agentdefinition) và [Python](/en/agent-sdk/python#agentdefinition)
* **Dựa trên hệ thống file (Filesystem-based)**: định nghĩa các agent dưới dạng các file markdown trong các thư mục `.claude/agents/`. Xem [định nghĩa subagent dưới dạng file](/en/sub-agents)
* **general-purpose có sẵn (Built-in)**: Claude có thể gọi subagent `general-purpose` có sẵn bất kỳ lúc nào thông qua tool Agent mà không cần bạn định nghĩa bất cứ điều gì

Hướng dẫn này tập trung vào cách tiếp cận theo lập trình, được khuyến nghị cho các ứng dụng SDK.

Khi bạn định nghĩa các subagent, Claude quyết định có gọi chúng hay không dựa trên trường `description` của mỗi subagent. Hãy viết các mô tả rõ ràng giải thích khi nào dùng subagent, và Claude sẽ tự động ủy thác (delegate) các tác vụ phù hợp. Bạn cũng có thể yêu cầu một subagent một cách tường minh bằng tên trong prompt của mình, ví dụ "Use the code-reviewer agent to...".

## Lợi ích của việc dùng subagent

### Cô lập ngữ cảnh

Mỗi subagent chạy trong cuộc hội thoại mới của riêng nó. Các lệnh gọi tool và kết quả trung gian nằm bên trong subagent; chỉ có tin nhắn cuối cùng của nó được trả về cho agent cha. Xem [Subagent thừa hưởng những gì](#what-subagents-inherit) để biết chính xác những gì có trong ngữ cảnh của subagent.

**Ví dụ:** một subagent `research-assistant` có thể khám phá hàng chục file mà không có nội dung nào trong đó tích lũy vào cuộc hội thoại chính. Agent cha nhận được một bản tóm tắt ngắn gọn, không phải mọi file mà subagent đã đọc.

### Song song hóa (Parallelization)

Nhiều subagent có thể chạy đồng thời, nên các tác vụ con độc lập hoàn thành trong khoảng thời gian của cái chậm nhất thay vì tổng thời gian của tất cả chúng.

**Ví dụ:** trong quá trình review code, bạn có thể chạy đồng thời các subagent `style-checker`, `security-scanner`, và `test-coverage` thay vì tuần tự.

### Chỉ dẫn và kiến thức chuyên biệt

Mỗi subagent có thể có system prompt được thiết kế riêng với chuyên môn, best practice và ràng buộc cụ thể.

**Ví dụ:** một subagent `database-migration` có thể có kiến thức chi tiết về best practice SQL, chiến lược rollback, và các kiểm tra tính toàn vẹn dữ liệu mà sẽ là nhiễu không cần thiết trong chỉ dẫn của agent chính.

### Hạn chế tool

Subagent có thể bị giới hạn ở các tool cụ thể, giảm nguy cơ các hành động ngoài ý muốn.

**Ví dụ:** một subagent `doc-reviewer` có thể chỉ có quyền truy cập vào các tool Read và Grep, đảm bảo nó có thể phân tích nhưng không bao giờ vô tình sửa đổi các file tài liệu của bạn.

## Tạo subagent

### Định nghĩa theo lập trình (được khuyến nghị)

Định nghĩa các subagent trực tiếp trong code của bạn bằng tham số `agents`. Claude gọi các subagent thông qua tool `Agent`, nên hãy đưa `Agent` vào `allowedTools` để tự động phê duyệt các lệnh gọi subagent mà không cần một yêu cầu về quyền.

Hầu hết các ví dụ trên trang này chỉ in ra kết quả cuối cùng. Để xác nhận rằng Claude đã ủy thác cho một subagent thay vì trả lời trực tiếp, xem [Phát hiện việc gọi subagent](#detect-subagent-invocation).

Ví dụ này tạo hai subagent: một code reviewer với quyền chỉ đọc và một test runner có thể thực thi lệnh.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition


  async def main():
      async for message in query(
          prompt="Review the authentication module for security issues",
          options=ClaudeAgentOptions(
              # Auto-approve these tools, including Agent for subagent invocation
              allowed_tools=["Read", "Grep", "Glob", "Agent"],
              agents={
                  "code-reviewer": AgentDefinition(
                      # description tells Claude when to use this subagent
                      description="Expert code review specialist. Use for quality, security, and maintainability reviews.",
                      # prompt defines the subagent's behavior and expertise
                      prompt="""You are a code review specialist with expertise in security, performance, and best practices.

  When reviewing code:
  - Identify security vulnerabilities
  - Check for performance issues
  - Verify adherence to coding standards
  - Suggest specific improvements

  Be thorough but concise in your feedback.""",
                      # tools restricts what the subagent can do (read-only here)
                      tools=["Read", "Grep", "Glob"],
                      # model overrides the default model for this subagent
                      model="sonnet",
                  ),
                  "test-runner": AgentDefinition(
                      description="Runs and analyzes test suites. Use for test execution and coverage analysis.",
                      prompt="""You are a test execution specialist. Run tests and provide clear analysis of results.

  Focus on:
  - Running test commands
  - Analyzing test output
  - Identifying failing tests
  - Suggesting fixes for failures""",
                      # Bash access lets this subagent run test commands
                      tools=["Bash", "Read", "Grep"],
                  ),
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
    prompt: "Review the authentication module for security issues",
    options: {
      // Auto-approve these tools, including Agent for subagent invocation
      allowedTools: ["Read", "Grep", "Glob", "Agent"],
      agents: {
        "code-reviewer": {
          // description tells Claude when to use this subagent
          description:
            "Expert code review specialist. Use for quality, security, and maintainability reviews.",
          // prompt defines the subagent's behavior and expertise
          prompt: `You are a code review specialist with expertise in security, performance, and best practices.

  When reviewing code:
  - Identify security vulnerabilities
  - Check for performance issues
  - Verify adherence to coding standards
  - Suggest specific improvements

  Be thorough but concise in your feedback.`,
          // tools restricts what the subagent can do (read-only here)
          tools: ["Read", "Grep", "Glob"],
          // model overrides the default model for this subagent
          model: "sonnet"
        },
        "test-runner": {
          description:
            "Runs and analyzes test suites. Use for test execution and coverage analysis.",
          prompt: `You are a test execution specialist. Run tests and provide clear analysis of results.

  Focus on:
  - Running test commands
  - Analyzing test output
  - Identifying failing tests
  - Suggesting fixes for failures`,
          // Bash access lets this subagent run test commands
          tools: ["Bash", "Read", "Grep"]
        }
      }
    }
  })) {
    if ("result" in message) console.log(message.result);
  }
  ```
</CodeGroup>

### Cấu hình AgentDefinition

| Trường            | Kiểu                                                        | Bắt buộc | Mô tả                                                                                                                                                                                                                            |
| :---------------- | :---------------------------------------------------------- | :------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `description`     | `string`                                                    | Có       | Mô tả bằng ngôn ngữ tự nhiên về khi nào dùng agent này                                                                                                                                                                          |
| `prompt`          | `string`                                                    | Có       | System prompt của agent định nghĩa vai trò và hành vi của nó                                                                                                                                                                     |
| `tools`           | `string[]`                                                  | Không    | Mảng các tên tool được phép. Nếu bỏ qua, sẽ thừa hưởng tất cả các tool                                                                                                                                                          |
| `disallowedTools` | `string[]`                                                  | Không    | Mảng các tên tool cần loại bỏ khỏi bộ tool của agent. Các mẫu ở cấp máy chủ MCP cũng được chấp nhận: `mcp__server` hoặc `mcp__server__*` loại bỏ mọi tool từ máy chủ đó, và `mcp__*` loại bỏ mọi tool MCP từ bất kỳ máy chủ nào |
| `model`           | `string`                                                    | Không    | Ghi đè model cho agent này. Chấp nhận một alias như `'fable'`, `'opus'`, `'sonnet'`, `'haiku'`, `'inherit'`, hoặc một model ID đầy đủ. Mặc định là model chính nếu bỏ qua                                                        |
| `skills`          | `string[]`                                                  | Không    | Danh sách các tên skill để nạp trước (preload) vào ngữ cảnh của agent lúc khởi động. Các skill không được liệt kê vẫn có thể gọi được qua tool Skill                                                                             |
| `memory`          | `'user' \| 'project' \| 'local'`                            | Không    | Nguồn memory cho agent này                                                                                                                                                                                                      |
| `mcpServers`      | `(string \| object)[]`                                      | Không    | Các máy chủ MCP khả dụng cho agent này, theo tên hoặc cấu hình inline                                                                                                                                                            |
| `initialPrompt`   | `string`                                                    | Không    | Tự động gửi làm lượt người dùng đầu tiên khi agent này chạy với vai trò agent của thread chính. Bị bỏ qua khi agent được gọi làm một subagent                                                                                    |
| `maxTurns`        | `number`                                                    | Không    | Số lượt agentic tối đa trước khi agent dừng                                                                                                                                                                                     |
| `background`      | `boolean`                                                   | Không    | Chạy agent này như một tác vụ nền (background) không chặn (non-blocking) khi được gọi                                                                                                                                            |
| `effort`          | `'low' \| 'medium' \| 'high' \| 'xhigh' \| 'max' \| number` | Không    | Mức độ nỗ lực suy luận (reasoning effort) cho agent này                                                                                                                                                                          |
| `permissionMode`  | `PermissionMode`                                            | Không    | Chế độ quyền cho việc thực thi tool bên trong agent này                                                                                                                                                                          |

Trong Python SDK, các tên trường nhiều từ như `disallowedTools` và `mcpServers` giữ nguyên cách viết camelCase để khớp với định dạng truyền dữ liệu (wire format) thay vì tuân theo quy ước snake\_case của Python. Xem [tham chiếu `AgentDefinition`](/en/agent-sdk/python#agentdefinition) để biết chi tiết.

Hai hành vi của subagent đã thay đổi trong Claude Code v2.1.198:

* Subagent chạy ở nền theo mặc định. Một lệnh gọi tool Agent bỏ qua đầu vào [`run_in_background`](/en/agent-sdk/typescript) sẽ khởi chạy một subagent nền, và Claude đặt `run_in_background: false` khi nó cần kết quả trước khi tiếp tục. Trước v2.1.198, việc bỏ qua `run_in_background` chạy subagent một cách đồng bộ. Đặt trường `background` thành `true` để buộc thực thi ở nền cho một agent cụ thể bất kể Claude yêu cầu gì.
* Một subagent thừa hưởng cấu hình extended thinking của phiên chính. Trên các phiên bản cũ hơn, extended thinking bị vô hiệu hóa bên trong các subagent bất kể cài đặt của phiên chính.

<Note>
  {/* min-version: 2.1.172 */}Kể từ Claude Code v2.1.172, các subagent có thể sinh ra các subagent của riêng chúng. Một subagent ở năm cấp dưới agent chính không thể sinh thêm subagent, bất kể nó chạy ở tiền cảnh (foreground) hay nền (background). Để ngăn một subagent sinh ra các subagent khác, hãy bỏ `Agent` khỏi mảng `tools` của nó hoặc thêm nó vào `disallowedTools`. Xem [subagent lồng nhau](/en/sub-agents#spawn-nested-subagents) để biết đầy đủ các quy tắc về độ sâu.
</Note>

### Định nghĩa dựa trên hệ thống file (thay thế)

Bạn cũng có thể định nghĩa các subagent dưới dạng các file markdown trong các thư mục `.claude/agents/`. Xem [tài liệu subagent của Claude Code](/en/sub-agents) để biết chi tiết về cách tiếp cận này. Các agent được định nghĩa theo lập trình được ưu tiên hơn các agent dựa trên hệ thống file có cùng tên.

<Note>
  Ngay cả khi không định nghĩa các subagent tùy chỉnh, Claude vẫn có thể sinh ra subagent `general-purpose` có sẵn. Điều này hữu ích để ủy thác các tác vụ nghiên cứu hoặc khám phá mà không cần tạo các agent chuyên biệt. Hãy đưa `Agent` vào `allowedTools` để các lệnh gọi này tự động phê duyệt mà không cần một yêu cầu về quyền.
</Note>

## Subagent thừa hưởng những gì

Cửa sổ ngữ cảnh (context window) của một subagent bắt đầu mới, không có cuộc hội thoại của agent cha, nhưng không rỗng. Kênh duy nhất từ agent cha đến subagent là chuỗi prompt của tool Agent, nên hãy đưa bất kỳ đường dẫn file, thông báo lỗi, hoặc quyết định nào mà subagent cần trực tiếp vào prompt đó.

| Subagent nhận được                                                                                                                     | Subagent không nhận được                                          |
| :------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------- |
| System prompt của riêng nó (`AgentDefinition.prompt`) và prompt của tool Agent                                                        | Lịch sử hội thoại hoặc kết quả tool của agent cha                 |
| CLAUDE.md của project (nạp qua [`settingSources`](/en/agent-sdk/claude-code-features#control-filesystem-settings-with-settingsources)) | Nội dung skill được nạp trước, trừ khi được liệt kê trong `AgentDefinition.skills` |
| Các định nghĩa tool (thừa hưởng từ agent cha, hoặc tập con trong `tools`)                                                             | System prompt của agent cha                                       |

<Note>
  Agent cha nhận được tin nhắn cuối cùng của subagent nguyên văn làm kết quả tool Agent, nhưng có thể tóm tắt nó trong phản hồi của chính mình. Để giữ nguyên văn đầu ra của subagent trong phản hồi hướng đến người dùng, hãy đưa một chỉ dẫn để làm điều đó vào prompt hoặc tùy chọn `systemPrompt` mà bạn truyền cho lệnh gọi `query()` chính.
</Note>

{/* min-version: 2.1.199 */}Một lỗi API kết thúc subagent sớm, chẳng hạn như một rate limit, sẽ không bao giờ được gửi làm kết quả của nó. Nếu một rate limit, quá tải (overload), hoặc lỗi máy chủ cắt ngang một subagent tiền cảnh vốn đã tạo ra đầu ra văn bản, thì tool Agent trả về đầu ra một phần đó kèm một ghi chú rằng subagent chưa hoàn thành. {/* min-version: 2.1.200 */}Một subagent không tạo ra gì, hoặc mà đầu ra duy nhất của nó là các lệnh gọi tool không có văn bản, sẽ thất bại với một thông báo lỗi, `Agent terminated early due to an API error`, theo sau là chi tiết lỗi. Xem [Lỗi API trong subagent](/en/sub-agents#api-errors-in-subagents) để biết hành vi ở tiền cảnh và nền.

Việc xử lý đầu ra một phần này yêu cầu Claude Code v2.1.199 trở lên. Trong v2.1.199, một rate limit, quá tải, hoặc lỗi máy chủ để lại hình dạng chỉ-có-lệnh-gọi-tool với một kết quả một phần rỗng chỉ chứa ghi chú về việc bị cắt ngang.

## Gọi subagent

### Gọi tự động

Claude tự động quyết định khi nào gọi các subagent dựa trên tác vụ và `description` của mỗi subagent. Ví dụ, nếu bạn định nghĩa một subagent `performance-optimizer` với mô tả "Performance optimization specialist for query tuning", Claude sẽ gọi nó khi prompt của bạn đề cập đến việc tối ưu hóa truy vấn.

Hãy viết các mô tả rõ ràng, cụ thể để Claude có thể khớp các tác vụ với đúng subagent.

### Gọi tường minh

Để đảm bảo Claude sử dụng một subagent cụ thể, hãy đề cập đến nó bằng tên trong prompt của bạn:

```text theme={null}
"Use the code-reviewer agent to check the authentication module"
```

Điều này bỏ qua việc khớp tự động và gọi trực tiếp subagent được nêu tên.

### Cấu hình agent động

Bạn có thể tạo các định nghĩa agent một cách động dựa trên các điều kiện lúc chạy. Ví dụ này tạo một security reviewer với các mức độ nghiêm ngặt khác nhau, sử dụng một model mạnh hơn cho các review nghiêm ngặt.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition


  # Factory function that returns an AgentDefinition
  # This pattern lets you customize agents based on runtime conditions
  def create_security_agent(security_level: str) -> AgentDefinition:
      is_strict = security_level == "strict"
      return AgentDefinition(
          description="Security code reviewer",
          # Customize the prompt based on strictness level
          prompt=f"You are a {'strict' if is_strict else 'balanced'} security reviewer...",
          tools=["Read", "Grep", "Glob"],
          # Key insight: use a more capable model for high-stakes reviews
          model="opus" if is_strict else "sonnet",
      )


  async def main():
      # The agent is created at query time, so each request can use different settings
      async for message in query(
          prompt="Review this PR for security issues",
          options=ClaudeAgentOptions(
              allowed_tools=["Read", "Grep", "Glob", "Agent"],
              agents={
                  # Call the factory with your desired configuration
                  "security-reviewer": create_security_agent("strict")
              },
          ),
      ):
          if hasattr(message, "result"):
              print(message.result)


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query, type AgentDefinition } from "@anthropic-ai/claude-agent-sdk";

  // Factory function that returns an AgentDefinition
  // This pattern lets you customize agents based on runtime conditions
  function createSecurityAgent(securityLevel: "basic" | "strict"): AgentDefinition {
    const isStrict = securityLevel === "strict";
    return {
      description: "Security code reviewer",
      // Customize the prompt based on strictness level
      prompt: `You are a ${isStrict ? "strict" : "balanced"} security reviewer...`,
      tools: ["Read", "Grep", "Glob"],
      // Key insight: use a more capable model for high-stakes reviews
      model: isStrict ? "opus" : "sonnet"
    };
  }

  // The agent is created at query time, so each request can use different settings
  for await (const message of query({
    prompt: "Review this PR for security issues",
    options: {
      allowedTools: ["Read", "Grep", "Glob", "Agent"],
      agents: {
        // Call the factory with your desired configuration
        "security-reviewer": createSecurityAgent("strict")
      }
    }
  })) {
    if ("result" in message) console.log(message.result);
  }
  ```
</CodeGroup>

## Phát hiện việc gọi subagent

Claude gọi các subagent thông qua tool Agent. Để phát hiện khi một subagent được gọi, hãy kiểm tra các khối `tool_use` mà `name` là `"Agent"`. Các tin nhắn từ bên trong ngữ cảnh của một subagent bao gồm một trường `parent_tool_use_id`.

<Note>
  Tên tool đã được đổi từ `"Task"` thành `"Agent"` trong Claude Code v2.1.63. Các bản phát hành SDK hiện tại phát ra `"Agent"` trong các khối `tool_use` nhưng vẫn dùng `"Task"` trong danh sách tool `system:init` và trong `result.permission_denials[].tool_name`. Kiểm tra cả hai giá trị trong `block.name` đảm bảo tương thích giữa các phiên bản SDK.
</Note>

Cấu trúc tin nhắn khác nhau giữa các SDK. Trong Python, bạn truy cập trực tiếp các khối nội dung qua `message.content`. Trong TypeScript, `SDKAssistantMessage` bọc tin nhắn Claude API, nên bạn truy cập nội dung qua `message.message.content`.

Ví dụ này lặp qua các tin nhắn được stream, ghi log khi một subagent được gọi và khi các tin nhắn tiếp theo bắt nguồn từ bên trong ngữ cảnh thực thi của subagent đó.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition, ToolUseBlock


  async def main():
      async for message in query(
          prompt="Use the code-reviewer agent to review this codebase",
          options=ClaudeAgentOptions(
              allowed_tools=["Read", "Glob", "Grep", "Agent"],
              agents={
                  "code-reviewer": AgentDefinition(
                      description="Expert code reviewer.",
                      prompt="Analyze code quality and suggest improvements.",
                      tools=["Read", "Glob", "Grep"],
                  )
              },
          ),
      ):
          # Check for subagent invocation. Match both names: older SDK
          # versions emitted "Task", current versions emit "Agent".
          if hasattr(message, "content") and message.content:
              for block in message.content:
                  if isinstance(block, ToolUseBlock) and block.name in (
                      "Task",
                      "Agent",
                  ):
                      print(f"Subagent invoked: {block.input.get('subagent_type')}")

          # Check if this message is from within a subagent's context
          if hasattr(message, "parent_tool_use_id") and message.parent_tool_use_id:
              print("  (running inside subagent)")

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
          description: "Expert code reviewer.",
          prompt: "Analyze code quality and suggest improvements.",
          tools: ["Read", "Glob", "Grep"]
        }
      }
    }
  })) {
    const msg = message as any;

    // Check for subagent invocation. Match both names: older SDK versions
    // emitted "Task", current versions emit "Agent".
    for (const block of msg.message?.content ?? []) {
      if (block.type === "tool_use" && (block.name === "Task" || block.name === "Agent")) {
        console.log(`Subagent invoked: ${block.input.subagent_type}`);
      }
    }

    // Check if this message is from within a subagent's context
    if (msg.parent_tool_use_id) {
      console.log("  (running inside subagent)");
    }

    if ("result" in message) {
      console.log(message.result);
    }
  }
  ```
</CodeGroup>

## Resume subagent

Bạn có thể resume một subagent để tiếp tục từ nơi nó đã dừng thay vì bắt đầu lại từ đầu. Một subagent được resume giữ lại toàn bộ lịch sử hội thoại của nó, bao gồm tất cả các lệnh gọi tool, kết quả và lập luận trước đó.

Khi một subagent hoàn thành, kết quả tool Agent bao gồm một khối văn bản chứa `agentId: <id>`. Các agent [`Explore` và `Plan` có sẵn](/en/sub-agents#built-in-subagents) là một-lần (one-shot) và không trả về một `agentId`, nên hãy dùng một agent tùy chỉnh hoặc `general-purpose` khi bạn cần resume. Để resume một subagent theo lập trình:

1. **Nắm bắt session ID**: trích xuất `session_id` từ các tin nhắn trong truy vấn đầu tiên
2. **Trích xuất agent ID**: phân tích `agentId` từ văn bản kết quả tool Agent
3. **Resume phiên**: truyền `resume: sessionId` trong options của truy vấn thứ hai, và đưa agent ID vào prompt của bạn

<Note>
  Bạn phải resume cùng một phiên để truy cập bản ghi (transcript) của subagent. Mỗi lệnh gọi `query()` theo mặc định bắt đầu một phiên mới, nên hãy truyền `resume: sessionId` để tiếp tục trong cùng một phiên.

  Khi dùng một agent tùy chỉnh, hãy truyền cùng một định nghĩa agent trong tham số `agents` cho cả hai truy vấn.
</Note>

Ví dụ dưới đây định nghĩa một agent `endpoint-finder` tùy chỉnh. Truy vấn đầu tiên chạy nó và nắm bắt session ID và agent ID từ kết quả tool Agent, sau đó truy vấn thứ hai resume phiên để hỏi một câu hỏi tiếp theo cần ngữ cảnh từ phân tích đầu tiên.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  import re
  from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition, ToolResultBlock

  AGENTS = {
      "endpoint-finder": AgentDefinition(
          description="Locates and catalogs API endpoints in a codebase.",
          prompt="You find and document API endpoints. Report each endpoint's path, method, and handler.",
          tools=["Read", "Grep", "Glob"],
      )
  }


  def extract_agent_id(block: ToolResultBlock) -> str | None:
      """Extract agentId from an Agent tool result's text content."""
      parts = block.content if isinstance(block.content, list) else [{"text": block.content}]
      for part in parts:
          if match := re.search(r"agentId:\s*([\w-]+)", part.get("text") or ""):
              return match.group(1)
      return None


  async def main():
      agent_id = None
      session_id = None

      # First invocation - run the endpoint-finder subagent
      try:
          async for message in query(
              prompt="Use the endpoint-finder agent to find all API endpoints in this codebase",
              options=ClaudeAgentOptions(allowed_tools=["Read", "Grep", "Glob", "Agent"], agents=AGENTS),
          ):
              # Capture session_id from ResultMessage (needed to resume this session)
              if hasattr(message, "session_id"):
                  session_id = message.session_id
              # Search tool results for the agentId trailer
              for block in getattr(message, "content", None) or []:
                  if isinstance(block, ToolResultBlock):
                      agent_id = extract_agent_id(block) or agent_id
              # Print the final result
              if hasattr(message, "result"):
                  print(message.result)
      except Exception as error:
          # A single-shot query() raises after yielding an error result,
          # so session_id and agent_id have already been captured by the loop above.
          print(f"Session ended with an error: {error}")

      # Second invocation - resume and ask follow-up
      if agent_id and session_id:
          async for message in query(
              prompt=f"Resume agent {agent_id} and list the top 3 most complex endpoints",
              options=ClaudeAgentOptions(
                  allowed_tools=["Read", "Grep", "Glob", "Agent"], agents=AGENTS, resume=session_id
              ),
          ):
              if hasattr(message, "result"):
                  print(message.result)
      else:
          print("No agentId found in the first query, so there is no subagent to resume.")


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query, type SDKMessage } from "@anthropic-ai/claude-agent-sdk";

  const agents = {
    "endpoint-finder": {
      description: "Locates and catalogs API endpoints in a codebase.",
      prompt: "You find and document API endpoints. Report each endpoint's path, method, and handler.",
      tools: ["Read", "Grep", "Glob"]
    }
  };

  // Stringify content to search for agentId without traversing nested block types
  function extractAgentId(message: SDKMessage): string | undefined {
    if (message.type !== "assistant" && message.type !== "user") return undefined;
    const content = JSON.stringify(message.message.content);
    const match = content.match(/agentId:\s*([\w-]+)/);
    return match?.[1];
  }

  let agentId: string | undefined;
  let sessionId: string | undefined;

  // First invocation - run the endpoint-finder subagent
  try {
    for await (const message of query({
      prompt: "Use the endpoint-finder agent to find all API endpoints in this codebase",
      options: { allowedTools: ["Read", "Grep", "Glob", "Agent"], agents }
    })) {
      // Capture session_id from ResultMessage (needed to resume this session)
      if ("session_id" in message) sessionId = message.session_id;
      // Search message content for the agentId (appears in Agent tool results)
      const extractedId = extractAgentId(message);
      if (extractedId) agentId = extractedId;
      // Print the final result
      if ("result" in message) console.log(message.result);
    }
  } catch (error) {
    // A single-shot query() throws after yielding an error result,
    // so sessionId and agentId have already been captured by the loop above.
    console.error(`Session ended with an error: ${error}`);
  }

  // Second invocation - resume and ask follow-up
  if (agentId && sessionId) {
    for await (const message of query({
      prompt: `Resume agent ${agentId} and list the top 3 most complex endpoints`,
      options: { allowedTools: ["Read", "Grep", "Glob", "Agent"], agents, resume: sessionId }
    })) {
      if ("result" in message) console.log(message.result);
    }
  } else {
    console.log("No agentId found in the first query, so there is no subagent to resume.");
  }
  ```
</CodeGroup>

Các bản ghi (transcript) của subagent được lưu độc lập với cuộc hội thoại chính:

* **Nén cuộc hội thoại chính**: khi cuộc hội thoại chính được nén (compact), các bản ghi subagent không bị ảnh hưởng. Chúng được lưu trong các file riêng biệt.
* **Duy trì phiên**: các bản ghi subagent được duy trì trong phiên của chúng. Bạn có thể resume một subagent sau khi khởi động lại Claude Code bằng cách resume cùng một phiên.
* **Dọn dẹp tự động**: các bản ghi được dọn dẹp dựa trên cài đặt `cleanupPeriodDays`, mặc định là 30 ngày.

## Hạn chế tool

Subagent có thể có quyền truy cập tool bị hạn chế qua trường `tools`:

* **Bỏ qua trường này**: agent thừa hưởng tất cả các tool khả dụng (mặc định)
* **Chỉ định các tool**: agent chỉ có thể dùng các tool được liệt kê

Ví dụ này tạo một agent phân tích chỉ đọc, có thể kiểm tra code nhưng không thể sửa đổi file hoặc chạy lệnh.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition


  async def main():
      async for message in query(
          prompt="Analyze the architecture of this codebase",
          options=ClaudeAgentOptions(
              allowed_tools=["Read", "Grep", "Glob", "Agent"],
              agents={
                  "code-analyzer": AgentDefinition(
                      description="Static code analysis and architecture review",
                      prompt="""You are a code architecture analyst. Analyze code structure,
  identify patterns, and suggest improvements without making changes.""",
                      # Read-only tools: no Edit, Write, or Bash access
                      tools=["Read", "Grep", "Glob"],
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
    prompt: "Analyze the architecture of this codebase",
    options: {
      allowedTools: ["Read", "Grep", "Glob", "Agent"],
      agents: {
        "code-analyzer": {
          description: "Static code analysis and architecture review",
          prompt: `You are a code architecture analyst. Analyze code structure,
  identify patterns, and suggest improvements without making changes.`,
          // Read-only tools: no Edit, Write, or Bash access
          tools: ["Read", "Grep", "Glob"]
        }
      }
    }
  })) {
    if ("result" in message) console.log(message.result);
  }
  ```
</CodeGroup>

### Các tổ hợp tool phổ biến

| Trường hợp sử dụng | Tool                                    | Mô tả                                                     |
| :----------------- | :-------------------------------------- | :------------------------------------------------------- |
| Phân tích chỉ đọc  | `Read`, `Grep`, `Glob`                  | Có thể kiểm tra code nhưng không sửa đổi hoặc thực thi    |
| Thực thi test      | `Bash`, `Read`, `Grep`                  | Có thể chạy lệnh và phân tích đầu ra                      |
| Sửa đổi code       | `Read`, `Edit`, `Write`, `Grep`, `Glob` | Quyền đọc/ghi đầy đủ mà không thực thi lệnh               |
| Truy cập đầy đủ    | Tất cả các tool                         | Thừa hưởng tất cả các tool từ agent cha (bỏ qua trường `tools`) |

## Mở rộng quy mô với các quy trình động

Subagent hoạt động tốt cho một vài tác vụ được ủy thác mỗi lượt. Đối với các lần chạy điều phối hàng chục đến hàng trăm agent, hãy dùng tool `Workflow`, vốn chuyển việc điều phối vào một script mà runtime thực thi bên ngoài ngữ cảnh hội thoại. Xem [quy trình động (dynamic workflows)](/en/workflows) để biết các workflow khác với việc ủy thác subagent theo từng lượt như thế nào.

Tool `Workflow` có sẵn trong TypeScript Agent SDK v0.3.149 trở lên. Hãy đưa `Workflow` vào `allowedTools` để tự động phê duyệt các lần chạy workflow. Các schema đầu vào và đầu ra của tool được liệt kê trong [tham chiếu TypeScript](/en/agent-sdk/typescript#workflow).

## Xử lý sự cố

### Claude không ủy thác cho subagent

Nếu Claude hoàn thành các tác vụ trực tiếp thay vì ủy thác cho subagent của bạn:

* **Kiểm tra các lệnh gọi Agent đã được phê duyệt**: đưa `Agent` vào `allowedTools` để tự động phê duyệt các lệnh gọi subagent. Không có nó, các lệnh gọi Agent sẽ chuyển sang callback `canUseTool` của bạn hoặc, trong chế độ `dontAsk`, bị từ chối
* **Dùng prompt tường minh**: đề cập đến subagent bằng tên trong prompt của bạn, ví dụ "Use the code-reviewer agent to..."
* **Viết một mô tả rõ ràng**: giải thích chính xác khi nào dùng subagent để Claude có thể khớp các tác vụ một cách phù hợp

### Các agent dựa trên hệ thống file không được nạp

Claude Code theo dõi `~/.claude/agents/` và `.claude/agents/` và tiếp nhận một file agent mới hoặc đã chỉnh sửa trong vòng vài giây, không cần khởi động lại. Nếu một định nghĩa không bao giờ xuất hiện, hãy xem xét các nguyên nhân sau:

* **Thư mục `agents` mới**: bộ theo dõi (watcher) chỉ bao phủ các thư mục đã tồn tại khi phiên bắt đầu, nên file đầu tiên trong một thư mục mới cần khởi động lại phiên. Đây là nguyên nhân phổ biến nhất.
* **Frontmatter không hợp lệ hoặc `name` trùng lặp**: kiểm tra YAML của file, và xem liệu một agent hiện có đã dùng `name` đó chưa.
* **`--disable-slash-commands`**: các phiên được khởi động với cờ này không theo dõi các thư mục này và luôn cần khởi động lại để nạp các file mới.
* **Một agent theo lập trình có cùng tên**: `agents` được truyền cho `query()` sẽ ghi đè một agent hệ thống file có cùng tên.

Về định dạng file, xem [cách viết các file subagent](/en/sub-agents#write-subagent-files).

### Lỗi prompt dài trên Windows

Trên Windows, các subagent với prompt rất dài có thể thất bại do giới hạn độ dài dòng lệnh là 8191 ký tự. Hãy giữ prompt ngắn gọn hoặc dùng các agent dựa trên hệ thống file cho các chỉ dẫn phức tạp.

## Tài liệu liên quan

* [Subagent của Claude Code](/en/sub-agents): tài liệu subagent toàn diện bao gồm các định nghĩa dựa trên hệ thống file
* [Quy trình động (Dynamic workflows)](/en/workflows): điều phối nhiều subagent từ một script cho các công việc quá lớn đối với một cuộc hội thoại
* [Tổng quan SDK](/en/agent-sdk/overview): bắt đầu với Claude Agent SDK
