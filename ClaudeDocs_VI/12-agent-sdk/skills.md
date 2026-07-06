> Nguồn: https://code.claude.com/docs/en/agent-sdk/skills.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Agent Skills trong SDK

> Mở rộng Claude với các năng lực chuyên biệt bằng Agent Skills trong Claude Agent SDK

## Tổng quan

Agent Skills mở rộng Claude với các năng lực chuyên biệt mà Claude tự động gọi khi phù hợp. Các skill được đóng gói dưới dạng file `SKILL.md` chứa hướng dẫn, mô tả và các tài nguyên hỗ trợ tùy chọn.

Để biết thông tin đầy đủ về Skills, bao gồm lợi ích, kiến trúc và hướng dẫn viết, xem [Tổng quan về Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview).

## Cách Skills hoạt động với SDK

Khi dùng Claude Agent SDK, các Skill được:

1. **Định nghĩa dưới dạng artifact trên hệ thống tệp**: Tạo dưới dạng file `SKILL.md` trong các thư mục cụ thể (`.claude/skills/`)
2. **Nạp từ hệ thống tệp**: Các Skill được nạp từ những vị trí trên hệ thống tệp do `settingSources` (TypeScript) hoặc `setting_sources` (Python) quản lý
3. **Tự động phát hiện**: Sau khi các thiết lập hệ thống tệp được nạp, metadata của Skill được phát hiện lúc khởi động từ các thư mục người dùng và dự án; nội dung đầy đủ được nạp khi được kích hoạt
4. **Do model gọi**: Claude tự động chọn thời điểm sử dụng chúng dựa trên ngữ cảnh
5. **Lọc qua tùy chọn `skills`**: Các skill được phát hiện sẽ được bật theo mặc định. Truyền một danh sách tên skill, `"all"`, hoặc `[]` để kiểm soát skill nào khả dụng trong phiên

Không giống subagent (có thể định nghĩa bằng lập trình), Skills phải được tạo dưới dạng artifact trên hệ thống tệp. SDK không cung cấp API lập trình để đăng ký Skills.

<Note>
  Các Skill được phát hiện thông qua các nguồn thiết lập (setting source) của hệ thống tệp. Với các tùy chọn `query()` mặc định, SDK nạp các nguồn user và project, do đó các skill trong `~/.claude/skills/`, `<cwd>/.claude/skills/`, và `.claude/skills/` trong bất kỳ thư mục cha nào của `<cwd>` tính đến gốc kho lưu trữ đều khả dụng. Nếu bạn đặt `settingSources` một cách tường minh, hãy bao gồm `'user'` hoặc `'project'` để giữ việc phát hiện skill, hoặc dùng [tùy chọn `plugins`](/en/agent-sdk/plugins) để nạp skill từ một đường dẫn cụ thể.
</Note>

## Sử dụng Skills với SDK

Đặt tùy chọn `skills` trên `query()` để kiểm soát Skill nào khả dụng cho phiên. Khi được bỏ qua, các Skill được phát hiện sẽ được bật và công cụ Skill khả dụng, khớp với hành vi của CLI. Truyền `"all"` để bật mọi Skill được phát hiện, một danh sách tên Skill để chỉ bật những skill đó, hoặc `[]` để tắt tất cả. Khi bạn đặt `skills`, SDK tự động thêm công cụ Skill vào `allowedTools`. Nếu bạn cũng truyền một danh sách `tools` tường minh, hãy bao gồm `"Skill"` trong danh sách đó để Claude có thể gọi các skill.

Sau khi được cấu hình, Claude tự động phát hiện Skills từ hệ thống tệp và gọi chúng khi phù hợp với yêu cầu của người dùng.

<CodeGroup>
  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions


  async def main():
      options = ClaudeAgentOptions(
          cwd="/path/to/project",  # Project with .claude/skills/
          setting_sources=["user", "project"],  # Load Skills from filesystem
          skills="all",  # Enable every discovered Skill
          allowed_tools=["Read", "Write", "Bash"],
      )

      async for message in query(
          prompt="Help me process this PDF document", options=options
      ):
          print(message)


  asyncio.run(main())
  ```

  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  for await (const message of query({
    prompt: "Help me process this PDF document",
    options: {
      cwd: "/path/to/project", // Project with .claude/skills/
      settingSources: ["user", "project"], // Load Skills from filesystem
      skills: "all", // Enable every discovered Skill
      allowedTools: ["Read", "Write", "Bash"]
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

Để chỉ bật các Skill cụ thể, hãy truyền tên của chúng. Tên khớp với trường `name` trong `SKILL.md` hoặc tên thư mục của Skill. Dùng `plugin:skill` cho các Skill do plugin cung cấp.

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(skills=["pdf", "docx"])
  ```

  ```typescript TypeScript theme={null}
  const options = { skills: ["pdf", "docx"] };
  ```
