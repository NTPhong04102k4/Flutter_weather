> Nguồn: https://code.claude.com/docs/en/common-workflows.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Các quy trình làm việc thường gặp

> Hướng dẫn từng bước để khám phá codebase, sửa lỗi, tái cấu trúc, kiểm thử và các tác vụ hằng ngày khác với Claude Code.

Trang này tập hợp các công thức ngắn cho công việc phát triển hằng ngày. Để có hướng dẫn ở tầm cao hơn về việc viết prompt và quản lý ngữ cảnh, xem [Thực hành tốt nhất](/en/best-practices).

Trang này bao gồm:

* [Các công thức prompt](#prompt-recipes) để khám phá code, sửa lỗi, tái cấu trúc, kiểm thử, PR và tài liệu
* [Tiếp tục các cuộc hội thoại trước đó](#resume-previous-conversations) để một tác vụ có thể trải qua nhiều buổi làm việc
* [Chạy các phiên song song với worktree](#run-parallel-sessions-with-worktrees) để các chỉnh sửa đồng thời không va chạm nhau
* [Lập kế hoạch trước khi chỉnh sửa](#plan-before-editing) để xem lại các thay đổi trước khi chúng ghi xuống ổ đĩa
* [Ủy thác việc nghiên cứu cho subagent](#delegate-research-to-subagents) để giữ ngữ cảnh chính của bạn gọn gàng
* [Đưa Claude vào các script](#pipe-claude-into-scripts) cho CI và xử lý hàng loạt

## Các công thức prompt

Đây là các mẫu prompt cho các tác vụ hằng ngày như khám phá code lạ, gỡ lỗi, tái cấu trúc, viết test và tạo PR. Mỗi mẫu đều hoạt động trên mọi giao diện của Claude Code; hãy điều chỉnh cách diễn đạt cho phù hợp với dự án của bạn.

### Hiểu codebase mới

Để cấu hình Claude Code trong một monorepo hoặc codebase lớn, xem [Monorepo và repo lớn](/en/large-codebases).

#### Có được cái nhìn tổng quan nhanh về codebase

Giả sử bạn vừa gia nhập một dự án mới và cần nhanh chóng hiểu cấu trúc của nó.

<Steps>
  <Step title="Điều hướng đến thư mục gốc của dự án">
    ```bash theme={null}
    cd /path/to/project 
    ```
  </Step>

  <Step title="Khởi động Claude Code">
    ```bash theme={null}
    claude 
    ```
  </Step>

  <Step title="Yêu cầu một cái nhìn tổng quan ở tầm cao">
    ```text theme={null}
    give me an overview of this codebase
    ```
  </Step>

  <Step title="Đi sâu vào các thành phần cụ thể">
    ```text theme={null}
    explain the main architecture patterns used here
    ```

    ```text theme={null}
    what are the key data models?
    ```

    ```text theme={null}
    how is authentication handled?
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Bắt đầu với các câu hỏi rộng, sau đó thu hẹp về các khu vực cụ thể
  * Hỏi về các quy ước và mẫu code được dùng trong dự án
  * Yêu cầu một bảng thuật ngữ các từ ngữ đặc thù của dự án
</Tip>

#### Tìm code liên quan

Giả sử bạn cần định vị code liên quan đến một tính năng hoặc chức năng cụ thể.

<Steps>
  <Step title="Yêu cầu Claude tìm các file liên quan">
    ```text theme={null}
    find the files that handle user authentication
    ```
  </Step>

  <Step title="Hiểu bối cảnh về cách các thành phần tương tác">
    ```text theme={null}
    how do these authentication files work together?
    ```
  </Step>

  <Step title="Hiểu luồng thực thi">
    ```text theme={null}
    trace the login process from front-end to database
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Hãy cụ thể về điều bạn đang tìm kiếm
  * Dùng ngôn ngữ chuyên ngành của dự án
  * Cài đặt một [plugin trí tuệ code (code intelligence)](/en/discover-plugins#code-intelligence) cho ngôn ngữ của bạn để cho Claude khả năng điều hướng "go to definition" và "find references" chính xác
</Tip>

***

### Sửa lỗi hiệu quả

Giả sử bạn gặp một thông báo lỗi và cần tìm rồi sửa nguồn gốc của nó.

<Steps>
  <Step title="Chia sẻ lỗi với Claude">
    ```text theme={null}
    I'm seeing an error when I run npm test
    ```
  </Step>

  <Step title="Yêu cầu các đề xuất sửa lỗi">
    ```text theme={null}
    suggest a few ways to fix the @ts-ignore in user.ts
    ```
  </Step>

  <Step title="Áp dụng bản sửa">
    ```text theme={null}
    update user.ts to add the null check you suggested
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Cho Claude biết câu lệnh để tái hiện vấn đề và lấy stack trace
  * Nêu bất kỳ bước nào để tái hiện lỗi
  * Cho Claude biết nếu lỗi xảy ra ngắt quãng hay liên tục
</Tip>

***

### Tái cấu trúc code

Giả sử bạn cần cập nhật code cũ để dùng các mẫu và thực hành hiện đại.

<Steps>
  <Step title="Xác định code cũ cần tái cấu trúc">
    ```text theme={null}
    find deprecated API usage in our codebase
    ```
  </Step>

  <Step title="Nhận các đề xuất tái cấu trúc">
    ```text theme={null}
    suggest how to refactor utils.js to use modern JavaScript features
    ```
  </Step>

  <Step title="Áp dụng các thay đổi một cách an toàn">
    ```text theme={null}
    refactor utils.js to use ES2024 features while maintaining the same behavior
    ```
  </Step>

  <Step title="Xác minh việc tái cấu trúc">
    ```text theme={null}
    run tests for the refactored code
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Yêu cầu Claude giải thích lợi ích của cách tiếp cận hiện đại
  * Yêu cầu các thay đổi vẫn tương thích ngược khi cần thiết
  * Thực hiện tái cấu trúc theo các bước nhỏ, có thể kiểm thử được
</Tip>

***

### Làm việc với test

Giả sử bạn cần thêm test cho code chưa được bao phủ.

<Steps>
  <Step title="Xác định code chưa có test">
    ```text theme={null}
    find functions in NotificationsService.swift that are not covered by tests
    ```
  </Step>

  <Step title="Sinh khung test (test scaffolding)">
    ```text theme={null}
    add tests for the notification service
    ```
  </Step>

  <Step title="Thêm các trường hợp test có ý nghĩa">
    ```text theme={null}
    add test cases for edge conditions in the notification service
    ```
  </Step>

  <Step title="Chạy và xác minh test">
    ```text theme={null}
    run the new tests and fix any failures
    ```
  </Step>
</Steps>

Claude có thể sinh các test tuân theo các mẫu và quy ước sẵn có của dự án. Khi yêu cầu test, hãy cụ thể về hành vi bạn muốn xác minh. Claude xem xét các file test hiện có của bạn để khớp với phong cách, framework và các mẫu assertion đang được dùng.

Để bao phủ toàn diện, hãy yêu cầu Claude xác định các trường hợp biên mà bạn có thể đã bỏ sót. Claude có thể phân tích các đường đi của code và đề xuất các test cho điều kiện lỗi, giá trị biên và đầu vào bất ngờ vốn dễ bị bỏ qua.

***

### Tạo pull request

Bạn có thể tạo pull request bằng cách yêu cầu Claude trực tiếp ("create a pr for my changes"), hoặc dẫn dắt Claude thực hiện từng bước:

<Steps>
  <Step title="Tóm tắt các thay đổi của bạn">
    ```text theme={null}
    summarize the changes I've made to the authentication module
    ```
  </Step>

  <Step title="Sinh một pull request">
    ```text theme={null}
    create a pr
    ```
  </Step>

  <Step title="Xem lại và tinh chỉnh">
    ```text theme={null}
    enhance the PR description with more context about the security improvements
    ```
  </Step>
</Steps>

Khi bạn tạo PR bằng `gh pr create`, phiên làm việc sẽ tự động được liên kết với PR đó. Để quay lại nó sau này, chạy `claude --from-pr 123`, thay 123 bằng số PR, hoặc dán URL của PR vào ô tìm kiếm trong [bộ chọn `/resume`](/en/sessions#use-the-session-picker).

<Tip>
  Xem lại PR do Claude sinh ra trước khi gửi và yêu cầu Claude làm nổi bật các rủi ro hoặc điểm cần cân nhắc tiềm ẩn.
</Tip>

### Xử lý tài liệu

Giả sử bạn cần thêm hoặc cập nhật tài liệu cho code của mình.

<Steps>
  <Step title="Xác định code chưa có tài liệu">
    ```text theme={null}
    find functions without proper JSDoc comments in the auth module
    ```
  </Step>

  <Step title="Sinh tài liệu">
    ```text theme={null}
    add JSDoc comments to the undocumented functions in auth.js
    ```
  </Step>

  <Step title="Xem lại và nâng cao">
    ```text theme={null}
    improve the generated documentation with more context and examples
    ```
  </Step>

  <Step title="Xác minh tài liệu">
    ```text theme={null}
    check if the documentation follows our project standards
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Chỉ định phong cách tài liệu bạn muốn (JSDoc, docstring, v.v.)
  * Yêu cầu các ví dụ trong tài liệu
  * Yêu cầu tài liệu cho các API công khai, interface và logic phức tạp
</Tip>

***

### Làm việc trong thư mục ghi chú và thư mục không phải code

Claude Code hoạt động trong mọi thư mục. Chạy nó bên trong một kho ghi chú (notes vault), một thư mục tài liệu, hoặc bất kỳ tập hợp file markdown nào để tìm kiếm, chỉnh sửa và tổ chức lại nội dung theo cách bạn làm với code.

Thư mục `.claude/` và `CLAUDE.md` nằm cạnh các thư mục cấu hình của các công cụ khác mà không xung đột. Claude đọc lại file mới mỗi lần gọi công cụ, nên nó thấy các chỉnh sửa bạn thực hiện trong một ứng dụng khác vào lần tiếp theo nó đọc file đó.

***

### Làm việc với hình ảnh

Giả sử bạn cần làm việc với hình ảnh trong codebase của mình, và bạn muốn Claude giúp phân tích nội dung hình ảnh.

<Steps>
  <Step title="Thêm một hình ảnh vào cuộc hội thoại">
    Bạn có thể dùng bất kỳ cách nào sau đây:

    1. Kéo và thả một hình ảnh vào cửa sổ Claude Code
    2. Sao chép một hình ảnh và dán nó vào CLI bằng ctrl+v (Không dùng cmd+v)
    3. Cung cấp đường dẫn hình ảnh cho Claude. Ví dụ: "Analyze this image: /path/to/your/image.png"
  </Step>

  <Step title="Yêu cầu Claude phân tích hình ảnh">
    ```text theme={null}
    What does this image show?
    ```

    ```text theme={null}
    Describe the UI elements in this screenshot
    ```

    ```text theme={null}
    Are there any problematic elements in this diagram?
    ```
  </Step>

  <Step title="Dùng hình ảnh để cung cấp ngữ cảnh">
    ```text theme={null}
    Here's a screenshot of the error. What's causing it?
    ```

    ```text theme={null}
    This is our current database schema. How should we modify it for the new feature?
    ```
  </Step>

  <Step title="Nhận đề xuất code từ nội dung trực quan">
    ```text theme={null}
    Generate CSS to match this design mockup
    ```

    ```text theme={null}
    What HTML structure would recreate this component?
    ```
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Dùng hình ảnh khi mô tả bằng chữ sẽ không rõ ràng hoặc rườm rà
  * Đính kèm ảnh chụp màn hình lỗi, thiết kế UI, hoặc sơ đồ để có ngữ cảnh tốt hơn
  * Bạn có thể làm việc với nhiều hình ảnh trong một cuộc hội thoại
  * Phân tích hình ảnh hoạt động với sơ đồ, ảnh chụp màn hình, mockup và nhiều loại khác
  * Khi Claude tham chiếu hình ảnh (ví dụ, `[Image #1]`), `Cmd+Click` (Mac) hoặc `Ctrl+Click` (Windows/Linux) vào liên kết để mở hình ảnh trong trình xem mặc định của bạn
</Tip>

***

### Tham chiếu file và thư mục

Dùng @ để nhanh chóng đưa vào file hoặc thư mục mà không cần chờ Claude đọc chúng.

<Steps>
  <Step title="Tham chiếu một file đơn lẻ">
    ```text theme={null}
    Explain the logic in @src/utils/auth.js
    ```

    Cách này đưa toàn bộ nội dung của file vào cuộc hội thoại.
  </Step>

  <Step title="Tham chiếu một thư mục">
    ```text theme={null}
    What's the structure of @src/components?
    ```

    Cách này cung cấp danh sách thư mục kèm thông tin file.
  </Step>

  <Step title="Tham chiếu tài nguyên MCP">
    ```text theme={null}
    Show me the data from @github:repos/owner/repo/issues
    ```

    Cách này lấy dữ liệu từ các máy chủ MCP đã kết nối theo định dạng @server:resource. Xem [Tài nguyên MCP](/en/mcp#use-mcp-resources) để biết chi tiết.
  </Step>
</Steps>

<Tip>
  Mẹo:

  * Đường dẫn file có thể là tương đối hoặc tuyệt đối
  * Tham chiếu file bằng @ sẽ thêm `CLAUDE.md` trong thư mục của file và các thư mục cha vào ngữ cảnh
  * Tham chiếu thư mục hiển thị danh sách file, không phải nội dung
  * Bạn có thể tham chiếu nhiều file trong một tin nhắn (ví dụ, "@file1.js and @file2.js")
</Tip>

***

### Chạy Claude theo lịch trình

Giả sử bạn muốn Claude tự động xử lý một tác vụ định kỳ, như xem xét các PR đang mở mỗi sáng, kiểm tra các phụ thuộc (dependency) hằng tuần, hoặc kiểm tra các lỗi CI qua đêm.

Chọn một tùy chọn lập lịch dựa trên nơi bạn muốn tác vụ chạy:

| Tùy chọn                                               | Nơi nó chạy                       | Phù hợp nhất cho                                                                                                                                                                                                 |
| :----------------------------------------------------- | :-------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Routines](/en/routines)                               | Hạ tầng do Anthropic quản lý       | Các tác vụ cần chạy ngay cả khi máy tính của bạn đã tắt. Cũng có thể kích hoạt bằng lời gọi API hoặc sự kiện GitHub bên cạnh lịch trình. Cấu hình tại [claude.ai/code/routines](https://claude.ai/code/routines). |
| [Tác vụ theo lịch trên desktop](/en/desktop-scheduled-tasks) | Máy của bạn, qua ứng dụng desktop | Các tác vụ cần truy cập trực tiếp vào file cục bộ, công cụ, hoặc các thay đổi chưa commit.                                                                                                                        |
| [GitHub Actions](/en/github-actions)                   | Pipeline CI của bạn               | Các tác vụ gắn với sự kiện repo như PR mở, hoặc lịch cron nên nằm cùng với cấu hình workflow của bạn.                                                                                                            |
| [`/loop`](/en/scheduled-tasks)                         | Phiên CLI hiện tại                | Việc thăm dò (polling) nhanh khi một phiên đang mở. Tác vụ dừng khi bạn bắt đầu cuộc hội thoại mới; `--resume` và `--continue` khôi phục những tác vụ chưa hết hạn.                                                |

<Tip>
  Khi viết prompt cho các tác vụ theo lịch, hãy nêu rõ thế nào là thành công và phải làm gì với kết quả. Tác vụ chạy tự động nên không thể hỏi lại để làm rõ. Ví dụ: "Review open PRs labeled `needs-review`, leave inline comments on any issues, and post a summary in the `#eng-reviews` Slack channel."
</Tip>

***

### Hỏi Claude về khả năng của nó

Claude có sẵn quyền truy cập tài liệu của nó và có thể trả lời các câu hỏi về các tính năng và giới hạn của chính nó.

#### Các câu hỏi ví dụ

```text theme={null}
can Claude Code create pull requests?
```

```text theme={null}
how does Claude Code handle permissions?
```

```text theme={null}
what skills are available?
```

```text theme={null}
how do I use MCP with Claude Code?
```

```text theme={null}
how do I configure Claude Code for Amazon Bedrock?
```

```text theme={null}
what are the limitations of Claude Code?
```

<Note>
  Claude cung cấp câu trả lời dựa trên tài liệu cho các câu hỏi này. Để có các minh họa thực hành, chạy `/powerup` để có các bài học tương tác với demo hoạt hình, hoặc tham khảo các phần quy trình làm việc cụ thể ở trên.
</Note>

<Tip>
  Mẹo:

  * Claude luôn có quyền truy cập tài liệu Claude Code mới nhất, bất kể bạn đang dùng phiên bản nào
  * Đặt câu hỏi cụ thể để nhận câu trả lời chi tiết
  * Claude có thể giải thích các tính năng phức tạp như tích hợp MCP, cấu hình doanh nghiệp và các quy trình làm việc nâng cao
</Tip>

***

## Tiếp tục các cuộc hội thoại trước đó

Khi một tác vụ trải qua nhiều buổi làm việc, hãy tiếp nối từ nơi bạn dừng lại thay vì giải thích lại ngữ cảnh. Claude Code lưu mọi cuộc hội thoại cục bộ.

```bash theme={null}
claude --continue
```

Lệnh này tiếp tục phiên gần nhất trong thư mục hiện tại; nếu chưa có phiên nào, nó in ra `No conversation found to continue` rồi thoát. Dùng `claude --resume` để chọn từ một danh sách, hoặc `/resume` từ bên trong một phiên đang chạy. Xem [Quản lý phiên](/en/sessions) để biết cách đặt tên, phân nhánh và tham khảo đầy đủ về bộ chọn.

## Chạy các phiên song song với worktree

Làm việc trên một tính năng ở một terminal trong khi Claude sửa lỗi ở terminal khác, mà các chỉnh sửa không va chạm nhau. Mỗi worktree (cây làm việc) là một checkout riêng biệt trên nhánh của riêng nó.

```bash theme={null}
claude --worktree feature-auth
```

Chạy cùng lệnh đó với một tên khác trong terminal thứ hai để bắt đầu một phiên song song biệt lập. Xem [Worktree](/en/worktrees) để biết về dọn dẹp, `.worktreeinclude` và hỗ trợ VCS không phải git. Để giám sát các phiên song song từ một màn hình thay vì các terminal riêng biệt, xem [background agent](/en/agent-view).

## Lập kế hoạch trước khi chỉnh sửa

Với những thay đổi bạn muốn xem lại trước khi chúng ghi xuống ổ đĩa, hãy chuyển sang chế độ plan (plan mode). Claude đọc các file và đề xuất một kế hoạch nhưng không thực hiện chỉnh sửa nào cho đến khi bạn phê duyệt.

```bash theme={null}
claude --permission-mode plan
```

Bạn cũng có thể nhấn `Shift+Tab` giữa phiên để chuyển sang chế độ plan. Xem [Plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode) để biết về luồng phê duyệt và chỉnh sửa kế hoạch trong trình soạn thảo văn bản của bạn.

## Ủy thác việc nghiên cứu cho subagent

Khám phá một codebase lớn sẽ làm đầy ngữ cảnh của bạn bằng các lần đọc file. Hãy ủy thác việc khám phá để chỉ có các phát hiện được trả về.

```text theme={null}
use a subagent to investigate how our auth system handles token refresh
```

Subagent đọc các file trong cửa sổ ngữ cảnh (context window) của riêng nó và báo cáo lại một bản tóm tắt. Xem [Subagent](/en/sub-agents) để định nghĩa các agent tùy chỉnh với công cụ và prompt riêng.

## Đưa Claude vào các script

Chạy Claude ở chế độ không tương tác cho CI, các hook pre-commit, hoặc xử lý hàng loạt. Stdin và stdout hoạt động như bất kỳ công cụ Unix nào.

```bash theme={null}
git log --oneline -20 | claude -p "summarize these recent commits"
```

Xem [Chế độ không tương tác](/en/headless) để biết về các định dạng đầu ra, các cờ quyền và các mẫu fan-out.

## Các bước tiếp theo

<CardGroup cols={2}>
  <Card title="Thực hành tốt nhất" icon="lightbulb" href="/en/best-practices">
    Các mẫu để tận dụng tối đa Claude Code
  </Card>

  <Card title="Quản lý phiên" icon="rotate-left" href="/en/sessions">
    Tiếp tục, đặt tên và phân nhánh các cuộc hội thoại
  </Card>

  <Card title="Worktree" icon="code-branch" href="/en/worktrees">
    Chạy các phiên song song biệt lập
  </Card>

  <Card title="Mở rộng Claude Code" icon="puzzle-piece" href="/en/features-overview">
    Thêm skill, hook, MCP, subagent và plugin
  </Card>
</CardGroup>
