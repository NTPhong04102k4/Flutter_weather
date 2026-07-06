> Nguồn: https://code.claude.com/docs/en/ultraplan.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Lập kế hoạch trên đám mây với ultraplan

> Bắt đầu một kế hoạch từ CLI của bạn, soạn thảo nó trên Claude Code trên web, sau đó thực thi nó từ xa hoặc trở lại terminal của bạn

<Note>
  Ultraplan đang ở giai đoạn research preview và yêu cầu Claude Code v2.1.91 trở lên. Hành vi và khả năng có thể thay đổi dựa trên phản hồi.
</Note>

Ultraplan chuyển giao một tác vụ lập kế hoạch từ CLI cục bộ của bạn cho một phiên [Claude Code trên web](/en/claude-code-on-the-web) đang chạy ở [chế độ plan (plan mode)](/en/permission-modes#analyze-before-you-edit-with-plan-mode). Claude soạn thảo kế hoạch trên đám mây trong khi bạn tiếp tục làm việc trong terminal của mình. Khi kế hoạch sẵn sàng, bạn mở nó trong trình duyệt để bình luận trên các phần cụ thể, yêu cầu chỉnh sửa, và chọn nơi thực thi nó.

Điều này hữu ích khi bạn muốn một bề mặt review phong phú hơn so với những gì terminal cung cấp:

* **Phản hồi có mục tiêu**: bình luận trên từng phần riêng lẻ của kế hoạch thay vì trả lời cho toàn bộ
* **Soạn thảo không cần trực tiếp thao tác**: kế hoạch được sinh ra từ xa, nên terminal của bạn vẫn rảnh cho công việc khác
* **Thực thi linh hoạt**: phê duyệt kế hoạch để chạy trên web và mở một pull request, hoặc gửi nó trở lại terminal của bạn

Ultraplan yêu cầu một tài khoản [Claude Code trên web](/en/claude-code-on-the-web) và một repository GitHub. Vì nó chạy trên hạ tầng đám mây của Anthropic, nó không khả dụng khi dùng Amazon Bedrock, Agent Platform của Google Cloud, hoặc Microsoft Foundry. Phiên đám mây chạy trong [môi trường đám mây (cloud environment)](/en/claude-code-on-the-web#the-cloud-environment) mặc định của tài khoản bạn. Nếu bạn chưa có môi trường đám mây, ultraplan tự động tạo một môi trường khi nó lần đầu khởi chạy.

## Khởi chạy ultraplan từ CLI

Từ phiên CLI cục bộ của bạn, bạn có thể khởi chạy ultraplan theo ba cách:

* **Command**: chạy `/ultraplan` theo sau là prompt của bạn
* **Keyword**: đưa từ `ultraplan` vào bất kỳ đâu trong một prompt thông thường
* **Từ một kế hoạch cục bộ**: khi Claude hoàn thành một kế hoạch cục bộ và hiển thị hộp thoại phê duyệt, chọn **No, refine with Ultraplan on Claude Code on the web** để gửi bản nháp lên đám mây để lặp thêm

Ví dụ, để lập kế hoạch di chuyển một dịch vụ bằng lệnh:

```
/ultraplan migrate the auth service from sessions to JWTs
```

Cách dùng lệnh và từ khóa mở một hộp thoại xác nhận trước khi khởi chạy. Cách từ kế hoạch cục bộ bỏ qua hộp thoại này vì lựa chọn đó đã đóng vai trò xác nhận. Nếu [Remote Control](/en/remote-control) đang hoạt động, nó ngắt kết nối khi ultraplan bắt đầu vì cả hai tính năng đều chiếm dụng giao diện claude.ai/code và chỉ một tính năng có thể được kết nối tại một thời điểm.

Sau khi phiên đám mây khởi chạy, ô nhập prompt của CLI hiển thị một chỉ báo trạng thái trong khi phiên đám mây làm việc:

| Trạng thái                     | Ý nghĩa                                                            |
| :----------------------------- | :----------------------------------------------------------------- |
| `◇ ultraplan`                  | Claude đang nghiên cứu codebase của bạn và soạn thảo kế hoạch      |
| `◇ ultraplan needs your input` | Claude có một câu hỏi làm rõ; mở liên kết phiên để trả lời         |
| `◆ ultraplan ready`            | Kế hoạch đã sẵn sàng để xem lại trong trình duyệt của bạn          |

Chạy `/tasks` và chọn mục ultraplan để mở một khung xem chi tiết với liên kết phiên, hoạt động của agent, và một hành động **Stop ultraplan**. Việc dừng lại lưu trữ (archive) phiên đám mây và xóa chỉ báo; không có gì được lưu vào terminal của bạn.

## Xem lại và chỉnh sửa kế hoạch trong trình duyệt của bạn

Khi trạng thái chuyển thành `◆ ultraplan ready`, mở liên kết phiên để xem kế hoạch trên claude.ai. Kế hoạch xuất hiện trong một khung xem review chuyên dụng:

* **Bình luận inline**: tô sáng bất kỳ đoạn nào và để lại bình luận cho Claude xử lý
* **Phản ứng emoji**: phản ứng với một phần để báo hiệu sự tán thành hoặc lo ngại mà không cần viết một bình luận đầy đủ
* **Thanh phác thảo (outline sidebar)**: nhảy giữa các phần của kế hoạch

Khi bạn yêu cầu Claude xử lý các bình luận của bạn, nó chỉnh sửa kế hoạch và trình bày một bản nháp cập nhật. Bạn có thể lặp lại bao nhiêu lần tùy cần trước khi chọn nơi thực thi.

## Chọn nơi thực thi

Khi kế hoạch trông đã ổn, bạn chọn từ trình duyệt xem Claude triển khai nó trong cùng phiên đám mây hay gửi nó trở lại terminal đang chờ của bạn.

### Thực thi trên web

Chọn **Approve Claude's plan and start coding** trong trình duyệt để Claude triển khai nó trong cùng phiên Claude Code trên web. Terminal của bạn hiển thị một xác nhận, chỉ báo trạng thái được xóa, và công việc tiếp tục trên đám mây. Khi việc triển khai hoàn tất, [xem lại diff](/en/claude-code-on-the-web#review-changes) và tạo một pull request từ giao diện web.

### Gửi kế hoạch trở lại terminal của bạn

Chọn **Approve plan and teleport back to terminal** trong trình duyệt để triển khai kế hoạch cục bộ với đầy đủ quyền truy cập vào môi trường của bạn. Tùy chọn này xuất hiện khi phiên được khởi chạy từ CLI của bạn và terminal vẫn đang thăm dò (polling). Phiên web được lưu trữ nên nó không tiếp tục làm việc song song.

Terminal của bạn hiển thị kế hoạch trong một hộp thoại có tiêu đề **Ultraplan approved** với ba tùy chọn:

* **Implement here**: đưa kế hoạch vào cuộc hội thoại hiện tại của bạn và tiếp tục từ nơi bạn dừng lại
* **Start new session**: xóa cuộc hội thoại hiện tại và bắt đầu mới chỉ với kế hoạch làm ngữ cảnh
* **Cancel**: lưu kế hoạch vào một file mà không thực thi; Claude in ra đường dẫn file để bạn có thể quay lại nó sau này

Nếu bạn bắt đầu một phiên mới, Claude in ra một lệnh `claude --resume` ở đầu để bạn có thể quay lại cuộc hội thoại trước của mình sau này.

## Tài nguyên liên quan

* [Claude Code trên web](/en/claude-code-on-the-web): hạ tầng đám mây mà ultraplan chạy trên đó
* [Plan mode](/en/permission-modes#analyze-before-you-edit-with-plan-mode): cách lập kế hoạch hoạt động trong một phiên cục bộ
* [Tìm lỗi với ultrareview](/en/ultrareview): đối tác code review của ultraplan để bắt các vấn đề trước khi merge
* [Remote Control](/en/remote-control): dùng giao diện claude.ai/code với một phiên chạy trên máy của riêng bạn