</CodeGroup>

Tùy chọn `skills` là một bộ lọc ngữ cảnh, không phải một sandbox. Các Skill không được liệt kê sẽ bị ẩn khỏi model và bị công cụ Skill từ chối, nhưng các file của chúng vẫn nằm trên đĩa và có thể tiếp cận qua Read và Bash.

## Vị trí của Skills

Các Skill được nạp từ các thư mục trên hệ thống tệp dựa trên cấu hình `settingSources`/`setting_sources` của bạn:

* **Skill của dự án** (`.claude/skills/`): Chia sẻ với nhóm của bạn qua git - được nạp khi `setting_sources` bao gồm `"project"`
* **Skill của người dùng** (`~/.claude/skills/`): Skill cá nhân trên tất cả các dự án - được nạp khi `setting_sources` bao gồm `"user"`
* **Skill của plugin**: Đi kèm với các plugin Claude Code đã cài đặt

## Tạo Skills

Các Skill được định nghĩa dưới dạng thư mục chứa một file `SKILL.md` với YAML frontmatter và nội dung Markdown. Trường `description` quyết định thời điểm Claude gọi Skill của bạn.

**Ví dụ cấu trúc thư mục**:

```bash theme={null}
.claude/skills/processing-pdfs/
└── SKILL.md
```

Để có hướng dẫn đầy đủ về tạo Skills, bao gồm cấu trúc SKILL.md, Skill nhiều file và ví dụ, xem:

* [Agent Skills trong Claude Code](/en/skills): Hướng dẫn đầy đủ với ví dụ
* [Thực hành tốt nhất cho Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices): Hướng dẫn viết và quy ước đặt tên

## Hạn chế công cụ

<Note>
  Trường frontmatter `allowed-tools` trong SKILL.md chỉ được hỗ trợ khi dùng Claude Code CLI trực tiếp. **Nó không áp dụng khi dùng Skills thông qua SDK**.

  Khi dùng SDK, hãy kiểm soát quyền truy cập công cụ thông qua tùy chọn `allowedTools` chính trong cấu hình query của bạn.
</Note>

Để kiểm soát quyền truy cập công cụ cho Skills trong các ứng dụng SDK, dùng `allowedTools` để phê duyệt trước các công cụ cụ thể. Khi không có callback `canUseTool`, bất kỳ thứ gì không nằm trong danh sách đều bị từ chối:

<Note>
  Các câu lệnh import từ ví dụ đầu tiên được giả định trong các đoạn code sau đây.
