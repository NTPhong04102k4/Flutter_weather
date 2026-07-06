> Nguồn: https://code.claude.com/docs/en/agent-teams.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Điều phối các nhóm phiên Claude Code

> Điều phối nhiều phiên bản Claude Code cùng làm việc như một nhóm, với danh sách công việc chung, nhắn tin giữa các agent, và quản lý tập trung.

<Warning>
  Agent teams là tính năng thử nghiệm và bị tắt theo mặc định. Bật chúng bằng cách thêm `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` vào [settings.json](/en/settings) hoặc vào môi trường của bạn. Nếu không có biến đó, sẽ không có nhóm nào được thiết lập khi bắt đầu phiên, không có thư mục nhóm nào được ghi, và Claude không tạo hay đề xuất các thành viên (teammate). Agent teams có [những hạn chế đã biết](#limitations) liên quan đến việc khôi phục phiên, điều phối công việc, và hành vi tắt.
</Warning>

Agent teams cho phép bạn điều phối nhiều phiên bản Claude Code cùng làm việc với nhau. Một phiên đóng vai trò trưởng nhóm (team lead), điều phối công việc, giao nhiệm vụ, và tổng hợp kết quả. Các thành viên (teammate) làm việc độc lập, mỗi người trong context window (cửa sổ ngữ cảnh) riêng, và giao tiếp trực tiếp với nhau.

Không giống như [subagent](/en/sub-agents), vốn chạy trong một phiên duy nhất và chỉ có thể báo cáo lại cho agent chính, bạn còn có thể tương tác trực tiếp với từng thành viên mà không cần thông qua trưởng nhóm.

<Note>
  Trang này mô tả agent teams tính đến phiên bản v2.1.178. Khi đã đặt `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, việc tạo một thành viên không còn cần bước thiết lập, và việc dọn dẹp diễn ra tự động khi phiên thoát. Trước v2.1.178, bạn phải yêu cầu Claude tạo và đặt tên cho nhóm trước, và Claude dùng các công cụ `TeamCreate` và `TeamDelete` để thiết lập và xóa nhóm. Cả hai công cụ này không còn tồn tại. Đầu vào `team_name` trên công cụ Agent vẫn được chấp nhận nhưng bị bỏ qua, và trường `team_name` trong các [payload của hook](/en/hooks#taskcreated) `TaskCreated`, `TaskCompleted`, và `TeammateIdle` mang tên bắt nguồn từ phiên và đã bị coi là lỗi thời (deprecated).
</Note>

## Khi nào dùng agent teams

Agent teams hiệu quả nhất cho các tác vụ mà việc khám phá song song mang lại giá trị thực sự. Xem [các ví dụ tình huống sử dụng](#use-case-examples) để có kịch bản đầy đủ. Các tình huống mạnh nhất là:

* **Nghiên cứu và rà soát**: nhiều thành viên có thể điều tra các khía cạnh khác nhau của một vấn đề cùng lúc, sau đó chia sẻ và phản biện phát hiện của nhau
* **Module hoặc tính năng mới**: mỗi thành viên có thể sở hữu một phần riêng mà không giẫm chân nhau
* **Gỡ lỗi với các giả thuyết cạnh tranh**: các thành viên kiểm chứng những lý thuyết khác nhau song song và hội tụ về câu trả lời nhanh hơn
* **Phối hợp xuyên tầng (cross-layer)**: những thay đổi trải rộng qua frontend, backend, và tests, mỗi phần do một thành viên khác nhau đảm nhiệm

Agent teams thêm chi phí điều phối và tiêu tốn nhiều token hơn đáng kể so với một phiên đơn. Chúng hoạt động tốt nhất khi các thành viên có thể vận hành độc lập. Với các tác vụ tuần tự, sửa cùng một file, hoặc công việc có nhiều phụ thuộc, thì một phiên đơn hoặc [subagent](/en/sub-agents) sẽ hiệu quả hơn.

### So sánh với subagent

Cả agent teams và [subagent](/en/sub-agents) đều cho phép bạn song song hóa công việc, nhưng chúng vận hành khác nhau. Hãy chọn dựa trên việc các worker của bạn có cần giao tiếp với nhau hay không:

<Frame caption="Subagent chỉ báo cáo kết quả lại cho agent chính và không bao giờ trò chuyện với nhau. Trong agent teams, các thành viên chia sẻ một danh sách công việc, nhận việc, và giao tiếp trực tiếp với nhau.">
  <img src="https://mintcdn.com/claude-code/nsvRFSDNfpSU5nT7/images/subagents-vs-agent-teams-light.png?fit=max&auto=format&n=nsvRFSDNfpSU5nT7&q=85&s=2f8db9b4f3705dd3ab931fbe2d96e42a" className="dark:hidden" alt="Sơ đồ so sánh kiến trúc subagent và agent team. Subagent được agent chính tạo ra, làm việc, và báo cáo kết quả lại. Agent teams điều phối thông qua một danh sách công việc chung, với các thành viên giao tiếp trực tiếp với nhau." width="4245" height="1615" data-path="images/subagents-vs-agent-teams-light.png" />

  <img src="https://mintcdn.com/claude-code/nsvRFSDNfpSU5nT7/images/subagents-vs-agent-teams-dark.png?fit=max&auto=format&n=nsvRFSDNfpSU5nT7&q=85&s=d573a037540f2ada6a9ae7d8285b46fd" className="hidden dark:block" alt="Sơ đồ so sánh kiến trúc subagent và agent team. Subagent được agent chính tạo ra, làm việc, và báo cáo kết quả lại. Agent teams điều phối thông qua một danh sách công việc chung, với các thành viên giao tiếp trực tiếp với nhau." width="4245" height="1615" data-path="images/subagents-vs-agent-teams-dark.png" />
</Frame>

|                     | Subagent                                                    | Agent teams                                                     |
| :------------------ | :--------------------------------------------------------- | :------------------------------------------------------------- |
| **Ngữ cảnh**        | Context window riêng; kết quả trả về cho bên gọi           | Context window riêng; hoàn toàn độc lập                        |
| **Giao tiếp**       | Chỉ báo cáo kết quả lại cho agent chính                    | Các thành viên nhắn tin trực tiếp cho nhau                     |
| **Điều phối**       | Agent chính quản lý toàn bộ công việc                      | Danh sách công việc chung với khả năng tự điều phối            |
| **Phù hợp nhất cho**| Tác vụ tập trung khi chỉ cần kết quả                       | Công việc phức tạp cần thảo luận và cộng tác                   |
| **Chi phí token**   | Thấp hơn: kết quả được tóm tắt lại về ngữ cảnh chính       | Cao hơn: mỗi thành viên là một phiên bản Claude riêng biệt     |

Dùng subagent khi bạn cần các worker nhanh, tập trung, báo cáo lại. Dùng agent teams khi các thành viên cần chia sẻ phát hiện, phản biện lẫn nhau, và tự điều phối.

## Bật agent teams

Agent teams bị tắt theo mặc định. Bật chúng bằng cách đặt biến môi trường `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` thành `1`, hoặc trong môi trường shell của bạn hoặc thông qua [settings.json](/en/settings):

```json settings.json theme={null}
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Bắt đầu agent team đầu tiên của bạn

Sau khi bật agent teams, hãy mô tả tác vụ và các thành viên bạn muốn bằng ngôn ngữ tự nhiên. Claude tạo chúng và điều phối công việc dựa trên prompt của bạn.

Ví dụ này hoạt động tốt vì ba vai trò là độc lập và có thể khám phá vấn đề mà không phải chờ đợi lẫn nhau:

```text theme={null}
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Spawn three teammates to explore this from different angles:
one on UX, one on technical architecture, one playing devil's advocate.
```

Từ đó, Claude điền vào một [danh sách công việc chung](/en/interactive-mode#task-list), tạo các thành viên cho từng góc nhìn, cho họ khám phá vấn đề, và tổng hợp phát hiện khi hoàn thành.

Terminal của trưởng nhóm liệt kê các thành viên trong bảng agent (agent panel) bên dưới ô nhập prompt. Từ bảng này:

* **Mũi tên lên và xuống**: chọn một thành viên
* **Enter**: mở bản ghi (transcript) của thành viên đã chọn và nhắn tin trực tiếp cho họ
* **Escape**: ngắt lượt hiện tại của thành viên đã chọn

{/* min-version: 2.1.199 */}Kể từ v2.1.199, dòng của một thành viên đang rảnh (idle) vẫn ở lại trong bảng khi còn bất kỳ thành viên hoặc subagent nào vẫn đang làm việc, nên bạn có thể chọn nó để xem lại transcript hoặc giao thêm việc. Một khi mọi agent trong bảng đều rảnh, các dòng rảnh sẽ ẩn đi sau 30 giây và xuất hiện lại ở lượt tiếp theo của thành viên; thành viên vẫn tiếp tục chạy và có thể được liên hệ khi đang ẩn. Trong các phiên bản từ v2.1.181 đến v2.1.198, một dòng rảnh sẽ ẩn 30 giây sau khi lượt của chính nó kết thúc, kể cả khi các thành viên khác vẫn đang làm việc; các dòng rảnh không bị ẩn ở các phiên bản trước v2.1.181.

Khi có hơn ba thành viên cùng rảnh một lúc, các dòng vượt quá ba dòng đầu sẽ gộp lại thành một dòng duy nhất đếm số thành viên đã gộp, chẳng hạn `2 idle agents` khi có năm thành viên rảnh. Chọn nó và nhấn Enter để mở rộng các dòng đã gộp, hoặc nhấn Esc để gộp lại. Các thành viên đang làm việc, các thành viên bị lỗi, và thành viên bạn đang xem luôn giữ dòng riêng của mình.

Nếu bạn muốn mỗi thành viên có ngăn (pane) chia riêng, xem [Chọn chế độ hiển thị](#choose-a-display-mode).

## Kiểm soát agent team của bạn

Nói cho trưởng nhóm biết điều bạn muốn bằng ngôn ngữ tự nhiên. Nó xử lý việc điều phối nhóm, giao nhiệm vụ, và ủy quyền dựa trên chỉ dẫn của bạn.

### Chọn chế độ hiển thị

Agent teams hỗ trợ hai chế độ hiển thị:

* **In-process**: tất cả thành viên chạy bên trong terminal chính của bạn. Dùng phím mũi tên lên và xuống trong agent panel để chọn một thành viên, rồi nhấn Enter để xem và gõ để nhắn tin trực tiếp cho họ. Hoạt động trong mọi terminal, không cần thiết lập thêm.
* **Split panes (chia ngăn)**: mỗi thành viên có ngăn riêng. Bạn có thể thấy đầu ra của mọi người cùng lúc và bấm vào một ngăn để tương tác trực tiếp. Yêu cầu tmux, hoặc iTerm2.

<Note>
  `tmux` có những hạn chế đã biết trên một số hệ điều hành và theo truyền thống hoạt động tốt nhất trên macOS. Dùng `tmux -CC` trong iTerm2 là điểm khởi đầu được đề xuất để vào `tmux`.
</Note>

Mặc định là `"in-process"`. Trước v2.1.179 mặc định là `"auto"`, nên các phiên đã nâng cấp mà trước đây mở split panes giờ vẫn ở trong một terminal trừ khi bạn đặt chế độ tường minh. Đặt `"auto"` để bật split panes khi bạn đã đang chạy bên trong một phiên tmux, hoặc khi terminal của bạn là iTerm2 với `it2` CLI đã cài đặt, và quay về in-process trong các trường hợp khác. Cài đặt `"tmux"` bật chế độ split-pane và tự động phát hiện nên dùng tmux hay iTerm2 dựa trên terminal của bạn.

{/* min-version: 2.1.186 */}Kể từ v2.1.186, đặt `"iterm2"` để dùng split panes gốc của iTerm2 một cách tường minh. Chế độ này yêu cầu [`it2` CLI](https://github.com/mkusaka/it2) và hiển thị lỗi kèm lệnh cài đặt nếu thiếu `it2`. Lời nhắc thiết lập đề nghị cài `it2` hoặc chuyển sang tmux xuất hiện dưới `"auto"` hoặc `"tmux"` khi terminal của bạn là iTerm2 và tmux có sẵn làm phương án dự phòng.

Để ghi đè mặc định, đặt [`teammateMode`](/en/settings#available-settings) trong `~/.claude/settings.json`:

```json theme={null}
{
  "teammateMode": "auto"
}
```

Để đặt chế độ cho một phiên duy nhất, truyền nó dưới dạng flag:

```bash theme={null}
claude --teammate-mode auto
```

Chế độ split-pane yêu cầu hoặc [tmux](https://github.com/tmux/tmux/wiki) hoặc iTerm2 với [`it2` CLI](https://github.com/mkusaka/it2). Để cài đặt thủ công:

* **tmux**: cài đặt thông qua trình quản lý gói của hệ thống. Xem [tmux wiki](https://github.com/tmux/tmux/wiki/Installing) để có hướng dẫn theo từng nền tảng.
* **iTerm2**: cài đặt [`it2` CLI](https://github.com/mkusaka/it2), sau đó bật Python API trong **iTerm2 → Settings → General → Magic → Enable Python API**.

### Chỉ định thành viên và model

Claude quyết định số lượng thành viên cần tạo dựa trên tác vụ của bạn, hoặc bạn có thể chỉ định chính xác điều bạn muốn:

```text theme={null}
Spawn 4 teammates to refactor these modules in parallel. Use Sonnet for
each teammate.
```

Các thành viên không thừa hưởng lựa chọn `/model` của trưởng nhóm theo mặc định. Để thay đổi model được dùng khi prompt không chỉ định, đặt **Default teammate model** trong `/config`. Chọn **Default (leader's model)** để các thành viên đi theo model hiện tại của trưởng nhóm.

{/* min-version: 2.1.186 */}Các thành viên thừa hưởng [mức độ nỗ lực (effort level)](/en/model-config#adjust-effort-level) của trưởng nhóm. Trong chế độ split-pane điều này áp dụng từ v2.1.186; các phiên bản trước không truyền effort của phiên trưởng nhóm cho các thành viên split-pane.

### Yêu cầu phê duyệt kế hoạch cho thành viên

Với các tác vụ phức tạp hoặc rủi ro, bạn có thể yêu cầu các thành viên lập kế hoạch trước khi triển khai. Thành viên làm việc ở chế độ plan chỉ đọc (read-only plan mode) cho đến khi trưởng nhóm phê duyệt cách tiếp cận của họ:

```text theme={null}
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

Khi một thành viên hoàn thành lập kế hoạch, nó gửi một yêu cầu phê duyệt kế hoạch cho trưởng nhóm. Trưởng nhóm xem xét kế hoạch và hoặc phê duyệt hoặc từ chối kèm phản hồi. Nếu bị từ chối, thành viên vẫn ở trong plan mode, chỉnh sửa dựa trên phản hồi, và gửi lại. Một khi được phê duyệt, thành viên thoát plan mode và bắt đầu triển khai.

Trưởng nhóm đưa ra quyết định phê duyệt một cách tự động. Để ảnh hưởng đến phán đoán của trưởng nhóm, hãy đưa cho nó tiêu chí trong prompt của bạn, chẳng hạn "only approve plans that include test coverage" hoặc "reject plans that modify the database schema."

### Trò chuyện trực tiếp với thành viên

Mỗi thành viên là một phiên Claude Code đầy đủ, độc lập. Bạn có thể nhắn tin trực tiếp cho bất kỳ thành viên nào để đưa thêm chỉ dẫn, hỏi câu hỏi tiếp theo, hoặc chuyển hướng cách tiếp cận của họ.

* **Chế độ in-process**: dùng phím mũi tên lên và xuống trong agent panel để chọn một thành viên, rồi nhấn Enter để xem phiên của họ và gõ để gửi tin nhắn. Nhấn `x` trên một thành viên đã chọn để dừng nó. Nhấn Ctrl+T để bật/tắt danh sách công việc.
* **Chế độ split-pane**: bấm vào ngăn của một thành viên để tương tác trực tiếp với phiên của họ. Mỗi thành viên có một khung nhìn đầy đủ về terminal của chính mình.

Khi bạn đang xem một thành viên in-process, văn bản thuần và [skill](/en/skills) sẽ đi đến thành viên đó, nhưng các lệnh dựng sẵn (built-in command) vẫn chạy trong phiên của trưởng nhóm.

Model và chế độ nhanh (fast mode) của một thành viên được cố định khi nó được tạo, nên `/model` và `/fast` chỉ thay đổi cài đặt của trưởng nhóm. {/* min-version: 2.1.199 */}Kể từ v2.1.199, gõ một trong hai lệnh này khi đang xem một thành viên sẽ hiển thị thông báo rằng thay đổi áp dụng cho trưởng nhóm; các phiên bản trước áp dụng nó cho trưởng nhóm mà không có dấu hiệu nào. `/effort` vẫn áp dụng cho các lượt sau của thành viên đang xem, vì các thành viên đi theo [mức độ nỗ lực (effort level)](/en/model-config#adjust-effort-level) của trưởng nhóm.

### Giao và nhận nhiệm vụ

Danh sách công việc chung điều phối công việc trên toàn nhóm. Trưởng nhóm tạo nhiệm vụ và các thành viên thực hiện chúng. Nhiệm vụ có ba trạng thái: đang chờ (pending), đang thực hiện (in progress), và đã hoàn thành (completed). Nhiệm vụ cũng có thể phụ thuộc vào các nhiệm vụ khác: một nhiệm vụ đang chờ có phụ thuộc chưa được giải quyết thì không thể được nhận cho đến khi các phụ thuộc đó hoàn thành.

Trưởng nhóm có thể giao nhiệm vụ tường minh, hoặc các thành viên có thể tự nhận:

* **Trưởng nhóm giao**: nói cho trưởng nhóm biết nên giao nhiệm vụ nào cho thành viên nào
* **Tự nhận**: sau khi hoàn thành một nhiệm vụ, một thành viên tự nhận nhiệm vụ chưa được giao, không bị chặn tiếp theo

Việc nhận nhiệm vụ dùng cơ chế khóa file (file locking) để ngăn tình trạng tranh chấp (race condition) khi nhiều thành viên cùng cố nhận một nhiệm vụ đồng thời.

### Tắt thành viên

Để kết thúc phiên của một thành viên một cách nhẹ nhàng, hãy nhắc đến nó theo tên. Ví dụ, với một thành viên tên researcher:

```text theme={null}
Ask the researcher teammate to shut down
```

Trưởng nhóm gửi một yêu cầu tắt. Thành viên có thể phê duyệt, thoát một cách nhẹ nhàng, hoặc từ chối kèm giải thích.

Các thư mục chung của nhóm được dọn dẹp tự động khi phiên kết thúc, nên không có bước dọn dẹp riêng biệt nào. Xem [Kiến trúc](#architecture) để biết những thư mục nào bị xóa và những thư mục nào được giữ lại cho các phiên được khôi phục.

### Thực thi các cổng chất lượng (quality gate) bằng hook

Dùng [hook](/en/hooks) để thực thi quy tắc khi các thành viên hoàn thành công việc hoặc khi nhiệm vụ được tạo hay hoàn thành:

* [`TeammateIdle`](/en/hooks#teammateidle): chạy khi một thành viên sắp chuyển sang trạng thái rảnh. Thoát với mã 2 để gửi phản hồi và giữ thành viên tiếp tục làm việc.
* [`TaskCreated`](/en/hooks#taskcreated): chạy khi một nhiệm vụ đang được tạo. Thoát với mã 2 để ngăn việc tạo và gửi phản hồi.
* [`TaskCompleted`](/en/hooks#taskcompleted): chạy khi một nhiệm vụ đang được đánh dấu hoàn thành. Thoát với mã 2 để ngăn việc hoàn thành và gửi phản hồi.

## Agent teams hoạt động như thế nào

Phần này trình bày kiến trúc và cơ chế đằng sau agent teams. Nếu bạn muốn bắt đầu sử dụng chúng, xem [Kiểm soát agent team của bạn](#control-your-agent-team) ở trên.

### Claude khởi động agent teams như thế nào

Một agent team hình thành khi thành viên đầu tiên được tạo, với phiên chính đóng vai trò trưởng nhóm. Có hai cách các thành viên được tạo:

* **Bạn yêu cầu thành viên**: đưa cho Claude một tác vụ hưởng lợi từ công việc song song và yêu cầu tường minh có thành viên. Claude tạo chúng dựa trên chỉ dẫn của bạn.
* **Claude đề xuất thành viên**: nếu Claude xác định tác vụ của bạn sẽ hưởng lợi từ công việc song song, nó có thể đề nghị tạo thành viên. Bạn xác nhận trước khi nó tiến hành.

Trong cả hai trường hợp, bạn vẫn giữ quyền kiểm soát. Claude sẽ không tạo thành viên khi chưa có sự chấp thuận của bạn.

### Kiến trúc

Một agent team bao gồm:

| Thành phần        | Vai trò                                                                            |
| :---------------- | :-------------------------------------------------------------------------------- |
| **Team lead**     | Phiên Claude Code chính tạo các thành viên và điều phối công việc                  |
| **Teammates**     | Các phiên bản Claude Code riêng biệt, mỗi phiên làm việc trên nhiệm vụ được giao   |
| **Task list**     | Danh sách công việc chung mà các thành viên nhận và hoàn thành                     |
| **Mailbox**       | Hệ thống nhắn tin để giao tiếp giữa các agent                                      |

Xem [Chọn chế độ hiển thị](#choose-a-display-mode) để biết các lựa chọn cấu hình hiển thị. Tin nhắn của thành viên tự động đến trưởng nhóm.

Hệ thống quản lý các phụ thuộc nhiệm vụ một cách tự động. Khi một thành viên hoàn thành một nhiệm vụ mà các nhiệm vụ khác phụ thuộc vào, các nhiệm vụ bị chặn sẽ được gỡ chặn mà không cần can thiệp thủ công.

Nhóm và nhiệm vụ được lưu cục bộ dưới một tên bắt nguồn từ phiên. Tên là `session-` theo sau bởi tám ký tự đầu của session ID:

* **Cấu hình nhóm**: `~/.claude/teams/{team-name}/config.json`
* **Danh sách công việc**: `~/.claude/tasks/{team-name}/`

Claude Code tạo cả hai thứ này một cách tự động khi khởi động phiên và cập nhật chúng khi các thành viên tham gia, chuyển sang rảnh, hoặc rời đi. Thư mục cấu hình nhóm bị xóa khi phiên kết thúc. Thư mục danh sách công việc được giữ lại cục bộ và không bao giờ được tải lên, nên các phiên được khôi phục vẫn giữ nhiệm vụ của mình. Việc lưu giữ được quản lý bởi cùng một [`cleanupPeriodDays`](/en/settings#available-settings) mà bạn đã kiểm soát cho các transcript của phiên.

Cấu hình nhóm giữ trạng thái thời gian chạy (runtime state) như session ID và tmux pane ID, nên đừng chỉnh sửa nó bằng tay hoặc soạn trước: các thay đổi của bạn sẽ bị ghi đè ở lần cập nhật trạng thái tiếp theo.

Để định nghĩa các vai trò thành viên có thể tái sử dụng, dùng [định nghĩa subagent](#use-subagent-definitions-for-teammates) thay thế.

Cấu hình nhóm chứa một mảng `members` với tên, agent ID, và loại agent của từng thành viên. Các thành viên có thể đọc file này để khám phá các thành viên khác trong nhóm.

Không có tương đương ở cấp dự án (project-level) cho cấu hình nhóm. Một file như `.claude/teams/teams.json` trong thư mục dự án của bạn không được nhận diện là cấu hình; Claude coi nó như một file bình thường.

### Dùng định nghĩa subagent cho thành viên

Khi tạo một thành viên, bạn có thể tham chiếu một loại [subagent](/en/sub-agents) từ bất kỳ [phạm vi subagent](/en/sub-agents#choose-the-subagent-scope) nào: dự án, người dùng, plugin, hoặc định nghĩa bằng CLI. Điều này cho phép bạn định nghĩa một vai trò một lần, chẳng hạn security-reviewer hoặc test-runner, và tái sử dụng nó cả như một subagent được ủy quyền lẫn như một thành viên agent team.

Để dùng một định nghĩa subagent, hãy nhắc đến nó theo tên khi yêu cầu Claude tạo thành viên:

```text theme={null}
Spawn a teammate using the security-reviewer agent type to audit the auth module.
```

Thành viên tôn trọng danh sách công cụ cho phép (`tools` allowlist) và `model` của định nghĩa đó, và phần thân của định nghĩa được nối vào system prompt của thành viên như chỉ dẫn bổ sung thay vì thay thế nó. Các công cụ điều phối nhóm như `SendMessage` và các công cụ quản lý nhiệm vụ luôn có sẵn cho một thành viên ngay cả khi `tools` hạn chế các công cụ khác.

<Note>
  Các trường frontmatter `skills` và `mcpServers` trong một định nghĩa subagent không được áp dụng khi định nghĩa đó chạy như một thành viên. Các thành viên nạp skill và MCP server từ cài đặt dự án và người dùng của bạn, giống như một phiên thông thường.
</Note>

### Quyền (Permissions)

Các thành viên bắt đầu với cài đặt quyền của trưởng nhóm. Nếu trưởng nhóm chạy với `--dangerously-skip-permissions`, thì tất cả thành viên cũng vậy. Sau khi tạo, bạn có thể thay đổi chế độ của từng thành viên, nhưng bạn không thể đặt chế độ theo từng thành viên tại thời điểm tạo.

Khi một agent gửi cho agent khác một tin nhắn qua `SendMessage`, agent nhận được cho biết rằng nó đến từ một phiên Claude khác, không phải từ bạn. Một thành viên không thể phê duyệt một lời nhắc quyền (permission prompt) hoặc cung cấp sự đồng ý thay bạn, và một thành viên bị từ chối một hành động không thể chuyển tiếp nó cho một thành viên khác để lách qua kiểm tra. Trong [auto mode](/en/permission-modes#eliminate-prompts-with-auto-mode), bộ phân loại (classifier) coi một tuyên bố phê duyệt được chuyển tiếp từ một agent khác như đầu vào không đáng tin cậy chứ không phải xác nhận từ bạn. Các lời nhắc quyền của thành viên nổi lên phiên trưởng nhóm, nên hãy tự phê duyệt chúng ở đó.

### Ngữ cảnh và giao tiếp

Mỗi thành viên có context window riêng. Khi được tạo, một thành viên nạp cùng ngữ cảnh dự án như một phiên thông thường: CLAUDE.md, MCP server, và skill. Nó cũng nhận được prompt tạo (spawn prompt) từ trưởng nhóm. Lịch sử hội thoại của trưởng nhóm không được mang theo.

**Cách các thành viên chia sẻ thông tin:**

* **Giao tin nhắn tự động**: khi các thành viên gửi tin nhắn, chúng được giao tự động đến người nhận. Trưởng nhóm không cần hỏi thăm (poll) để cập nhật.
* **Thông báo rảnh**: khi một thành viên hoàn thành và dừng, nó tự động thông báo cho trưởng nhóm. {/* min-version: 2.1.198 */}Kể từ v2.1.198, một thành viên có lượt kết thúc bằng một lỗi API sẽ thông báo cho trưởng nhóm rằng nó đã thất bại và kèm theo văn bản lỗi, thay vì có vẻ như hoàn thành bình thường.
* **Danh sách công việc chung**: tất cả agent có thể thấy trạng thái nhiệm vụ và nhận công việc còn trống.
* **Nhắn tin cho thành viên**: gửi một tin nhắn tới một thành viên cụ thể theo tên. Để tiếp cận mọi người, gửi một tin nhắn cho mỗi người nhận.

Trưởng nhóm gán cho mỗi thành viên một tên khi tạo họ, và bất kỳ thành viên nào cũng có thể nhắn tin cho bất kỳ thành viên khác theo tên đó. Để có tên dễ đoán mà bạn có thể tham chiếu trong các prompt sau, hãy nói cho trưởng nhóm biết gọi mỗi thành viên là gì trong chỉ dẫn tạo của bạn.

### Sử dụng token

Agent teams dùng nhiều token hơn đáng kể so với một phiên đơn. Mỗi thành viên có context window riêng, và mức sử dụng token tỷ lệ thuận với số lượng thành viên đang hoạt động. Với công việc nghiên cứu, rà soát, và làm tính năng mới, số token thêm thường xứng đáng. Với các tác vụ thường quy, một phiên đơn tiết kiệm chi phí hơn. Xem [chi phí token của agent team](/en/costs#agent-team-token-costs) để có hướng dẫn sử dụng.

## Các ví dụ tình huống sử dụng

Các ví dụ này cho thấy cách agent teams xử lý những tác vụ mà việc khám phá song song mang lại giá trị.

### Chạy rà soát code song song

Một người rà soát đơn lẻ có xu hướng nghiêng về một loại vấn đề tại một thời điểm. Chia tiêu chí rà soát thành các lĩnh vực độc lập có nghĩa là bảo mật, hiệu năng, và độ phủ kiểm thử đều được chú ý kỹ càng cùng lúc. Prompt gán cho mỗi thành viên một lăng kính riêng biệt để họ không trùng lặp:

```text theme={null}
Spawn three teammates to review PR #142:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

Mỗi người rà soát làm việc từ cùng một PR nhưng áp dụng một bộ lọc khác nhau. Trưởng nhóm tổng hợp phát hiện trên cả ba sau khi họ hoàn thành.

### Điều tra với các giả thuyết cạnh tranh

Khi nguyên nhân gốc chưa rõ, một agent đơn lẻ có xu hướng tìm ra một lời giải thích hợp lý và dừng tìm kiếm. Prompt chống lại điều này bằng cách khiến các thành viên đối kháng nhau một cách tường minh: công việc của mỗi người không chỉ là điều tra lý thuyết của chính mình mà còn là phản biện lý thuyết của người khác.

```text theme={null}
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

Cấu trúc tranh luận là cơ chế then chốt ở đây. Việc điều tra tuần tự chịu hiệu ứng neo (anchoring): một khi một lý thuyết đã được khám phá, việc điều tra tiếp theo bị thiên lệch về phía nó.

Với nhiều người điều tra độc lập chủ động cố bác bỏ lẫn nhau, lý thuyết sống sót có nhiều khả năng hơn hẳn là nguyên nhân gốc thực sự.

## Thực hành tốt nhất (Best practices)

### Cung cấp cho thành viên đủ ngữ cảnh

Các thành viên nạp ngữ cảnh dự án một cách tự động, bao gồm CLAUDE.md, MCP server, và skill, nhưng họ không thừa hưởng lịch sử hội thoại của trưởng nhóm. Xem [Ngữ cảnh và giao tiếp](#context-and-communication) để biết chi tiết. Hãy đưa các chi tiết cụ thể của nhiệm vụ vào prompt tạo:

```text theme={null}
Spawn a security reviewer teammate with the prompt: "Review the authentication module
at src/auth/ for security vulnerabilities. Focus on token handling, session
management, and input validation. The app uses JWT tokens stored in
httpOnly cookies. Report any issues with severity ratings."
```

### Chọn quy mô nhóm phù hợp

Không có giới hạn cứng về số lượng thành viên, nhưng có những ràng buộc thực tế:

* **Chi phí token tăng tuyến tính**: mỗi thành viên có context window riêng và tiêu tốn token độc lập. Xem [chi phí token của agent team](/en/costs#agent-team-token-costs) để biết chi tiết.
* **Chi phí điều phối tăng lên**: càng nhiều thành viên nghĩa là càng nhiều giao tiếp, điều phối nhiệm vụ, và khả năng xung đột
* **Lợi ích giảm dần**: vượt quá một điểm nhất định, thêm thành viên không tăng tốc công việc theo tỷ lệ

Hãy bắt đầu với 3-5 thành viên cho hầu hết quy trình. Điều này cân bằng giữa công việc song song và mức điều phối có thể quản lý được. Các ví dụ trong hướng dẫn này dùng 3-5 thành viên vì khoảng này hoạt động tốt trên nhiều loại tác vụ khác nhau.

Có 5-6 [nhiệm vụ](/en/agent-teams#architecture) mỗi thành viên giữ cho mọi người năng suất mà không phải chuyển ngữ cảnh quá nhiều. Nếu bạn có 15 nhiệm vụ độc lập, 3 thành viên là điểm khởi đầu tốt.

Chỉ mở rộng quy mô khi công việc thực sự hưởng lợi từ việc các thành viên làm việc đồng thời. Ba thành viên tập trung thường vượt trội hơn năm thành viên rời rạc.

### Chia kích thước nhiệm vụ phù hợp

* **Quá nhỏ**: chi phí điều phối vượt quá lợi ích
* **Quá lớn**: các thành viên làm việc quá lâu mà không kiểm tra lại (check-in), làm tăng nguy cơ lãng phí công sức
* **Vừa phải**: các đơn vị tự chứa tạo ra một sản phẩm rõ ràng, chẳng hạn một hàm, một file test, hoặc một lần rà soát

<Tip>
  Trưởng nhóm chia công việc thành các nhiệm vụ và giao chúng cho các thành viên một cách tự động. Nếu nó không tạo đủ nhiệm vụ, hãy yêu cầu nó chia nhỏ công việc thành các phần nhỏ hơn. Có 5-6 nhiệm vụ mỗi thành viên giữ cho mọi người năng suất và cho phép trưởng nhóm phân công lại công việc nếu ai đó bị kẹt.
</Tip>

### Chờ các thành viên hoàn thành

Đôi khi trưởng nhóm tự bắt đầu triển khai nhiệm vụ thay vì chờ các thành viên. Nếu bạn nhận thấy điều này:

```text theme={null}
Wait for your teammates to complete their tasks before proceeding
```

### Bắt đầu với nghiên cứu và rà soát

Nếu bạn mới làm quen với agent teams, hãy bắt đầu với các tác vụ có ranh giới rõ ràng và không yêu cầu viết code: rà soát một PR, nghiên cứu một thư viện, hoặc điều tra một bug. Các tác vụ này cho thấy giá trị của khám phá song song mà không có các thách thức điều phối đi kèm với việc triển khai song song.

### Tránh xung đột file

Hai thành viên sửa cùng một file dẫn đến ghi đè. Hãy chia công việc sao cho mỗi thành viên sở hữu một tập file khác nhau.

### Giám sát và điều hướng

Kiểm tra tiến độ của các thành viên, chuyển hướng các cách tiếp cận không hiệu quả, và tổng hợp phát hiện khi chúng đến. Để một nhóm chạy không giám sát quá lâu làm tăng nguy cơ lãng phí công sức.

## Xử lý sự cố (Troubleshooting)

### Thành viên không xuất hiện

Nếu các thành viên không xuất hiện sau khi bạn yêu cầu Claude tạo chúng:

* Trong chế độ in-process, các thành viên xuất hiện trong agent panel bên dưới ô nhập prompt. Dùng phím mũi tên lên và xuống để chọn một cái, rồi nhấn Enter để xem nó.
* Một dòng thành viên biến mất sau khi ngồi rảnh là đã bị ẩn, không phải dừng. Các dòng rảnh ẩn 30 giây sau khi cả bảng chuyển sang rảnh và xuất hiện lại ở lượt tiếp theo của thành viên. Khi có hơn ba thành viên rảnh, các dòng thừa của họ gộp lại thành một dòng `N idle agents` duy nhất mà Enter sẽ mở rộng. Gửi tin nhắn cho thành viên theo tên để đưa một dòng bị ẩn trở lại.
* Kiểm tra xem tác vụ bạn đưa cho Claude có đủ phức tạp để cần một nhóm hay không. Claude quyết định có tạo thành viên hay không dựa trên tác vụ.
* Nếu bạn yêu cầu split panes một cách tường minh, hãy đảm bảo tmux đã cài đặt và có sẵn trong PATH của bạn:
  ```bash theme={null}
  which tmux
  ```
* Với iTerm2, xác minh `it2` CLI đã cài đặt và Python API được bật trong tùy chọn của iTerm2.

### Quá nhiều lời nhắc quyền

Các yêu cầu quyền của thành viên nổi lên phiên trưởng nhóm, điều này có thể gây phiền toái. Hãy phê duyệt trước các thao tác thường gặp trong [cài đặt quyền](/en/permissions) của bạn trước khi tạo thành viên để giảm sự gián đoạn.

### Thành viên dừng khi gặp lỗi

Các thành viên có thể dừng sau khi gặp lỗi thay vì phục hồi. Kiểm tra đầu ra của họ bằng cách chọn thành viên trong agent panel và nhấn Enter trong chế độ in-process, hoặc bằng cách bấm vào ngăn trong chế độ split, sau đó hoặc:

* Đưa cho họ thêm chỉ dẫn trực tiếp
* Tạo một thành viên thay thế để tiếp tục công việc

{/* min-version: 2.1.198 */}Kể từ v2.1.198, một tin nhắn từ trưởng nhóm hoặc một thành viên khác sẽ đánh thức một thành viên in-process đang chờ thử lại một yêu cầu API thất bại, nên nó thử lại ngay lập tức thay vì chờ hết thời gian trễ thử lại.

### Trưởng nhóm tắt trước khi công việc hoàn thành

Trưởng nhóm có thể quyết định nhóm đã xong trước khi tất cả nhiệm vụ thực sự hoàn thành. Nếu điều này xảy ra, hãy bảo nó tiếp tục. Bạn cũng có thể bảo trưởng nhóm chờ các thành viên hoàn thành trước khi tiến hành nếu nó bắt đầu tự làm việc thay vì ủy quyền.

### Phiên tmux mồ côi (orphaned)

Nếu một phiên tmux vẫn tồn tại sau khi phiên Claude Code kết thúc, có thể nó chưa được dọn dẹp hoàn toàn. Liệt kê các phiên và kết thúc phiên do nhóm tạo ra:

```bash theme={null}
tmux ls
tmux kill-session -t <session-name>
```

## Hạn chế (Limitations)

Agent teams là tính năng thử nghiệm. Các hạn chế hiện tại cần lưu ý:

* **Không khôi phục phiên với thành viên in-process**: `/resume` và `/rewind` không khôi phục các thành viên in-process. Sau khi khôi phục một phiên, trưởng nhóm có thể cố nhắn tin cho các thành viên không còn tồn tại. Nếu điều này xảy ra, hãy bảo trưởng nhóm tạo các thành viên mới.
* **Trạng thái nhiệm vụ có thể trễ**: các thành viên đôi khi không đánh dấu nhiệm vụ là đã hoàn thành, điều này chặn các nhiệm vụ phụ thuộc. Nếu một nhiệm vụ có vẻ bị kẹt, hãy kiểm tra xem công việc có thực sự xong không và cập nhật trạng thái nhiệm vụ thủ công hoặc bảo trưởng nhóm nhắc thành viên.
* **Việc tắt có thể chậm**: các thành viên hoàn thành yêu cầu hoặc lệnh gọi công cụ hiện tại trước khi tắt, việc này có thể mất thời gian.
* **Một nhóm mỗi phiên**: một phiên có đúng một nhóm, giới hạn trong phiên đó. Bạn không thể tạo thêm các nhóm được đặt tên hoặc chia sẻ một nhóm qua nhiều phiên.
* **Không có nhóm lồng nhau (nested teams)**: các thành viên không thể tạo thành viên của riêng mình. Chỉ trưởng nhóm mới có thể quản lý nhóm.
* **Không có subagent chạy nền từ thành viên in-process**: các subagent của chính một thành viên in-process chạy ở tiền cảnh (foreground). Yêu cầu một cái chạy nền, dù bằng `run_in_background` hay một định nghĩa subagent đặt `background: true`, sẽ trả về lỗi, vì công việc nền của một thành viên không thể sống lâu hơn tiến trình của trưởng nhóm. Các subagent được khởi chạy từ cuộc hội thoại chính đi theo [mặc định chạy nền](/en/sub-agents#run-subagents-in-foreground-or-background).
* **Trưởng nhóm là cố định**: phiên chính là trưởng nhóm trong suốt vòng đời của nó. Bạn không thể thăng một thành viên lên làm trưởng nhóm hoặc chuyển giao quyền lãnh đạo.
* **Quyền được đặt lúc tạo**: tất cả thành viên bắt đầu với chế độ quyền của trưởng nhóm. Bạn có thể thay đổi chế độ của từng thành viên sau khi tạo, nhưng bạn không thể đặt chế độ theo từng thành viên tại thời điểm tạo.
* **Split panes yêu cầu tmux hoặc iTerm2**: chế độ in-process mặc định hoạt động trong mọi terminal. Chế độ split-pane không được hỗ trợ trong terminal tích hợp của VS Code, Windows Terminal, hoặc Ghostty.

<Tip>
  **`CLAUDE.md` hoạt động bình thường**: các thành viên đọc các file `CLAUDE.md` từ thư mục làm việc của họ. Dùng điều này để cung cấp hướng dẫn cụ thể của dự án cho tất cả thành viên.
</Tip>

## Bước tiếp theo

Khám phá các cách tiếp cận liên quan cho công việc song song và ủy quyền:

* **Ủy quyền nhẹ**: [subagent](/en/sub-agents) tạo các agent hỗ trợ cho nghiên cứu hoặc xác minh trong phiên của bạn, phù hợp hơn cho các tác vụ không cần điều phối giữa các agent
* **Các phiên song song thủ công**: [Git worktree](/en/worktrees) cho phép bạn tự chạy nhiều phiên Claude Code mà không cần điều phối nhóm tự động
* **So sánh các cách tiếp cận**: xem so sánh [subagent với agent team](/en/features-overview#compare-similar-features) để có phân tích cạnh nhau
