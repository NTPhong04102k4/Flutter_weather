> Nguồn: https://code.claude.com/docs/en/best-practices.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Thực hành tốt nhất cho Claude Code

> Mẹo và mẫu hình để tận dụng tối đa Claude Code, từ cấu hình môi trường đến mở rộng quy mô qua nhiều phiên song song.

Claude Code là một môi trường lập trình dạng agentic (tác tử). Không giống một chatbot chỉ trả lời câu hỏi rồi chờ đợi, Claude Code có thể đọc file của bạn, chạy lệnh, thực hiện thay đổi và tự động giải quyết vấn đề trong khi bạn quan sát, điều hướng lại, hoặc rời đi hoàn toàn.

Điều này thay đổi cách bạn làm việc. Thay vì tự viết code rồi nhờ Claude xem lại, bạn mô tả điều bạn muốn và Claude tự tìm ra cách xây dựng nó. Claude khám phá, lập kế hoạch và triển khai.

Nhưng khả năng tự chủ này vẫn đi kèm một quá trình làm quen. Claude làm việc trong một số ràng buộc mà bạn cần hiểu.

Hướng dẫn này trình bày các mẫu hình đã được chứng minh là hiệu quả trong các nhóm nội bộ của Anthropic và với các kỹ sư sử dụng Claude Code trên nhiều codebase, ngôn ngữ và môi trường khác nhau. Để hiểu vòng lặp agentic hoạt động bên trong ra sao, xem [Cách Claude Code hoạt động](/en/how-claude-code-works).

***

Hầu hết các thực hành tốt nhất đều dựa trên một ràng buộc: context window (cửa sổ ngữ cảnh) của Claude đầy lên nhanh chóng, và hiệu năng suy giảm khi nó đầy dần.

Context window của Claude lưu toàn bộ cuộc trò chuyện của bạn, bao gồm mọi tin nhắn, mọi file Claude đọc, và mọi kết quả lệnh. Tuy nhiên, nó có thể đầy lên rất nhanh. Một phiên gỡ lỗi hoặc khám phá codebase có thể tạo ra và tiêu thụ hàng chục nghìn token.