</Note>

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      setting_sources=["user", "project"],  # Load Skills from filesystem
      skills="all",
      allowed_tools=["Read", "Grep", "Glob"],
  )

  async for message in query(prompt="Analyze the codebase structure", options=options):
      print(message)
  ```

  ```typescript TypeScript theme={null}
  for await (const message of query({
    prompt: "Analyze the codebase structure",
    options: {
      settingSources: ["user", "project"], // Load Skills from filesystem
      skills: "all",
      allowedTools: ["Read", "Grep", "Glob"],
      permissionMode: "dontAsk" // Deny anything not in allowedTools
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

## Khám phá các Skill khả dụng

Để xem những Skill nào khả dụng trong ứng dụng SDK của bạn, chỉ cần hỏi Claude:

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      setting_sources=["user", "project"],  # Load Skills from filesystem
      skills="all",
  )

  async for message in query(prompt="What Skills are available?", options=options):
      print(message)
  ```

  ```typescript TypeScript theme={null}
  for await (const message of query({
    prompt: "What Skills are available?",
    options: {
      settingSources: ["user", "project"], // Load Skills from filesystem
      skills: "all"
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

Claude sẽ liệt kê các Skill khả dụng dựa trên thư mục làm việc hiện tại và các plugin đã cài đặt của bạn.

## Kiểm thử Skills

Kiểm thử Skills bằng cách đặt câu hỏi khớp với mô tả của chúng:

<CodeGroup>
  ```python Python theme={null}
  options = ClaudeAgentOptions(
      cwd="/path/to/project",
      setting_sources=["user", "project"],  # Load Skills from filesystem
      skills="all",
      allowed_tools=["Read", "Bash"],
  )

  async for message in query(prompt="Extract text from invoice.pdf", options=options):
      print(message)
  ```

  ```typescript TypeScript theme={null}
  for await (const message of query({
    prompt: "Extract text from invoice.pdf",
    options: {
      cwd: "/path/to/project",
      settingSources: ["user", "project"], // Load Skills from filesystem
      skills: "all",
      allowedTools: ["Read", "Bash"]
    }
  })) {
    console.log(message);
  }
  ```
</CodeGroup>

Claude tự động gọi Skill liên quan nếu mô tả khớp với yêu cầu của bạn.

## Khắc phục sự cố

### Không tìm thấy Skills

**Kiểm tra cấu hình settingSources**: Các Skill được phát hiện thông qua các nguồn thiết lập `user` và `project`. Nếu bạn đặt `settingSources`/`setting_sources` một cách tường minh và bỏ qua các nguồn đó, các skill sẽ không được nạp:

<CodeGroup>
  ```python Python theme={null}
  # Skills not loaded: setting_sources excludes user and project
  options = ClaudeAgentOptions(setting_sources=[], skills="all")

  # Skills loaded: user and project sources included
  options = ClaudeAgentOptions(
      setting_sources=["user", "project"],
      skills="all",
  )
  ```

  ```typescript TypeScript theme={null}
  // Skills not loaded: settingSources excludes user and project
  const options = {
    settingSources: [],
    skills: "all"
  };

  // Skills loaded: user and project sources included
  const options = {
    settingSources: ["user", "project"],
    skills: "all"
  };
  ```
</CodeGroup>

Để biết thêm chi tiết về `settingSources`/`setting_sources`, xem [tham chiếu TypeScript SDK](/en/agent-sdk/typescript#settingsource) hoặc [tham chiếu Python SDK](/en/agent-sdk/python#settingsource).

**Kiểm tra thư mục làm việc**: SDK nạp Skills từ `.claude/skills/` trong tùy chọn `cwd` và trong mọi thư mục cha tính đến gốc kho lưu trữ. Đảm bảo `cwd` trỏ tới hoặc nằm dưới thư mục chứa `.claude/skills/`, trong cùng một kho lưu trữ:

<CodeGroup>
  ```python Python theme={null}
  # Ensure your cwd points to the directory containing .claude/skills/
  options = ClaudeAgentOptions(
      cwd="/path/to/project",  # .claude/skills/ here or in a parent directory
      setting_sources=["user", "project"],  # Loads skills from these sources
      skills="all",
  )
  ```

  ```typescript TypeScript theme={null}
  // Ensure your cwd points to the directory containing .claude/skills/
  const options = {
    cwd: "/path/to/project", // .claude/skills/ here or in a parent directory
    settingSources: ["user", "project"], // Loads skills from these sources
    skills: "all"
  };
  ```
</CodeGroup>

Xem phần "Sử dụng Skills với SDK" ở trên để biết mẫu đầy đủ.

**Xác minh vị trí trên hệ thống tệp**:

```bash theme={null}
# Check project Skills
ls .claude/skills/*/SKILL.md

# Check personal Skills
ls ~/.claude/skills/*/SKILL.md
```

### Skill không được sử dụng

**Kiểm tra tùy chọn `skills`**: Nếu bạn đã truyền một danh sách `skills`, hãy xác nhận tên của skill được bao gồm. Truyền `[]` sẽ tắt tất cả các skill.

**Kiểm tra mô tả**: Đảm bảo nó cụ thể và bao gồm các từ khóa liên quan. Xem [Thực hành tốt nhất cho Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#writing-effective-descriptions) để có hướng dẫn viết mô tả hiệu quả.

### Khắc phục sự cố bổ sung

Để khắc phục sự cố Skills tổng quát (cú pháp YAML, gỡ lỗi, v.v.), xem [phần khắc phục sự cố Skills của Claude Code](/en/skills#troubleshooting).

## Tài liệu liên quan

### Hướng dẫn về Skills

* [Agent Skills trong Claude Code](/en/skills): Hướng dẫn Skills đầy đủ với cách tạo, ví dụ và khắc phục sự cố
* [Tổng quan về Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview): Tổng quan khái niệm, lợi ích và kiến trúc
* [Thực hành tốt nhất cho Agent Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices): Hướng dẫn viết cho các Skill hiệu quả
* [Agent Skills Cookbook](https://platform.claude.com/cookbook/skills-notebooks-01-skills-introduction): Các Skill và template ví dụ

### Tài nguyên SDK

* [Subagent trong SDK](/en/agent-sdk/subagents): Các agent dựa trên hệ thống tệp tương tự với các tùy chọn lập trình
* [Slash Command trong SDK](/en/agent-sdk/slash-commands): Các lệnh do người dùng gọi
* [Tổng quan SDK](/en/agent-sdk/overview): Các khái niệm SDK tổng quát
* [Tham chiếu TypeScript SDK](/en/agent-sdk/typescript): Tài liệu API đầy đủ
* [Tham chiếu Python SDK](/en/agent-sdk/python): Tài liệu API đầy đủ
