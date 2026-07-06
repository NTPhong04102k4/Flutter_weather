> Nguồn: https://code.claude.com/docs/en/quickstart.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bắt đầu nhanh

> Chào mừng bạn đến với Claude Code!

Hướng dẫn bắt đầu nhanh này sẽ giúp bạn sử dụng trợ lý lập trình dựa trên AI chỉ trong vài phút. Đến cuối hướng dẫn, bạn sẽ hiểu cách dùng Claude Code cho các tác vụ phát triển phần mềm phổ biến.

## Trước khi bắt đầu

Hãy chắc chắn rằng bạn có:

* Một cửa sổ terminal hoặc dòng lệnh (command prompt) đang mở
  * Nếu bạn chưa từng dùng terminal, hãy xem [hướng dẫn về terminal](/en/terminal-guide)
* Một dự án mã nguồn để làm việc cùng
* Một [gói đăng ký Claude](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=quickstart_prereq) (Pro, Max, Team hoặc Enterprise), tài khoản [Claude Console](https://console.anthropic.com/), hoặc truy cập thông qua một [nhà cung cấp đám mây được hỗ trợ](/en/third-party-integrations)

<Note>
  Hướng dẫn này bao gồm CLI trên terminal. Claude Code cũng có sẵn trên [web](https://claude.ai/code), dưới dạng [ứng dụng desktop](/en/desktop), trong [VS Code](/en/vs-code) và [các IDE JetBrains](/en/jetbrains), trong [Slack](/en/slack), và trong CI/CD với [GitHub Actions](/en/github-actions) và [GitLab](/en/gitlab-ci-cd). Xem [tất cả các giao diện](/en/overview#use-claude-code-everywhere).
</Note>

## Bước 1: Cài đặt Claude Code

Để cài đặt Claude Code, hãy dùng một trong các phương pháp sau:

<Tabs>
  <Tab title="Cài đặt Native (Khuyến nghị)">
    **macOS, Linux, WSL:**

    ```bash theme={null}
    curl -fsSL https://claude.ai/install.sh | bash
    ```

    **Windows PowerShell:**

    ```powershell theme={null}
    irm https://claude.ai/install.ps1 | iex
    ```

    **Windows CMD:**

    ```batch theme={null}
    curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
    ```

    Nếu bạn thấy `The token '&&' is not a valid statement separator`, nghĩa là bạn đang ở PowerShell chứ không phải CMD. Nếu bạn thấy `'irm' is not recognized as an internal or external command`, nghĩa là bạn đang ở CMD chứ không phải PowerShell. Dấu nhắc lệnh của bạn hiển thị `PS C:\` khi bạn ở PowerShell và `C:\` không có `PS` khi bạn ở CMD.

    Nếu lệnh cài đặt thất bại với `syntax error near unexpected token '<'`, lỗi `403`, hoặc lỗi curl khác, hãy xem [Khắc phục sự cố cài đặt](/en/troubleshoot-install#find-your-error) để đối chiếu lỗi với cách khắc phục và tìm các phương pháp cài đặt thay thế.

    [Git for Windows](https://git-scm.com/downloads/win) được khuyến nghị trên Windows native để Claude Code có thể dùng công cụ Bash. Nếu Git for Windows chưa được cài đặt, Claude Code sẽ dùng PowerShell làm công cụ shell thay thế. Các thiết lập WSL không cần Git for Windows.

    <Info>
      Các bản cài đặt native tự động cập nhật trong nền để giữ bạn luôn ở phiên bản mới nhất.
    </Info>
  </Tab>

  <Tab title="Homebrew">
    ```bash theme={null}
    brew install --cask claude-code
    ```

    Homebrew cung cấp hai cask. `claude-code` bám theo kênh phát hành ổn định (stable), thường chậm hơn khoảng một tuần và bỏ qua các bản phát hành có lỗi hồi quy nghiêm trọng. `claude-code@latest` bám theo kênh mới nhất (latest) và nhận các phiên bản mới ngay khi chúng được phát hành.

    <Info>
      Các bản cài đặt qua Homebrew không tự động cập nhật. Chạy `brew upgrade claude-code` hoặc `brew upgrade claude-code@latest`, tùy theo cask bạn đã cài, để nhận các tính năng và bản vá bảo mật mới nhất.
    </Info>
  </Tab>

  <Tab title="WinGet">
    ```powershell theme={null}
    winget install Anthropic.ClaudeCode
    ```

    <Info>
      Các bản cài đặt qua WinGet không tự động cập nhật. Chạy `winget upgrade Anthropic.ClaudeCode` định kỳ để nhận các tính năng và bản vá bảo mật mới nhất.
    </Info>
  </Tab>
</Tabs>

Bạn cũng có thể cài đặt bằng [apt, dnf hoặc apk](/en/setup#install-with-linux-package-managers) trên Debian, Fedora, RHEL và Alpine.

## Bước 2: Đăng nhập vào tài khoản của bạn

Claude Code yêu cầu một tài khoản để sử dụng. Bắt đầu một phiên tương tác bằng lệnh `claude` và bạn sẽ được nhắc đăng nhập trong lần dùng đầu tiên:

```bash theme={null}
claude
```

Với tài khoản đăng ký Claude hoặc Console, hãy làm theo các bước nhắc để hoàn tất xác thực trong trình duyệt. Để chuyển tài khoản sau này hoặc xác thực lại, gõ `/login` bên trong phiên đang chạy:

```text theme={null}
/login
```

Bạn có thể đăng nhập bằng bất kỳ loại tài khoản nào sau đây:

* [Claude Pro, Max, Team hoặc Enterprise](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=quickstart_login) (khuyến nghị)
* [Claude Console](https://console.anthropic.com/) (truy cập API với tín dụng trả trước). Trong lần đăng nhập đầu tiên, một workspace "Claude Code" được tự động tạo trong Console để theo dõi chi phí tập trung.
* [Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry](/en/third-party-integrations) (các nhà cung cấp đám mây doanh nghiệp)
* Một [Claude apps gateway](/en/claude-apps-gateway) tự vận hành, nếu tổ chức của bạn có: quản trị viên của bạn cấu hình sẵn URL của gateway, và `/login` sẽ mở trực tiếp màn hình **Cloud gateway** để bạn đăng nhập bằng SSO của công ty

Sau khi đã đăng nhập, thông tin đăng nhập của bạn được lưu trữ và bạn sẽ không cần đăng nhập lại.

## Bước 3: Bắt đầu phiên làm việc đầu tiên

Mở terminal trong bất kỳ thư mục dự án nào và khởi động Claude Code:

```bash theme={null}
cd /path/to/your/project
claude
```

Bạn sẽ thấy dấu nhắc của Claude Code với phiên bản, mô hình hiện tại, và thư mục làm việc hiển thị phía trên. Gõ `/help` để xem các lệnh có sẵn hoặc `/resume` để tiếp tục một cuộc trò chuyện trước đó.

<Tip>
  Sau khi đăng nhập (Bước 2), thông tin đăng nhập của bạn được lưu trên hệ thống. Tìm hiểu thêm trong [Quản lý thông tin đăng nhập](/en/authentication#credential-management).
</Tip>

## Bước 4: Đặt câu hỏi đầu tiên

Hãy bắt đầu bằng việc hiểu về codebase của bạn. Thử một trong các lệnh sau:

```text theme={null}
what does this project do?
```

Claude sẽ phân tích các tệp của bạn và cung cấp một bản tóm tắt. Bạn cũng có thể đặt các câu hỏi cụ thể hơn:

```text theme={null}
what technologies does this project use?
```

```text theme={null}
where is the main entry point?
```

```text theme={null}
explain the folder structure
```

Bạn cũng có thể hỏi Claude về chính khả năng của nó:

```text theme={null}
what can Claude Code do?
```

```text theme={null}
how do I create custom skills in Claude Code?
```

```text theme={null}
can Claude Code work with Docker?
```

<Note>
  Claude Code đọc các tệp trong dự án của bạn khi cần. Bạn không phải thêm ngữ cảnh (context) thủ công.
</Note>

## Bước 5: Thực hiện thay đổi mã nguồn đầu tiên

Bây giờ hãy để Claude Code thực sự viết mã. Thử một tác vụ đơn giản:

```text theme={null}
add a hello world function to the main file
```

Claude Code sẽ:

1. Tìm tệp phù hợp
2. Hiển thị cho bạn các thay đổi được đề xuất
3. Yêu cầu bạn phê duyệt
4. Thực hiện chỉnh sửa

<Note>
  Claude Code luôn xin phép trước khi sửa đổi tệp. Bạn có thể phê duyệt từng thay đổi riêng lẻ hoặc bật chế độ "Accept all" cho một phiên.
</Note>

## Bước 6: Dùng Git với Claude Code

Claude Code biến các thao tác Git thành hội thoại:

```text theme={null}
what files have I changed?
```

```text theme={null}
commit my changes with a descriptive message
```

Bạn cũng có thể yêu cầu các thao tác Git phức tạp hơn:

```text theme={null}
create a new branch called feature/quickstart
```

```text theme={null}
show me the last 5 commits
```

```text theme={null}
help me resolve merge conflicts
```

## Bước 7: Sửa lỗi hoặc thêm tính năng

Claude thành thạo việc gỡ lỗi và triển khai tính năng.

Mô tả điều bạn muốn bằng ngôn ngữ tự nhiên:

```text theme={null}
add input validation to the user registration form
```

Hoặc sửa các vấn đề hiện có:

```text theme={null}
there's a bug where users can submit empty forms - fix it
```

Claude Code sẽ:

* Định vị mã nguồn liên quan
* Hiểu ngữ cảnh
* Triển khai giải pháp
* Chạy các bài kiểm thử (test) nếu có

## Bước 8: Thử các quy trình làm việc phổ biến khác

Có nhiều cách để làm việc với Claude:

**Tái cấu trúc (refactor) mã nguồn**

```text theme={null}
refactor the authentication module to use async/await instead of callbacks
```

**Viết test**

```text theme={null}
write unit tests for the calculator functions
```

**Cập nhật tài liệu**

```text theme={null}
update the README with installation instructions
```

**Rà soát mã (code review)**

```text theme={null}
review my changes and suggest improvements
```

<Tip>
  Hãy trò chuyện với Claude như với một đồng nghiệp hữu ích. Mô tả điều bạn muốn đạt được, và nó sẽ giúp bạn đạt tới đó.
</Tip>

## Các lệnh thiết yếu

Dưới đây là những lệnh quan trọng nhất cho việc sử dụng hằng ngày. Các lệnh shell chạy từ terminal của bạn để khởi động hoặc tiếp tục Claude Code. Các lệnh phiên (session command) chạy bên trong Claude Code sau khi nó khởi động.

**Các lệnh shell**

| Lệnh                | Chức năng                                                | Ví dụ                               |
| ------------------- | ------------------------------------------------------- | ----------------------------------- |
| `claude`            | Khởi động chế độ tương tác                               | `claude`                            |
| `claude "task"`     | Chạy một tác vụ một lần                                  | `claude "fix the build error"`      |
| `claude -p "query"` | Chạy một truy vấn một lần rồi thoát                      | `claude -p "explain this function"` |
| `claude -c`         | Tiếp tục cuộc trò chuyện gần nhất trong thư mục hiện tại | `claude -c`                         |
| `claude -r`         | Tiếp tục một cuộc trò chuyện trước đó                    | `claude -r`                         |

**Các lệnh phiên**

| Lệnh              | Chức năng                    | Ví dụ    |
| ----------------- | ---------------------------- | -------- |
| `/clear`          | Xóa lịch sử cuộc trò chuyện  | `/clear` |
| `/help`           | Hiển thị các lệnh có sẵn     | `/help`  |
| `/exit` hoặc Ctrl+D | Thoát Claude Code          | `/exit`  |

Xem [tham chiếu CLI](/en/cli-reference) để có danh sách đầy đủ các lệnh shell và [tham chiếu lệnh](/en/commands) để có danh sách đầy đủ các lệnh phiên.

## Mẹo dành cho người mới bắt đầu

Để biết thêm, xem [thực hành tốt nhất](/en/best-practices) và [các quy trình làm việc phổ biến](/en/common-workflows).

<AccordionGroup>
  <Accordion title="Hãy cụ thể trong yêu cầu của bạn">
    Thay vì: "fix the bug"

    Hãy thử: "fix the login bug where users see a blank screen after entering wrong credentials"
  </Accordion>

  <Accordion title="Dùng chỉ dẫn theo từng bước">
    Chia nhỏ các tác vụ phức tạp thành các bước:

    ```text theme={null}
    1. create a new database table for user profiles
    2. create an API endpoint to get and update user profiles
    3. build a webpage that allows users to see and edit their information
    ```
  </Accordion>

  <Accordion title="Để Claude khám phá trước">
    Trước khi thực hiện thay đổi, hãy để Claude hiểu mã nguồn của bạn:

    ```text theme={null}
    analyze the database schema
    ```

    ```text theme={null}
    build a dashboard showing products that are most frequently returned by our UK customers
    ```
  </Accordion>

  <Accordion title="Tiết kiệm thời gian với các phím tắt">
    * Gõ `/` để xem tất cả các lệnh và skill
    * Dùng Tab để tự động hoàn thành lệnh
    * Nhấn ↑ để xem lịch sử lệnh
    * Nhấn `Shift+Tab` để chuyển đổi giữa các chế độ quyền (permission mode)
  </Accordion>
</AccordionGroup>

## Tiếp theo là gì?

Giờ bạn đã học được những điều cơ bản, hãy khám phá các tính năng nâng cao hơn:

<CardGroup cols={2}>
  <Card title="Claude Code hoạt động như thế nào" icon="microchip" href="/en/how-claude-code-works">
    Hiểu về vòng lặp agentic (agentic loop), các công cụ tích hợp sẵn, và cách Claude Code tương tác với dự án của bạn
  </Card>

  <Card title="Thực hành tốt nhất" icon="star" href="/en/best-practices">
    Đạt kết quả tốt hơn với việc viết prompt hiệu quả và thiết lập dự án hợp lý
  </Card>

  <Card title="Các quy trình làm việc phổ biến" icon="graduation-cap" href="/en/common-workflows">
    Hướng dẫn từng bước cho các tác vụ phổ biến
  </Card>

  <Card title="Mở rộng Claude Code" icon="puzzle-piece" href="/en/features-overview">
    Tùy chỉnh với CLAUDE.md, skill, hook, MCP và nhiều hơn nữa
  </Card>
</CardGroup>

## Nhận trợ giúp

* **Trong Claude Code**: Gõ `/help` hoặc hỏi "how do I..."
* **Tài liệu**: Bạn đang ở đây! Duyệt qua các hướng dẫn khác
* **Cộng đồng**: Tham gia [Discord](https://www.anthropic.com/discord) của chúng tôi để có mẹo và hỗ trợ
