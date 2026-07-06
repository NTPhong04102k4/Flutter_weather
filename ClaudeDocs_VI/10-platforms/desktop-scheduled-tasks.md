> Nguồn: https://code.claude.com/docs/en/desktop-scheduled-tasks.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Lập lịch các tác vụ lặp lại trong Claude Code Desktop

> Thiết lập các tác vụ theo lịch trong Claude Code Desktop để chạy Claude tự động trên cơ sở lặp lại cho việc đánh giá mã hàng ngày, kiểm toán phụ thuộc, hoặc bản tóm tắt buổi sáng.

Các tác vụ theo lịch tự động khởi động một phiên mới vào thời điểm và tần suất bạn chọn. Dùng chúng cho công việc lặp lại như đánh giá mã hàng ngày, kiểm tra cập nhật phụ thuộc, hoặc các bản tóm tắt buổi sáng lấy từ lịch và hộp thư của bạn.

Trang **Routines** của ứng dụng Desktop cho phép bạn tạo cả các tác vụ theo lịch cục bộ lẫn [routines](/en/routines) từ xa. Một tác vụ cục bộ chạy trên máy của bạn với quyền truy cập trực tiếp vào các tệp và công cụ của bạn, nhưng chỉ kích hoạt khi ứng dụng đang mở và máy tính của bạn đang thức. Một routine từ xa chạy trên hạ tầng đám mây do Anthropic quản lý ngay cả khi máy tính của bạn tắt, và cũng có thể kích hoạt trên các lời gọi API hoặc sự kiện GitHub. Trang này bao gồm các tác vụ theo lịch cục bộ; đối với các routine từ xa và các tùy chọn kích hoạt của chúng, xem [Routines](/en/routines).

## So sánh các tùy chọn lập lịch

Claude Code cung cấp ba cách để lập lịch công việc lặp lại hoặc một lần:

|                            | [Đám mây](/en/routines)          | [Desktop](/en/desktop-scheduled-tasks) | [`/loop`](/en/scheduled-tasks)      |
| :------------------------- | :----------------------------- | :------------------------------------- | :---------------------------------- |
| Chạy trên                    | Đám mây Anthropic                | Máy của bạn                           | Máy của bạn                        |
| Yêu cầu máy bật        | Không                             | Có                                    | Có                                 |
| Yêu cầu phiên đang mở      | Không                             | Không                                    | Có                                 |
| Bền vững qua các lần khởi động lại | Có                            | Có                                    | Được khôi phục khi `--resume` nếu chưa hết hạn |
| Truy cập tệp cục bộ      | Không (clone mới)               | Có                                    | Có                                 |
| Máy chủ MCP                | Connector được cấu hình theo từng tác vụ | [Tệp cấu hình](/en/mcp) và connector | Kế thừa từ phiên               |
| Lời nhắc quyền         | Không (chạy tự chủ)         | Có thể cấu hình theo từng tác vụ                  | Kế thừa từ phiên               |
| Lịch có thể tùy chỉnh      | Qua `/schedule` trong CLI     | Có                                    | Có                                 |
| Khoảng thời gian tối thiểu           | 1 giờ                         | 1 phút                              | 1 phút                          |

<Tip>
  Dùng **tác vụ đám mây** cho công việc cần chạy đáng tin cậy mà không cần máy của bạn. Dùng **tác vụ Desktop** khi bạn cần truy cập các tệp và công cụ cục bộ. Dùng **`/loop`** cho việc thăm dò nhanh trong một phiên.
</Tip>

