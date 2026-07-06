> Nguồn: https://code.claude.com/docs/en/plugins.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tạo plugin

> Tạo các plugin tùy chỉnh để mở rộng Claude Code với skill, agent, hook và MCP server.

Plugin cho phép bạn mở rộng Claude Code với chức năng tùy chỉnh, có thể chia sẻ giữa các dự án và nhóm. Hướng dẫn này trình bày cách tạo plugin của riêng bạn với skill, agent, hook và MCP server.

Bạn muốn cài đặt các plugin có sẵn? Xem [Khám phá và cài đặt plugin](/en/discover-plugins). Để biết đặc tả kỹ thuật đầy đủ, xem [Tài liệu tham chiếu Plugin](/en/plugins-reference).

## Khi nào dùng plugin so với cấu hình độc lập

Claude Code hỗ trợ hai cách để thêm skill, agent và hook tùy chỉnh:

| Cách tiếp cận                                                                                                        | Tên skill          | Phù hợp nhất cho                                                                                        |
| :-------------------------------------------------------------------------------------------------------------- | :------------------- | :---------------------------------------------------------------------------------------------- |
| **Độc lập** (thư mục `.claude/`)                                                                           | `/hello`             | Quy trình cá nhân, tùy chỉnh riêng cho dự án, thử nghiệm nhanh                          |
| **Plugin** (thư mục tự chứa với skill, agent, hook, hoặc một manifest `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Chia sẻ với đồng đội, phân phối cho cộng đồng, phát hành có phiên bản, tái sử dụng qua nhiều dự án |

**Dùng cấu hình độc lập khi**:

* Bạn đang tùy chỉnh Claude Code cho một dự án duy nhất
* Cấu hình mang tính cá nhân và không cần chia sẻ
* Bạn đang thử nghiệm với skill hoặc hook trước khi đóng gói chúng
* Bạn muốn tên skill ngắn như `/hello` hoặc `/deploy`

**Dùng plugin khi**:

* Bạn muốn chia sẻ chức năng với nhóm hoặc cộng đồng của mình
* Bạn cần cùng một tập skill/agent trên nhiều dự án
* Bạn muốn quản lý phiên bản và cập nhật dễ dàng cho các phần mở rộng
* Bạn đang phân phối qua một marketplace
* Bạn chấp nhận skill có namespace như `/my-plugin:hello` (việc gắn namespace ngăn xung đột giữa các plugin)

<Tip>
  Hãy bắt đầu với cấu hình độc lập trong `.claude/` để lặp lại nhanh, rồi [chuyển đổi sang plugin](#convert-existing-configurations-to-plugins) khi bạn sẵn sàng chia sẻ.
</Tip>

## Bắt đầu nhanh

Phần bắt đầu nhanh này hướng dẫn bạn tạo một plugin với một skill tùy chỉnh. Bạn sẽ tạo một manifest (tệp cấu hình định nghĩa plugin của bạn), thêm một skill, và kiểm thử nó cục bộ bằng cờ `--plugin-dir`.

### Điều kiện tiên quyết

* Claude Code đã [cài đặt và xác thực](/en/quickstart#step-1-install-claude-code)

<Note>
  Nếu bạn không thấy lệnh `/plugin`, hãy cập nhật Claude Code lên phiên bản mới nhất. Xem [Khắc phục sự cố](/en/troubleshooting) để biết hướng dẫn nâng cấp.
</Note>

### Tạo plugin đầu tiên của bạn

<Steps>
  <Step title="Tạo thư mục plugin">
    Mỗi plugin nằm trong thư mục riêng của nó, chứa các skill, agent hoặc hook, có thể kèm theo một manifest `.claude-plugin/plugin.json` (tùy chọn). Vị trí không quan trọng đối với phần bắt đầu nhanh này vì bạn sẽ trỏ Claude Code tới thư mục bằng `--plugin-dir` ở bước kiểm thử. Hãy tạo nó ở bất kỳ nơi thuận tiện nào, chẳng hạn thư mục nháp hoặc thư mục dự án:

    ```bash theme={null}
    mkdir my-first-plugin
    ```

    Các bước còn lại chạy từ thư mục cha và tham chiếu các đường dẫn như `my-first-plugin/...` tương đối so với nó.
  </Step>

  <Step title="Tạo manifest của plugin">
    Tệp manifest tại `.claude-plugin/plugin.json` định nghĩa danh tính của plugin: tên, mô tả và phiên bản. Claude Code dùng metadata này để hiển thị plugin của bạn trong trình quản lý plugin.

    Tạo thư mục `.claude-plugin` bên trong thư mục plugin của bạn:

    ```bash theme={null}
    mkdir my-first-plugin/.claude-plugin
    ```

    Sau đó tạo `my-first-plugin/.claude-plugin/plugin.json` với nội dung này:

    ```json my-first-plugin/.claude-plugin/plugin.json theme={null}
    {
      "name": "my-first-plugin",
      "description": "A greeting plugin to learn the basics",
      "version": "1.0.0",
      "author": {
        "name": "Your Name"
      }
    }
    ```

    | Trường         | Mục đích                                                                                                                                                                                                                                                        |
    | :------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `name`        | Định danh duy nhất và namespace của skill. Skill được thêm tiền tố này (ví dụ, `/my-first-plugin:hello`).                                                                                                                                                         |
    | `description` | Hiển thị trong trình quản lý plugin khi duyệt hoặc cài đặt plugin.                                                                                                                                                                                               |
    | `version`     | Tùy chọn. Nếu được đặt, người dùng chỉ nhận cập nhật khi bạn tăng trường này. Nếu bỏ trống và plugin của bạn được phân phối qua git, commit SHA sẽ được dùng và mỗi commit được tính là một phiên bản mới. Xem [quản lý phiên bản](/en/plugins-reference#version-management). |
    | `author`      | Tùy chọn. Hữu ích cho việc ghi công.                                                                                                                                                                                                                              |

    Về các trường bổ sung như `homepage`, `repository` và `license`, xem [lược đồ manifest đầy đủ](/en/plugins-reference#plugin-manifest-schema).
  </Step>

  <Step title="Thêm một skill">
    Skill nằm trong thư mục `skills/`. Mỗi skill là một thư mục chứa tệp `SKILL.md`. Tên thư mục trở thành tên skill, được thêm tiền tố namespace của plugin (`hello/` trong plugin tên `my-first-plugin` tạo ra `/my-first-plugin:hello`).

    Tạo một thư mục skill trong thư mục plugin của bạn:

    ```bash theme={null}
    mkdir -p my-first-plugin/skills/hello
    ```

    Sau đó tạo `my-first-plugin/skills/hello/SKILL.md` với nội dung này:

    ```markdown my-first-plugin/skills/hello/SKILL.md theme={null}
    ---
    description: Greet the user with a friendly message
    disable-model-invocation: true
    ---

    Greet the user warmly and ask how you can help them today.
    ```
  </Step>

  <Step title="Kiểm thử plugin của bạn">
    Chạy Claude Code với cờ `--plugin-dir` để tải plugin của bạn:

    ```bash theme={null}
    claude --plugin-dir ./my-first-plugin
    ```

    Sau khi Claude Code khởi động, hãy thử skill mới của bạn:

    ```shell theme={null}
    /my-first-plugin:hello
    ```

    Bạn sẽ thấy Claude phản hồi bằng một lời chào. Chạy `/help` để thấy skill của bạn được liệt kê dưới namespace của plugin.

    <Note>
      **Tại sao lại gắn namespace?** Skill của plugin luôn được gắn namespace (như `/my-first-plugin:hello`) để ngăn xung đột khi nhiều plugin có skill cùng tên.

      Để thay đổi tiền tố namespace, cập nhật trường `name` trong `plugin.json`.
    </Note>
  </Step>

  <Step title="Thêm đối số cho skill">
    Làm cho skill của bạn động bằng cách chấp nhận đầu vào từ người dùng. Placeholder `$ARGUMENTS` bắt lấy bất kỳ văn bản nào người dùng cung cấp sau tên skill.

    Cập nhật tệp `SKILL.md` của bạn:

    ```markdown my-first-plugin/skills/hello/SKILL.md theme={null}
    ---
    description: Greet the user with a personalized message
    ---

    # Hello Skill

    Greet the user named "$ARGUMENTS" warmly and ask how you can help them today. Make the greeting personal and encouraging.
    ```

    Chạy `/reload-plugins` để nhận các thay đổi, rồi thử skill với tên của bạn:

    ```shell theme={null}
    /my-first-plugin:hello Alex
    ```

    Claude sẽ chào bạn bằng tên. Để biết thêm về việc truyền đối số cho skill, xem [Skills](/en/skills#pass-arguments-to-skills).
  </Step>
</Steps>

Bạn đã tạo và kiểm thử thành công một plugin với các thành phần chính này:

* **Manifest của plugin** (`.claude-plugin/plugin.json`): mô tả metadata của plugin
* **Thư mục skill** (`skills/`): chứa các skill tùy chỉnh của bạn
* **Đối số của skill** (`$ARGUMENTS`): bắt lấy đầu vào của người dùng cho hành vi động

<Tip>
  Cờ `--plugin-dir` hữu ích cho việc phát triển và kiểm thử. Khi bạn sẵn sàng chia sẻ plugin của mình với người khác, xem [Tạo và phân phối một marketplace plugin](/en/plugin-marketplaces).
</Tip>

## Phát triển plugin trong thư mục skills của bạn

Thay vì truyền `--plugin-dir` mỗi lần khởi động, bạn có thể giữ một plugin trong thư mục skills của mình và để Claude Code tải nó tự động. `claude plugin init` sẽ tạo khung sườn cho một plugin như vậy:

```bash theme={null}
claude plugin init my-tool
```

Lệnh này tạo `~/.claude/skills/my-tool/` với một manifest `.claude-plugin/plugin.json` và một `SKILL.md` khởi đầu. Ở phiên tiếp theo, nó tải dưới dạng `my-tool@skills-dir` mà không cần marketplace hay bước cài đặt.

Về quy tắc tự động tải, phạm vi cá nhân so với phạm vi dự án, yêu cầu tin cậy workspace, và cách cập nhật hoặc gỡ bỏ một plugin như vậy, xem [Plugin trong thư mục skills](/en/plugins-reference#skills-directory-plugins).

## Tổng quan cấu trúc plugin

Bạn đã tạo một plugin với một skill, nhưng plugin có thể bao gồm nhiều hơn thế: agent tùy chỉnh, hook, MCP server, LSP server, và monitor chạy nền.

<Warning>
  **Lỗi thường gặp**: Đừng đặt `commands/`, `agents/`, `skills/`, hoặc `hooks/` bên trong thư mục `.claude-plugin/`. Chỉ có `plugin.json` nằm bên trong `.claude-plugin/`. Tất cả các thư mục khác phải nằm ở cấp gốc của plugin.
</Warning>

| Thư mục         | Vị trí    | Mục đích                                                                        |
| :---------------- | :---------- | :----------------------------------------------------------------------------- |
| `.claude-plugin/` | Gốc plugin | Chứa manifest `plugin.json` (tùy chọn nếu các thành phần dùng vị trí mặc định) |
| `skills/`         | Gốc plugin | Skill dưới dạng thư mục `<name>/SKILL.md`                                        |
| `commands/`       | Gốc plugin | Skill dưới dạng tệp Markdown phẳng. Dùng `skills/` cho plugin mới                   |
| `agents/`         | Gốc plugin | Định nghĩa agent tùy chỉnh                                                 |
| `hooks/`          | Gốc plugin | Bộ xử lý sự kiện trong `hooks.json`                                                       |
| `.mcp.json`       | Gốc plugin | Cấu hình MCP server                                              |
| `.lsp.json`       | Gốc plugin | Cấu hình LSP server cho trí tuệ mã nguồn (code intelligence)                                |
| `monitors/`       | Gốc plugin | Cấu hình monitor chạy nền trong `monitors.json`                           |
| `bin/`            | Gốc plugin | Các tệp thực thi được thêm vào `PATH` của công cụ Bash khi plugin được bật        |
| `settings.json`   | Gốc plugin | [Cài đặt](/en/settings) mặc định được áp dụng khi plugin được bật            |

Một plugin chỉ chứa đúng một skill có thể đặt `SKILL.md` trực tiếp ở gốc plugin thay vì tạo thư mục `skills/`. Claude Code tải nó như một skill đơn lẻ và dùng trường `name` trong frontmatter làm tên gọi. Hãy dùng bố cục `skills/` cho các plugin có thể phát triển thành nhiều hơn một skill.

<Note>
  **Bước tiếp theo**: Sẵn sàng thêm nhiều tính năng hơn? Chuyển đến [Phát triển các plugin phức tạp hơn](#develop-more-complex-plugins) để thêm agent, hook, MCP server và LSP server. Để biết đặc tả kỹ thuật đầy đủ của tất cả thành phần plugin, xem [Tài liệu tham chiếu Plugin](/en/plugins-reference).
</Note>

## Phát triển các plugin phức tạp hơn

Một khi bạn đã quen với plugin cơ bản, bạn có thể tạo các phần mở rộng tinh vi hơn.

### Thêm Skill vào plugin của bạn

Plugin có thể bao gồm [Agent Skills](/en/skills) để mở rộng khả năng của Claude. Skill được gọi bởi mô hình (model-invoked): Claude tự động dùng chúng dựa trên ngữ cảnh của tác vụ.

Thêm một thư mục `skills/` ở gốc plugin với các thư mục Skill chứa tệp `SKILL.md`:

```text theme={null}
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── code-review/
        └── SKILL.md
```

Mỗi `SKILL.md` chứa YAML frontmatter và các chỉ dẫn. Hãy kèm một `description` để Claude biết khi nào dùng skill:

```yaml theme={null}
---
description: Reviews code for best practices and potential issues. Use when reviewing code, checking PRs, or analyzing code quality.
---

When reviewing code, check for:
1. Code organization and structure
2. Error handling
3. Security concerns
4. Test coverage
```

Sau khi cài đặt plugin, chạy `/reload-plugins` để tải các Skill. Để biết hướng dẫn viết Skill đầy đủ bao gồm tiết lộ dần dần (progressive disclosure) và giới hạn công cụ, xem [Agent Skills](/en/skills).

### Thêm LSP server vào plugin của bạn

<Tip>
  Đối với các ngôn ngữ phổ biến như TypeScript, Python và Rust, hãy cài đặt các plugin LSP dựng sẵn từ marketplace chính thức. Chỉ tạo plugin LSP tùy chỉnh khi bạn cần hỗ trợ những ngôn ngữ chưa được bao phủ.
</Tip>

Plugin LSP (Language Server Protocol) mang lại cho Claude trí tuệ mã nguồn theo thời gian thực. Nếu bạn cần hỗ trợ một ngôn ngữ chưa có plugin LSP chính thức, bạn có thể tạo riêng bằng cách thêm tệp `.lsp.json` vào plugin của bạn:

```json .lsp.json theme={null}
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

Người dùng cài đặt plugin của bạn phải có sẵn binary của language server trên máy của họ.

Để biết đầy đủ tùy chọn cấu hình LSP, xem [LSP servers](/en/plugins-reference#lsp-servers).

### Thêm monitor chạy nền vào plugin của bạn

Monitor chạy nền cho phép plugin của bạn theo dõi log, tệp hoặc trạng thái bên ngoài ở chế độ nền và thông báo cho Claude khi các sự kiện xảy đến. Claude Code khởi động mỗi monitor tự động khi plugin đang hoạt động, nên bạn không cần chỉ dẫn Claude bắt đầu theo dõi.

Thêm tệp `monitors/monitors.json` ở gốc plugin với một mảng các mục monitor:

```json monitors/monitors.json theme={null}
[
  {
    "name": "error-log",
    "command": "tail -F ./logs/error.log",
    "description": "Application error log"
  }
]
```

Mỗi dòng stdout từ `command` được gửi tới Claude dưới dạng một thông báo trong phiên. Để biết lược đồ đầy đủ, bao gồm trình kích hoạt `when` và thay thế biến, xem [Monitors](/en/plugins-reference#monitors).

### Đóng gói cài đặt mặc định cùng plugin của bạn

Plugin có thể bao gồm một tệp `settings.json` ở gốc plugin để áp dụng cấu hình mặc định khi plugin được bật. Hiện tại, chỉ hỗ trợ các khóa `agent` và `subagentStatusLine`.

Đặt `agent` sẽ kích hoạt một trong các [agent tùy chỉnh](/en/sub-agents) của plugin làm luồng chính (main thread), áp dụng system prompt, giới hạn công cụ và mô hình của agent đó. Điều này cho phép một plugin thay đổi hành vi mặc định của Claude Code khi được bật.

```json settings.json theme={null}
{
  "agent": "security-reviewer"
}
```

Ví dụ này kích hoạt agent `security-reviewer` được định nghĩa trong thư mục `agents/` của plugin. Cài đặt từ `settings.json` có ưu tiên cao hơn `settings` được khai báo trong `plugin.json`. Các khóa không xác định bị bỏ qua âm thầm.

### Tổ chức các plugin phức tạp

Đối với plugin có nhiều thành phần, hãy tổ chức cấu trúc thư mục theo chức năng. Để biết đầy đủ bố cục thư mục và mẫu tổ chức, xem [Cấu trúc thư mục plugin](/en/plugins-reference#plugin-directory-structure).

### Kiểm thử plugin của bạn cục bộ

Dùng cờ `--plugin-dir` để kiểm thử plugin trong quá trình phát triển. Cờ này tải plugin của bạn trực tiếp mà không cần cài đặt.

```bash theme={null}
claude --plugin-dir ./my-plugin
```

Cờ này cũng chấp nhận một tệp lưu trữ `.zip` của thư mục plugin, yêu cầu Claude Code v2.1.128 trở lên.

```bash theme={null}
claude --plugin-dir ./my-plugin.zip
```

Khi một plugin `--plugin-dir` có cùng tên với một plugin marketplace đã cài đặt, bản sao cục bộ sẽ được ưu tiên cho phiên đó. Điều này cho phép bạn kiểm thử các thay đổi đối với một plugin bạn đã cài mà không cần gỡ nó trước. Ngoại lệ là các plugin mà cài đặt được quản lý (managed settings) buộc-bật hoặc buộc-tắt: `--plugin-dir` không thể ghi đè lên chúng.

Khi bạn thực hiện thay đổi đối với plugin, chạy `/reload-plugins` để nhận các cập nhật mà không cần khởi động lại. Lệnh này tải lại plugin, skill, agent, hook, MCP server của plugin và LSP server của plugin. Hãy kiểm thử các thành phần plugin của bạn:

* Thử các skill của bạn với `/plugin-name:skill-name`
* Kiểm tra xem agent có xuất hiện trong `/context` dưới mục Custom Agents không, hoặc @-mention một agent bằng tên có phạm vi (scoped name) của nó
* Xác minh hook hoạt động như mong đợi

<Tip>
  Bạn có thể tải nhiều plugin cùng lúc bằng cách chỉ định cờ nhiều lần:

  ```bash theme={null}
  claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
  ```
</Tip>

Để kiểm thử một plugin đã được đóng gói dưới dạng tệp lưu trữ `.zip` và được lưu tại một URL, chẳng hạn một artifact build CI, dùng `--plugin-url` thay thế. Claude Code tải tệp lưu trữ khi khởi động và nạp nó chỉ cho phiên đó. Nếu việc tải thất bại hoặc tệp lưu trữ không hợp lệ, Claude Code báo lỗi tải plugin và khởi động mà không có nó. Vẫn áp dụng cùng [cân nhắc về tin cậy](/en/discover-plugins#security) như với bất kỳ nguồn plugin nào: chỉ trỏ cờ này tới các tệp lưu trữ bạn kiểm soát hoặc tin tưởng.

Để tải nhiều plugin, lặp lại cờ cho mỗi URL:

```bash theme={null}
claude --plugin-url https://example.com/my-plugin.zip --plugin-url https://example.com/other.zip
```

Hoặc truyền các URL cách nhau bởi khoảng trắng dưới dạng một đối số được đặt trong dấu ngoặc kép:

```bash theme={null}
claude --plugin-url "https://example.com/my-plugin.zip https://example.com/other.zip"
```

### Gỡ lỗi các vấn đề của plugin

Nếu plugin của bạn không hoạt động như mong đợi:

1. **Kiểm tra cấu trúc**: Đảm bảo các thư mục của bạn nằm ở gốc plugin, không phải bên trong `.claude-plugin/`
2. **Kiểm thử từng thành phần riêng lẻ**: Kiểm tra riêng từng skill, agent và hook
3. **Dùng công cụ xác thực và gỡ lỗi**: Xem [Công cụ gỡ lỗi và phát triển](/en/plugins-reference#debugging-and-development-tools) để biết các lệnh CLI và kỹ thuật khắc phục sự cố

### Chia sẻ plugin của bạn

Khi plugin của bạn đã sẵn sàng chia sẻ:

1. **Thêm tài liệu**: Kèm một `README.md` với hướng dẫn cài đặt và sử dụng
2. **Chọn chiến lược quản lý phiên bản**: Quyết định đặt `version` rõ ràng hay dựa vào git commit SHA. Xem [quản lý phiên bản](/en/plugins-reference#version-management)
3. **Tạo hoặc dùng một marketplace**: Phân phối qua [marketplace plugin](/en/plugin-marketplaces) để cài đặt
4. **Kiểm thử với người khác**: Cho các thành viên nhóm kiểm thử plugin trước khi phân phối rộng rãi hơn

Một khi plugin của bạn nằm trong một marketplace, người khác có thể cài đặt nó bằng các hướng dẫn trong [Khám phá và cài đặt plugin](/en/discover-plugins). Để giữ một plugin nội bộ cho nhóm của bạn, hãy lưu marketplace trong một [kho lưu trữ riêng tư (private repository)](/en/plugin-marketplaces#private-repositories).

### Gửi plugin của bạn tới marketplace cộng đồng

Anthropic duy trì hai marketplace công khai cho plugin Claude Code:

* **`claude-plugins-official`**: một tập plugin được tuyển chọn do Anthropic duy trì. Được đăng ký tự động vào lần đầu tiên bạn khởi động Claude Code ở chế độ tương tác. Một kịch bản không tương tác chạy trước lần khởi động đầu tiên đó phải thêm nó một cách tường minh bằng `claude plugin marketplace add anthropics/claude-plugins-official`.
* **`claude-community`**: marketplace cộng đồng công khai nơi các đề xuất từ bên thứ ba xuất hiện sau khi được xét duyệt. Người dùng thêm nó với `/plugin marketplace add anthropics/claude-plugins-community` và cài đặt từ đó dưới dạng `@claude-community`.

Để gửi plugin của bạn cho quá trình xét duyệt marketplace cộng đồng, dùng một trong các biểu mẫu trong ứng dụng:

* **claude.ai**: [claude.ai/admin-settings/directory/submissions/plugins/new](https://claude.ai/admin-settings/directory/submissions/plugins/new)
* **Console**: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

Biểu mẫu claude.ai yêu cầu một tổ chức Team hoặc Enterprise và quyền quản lý danh mục (directory management access); Chủ sở hữu (Owners) của tổ chức có quyền này theo mặc định. Các tác giả cá nhân không thuộc một tổ chức Team hoặc Enterprise có thể dùng biểu mẫu Console thay thế.

Chạy `claude plugin validate` cục bộ trước khi bạn gửi. Quy trình xét duyệt chạy cùng phép kiểm tra đó trên mỗi lần gửi, cùng với sàng lọc an toàn tự động.

Các plugin được phê duyệt được ghim vào một commit SHA cụ thể trong catalog [`anthropics/claude-plugins-community`](https://github.com/anthropics/claude-plugins-community), và CI tự động cập nhật con ghim khi bạn đẩy các commit mới lên kho lưu trữ của mình. Catalog công khai đồng bộ hằng đêm từ quy trình xét duyệt, nên có thể có độ trễ giữa lúc phê duyệt và lúc plugin của bạn xuất hiện trong `marketplace.json`. Để kiểm tra xem plugin của bạn đã có thể cài đặt hay chưa, hãy tìm tên của nó trong [catalog cộng đồng](https://github.com/anthropics/claude-plugins-community/blob/main/.claude-plugin/marketplace.json).

Marketplace chính thức, `claude-plugins-official`, được tuyển chọn riêng biệt. Anthropic quyết định plugin nào được đưa vào theo toàn quyền của mình. Không có quy trình đăng ký, và biểu mẫu gửi không thêm plugin vào marketplace chính thức.

Nếu Anthropic liệt kê plugin của bạn trong marketplace chính thức, CLI của bạn có thể nhắc người dùng Claude Code cài đặt nó. Xem [Đề xuất plugin của bạn từ CLI của bạn](/en/plugin-hints).

<Note>
  Để biết đặc tả kỹ thuật đầy đủ, kỹ thuật gỡ lỗi và chiến lược phân phối, xem [Tài liệu tham chiếu Plugin](/en/plugins-reference).
</Note>

## Chuyển đổi cấu hình hiện có thành plugin

Nếu bạn đã có skill hoặc hook trong thư mục `.claude/` của mình, bạn có thể chuyển đổi chúng thành một plugin để chia sẻ và phân phối dễ dàng hơn.

### Các bước di chuyển (migration)

<Steps>
  <Step title="Tạo cấu trúc plugin">
    Tạo một thư mục plugin mới ở gốc dự án, bên cạnh thư mục `.claude/` hiện có, để các đường dẫn `cp` tương đối ở bước tiếp theo phân giải được:

    ```bash theme={null}
    mkdir -p my-plugin/.claude-plugin
    ```

    Tạo tệp manifest tại `my-plugin/.claude-plugin/plugin.json`:

    ```json my-plugin/.claude-plugin/plugin.json theme={null}
    {
      "name": "my-plugin",
      "description": "Migrated from standalone configuration",
      "version": "1.0.0"
    }
    ```
  </Step>

  <Step title="Sao chép các tệp hiện có của bạn">
    Sao chép các cấu hình hiện có của bạn sang thư mục plugin:

    ```bash theme={null}
    # Copy commands
    cp -r .claude/commands my-plugin/

    # Copy agents (if any)
    cp -r .claude/agents my-plugin/

    # Copy skills (if any)
    cp -r .claude/skills my-plugin/
    ```
  </Step>

  <Step title="Di chuyển hook">
    Nếu bạn có hook trong cài đặt của mình, tạo một thư mục hooks:

    ```bash theme={null}
    mkdir my-plugin/hooks
    ```

    Tạo `my-plugin/hooks/hooks.json` với cấu hình hook của bạn. Sao chép đối tượng `hooks` từ `.claude/settings.json` hoặc `settings.local.json` của bạn, vì định dạng giống nhau. Lệnh nhận đầu vào hook dưới dạng JSON trên stdin, nên hãy dùng `jq` để trích xuất đường dẫn tệp:

    ```json my-plugin/hooks/hooks.json theme={null}
    {
      "hooks": {
        "PostToolUse": [
          {
            "matcher": "Write|Edit",
            "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix" }]
          }
        ]
      }
    }
    ```
  </Step>

  <Step title="Kiểm thử plugin đã di chuyển của bạn">
    Tải plugin của bạn để xác minh mọi thứ hoạt động:

    ```bash theme={null}
    claude --plugin-dir ./my-plugin
    ```

    Kiểm thử từng thành phần: chạy các lệnh của bạn, kiểm tra agent xuất hiện trong `/context`, và xác minh hook kích hoạt đúng.
  </Step>
</Steps>

### Những gì thay đổi khi di chuyển

| Độc lập (`.claude/`)       | Plugin                           |
| :---------------------------- | :------------------------------- |
| Chỉ khả dụng trong một dự án | Có thể chia sẻ qua marketplace   |
| Tệp trong `.claude/commands/`  | Tệp trong `plugin-name/commands/` |
| Hook trong `settings.json`      | Hook trong `hooks/hooks.json`      |
| Phải sao chép thủ công để chia sẻ   | Cài đặt với `/plugin install`   |

<Note>
  Sau khi di chuyển, hãy xóa các tệp gốc khỏi `.claude/` để tránh trùng lặp. Các định nghĩa agent trong `.claude/agents/` của dự án và người dùng ghi đè lên các agent plugin cùng tên, nên phiên bản plugin chỉ có hiệu lực khi các bản gốc đã bị gỡ bỏ.
</Note>

## Bước tiếp theo

Giờ khi bạn đã hiểu hệ thống plugin của Claude Code, đây là các hướng đi đề xuất cho các mục tiêu khác nhau:

### Dành cho người dùng plugin

* [Khám phá và cài đặt plugin](/en/discover-plugins): duyệt marketplace và cài đặt plugin
* [Cấu hình marketplace cho nhóm](/en/discover-plugins#configure-team-marketplaces): thiết lập plugin ở cấp kho lưu trữ cho nhóm của bạn

### Dành cho nhà phát triển plugin

* [Tạo và phân phối một marketplace](/en/plugin-marketplaces): đóng gói và chia sẻ plugin của bạn
* [Tài liệu tham chiếu Plugin](/en/plugins-reference): đặc tả kỹ thuật đầy đủ
* Tìm hiểu sâu hơn về các thành phần plugin cụ thể:
  * [Skills](/en/skills): chi tiết phát triển skill
  * [Subagents](/en/sub-agents): cấu hình và khả năng của agent
  * [Hooks](/en/hooks): xử lý sự kiện và tự động hóa
  * [MCP](/en/mcp): tích hợp công cụ bên ngoài
