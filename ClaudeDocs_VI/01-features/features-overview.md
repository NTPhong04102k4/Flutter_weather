> Nguồn: https://code.claude.com/docs/en/features-overview.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Mở rộng Claude Code

> Hiểu khi nào nên dùng CLAUDE.md, Skill, subagent, hook, MCP, và plugin.

Claude Code kết hợp một model suy luận về code của bạn với [các công cụ tích hợp sẵn](/en/how-claude-code-works#tools) cho các thao tác file, tìm kiếm, thực thi, và truy cập web. Các công cụ tích hợp sẵn bao quát hầu hết các tác vụ lập trình. Hướng dẫn này bao gồm lớp mở rộng: các tính năng bạn thêm vào để tùy chỉnh những gì Claude biết, kết nối nó với các dịch vụ bên ngoài, và tự động hóa quy trình.

<Note>
  Để biết vòng lặp agent cốt lõi hoạt động ra sao, xem [How Claude Code works](/en/how-claude-code-works).
</Note>

**Mới dùng Claude Code?** Bắt đầu với [CLAUDE.md](/en/memory) cho các quy ước của dự án, rồi thêm các phần mở rộng khác [khi các tác nhân kích hoạt (trigger) cụ thể xuất hiện](#build-your-setup-over-time).

## Tổng quan

Các phần mở rộng cắm vào các phần khác nhau của vòng lặp agent:

* **[CLAUDE.md](/en/memory)** thêm ngữ cảnh bền vững mà Claude thấy mỗi phiên
* **[Skills](/en/skills)** thêm kiến thức tái sử dụng và các quy trình có thể gọi được
* **[Code intelligence](/en/tools-reference#lsp-tool-behavior)** kết nối Claude với một language server để điều hướng ở cấp độ ký hiệu (symbol) và xem lỗi kiểu (type errors) trực tiếp
* **[MCP](/en/mcp)** kết nối Claude với các dịch vụ và công cụ bên ngoài
* **[Subagents](/en/sub-agents)** chạy vòng lặp riêng của chúng trong ngữ cảnh tách biệt, trả về các bản tóm tắt
* **[Agent teams](/en/agent-teams)** điều phối nhiều phiên độc lập với các tác vụ chung và nhắn tin ngang hàng (peer-to-peer)
* **[Hooks](/en/hooks-guide)** kích hoạt trên các sự kiện vòng đời và có thể chạy một script, HTTP request, prompt, hoặc subagent
* **[Plugins](/en/plugins)** và **[marketplaces](/en/plugin-marketplaces)** đóng gói và phân phối các tính năng này

[Skill](/en/skills) là phần mở rộng linh hoạt nhất. Một skill là một file markdown chứa kiến thức, quy trình, hoặc chỉ dẫn. Bạn có thể gọi skill bằng một lệnh như `/deploy`, hoặc Claude có thể nạp chúng tự động khi liên quan. Skill có thể chạy trong hội thoại hiện tại của bạn hoặc trong một ngữ cảnh tách biệt qua subagent.

## Khớp tính năng với mục tiêu của bạn

Các tính năng trải dài từ ngữ cảnh luôn bật (always-on) mà Claude thấy mỗi phiên, đến các khả năng theo yêu cầu (on-demand) mà bạn hoặc Claude có thể gọi, đến tự động hóa ở nền chạy trên các sự kiện cụ thể. Bảng dưới đây cho thấy những gì có sẵn và khi nào mỗi cái hợp lý.

| Tính năng                                                      | Nó làm gì                                                     | Khi nào dùng                                                                    | Ví dụ                                                                           |
| -------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **CLAUDE.md**                                                  | Ngữ cảnh bền vững được nạp mỗi hội thoại                       | Quy ước dự án, các quy tắc "luôn làm X"                                          | "Use pnpm, not npm. Run tests before committing."                               |
| **Skill**                                                      | Chỉ dẫn, kiến thức, và quy trình mà Claude có thể dùng        | Nội dung tái sử dụng, tài liệu tham chiếu, tác vụ lặp lại                        | `/deploy` chạy checklist triển khai của bạn; skill API docs với các mẫu endpoint |
| **Subagent**                                                   | Ngữ cảnh thực thi tách biệt trả về kết quả đã tóm tắt          | Tách biệt ngữ cảnh, tác vụ song song, worker chuyên biệt                        | Tác vụ nghiên cứu đọc nhiều file nhưng chỉ trả về các phát hiện chính           |
| **[Agent teams](/en/agent-teams)**                             | Điều phối nhiều phiên Claude Code độc lập                     | Nghiên cứu song song, phát triển tính năng mới, gỡ lỗi với các giả thuyết cạnh tranh | Sinh ra các reviewer để kiểm tra bảo mật, hiệu năng, và test đồng thời           |
| **[Code intelligence](/en/tools-reference#lsp-tool-behavior)** | Điều hướng và chẩn đoán bằng language server                  | Ngôn ngữ có kiểu (typed), codebase lớn nơi grep chậm hoặc thiếu chính xác        | Nhảy tới định nghĩa của một ký hiệu thay vì đọc cả file                          |
| **MCP**                                                        | Kết nối tới các dịch vụ bên ngoài                             | Dữ liệu hoặc hành động bên ngoài                                                 | Truy vấn database của bạn, đăng lên Slack, điều khiển trình duyệt                |
| **Hook**                                                       | Script, HTTP request, prompt, hoặc subagent được kích hoạt bởi sự kiện | Tự động hóa phải chạy trên mỗi sự kiện khớp                                      | Chạy ESLint sau mỗi lần chỉnh sửa file                                           |
| **[Artifact](/en/artifacts)**                                  | Xuất bản đầu ra của phiên thành một trang web tương tác riêng tư | Đầu ra bạn muốn xem hoặc chia sẻ trực quan thay vì dưới dạng văn bản terminal    | Một dòng thời gian sự cố cập nhật khi Claude điều tra                            |

**[Plugin](/en/plugins)** là lớp đóng gói. Một plugin gói các skill, hook, subagent, và MCP server thành một đơn vị cài đặt được duy nhất. Skill của plugin được đặt trong không gian tên (namespaced) (như `/my-plugin:review`) để nhiều plugin có thể cùng tồn tại. Dùng plugin khi bạn muốn tái sử dụng cùng một thiết lập trên nhiều repository hoặc phân phối cho người khác qua một **[marketplace](/en/plugin-marketplaces)**.

### Xây dựng thiết lập của bạn theo thời gian

Bạn không cần cấu hình mọi thứ ngay từ đầu. Mỗi tính năng có một tác nhân kích hoạt (trigger) dễ nhận biết, và hầu hết các nhóm thêm chúng theo thứ tự đại khái như sau:

| Trigger (tác nhân kích hoạt)                                                       | Thêm vào                                                                                      |
| :------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------- |
| Claude làm sai một quy ước hoặc lệnh hai lần                                       | Thêm nó vào [CLAUDE.md](/en/memory)                                                            |
| Bạn cứ gõ đi gõ lại cùng một prompt để bắt đầu một tác vụ                          | Lưu nó thành một [skill](/en/skills) mà người dùng gọi được                                    |
| Bạn dán cùng một playbook hoặc quy trình nhiều bước vào chat lần thứ ba            | Nắm bắt nó thành một [skill](/en/skills)                                                       |
| Bạn cứ sao chép dữ liệu từ một tab trình duyệt mà Claude không thể thấy            | Kết nối hệ thống đó thành một [MCP server](/en/mcp)                                            |
| Claude đọc nhiều file để tìm nơi một ký hiệu được định nghĩa hoặc sử dụng          | Cài một [code intelligence plugin](/en/discover-plugins#code-intelligence) cho ngôn ngữ của bạn |
| Một tác vụ phụ làm ngập hội thoại của bạn với đầu ra bạn sẽ không tham chiếu lại   | Định tuyến nó qua một [subagent](/en/sub-agents)                                               |
| Bạn muốn điều gì đó xảy ra mỗi lần mà không cần hỏi                                | Viết một [hook](/en/hooks-guide)                                                               |
| Một repository thứ hai cần cùng một thiết lập                                      | Đóng gói nó thành một [plugin](/en/plugins)                                                    |

Cùng những trigger này cho bạn biết khi nào cần cập nhật thứ bạn đã có. Một lỗi lặp lại hoặc một nhận xét review tái diễn là một lần chỉnh sửa CLAUDE.md, không phải một lần sửa lỗi đơn lẻ trong chat. Một quy trình bạn cứ tinh chỉnh thủ công là một skill cần thêm một lần chỉnh sửa nữa.

### So sánh các tính năng tương tự

Một số tính năng có vẻ giống nhau. Đây là cách để phân biệt chúng.

<Tabs>
  <Tab title="Skill vs Subagent">
    Skill và subagent giải quyết các vấn đề khác nhau:

    * **Skill** là nội dung tái sử dụng mà bạn có thể nạp vào bất kỳ ngữ cảnh nào
    * **Subagent** là các worker tách biệt chạy riêng khỏi hội thoại chính của bạn

    | Khía cạnh                                        | Skill                                          | Subagent                                                         |
    | ----------------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------- |
    | **Nó là gì**                                    | Chỉ dẫn, kiến thức, hoặc quy trình tái sử dụng | Worker tách biệt với ngữ cảnh riêng của nó                       |
    | **Lợi ích chính**                               | Chia sẻ nội dung giữa các ngữ cảnh             | Tách biệt ngữ cảnh. Công việc diễn ra riêng, chỉ bản tóm tắt được trả về |
    | **Tác động lên [context window](/en/context-window)** | Thêm vào cửa sổ chính của bạn             | Dùng một cửa sổ riêng với input và output token của riêng nó     |
    | **Tốt nhất cho**                                | Tài liệu tham chiếu, quy trình gọi được         | Tác vụ đọc nhiều file, công việc song song, worker chuyên biệt   |

    **Skill có thể là tham chiếu hoặc hành động.** Skill tham chiếu cung cấp kiến thức mà Claude dùng xuyên suốt phiên của bạn (như bản hướng dẫn phong cách API của bạn). Skill hành động bảo Claude làm một điều gì đó cụ thể (như `/deploy` chạy quy trình triển khai của bạn).

    **Dùng một subagent** khi bạn cần tách biệt ngữ cảnh hoặc khi context window của bạn đang đầy dần. Subagent có thể đọc hàng chục file hoặc chạy các tìm kiếm sâu rộng, nhưng hội thoại chính của bạn chỉ nhận một bản tóm tắt. Vì công việc của subagent không tiêu tốn ngữ cảnh chính của bạn, điều này cũng hữu ích khi bạn không cần công việc trung gian vẫn hiển thị. Subagent tùy chỉnh có thể có chỉ dẫn riêng và có thể nạp trước (preload) skill.

    **Chúng có thể kết hợp.** Một subagent có thể nạp trước các skill cụ thể (trường `skills:`). Một skill có thể chạy trong ngữ cảnh tách biệt bằng `context: fork`. Xem [Skills](/en/skills) để biết chi tiết.
  </Tab>

  <Tab title="CLAUDE.md vs Skill">
    Cả hai đều lưu chỉ dẫn, nhưng chúng nạp khác nhau và phục vụ mục đích khác nhau.

    | Khía cạnh                 | CLAUDE.md                    | Skill                                   |
    | ------------------------- | ---------------------------- | --------------------------------------- |
    | **Nạp khi**               | Mỗi phiên, tự động            | Theo yêu cầu                             |
    | **Có thể chèn file**      | Có, với import `@path`        | Có, với import `@path`                   |
    | **Có thể kích hoạt quy trình** | Không                    | Có, với `/<name>`                       |
    | **Tốt nhất cho**          | Các quy tắc "luôn làm X"      | Tài liệu tham chiếu, quy trình gọi được |

    **Đặt vào CLAUDE.md** nếu Claude luôn cần biết: quy ước lập trình, lệnh build, cấu trúc dự án, các quy tắc "không bao giờ làm X".

    **Đặt vào một skill** nếu đó là tài liệu tham chiếu mà Claude thỉnh thoảng cần (API docs, hướng dẫn phong cách) hoặc một quy trình bạn kích hoạt bằng `/<name>` (deploy, review, release).

    **Quy tắc chung:** Giữ CLAUDE.md dưới 200 dòng. Nếu nó đang phình to, di chuyển nội dung tham chiếu sang skill hoặc tách thành các file [`.claude/rules/`](/en/memory#organize-rules-with-claude/rules/).
  </Tab>

  <Tab title="CLAUDE.md vs Rules vs Skills">
    Cả ba đều lưu chỉ dẫn, nhưng chúng nạp khác nhau:

    | Khía cạnh    | CLAUDE.md                           | `.claude/rules/`                                   | Skill                                    |
    | ------------ | ----------------------------------- | -------------------------------------------------- | ---------------------------------------- |
    | **Nạp khi**  | Mỗi phiên                           | Mỗi phiên, hoặc khi các file khớp được mở          | Theo yêu cầu, khi được gọi hoặc liên quan |
    | **Phạm vi**  | Toàn dự án                          | Có thể phạm vi hóa theo đường dẫn file             | Theo tác vụ cụ thể                        |
    | **Tốt nhất cho** | Quy ước cốt lõi và lệnh build     | Hướng dẫn theo ngôn ngữ hoặc theo thư mục          | Tài liệu tham chiếu, quy trình lặp lại    |

    **Dùng CLAUDE.md** cho các chỉ dẫn mà mọi phiên đều cần: lệnh build, quy ước test, kiến trúc dự án.

    **Dùng rules** để giữ CLAUDE.md tập trung. Rules với [`paths` frontmatter](/en/memory#path-specific-rules) chỉ nạp khi Claude làm việc với các file khớp, tiết kiệm ngữ cảnh.

    **Dùng skills** cho nội dung mà Claude chỉ thỉnh thoảng cần, như tài liệu API hoặc một checklist triển khai bạn kích hoạt bằng `/<name>`.
  </Tab>

  <Tab title="Subagent vs Agent team">
    Cả hai đều song song hóa công việc, nhưng chúng khác nhau về mặt kiến trúc:

    * **Subagent** chạy bên trong phiên của bạn và báo cáo kết quả về ngữ cảnh chính của bạn
    * **Agent team** là các phiên Claude Code độc lập giao tiếp với nhau

    | Khía cạnh          | Subagent                                         | Agent team                                          |
    | ----------------- | ------------------------------------------------ | --------------------------------------------------- |
    | **Ngữ cảnh**      | Context window riêng; kết quả trả về cho bên gọi  | Context window riêng; hoàn toàn độc lập             |
    | **Giao tiếp**     | Chỉ báo cáo kết quả về agent chính                | Các đồng đội nhắn tin trực tiếp cho nhau            |
    | **Điều phối**     | Agent chính quản lý toàn bộ công việc             | Danh sách tác vụ chung với tự điều phối             |
    | **Tốt nhất cho**  | Tác vụ tập trung nơi chỉ kết quả là quan trọng    | Công việc phức tạp cần thảo luận và cộng tác        |
    | **Chi phí token** | Thấp hơn: kết quả được tóm tắt về ngữ cảnh chính  | Cao hơn: mỗi đồng đội là một instance Claude riêng  |

    **Dùng một subagent** khi bạn cần một worker nhanh, tập trung: nghiên cứu một câu hỏi, xác minh một tuyên bố, review một file. Subagent làm công việc và trả về một bản tóm tắt. Hội thoại chính của bạn giữ được sự gọn gàng.

    **Dùng một agent team** khi các đồng đội cần chia sẻ phát hiện, thách thức lẫn nhau, và điều phối độc lập. Agent team tốt nhất cho nghiên cứu với các giả thuyết cạnh tranh, review code song song, và phát triển tính năng mới nơi mỗi đồng đội sở hữu một phần riêng.

    **Điểm chuyển tiếp:** Nếu bạn đang chạy các subagent song song nhưng chạm giới hạn ngữ cảnh, hoặc nếu các subagent của bạn cần giao tiếp với nhau, thì agent team là bước tiếp theo tự nhiên.

    <Note>
      Agent team đang trong giai đoạn thử nghiệm (experimental) và bị tắt theo mặc định. Xem [agent teams](/en/agent-teams) để biết cách thiết lập và các giới hạn hiện tại.
    </Note>
  </Tab>

  <Tab title="MCP vs Skill">
    MCP kết nối Claude với các dịch vụ bên ngoài. Skill mở rộng những gì Claude biết, bao gồm cách dùng các dịch vụ đó một cách hiệu quả.

    | Khía cạnh      | MCP                                                  | Skill                                                   |
    | -------------- | ---------------------------------------------------- | ------------------------------------------------------- |
    | **Nó là gì**   | Giao thức để kết nối tới các dịch vụ bên ngoài        | Kiến thức, quy trình, và tài liệu tham chiếu            |
    | **Cung cấp**   | Truy cập công cụ và dữ liệu                          | Kiến thức, quy trình, tài liệu tham chiếu               |
    | **Ví dụ**      | Tích hợp Slack, truy vấn database, điều khiển trình duyệt | Checklist review code, quy trình deploy, hướng dẫn phong cách API |

    Chúng giải quyết các vấn đề khác nhau và phối hợp tốt với nhau:

    **MCP** cung cấp cho Claude các công cụ được xây dựng chuyên biệt cho một hệ thống bên ngoài, với việc kết nối và xác thực do server xử lý.

    **Skill** cung cấp cho Claude kiến thức về cách dùng các công cụ đó một cách hiệu quả, cộng với các quy trình bạn có thể kích hoạt bằng `/<name>`. Một skill có thể bao gồm sơ đồ database và các mẫu truy vấn của nhóm bạn, hoặc một quy trình `/post-to-slack` với các quy tắc định dạng tin nhắn của nhóm bạn.

    Ví dụ: Một MCP server kết nối Claude tới database của bạn. Một skill dạy Claude mô hình dữ liệu của bạn, các mẫu truy vấn thông dụng, và những bảng nào cần dùng cho các tác vụ khác nhau.
  </Tab>

  <Tab title="Hook vs Skill">
    Một hook kích hoạt trên một sự kiện vòng đời; một skill được nạp vào ngữ cảnh để Claude áp dụng.

    | Khía cạnh        | Hook                                                                              | Skill                                                                 |
    | ---------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
    | **Chạy**         | Một lệnh shell, HTTP request, LLM prompt, hoặc subagent                            | Chỉ dẫn mà Claude đọc và làm theo                                     |
    | **Kích hoạt bởi** | [Các sự kiện vòng đời](/en/hooks#hook-events) như `PostToolUse` hoặc `SessionStart` | Bạn gõ `/<name>`, hoặc Claude khớp mô tả với tác vụ của bạn           |
    | **Tính xác định** | Luôn kích hoạt trên sự kiện của nó; trigger được đảm bảo                          | Claude diễn giải chỉ dẫn; kết quả có thể thay đổi                     |
    | **Chi phí ngữ cảnh** | Bằng không trừ khi hook trả về đầu ra                                          | Mô tả nạp mỗi phiên; nội dung đầy đủ nạp khi được dùng                |
    | **Tốt nhất cho** | Lint sau khi chỉnh sửa, chặn lệnh không an toàn, ghi log, thông báo               | Quy trình cần suy luận, tài liệu tham chiếu, tác vụ nhiều bước         |

    **Dùng một hook** khi hành động phải xảy ra cùng một cách mỗi lần và không cần Claude suy nghĩ. Ví dụ: format khi lưu, từ chối `rm -rf /`, đăng một tin nhắn Slack khi một phiên kết thúc.

    **Dùng một skill** khi Claude nên quyết định cách áp dụng các bước, hoặc khi nội dung là kiến thức chứ không phải một script. Ví dụ: một checklist `/release`, hướng dẫn phong cách API của bạn, một playbook gỡ lỗi.

    **Đặt các lan can bảo vệ (guardrail) vào hook.** Một chỉ dẫn như "never edit `.env`" trong CLAUDE.md hoặc một skill là một yêu cầu, không phải một sự đảm bảo. Một hook `PreToolUse` chặn việc chỉnh sửa là sự thực thi (enforcement). Nếu một quy tắc phải giữ đúng mỗi lần, hãy biến nó thành một hook thay vì một chỉ dẫn prompt.

    **Đầu ra của hook đi vào ngữ cảnh.** Một hook `PostToolUse` chạy linter của bạn đưa kết quả trở lại dưới dạng văn bản mà Claude đọc; một skill `/fix-lint` bảo Claude cách giải quyết chúng.
  </Tab>
</Tabs>

### Hiểu cách các tính năng xếp lớp

Các tính năng có thể được định nghĩa ở nhiều cấp độ: toàn người dùng (user-wide), theo từng dự án (per-project), qua plugin, hoặc thông qua các chính sách được quản lý (managed policies). Bạn cũng có thể lồng các file CLAUDE.md trong các thư mục con hoặc đặt skill trong các package cụ thể của một monorepo. Khi cùng một tính năng tồn tại ở nhiều cấp độ, đây là cách chúng xếp lớp:

* **Các file CLAUDE.md** có tính cộng dồn (additive): tất cả các cấp độ đóng góp nội dung vào ngữ cảnh của Claude đồng thời. Các file từ thư mục làm việc của bạn và cấp trên nạp khi khởi động; các thư mục con nạp khi bạn làm việc trong chúng. Khi các chỉ dẫn xung đột, Claude dùng phán đoán để hòa giải chúng, với các chỉ dẫn cụ thể hơn thường được ưu tiên. Xem [how CLAUDE.md files load](/en/memory#how-claude-md-files-load).
* **Skill và subagent** ghi đè theo tên: khi cùng một tên tồn tại ở nhiều cấp độ, một định nghĩa thắng dựa trên độ ưu tiên (managed > user > project với skill; managed > CLI flag > project > user > plugin với subagent). Skill của plugin được [đặt trong không gian tên](/en/plugins#add-skills-to-your-plugin) để tránh xung đột. Xem [skill discovery](/en/skills#where-skills-live) và [subagent scope](/en/sub-agents#choose-the-subagent-scope).
* **MCP server** ghi đè theo tên: local > project > user. Xem [MCP scope](/en/mcp#scope-hierarchy-and-precedence).
* **Hook** hợp nhất (merge): tất cả các hook đã đăng ký đều kích hoạt cho các sự kiện khớp của chúng bất kể nguồn. Xem [hooks](/en/hooks).

### Kết hợp các tính năng

Mỗi phần mở rộng giải quyết một vấn đề khác nhau: CLAUDE.md xử lý ngữ cảnh luôn bật, skill xử lý kiến thức và quy trình theo yêu cầu, MCP xử lý các kết nối bên ngoài, subagent xử lý sự tách biệt, và hook xử lý tự động hóa. Các thiết lập thực tế kết hợp chúng dựa trên quy trình của bạn.

Ví dụ, bạn có thể dùng CLAUDE.md cho quy ước dự án, một skill cho quy trình triển khai của bạn, MCP để kết nối tới database của bạn, và một hook để chạy lint sau mỗi lần chỉnh sửa. Mỗi tính năng xử lý cái nó làm tốt nhất.

| Mẫu (Pattern)          | Cách nó hoạt động                                                                | Ví dụ                                                                                             |
| ---------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Skill + MCP**        | MCP cung cấp kết nối; một skill dạy Claude cách dùng nó cho tốt                   | MCP kết nối tới database của bạn, một skill ghi lại sơ đồ và các mẫu truy vấn của bạn              |
| **Skill + Subagent**   | Một skill sinh ra các subagent cho công việc song song                           | Skill `/audit` khởi động các subagent bảo mật, hiệu năng, và phong cách làm việc trong ngữ cảnh tách biệt |
| **CLAUDE.md + Skills** | CLAUDE.md giữ các quy tắc luôn bật; skill giữ tài liệu tham chiếu nạp theo yêu cầu | CLAUDE.md nói "follow our API conventions", một skill chứa toàn bộ hướng dẫn phong cách API        |
| **Hook + MCP**         | Một hook kích hoạt các hành động bên ngoài qua MCP                               | Hook sau khi chỉnh sửa gửi một thông báo Slack khi Claude sửa đổi các file quan trọng             |

## Hiểu về chi phí ngữ cảnh (context costs)

Mỗi tính năng bạn thêm vào đều tiêu tốn một phần ngữ cảnh của Claude. Quá nhiều có thể làm đầy context window của bạn, nhưng nó cũng có thể thêm nhiễu khiến Claude kém hiệu quả hơn; skill có thể không kích hoạt đúng cách, hoặc Claude có thể mất dấu các quy ước của bạn. Hiểu các đánh đổi này giúp bạn xây dựng một thiết lập hiệu quả. Để có góc nhìn tương tác về cách các tính năng này kết hợp trong một phiên đang chạy, xem [Explore the context window](/en/context-window).

### Chi phí ngữ cảnh theo tính năng

Mỗi tính năng có một chiến lược nạp và chi phí ngữ cảnh khác nhau:

| Tính năng             | Khi nào nạp                    | Cái gì được nạp                                     | Chi phí ngữ cảnh                             |
| --------------------- | ------------------------------ | --------------------------------------------------- | -------------------------------------------- |
| **CLAUDE.md**         | Khởi động phiên                | Toàn bộ nội dung                                     | Mỗi request                                  |
| **Skills**            | Khởi động phiên + khi được dùng | Mô tả khi khởi động, nội dung đầy đủ khi được dùng   | Thấp (mô tả mỗi request)\*                    |
| **MCP servers**       | Khởi động phiên                | Tên công cụ; schema đầy đủ theo yêu cầu              | Thấp cho đến khi một công cụ được dùng        |
| **Code intelligence** | Sau khi chỉnh sửa file và theo yêu cầu | Chẩn đoán sau khi chỉnh sửa; vị trí ký hiệu khi tra cứu | Thấp; giảm việc đọc file ở nơi khác           |
| **Subagents**         | Khi được sinh ra               | Ngữ cảnh mới với các skill được chỉ định             | Tách biệt khỏi phiên chính                   |
| **Hooks**             | Khi được kích hoạt             | Không có gì (chạy bên ngoài)                         | Bằng không, trừ khi hook trả về ngữ cảnh bổ sung |

\*Theo mặc định, mô tả skill nạp ở đầu phiên để Claude có thể quyết định khi nào dùng chúng. Đặt `disable-model-invocation: true` trong frontmatter của một skill để ẩn nó hoàn toàn khỏi Claude cho đến khi bạn gọi nó thủ công. Điều này giảm chi phí ngữ cảnh xuống bằng không cho các skill bạn chỉ tự kích hoạt. Với một skill bạn không viết, đặt [`skillOverrides`](/en/skills#override-skill-visibility-from-settings) trong settings để làm điều tương tự mà không cần chỉnh sửa file của nó.

### Hiểu cách các tính năng nạp

Mỗi tính năng nạp ở các thời điểm khác nhau trong phiên của bạn. Các tab dưới đây giải thích khi nào mỗi cái nạp và cái gì đi vào ngữ cảnh.

<img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/context-loading.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=aab139e750494a237ae2e0c8f9139b0a" alt="Context loading: CLAUDE.md loads at session start and stays in every request. MCP tool names load at start with full schemas deferred until use. Skills load descriptions at start, full content on invocation. Subagents get isolated context. Hooks run externally." width="720" height="382" data-path="images/context-loading.svg" />

<Tabs>
  <Tab title="CLAUDE.md">
    **Khi nào:** Khởi động phiên

    **Cái gì được nạp:** Toàn bộ nội dung của tất cả các file CLAUDE.md (các cấp managed, user, và project).

    **Kế thừa:** Claude đọc các file CLAUDE.md từ thư mục làm việc của bạn lên đến gốc, và phát hiện các file lồng nhau trong các thư mục con khi nó truy cập các file đó. Xem [How CLAUDE.md files load](/en/memory#how-claude-md-files-load) để biết chi tiết.

    <Tip>Giữ CLAUDE.md dưới 200 dòng. Di chuyển tài liệu tham chiếu sang skill, vốn nạp theo yêu cầu.</Tip>
  </Tab>

  <Tab title="Skills">
    Skill là các khả năng bổ sung trong bộ công cụ của Claude. Chúng có thể là tài liệu tham chiếu (như một hướng dẫn phong cách API) hoặc các quy trình gọi được mà bạn kích hoạt bằng `/<name>` (như `/deploy`). Claude Code bao gồm [các skill đóng gói sẵn (bundled skills)](/en/commands) như `/code-review`, `/batch`, và `/debug` hoạt động ngay lập tức. Bạn cũng có thể tạo skill của riêng mình. Claude dùng skill khi thích hợp, hoặc bạn có thể gọi một skill trực tiếp.

    **Khi nào:** Tùy vào cấu hình của skill. Theo mặc định, mô tả nạp ở đầu phiên và nội dung đầy đủ nạp khi được dùng. Với các skill chỉ dành cho người dùng (`disable-model-invocation: true`), không có gì nạp cho đến khi bạn gọi chúng.

    **Cái gì được nạp:** Với các skill mà model có thể gọi, Claude thấy tên và mô tả trong mỗi request. Khi bạn gọi một skill bằng `/<name>` hoặc Claude nạp nó tự động, toàn bộ nội dung nạp vào hội thoại của bạn.

    **Cách Claude chọn skill:** Claude khớp tác vụ của bạn với các mô tả skill để quyết định cái nào liên quan. Nếu các mô tả mơ hồ hoặc trùng lặp, Claude có thể nạp sai skill hoặc bỏ lỡ một cái có thể giúp ích. Để bảo Claude dùng một skill cụ thể, hãy gọi nó bằng `/<name>`. Các skill có `disable-model-invocation: true` là vô hình với Claude cho đến khi bạn gọi chúng.

    **Chi phí ngữ cảnh:** Thấp cho đến khi được dùng. Các skill chỉ dành cho người dùng có chi phí bằng không cho đến khi được gọi.

    **Trong subagent:** Skill hoạt động khác trong subagent. Thay vì nạp theo yêu cầu, các skill được liệt kê trong trường `skills` của subagent được nạp trước hoàn toàn vào ngữ cảnh của nó khi khởi động. Subagent vẫn có thể phát hiện và gọi các skill project, user, và plugin chưa được liệt kê thông qua công cụ Skill.

    <Tip>Dùng `disable-model-invocation: true` cho các skill có tác dụng phụ. Điều này tiết kiệm ngữ cảnh và đảm bảo chỉ bạn kích hoạt chúng.</Tip>
  </Tab>

  <Tab title="MCP servers">
    **Khi nào:** Khởi động phiên.

    **Cái gì được nạp:** Tên công cụ từ các server đã kết nối. Các JSON schema đầy đủ vẫn được hoãn cho đến khi Claude cần một công cụ cụ thể.

    **Chi phí ngữ cảnh:** [Tool search](/en/mcp#scale-with-mcp-tool-search) được bật theo mặc định, nên các công cụ MCP nhàn rỗi tiêu tốn ngữ cảnh tối thiểu.

    <Tip>Chạy `/mcp` để xem trạng thái kết nối và chi phí token theo từng server. Claude Code [tự động kết nối lại tới các server từ xa](/en/mcp#automatic-reconnection) nếu chúng bị rớt, và bạn có thể ngắt kết nối các server bạn không dùng tích cực.</Tip>
  </Tab>

  <Tab title="Code intelligence">
    **Khi nào:** Sau khi chỉnh sửa file, và theo yêu cầu khi Claude điều hướng code.

    **Cái gì được nạp:** Lỗi kiểu và cảnh báo sau mỗi lần chỉnh sửa file. Thông tin định nghĩa, tham chiếu, và kiểu khi Claude tra cứu một ký hiệu.

    **Chi phí ngữ cảnh:** Thấp. Việc tra cứu ký hiệu thường thay thế việc đọc file trên diện rộng, nên mức dùng ngữ cảnh ròng có thể giảm.

    <Tip>Công cụ LSP không hoạt động cho đến khi bạn cài một [code intelligence plugin](/en/discover-plugins#code-intelligence) cho ngôn ngữ của bạn.</Tip>
  </Tab>

  <Tab title="Subagents">
    **Khi nào:** Theo yêu cầu, khi bạn hoặc Claude sinh ra một cái cho một tác vụ.

    **Cái gì được nạp:** Ngữ cảnh mới, tách biệt chứa:

    * System prompt riêng của agent, không phải toàn bộ system prompt của Claude Code
    * Toàn bộ nội dung của các skill được liệt kê trong trường `skills:` của agent
    * CLAUDE.md và trạng thái git, ngoại trừ các agent Explore và Plan tích hợp sẵn [bỏ qua cả hai](/en/sub-agents#what-loads-at-startup)
    * Bất kỳ ngữ cảnh nào agent chính truyền vào trong prompt

    **Chi phí ngữ cảnh:** Tách biệt khỏi phiên chính. Subagent không kế thừa lịch sử hội thoại hoặc các skill đã gọi của bạn.

    <Tip>Dùng subagent cho công việc không cần toàn bộ ngữ cảnh hội thoại của bạn. Sự tách biệt của chúng ngăn làm phình phiên chính của bạn.</Tip>
  </Tab>

  <Tab title="Hooks">
    **Khi nào:** Khi được kích hoạt. Hook kích hoạt tại các sự kiện vòng đời cụ thể như thực thi công cụ, ranh giới phiên, gửi prompt, yêu cầu quyền hạn, và nén. Xem [Hooks](/en/hooks) để có danh sách đầy đủ.

    **Cái gì được nạp:** Không có gì theo mặc định. Hook thực thi bên ngoài hội thoại chính.

    **Chi phí ngữ cảnh:** Bằng không, trừ khi hook trả về đầu ra được thêm dưới dạng tin nhắn vào hội thoại của bạn.

    <Tip>Hook lý tưởng cho các tác dụng phụ (lint, ghi log) không cần ảnh hưởng đến ngữ cảnh của Claude.</Tip>
  </Tab>
</Tabs>

## Tìm hiểu thêm

Mỗi tính năng có hướng dẫn riêng với các hướng dẫn thiết lập, ví dụ, và tùy chọn cấu hình.

<CardGroup cols={2}>
  <Card title="CLAUDE.md" icon="file-lines" href="/en/memory">
    Lưu ngữ cảnh dự án, quy ước, và chỉ dẫn
  </Card>

  <Card title="Skills" icon="brain" href="/en/skills">
    Trao cho Claude chuyên môn theo lĩnh vực và các quy trình tái sử dụng
  </Card>

  <Card title="Subagents" icon="users" href="/en/sub-agents">
    Giao phó công việc cho ngữ cảnh tách biệt
  </Card>

  <Card title="Agent teams" icon="network" href="/en/agent-teams">
    Điều phối nhiều phiên làm việc song song
  </Card>

  <Card title="MCP" icon="plug" href="/en/mcp">
    Kết nối Claude với các dịch vụ bên ngoài
  </Card>

  <Card title="Hooks" icon="bolt" href="/en/hooks-guide">
    Tự động hóa hành động với hook
  </Card>

  <Card title="Plugins" icon="puzzle-piece" href="/en/plugins">
    Đóng gói và chia sẻ các bộ tính năng
  </Card>

  <Card title="Marketplaces" icon="store" href="/en/plugin-marketplaces">
    Lưu trữ và phân phối các bộ sưu tập plugin
  </Card>
</CardGroup>