<Note>
  Theo mặc định, các tác vụ theo lịch chạy trên bất kỳ trạng thái nào của thư mục làm việc của bạn, bao gồm cả các thay đổi chưa commit. Bật công tắc worktree khi tạo tác vụ để cho mỗi lần chạy một Git worktree riêng biệt của chính nó, giống như cách các [phiên song song](/en/desktop#work-in-parallel-with-sessions) hoạt động.
</Note>

## Tạo một tác vụ theo lịch

Nhấp **Routines** trong thanh bên, sau đó nhấp **New routine** và chọn **Local**. Cấu hình các trường sau:

| Trường        | Mô tả                                                                                                                                                                                                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Name         | Định danh cho tác vụ. Được chuyển thành chữ thường kebab-case và dùng làm tên thư mục trên đĩa. Phải là duy nhất trong các tác vụ của bạn.                                                                                                                              |
| Description  | Bản tóm tắt ngắn hiển thị trong danh sách tác vụ.                                                                                                                                                                                                                          |
| Instructions | Những gì Claude nên làm khi tác vụ chạy. Viết điều này theo cùng cách bạn viết bất kỳ tin nhắn nào trong ô prompt. Trường instructions bao gồm bộ chọn cho chế độ quyền và model, và bên dưới nó bạn chọn thư mục làm việc và có chạy trong một worktree riêng biệt hay không. |
| Schedule     | Tần suất tác vụ chạy. Xem [các tùy chọn lịch](#schedule-options) bên dưới.                                                                                                                                                                                      |

Cần có một thư mục trước khi bạn có thể lưu tác vụ. Nếu bạn chưa tin cậy thư mục đó, Desktop nhắc bạn tin cậy nó trước khi lưu.

Bạn cũng có thể tạo một tác vụ bằng cách mô tả những gì bạn muốn trong bất kỳ phiên nào. Ví dụ, "set up a daily code review that runs every morning at 9am" tạo một tác vụ lặp lại, và "remind me at 3pm tomorrow to check the deploy" tạo một tác vụ một lần tự vô hiệu hóa sau khi nó kích hoạt.

## Các tùy chọn lịch

Chọn một preset từ điều khiển Schedule:

* **Manual**: không có lịch, chỉ chạy khi bạn nhấp **Run now**. Hữu ích cho việc lưu một prompt mà bạn kích hoạt theo yêu cầu
* **Hourly**: chạy mỗi giờ
* **Daily**: hiển thị bộ chọn thời gian, mặc định là 9:00 AM giờ địa phương
* **Weekdays**: giống Daily nhưng bỏ qua Thứ Bảy và Chủ Nhật
* **Weekly**: hiển thị bộ chọn thời gian và bộ chọn ngày

Đối với các khoảng thời gian mà bộ chọn không cung cấp, chẳng hạn như mỗi 15 phút, ngày đầu tiên của mỗi tháng, hoặc một lần chạy duy nhất vào một thời điểm cụ thể trong tương lai, hãy hỏi Claude trong bất kỳ phiên Desktop nào để đặt lịch. Dùng ngôn ngữ thường; ví dụ, "schedule a task to run all the tests every 6 hours."

## Cách các tác vụ theo lịch chạy

Các tác vụ theo lịch chạy trên máy của bạn. Desktop kiểm tra lịch mỗi phút khi ứng dụng đang mở và khởi động một phiên mới khi một tác vụ đến hạn, độc lập với bất kỳ phiên thủ công nào bạn đang mở. Mỗi tác vụ nhận một độ trễ nhỏ vài phút sau thời gian đã lên lịch để phân bổ đều lưu lượng API. Độ trễ này có tính xác định: cùng một tác vụ luôn bắt đầu ở cùng một độ lệch.

Khi một tác vụ kích hoạt, bạn nhận được một thông báo desktop và một phiên mới xuất hiện dưới mục **Scheduled** trong thanh bên. Mở nó để xem Claude đã làm gì, xem xét các thay đổi, hoặc phản hồi các lời nhắc quyền. Phiên hoạt động như bất kỳ phiên nào khác: Claude có thể sửa các tệp, chạy các lệnh, tạo commit, và mở pull request.

Các tác vụ chỉ chạy khi ứng dụng desktop đang chạy và máy tính của bạn đang thức. Nếu máy tính của bạn ngủ qua một thời điểm đã lên lịch, lần chạy đó bị bỏ qua. Để ngăn ngủ khi nhàn rỗi, hãy bật **Keep computer awake** trong Settings dưới **Desktop app → General**. Đóng nắp laptop vẫn khiến nó ngủ. Đối với các tác vụ cần chạy ngay cả khi máy tính của bạn tắt, hoặc cần kích hoạt trên một lời gọi API hoặc sự kiện GitHub, hãy tạo một [routine](/en/routines) từ xa thay thế.

## Các lần chạy bị bỏ lỡ

Khi ứng dụng khởi động hoặc máy tính của bạn thức dậy, Desktop kiểm tra xem mỗi tác vụ có bỏ lỡ bất kỳ lần chạy nào trong bảy ngày qua hay không. Nếu có, Desktop khởi động chính xác một lần chạy bù cho thời điểm bị bỏ lỡ gần đây nhất và loại bỏ bất cứ điều gì cũ hơn. Một tác vụ hàng ngày đã bỏ lỡ sáu ngày chạy một lần khi thức dậy. Desktop hiển thị một thông báo khi một lần chạy bù bắt đầu.

Hãy ghi nhớ điều này khi viết prompt. Một tác vụ được lên lịch cho 9am có thể chạy lúc 11pm nếu máy tính của bạn ngủ cả ngày. Nếu thời điểm quan trọng, hãy thêm các biện pháp bảo vệ vào chính prompt, ví dụ: "Only review today's commits. If it's after 5pm, skip the review and just post a summary of what was missed."

## Quyền cho các tác vụ theo lịch

Mỗi tác vụ có chế độ quyền riêng của nó, mà bạn đặt khi tạo hoặc chỉnh sửa tác vụ. Các quy tắc allow từ `~/.claude/settings.json` cũng áp dụng cho các phiên tác vụ theo lịch. Nếu một tác vụ chạy ở chế độ Ask và cần chạy một công cụ mà nó không có quyền, lần chạy sẽ đình trệ cho đến khi bạn phê duyệt nó. Phiên vẫn mở trong thanh bên để bạn có thể trả lời sau.

Để tránh đình trệ, hãy nhấp **Run now** sau khi tạo một tác vụ, theo dõi các lời nhắc quyền, và chọn "always allow" cho mỗi lời nhắc. Các lần chạy sau của tác vụ đó tự động phê duyệt cùng các công cụ mà không cần nhắc. Bạn có thể xem xét và thu hồi các phê duyệt này từ trang chi tiết của tác vụ.

## Quản lý các tác vụ theo lịch

Nhấp vào một tác vụ trong danh sách **Routines** để mở trang chi tiết của nó. Từ đây bạn có thể:

* **Run now**: khởi động tác vụ ngay lập tức mà không cần chờ đến thời gian lên lịch tiếp theo
* **Status**: chuyển đổi giữa Active và Paused để tạm dừng hoặc tiếp tục các lần chạy theo lịch mà không xóa tác vụ
* **Edit**: thay đổi các instructions, lịch, thư mục, hoặc các thiết lập khác
* **Review history**: xem mọi lần chạy trước đó, bao gồm cả các lần chạy bị bỏ qua. Di chuột qua một mục bị bỏ qua để xem lý do: máy tính của bạn đang ngủ, lần chạy trước vẫn đang tiến hành, hoặc các tác vụ theo lịch khác đang chạy. Nhấp **Show more** để tải các mục cũ hơn.
* **Review allowed permissions**: xem và thu hồi các phê duyệt công cụ đã lưu cho tác vụ này từ bảng **Always allowed**
* **Delete**: gỡ tác vụ và lưu trữ tất cả các phiên nó đã tạo. Một hộp kiểm **Also delete files on disk** xuất hiện trong hộp thoại xác nhận; chọn nó để cũng gỡ tệp `SKILL.md` của tác vụ và dữ liệu liên quan khỏi `~/.claude/scheduled-tasks/`.

Bạn cũng có thể liệt kê, tạo, chỉnh sửa, và tạm dừng các tác vụ bằng cách hỏi Claude trong bất kỳ phiên Desktop nào. Ví dụ, "pause my dependency-audit task" hoặc "show me my scheduled tasks." Để xóa một tác vụ, dùng nút **Delete** trên trang chi tiết của nó.

Một tác vụ theo lịch cũng có thể sửa đổi lịch hoặc prompt của chính nó từ bên trong một phiên đang chạy bằng công cụ MCP `update_scheduled_task`. Điều này cho phép một tác vụ tự lên lịch lại dựa trên những gì nó tìm thấy, ví dụ, lên lịch lại một lần đánh giá mã để chạy sớm hơn khi nó phát hiện một nhánh release đã được tạo.

Để chỉnh sửa prompt của một tác vụ trên đĩa, mở `~/.claude/scheduled-tasks/<task-name>/SKILL.md` (hoặc dưới [`CLAUDE_CONFIG_DIR`](/en/env-vars) nếu được đặt). Tệp này dùng YAML frontmatter cho `name` và `description`, với prompt làm phần thân. Các thay đổi có hiệu lực ở lần chạy tiếp theo. Lịch, thư mục, model, và trạng thái bật không nằm trong tệp này: thay đổi chúng qua biểu mẫu Edit hoặc hỏi Claude.

## Tài nguyên liên quan

* [Routines](/en/routines): chạy các tác vụ trên hạ tầng do Anthropic quản lý theo lịch, qua lời gọi API, hoặc phản hồi các sự kiện GitHub, ngay cả khi máy tính của bạn tắt
* [Chạy prompt theo lịch](/en/scheduled-tasks): lập lịch trong phạm vi phiên với `/loop` trong CLI
* [Claude Code GitHub Actions](/en/github-actions): chạy Claude theo lịch trong CI thay vì trên máy của bạn
* [Dùng Claude Code Desktop](/en/desktop): hướng dẫn đầy đủ về ứng dụng Desktop
