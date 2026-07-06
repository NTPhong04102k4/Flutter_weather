> Nguồn: https://code.claude.com/docs/en/how-claude-code-works.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Claude Code hoạt động như thế nào

> Hiểu về vòng lặp agent (agentic loop), các công cụ tích hợp sẵn, và cách Claude Code tương tác với dự án của bạn.

Claude Code là một trợ lý dạng agent chạy trong terminal của bạn. Dù nó xuất sắc trong lập trình, nó có thể giúp với bất cứ điều gì bạn làm được từ dòng lệnh: viết tài liệu, chạy build, tìm kiếm file, nghiên cứu chủ đề, và hơn thế nữa.

Hướng dẫn này bao gồm kiến trúc cốt lõi, các khả năng tích hợp sẵn, và [mẹo để làm việc hiệu quả](#work-effectively-with-claude-code). Để có hướng dẫn từng bước, xem [Common workflows](/en/common-workflows). Để tìm hiểu các tính năng mở rộng như skill, MCP, và hook, xem [Extend Claude Code](/en/features-overview).

## Vòng lặp agent (agentic loop)

Khi bạn giao cho Claude một tác vụ, nó làm việc qua ba giai đoạn: **thu thập ngữ cảnh (gather context)**, **thực hiện hành động (take action)**, và **xác minh kết quả (verify results)**. Các giai đoạn này hòa quyện vào nhau. Claude dùng công cụ xuyên suốt, dù là tìm kiếm file để hiểu code của bạn, chỉnh sửa để thực hiện thay đổi, hay chạy test để kiểm tra công việc của nó.

<img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/agentic-loop.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=4a30fb7ce2815012a9f27c955e2c6bb0" alt="Diagram of the agentic loop: Your prompt leads to Claude gathering context, taking action, verifying results, and repeating until task complete. You can interrupt at any point." width="720" height="280" data-path="images/agentic-loop.svg" />

Vòng lặp thích ứng với những gì bạn yêu cầu. Một câu hỏi về codebase của bạn có thể chỉ cần thu thập ngữ cảnh. Một bản sửa lỗi lặp lại toàn bộ ba giai đoạn nhiều lần. Một lần refactor có thể liên quan đến việc xác minh sâu rộng. Claude quyết định mỗi bước cần gì dựa trên những gì nó học được từ bước trước, kết chuỗi hàng chục hành động lại với nhau và tự điều chỉnh trên đường đi.

Bạn cũng là một phần của vòng lặp này. Bạn có thể ngắt tại bất kỳ thời điểm nào để lái Claude theo một hướng khác, cung cấp thêm ngữ cảnh, hoặc yêu cầu nó thử một cách tiếp cận khác. Claude làm việc tự chủ nhưng vẫn nhạy bén với đầu vào của bạn.

Vòng lặp agent được vận hành bởi hai thành phần: [các model](#models) suy luận và [các công cụ](#tools) hành động. Claude Code đóng vai trò là **agentic harness** bao quanh Claude: nó cung cấp các công cụ, việc quản lý ngữ cảnh, và môi trường thực thi để biến một model ngôn ngữ thành một agent lập trình có năng lực.

### Model

Claude Code dùng các model Claude để hiểu code của bạn và suy luận về các tác vụ. Claude có thể đọc code ở bất kỳ ngôn ngữ nào, hiểu cách các thành phần kết nối với nhau, và tìm ra những gì cần thay đổi để hoàn thành mục tiêu của bạn. Với các tác vụ phức tạp, nó chia nhỏ công việc thành các bước, thực hiện chúng, và điều chỉnh dựa trên những gì học được.

[Nhiều model](/en/model-config) có sẵn với các đánh đổi khác nhau. Sonnet xử lý tốt hầu hết các tác vụ lập trình. Opus cung cấp khả năng suy luận mạnh hơn cho các quyết định kiến trúc phức tạp. Chuyển đổi bằng `/model` trong một phiên hoặc khởi động với `claude --model <name>`.

Khi hướng dẫn này nói "Claude chooses" (Claude chọn) hoặc "Claude decides" (Claude quyết định), thì đó là model đang thực hiện việc suy luận.

### Công cụ (Tools)

Công cụ là thứ khiến Claude Code trở thành agent. Không có công cụ, Claude chỉ có thể phản hồi bằng văn bản. Với công cụ, Claude có thể hành động: đọc code của bạn, chỉnh sửa file, chạy lệnh, tìm kiếm trên web, và tương tác với các dịch vụ bên ngoài. Mỗi lần dùng công cụ đều trả về thông tin đưa ngược trở lại vào vòng lặp, giúp định hướng quyết định tiếp theo của Claude.

Các công cụ tích hợp sẵn nhìn chung rơi vào năm nhóm, mỗi nhóm đại diện cho một kiểu năng lực (agency) khác nhau.

| Nhóm                  | Claude có thể làm gì                                                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **File operations**   | Đọc file, chỉnh sửa code, tạo file mới, đổi tên và tổ chức lại                                                                                                |
| **Search**            | Tìm file theo mẫu (pattern), tìm nội dung với regex, khám phá codebase                                                                                        |
| **Execution**         | Chạy lệnh shell, khởi động server, chạy test, dùng git                                                                                                        |
| **Web**               | Tìm kiếm trên web, lấy tài liệu, tra cứu thông báo lỗi                                                                                                        |
| **Code intelligence** | Xem lỗi kiểu (type errors) và cảnh báo sau khi chỉnh sửa, nhảy tới định nghĩa, tìm tham chiếu (yêu cầu [code intelligence plugins](/en/discover-plugins#code-intelligence)) |

Đây là các khả năng chính. Claude cũng có các công cụ để sinh subagent, đặt câu hỏi cho bạn, và các tác vụ điều phối khác. Xem [Tools available to Claude](/en/tools-reference) để có danh sách đầy đủ.

Claude chọn công cụ nào để dùng dựa trên prompt của bạn và những gì nó học được trên đường đi. Khi bạn nói "fix the failing tests", Claude có thể:

1. Chạy bộ test để xem cái nào đang thất bại
2. Đọc đầu ra lỗi
3. Tìm kiếm các file mã nguồn liên quan
4. Đọc các file đó để hiểu code
5. Chỉnh sửa các file để sửa vấn đề
6. Chạy test lại để xác minh

Mỗi lần dùng công cụ mang lại cho Claude thông tin mới định hướng bước tiếp theo. Đây chính là vòng lặp agent trong thực tế.

**Mở rộng các khả năng nền tảng:** Các công cụ tích hợp sẵn là nền tảng. Bạn có thể mở rộng những gì Claude biết với [skill](/en/skills), kết nối tới các dịch vụ bên ngoài với [MCP](/en/mcp), tự động hóa quy trình với [hook](/en/hooks), và giao phó tác vụ cho [subagent](/en/sub-agents). Các phần mở rộng này tạo thành một lớp trên đỉnh vòng lặp agent cốt lõi. Xem [Extend Claude Code](/en/features-overview) để được hướng dẫn chọn phần mở rộng phù hợp với nhu cầu của bạn.

## Những gì Claude có thể truy cập

Hướng dẫn này tập trung vào terminal. Claude Code cũng chạy trong [VS Code](/en/vs-code), [JetBrains IDEs](/en/jetbrains), và các môi trường khác.

Khi bạn chạy `claude` trong một thư mục, Claude Code có quyền truy cập vào:

* **Dự án của bạn.** Các file trong thư mục và thư mục con của bạn, cùng với các file ở nơi khác với sự cho phép của bạn.
* **Terminal của bạn.** Bất kỳ lệnh nào bạn có thể chạy: công cụ build, git, trình quản lý gói, tiện ích hệ thống, script. Nếu bạn có thể làm được từ dòng lệnh, Claude cũng vậy.
* **Trạng thái git của bạn.** Nhánh hiện tại, các thay đổi chưa commit, và lịch sử commit gần đây.
* **[CLAUDE.md](/en/memory) của bạn.** Một file markdown nơi bạn lưu các chỉ dẫn, quy ước và ngữ cảnh riêng của dự án mà Claude cần biết mỗi phiên.
* **[Auto memory](/en/memory#auto-memory).** Những điều học được mà Claude tự động lưu khi bạn làm việc, như các mẫu (pattern) của dự án và sở thích của bạn. 200 dòng hoặc 25KB đầu tiên của MEMORY.md, tùy cái nào đến trước, được nạp ở đầu mỗi phiên.
* **Các phần mở rộng bạn cấu hình.** [MCP server](/en/mcp) cho các dịch vụ bên ngoài, [skill](/en/skills) cho quy trình, [subagent](/en/sub-agents) cho công việc được giao, và [Claude in Chrome](/en/chrome) để tương tác với trình duyệt.

Vì Claude thấy toàn bộ dự án của bạn, nó có thể làm việc xuyên suốt dự án. Khi bạn yêu cầu Claude "fix the authentication bug", nó tìm kiếm các file liên quan, đọc nhiều file để hiểu ngữ cảnh, thực hiện các chỉnh sửa phối hợp trên các file đó, chạy test để xác minh bản sửa, và commit các thay đổi nếu bạn yêu cầu. Điều này khác với các trợ lý code nội tuyến (inline) chỉ thấy file hiện tại.

## Môi trường và giao diện

Vòng lặp agent, các công cụ, và các khả năng được mô tả ở trên là như nhau ở mọi nơi bạn dùng Claude Code. Điều thay đổi là nơi code được thực thi và cách bạn tương tác với nó.

### Môi trường thực thi

Claude Code chạy trong ba môi trường, mỗi môi trường có các đánh đổi khác nhau về nơi code của bạn thực thi.

| Môi trường         | Nơi code chạy                            | Trường hợp sử dụng                                              |
| ------------------ | --------------------------------------- | ---------------------------------------------------------------- |
| **Local**          | Máy của bạn                             | Mặc định. Toàn quyền truy cập file, công cụ và môi trường của bạn |
| **Cloud**          | Các máy ảo (VM) do Anthropic quản lý     | Giao phó tác vụ, làm việc trên các repo bạn không có cục bộ      |
| **Remote Control** | Máy của bạn, điều khiển từ trình duyệt   | Dùng giao diện web trong khi giữ mọi thứ cục bộ                 |

### Giao diện

Bạn có thể truy cập Claude Code qua terminal, [ứng dụng desktop](/en/desktop), [tiện ích IDE](/en/vs-code), [claude.ai/code](https://claude.ai/code), [Remote Control](/en/remote-control), [Slack](/en/slack), và [đường ống CI/CD](/en/github-actions). Giao diện quyết định cách bạn thấy và tương tác với Claude, nhưng vòng lặp agent nền tảng là giống hệt nhau. Xem [Use Claude Code everywhere](/en/overview#use-claude-code-everywhere) để có danh sách đầy đủ.

## Làm việc với các phiên (session)

Claude Code lưu hội thoại của bạn cục bộ khi bạn làm việc. Mỗi tin nhắn, lần dùng công cụ, và kết quả được ghi vào một file JSONL dạng văn bản thuần dưới `~/.claude/projects/`, cho phép [tua lại (rewinding)](#undo-changes-with-checkpoints), [tiếp tục, và phân nhánh (forking)](#resume-or-fork-sessions) các phiên. Trước khi Claude thực hiện thay đổi code, nó cũng chụp nhanh (snapshot) các file bị ảnh hưởng để bạn có thể hoàn nguyên nếu cần. Để biết đường dẫn, thời gian lưu giữ, và cách xóa dữ liệu này, xem [application data in `~/.claude`](/en/claude-directory#application-data).

**Các phiên là độc lập.** Mỗi phiên mới bắt đầu với một context window (cửa sổ ngữ cảnh) mới toanh, không có lịch sử hội thoại từ các phiên trước. Claude có thể lưu giữ những điều học được xuyên suốt các phiên bằng [auto memory](/en/memory#auto-memory), và bạn có thể thêm các chỉ dẫn bền vững của riêng mình trong [CLAUDE.md](/en/memory).

### Làm việc trên nhiều nhánh

Mỗi hội thoại Claude Code là một phiên gắn với thư mục hiện tại của bạn. Bộ chọn `/resume` mặc định hiển thị các phiên từ worktree hiện tại, với các phím tắt để mở rộng danh sách sang các worktree hoặc dự án khác. Xem [Manage sessions](/en/sessions#use-the-session-picker) để có danh sách đầy đủ các phím tắt của bộ chọn và cách phân giải tên hoạt động.

Claude thấy các file của nhánh hiện tại của bạn. Khi bạn chuyển nhánh, Claude thấy các file của nhánh mới, nhưng lịch sử hội thoại của bạn vẫn giữ nguyên. Claude nhớ những gì bạn đã bàn ngay cả sau khi chuyển nhánh.

Vì các phiên được gắn với thư mục, bạn có thể chạy các phiên Claude song song bằng cách dùng [git worktree](/en/worktrees), tạo các thư mục riêng biệt cho từng nhánh.

### Tiếp tục hoặc phân nhánh phiên

Tiếp tục một phiên với `claude --continue` hoặc `claude --resume` sẽ mở lại nó dưới cùng session ID và nối các tin nhắn mới vào hội thoại hiện có. Phân nhánh (forking) với `--fork-session` hoặc `/branch` sao chép lịch sử vào một session ID mới, giữ nguyên bản gốc.

<img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/session-continuity.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=04ed0984a58e4127e05b3640265241a3" alt="Diagram of session continuity: resume continues the same session, fork creates a new branch with a new ID." width="560" height="280" data-path="images/session-continuity.svg" />

Để biết các flag resume, bộ chọn `/resume`, cách đặt tên, và điều gì xảy ra khi cùng một phiên được mở trong hai terminal, xem [Manage sessions](/en/sessions).

### Context window (cửa sổ ngữ cảnh)

Context window của Claude chứa lịch sử hội thoại, nội dung file, đầu ra lệnh, [CLAUDE.md](/en/memory), [auto memory](/en/memory#auto-memory), các skill đã nạp, và các chỉ dẫn hệ thống của bạn. Khi bạn làm việc, ngữ cảnh dần đầy lên. Claude nén (compact) tự động, nhưng các chỉ dẫn từ giai đoạn đầu hội thoại có thể bị mất. Đặt các quy tắc bền vững trong CLAUDE.md, và chạy `/context` để xem cái gì đang chiếm dung lượng.

Để có hướng dẫn tương tác về những gì được nạp và khi nào, xem [Explore the context window](/en/context-window).

#### Khi ngữ cảnh đầy lên

Claude Code quản lý ngữ cảnh tự động khi bạn tiến gần đến giới hạn. Nó xóa các đầu ra công cụ cũ hơn trước, sau đó tóm tắt hội thoại nếu cần. Các yêu cầu của bạn và các đoạn code quan trọng được giữ lại; các chỉ dẫn chi tiết từ giai đoạn đầu hội thoại có thể bị mất. Đặt các quy tắc bền vững trong CLAUDE.md thay vì dựa vào lịch sử hội thoại.

Để kiểm soát những gì được giữ lại trong quá trình nén, thêm một mục "Compact Instructions" vào CLAUDE.md hoặc chạy `/compact` với một trọng tâm (như `/compact focus on the API changes`).

Nếu một file hoặc đầu ra công cụ đơn lẻ lớn đến mức ngữ cảnh lập tức đầy lại sau mỗi lần tóm tắt, Claude Code sẽ dừng tự động nén sau vài lần thử và hiển thị lỗi thay vì lặp vô tận. Xem [Auto-compaction stops with a thrashing error](/en/troubleshooting#auto-compaction-stops-with-a-thrashing-error) để biết các bước khôi phục.

Chạy `/context` để xem cái gì đang chiếm dung lượng. Các định nghĩa công cụ MCP được hoãn (deferred) theo mặc định và được nạp theo yêu cầu qua [tool search](/en/mcp#scale-with-mcp-tool-search), nên chỉ tên công cụ tiêu tốn ngữ cảnh cho đến khi Claude dùng một công cụ cụ thể. Chạy `/mcp` để kiểm tra chi phí theo từng server.

#### Quản lý ngữ cảnh với skill và subagent

Ngoài việc nén, bạn có thể dùng các tính năng khác để kiểm soát những gì được nạp vào ngữ cảnh.

[Skill](/en/skills) được nạp theo yêu cầu. Claude thấy mô tả skill ở đầu phiên, nhưng nội dung đầy đủ chỉ được nạp khi một skill được dùng. Với các skill bạn tự gọi thủ công, đặt `disable-model-invocation: true` để giữ các mô tả ngoài ngữ cảnh cho đến khi bạn cần. Với các skill bạn không viết, dùng [`skillOverrides`](/en/skills#override-skill-visibility-from-settings) để làm điều tương tự từ settings.

[Subagent](/en/sub-agents) có ngữ cảnh mới của riêng mình, hoàn toàn tách biệt với hội thoại chính của bạn. Công việc của chúng không làm phình ngữ cảnh của bạn. Khi xong, chúng trả về một bản tóm tắt. Sự tách biệt này là lý do subagent giúp ích với các phiên dài.

Xem [context costs](/en/features-overview#understand-context-costs) để biết mỗi tính năng tốn gì, và [reduce token usage](/en/costs#reduce-token-usage) để có mẹo quản lý ngữ cảnh.

## Giữ an toàn với checkpoint và permission

Claude có hai cơ chế an toàn: checkpoint cho phép bạn hoàn tác các thay đổi file, và permission kiểm soát những gì Claude có thể làm mà không cần hỏi.

### Hoàn tác thay đổi với checkpoint

**Mọi lần chỉnh sửa file đều có thể hoàn nguyên.** Trước khi Claude chỉnh sửa bất kỳ file nào, nó chụp nhanh nội dung hiện tại. Nếu có gì sai, nhấn `Esc` hai lần để tua lại về một trạng thái trước đó, hoặc yêu cầu Claude hoàn tác.

Checkpoint là cục bộ theo phiên của bạn, tách biệt với git. Chúng chỉ bao gồm các thay đổi file. Các hành động ảnh hưởng đến hệ thống từ xa (database, API, triển khai) không thể được checkpoint, đó là lý do Claude hỏi trước khi chạy các lệnh có tác dụng phụ bên ngoài.

### Kiểm soát những gì Claude có thể làm

Nhấn `Shift+Tab` để luân chuyển qua các permission mode (chế độ quyền hạn):

* **Default**: Claude hỏi trước khi chỉnh sửa file và chạy lệnh shell
* **Auto-accept edits**: Claude chỉnh sửa file và chạy các lệnh hệ thống file thông dụng như `mkdir` và `mv` mà không hỏi, vẫn hỏi với các lệnh khác
* **Plan mode**: Claude khám phá và đề xuất một kế hoạch mà không chỉnh sửa các file mã nguồn của bạn; các prompt xin quyền vẫn áp dụng như ở chế độ mặc định
* **Auto mode**: Claude đánh giá tất cả các hành động với các kiểm tra an toàn ở nền. Hiện là bản xem trước nghiên cứu (research preview)

Bạn cũng có thể cho phép các lệnh cụ thể trong `.claude/settings.json` để Claude không hỏi mỗi lần. Điều này hữu ích với các lệnh đáng tin cậy như `npm test` hoặc `git status`. Settings có thể được phạm vi hóa từ các chính sách toàn tổ chức xuống đến sở thích cá nhân. Xem [Permissions](/en/permissions) để biết chi tiết.

***

## Làm việc hiệu quả với Claude Code

Các mẹo này giúp bạn có kết quả tốt hơn từ Claude Code.

### Hỏi Claude Code để được trợ giúp

Claude Code có thể dạy bạn cách dùng nó. Hãy hỏi những câu như "how do I set up hooks?" hoặc "what's the best way to structure my CLAUDE.md?" và Claude sẽ giải thích.

Các lệnh tích hợp sẵn cũng hướng dẫn bạn qua quá trình thiết lập:

* `/init` hướng dẫn bạn qua việc tạo một CLAUDE.md cho dự án của bạn
* `/doctor` chẩn đoán các vấn đề thường gặp với bản cài đặt của bạn

### Đó là một cuộc hội thoại

Claude Code mang tính hội thoại. Bạn không cần các prompt hoàn hảo. Bắt đầu với những gì bạn muốn, rồi tinh chỉnh:

```text theme={null}
Fix the login bug
```

\[Claude điều tra, thử một cách gì đó]

```text theme={null}
That's not quite right. The issue is in the session handling.
```

\[Claude điều chỉnh cách tiếp cận]

Khi lần thử đầu tiên chưa đúng, bạn không phải bắt đầu lại. Bạn lặp lại (iterate).

#### Ngắt và lái

Bạn có thể chuyển hướng Claude tại bất kỳ thời điểm nào mà không cần chờ lượt (turn) kết thúc hoặc bắt đầu lại:

* **Nhấn `Esc`** để dừng Claude ngay lập tức. Lệnh gọi công cụ đang chạy bị hủy và Claude chờ chỉ dẫn tiếp theo của bạn.
* **Gõ một chỉnh sửa và nhấn `Enter`** để gửi nó mà không dừng công cụ đang chạy. Claude đọc nó ngay khi hành động hiện tại hoàn thành và điều chỉnh trước khi quyết định bước tiếp theo.

### Cụ thể ngay từ đầu

Prompt ban đầu của bạn càng chính xác, bạn càng cần ít chỉnh sửa. Tham chiếu các file cụ thể, nêu các ràng buộc, và trỏ đến các mẫu ví dụ.

```text theme={null}
The checkout flow is broken for users with expired cards.
Check src/payments/ for the issue, especially token refresh.
Write a failing test first, then fix it.
```

Các prompt mơ hồ vẫn có tác dụng, nhưng bạn sẽ tốn nhiều thời gian hơn để lái. Các prompt cụ thể như ví dụ trên thường thành công ngay từ lần thử đầu tiên.

### Cho Claude thứ gì đó để đối chiếu xác minh

Claude làm tốt hơn khi nó có thể tự kiểm tra công việc của mình. Bao gồm các test case, dán ảnh chụp màn hình của giao diện mong muốn, hoặc định nghĩa đầu ra bạn muốn.

```text theme={null}
Implement validateEmail. Test cases: 'user@example.com' → true,
'invalid' → false, 'user@.com' → false. Run the tests after.
```

Với công việc trực quan, dán ảnh chụp màn hình của thiết kế và yêu cầu Claude so sánh bản triển khai của nó với nó.

### Khám phá trước khi triển khai

Với các vấn đề phức tạp, tách phần nghiên cứu khỏi phần lập trình. Dùng plan mode (`Shift+Tab` hai lần) để phân tích codebase trước:

```text theme={null}
Read src/auth/ and understand how we handle sessions.
Then create a plan for adding OAuth support.
```

Xem xét kế hoạch, tinh chỉnh nó qua hội thoại, rồi để Claude triển khai. Cách tiếp cận hai giai đoạn này cho kết quả tốt hơn so với nhảy thẳng vào code.

### Giao phó, đừng chỉ đạo từng ly

Hãy nghĩ đến việc giao phó cho một đồng nghiệp có năng lực. Cung cấp ngữ cảnh và định hướng, rồi tin tưởng Claude tự tìm ra các chi tiết:

```text theme={null}
The checkout flow is broken for users with expired cards.
The relevant code is in src/payments/. Can you investigate and fix it?
```

Bạn không cần chỉ định file nào cần đọc hay lệnh nào cần chạy. Claude tự tìm ra điều đó.

## Tiếp theo là gì

<CardGroup cols={2}>
  <Card title="Extend with features" icon="puzzle-piece" href="/en/features-overview">
    Thêm Skill, kết nối MCP, và các lệnh tùy chỉnh
  </Card>

  <Card title="Common workflows" icon="graduation-cap" href="/en/common-workflows">
    Hướng dẫn từng bước cho các tác vụ điển hình
  </Card>
</CardGroup>
