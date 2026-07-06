> Nguồn: https://code.claude.com/docs/en/goal.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Giữ cho Claude làm việc hướng tới một mục tiêu

> Đặt một điều kiện hoàn thành bằng /goal và Claude sẽ tiếp tục làm việc qua nhiều lượt cho đến khi điều kiện được thỏa mãn.

<Note>
  `/goal` yêu cầu Claude Code v2.1.139 trở lên.
</Note>

Lệnh `/goal` đặt ra một điều kiện hoàn thành và Claude sẽ tiếp tục làm việc hướng tới điều kiện đó mà không cần bạn ra prompt ở mỗi bước. Sau mỗi lượt (turn), một model nhỏ và nhanh sẽ kiểm tra xem điều kiện đã được thỏa mãn hay chưa. Nếu chưa, Claude sẽ bắt đầu một lượt khác thay vì trả quyền điều khiển lại cho bạn. Mục tiêu tự động được xóa bỏ khi điều kiện được thỏa mãn.

Hãy dùng một mục tiêu cho những công việc đáng kể có trạng thái kết thúc có thể kiểm chứng được:

* Di chuyển (migrate) một module sang API mới cho đến khi mọi vị trí gọi (call site) biên dịch được và các bài test đều pass
* Triển khai một tài liệu thiết kế (design doc) cho đến khi tất cả tiêu chí nghiệm thu (acceptance criteria) đều được thỏa mãn
* Tách một file lớn thành các module tập trung cho đến khi mỗi module nằm dưới một ngưỡng kích thước
* Xử lý hết một hàng đợi (backlog) các issue được gắn nhãn cho đến khi hàng đợi rỗng

## So sánh các cách giữ cho một phiên làm việc tiếp tục chạy

Có ba cách tiếp cận giúp phiên làm việc hiện tại tiếp tục chạy giữa các prompt. Hãy chọn dựa trên điều gì sẽ khởi động lượt kế tiếp:

| Cách tiếp cận                                                        | Lượt kế tiếp bắt đầu khi   | Dừng khi                                        |
| :------------------------------------------------------------------ | :------------------------- | :---------------------------------------------- |
| `/goal`                                                             | Lượt trước đó kết thúc      | Một model xác nhận điều kiện đã được thỏa mãn    |
| [`/loop`](/en/scheduled-tasks#run-a-prompt-repeatedly-with-%2Floop) | Một khoảng thời gian trôi qua | Bạn dừng nó, hoặc Claude quyết định công việc đã xong |
| [Stop hook](/en/hooks-guide#prompt-based-hooks)                     | Lượt trước đó kết thúc      | Script hoặc prompt của riêng bạn quyết định      |

Cả `/goal` và Stop hook đều kích hoạt sau mỗi lượt. `/goal` là một lối tắt trong phạm vi phiên (session-scoped): bạn gõ một điều kiện và nó có hiệu lực chỉ cho phiên hiện tại. Một Stop hook nằm trong file settings của bạn, áp dụng cho mọi phiên trong phạm vi của nó, và có thể chạy một script để kiểm tra tất định (deterministic) hoặc một prompt cho các kiểm tra do model đánh giá.

[Auto mode](/en/auto-mode-config) tự thân nó phê duyệt các lệnh gọi tool trong phạm vi một lượt duy nhất nhưng không khởi động một lượt mới. Claude dừng lại khi nó cho rằng công việc đã xong. `/goal` bổ sung một bộ đánh giá (evaluator) riêng biệt để kiểm tra điều kiện của bạn sau mỗi lượt, nhờ đó việc hoàn thành được quyết định bởi một model mới thay vì model đang thực thi công việc. Hai thứ này bổ trợ cho nhau: auto mode loại bỏ các lời nhắc phê duyệt ở từng tool, còn `/goal` loại bỏ các lời nhắc ở từng lượt.

<Tip>
  Các cách tiếp cận ở trên giữ cho phiên hiện tại tiếp tục chạy. Bạn cũng có thể lên lịch công việc chạy độc lập với bất kỳ phiên đang mở nào, chẳng hạn như test ban đêm hoặc phân loại (triage) buổi sáng. Xem [các tùy chọn lên lịch](/en/scheduled-tasks#compare-scheduling-options) cho cloud routine và desktop scheduled task.
</Tip>

## Sử dụng `/goal`

Mỗi phiên chỉ có thể có một mục tiêu đang hoạt động. Cùng một lệnh sẽ đặt, kiểm tra, và xóa mục tiêu tùy theo tham số truyền vào.

### Đặt một mục tiêu

Chạy `/goal` theo sau là điều kiện bạn muốn được thỏa mãn. Nếu đã có một mục tiêu đang hoạt động, mục tiêu mới sẽ thay thế nó.

```text theme={null}
/goal all tests in test/auth pass and the lint step is clean
```

Việc đặt một mục tiêu sẽ khởi động một lượt ngay lập tức, với chính điều kiện đó làm chỉ thị (directive). Bạn không cần gửi một prompt riêng. Trong khi mục tiêu đang hoạt động, một chỉ báo `◎ /goal active` cho biết mục tiêu đã chạy được bao lâu.

Sau mỗi lượt, bộ đánh giá trả về một lý do ngắn giải thích tại sao điều kiện đã hoặc chưa được thỏa mãn. Lý do gần nhất xuất hiện trong khung xem trạng thái và trong transcript để bạn có thể thấy Claude đang hướng tới điều gì tiếp theo.

<Note>
  Một mục tiêu tiếp tục chạy cho đến khi điều kiện được thỏa mãn hoặc bạn chạy `/goal clear`. Chạy `/goal` không kèm tham số để xem số lượt và số token đã tiêu tốn cho tới hiện tại.
</Note>

### Viết một điều kiện hiệu quả

[Bộ đánh giá](#how-evaluation-works) phán xét điều kiện của bạn dựa trên những gì Claude đã đưa ra trong cuộc hội thoại. Nó không chạy lệnh hay đọc file một cách độc lập, vì vậy hãy viết điều kiện như một thứ mà chính output của Claude có thể chứng minh được. "Tất cả test trong `test/auth` pass" là hiệu quả vì Claude chạy các test và kết quả xuất hiện trong transcript để bộ đánh giá đọc được.

Một điều kiện bền vững qua nhiều lượt thường có:

* **Một trạng thái kết thúc đo lường được**: một kết quả test, một mã thoát (exit code) của build, một số lượng file, một hàng đợi rỗng
* **Một cách kiểm tra được nêu rõ**: Claude nên chứng minh nó như thế nào, chẳng hạn "`npm test` exits 0" hoặc "`git status` is clean"
* **Các ràng buộc quan trọng**: bất cứ điều gì không được thay đổi trên đường đi tới đó, chẳng hạn "no other test file is modified"

Điều kiện có thể dài tối đa 4.000 ký tự.

Để giới hạn thời gian một mục tiêu chạy, hãy đưa vào một mệnh đề về số lượt hoặc thời gian trong điều kiện, chẳng hạn `or stop after 20 turns`. Claude báo cáo tiến độ so với mệnh đề đó ở mỗi lượt và bộ đánh giá phán xét nó dựa trên cuộc hội thoại.

### Kiểm tra trạng thái

Chạy `/goal` không kèm tham số để xem trạng thái hiện tại.

```text theme={null}
/goal
```

Nếu có một mục tiêu đang hoạt động, trạng thái sẽ hiển thị:

* Điều kiện
* Nó đã chạy được bao lâu
* Đã có bao nhiêu lượt được đánh giá
* Mức tiêu tốn token hiện tại
* Lý do gần nhất của bộ đánh giá

Nếu không có mục tiêu nào đang hoạt động nhưng có một mục tiêu đã đạt được trước đó trong phiên, trạng thái sẽ hiển thị điều kiện đã đạt được cùng với thời lượng, số lượt, và mức tiêu tốn token của nó.

### Xóa một mục tiêu

Chạy `/goal clear` để gỡ bỏ một mục tiêu đang hoạt động trước khi điều kiện của nó được thỏa mãn.

```text theme={null}
/goal clear
```

`stop`, `off`, `reset`, `none`, và `cancel` được chấp nhận như các bí danh (alias) của `clear`. Chạy `/clear` để bắt đầu một cuộc hội thoại mới cũng gỡ bỏ mọi mục tiêu đang hoạt động.

### Tiếp tục với một mục tiêu đang hoạt động

Một mục tiêu vẫn còn đang hoạt động khi một phiên kết thúc sẽ được khôi phục khi bạn tiếp tục phiên đó bằng `--resume` hoặc `--continue`. Điều kiện được mang theo, nhưng số lượt, bộ đếm thời gian, và mốc cơ sở (baseline) tiêu tốn token đều được đặt lại khi tiếp tục. Một mục tiêu đã được đạt hoặc đã bị xóa sẽ không được khôi phục.

### Chạy phi tương tác (non-interactive)

`/goal` hoạt động ở [chế độ phi tương tác](/en/headless), trong [ứng dụng desktop](/en/desktop), và thông qua [Remote Control](/en/remote-control). Việc đặt một mục tiêu với `-p` sẽ chạy vòng lặp cho đến khi hoàn tất trong một lần gọi duy nhất:

```bash theme={null}
claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"
```

Ngắt tiến trình bằng Ctrl+C để dừng một mục tiêu phi tương tác trước khi điều kiện được thỏa mãn.

## Cách hoạt động của việc đánh giá

`/goal` là một lớp bọc (wrapper) quanh một [prompt-based Stop hook trong phạm vi phiên](/en/hooks#prompt-based-hooks). Mỗi khi Claude kết thúc một lượt, điều kiện và cuộc hội thoại cho tới thời điểm đó được gửi tới [small fast model](/en/model-config) đã cấu hình của bạn, mặc định là Haiku. Model trả về một quyết định có-hoặc-không và một lý do ngắn. Câu trả lời "no" báo cho Claude tiếp tục làm việc và kèm theo lý do như một hướng dẫn cho lượt kế tiếp. Câu trả lời "yes" sẽ xóa mục tiêu và ghi lại một mục "đã đạt được" (achieved) trong transcript.

Bộ đánh giá chạy trên bất kỳ nhà cung cấp (provider) nào mà phiên của bạn được cấu hình. Nó không gọi tool, nên nó chỉ có thể phán xét những gì Claude đã đưa ra trong cuộc hội thoại.

<Note>
  Token đánh giá được tính phí trên small fast model được cấu hình cho provider của bạn và thường không đáng kể so với mức tiêu tốn của các lượt chính.
</Note>

## Yêu cầu

`/goal` chỉ chạy trong các workspace mà bạn đã chấp nhận hộp thoại tin cậy (trust dialog), bởi vì bộ đánh giá là một phần của hệ thống hook. `/goal` cũng không khả dụng khi [`disableAllHooks`](/en/hooks#disable-or-remove-hooks) được đặt ở bất kỳ cấp settings nào hoặc khi [`allowManagedHooksOnly`](/en/settings#hook-configuration) được đặt trong managed settings. Trong mỗi trường hợp, lệnh sẽ cho bạn biết lý do thay vì âm thầm không làm gì.

## Xem thêm

* [Chạy một prompt lặp đi lặp lại với `/loop`](/en/scheduled-tasks#run-a-prompt-repeatedly-with-%2Floop): chạy lại theo một khoảng thời gian thay vì cho đến khi một điều kiện được thỏa mãn
* [Prompt-based hooks](/en/hooks-guide#prompt-based-hooks): viết Stop hook của riêng bạn khi bạn cần logic đánh giá tùy chỉnh
* [Auto mode](/en/auto-mode-config): tự động phê duyệt các lệnh gọi tool để mỗi lượt của mục tiêu chạy mà không cần giám sát
* [So sánh việc lên lịch](/en/scheduled-tasks#compare-scheduling-options): chạy công việc theo lịch, độc lập với bất kỳ phiên đang mở nào