Điều này quan trọng vì hiệu năng của LLM suy giảm khi context đầy dần. Khi context window gần đầy, Claude có thể bắt đầu "quên" các chỉ dẫn trước đó hoặc mắc nhiều lỗi hơn. Context window là tài nguyên quan trọng nhất cần quản lý. Để xem một phiên đầy lên trên thực tế như thế nào, [xem hướng dẫn tương tác](/en/context-window) về những gì được nạp lúc khởi động và chi phí của mỗi lần đọc file. Theo dõi mức sử dụng context liên tục với một [status line tùy chỉnh](/en/statusline), và xem [Giảm mức sử dụng token](/en/costs#reduce-token-usage) để biết các chiến lược giảm mức dùng token.

***

## Cho Claude một cách để kiểm chứng công việc của nó

<Tip>
  Hãy cho Claude một phép kiểm tra mà nó có thể chạy: các bài test, một bản build, một ảnh chụp màn hình để so sánh. Đó là sự khác biệt giữa một phiên bạn phải ngồi canh và một phiên bạn có thể bỏ đi làm việc khác.
</Tip>

Claude dừng lại khi công việc trông có vẻ đã xong. Nếu không có phép kiểm tra nào để chạy, "trông có vẻ xong" là tín hiệu duy nhất có sẵn, và bạn trở thành vòng lặp kiểm chứng: mọi lỗi đều phải chờ bạn phát hiện. Hãy cho Claude thứ gì đó tạo ra kết quả đạt hoặc không đạt, và vòng lặp sẽ tự khép lại. Claude làm việc, chạy phép kiểm tra, đọc kết quả, và lặp lại cho đến khi phép kiểm tra đạt.

Phép kiểm tra là bất cứ thứ gì trả về một tín hiệu mà Claude có thể đọc trong cuộc trò chuyện: một bộ test, mã thoát (exit code) của bản build, một linter, một script so sánh output với một fixture, hoặc một [ảnh chụp màn hình trình duyệt](/en/chrome) so với thiết kế.

| Chiến lược                              | Trước                                                  | Sau                                                                                                                                                                                                   |
| ------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cung cấp tiêu chí kiểm chứng**     | *"triển khai một hàm xác thực địa chỉ email"* | *"viết một hàm validateEmail. ví dụ các test case: [user@example.com](mailto:user@example.com) là true, invalid là false, [user@.com](mailto:user@.com) là false. chạy test sau khi triển khai"* |
| **Kiểm chứng thay đổi UI bằng hình ảnh**        | *"làm cho dashboard trông đẹp hơn"*                      | *"\[dán ảnh chụp màn hình] triển khai thiết kế này. chụp màn hình kết quả và so sánh với bản gốc. liệt kê các điểm khác biệt và sửa chúng"*                                                            |
| **Xử lý nguyên nhân gốc, không phải triệu chứng** | *"bản build đang lỗi"*                                | *"bản build lỗi với thông báo này: \[dán lỗi]. sửa nó và kiểm chứng bản build thành công. xử lý nguyên nhân gốc, đừng che giấu lỗi"*                                                             |

Một khi đã có phép kiểm tra, hãy quyết định nó chặn việc dừng chặt đến mức nào:

* **Trong một prompt**: yêu cầu Claude chạy phép kiểm tra và lặp lại ngay trong cùng một tin nhắn, như trong bảng trên.
* **Xuyên suốt một phiên**: đặt phép kiểm tra thành một [điều kiện `/goal`](/en/goal). Một bộ đánh giá riêng biệt sẽ kiểm tra lại nó sau mỗi lượt và Claude tiếp tục làm việc cho đến khi nó thỏa mãn.
* **Như một cổng chặn xác định (deterministic gate)**: một [Stop hook](/en/hooks#stop) chạy phép kiểm tra của bạn dưới dạng một script và chặn lượt kết thúc cho đến khi nó đạt. Claude Code ghi đè hook và kết thúc lượt sau 8 lần chặn liên tiếp.
* **Bằng ý kiến thứ hai**: một [subagent kiểm chứng](/en/sub-agents) hoặc một [workflow động](/en/workflows) tự kiểm tra phát hiện của chính nó bằng cách để một model mới thử bác bỏ kết quả, để agent làm việc không phải là agent chấm điểm.

Mỗi bước đánh đổi công sức thiết lập lấy sự tập trung. Phiên bản dùng prompt hoạt động cho bất kỳ tác vụ nào ngay hôm nay. Các phiên bản `/goal` và Stop hook là thứ giúp một lượt chạy không giám sát hoàn thành đúng đắn mà không cần bạn.

Hãy để Claude đưa ra bằng chứng thay vì khẳng định thành công: output của test, lệnh nó đã chạy và kết quả trả về, hoặc một ảnh chụp màn hình của kết quả. Xem lại bằng chứng nhanh hơn tự chạy lại việc kiểm chứng, và nó hiệu quả cho cả những phiên bạn không quan sát.

***

## Khám phá trước, rồi lập kế hoạch, rồi mới code

<Tip>
  Tách phần nghiên cứu và lập kế hoạch khỏi phần triển khai để tránh giải sai vấn đề.
</Tip>

Để Claude nhảy thẳng vào code có thể tạo ra code giải sai vấn đề. Hãy dùng [plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode) để tách phần khám phá khỏi phần thực thi.

Workflow được khuyến nghị có bốn giai đoạn:

<Steps>
  <Step title="Khám phá">
    Vào plan mode. Claude đọc file và trả lời câu hỏi mà không thực hiện thay đổi.

    ```txt claude (plan mode) theme={null}
    read /src/auth and understand how we handle sessions and login.
    also look at how we manage environment variables for secrets.
    ```
  </Step>

  <Step title="Lập kế hoạch">
    Yêu cầu Claude tạo một kế hoạch triển khai chi tiết.

    ```txt claude (plan mode) theme={null}
    I want to add Google OAuth. What files need to change?
    What's the session flow? Create a plan.
    ```

    Nhấn `Ctrl+G` để mở kế hoạch trong trình soạn thảo văn bản của bạn để chỉnh sửa trực tiếp trước khi Claude tiếp tục.
  </Step>

  <Step title="Triển khai">
    Chuyển ra khỏi plan mode và để Claude code, kiểm chứng lại theo kế hoạch của nó.

    ```txt claude (default mode) theme={null}
    implement the OAuth flow from your plan. write tests for the
    callback handler, run the test suite and fix any failures.
    ```
  </Step>

  <Step title="Commit">
    Yêu cầu Claude commit với một thông điệp mô tả và tạo một PR.

    ```txt claude (default mode) theme={null}
    commit with a descriptive message and open a PR
    ```
  </Step>
</Steps>

<Callout>
  Plan mode hữu ích, nhưng cũng thêm chi phí phụ (overhead).

  Với các tác vụ mà phạm vi đã rõ ràng và cách sửa nhỏ (như sửa một lỗi chính tả, thêm một dòng log, hoặc đổi tên một biến) hãy yêu cầu Claude làm trực tiếp.

  Lập kế hoạch hữu ích nhất khi bạn không chắc về cách tiếp cận, khi thay đổi động chạm nhiều file, hoặc khi bạn chưa quen với đoạn code đang được chỉnh sửa. Nếu bạn có thể mô tả diff trong một câu, hãy bỏ qua bước lập kế hoạch.
</Callout>

***

## Cung cấp ngữ cảnh cụ thể trong prompt của bạn

<Tip>
  Chỉ dẫn của bạn càng chính xác, bạn càng ít phải chỉnh sửa.
</Tip>

Claude có thể suy luận ý định, nhưng nó không đọc được suy nghĩ của bạn. Hãy tham chiếu các file cụ thể, nêu ra các ràng buộc, và chỉ tới các mẫu hình làm ví dụ.

| Chiến lược                                                                                         | Trước                                               | Sau                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Xác định phạm vi tác vụ.** Chỉ rõ file nào, kịch bản gì, và ưu tiên về việc test.                  | *"add tests for foo.py"*                             | *"write a test for foo.py covering the edge case where the user is logged out. avoid mocks."*                                                                                                                                                                                                                                                                    |
| **Chỉ tới nguồn.** Hướng Claude tới nguồn có thể trả lời một câu hỏi.                    | *"why does ExecutionFactory have such a weird api?"* | *"look through ExecutionFactory's git history and summarize how its api came to be"*                                                                                                                                                                                                                                                                             |
| **Tham chiếu các mẫu hình có sẵn.** Chỉ Claude tới các mẫu hình trong codebase của bạn.                      | *"add a calendar widget"*                            | *"look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern to implement a new calendar widget that lets the user select a month and paginate forwards/backwards to pick a year. build from scratch without libraries other than the ones already used in the codebase."* |
| **Mô tả triệu chứng.** Cung cấp triệu chứng, vị trí có khả năng, và "sửa xong" trông ra sao. | *"fix the login bug"*                                | *"users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it"*                                                                                                                                                                                 |

Prompt mơ hồ có thể hữu ích khi bạn đang khám phá và có thể chấp nhận việc điều chỉnh giữa chừng. Một prompt như `"what would you improve in this file?"` có thể phát hiện những điều bạn không nghĩ tới để hỏi.

### Cung cấp nội dung phong phú

<Tip>
  Dùng `@` để tham chiếu file, dán ảnh chụp màn hình/hình ảnh, hoặc pipe dữ liệu trực tiếp.
</Tip>

Bạn có thể cung cấp dữ liệu phong phú cho Claude theo nhiều cách:

* **Tham chiếu file bằng `@`** thay vì mô tả code nằm ở đâu. Claude sẽ đọc file trước khi trả lời.
* **Dán ảnh trực tiếp**. Copy/paste hoặc kéo thả hình ảnh vào prompt.
* **Cung cấp URL** cho tài liệu và tài liệu tham khảo API. Dùng `/permissions` để đưa vào danh sách cho phép các tên miền hay dùng.
* **Pipe dữ liệu vào** bằng cách chạy `cat error.log | claude` để gửi nội dung file trực tiếp.
* **Để Claude tự lấy thứ nó cần**. Bảo Claude tự kéo ngữ cảnh về bằng lệnh Bash, công cụ MCP, hoặc bằng cách đọc file.

***

## Cấu hình môi trường của bạn

Một vài bước thiết lập giúp Claude Code hiệu quả hơn đáng kể trên tất cả các phiên của bạn. Để có cái nhìn tổng quan đầy đủ về các tính năng mở rộng và khi nào dùng từng cái, xem [Mở rộng Claude Code](/en/features-overview).

### Viết một CLAUDE.md hiệu quả

<Tip>
  Chạy `/init` để tạo một file CLAUDE.md khởi đầu dựa trên cấu trúc dự án hiện tại của bạn, rồi tinh chỉnh dần theo thời gian.
</Tip>

CLAUDE.md là một file đặc biệt mà Claude đọc ở đầu mỗi cuộc trò chuyện. Hãy đưa vào các lệnh Bash, phong cách code, và quy tắc workflow. Điều này cho Claude ngữ cảnh bền vững mà nó không thể suy ra chỉ từ code.

Lệnh `/init` phân tích codebase của bạn để phát hiện hệ thống build, framework test, và các mẫu hình code, cho bạn một nền tảng vững chắc để tinh chỉnh.

Không có định dạng bắt buộc cho file CLAUDE.md, nhưng hãy giữ nó ngắn gọn và dễ đọc cho con người. Ví dụ:

```markdown CLAUDE.md theme={null}
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
```

CLAUDE.md được nạp mỗi phiên, nên chỉ đưa vào những thứ áp dụng rộng rãi. Với kiến thức chuyên ngành hoặc workflow chỉ đôi khi liên quan, hãy dùng [skill](/en/skills) thay thế. Claude nạp chúng theo yêu cầu mà không làm phình mọi cuộc trò chuyện.

Giữ nó súc tích. Với mỗi dòng, hãy tự hỏi: *"Việc xóa dòng này có khiến Claude mắc lỗi không?"* Nếu không, hãy cắt bỏ. File CLAUDE.md phình to khiến Claude bỏ qua các chỉ dẫn thực sự của bạn!

| ✅ Nên đưa vào                                            | ❌ Nên loại bỏ                                          |
| ---------------------------------------------------- | -------------------------------------------------- |
| Các lệnh Bash mà Claude không thể đoán được                     | Bất cứ thứ gì Claude có thể tự tìm ra bằng cách đọc code     |
| Quy tắc phong cách code khác với mặc định           | Quy ước ngôn ngữ chuẩn mà Claude đã biết |
| Chỉ dẫn về test và bộ chạy test ưa dùng      | Tài liệu API chi tiết (thay vào đó hãy liên kết tới docs)  |
| Quy tắc ứng xử với repository (đặt tên nhánh, quy ước PR) | Thông tin thay đổi thường xuyên               |
| Quyết định kiến trúc riêng cho dự án của bạn         | Giải thích dài dòng hoặc hướng dẫn từng bước                |
| Điểm đặc thù của môi trường lập trình (biến môi trường bắt buộc)     | Mô tả codebase theo từng file           |
| Những cạm bẫy phổ biến hoặc hành vi không hiển nhiên          | Các thực hành hiển nhiên như "viết code sạch"    |

Nếu Claude cứ tiếp tục làm điều bạn không muốn dù đã có quy tắc cấm, file có lẽ quá dài và quy tắc bị lạc mất. Nếu Claude hỏi bạn những câu đã được trả lời trong CLAUDE.md, cách diễn đạt có thể mơ hồ. Hãy coi CLAUDE.md như code: xem lại nó khi mọi thứ trục trặc, cắt tỉa thường xuyên, và kiểm tra thay đổi bằng cách quan sát xem hành vi của Claude có thực sự thay đổi hay không.

Bạn có thể tinh chỉnh chỉ dẫn bằng cách thêm nhấn mạnh (ví dụ "IMPORTANT" hoặc "YOU MUST") để cải thiện mức tuân thủ. Đưa CLAUDE.md vào git để nhóm của bạn có thể đóng góp. Giá trị của file này cộng dồn theo thời gian.

File CLAUDE.md có thể import thêm các file khác bằng cú pháp `@path/to/import`:

```markdown CLAUDE.md theme={null}
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

Bạn có thể đặt file CLAUDE.md ở nhiều vị trí:

* **Thư mục home (`~/.claude/CLAUDE.md`)**: áp dụng cho tất cả các phiên Claude
* **Gốc dự án (`./CLAUDE.md`)**: đưa vào git để chia sẻ với nhóm của bạn
* **Gốc dự án (`./CLAUDE.local.md`)**: ghi chú riêng cho dự án; thêm file này vào `.gitignore` để nó không bị chia sẻ với nhóm
* **Thư mục cha**: hữu ích cho monorepo nơi cả `root/CLAUDE.md` và `root/foo/CLAUDE.md` đều được tự động kéo vào
* **Thư mục con**: Claude kéo các file CLAUDE.md con vào theo yêu cầu khi nó đọc một file trong các thư mục đó

### Cấu hình quyền (permissions)

<Tip>
  Dùng [auto mode](/en/permission-modes#eliminate-prompts-with-auto-mode) để một bộ phân loại xử lý việc phê duyệt, `/permissions` để đưa các lệnh cụ thể vào danh sách cho phép, hoặc `/sandbox` để cô lập ở cấp hệ điều hành. Mỗi cách đều giảm gián đoạn trong khi vẫn giữ bạn ở thế kiểm soát.
</Tip>

Theo mặc định, Claude Code yêu cầu quyền cho các hành động có thể chỉnh sửa hệ thống của bạn: ghi file, lệnh Bash, công cụ MCP, v.v. Điều này an toàn nhưng tẻ nhạt. Sau lần phê duyệt thứ mười, bạn không thực sự xem xét nữa mà chỉ bấm qua loa. Có ba cách giảm những gián đoạn này:

* **Auto mode**: một model phân loại riêng biệt xem xét các lệnh và chỉ chặn những gì trông có vẻ rủi ro: leo thang phạm vi, hạ tầng chưa biết, hoặc hành động bị điều khiển bởi nội dung thù địch. Tốt nhất khi bạn tin tưởng hướng đi chung của một tác vụ nhưng không muốn bấm qua từng bước
* **Danh sách cho phép quyền (Permission allowlists)**: cho phép các công cụ cụ thể bạn biết là an toàn, như `npm run lint` hoặc `git commit`
* **Sandboxing**: bật cô lập ở cấp hệ điều hành hạn chế truy cập hệ thống file và mạng, cho phép Claude làm việc tự do hơn trong các ranh giới đã định

Đọc thêm về [permission modes](/en/permission-modes), [quy tắc quyền](/en/permissions), và [sandboxing](/en/sandboxing).

### Dùng các công cụ CLI

<Tip>
  Bảo Claude Code dùng các công cụ CLI như `gh`, `aws`, `gcloud`, và `sentry-cli` khi tương tác với các dịch vụ bên ngoài.
</Tip>

Công cụ CLI là cách tương tác với dịch vụ bên ngoài tiết kiệm ngữ cảnh nhất. Nếu bạn dùng GitHub, hãy cài `gh` CLI. Claude biết cách dùng nó để tạo issue, mở pull request, và đọc comment. Không có `gh`, Claude vẫn có thể dùng GitHub API, nhưng các yêu cầu không xác thực thường bị giới hạn tốc độ (rate limit).

Claude cũng rất giỏi học các công cụ CLI mà nó chưa biết. Thử các prompt như `Use 'foo-cli-tool --help' to learn about foo tool, then use it to solve A, B, C.`

### Kết nối MCP server

<Tip>
  Chạy `claude mcp add` để kết nối các công cụ bên ngoài như Notion, Figma, hoặc cơ sở dữ liệu của bạn.
</Tip>

Với [MCP server](/en/mcp), bạn có thể yêu cầu Claude triển khai tính năng từ hệ thống theo dõi issue, truy vấn cơ sở dữ liệu, phân tích dữ liệu giám sát, tích hợp thiết kế từ Figma, và tự động hóa workflow.

### Thiết lập hook

<Tip>
  Dùng hook cho các hành động phải xảy ra mỗi lần với không có ngoại lệ.
</Tip>

[Hook](/en/hooks-guide) chạy script tự động tại các thời điểm cụ thể trong workflow của Claude. Không giống các chỉ dẫn trong CLAUDE.md vốn chỉ mang tính khuyến nghị, hook mang tính xác định và đảm bảo hành động xảy ra.

Claude có thể viết hook cho bạn. Thử các prompt như *"Write a hook that runs eslint after every file edit"* hoặc *"Write a hook that blocks writes to the migrations folder."* Chỉnh sửa `.claude/settings.json` trực tiếp để cấu hình hook bằng tay, và chạy `/hooks` để duyệt xem những gì đã được cấu hình.

### Tạo skill

<Tip>
  Tạo các file `SKILL.md` trong `.claude/skills/` để cho Claude kiến thức chuyên ngành và các workflow tái sử dụng được.
</Tip>

[Skill](/en/skills) mở rộng kiến thức của Claude với thông tin đặc thù cho dự án, nhóm, hoặc lĩnh vực của bạn. Claude áp dụng chúng tự động khi liên quan, hoặc bạn có thể gọi trực tiếp bằng `/skill-name`.

Tạo một skill bằng cách thêm một thư mục có file `SKILL.md` vào `.claude/skills/`:

```markdown .claude/skills/api-conventions/SKILL.md theme={null}
---
name: api-conventions
description: REST API design conventions for our services
---
# API Conventions
- Use kebab-case for URL paths
- Use camelCase for JSON properties
- Always include pagination for list endpoints
- Version APIs in the URL path (/v1/, /v2/)
```

Skill cũng có thể định nghĩa các workflow lặp lại mà bạn gọi trực tiếp:

```markdown .claude/skills/fix-issue/SKILL.md theme={null}
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---
Analyze and fix the GitHub issue: $ARGUMENTS.

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR
```

Chạy `/fix-issue 1234` để gọi nó. Dùng `disable-model-invocation: true` cho các workflow có tác dụng phụ mà bạn muốn kích hoạt thủ công.

### Tạo subagent tùy chỉnh

<Tip>
  Định nghĩa các trợ lý chuyên biệt trong `.claude/agents/` mà Claude có thể ủy thác cho các tác vụ cô lập.
</Tip>

[Subagent](/en/sub-agents) chạy trong ngữ cảnh riêng với bộ công cụ được phép riêng. Chúng hữu ích cho các tác vụ đọc nhiều file hoặc cần sự tập trung chuyên biệt mà không làm lộn xộn cuộc trò chuyện chính của bạn.

```markdown .claude/agents/security-reviewer.md theme={null}
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

Bảo Claude dùng subagent một cách tường minh: *"Use a subagent to review this code for security issues."*

### Cài đặt plugin

<Tip>
  Chạy `/plugin` để duyệt marketplace. Plugin thêm skill, công cụ, và tích hợp mà không cần cấu hình.
</Tip>

[Plugin](/en/plugins) đóng gói skill, hook, subagent, và MCP server thành một đơn vị cài đặt được duy nhất từ cộng đồng và Anthropic. Nếu bạn làm việc với ngôn ngữ có kiểu tĩnh (typed language), hãy cài một [plugin trí tuệ code (code intelligence)](/en/discover-plugins#code-intelligence) để cho Claude khả năng điều hướng symbol chính xác và tự động phát hiện lỗi sau khi chỉnh sửa.

Để được hướng dẫn cách chọn giữa skill, subagent, hook, và MCP, xem [Mở rộng Claude Code](/en/features-overview#match-features-to-your-goal).

***

## Giao tiếp hiệu quả

Cách bạn giao tiếp với Claude Code ảnh hưởng đáng kể tới chất lượng kết quả.

### Đặt câu hỏi về codebase

<Tip>
  Hãy hỏi Claude những câu bạn sẽ hỏi một kỹ sư cao cấp.
</Tip>

Khi làm quen với một codebase mới, hãy dùng Claude Code để học hỏi và khám phá. Bạn có thể hỏi Claude những loại câu hỏi mà bạn sẽ hỏi một kỹ sư khác:

* Logging hoạt động như thế nào?
* Làm sao để tạo một API endpoint mới?
* `async move { ... }` ở dòng 134 của `foo.rs` làm gì?
* `CustomerOnboardingFlowImpl` xử lý những trường hợp biên nào?
* Tại sao đoạn code này gọi `foo()` thay vì `bar()` ở dòng 333?

Dùng Claude Code theo cách này là một workflow làm quen hiệu quả, cải thiện thời gian bắt nhịp và giảm tải cho các kỹ sư khác. Không cần prompt đặc biệt: cứ hỏi trực tiếp.

### Để Claude phỏng vấn bạn

<Tip>
  Với các tính năng lớn hơn, hãy để Claude phỏng vấn bạn trước. Bắt đầu với một prompt tối giản và yêu cầu Claude phỏng vấn bạn bằng công cụ `AskUserQuestion`.
</Tip>

Claude hỏi về những điều bạn có thể chưa cân nhắc tới, bao gồm triển khai kỹ thuật, UI/UX, trường hợp biên, và các đánh đổi.

```text theme={null}
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions, dig into the hard parts I might not have considered.

Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

Một khi spec hoàn tất, hãy bắt đầu một phiên mới để thực thi nó. Phiên mới có ngữ cảnh sạch tập trung hoàn toàn vào việc triển khai, và bạn có một spec viết sẵn để tham chiếu.

Các spec hữu ích nhất là những spec tự chứa: chúng nêu tên các file và interface liên quan, nêu rõ điều gì nằm ngoài phạm vi, và kết thúc bằng một bước kiểm chứng đầu-cuối chứng minh tính năng hoạt động. Thời gian bỏ ra để làm spec chính xác đem lại lợi ích nhiều hơn thời gian ngồi xem quá trình triển khai.

***

## Quản lý phiên của bạn

Các cuộc trò chuyện có tính bền vững và có thể đảo ngược. Hãy tận dụng điều này!

### Điều chỉnh hướng sớm và thường xuyên

<Tip>
  Hãy điều chỉnh Claude ngay khi bạn nhận thấy nó đi lệch hướng.
</Tip>

Kết quả tốt nhất đến từ các vòng phản hồi chặt chẽ. Dù đôi khi Claude giải quyết vấn đề hoàn hảo ngay lần đầu, việc điều chỉnh nó nhanh chóng nhìn chung tạo ra giải pháp tốt hơn nhanh hơn.

* **`Esc`**: dừng Claude giữa chừng bằng phím `Esc`. Ngữ cảnh được giữ lại, nên bạn có thể điều hướng lại.
* **`Esc + Esc` hoặc `/rewind`**: nhấn `Esc` hai lần hoặc chạy `/rewind` để mở menu tua lại và khôi phục trạng thái cuộc trò chuyện và code trước đó, hoặc tóm tắt từ một tin nhắn được chọn.
* **`"Undo that"`**: bảo Claude hoàn tác các thay đổi của nó.
* **`/clear`**: đặt lại ngữ cảnh giữa các tác vụ không liên quan. Phiên dài với ngữ cảnh không liên quan có thể làm giảm hiệu năng.

Nếu bạn đã điều chỉnh Claude hơn hai lần về cùng một vấn đề trong một phiên, ngữ cảnh đã bị lộn xộn với các cách tiếp cận thất bại. Chạy `/clear` và bắt đầu lại với một prompt cụ thể hơn kết hợp những gì bạn đã học được. Một phiên sạch với prompt tốt hơn hầu như luôn vượt trội một phiên dài với các điều chỉnh tích lũy.

### Quản lý ngữ cảnh một cách quyết liệt

<Tip>
  Chạy `/clear` giữa các tác vụ không liên quan để đặt lại ngữ cảnh.
</Tip>

Claude Code tự động nén lịch sử cuộc trò chuyện khi bạn tiến gần tới giới hạn ngữ cảnh, việc này giữ lại code và quyết định quan trọng trong khi giải phóng không gian.

Trong các phiên dài, context window của Claude có thể đầy lên với các cuộc trò chuyện, nội dung file, và lệnh không liên quan. Điều này có thể làm giảm hiệu năng và đôi khi làm Claude sao lãng.

* Dùng `/clear` thường xuyên giữa các tác vụ để đặt lại hoàn toàn context window
* Khi nén tự động kích hoạt, Claude tóm tắt những gì quan trọng nhất, bao gồm mẫu hình code, trạng thái file, và các quyết định then chốt
* Để kiểm soát nhiều hơn, chạy `/compact <instructions>`, như `/compact Focus on the API changes`
* Để chỉ nén một phần cuộc trò chuyện, dùng `Esc + Esc` hoặc `/rewind`, chọn một checkpoint tin nhắn, và chọn **Summarize from here** hoặc **Summarize up to here**. Cái đầu cô đọng các tin nhắn từ điểm đó trở đi trong khi giữ nguyên ngữ cảnh trước đó; cái sau cô đọng các tin nhắn trước đó trong khi giữ nguyên các tin nhắn gần đây. Xem [Restore vs. summarize](/en/checkpointing#restore-vs-summarize).
* Tùy chỉnh hành vi nén trong CLAUDE.md với các chỉ dẫn như `"When compacting, always preserve the full list of modified files and any test commands"` để đảm bảo ngữ cảnh quan trọng sống sót qua quá trình tóm tắt
* Với các câu hỏi nhanh không cần lưu trong ngữ cảnh, dùng [`/btw`](/en/interactive-mode#side-questions-with-%2Fbtw). Câu trả lời xuất hiện trong một lớp phủ có thể đóng lại và không bao giờ đi vào lịch sử cuộc trò chuyện, nên bạn có thể kiểm tra một chi tiết mà không làm ngữ cảnh phình ra.

### Dùng subagent để điều tra

<Tip>
  Ủy thác việc nghiên cứu với `"use subagents to investigate X"`. Chúng khám phá trong ngữ cảnh riêng, giữ cuộc trò chuyện chính của bạn sạch sẽ cho việc triển khai.
</Tip>

Vì ngữ cảnh là ràng buộc cốt yếu của bạn, subagent là một trong những công cụ mạnh nhất có sẵn. Khi Claude nghiên cứu một codebase, nó đọc rất nhiều file, tất cả đều tiêu thụ ngữ cảnh của bạn. Subagent chạy trong context window riêng và báo cáo lại các bản tóm tắt:

```text theme={null}
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```

Subagent khám phá codebase, đọc các file liên quan, và báo cáo lại các phát hiện, tất cả mà không làm lộn xộn cuộc trò chuyện chính của bạn.

Bạn cũng có thể dùng subagent để kiểm chứng sau khi Claude triển khai xong thứ gì đó:

```text theme={null}
use a subagent to review this code for edge cases
```

### Tua lại với checkpoint

<Tip>
  Mỗi prompt bạn gửi tạo ra một checkpoint. Bạn có thể khôi phục cuộc trò chuyện, code, hoặc cả hai về bất kỳ checkpoint nào trước đó.
</Tip>

Claude tự động chụp nhanh (snapshot) các file trước mỗi thay đổi để một checkpoint có thể khôi phục chúng. Nhấn `Escape` hai lần hoặc chạy `/rewind` để mở menu tua lại. Bạn có thể chỉ khôi phục cuộc trò chuyện, chỉ khôi phục code, khôi phục cả hai, hoặc tóm tắt từ một tin nhắn được chọn. Xem [Checkpointing](/en/checkpointing) để biết chi tiết.

Thay vì lên kế hoạch cẩn thận từng bước đi, bạn có thể bảo Claude thử một điều gì đó mạo hiểm. Nếu không hiệu quả, hãy tua lại và thử một cách tiếp cận khác. Checkpoint tồn tại qua các phiên, nên bạn có thể đóng terminal và vẫn tua lại về sau.

<Warning>
  Checkpoint chỉ theo dõi các thay đổi do *Claude* thực hiện, không phải các tiến trình bên ngoài. Đây không phải là thứ thay thế cho git.
</Warning>

### Tiếp tục lại cuộc trò chuyện

<Tip>
  Đặt tên phiên với `/rename` và coi chúng như các nhánh: mỗi luồng công việc có ngữ cảnh bền vững riêng.
</Tip>

Claude Code lưu các cuộc trò chuyện cục bộ, nên khi một tác vụ trải dài qua nhiều lần ngồi làm bạn không phải giải thích lại ngữ cảnh. Chạy `claude --continue` để tiếp tục phiên gần nhất, hoặc `claude --resume` để chọn từ một danh sách. Đặt cho các phiên những tên mô tả như `oauth-migration` để bạn có thể tìm chúng về sau. Xem [Quản lý phiên](/en/sessions) để biết đầy đủ các điều khiển tiếp tục, phân nhánh và đặt tên.

***

## Tự động hóa và mở rộng quy mô

Một khi bạn đã hiệu quả với một Claude, hãy nhân bội đầu ra của bạn với các phiên song song, chế độ không tương tác (non-interactive mode), và các mẫu hình fan-out (tỏa rộng).

Mọi thứ từ đầu tới giờ đều giả định một con người, một Claude, và một cuộc trò chuyện. Nhưng Claude Code mở rộng theo chiều ngang. Các kỹ thuật trong phần này cho thấy cách bạn có thể làm được nhiều hơn.

### Chạy chế độ không tương tác

<Tip>
  Dùng `claude -p "prompt"` trong CI, pre-commit hook, hoặc script. Thêm `--output-format stream-json --verbose` để có output JSON dạng streaming.
</Tip>

Với `claude -p "your prompt"`, bạn có thể chạy Claude ở chế độ không tương tác, không cần một phiên. [Chế độ không tương tác](/en/headless) là cách bạn tích hợp Claude vào pipeline CI, pre-commit hook, hoặc bất kỳ workflow tự động nào. Các định dạng output cho phép bạn phân tích kết quả theo chương trình: văn bản thuần, JSON, hoặc JSON dạng streaming.

```bash theme={null}
# One-off queries
claude -p "Explain what this project does"

# Structured output for scripts
claude -p "List all API endpoints" --output-format json

# Streaming for real-time processing
claude -p "Analyze this log file" --output-format stream-json --verbose
```

### Chạy nhiều phiên Claude

<Tip>
  Chạy nhiều phiên Claude song song để tăng tốc phát triển, chạy các thử nghiệm cô lập, hoặc khởi động các workflow phức tạp.
</Tip>

Hãy chọn cách tiếp cận song song phù hợp với mức độ điều phối bạn muốn tự mình làm:

* [Worktree](/en/worktrees): chạy các phiên CLI riêng biệt trong các checkout git cô lập để các chỉnh sửa không đụng nhau
* [Ứng dụng desktop](/en/desktop#work-in-parallel-with-sessions): quản lý nhiều phiên cục bộ một cách trực quan, mỗi phiên trong worktree riêng
* [Claude Code trên web](/en/claude-code-on-the-web): chạy các phiên trên hạ tầng đám mây do Anthropic quản lý trong các VM cô lập
* [Agent teams](/en/agent-teams): điều phối tự động nhiều phiên với các tác vụ chung, nhắn tin, và một team lead

Ngoài việc song song hóa công việc, nhiều phiên còn cho phép các workflow tập trung vào chất lượng. Một ngữ cảnh mới cải thiện việc review code vì Claude sẽ không bị thiên vị về phía code mà nó vừa viết.

Ví dụ, dùng mẫu hình Writer/Reviewer (Người viết/Người review):

| Phiên A (Writer)                                                      | Phiên B (Reviewer)                                                                                                                                                     |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Implement a rate limiter for our API endpoints`                        |                                                                                                                                                                          |
|                                                                         | `Review the rate limiter implementation in @src/middleware/rateLimiter.ts. Look for edge cases, race conditions, and consistency with our existing middleware patterns.` |
| `Here's the review feedback: [Session B output]. Address these issues.` |                                                                                                                                                                          |

Bạn có thể làm điều tương tự với test: cho một Claude viết test, rồi một Claude khác viết code để vượt qua chúng.

### Tỏa rộng (fan out) qua nhiều file

<Tip>
  Lặp qua các tác vụ bằng cách gọi `claude -p` cho mỗi tác vụ. Dùng `--allowedTools` để giới hạn phạm vi quyền cho các thao tác hàng loạt.
</Tip>

Với các cuộc migration hoặc phân tích lớn, bạn có thể phân phối công việc qua nhiều lần gọi Claude song song:

<Steps>
  <Step title="Tạo một danh sách tác vụ">
    Cho Claude liệt kê tất cả file cần migrate (ví dụ, `list all 2,000 Python files that need migrating`)
  </Step>

  <Step title="Viết một script để lặp qua danh sách">
    ```bash theme={null}
    for file in $(cat files.txt); do
      claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
        --allowedTools "Edit,Bash(git commit *)"
    done
    ```
  </Step>

  <Step title="Test trên vài file, rồi chạy ở quy mô lớn">
    Tinh chỉnh prompt của bạn dựa trên những gì sai với 2-3 file đầu tiên, rồi chạy trên toàn bộ tập. Cờ `--allowedTools` hạn chế những gì Claude có thể làm, điều quan trọng khi bạn chạy không giám sát.
  </Step>
</Steps>

Bạn cũng có thể tích hợp Claude vào các pipeline dữ liệu/xử lý có sẵn:

```bash theme={null}
claude -p "<your prompt>" --output-format json | your_command
```

Dùng `--verbose` để gỡ lỗi trong quá trình phát triển, và tắt nó trong môi trường production.

### Chạy tự chủ với auto mode

Để thực thi liên tục không gián đoạn với các kiểm tra an toàn chạy nền, hãy dùng [auto mode](/en/permission-modes#eliminate-prompts-with-auto-mode). Một model phân loại xem xét các lệnh trước khi chúng chạy, chặn leo thang phạm vi, hạ tầng chưa biết, và các hành động bị điều khiển bởi nội dung thù địch trong khi để công việc thường lệ tiến hành mà không cần hỏi.

```bash theme={null}
claude --permission-mode auto -p "fix all lint errors"
```

Với các lượt chạy không tương tác dùng cờ `-p`, auto mode sẽ hủy nếu bộ phân loại liên tục chặn các hành động, vì không có người dùng để dựa vào. Xem [khi nào auto mode quay về (fall back)](/en/permission-modes#when-auto-mode-falls-back) để biết các ngưỡng.

### Thêm một bước review đối kháng (adversarial)

<Tip>
  Trước khi coi một tác vụ là đã xong, hãy để một subagent review diff trong một ngữ cảnh mới và báo cáo các lỗ hổng.
</Tip>

Claude làm việc không giám sát càng lâu, một sự kiểm tra độc lập càng quan trọng trước khi bạn tính công việc là đã xong. Một người review chạy trong một ngữ cảnh [subagent](/en/sub-agents) mới chỉ thấy diff và các tiêu chí bạn đưa cho nó, không thấy lập luận đã tạo ra thay đổi, nên nó đánh giá kết quả theo cách của riêng nó.

Để kiểm tra tính đúng đắn, chạy [skill `/code-review`](/en/commands) đi kèm, nó review diff hiện tại để tìm bug trong một subagent mới và trả các phát hiện về phiên. Để thay vào đó kiểm tra diff so với kế hoạch của bạn, hãy tự viết prompt review. Nêu tên công việc cần kiểm tra, kế hoạch để đối chiếu, và điều gì được tính là một phát hiện:

```text theme={null}
Use a subagent to review the rate limiter diff against PLAN.md. Check that
every requirement is implemented, the listed edge cases have tests, and
nothing outside the task's scope changed. Report gaps, not style preferences.
```

Vì người review chạy như một subagent, phiên đang triển khai nhận các lỗ hổng trực tiếp và có thể sửa chúng rồi review lại mà bạn không phải sao chép các phát hiện giữa các cửa sổ. Với các lượt chạy tự chủ dài hơn, một [agent team](/en/agent-teams) có thể duy trì vòng lặp này qua nhiều tác vụ trong khi bạn kiểm tra ngẫu nhiên các phát hiện đã ghi lại.

<Callout>
  Một người review được yêu cầu tìm lỗ hổng thường sẽ báo cáo vài lỗ hổng, ngay cả khi công việc vững chắc, vì đó là điều nó được yêu cầu làm. Chạy theo mọi phát hiện dẫn tới thừa kỹ thuật (over-engineering): các lớp trừu tượng thừa, code phòng thủ, và test cho các trường hợp không thể xảy ra. Hãy bảo người review chỉ đánh dấu các lỗ hổng ảnh hưởng tới tính đúng đắn hoặc các yêu cầu đã nêu, và coi phần còn lại là tùy chọn.
</Callout>

***

## Tránh các mẫu hình thất bại phổ biến

Đây là những sai lầm phổ biến. Nhận ra chúng sớm giúp tiết kiệm thời gian:

* **Phiên "bồn rửa bát" (kitchen sink).** Bạn bắt đầu với một tác vụ, rồi hỏi Claude điều gì đó không liên quan, rồi quay lại tác vụ đầu tiên. Ngữ cảnh đầy thông tin không liên quan.
  > **Cách sửa**: `/clear` giữa các tác vụ không liên quan.
* **Sửa đi sửa lại.** Claude làm sai điều gì đó, bạn sửa nó, nó vẫn sai, bạn sửa lại. Ngữ cảnh bị ô nhiễm với các cách tiếp cận thất bại.
  > **Cách sửa**: Sau hai lần sửa thất bại, `/clear` và viết một prompt ban đầu tốt hơn kết hợp những gì bạn đã học được.
* **CLAUDE.md quá chi tiết.** Nếu CLAUDE.md của bạn quá dài, Claude bỏ qua một nửa nó vì các quy tắc quan trọng bị lạc trong đống nhiễu.
  > **Cách sửa**: Cắt tỉa không thương tiếc. Nếu Claude đã làm điều gì đó đúng mà không cần chỉ dẫn, hãy xóa nó hoặc chuyển nó thành một hook.
* **Khoảng cách tin-rồi-mới-kiểm-chứng.** Claude tạo ra một triển khai trông hợp lý nhưng không xử lý các trường hợp biên.
  > **Cách sửa**: Luôn cung cấp phép kiểm chứng (test, script, ảnh chụp màn hình). Nếu bạn không thể kiểm chứng nó, đừng đưa nó lên production.
* **Khám phá vô tận.** Bạn yêu cầu Claude "điều tra" điều gì đó mà không xác định phạm vi. Claude đọc hàng trăm file, làm đầy ngữ cảnh.
  > **Cách sửa**: Xác định phạm vi điều tra hẹp lại hoặc dùng subagent để việc khám phá không tiêu thụ ngữ cảnh chính của bạn.

***

## Phát triển trực giác của bạn

Các mẫu hình trong hướng dẫn này không phải là bất di bất dịch. Chúng là các điểm khởi đầu nhìn chung hoạt động tốt, nhưng có thể không tối ưu cho mọi tình huống.

Đôi khi bạn *nên* để ngữ cảnh tích lũy vì bạn đang đắm sâu trong một vấn đề phức tạp và lịch sử là có giá trị. Đôi khi bạn nên bỏ qua việc lập kế hoạch và để Claude tự tìm ra vì tác vụ mang tính khám phá. Đôi khi một prompt mơ hồ lại chính xác là điều đúng đắn vì bạn muốn xem Claude diễn giải vấn đề như thế nào trước khi ràng buộc nó.

Hãy chú ý tới điều gì hiệu quả. Khi Claude tạo ra kết quả tuyệt vời, hãy để ý bạn đã làm gì: cấu trúc prompt, ngữ cảnh bạn cung cấp, chế độ bạn đang dùng. Khi Claude vật lộn, hãy tự hỏi tại sao. Ngữ cảnh có quá nhiễu không? Prompt có quá mơ hồ không? Tác vụ có quá lớn cho một lượt xử lý không?

Theo thời gian, bạn sẽ phát triển một trực giác mà không hướng dẫn nào có thể nắm bắt. Bạn sẽ biết khi nào nên cụ thể và khi nào nên mở, khi nào nên lập kế hoạch và khi nào nên khám phá, khi nào nên xóa ngữ cảnh và khi nào nên để nó tích lũy.

## Tài nguyên liên quan

* [Cách Claude Code hoạt động](/en/how-claude-code-works): vòng lặp agentic, công cụ, và quản lý ngữ cảnh
* [Mở rộng Claude Code](/en/features-overview): skill, hook, MCP, subagent, và plugin
* [Các workflow thường gặp](/en/common-workflows): các công thức từng bước cho gỡ lỗi, test, PR, và hơn thế nữa
* [CLAUDE.md](/en/memory): lưu trữ quy ước dự án và ngữ cảnh bền vững
