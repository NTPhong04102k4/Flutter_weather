> Nguồn: https://code.claude.com/docs/en/output-styles.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Kiểu đầu ra (Output styles)

> Điều chỉnh Claude Code cho các mục đích vượt ra ngoài kỹ thuật phần mềm

Kiểu đầu ra (output style) thay đổi cách Claude phản hồi, chứ không phải những gì Claude biết. Chúng chỉnh sửa system prompt để thiết lập vai trò, giọng điệu và định dạng đầu ra. Hãy dùng một kiểu đầu ra khi bạn liên tục phải nhắc lại cùng một giọng điệu hoặc định dạng ở mỗi lượt, hoặc khi bạn muốn Claude đóng vai một thứ gì đó khác với một kỹ sư phần mềm.

Một kiểu đầu ra tùy chỉnh thêm chỉ dẫn của bạn vào system prompt và cho phép bạn chọn có giữ lại các chỉ dẫn kỹ thuật phần mềm tích hợp sẵn của Claude Code hay không. Hãy giữ chúng khi bạn đang thay đổi cách Claude giao tiếp nhưng vẫn đang viết mã, chẳng hạn luôn trả lời kèm một sơ đồ. Bỏ chúng đi khi Claude hoàn toàn không làm kỹ thuật phần mềm, chẳng hạn như một trợ lý viết lách hay một nhà phân tích dữ liệu.

Đối với các chỉ dẫn về dự án, quy ước hoặc codebase của bạn, hãy dùng [CLAUDE.md](/en/memory) thay thế.

## Các kiểu đầu ra tích hợp sẵn

Kiểu đầu ra **Default** (mặc định) của Claude Code chính là system prompt hiện có, được thiết kế để giúp bạn hoàn thành các tác vụ kỹ thuật phần mềm một cách hiệu quả.

Có thêm ba kiểu đầu ra tích hợp sẵn khác:

* **Proactive**: Claude thực thi ngay lập tức, đưa ra các giả định hợp lý thay vì tạm dừng để hỏi những quyết định thường lệ, và ưu tiên hành động hơn là lập kế hoạch. Đây là chỉ dẫn thực thi tự chủ mạnh hơn so với những gì [chế độ auto](/en/permission-modes#eliminate-prompts-with-auto-mode) áp dụng, và nó hoạt động mà không cần thay đổi chế độ quyền (permission mode) của bạn, nên bạn vẫn thấy các lời nhắc xin quyền trước khi công cụ chạy.

* **Explanatory**: Cung cấp các "Insights" mang tính giáo dục xen kẽ trong khi giúp bạn hoàn thành các tác vụ kỹ thuật phần mềm. Giúp bạn hiểu các lựa chọn triển khai và các mẫu (pattern) trong codebase.

* **Learning**: Chế độ cộng tác, học qua thực hành, nơi Claude không chỉ chia sẻ "Insights" trong lúc viết mã mà còn yêu cầu bạn tự đóng góp những phần mã nhỏ, có tính chiến lược. Claude Code sẽ thêm các dấu `TODO(human)` trong mã của bạn để bạn tự triển khai.

## Thay đổi kiểu đầu ra của bạn

Chạy `/config` và chọn **Output style** để chọn một kiểu từ menu. Lựa chọn của bạn được lưu vào `.claude/settings.local.json` ở [cấp dự án cục bộ](/en/settings).

<Note>{/* max-version: 2.1.90 */}Lệnh độc lập `/output-style` đã bị deprecated (không dùng nữa) trong v2.1.73 và bị loại bỏ trong v2.1.91. Hãy dùng `/config` hoặc chỉnh sửa trực tiếp thiết lập `outputStyle`.</Note>

Để đặt một kiểu mà không cần menu, hãy chỉnh sửa trực tiếp trường `outputStyle` trong một tệp settings:

```json theme={null}
{
  "outputStyle": "Explanatory"
}
```

Kiểu đầu ra là một phần của system prompt, thứ mà Claude Code đọc một lần khi bắt đầu phiên. Các thay đổi có hiệu lực sau khi `/clear` hoặc bắt đầu một phiên mới. Xem [Cách Claude Code sử dụng prompt caching](/en/prompt-caching#changing-output-style) để biết việc thay đổi kiểu đầu ra tác động thế nào đến cache.

## Tạo một kiểu đầu ra tùy chỉnh

Một kiểu đầu ra tùy chỉnh là một tệp Markdown: phần frontmatter cho metadata, sau đó là các chỉ dẫn để thêm vào system prompt.

<Steps>
  <Step title="Tạo một tệp Markdown">
    Lưu tệp ở một trong ba cấp. Tên tệp trở thành tên kiểu trừ khi bạn đặt `name` trong frontmatter.

    * Người dùng: `~/.claude/output-styles`
    * Dự án: `.claude/output-styles`
    * Chính sách được quản lý (managed policy): `.claude/output-styles` bên trong [thư mục settings được quản lý](/en/settings#settings-files)

    Các kiểu đầu ra cấp dự án được nạp từ mọi `.claude/output-styles/` nằm giữa thư mục làm việc và gốc của repository. {/* min-version: 2.1.178 */}Kể từ v2.1.178, khi có nhiều hơn một trong các thư mục lồng nhau này định nghĩa một kiểu cùng tên, Claude Code dùng kiểu gần thư mục làm việc nhất.
  </Step>

  <Step title="Thêm frontmatter và chỉ dẫn">
    Quyết định có giữ lại các chỉ dẫn kỹ thuật phần mềm của Claude Code hay không. Đặt `keep-coding-instructions: true` nếu bạn đang thay đổi cách Claude giao tiếp nhưng vẫn muốn nó viết mã theo cách như cũ. Bỏ trường này đi nếu Claude sẽ không làm kỹ thuật phần mềm.

    Ví dụ này mở đầu mọi lời giải thích bằng một sơ đồ trong khi vẫn giữ nguyên hành vi viết mã của Claude:

    ```markdown theme={null}
    ---
    name: Diagrams first
    description: Lead every explanation with a diagram
    keep-coding-instructions: true
    ---

    When explaining code, architecture, or data flow, start with a Mermaid diagram showing the structure, then explain in prose.

    ## Diagram conventions

    Use `flowchart TD` for control flow and `sequenceDiagram` for request paths. Keep diagrams under 15 nodes.
    ```
  </Step>

  <Step title="Chuyển sang kiểu của bạn">
    Chạy `/config` và chọn kiểu của bạn dưới mục **Output style**. Nó có hiệu lực sau khi `/clear` hoặc lần tiếp theo bạn bắt đầu một phiên.
  </Step>
</Steps>

[Plugin](/en/plugins-reference) cũng có thể cung cấp kèm các kiểu đầu ra trong một thư mục `output-styles/`.

### Frontmatter

Các tệp kiểu đầu ra hỗ trợ các trường frontmatter sau:

| Frontmatter                | Mục đích                                                                                                                                                                                                                                                | Mặc định                |
| :------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------- |
| `name`                     | Tên của kiểu đầu ra, nếu không phải tên tệp                                                                                                                                                                                                             | Kế thừa từ tên tệp      |
| `description`              | Mô tả của kiểu đầu ra, hiển thị trong bộ chọn `/config`                                                                                                                                                                                                | Không có                |
| `keep-coding-instructions` | Giữ lại các chỉ dẫn kỹ thuật phần mềm tích hợp sẵn của Claude Code                                                                                                                                                                                     | `false`                 |
| `force-for-plugin`         | Chỉ dành cho kiểu đầu ra của plugin: tự động áp dụng kiểu này bất cứ khi nào plugin được bật, mà không yêu cầu người dùng phải chọn nó. Ghi đè thiết lập `outputStyle` của người dùng. Nếu nhiều plugin đang bật cùng đặt trường này, Claude Code dùng cái được nạp đầu tiên. | `false`                 |

## Cách các kiểu đầu ra hoạt động

Các kiểu đầu ra chỉnh sửa trực tiếp system prompt của Claude Code.

* Tất cả các kiểu đầu ra đều có các chỉ dẫn tùy chỉnh riêng được thêm vào cuối system prompt.
* Tất cả các kiểu đầu ra đều kích hoạt các lời nhắc để Claude tuân thủ các chỉ dẫn của kiểu đầu ra trong suốt cuộc trò chuyện.
* Các kiểu đầu ra tùy chỉnh sẽ bỏ đi các chỉ dẫn kỹ thuật phần mềm tích hợp sẵn của Claude Code, chẳng hạn cách giới hạn phạm vi thay đổi, viết bình luận (comment), và kiểm chứng công việc, trừ khi `keep-coding-instructions` được đặt là `true`.

Mức sử dụng token phụ thuộc vào kiểu. Việc thêm chỉ dẫn vào system prompt làm tăng số token đầu vào, dù prompt caching giảm chi phí này sau yêu cầu đầu tiên trong một phiên. Các kiểu Explanatory và Learning tích hợp sẵn tạo ra các phản hồi dài hơn so với Default một cách có chủ ý, điều này làm tăng số token đầu ra. Đối với các kiểu tùy chỉnh, mức sử dụng token đầu ra phụ thuộc vào những gì chỉ dẫn của bạn yêu cầu Claude tạo ra.

## So sánh với các tính năng liên quan

Một số tính năng tùy chỉnh cách Claude Code hành xử. Các kiểu đầu ra chỉnh sửa trực tiếp system prompt và áp dụng cho mọi phản hồi. Các tính năng khác thêm chỉ dẫn mà không thay đổi system prompt mặc định, hoặc giới hạn chúng vào một tác vụ cụ thể.

| Tính năng                | Cách hoạt động                                               | Dùng khi                                                                |
| :----------------------- | :---------------------------------------------------------- | :--------------------------------------------------------------------- |
| Kiểu đầu ra (Output styles) | Chỉnh sửa system prompt                                  | Bạn muốn một vai trò, giọng điệu hoặc định dạng phản hồi mặc định khác ở mỗi lượt |
| [CLAUDE.md](/en/memory)  | Thêm một tin nhắn người dùng sau system prompt              | Claude luôn cần biết các quy ước dự án và ngữ cảnh codebase của bạn    |
| `--append-system-prompt` | Nối thêm vào system prompt mà không loại bỏ bất cứ điều gì  | Bạn muốn một bổ sung một lần cho một lần gọi duy nhất                  |
| [Agent](/en/sub-agents)  | Chạy một subagent với system prompt, mô hình và công cụ riêng | Bạn muốn một trợ thủ được giới hạn riêng cho một tác vụ tập trung    |
| [Skill](/en/skills)      | Nạp các chỉ dẫn theo tác vụ khi được gọi hoặc khi phù hợp   | Bạn có một quy trình làm việc tái sử dụng được                        |

## Tài nguyên liên quan

* [Settings](/en/settings): nơi trường `outputStyle` nằm và cách hoạt động của thứ tự ưu tiên trong settings
* [Chế độ quyền (Permission modes)](/en/permission-modes): cách kiểu Proactive so sánh với chế độ auto
* [Plugin](/en/plugins): đóng gói và phân phối các kiểu đầu ra cùng với skill, hook và agent
* [Gỡ lỗi cấu hình của bạn](/en/debug-your-config): chẩn đoán vì sao một kiểu đầu ra không có hiệu lực
