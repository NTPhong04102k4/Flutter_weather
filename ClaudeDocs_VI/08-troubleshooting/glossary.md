> Nguồn: https://code.claude.com/docs/en/glossary.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bảng thuật ngữ

> Định nghĩa cho các thuật ngữ của Claude Code. Tìm hiểu ý nghĩa của agentic loop, compaction, CLAUDE.md, hook, subagent, MCP, và các khái niệm cốt lõi khác.

Bảng thuật ngữ này định nghĩa các thuật ngữ của Claude Code. Mỗi mục liên kết đến trang trình bày chuyên sâu về khái niệm đó. Đối với các khái niệm ở cấp độ model như token, temperature, và RAG, hãy xem [bảng thuật ngữ nền tảng](https://platform.claude.com/docs/en/about-claude/glossary).

## A

### Agent teams (Đội agent)

Nhiều phiên Claude Code độc lập được điều phối bởi một team lead, với một danh sách tác vụ chung và nhắn tin ngang hàng (peer-to-peer). Không giống [subagent](#subagent), vốn chạy trong một phiên duy nhất và chỉ báo cáo cho tiến trình cha, mỗi thành viên trong đội có context window (cửa sổ ngữ cảnh) riêng và bạn có thể tương tác trực tiếp với bất kỳ ai trong số họ. Agent teams đang ở dạng thử nghiệm và phải được bật bằng cách đặt `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

Tìm hiểu thêm: [Chạy agent teams](/en/agent-teams)

### Agentic coding (Lập trình theo hướng agent)

Một quy trình làm việc trong đó AI có thể đọc file, chạy lệnh, và thực hiện thay đổi một cách tự chủ trong khi bạn quan sát, chuyển hướng, hoặc rời đi, trái ngược với các trợ lý dạng chat vốn chỉ phản hồi bằng văn bản mà bạn phải tự áp dụng. Claude Code có tính agentic vì nó có [tool](#tool) cho phép nó hành động, chứ không chỉ đưa lời khuyên.

Tìm hiểu thêm: [Cách Claude Code hoạt động](/en/how-claude-code-works)

### Agentic harness (Bộ khung agent)

Các tool, quản lý context, và môi trường thực thi biến một mô hình ngôn ngữ thành một agent lập trình có năng lực. Claude Code là harness; Claude là model bên trong nó. Harness cung cấp quyền truy cập file, thực thi shell, kiểm soát permission, nạp bộ nhớ, và vòng lặp nối các hành động lại với nhau.

Tìm hiểu thêm: [Cách Claude Code hoạt động](/en/how-claude-code-works)

### Agentic loop (Vòng lặp agent)

Chu trình Claude thực hiện cho mỗi tác vụ: thu thập context, hành động, xác minh kết quả, và lặp lại cho đến khi hoàn thành. Mỗi lần dùng tool trả về thông tin định hướng bước tiếp theo. Bạn có thể ngắt vòng lặp tại bất kỳ điểm nào để chuyển hướng. Hầu hết các điểm mở rộng, bao gồm [hook](#hook), [skill](#skill), và [MCP](#mcp-model-context-protocol), đều cắm vào các pha cụ thể của vòng lặp này.

Tìm hiểu thêm: [Cách Claude Code hoạt động](/en/how-claude-code-works#the-agentic-loop)

### Artifact

Một trang web trực tiếp, có tính tương tác mà Claude Code xuất bản từ phiên của bạn đến một URL riêng tư trên claude.ai, để bạn có thể xem đầu ra một cách trực quan hoặc chia sẻ trong nội bộ tổ chức của bạn thay vì đọc văn bản trên terminal. Trang được cập nhật tại chỗ khi phiên xuất bản lại. Các artifact bạn tạo từ Claude Code xuất hiện trong cùng thư viện với các artifact được tạo trong các cuộc hội thoại trên claude.ai, nhưng việc chia sẻ chúng dừng lại ở tổ chức của bạn và chúng không thể được công khai.

Tìm hiểu thêm: [Chia sẻ đầu ra phiên dưới dạng artifact](/en/artifacts)

### Auto memory (Bộ nhớ tự động)

Các ghi chú Claude tự viết cho chính nó dựa trên các chỉnh sửa và sở thích của bạn, được lưu trữ theo từng git repository dưới `~/.claude/projects/`. Tất cả các worktree của cùng một repository chia sẻ một thư mục auto memory. 200 dòng đầu tiên hoặc 25 KB của chỉ mục `MEMORY.md` được nạp lúc bắt đầu mỗi phiên. Auto memory là bản đối ứng do Claude viết của [CLAUDE.md](#claude-md), thứ mà bạn viết.

Tìm hiểu thêm: [Auto memory](/en/memory#auto-memory)

### Auto mode (Chế độ tự động)

Một [permission mode](#permission-mode) trong đó một model phân loại (classifier) riêng biệt xem xét các hành động ở nền, nên hầu hết chạy mà không cần lời nhắc phê duyệt; các quy tắc ask rõ ràng vẫn nhắc. Classifier chặn việc leo thang phạm vi, hạ tầng không đáng tin cậy, và [prompt injection](#prompt-injection). Nó không bao giờ thấy kết quả tool, nên các chỉ dẫn bị chèn (injected) không thể ảnh hưởng đến quyết định của nó. Auto mode là một bản xem trước nghiên cứu (research preview).

Tìm hiểu thêm: [Loại bỏ lời nhắc với auto mode](/en/permission-modes#eliminate-prompts-with-auto-mode)

## B

### Bare mode (Chế độ trần)

Một flag khởi động, `--bare`, bỏ qua việc tự động phát hiện hook, skill, plugin, MCP server, auto memory, và CLAUDE.md. Chỉ các flag bạn truyền vào một cách rõ ràng mới có hiệu lực. Được khuyến nghị cho CI và các lệnh gọi qua script nơi bạn cần hành vi giống hệt nhau trên các máy bất kể cấu hình cục bộ.

Tìm hiểu thêm: [Khởi động nhanh hơn với bare mode](/en/headless#start-faster-with-bare-mode)

### Bundled skills (Các skill đóng gói sẵn)

Các playbook dựa trên prompt được kèm theo Claude Code, chẳng hạn `/batch`, `/code-review`, `/debug`, và `/loop`. Không giống các lệnh built-in vốn thực thi logic cố định, các bundled skill đưa cho Claude một prompt chi tiết và để Claude điều phối công việc, nên chúng có thể spawn agent, đọc file, và thích ứng với codebase của bạn.

Tìm hiểu thêm: [Bundled skills](/en/skills#bundled-skills)

## C

### Channel (Kênh)

Một [MCP server](#mcp-model-context-protocol) đẩy các sự kiện vào phiên đang chạy của bạn để Claude có thể phản ứng với những việc xảy ra khi bạn rời khỏi terminal. Channel có thể hai chiều: Claude đọc một sự kiện đến và trả lời lại thông qua cùng kênh đó. Telegram, Discord, và iMessage được bao gồm trong bản xem trước nghiên cứu.

Tìm hiểu thêm: [Channels](/en/channels)

### Checkpoint (Điểm khôi phục)

Một điểm khôi phục được tạo tại mỗi prompt bạn gửi. Claude Code chụp nhanh (snapshot) các file trước mỗi lần chỉnh sửa để một checkpoint có thể hoàn nguyên chúng. Nhấn `Esc` hai lần hoặc chạy `/rewind` để khôi phục mã, hội thoại, hoặc cả hai về một điểm trước đó, hoặc để tóm tắt một phần của hội thoại từ một tin nhắn được chọn. Các checkpoint là cục bộ trong phiên, tách biệt với git, và không theo dõi các thay đổi được thực hiện qua công cụ Bash.

Tìm hiểu thêm: [Checkpointing](/en/checkpointing)

### Thư mục `.claude`

Thư mục nơi Claude Code đọc cấu hình phạm vi project: settings, hook, skill, subagent, rule, và auto memory. Một project có `.claude/` ở gốc của nó; các mặc định ở cấp user của bạn nằm ở `~/.claude/`.

Tìm hiểu thêm: [Thư mục `.claude`](/en/claude-directory)

### CLAUDE.md

Một file markdown chứa các chỉ dẫn bền vững mà bạn viết cho Claude, được nạp lúc bắt đầu mỗi phiên dưới dạng một tin nhắn user sau system prompt. Đặt các quy ước của project, ghi chú kiến trúc, và các quy tắc "luôn làm X" ở đây. CLAUDE.md ở gốc project tồn tại qua [compaction](#compaction) và được đọc lại tươi mới từ đĩa sau đó.

Bạn có thể đặt CLAUDE.md ở phạm vi project trong `./CLAUDE.md` hoặc `./.claude/CLAUDE.md`, ở phạm vi user trong `~/.claude/CLAUDE.md`, hoặc dưới dạng [chính sách được quản lý](#managed-settings) cho tổ chức của bạn. Tất cả các file được phát hiện đều được nối lại vào context thay vì ghi đè lẫn nhau, sắp xếp từ phạm vi rộng nhất đến cụ thể nhất.

Tìm hiểu thêm: [Các file CLAUDE.md](/en/memory#claude-md-files)

### Command (Lệnh)

Một chỉ dẫn có thể tái sử dụng mà bạn gọi bằng cách gõ `/name` trong prompt. Các lệnh built-in như `/clear`, `/model`, và `/compact` điều khiển phiên. Bạn có thể định nghĩa các lệnh của riêng mình dưới dạng file trong `.claude/commands/`, hoặc cài đặt chúng từ một [plugin](#plugin). [Skill](#skill) là cách được khuyến nghị để đóng gói các lệnh nhiều bước.

Tìm hiểu thêm: [Commands](/en/commands) · [Skills](/en/skills)

### Compaction (Nén hội thoại)

Việc tự động tóm tắt hội thoại của bạn khi [context window](#context-window) tiến gần đến giới hạn của nó. Các đầu ra tool cũ hơn được xóa trước, sau đó hội thoại được tóm tắt. CLAUDE.md ở gốc project và auto memory tồn tại qua compaction và được nạp lại từ đĩa; các chỉ dẫn chỉ được đưa ra trong hội thoại có thể bị mất. Chạy `/compact` để kích hoạt thủ công, tùy chọn kèm một trọng tâm như `/compact focus on the API changes`.

Tìm hiểu thêm: [Những gì tồn tại qua compaction](/en/context-window#what-survives-compaction) · [Khi context đầy](/en/how-claude-code-works#when-context-fills-up)

### Context window (Cửa sổ ngữ cảnh)

Bộ nhớ làm việc cho một phiên, chứa lịch sử hội thoại, nội dung file, đầu ra lệnh, CLAUDE.md, auto memory, các skill đã nạp, và các chỉ dẫn hệ thống. Khi bạn làm việc, context đầy dần cho đến khi [compaction](#compaction) tóm tắt nó. Chạy `/context` để xem cái gì đang chiếm dụng không gian. Về khái niệm model bên dưới, hãy xem [bảng thuật ngữ nền tảng](https://platform.claude.com/docs/en/about-claude/glossary#context-window).

Tìm hiểu thêm: [Khám phá context window](/en/context-window)

## D

### Dispatch

Một bộ định tuyến tác vụ khởi phát từ điện thoại, nó spawn một phiên Claude Code trong ứng dụng Desktop khi bạn gửi một tác vụ lập trình từ ứng dụng Claude trên di động. Prompt của bạn được định tuyến đến đúng tool một cách tự động. Khả dụng trên các gói Pro và Max.

Tìm hiểu thêm: [Các phiên từ Dispatch](/en/desktop#sessions-from-dispatch)

## E

### Effort level (Mức độ nỗ lực)

Một cài đặt kiểm soát Claude dùng bao nhiêu ngân sách suy nghĩ của adaptive-reasoning trên mỗi lượt. Mức độ nỗ lực cao hơn nghĩa là nhiều token suy nghĩ hơn và lập luận sâu hơn; mức độ thấp hơn thì nhanh hơn và rẻ hơn. Effort được hỗ trợ trên Fable 5, trên Opus 4.6 trở lên, và trên Sonnet 4.6 trở lên.

Tìm hiểu thêm: [Điều chỉnh effort level](/en/model-config#adjust-effort-level)

### Extended thinking (Suy nghĩ mở rộng)

Lập luận từng bước có thể nhìn thấy mà model thực hiện trước khi phản hồi. Bạn có thể điều chỉnh nó bằng [effort level](#effort-level), hoặc giới hạn số token suy nghĩ bằng `MAX_THINKING_TOKENS` trên các model có ngân sách suy nghĩ cố định. Suy nghĩ hiển thị dưới dạng văn bản in nghiêng màu xám trong terminal.

Tìm hiểu thêm: [Dùng extended thinking](/en/model-config#extended-thinking)

## H

### Hook

Một trình xử lý (handler) do người dùng định nghĩa, tự động thực thi tại một điểm cụ thể trong vòng đời của Claude Code, chẳng hạn trước khi một tool chạy, sau một lần chỉnh sửa file, hoặc lúc bắt đầu phiên. Các handler có thể là một lệnh shell, một endpoint HTTP, một MCP tool, một LLM prompt, hoặc một subagent. Hook có tính tất định (deterministic): chúng kích hoạt tại các điểm vòng đời cố định thay vì theo quyết định của model.

Một cấu hình hook có ba cấp độ:

* **Hook event (Sự kiện hook)**: điểm trong vòng đời
* **Matcher**: lọc những sự kiện nào kích hoạt nó
* **Hook handler (Trình xử lý hook)**: cái gì chạy

Tìm hiểu thêm: [Bắt đầu với hook](/en/hooks-guide) · [Tài liệu tham khảo hook](/en/hooks)

## M

### Managed settings (Settings được quản lý)

Các settings được áp đặt trên toàn tổ chức bởi IT hoặc DevOps, được phân phối từ máy chủ của Anthropic thông qua admin console hoặc được triển khai đến thiết bị tại một đường dẫn cấp OS bên ngoài `~/.claude`. Settings của user và project không thể ghi đè managed settings. Việc phân phối do máy chủ quản lý áp dụng trên [các cấu hình đủ điều kiện](/en/server-managed-settings#platform-availability); xem [Các cân nhắc về bảo mật](/en/server-managed-settings#security-considerations). Dùng cái này cho các chính sách bảo mật, yêu cầu tuân thủ, hoặc công cụ được chuẩn hóa trên toàn bộ đội máy (fleet).

Tìm hiểu thêm: [Server-managed settings](/en/server-managed-settings) · [Các file settings](/en/settings#settings-files)

### MCP (Model Context Protocol)

Một chuẩn mở để kết nối các công cụ AI với các nguồn dữ liệu và dịch vụ bên ngoài. Các MCP server cấp cho Claude các tool mới cho Slack, Jira, cơ sở dữ liệu, trình duyệt, và hàng trăm tích hợp khác. Bạn kết nối server qua `/mcp` hoặc bằng cách thêm chúng vào `.mcp.json`. Về bản thân giao thức, hãy xem [bảng thuật ngữ nền tảng](https://platform.claude.com/docs/en/about-claude/glossary#mcp-model-context-protocol).

Tìm hiểu thêm: [Model Context Protocol](/en/mcp)

### MCP Tool Search (Tìm kiếm MCP tool)

Một cơ chế tiết kiệm context, trì hoãn các schema của MCP tool cho đến khi cần. Chỉ tên tool được nạp lúc khởi động; Claude lấy toàn bộ schema theo yêu cầu khi nó quyết định dùng một tool cụ thể. Điều này giữ cho các MCP server nhàn rỗi không tiêu tốn nhiều context.

Tìm hiểu thêm: [Mở rộng quy mô với MCP Tool Search](/en/mcp#scale-with-mcp-tool-search)

## N

### Non-interactive mode (Chế độ không tương tác)

Một chế độ thực thi một prompt đơn lẻ rồi thoát mà không có phiên hội thoại, được gọi bằng `-p` hoặc `--print`. Được dùng cho CI, script, và piping. [Agent SDK](/en/agent-sdk/overview) là bản tương đương cho Python và TypeScript. Trước đây gọi là headless mode.

Tìm hiểu thêm: [Chạy Claude Code theo lập trình](/en/headless)

## O

### Output style (Kiểu đầu ra)

Một cấu hình sửa đổi system prompt của Claude để thay đổi hành vi phản hồi, giọng điệu, hoặc định dạng. Output style tắt các phần chuyên về kỹ thuật phần mềm của system prompt mặc định, không giống [CLAUDE.md](#claude-md) vốn được phân phối dưới dạng một tin nhắn user theo sau system prompt. Các kiểu built-in bao gồm Default, Proactive, Explanatory, và Learning.

Tìm hiểu thêm: [Output styles](/en/output-styles)

## P

### Permission mode (Chế độ permission)

Hành vi phê duyệt cơ sở cho phiên. Chuyển vòng bằng `Shift+Tab` trong CLI hoặc dùng bộ chọn chế độ trong VS Code, Desktop, và claude.ai. Các chế độ khả dụng là `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, và `bypassPermissions`.

Chế độ `default` được gán nhãn Manual trong CLI và trong các extension của VS Code và JetBrains, và Claude Code chấp nhận `manual` như một bí danh (alias) cho giá trị đó.

Tìm hiểu thêm: [Chọn một permission mode](/en/permission-modes)

### Permission rule (Quy tắc permission)

Một mục settings cho phép, hỏi về, hoặc từ chối một lệnh gọi tool dựa trên tên tool và mô hình đối số. Các quy tắc được đánh giá theo thứ tự deny→ask→allow, khớp đầu tiên sẽ thắng. Permission rule là các kiểm soát chi tiết được xếp lớp lên trên [permission mode](#permission-mode) rộng hơn.

Tìm hiểu thêm: [Cấu hình permissions](/en/permissions)

### Plan mode (Chế độ lập kế hoạch)

Một [permission mode](#permission-mode) trong đó Claude nghiên cứu và đề xuất các thay đổi mà không chỉnh sửa các file nguồn của bạn. Nó có thể đọc, tìm kiếm, và chạy các lệnh khám phá, sau đó trình bày một kế hoạch để phê duyệt trước khi đụng vào bất cứ thứ gì. Vào plan mode bằng `/plan` hoặc bằng cách nhấn `Shift+Tab`.

Tìm hiểu thêm: [Phân tích trước khi chỉnh sửa với plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode)

### Plugin

Một gói gồm skill, hook, subagent, và MCP server được đóng gói thành một đơn vị có thể cài đặt duy nhất. Các skill của plugin được đặt namespace là `plugin-name:skill-name` để nhiều plugin có thể cùng tồn tại. Phân phối plugin trên các đội thông qua một [marketplace](/en/plugin-marketplaces).

Tìm hiểu thêm: [Plugins](/en/plugins)

### Project trust (Sự tin cậy project)

Một hộp thoại chấp nhận một thư mục trước khi Claude Code nạp cấu hình của nó. Việc chấp nhận được lưu theo từng thư mục project, ngoại trừ thư mục home của bạn, nơi sự tin cậy chỉ được giữ cho phiên hiện tại và lời nhắc xuất hiện lại mỗi lần khởi chạy. Sự tin cậy kiểm soát việc tự động cài đặt các plugin từ marketplace và việc thực thi các hook do project định nghĩa. Tin cậy một thư mục có nghĩa là các file cấu hình `.claude/settings.json`, `.mcp.json`, và các file khác của nó có hiệu lực.

Tìm hiểu thêm: [Thư mục `.claude`](/en/claude-directory)

### Prompt injection (Chèn prompt độc hại)

Các chỉ dẫn thù địch được nhúng trong một file, một trang web, hoặc một kết quả tool nhằm chuyển hướng Claude sang các hành động mà bạn chưa bao giờ yêu cầu. Các biện pháp phòng thủ của Claude Code bao gồm hệ thống permission, phát hiện command injection, và xác minh sự tin cậy. [Auto mode](#auto-mode) bổ sung một đầu dò (probe) phía máy chủ quét các kết quả tool để tìm nội dung đáng ngờ, và một classifier không bao giờ thấy kết quả tool, nên văn bản bị chèn không thể ảnh hưởng đến các quyết định phê duyệt của nó.

Tìm hiểu thêm: [Phòng chống prompt injection](/en/security#protect-against-prompt-injection)

## R

### Remote Control (Điều khiển từ xa)

Một cách để tiếp tục một phiên Claude Code cục bộ từ điện thoại hoặc trình duyệt của bạn qua claude.ai. Mã của bạn ở lại trên máy của bạn; chỉ có UI là ở xa. Khác với Claude Code trên web, vốn chạy trong một sandbox trên đám mây.

Tìm hiểu thêm: [Remote Control](/en/remote-control)

### Rules (Các rule)

Các file chỉ dẫn dạng module trong `.claude/rules/` được nạp cùng với CLAUDE.md. Một rule có thể được giới hạn theo đường dẫn bằng frontmatter YAML `paths:` để nó chỉ được nạp khi Claude đọc một file khớp, giữ cho context tinh gọn cho đến khi nó có liên quan.

Tìm hiểu thêm: [Tổ chức các rule với `.claude/rules/`](/en/memory#organize-rules-with-claude/rules/)

## S

### Sandboxing (Đóng hộp cát)

Sự cô lập hệ thống file và mạng ở cấp OS cho công cụ Bash. Các lệnh chạy bên trong một ranh giới bạn định nghĩa trước, nên Claude có thể làm việc thoải mái trong đó mà không cần lời nhắc phê duyệt cho từng lệnh. Sandboxing là một lớp riêng biệt với [permission rule](#permission-rule).

Tìm hiểu thêm: [Sandboxing](/en/sandboxing)

### Session (Phiên)

Một cuộc hội thoại gắn với thư mục hiện tại của bạn, với context window độc lập của riêng nó. Các phiên có thể được tiếp tục với `claude -c`, được fork với `--fork-session` để giữ lại lịch sử dưới một ID phiên mới, hoặc chạy song song trên nhiều terminal. Chạy `/clear` bắt đầu một phiên mới; phiên trước đó vẫn được lưu trữ và có sẵn qua `/resume`. Bản ghi (transcript) của mỗi phiên được lưu trữ dưới `~/.claude/projects/`.

Tìm hiểu thêm: [Làm việc với các phiên](/en/how-claude-code-works#work-with-sessions)

### Settings layers (Các lớp settings)

Hệ thống phân cấp mà Claude Code đọc cấu hình từ đó, theo thứ tự ưu tiên từ cao nhất đến thấp nhất: [managed policy](#managed-settings), các đối số dòng lệnh, local settings tại `.claude/settings.local.json`, project settings tại `.claude/settings.json`, rồi user settings tại `~/.claude/settings.json`. Các mảng (array) được hợp nhất qua các lớp; các giá trị vô hướng (scalar) ở lớp cao hơn ghi đè các lớp thấp hơn.

Tìm hiểu thêm: [Các file settings](/en/settings#settings-files)

### Skill

Một file `SKILL.md` chứa các chỉ dẫn, kiến thức, hoặc một quy trình làm việc mà Claude thêm vào bộ công cụ của nó. Claude nạp một skill một cách tự động khi có liên quan, hoặc bạn gọi nó trực tiếp với `/skill-name`. Skill tuân theo chuẩn mở Agent Skills; Claude Code mở rộng nó với kiểm soát gọi (invocation) và thực thi qua subagent.

Skill là kế thừa được khuyến nghị cho các lệnh tùy chỉnh. Một file tại `.claude/commands/deploy.md` và một file tại `.claude/skills/deploy/SKILL.md` đều tạo ra `/deploy` và hoạt động theo cùng cách; các file lệnh hiện có vẫn tiếp tục hoạt động.

Tìm hiểu thêm: [Mở rộng Claude với skill](/en/skills)

### Subagent

Một trợ lý AI chuyên biệt chạy trong context window riêng của nó với một system prompt tùy chỉnh, quyền truy cập tool cụ thể, và permission độc lập. Nó làm việc trên một tác vụ được ủy thác và trả về một bản tóm tắt cho hội thoại chính. Dùng subagent để giữ các khám phá lớn ra khỏi context chính của bạn hoặc để chạy nghiên cứu song song. Khác với [agent teams](#agent-teams), nơi mỗi agent là một phiên độc lập đầy đủ mà bạn có thể nói chuyện trực tiếp.

Các subagent built-in bao gồm Explore, Plan, và general-purpose.

Tìm hiểu thêm: [Tạo subagent tùy chỉnh](/en/sub-agents)

### Surface (Bề mặt)

Bất kỳ nơi nào bạn truy cập Claude Code: CLI, VS Code, JetBrains, Desktop, hoặc claude.ai. Tất cả các bề mặt chia sẻ cùng một engine, nên CLAUDE.md, settings, và skill của bạn hoạt động theo cùng cách trên tất cả chúng. Slack và extension Chrome là các tích hợp kết nối đến một bề mặt chứ không phải bản thân là bề mặt.

Tìm hiểu thêm: [Nền tảng và tích hợp](/en/platforms)

## T

### Teleport

Một lệnh, `/teleport`, kéo một phiên Claude Code trên đám mây vào terminal cục bộ của bạn. Claude lấy nhánh (branch), nạp lịch sử hội thoại, và tiếp tục từ trạng thái cuối cùng của phiên web. Hướng ngược lại là `--cloud`, gửi một tác vụ cục bộ để chạy trên web.

Tìm hiểu thêm: [Từ web đến terminal](/en/claude-code-on-the-web#from-web-to-terminal)

### Tool (Công cụ)

Một hành động Claude có thể thực hiện: đọc một file, chỉnh sửa mã, chạy một lệnh shell, tìm kiếm web, spawn một subagent. Tool là thứ làm cho Claude Code có tính agentic. Không có chúng, Claude chỉ có thể phản hồi bằng văn bản. Mỗi lần dùng tool trả về một kết quả định hướng quyết định tiếp theo của Claude trong [agentic loop](#agentic-loop).

Tìm hiểu thêm: [Các tool khả dụng cho Claude](/en/tools-reference)

### Turn (Lượt)

Một phản hồi hoàn chỉnh từ Claude trong một [session](#session). Một lượt bắt đầu khi bạn gửi một tin nhắn và kết thúc khi Claude hoàn tất phản hồi, với bất kỳ số lượng lệnh gọi [tool](#tool) nào ở giữa. [Stop hook](#hook) kích hoạt ở cuối mỗi lượt. Một phiên bao gồm nhiều lượt, và [agentic loop](#agentic-loop) mô tả những gì xảy ra bên trong một lượt.

Tìm hiểu thêm: [Cách Claude Code hoạt động](/en/how-claude-code-works#the-agentic-loop)

## V

### Verification loop (Vòng lặp xác minh)

Cách một phiên biết công việc thực sự đã hoàn thành chứ không chỉ có vẻ hợp lý. Bạn đưa cho Claude một phép kiểm tra mà nó có thể chạy, chẳng hạn một bộ test, một lần build, hoặc so sánh ảnh chụp màn hình, và Claude lặp lại cho đến khi phép kiểm tra đạt thay vì dừng sau một lần thử. Một verification loop là điều kiện tiên quyết cho [`/goal`](/en/goal), các lần chạy không giám sát, và [dynamic workflow](/en/workflows): không có nó, thứ duy nhất quyết định agent đã hoàn thành lại chính là bản thân agent.

Tìm hiểu thêm: [Cho Claude một cách để xác minh công việc của nó](/en/best-practices#give-claude-a-way-to-verify-its-work)

## W

### Worktree isolation (Cô lập worktree)

Một chế độ cô lập chạy Claude trong một git worktree riêng biệt dưới `.claude/worktrees/`, được bật bằng flag `-w` hoặc `isolation: worktree` trong cấu hình subagent. Các thay đổi ở lại trên một nhánh riêng biệt trong một thư mục riêng biệt, nên các agent song song không ghi đè lên file của nhau.

Tìm hiểu thêm: [Chạy các phiên song song với git worktree](/en/worktrees)

***

## Các thuật ngữ đã ngừng dùng và đổi tên

Các thuật ngữ này xuất hiện trong tài liệu cũ, bài blog, và nội dung cộng đồng. Hãy dùng tên hiện tại khi tìm kiếm trên trang này.

| Thuật ngữ cũ    | Nay gọi là                                    | Ghi chú                              |
| --------------- | --------------------------------------------- | ------------------------------------ |
| Headless mode   | [Non-interactive mode](#non-interactive-mode) | Cùng flag `-p`, cùng hành vi         |
| Custom commands | [Skills](#skill)                              | Các file `.claude/commands/` vẫn hoạt động |
| Slash commands  | Commands                                      | "Slash" đã bị bỏ khỏi nội dung sản phẩm |
