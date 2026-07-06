> Nguồn: https://code.claude.com/docs/en/agents.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Chạy các agent song song

> So sánh các cách Claude Code có thể đảm nhận nhiều tác vụ cùng một lúc: subagent, agent view, agent teams, và dynamic workflows.

[Subagent](/en/sub-agents), [agent view](/en/agent-view), [agent teams](/en/agent-teams), và [dynamic workflows](/en/workflows) mỗi cái song song hóa công việc theo một cách khác nhau. Lựa chọn đúng phụ thuộc vào việc bạn muốn tự ở lại trong mỗi cuộc hội thoại, giao việc đi và kiểm tra lại sau, hay để Claude điều phối một nhóm worker cho bạn.

| Cách tiếp cận                       | Nó mang lại cho bạn điều gì                                                                                                                                | Dùng nó khi                                                                                                                                                                                        |
| :--------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Subagent](/en/sub-agents)         | Các worker được ủy quyền bên trong một phiên, thực hiện một tác vụ phụ trong ngữ cảnh riêng của chúng và trả về một bản tóm tắt                          | Một tác vụ phụ sẽ làm ngập cuộc hội thoại chính của bạn bằng kết quả tìm kiếm, log, hoặc nội dung file mà bạn sẽ không tham chiếu lại                                                             |
| [Agent view](/en/agent-view)       | Một màn hình để tạo và giám sát các phiên chạy ở chế độ nền, mở bằng `claude agents`. Bản xem trước nghiên cứu (research preview)                        | Bạn có nhiều tác vụ độc lập và muốn giao chúng đi, kiểm tra trạng thái nhanh, và chỉ bước vào khi một cái cần bạn                                                                                 |
| [Agent teams](/en/agent-teams)     | Nhiều phiên được điều phối với một danh sách công việc chung và nhắn tin giữa các agent, do một trưởng nhóm quản lý. Thử nghiệm và bị tắt theo mặc định  | Bạn muốn Claude chia một dự án thành các phần, giao chúng, và giữ các worker đồng bộ                                                                                                             |
| [Dynamic workflows](/en/workflows) | Một script chạy nhiều subagent và kiểm chứng chéo kết quả của chúng, cho công việc quá lớn để điều phối từng lượt một hoặc cần nhiều hơn một lần chạy    | Một công việc vượt quá một nhúm subagent, hoặc bạn muốn các phát hiện được xác minh với nhau: một cuộc rà soát toàn codebase, một cuộc di trú 500 file, nghiên cứu được kiểm chứng chéo, hoặc một kế hoạch được phác từ nhiều góc độ |

Trong mọi cách tiếp cận, các worker đều là các phiên Claude. Để đưa một công cụ khác vào cuộc, hãy phơi bày nó cho Claude dưới dạng một [MCP server](/en/mcp).

Có hai công cụ nữa hỗ trợ công việc này mà bản thân chúng không phải là một cách để chạy agent:

* [Worktree](/en/worktrees) cho mỗi phiên một git checkout riêng biệt, nên các phiên song song không bao giờ sửa cùng một file. Dùng chúng cho các phiên bạn tự chạy. Agent view tự động chuyển mỗi phiên được tạo vào worktree riêng của nó, và các subagent bạn tạo cũng có thể mỗi cái nhận một cái.
* [`/batch`](/en/commands) là một [skill](/en/skills) khiến Claude chia một thay đổi lớn thành 5 đến 30 subagent được cô lập bằng worktree, mỗi cái mở một pull request. Đó là một cách dùng đóng gói của subagent và worktree, không phải một kiểu điều phối riêng biệt.

Một số tính năng khác chạy Claude mà không cần bạn điều khiển từng bước, nhưng chúng giải quyết một vấn đề khác với việc chia công việc trên các agent:

* Một [lệnh bash chạy nền](/en/interactive-mode#background-bash-commands) chạy một lệnh shell mà không chặn cuộc hội thoại. Nó không tạo ra một agent.
* Một [subagent được rẽ nhánh (forked)](/en/sub-agents#fork-the-current-conversation) là một subagent thừa hưởng toàn bộ ngữ cảnh hội thoại của bạn thay vì bắt đầu mới. Đó là một cách tạo một subagent, không phải một bề mặt riêng biệt.
* Một [routine](/en/routines) chạy một phiên theo lịch trên đám mây của Anthropic, không phải song song trên máy của bạn.

<Note>
  Chạy nhiều phiên hoặc subagent cùng lúc nhân lên mức sử dụng token. Xem [Chi phí](/en/costs) để biết chi tiết về sử dụng và giới hạn tốc độ.
</Note>

## Chọn một cách tiếp cận

Cách tiếp cận đúng phụ thuộc vào ai điều phối công việc, các worker có cần giao tiếp hay không, và chúng có sửa cùng một file hay không:

* **Ai điều phối công việc?**
  * Claude ủy quyền và thu thập kết quả bên trong một cuộc hội thoại: [subagent](/en/sub-agents)
  * Bạn giao đi các tác vụ độc lập và kiểm tra lại sau: [agent view](/en/agent-view)
  * Claude lập kế hoạch, giao việc, và giám sát một nhóm worker: [agent teams](/en/agent-teams), thử nghiệm và bị tắt theo mặc định
  * Một script giữ kế hoạch thay vì phán đoán từng lượt của Claude: [dynamic workflows](/en/workflows). Xem [workflow so sánh với subagent và skill như thế nào](/en/workflows#when-to-use-a-workflow)
* **Các worker có cần trò chuyện với nhau không?** Subagent báo cáo kết quả lại cho cuộc hội thoại đã tạo ra chúng, và các phiên agent view chỉ báo cáo cho bạn. Các thành viên trong một agent team chia sẻ một danh sách công việc và nhắn tin cho nhau trực tiếp.
* **Các tác vụ có chạm vào cùng file không?** Hãy cô lập công việc bằng [worktree](/en/worktrees). Subagent và các phiên bạn tự chạy có thể mỗi cái dùng một worktree riêng biệt. Agent teams không cô lập các thành viên trong worktree, nên hãy [phân vùng công việc](/en/agent-teams#avoid-file-conflicts) sao cho mỗi thành viên sở hữu một tập file khác nhau.

## Kiểm tra công việc đang chạy

Lệnh để kiểm tra công việc đang chạy phụ thuộc vào cách tiếp cận bạn đã dùng:

* Với các phiên nền, `claude agents` mở [agent view](/en/agent-view): một màn hình hiển thị mọi phiên, trạng thái của nó, và những cái nào cần bạn nhập liệu.
* Với các subagent trong phiên hiện tại, các subagent nền được đặt tên xuất hiện trong gợi ý @-mention kèm trạng thái của chúng. {/* min-version: 2.1.198 */}Kể từ v2.1.198, `/agents` không còn mở một bảng nữa; nó in một thông báo chỉ đến vị trí các file subagent. Để [tạo và chỉnh sửa subagent tùy chỉnh](/en/sub-agents#configure-subagents), hãy yêu cầu Claude hoặc chỉnh sửa các file trực tiếp. Dù tên tương tự, `/agents` tách biệt với `claude agents`.
* Với bất cứ thứ gì chạy ở chế độ nền của phiên hiện tại, `/tasks` liệt kê từng mục và cho phép bạn kiểm tra, gắn vào (attach), hoặc dừng nó.
* Với dynamic workflows, `/workflows` liệt kê các lần chạy đang chạy và đã hoàn thành, giai đoạn mà mỗi cái đang ở, và bao nhiêu agent đã hoàn thành.

Để có một khung nhìn desktop cho tất cả các phiên của bạn, xem [các phiên song song trong ứng dụng desktop](/en/desktop#work-in-parallel-with-sessions).

## Tìm hiểu thêm

Mỗi hướng dẫn dưới đây trình bày việc thiết lập và cấu hình cho một cách tiếp cận:

* [Tạo subagent tùy chỉnh](/en/sub-agents): định nghĩa các chuyên gia có thể tái sử dụng và kiểm soát công cụ nào chúng có thể dùng.
* [Quản lý agent với agent view](/en/agent-view): tạo các phiên, theo dõi trạng thái của chúng, và gắn vào khi một cái cần bạn.
* [Điều phối agent teams](/en/agent-teams): thiết lập một trưởng nhóm và các thành viên, giao nhiệm vụ, và rà soát công việc của họ.
* [Điều phối dynamic workflows](/en/workflows): chạy một workflow đóng gói sẵn hoặc để Claude viết một cái chạy nhiều subagent và xác minh phát hiện của chúng với nhau.
* [Chạy các phiên song song với worktree](/en/worktrees): khởi động Claude trong một checkout cô lập, kiểm soát cái gì được sao chép vào, và dọn dẹp sau đó.
