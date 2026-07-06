> Nguồn: https://code.claude.com/docs/en/costs.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Quản lý chi phí hiệu quả

> Theo dõi mức sử dụng token, đặt giới hạn chi tiêu cho nhóm, và giảm chi phí Claude Code với quản lý ngữ cảnh, lựa chọn model, cài đặt extended thinking, và các hook tiền xử lý.

Claude Code tính phí theo lượng token API tiêu thụ. Về giá của các gói đăng ký (Pro, Max, Team, Enterprise), xem [claude.com/pricing](https://claude.com/pricing). Chi phí trên mỗi lập trình viên khác nhau rất nhiều tùy theo lựa chọn model, kích thước codebase, và các mẫu hình sử dụng như chạy nhiều instance hoặc tự động hóa.

Trên toàn bộ các triển khai doanh nghiệp, chi phí trung bình khoảng \$13 mỗi lập trình viên mỗi ngày hoạt động và \$150-250 mỗi lập trình viên mỗi tháng, với chi phí giữ dưới \$30 mỗi ngày hoạt động cho 90% người dùng. Để ước tính chi tiêu cho nhóm của riêng bạn, hãy bắt đầu với một nhóm thí điểm nhỏ và dùng các công cụ theo dõi bên dưới để thiết lập một đường cơ sở trước khi triển khai rộng hơn.

Trang này trình bày cách [theo dõi chi phí của bạn](#track-your-costs), [quản lý chi phí cho các nhóm](#managing-costs-for-teams), và [giảm mức sử dụng token](#reduce-token-usage).

## Theo dõi chi phí của bạn

### Dùng lệnh `/usage`

<Note>
  Khối Session trong `/usage` hiển thị mức sử dụng token API và dành cho người dùng API. Người đăng ký Claude Max và Pro đã bao gồm mức sử dụng trong gói đăng ký của họ, nên con số chi phí phiên không liên quan tới mục đích thanh toán. Người đăng ký thấy các thanh sử dụng theo gói, thống kê hoạt động, và một bảng phân tích mức sử dụng trên cùng màn hình.
</Note>

Khối Session ở đầu `/usage` hiển thị thống kê chi tiết mức sử dụng token cho phiên hiện tại của bạn. Con số bằng đô la là một ước tính được tính cục bộ từ số lượng token và có thể khác với hóa đơn thực tế của bạn. Để có thông tin thanh toán chính thức, xem trang Usage trong [Claude Console](https://platform.claude.com/usage).

```text theme={null}
Total cost:            $0.55
Total duration (API):  6m 19.7s
Total duration (wall): 6h 33m 10.2s
Total code changes:    0 lines added, 0 lines removed
```

Trên gói Pro, Max, Team, hoặc Enterprise, `/usage` cũng hiển thị một bảng phân tích những gì được tính vào giới hạn gói của bạn. Nó quy mức sử dụng gần đây cho skill, subagent, plugin, và từng MCP server, mỗi cái được hiển thị theo phần trăm của tổng. Nhấn `d` hoặc `w` để chuyển giữa 24 giờ qua và 7 ngày qua. Các con số là gần đúng và được tính từ lịch sử phiên cục bộ trên máy này, nên mức sử dụng từ các thiết bị khác hoặc claude.ai không được bao gồm.

Trong [tiện ích mở rộng VS Code](/en/vs-code#check-account-and-usage), bảng phân tích tương tự xuất hiện trong hộp thoại Account & usage với công tắc Day và Week. Yêu cầu Claude Code v2.1.174 trở lên.

## Quản lý chi phí cho các nhóm

Khi dùng Claude API, bạn có thể [đặt giới hạn chi tiêu workspace](https://platform.claude.com/docs/en/build-with-claude/workspaces#workspace-limits) trên tổng chi tiêu workspace Claude Code. Quản trị viên có thể [xem báo cáo chi phí và mức sử dụng](https://platform.claude.com/docs/en/build-with-claude/workspaces#usage-and-cost-tracking) trong Console.

Trên gói Pro và Max, bạn có thể đặt giới hạn chi tiêu hàng tháng trên tín dụng sử dụng (usage credits) với lệnh `/usage-credits`. Nếu bạn đạt giới hạn đó trong khi vẫn còn tín dụng sử dụng, Claude Code sẽ nhắc bạn nâng hoặc gỡ bỏ giới hạn để bạn có thể tiếp tục mà không rời khỏi CLI. Thay đổi giới hạn yêu cầu quyền truy cập thanh toán trên tài khoản.

<Note>
  Khi bạn xác thực Claude Code với tài khoản Claude Console của mình lần đầu, một workspace tên "Claude Code" được tự động tạo cho bạn. Workspace này cung cấp việc theo dõi và quản lý chi phí tập trung cho tất cả mức sử dụng Claude Code trong tổ chức của bạn. Bạn không thể tạo API key cho workspace này; nó chỉ dành riêng cho việc xác thực và sử dụng Claude Code.

  Với các tổ chức có rate limit tùy chỉnh, lưu lượng Claude Code trong workspace này được tính vào tổng rate limit API của tổ chức bạn. Bạn có thể đặt một [rate limit workspace](https://platform.claude.com/docs/en/api/rate-limits#setting-lower-limits-for-workspaces) trên trang Limits của workspace này trong Claude Console để giới hạn phần của Claude Code và bảo vệ các workload production khác.
</Note>

Trên Amazon Bedrock, Agent Platform của Google Cloud, và Microsoft Foundry, Claude Code không gửi metric từ đám mây của bạn. Một [Claude apps gateway](/en/claude-apps-gateway) tự host cung cấp việc quy mức sử dụng theo từng người dùng, các metric OTLP với số lượng token, và [giới hạn chi tiêu theo từng người dùng](/en/claude-apps-gateway-spend-limits) trên các nhà cung cấp này. Các tổ chức định tuyến Claude Code qua một [LLM gateway](/en/llm-gateway) khác có thể theo dõi chi tiêu tại gateway thay thế, vì nó thấy mọi yêu cầu.

### Khuyến nghị về rate limit

Khi thiết lập Claude Code cho các nhóm, hãy cân nhắc các khuyến nghị Token Per Minute (TPM) và Request Per Minute (RPM) theo từng người dùng dựa trên quy mô tổ chức của bạn:

| Quy mô nhóm     | TPM mỗi người dùng | RPM mỗi người dùng |
| ------------- | ------------ | ------------ |
| 1-5 người dùng     | 200k-300k    | 5-7          |
| 5-20 người dùng    | 100k-150k    | 2.5-3.5      |
| 20-50 người dùng   | 50k-75k      | 1.25-1.75    |
| 50-100 người dùng  | 25k-35k      | 0.62-0.87    |
| 100-500 người dùng | 15k-20k      | 0.37-0.47    |
| 500+ người dùng     | 10k-15k      | 0.25-0.35    |

Ví dụ, nếu bạn có 200 người dùng, bạn có thể yêu cầu 20k TPM cho mỗi người dùng, hoặc tổng cộng 4 triệu TPM (200\*20,000 = 4 triệu).

TPM mỗi người dùng giảm khi quy mô nhóm tăng vì ít người dùng có xu hướng dùng Claude Code đồng thời hơn ở các tổ chức lớn hơn. Các rate limit này áp dụng ở cấp tổ chức, không phải theo từng người dùng riêng lẻ, nghĩa là từng người dùng có thể tạm thời tiêu thụ nhiều hơn phần được tính của mình khi những người khác không dùng dịch vụ tích cực.

<Note>
  Nếu bạn dự đoán các kịch bản có mức sử dụng đồng thời cao bất thường (như các buổi đào tạo trực tiếp với nhóm lớn), bạn có thể cần phân bổ TPM cao hơn cho mỗi người dùng.
</Note>

### Chi phí token của agent team

[Agent teams](/en/agent-teams) sinh ra nhiều instance Claude Code, mỗi cái có context window riêng. Mức sử dụng token tỷ lệ với số lượng thành viên (teammate) đang hoạt động và mỗi thành viên chạy bao lâu.

Để giữ chi phí agent team ở mức quản lý được:

* Dùng Sonnet cho các thành viên. Nó cân bằng khả năng và chi phí cho các tác vụ điều phối.
* Giữ nhóm nhỏ. Mỗi thành viên chạy context window riêng, nên mức sử dụng token gần như tỷ lệ với quy mô nhóm.
* Giữ prompt sinh (spawn prompt) tập trung. Các thành viên tự động nạp CLAUDE.md, MCP server, và skill, nhưng mọi thứ trong spawn prompt đều cộng thêm vào ngữ cảnh của chúng ngay từ đầu.
* Tắt các thành viên khi công việc của họ xong. Mỗi thành viên hoạt động tiếp tục tiêu thụ token cho đến khi nó thoát hoặc phiên kết thúc.
* Agent teams bị tắt theo mặc định. Đặt `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` trong [settings.json](/en/settings) hoặc môi trường của bạn để bật chúng. Xem [bật agent teams](/en/agent-teams#enable-agent-teams).

## Giảm mức sử dụng token

Chi phí token tỷ lệ với kích thước ngữ cảnh: Claude xử lý càng nhiều ngữ cảnh, bạn dùng càng nhiều token. Claude Code tự động tối ưu chi phí thông qua [prompt caching](/en/prompt-caching), giúp giảm chi phí cho nội dung lặp lại như system prompt, và nén tự động (auto-compaction), giúp tóm tắt lịch sử cuộc trò chuyện khi tiến gần tới giới hạn ngữ cảnh.

Các chiến lược sau giúp bạn giữ ngữ cảnh nhỏ và giảm chi phí trên mỗi tin nhắn.

### Quản lý ngữ cảnh một cách chủ động

Dùng `/usage` để kiểm tra mức sử dụng token hiện tại của bạn, hoặc [cấu hình status line của bạn](/en/statusline#context-window-usage) để hiển thị nó liên tục.

* **Clear giữa các tác vụ**: Dùng `/clear` để bắt đầu mới khi chuyển sang công việc không liên quan. Ngữ cảnh cũ lãng phí token trên mọi tin nhắn tiếp theo. Dùng `/rename` trước khi clear để bạn có thể dễ dàng tìm phiên về sau, rồi `/resume` để quay lại nó.
* **Thêm chỉ dẫn nén tùy chỉnh**: `/compact Focus on code samples and API usage` cho Claude biết cần giữ lại gì trong quá trình tóm tắt.

Bạn cũng có thể tùy chỉnh hành vi nén trong file CLAUDE.md ở gốc dự án của bạn:

```markdown theme={null}
# Compact instructions

When you are using compact, please focus on test output and code changes
```

### Chọn đúng model

Sonnet xử lý hầu hết các tác vụ lập trình tốt và tốn ít hơn Opus. Dành Opus cho các quyết định kiến trúc phức tạp hoặc lập luận nhiều bước. Dùng `/model` để chuyển model giữa phiên, hoặc đặt mặc định trong `/config`. Với các tác vụ subagent đơn giản, chỉ định `model: haiku` trong [cấu hình subagent](/en/sub-agents#choose-a-model) của bạn.

### Giảm chi phí phụ (overhead) của MCP server

Định nghĩa công cụ MCP được [hoãn (deferred) theo mặc định](/en/mcp#scale-with-mcp-tool-search), nên chỉ tên công cụ đi vào ngữ cảnh cho đến khi Claude dùng một công cụ cụ thể. Chạy `/context` để xem những gì đang chiếm không gian.

* **Ưu tiên công cụ CLI khi có sẵn**: Các công cụ như `gh`, `aws`, `gcloud`, và `sentry-cli` vẫn tiết kiệm ngữ cảnh hơn MCP server vì chúng không thêm bất kỳ danh sách liệt kê theo từng công cụ nào. Claude có thể chạy lệnh CLI trực tiếp.
* **Tắt các server không dùng**: Chạy `/mcp` để xem các server đã cấu hình và tắt bất kỳ cái nào bạn không dùng tích cực.

### Cài các plugin trí tuệ code (code intelligence) cho ngôn ngữ có kiểu tĩnh

[Các plugin trí tuệ code](/en/discover-plugins#code-intelligence) cho Claude khả năng điều hướng symbol chính xác thay vì tìm kiếm dựa trên văn bản, giảm các lần đọc file không cần thiết khi khám phá code không quen thuộc. Một lệnh gọi "go to definition" thay thế cho những gì lẽ ra có thể là một lệnh grep theo sau bằng việc đọc nhiều file ứng viên. Các language server đã cài cũng tự động báo cáo lỗi kiểu (type error) sau các chỉnh sửa, nên Claude bắt được sai lầm mà không cần chạy trình biên dịch.

### Chuyển việc xử lý sang hook và skill

[Hook](/en/hooks) tùy chỉnh có thể tiền xử lý dữ liệu trước khi Claude thấy nó. Thay vì Claude đọc một file log 10.000 dòng để tìm lỗi, một hook có thể grep tìm `ERROR` và chỉ trả về các dòng khớp, giảm ngữ cảnh từ hàng chục nghìn token xuống hàng trăm.

Một [skill](/en/skills) có thể cho Claude kiến thức chuyên ngành để nó không phải khám phá. Ví dụ, một skill "codebase-overview" có thể mô tả kiến trúc dự án, các thư mục chính, và quy ước đặt tên của bạn. Khi Claude gọi skill, nó nhận ngữ cảnh này ngay lập tức thay vì tốn token đọc nhiều file để hiểu cấu trúc.

Ví dụ, hook PreToolUse này lọc output của test để chỉ hiển thị các lỗi (failure):

<Tabs>
  <Tab title="settings.json">
    Thêm cái này vào [settings.json](/en/settings#settings-files) của bạn để chạy hook trước mỗi lệnh Bash:

    ```json theme={null}
    {
      "hooks": {
        "PreToolUse": [
          {
            "matcher": "Bash",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/hooks/filter-test-output.sh"
              }
            ]
          }
        ]
      }
    }
    ```
  </Tab>

  <Tab title="filter-test-output.sh">
    Hook gọi script này. Tạo thư mục với `mkdir -p ~/.claude/hooks`, lưu script bên dưới thành `~/.claude/hooks/filter-test-output.sh`, và làm cho nó thực thi được với `chmod +x ~/.claude/hooks/filter-test-output.sh`. Nó kiểm tra xem lệnh có phải là một bộ chạy test không và chỉnh sửa nó để chỉ hiển thị các lỗi:

    ```bash theme={null}
    #!/bin/bash
    input=$(cat)
    cmd=$(echo "$input" | jq -r '.tool_input.command')

    # If running tests, filter to show only failures
    if [[ "$cmd" =~ ^(npm test|pytest|go test) ]]; then
      filtered_cmd="$cmd 2>&1 | grep -A 5 -E '(FAIL|ERROR|error:)' | head -100"
      echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":{\"command\":\"$filtered_cmd\"}}}"
    else
      echo "{}"
    fi
    ```
  </Tab>
</Tabs>

### Chuyển chỉ dẫn từ CLAUDE.md sang skill

File [CLAUDE.md](/en/memory) của bạn được nạp vào ngữ cảnh lúc bắt đầu phiên. Nếu nó chứa các chỉ dẫn chi tiết cho các workflow cụ thể (như review PR hoặc migration cơ sở dữ liệu), các token đó hiện diện ngay cả khi bạn đang làm công việc không liên quan. [Skill](/en/skills) nạp theo yêu cầu chỉ khi được gọi, nên chuyển các chỉ dẫn chuyên biệt vào skill giữ ngữ cảnh nền của bạn nhỏ hơn. Hãy hướng tới giữ CLAUDE.md dưới 200 dòng bằng cách chỉ đưa vào những thứ thiết yếu.

### Điều chỉnh extended thinking

Extended thinking được bật theo mặc định vì nó cải thiện đáng kể hiệu năng trên các tác vụ lập kế hoạch và lập luận phức tạp. Các token thinking được tính là output token, và ngân sách mặc định có thể lên tới hàng chục nghìn token mỗi yêu cầu tùy theo model. Với các tác vụ đơn giản hơn không cần lập luận sâu, bạn có thể giảm chi phí bằng cách hạ [mức nỗ lực (effort level)](/en/model-config#adjust-effort-level) với `/effort` hoặc trong `/model`, tắt thinking trong `/config`, hoặc, trên các model có [ngân sách thinking cố định](/en/model-config#adaptive-reasoning-and-fixed-thinking-budgets), hạ ngân sách bằng cách đặt [biến môi trường](/en/env-vars) `MAX_THINKING_TOKENS`, ví dụ `MAX_THINKING_TOKENS=8000`. Các model lập luận thích ứng (adaptive-reasoning) bỏ qua các ngân sách khác không, nên hãy dùng effort level ở đó thay thế. Việc tắt thinking không có sẵn trên Fable 5, vốn luôn dùng extended thinking.

### Ủy thác các thao tác dài dòng cho subagent

Chạy test, lấy tài liệu, hoặc xử lý file log có thể tiêu thụ nhiều ngữ cảnh. Hãy ủy thác chúng cho [subagent](/en/sub-agents#isolate-high-volume-operations) để output dài dòng ở lại trong ngữ cảnh của subagent trong khi chỉ một bản tóm tắt trả về cuộc trò chuyện chính của bạn.

### Quản lý chi phí agent team

Agent team dùng khoảng 7 lần nhiều token hơn các phiên tiêu chuẩn khi các thành viên chạy trong plan mode, vì mỗi thành viên duy trì context window riêng và chạy như một instance Claude riêng biệt. Giữ các tác vụ nhóm nhỏ và tự chứa để hạn chế mức sử dụng token trên mỗi thành viên. Xem [agent teams](/en/agent-teams) để biết chi tiết.

### Viết prompt cụ thể

Các yêu cầu mơ hồ như "improve this codebase" kích hoạt việc quét rộng. Các yêu cầu cụ thể như "add input validation to the login function in auth.ts" cho phép Claude làm việc hiệu quả với ít lần đọc file nhất.

### Làm việc hiệu quả trên các tác vụ phức tạp

Với công việc dài hơn hoặc phức tạp hơn, các thói quen này giúp tránh lãng phí token do đi sai hướng:

* **Dùng plan mode cho các tác vụ phức tạp**: Nhấn Shift+Tab để vào [plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode) trước khi triển khai. Claude khám phá codebase và đề xuất một cách tiếp cận để bạn phê duyệt, ngăn chặn việc làm lại tốn kém khi hướng đi ban đầu sai.
* **Điều chỉnh hướng sớm**: Nếu Claude bắt đầu đi sai hướng, nhấn Escape để dừng ngay lập tức. Dùng `/rewind` hoặc nhấn Escape hai lần để khôi phục cuộc trò chuyện và code về một checkpoint trước đó.
* **Cung cấp mục tiêu kiểm chứng**: Đưa vào các test case, dán ảnh chụp màn hình, hoặc định nghĩa output mong đợi trong prompt của bạn. Khi Claude có thể tự kiểm chứng công việc của nó, nó bắt được vấn đề trước khi bạn cần yêu cầu sửa.
* **Test tăng dần (incrementally)**: Viết một file, test nó, rồi tiếp tục. Điều này bắt được vấn đề sớm khi chúng còn rẻ để sửa.

## Mức sử dụng token chạy nền

Claude Code dùng token cho một số chức năng chạy nền ngay cả khi rảnh rỗi:

* **Tóm tắt cuộc trò chuyện**: Các công việc chạy nền tóm tắt các cuộc trò chuyện trước đó cho tính năng `claude --resume`
* **Xử lý lệnh**: Một số lệnh như `/usage` có thể tạo các yêu cầu để kiểm tra trạng thái

Các tiến trình nền này tiêu thụ một lượng nhỏ token (thường dưới \$0.04 mỗi phiên) ngay cả khi không có tương tác tích cực.

## Hiểu các thay đổi trong hành vi của Claude Code

Claude Code thường xuyên nhận các bản cập nhật có thể thay đổi cách các tính năng hoạt động, bao gồm cả báo cáo chi phí. Chạy `claude --version` để kiểm tra phiên bản hiện tại của bạn. Với các câu hỏi thanh toán cụ thể, liên hệ hỗ trợ Anthropic qua [tài khoản Console](https://platform.claude.com/login) của bạn.
