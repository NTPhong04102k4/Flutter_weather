> Nguồn: https://code.claude.com/docs/en/data-usage.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Sử dụng dữ liệu

> Tìm hiểu về các chính sách sử dụng dữ liệu của Anthropic đối với Claude

## Các chính sách dữ liệu

### Chính sách huấn luyện dữ liệu

**Người dùng tiêu dùng (gói Free, Pro và Max)**:
Chúng tôi cho bạn quyền lựa chọn cho phép dữ liệu của bạn được sử dụng để cải thiện các mô hình Claude trong tương lai. Chúng tôi sẽ huấn luyện các mô hình mới bằng dữ liệu từ tài khoản Free, Pro và Max khi thiết lập này được bật (bao gồm cả khi bạn sử dụng Claude Code từ các tài khoản này).

**Người dùng thương mại**: (gói Team và Enterprise, API, các nền tảng bên thứ ba và Claude Gov) duy trì các chính sách hiện hành: Anthropic không huấn luyện các mô hình sinh (generative) bằng code hoặc prompt được gửi đến Claude Code theo các điều khoản thương mại, trừ khi khách hàng đã chọn cung cấp dữ liệu của họ cho chúng tôi nhằm cải thiện mô hình (ví dụ, [Chương trình Đối tác Phát triển](https://support.claude.com/en/articles/11174108-about-the-development-partner-program)).

### Chương trình Đối tác Phát triển (Development Partner Program)

Nếu bạn chủ động chọn tham gia (opt in) các phương thức cung cấp cho chúng tôi tài liệu để huấn luyện, chẳng hạn như thông qua [Chương trình Đối tác Phát triển](https://support.claude.com/en/articles/11174108-about-the-development-partner-program), chúng tôi có thể sử dụng những tài liệu được cung cấp đó để huấn luyện mô hình của mình. Quản trị viên của tổ chức có thể chủ động opt-in vào Chương trình Đối tác Phát triển cho tổ chức của họ. Lưu ý rằng chương trình này chỉ khả dụng cho API bên thứ nhất (first-party) của Anthropic, và không dành cho người dùng Amazon Bedrock hoặc Google Cloud's Agent Platform.

### Phản hồi bằng lệnh `/feedback`

Nếu bạn chọn gửi cho chúng tôi phản hồi về Claude Code bằng lệnh `/feedback`, chúng tôi có thể sử dụng phản hồi của bạn để cải thiện các sản phẩm và dịch vụ của mình. Các transcript được chia sẻ qua `/feedback` được lưu giữ trong 5 năm.

### Khảo sát chất lượng phiên (session quality survey)

Khi bạn thấy lời nhắc "How is Claude doing this session?" trong Claude Code, việc trả lời khảo sát này, bao gồm cả khi chọn "Dismiss", chỉ ghi lại đánh giá của bạn. Chúng tôi không thu thập hoặc lưu trữ bất kỳ transcript hội thoại, đầu vào, đầu ra hay dữ liệu phiên nào khác trong khuôn khổ lời nhắc đánh giá này. Không giống như phản hồi thích/không thích (thumbs up/down) hoặc báo cáo `/feedback`, khảo sát chất lượng phiên này là một chỉ số đo lường mức độ hài lòng sản phẩm đơn giản.

Sau lời nhắc đánh giá, bạn có thể thấy một câu hỏi tiếp theo riêng biệt hỏi "Can Anthropic look at your session transcript to help us improve Claude Code?". Đây là một bước thứ hai tùy chọn, tách biệt với phần đánh giá:

* **Yes**: tải lên transcript hội thoại của bạn, mọi transcript của subagent, và tệp log phiên thô từ đĩa lên Anthropic. Các mẫu API key và token đã biết được biên tập ẩn (redact) trước khi tải lên. Mã nguồn, nội dung tệp và nội dung hội thoại khác được tải lên nguyên trạng. Các transcript được chia sẻ được lưu giữ tối đa 6 tháng. Trên Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, và các phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, chọn Yes sẽ ghi cùng payload đó vào một kho lưu trữ cục bộ tại `~/.claude/feedback-bundles/` thay vì tải lên; không có gì rời khỏi máy của bạn cho đến khi bạn chuyển tiếp tệp đó.
* **No**: từ chối mà không gửi bất cứ điều gì
* **Don't ask again**: từ chối và ngừng hiển thị câu hỏi tiếp theo này trong các phiên tương lai

Không có gì được tải lên trừ khi bạn chủ động chọn **Yes**. Các tổ chức áp dụng [zero data retention](/en/zero-data-retention) (không lưu giữ dữ liệu), hoặc nơi phản hồi sản phẩm bị vô hiệu hóa bởi chính sách của tổ chức, hoặc nơi `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` được thiết lập, sẽ không bao giờ thấy câu hỏi tiếp theo này. Các phản hồi của bạn cho khảo sát này, bao gồm cả các transcript phiên được gửi sau lời nhắc đánh giá, không ảnh hưởng đến tùy chọn huấn luyện dữ liệu của bạn và không thể được sử dụng để huấn luyện các mô hình AI của chúng tôi.

Để tắt các khảo sát này, hãy thiết lập `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1`. Khảo sát cũng bị vô hiệu hóa khi `DISABLE_TELEMETRY`, `DO_NOT_TRACK`, hoặc `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` được thiết lập. Các tổ chức chặn lưu lượng không thiết yếu nhưng vẫn thu thập phản hồi khảo sát thông qua [OpenTelemetry collector](/en/monitoring-usage) riêng của họ có thể bật lại khảo sát bằng cách thiết lập `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL=1`. Khi đó khảo sát chỉ ghi các đánh giá vào collector đã cấu hình. Câu hỏi chia sẻ transcript tiếp theo và mọi lưu lượng phản hồi khác hướng đến Anthropic vẫn bị vô hiệu hóa. Để kiểm soát tần suất thay vì tắt hoàn toàn, hãy thiết lập [`feedbackSurveyRate`](/en/settings#available-settings) trong tệp settings của bạn thành một xác suất từ `0` đến `1`.

### Lưu giữ dữ liệu (Data retention)

Anthropic lưu giữ dữ liệu Claude Code dựa trên loại tài khoản và các tùy chọn của bạn.

**Người dùng tiêu dùng (gói Free, Pro và Max)**:

* Người dùng cho phép sử dụng dữ liệu để cải thiện mô hình: thời hạn lưu giữ 5 năm nhằm hỗ trợ phát triển mô hình và cải thiện an toàn
* Người dùng không cho phép sử dụng dữ liệu để cải thiện mô hình: thời hạn lưu giữ 30 ngày
* Các thiết lập quyền riêng tư có thể thay đổi bất cứ lúc nào tại [claude.ai/settings/data-privacy-controls](https://claude.ai/settings/data-privacy-controls).

**Người dùng thương mại (Team, Enterprise và API)**:

* Tiêu chuẩn: thời hạn lưu giữ 30 ngày
* [Zero data retention](/en/zero-data-retention): dành cho các tài khoản đủ điều kiện đối với Claude Code trên Claude for Enterprise. ZDR không được bao gồm trong gói Enterprise tiêu chuẩn; nó được bật theo từng tổ chức bởi nhóm phụ trách tài khoản của bạn sau khi xác nhận đủ điều kiện
* Cache cục bộ: các client Claude Code lưu trữ transcript phiên cục bộ ở dạng văn bản thuần (plaintext) tại `~/.claude/projects/` trong 30 ngày theo mặc định để cho phép tiếp tục phiên. Điều chỉnh khoảng thời gian bằng `cleanupPeriodDays`. Xem [dữ liệu ứng dụng](/en/claude-directory#application-data) để biết những gì được lưu trữ và cách xóa chúng.

Bạn có thể xóa từng phiên Claude Code on the web bất cứ lúc nào. Việc xóa một phiên sẽ xóa vĩnh viễn dữ liệu sự kiện của phiên đó. Để biết hướng dẫn cách xóa các phiên, xem [Delete sessions](/en/claude-code-on-the-web#delete-sessions).

Tìm hiểu thêm về các thực hành lưu giữ dữ liệu trong [Trung tâm Quyền riêng tư](https://privacy.anthropic.com/) của chúng tôi.

Để biết đầy đủ chi tiết, vui lòng xem lại [Điều khoản Dịch vụ Thương mại](https://www.anthropic.com/legal/commercial-terms) (dành cho người dùng Team, Enterprise và API) hoặc [Điều khoản Tiêu dùng](https://www.anthropic.com/legal/consumer-terms) (dành cho người dùng Free, Pro và Max) và [Chính sách Quyền riêng tư](https://www.anthropic.com/legal/privacy) của chúng tôi.

## Truy cập dữ liệu

Đối với tất cả người dùng bên thứ nhất, bạn có thể tìm hiểu thêm về loại dữ liệu nào được ghi log cho [Claude Code cục bộ](#local-claude-code-data-flow-and-dependencies) và [Claude Code từ xa](#cloud-execution-data-flow-and-dependencies). Các phiên [Remote Control](/en/remote-control) tuân theo luồng dữ liệu cục bộ vì toàn bộ quá trình thực thi diễn ra trên máy của bạn. Lưu ý đối với Claude Code từ xa, Claude truy cập kho lưu trữ (repository) nơi bạn khởi tạo phiên Claude Code của mình. Claude không truy cập các repository mà bạn đã kết nối nhưng chưa khởi tạo phiên trong đó.

## Claude Code cục bộ: Luồng dữ liệu và các thành phần phụ thuộc

Sơ đồ dưới đây cho thấy cách Claude Code kết nối đến các dịch vụ bên ngoài trong quá trình cài đặt và vận hành thông thường. Các đường liền nét biểu thị các kết nối bắt buộc, trong khi các đường nét đứt biểu thị các luồng dữ liệu tùy chọn hoặc do người dùng khởi tạo.

<img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/claude-code-data-flow.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=5b1131530bdfdd415700a0cb4d4070c4" alt="Diagram showing Claude Code's external connections: install/update connects to the distribution server, and user requests connect to Anthropic services including Console auth, public-api, and optionally metrics and Sentry. Feedback sent with /feedback goes to Google Cloud Storage and optionally creates a GitHub issue" width="720" height="520" data-path="images/claude-code-data-flow.svg" />

Claude Code chạy cục bộ. Để tương tác với LLM, Claude Code gửi dữ liệu qua mạng. Dữ liệu này bao gồm tất cả prompt của người dùng và đầu ra của mô hình, được mã hóa khi truyền qua TLS 1.2+. Claude Code tương thích với hầu hết các VPN và LLM proxy phổ biến.

Mã hóa khi lưu trữ (encryption at rest) phụ thuộc vào nhà cung cấp mô hình của bạn:

| Nhà cung cấp                  | Mã hóa khi lưu trữ                                                                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Anthropic API                 | Mã hóa đĩa ở cấp hạ tầng (AES-256). Bật [Zero Data Retention](/en/zero-data-retention) để không lưu trữ dai dẳng ở phía máy chủ.       |
| Amazon Bedrock                | AES-256 với các khóa do AWS quản lý. Có thể dùng khóa do khách hàng quản lý qua AWS KMS.                                               |
| Google Cloud's Agent Platform | Các khóa mã hóa do Google quản lý. Có thể dùng CMEK.                                                                                   |
| Microsoft Foundry             | Các yêu cầu được định tuyến đến hạ tầng của Anthropic với mã hóa đĩa AES-256.                                                          |

Claude Code được xây dựng dựa trên các API của Anthropic. Để biết chi tiết về các biện pháp kiểm soát an toàn API, bao gồm cả quy trình ghi log API, hãy xem các tài liệu tuân thủ (compliance artifacts) trong [Anthropic Trust Center](https://trust.anthropic.com).

### Thực thi trên đám mây: Luồng dữ liệu và các thành phần phụ thuộc

Khi sử dụng [Claude Code on the web](/en/claude-code-on-the-web), các phiên chạy trong các máy ảo do Anthropic quản lý thay vì chạy cục bộ. Trong các môi trường đám mây:

* **Lưu trữ code và dữ liệu:** Repository của bạn được clone vào một máy ảo (VM) biệt lập. Code và dữ liệu phiên tuân theo các chính sách lưu giữ và sử dụng dành cho loại tài khoản của bạn (xem phần Lưu giữ dữ liệu ở trên)
* **Thông tin xác thực (Credentials):** Việc xác thực GitHub được xử lý thông qua một proxy an toàn; thông tin xác thực GitHub của bạn không bao giờ đi vào sandbox
* **Lưu lượng mạng:** Toàn bộ lưu lượng đi ra ngoài đều đi qua một proxy an toàn để ghi log kiểm toán và ngăn chặn lạm dụng
* **Dữ liệu phiên:** Prompt, thay đổi code và đầu ra tuân theo cùng các chính sách dữ liệu như khi sử dụng Claude Code cục bộ

Để biết chi tiết an toàn về thực thi trên đám mây, xem [Security](/en/security#cloud-execution-security).

## Các dịch vụ đo lường từ xa (Telemetry)

Claude Code kết nối từ máy của người dùng đến Anthropic để ghi log các chỉ số vận hành như độ trễ (latency), độ tin cậy và các mẫu sử dụng. Việc ghi log này không bao gồm bất kỳ code hay đường dẫn tệp nào. Dữ liệu được mã hóa khi truyền và khi lưu trữ. Để chọn không tham gia (opt out) telemetry, hãy thiết lập biến môi trường `DISABLE_TELEMETRY`.

Claude Code kết nối từ máy của người dùng đến Sentry để ghi log lỗi vận hành. Dữ liệu được mã hóa khi truyền bằng TLS và khi lưu trữ bằng mã hóa AES 256-bit. Đọc thêm trong [tài liệu bảo mật của Sentry](https://sentry.io/security/). Để chọn không tham gia việc ghi log lỗi, hãy thiết lập biến môi trường `DISABLE_ERROR_REPORTING`.

Khi bạn chạy lệnh `/feedback`, một bản sao lịch sử hội thoại của bạn bao gồm cả code sẽ được gửi đến Anthropic. Trước khi gửi, bạn chọn mức độ lịch sử muốn đưa vào: chỉ phiên hiện tại (mặc định), hoặc bao gồm cả các phiên khác từ cùng dự án trong 24 giờ hoặc 7 ngày qua. Dữ liệu được mã hóa khi truyền qua TLS và được lưu trữ trong Google Cloud Storage, dịch vụ này mã hóa dữ liệu lưu trữ khi lưu trữ theo mặc định. Tùy chọn, một GitHub issue sẽ được tạo trong kho lưu trữ công khai. Để chọn không tham gia, hãy thiết lập biến môi trường `DISABLE_FEEDBACK_COMMAND` thành `1`.

Khi bạn sử dụng một nhà cung cấp bên thứ ba như Amazon Bedrock hoặc Google Cloud's Agent Platform, hoặc không có thông tin xác thực Anthropic nào được cấu hình, `/feedback` sẽ ghi báo cáo vào một kho lưu trữ cục bộ tại `~/.claude/feedback-bundles/` thay vì gửi đến Anthropic. Các mẫu API key và token đã biết được biên tập ẩn (redact) trước khi kho lưu trữ được ghi. Không có gì rời khỏi máy của bạn cho đến khi bạn gửi tệp đó cho đại diện tài khoản Anthropic của mình hoặc đính kèm vào một yêu cầu hỗ trợ.

## Các hành vi mặc định theo nhà cung cấp API

Theo mặc định, việc báo cáo lỗi, telemetry và báo cáo lỗi bug bị vô hiệu hóa khi sử dụng Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, hoặc Claude Platform on AWS. Khảo sát chất lượng phiên và kiểm tra an toàn miền của WebFetch là các ngoại lệ và vẫn chạy bất kể nhà cung cấp nào. Trên một phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, phân tích sử dụng (usage analytics), báo cáo lỗi và các đánh giá khảo sát gửi đến Anthropic bị vô hiệu hóa bởi chính thông tin xác thực gateway, không có thiết lập nào để bật lại chúng. Bạn có thể chọn không tham gia toàn bộ lưu lượng không thiết yếu, bao gồm cả khảo sát, cùng một lúc bằng cách thiết lập `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`. Biến này không ảnh hưởng đến kiểm tra WebFetch, vốn có tùy chọn opt-out riêng. Dưới đây là các hành vi mặc định đầy đủ:

| Dịch vụ                              | Claude API                                                                             | Google Cloud's Agent Platform API                                                      | Amazon Bedrock API                                                                     | Microsoft Foundry API                                                                  | Claude Platform on AWS                                                                 |
| ------------------------------------ | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| **Anthropic (Metrics)**              | Mặc định bật.<br />`DISABLE_TELEMETRY=1` để tắt.                                       | Mặc định tắt.<br />`CLAUDE_CODE_USE_VERTEX` phải là 1.                                 | Mặc định tắt.<br />`CLAUDE_CODE_USE_BEDROCK` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_FOUNDRY` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_ANTHROPIC_AWS` phải là 1.                          |
| **Sentry (Errors)**                  | Mặc định bật.<br />`DISABLE_ERROR_REPORTING=1` để tắt.                                 | Mặc định tắt.<br />`CLAUDE_CODE_USE_VERTEX` phải là 1.                                 | Mặc định tắt.<br />`CLAUDE_CODE_USE_BEDROCK` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_FOUNDRY` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_ANTHROPIC_AWS` phải là 1.                          |
| **Claude API (báo cáo `/feedback`)** | Mặc định bật.<br />`DISABLE_FEEDBACK_COMMAND=1` để tắt.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_VERTEX` phải là 1.                                 | Mặc định tắt.<br />`CLAUDE_CODE_USE_BEDROCK` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_FOUNDRY` phải là 1.                                | Mặc định tắt.<br />`CLAUDE_CODE_USE_ANTHROPIC_AWS` phải là 1.                          |
| **Khảo sát chất lượng phiên**        | Mặc định bật.<br />`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` để tắt.                     | Mặc định bật.<br />`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` để tắt.                     | Mặc định bật.<br />`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` để tắt.                     | Mặc định bật.<br />`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` để tắt.                     | Mặc định bật.<br />`CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1` để tắt.                     |
| **Kiểm tra an toàn miền WebFetch**   | Mặc định bật.<br />`skipWebFetchPreflight: true` trong [settings](/en/settings) để tắt. | Mặc định bật.<br />`skipWebFetchPreflight: true` trong [settings](/en/settings) để tắt. | Mặc định bật.<br />`skipWebFetchPreflight: true` trong [settings](/en/settings) để tắt. | Mặc định bật.<br />`skipWebFetchPreflight: true` trong [settings](/en/settings) để tắt. | Mặc định bật.<br />`skipWebFetchPreflight: true` trong [settings](/en/settings) để tắt. |

Tất cả các biến môi trường đều có thể được đưa vào (check in) `settings.json` (xem [tài liệu tham chiếu settings](/en/settings)).

Kể từ phiên bản v2.1.126, khi một nền tảng host thiết lập `CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST`, metrics sẽ mặc định bật cho Google Cloud's Agent Platform, Amazon Bedrock và Microsoft Foundry, và tuân theo tùy chọn opt-out tiêu chuẩn `DISABLE_TELEMETRY`. Việc báo cáo lỗi Sentry và các báo cáo `/feedback` vẫn tắt theo mặc định trên các nhà cung cấp đó.

### Kiểm tra an toàn miền của WebFetch

Trước khi tải một URL, công cụ WebFetch gửi tên host (hostname) được yêu cầu đến `api.anthropic.com` để kiểm tra nó dựa trên một danh sách chặn (blocklist) an toàn do Anthropic duy trì. Chỉ tên host được gửi đi, không phải toàn bộ URL, đường dẫn hay nội dung trang. Kết quả được cache theo từng tên host trong năm phút.

Kiểm tra này chạy bất kể bạn dùng nhà cung cấp mô hình nào và không bị ảnh hưởng bởi `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`. Nếu mạng của bạn chặn `api.anthropic.com`, các yêu cầu WebFetch sẽ thất bại cho đến khi bạn đưa miền vào danh sách cho phép (allowlist) hoặc thiết lập `skipWebFetchPreflight: true` trong [settings](/en/settings). Việc vô hiệu hóa kiểm tra này có nghĩa là WebFetch sẽ cố gắng truy xuất bất kỳ URL nào mà không tham chiếu blocklist, vì vậy hãy kết hợp nó với [quy tắc quyền (permission rules) cho `WebFetch`](/en/permissions#webfetch) nếu bạn cần giới hạn các miền mà Claude có thể truy cập.
