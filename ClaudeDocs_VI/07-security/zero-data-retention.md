> Nguồn: https://code.claude.com/docs/en/zero-data-retention.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Zero Data Retention (Không lưu giữ dữ liệu)

> Tìm hiểu về Zero Data Retention (ZDR — không lưu giữ dữ liệu) cho Claude Code, khả dụng cho các tài khoản đủ điều kiện trên Claude for Enterprise, bao gồm phạm vi áp dụng, các tính năng bị vô hiệu hóa, và cách yêu cầu kích hoạt.

Zero Data Retention (ZDR) cho Claude Code khả dụng cho các tài khoản đủ điều kiện trên Claude for Enterprise. Khi ZDR được bật, các prompt và phản hồi của model được tạo ra trong các phiên làm việc Claude Code sẽ được xử lý theo thời gian thực và không được Anthropic lưu trữ sau khi phản hồi đã được trả về, ngoại trừ những trường hợp cần thiết để tuân thủ pháp luật hoặc chống lạm dụng.

<Note>
  ZDR không bao gồm trong gói Claude for Enterprise tiêu chuẩn và không thể được bật từ cài đặt quản trị (admin settings) của bạn. Tính năng này khả dụng cho các tài khoản đủ điều kiện và yêu cầu Anthropic kích hoạt riêng. Nếu tổ chức của bạn cần ZDR, [liên hệ bộ phận kinh doanh](https://www.anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=zero_data_retention_request) hoặc đội ngũ phụ trách tài khoản Anthropic của bạn để xác nhận điều kiện đủ.
</Note>

ZDR trên Claude for Enterprise mang lại cho khách hàng doanh nghiệp khả năng sử dụng Claude Code với chế độ không lưu giữ dữ liệu và truy cập các năng lực quản trị:

* Kiểm soát chi phí theo từng người dùng
* Bảng điều khiển [Analytics](/en/analytics)
* [Server-managed settings](/en/server-managed-settings)
* Nhật ký kiểm toán (audit log)

ZDR cho Claude Code trên Claude for Enterprise chỉ áp dụng cho nền tảng trực tiếp của Anthropic. Đối với các bản triển khai Claude trên Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry, hãy tham khảo chính sách lưu giữ dữ liệu của các nền tảng đó.

## Phạm vi của ZDR

ZDR bao trùm hoạt động suy luận (inference) của Claude Code trên Claude for Enterprise.

<Warning>
  ZDR được bật trên cơ sở từng tổ chức. Mỗi tổ chức mới đều yêu cầu đội ngũ phụ trách tài khoản Anthropic của bạn bật ZDR riêng. ZDR không tự động áp dụng cho các tổ chức mới được tạo dưới cùng một tài khoản. Hãy liên hệ đội ngũ phụ trách tài khoản của bạn để bật ZDR cho bất kỳ tổ chức mới nào.
</Warning>

### Những gì ZDR bao trùm

ZDR bao trùm các lệnh gọi suy luận model được thực hiện thông qua Claude Code trên Claude for Enterprise. Khi bạn sử dụng Claude Code trong terminal, các prompt bạn gửi và các phản hồi Claude tạo ra sẽ không được Anthropic lưu giữ. Điều này áp dụng cho mọi model khả dụng đối với các tổ chức dùng ZDR. Một số model yêu cầu lưu giữ dữ liệu và không khả dụng dưới ZDR; xem [Tình trạng khả dụng của model dưới ZDR](#model-availability-under-zdr).

### Những gì ZDR không bao trùm

ZDR không mở rộng tới những mục sau, ngay cả đối với các tổ chức đã bật ZDR. Các tính năng này tuân theo [chính sách lưu giữ dữ liệu tiêu chuẩn](/en/data-usage#data-retention):

| Tính năng                | Chi tiết                                                                                                                                                                                                                                                     |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chat trên claude.ai      | Các cuộc trò chuyện chat qua giao diện web Claude for Enterprise không được ZDR bao trùm.                                                                                                                                                                    |
| Cowork                   | Các phiên Cowork không được ZDR bao trùm.                                                                                                                                                                                                                    |
| Claude Code Analytics    | Không lưu trữ prompt hoặc phản hồi của model, nhưng thu thập metadata về năng suất như email tài khoản và số liệu thống kê sử dụng. Các chỉ số đóng góp (contribution metrics) không khả dụng cho các tổ chức dùng ZDR; [bảng điều khiển analytics](/en/analytics) chỉ hiển thị các chỉ số sử dụng. |
| Quản lý người dùng và ghế | Dữ liệu quản trị như email tài khoản và phân bổ ghế (seat assignments) được lưu giữ theo chính sách tiêu chuẩn.                                                                                                                                             |
| Tích hợp bên thứ ba      | Dữ liệu được xử lý bởi các công cụ bên thứ ba, các MCP server, hoặc các tích hợp bên ngoài khác không được ZDR bao trùm. Hãy xem xét độc lập cách xử lý dữ liệu của các dịch vụ đó.                                                                          |

## Các tính năng bị vô hiệu hóa dưới ZDR

Khi ZDR được bật cho một tổ chức Claude Code trên Claude for Enterprise, một số tính năng nhất định yêu cầu lưu trữ prompt hoặc phản hồi sẽ tự động bị vô hiệu hóa ở cấp backend:

| Tính năng                                                          | Lý do                                                                          |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [Claude Code on the Web](/en/claude-code-on-the-web)              | Yêu cầu lưu trữ lịch sử cuộc trò chuyện phía server.                           |
| [Cloud sessions](/en/desktop#cloud-sessions) từ ứng dụng Desktop  | Yêu cầu dữ liệu phiên bền vững bao gồm prompt và phản hồi.                     |
| [Artifacts](/en/artifacts)                                        | Yêu cầu lưu trữ nội dung trang đã xuất bản trên hạ tầng do Anthropic vận hành. |
| Gửi phản hồi (`/feedback`)                                        | Việc gửi phản hồi sẽ gửi dữ liệu cuộc trò chuyện tới Anthropic.                |

Các tính năng này bị chặn ở backend bất kể hiển thị phía client. Nếu bạn thấy một tính năng bị vô hiệu hóa trong terminal Claude Code khi khởi động, việc cố sử dụng nó sẽ trả về lỗi cho biết chính sách của tổ chức không cho phép hành động đó.

Các tính năng trong tương lai cũng có thể bị vô hiệu hóa nếu chúng yêu cầu lưu trữ prompt hoặc phản hồi.

### Tình trạng khả dụng của model dưới ZDR

Claude Fable 5 không khả dụng cho các tổ chức đã bật zero data retention. Lớp model này [yêu cầu lưu giữ dữ liệu](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention#model-specific-data-retention-requirements), do đó các yêu cầu từ các tổ chức dùng ZDR không thể được model này phục vụ. Model này hoặc vắng mặt khỏi bộ chọn `/model` đối với các tổ chức dùng ZDR, hoặc hiển thị ở trạng thái vô hiệu hóa kèm thông báo rằng cần tắt ZDR, và server sẽ từ chối các yêu cầu tới model này bất kể cấu hình phía client.

Các model khác vẫn khả dụng dưới ZDR. Fable 5 không phải là model mặc định, và alias `best` — vốn phân giải thành Fable 5 ở những nơi model này khả dụng — sẽ phân giải thành Opus đối với các tổ chức không có model này, bao gồm các tổ chức dùng ZDR.

## Lưu giữ dữ liệu khi vi phạm chính sách

Ngay cả khi đã bật ZDR, Anthropic vẫn có thể lưu giữ dữ liệu ở những trường hợp pháp luật yêu cầu hoặc để xử lý các vi phạm Chính sách sử dụng (Usage Policy). Nếu một phiên bị gắn cờ vì vi phạm chính sách, Anthropic có thể lưu giữ các đầu vào và đầu ra liên quan trong tối đa 2 năm, nhất quán với chính sách ZDR tiêu chuẩn của Anthropic.

## Yêu cầu ZDR

Để yêu cầu ZDR cho Claude Code trên Claude for Enterprise, [liên hệ bộ phận kinh doanh](https://www.anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=zero_data_retention_request) hoặc đội ngũ phụ trách tài khoản Anthropic của bạn. Đội ngũ phụ trách tài khoản của bạn sẽ gửi yêu cầu nội bộ, và Anthropic sẽ xem xét rồi bật ZDR cho tổ chức của bạn sau khi xác nhận điều kiện đủ. Tất cả các hành động kích hoạt đều được ghi vào nhật ký kiểm toán (audit log).

Nếu bạn hiện đang sử dụng ZDR cho Claude Code thông qua các API key trả theo mức dùng (pay-as-you-go), bạn có thể chuyển sang Claude for Enterprise để có được các tính năng quản trị trong khi vẫn duy trì ZDR cho Claude Code. Hãy liên hệ đội ngũ phụ trách tài khoản của bạn để phối hợp việc di chuyển.
