> Nguồn: https://code.claude.com/docs/en/security.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bảo mật

> Tìm hiểu về các biện pháp bảo vệ an ninh của Claude Code và các thực hành tốt nhất để sử dụng an toàn.

## Cách chúng tôi tiếp cận vấn đề bảo mật

### Nền tảng bảo mật

Bảo mật mã nguồn của bạn là tối quan trọng. Claude Code được xây dựng với bảo mật làm cốt lõi, phát triển theo chương trình bảo mật toàn diện của Anthropic. Tìm hiểu thêm và truy cập các tài nguyên (báo cáo SOC 2 Type 2, chứng chỉ ISO 27001, v.v.) tại [Anthropic Trust Center](https://trust.anthropic.com).

### Kiến trúc dựa trên quyền hạn (permission)

Claude Code sử dụng quyền chỉ-đọc (read-only) nghiêm ngặt theo mặc định. Khi cần thực hiện các hành động bổ sung (chỉnh sửa file, chạy test, thực thi lệnh), Claude Code sẽ yêu cầu quyền một cách rõ ràng. Người dùng kiểm soát việc phê duyệt hành động một lần hay cho phép tự động.

Claude Code yêu cầu phê duyệt trước khi chạy các lệnh Bash có thể thay đổi hệ thống của bạn. Một tập hợp lệnh chỉ-đọc tích hợp sẵn như `ls`, `cat`, và `git status` sẽ chạy mà không cần hỏi. Cách tiếp cận này cho phép người dùng và tổ chức cấu hình quyền hạn một cách trực tiếp.

Để biết chi tiết cấu hình quyền hạn, xem [Permissions](/en/permissions).

### Các cơ chế bảo vệ tích hợp sẵn

Để giảm thiểu rủi ro trong các hệ thống agentic (dựa trên agent):

* **Công cụ bash trong sandbox**: [Sandbox](/en/sandboxing) hóa các lệnh bash với cô lập hệ thống file và mạng, giảm số lần hỏi quyền trong khi vẫn duy trì bảo mật. Bật bằng `/sandbox` để định nghĩa các ranh giới nơi Claude Code có thể làm việc tự động
* **Hạn chế quyền ghi**: Claude Code chỉ có thể ghi vào thư mục nơi nó được khởi động và các thư mục con của nó—nó không thể chỉnh sửa file trong các thư mục cha nếu không có quyền rõ ràng. Mặc dù Claude Code có thể đọc file bên ngoài thư mục làm việc (hữu ích để truy cập thư viện hệ thống và các dependency), thao tác ghi bị giới hạn nghiêm ngặt trong phạm vi dự án, tạo ra một ranh giới bảo mật rõ ràng
* **Giảm mệt mỏi vì bị hỏi quyền (prompt fatigue)**: Hỗ trợ đưa vào danh sách cho phép (allowlist) các lệnh an toàn thường dùng theo từng người dùng, từng codebase, hoặc từng tổ chức
* **Chế độ Accept Edits**: Tự động phê duyệt các chỉnh sửa file và một tập cố định các lệnh Bash thao tác hệ thống file như `mkdir`, `touch`, `rm`, `mv`, `cp`, và `sed` cho các đường dẫn trong thư mục làm việc. Các lệnh Bash khác và các đường dẫn ngoài phạm vi vẫn sẽ hỏi quyền

### Trách nhiệm của người dùng

Claude Code chỉ có những quyền mà bạn cấp cho nó. Bạn chịu trách nhiệm xem xét mã nguồn và lệnh được đề xuất để đảm bảo an toàn trước khi phê duyệt.

## Bảo vệ chống lại prompt injection

Prompt injection là một kỹ thuật trong đó kẻ tấn công cố gắng ghi đè hoặc thao túng hướng dẫn của một trợ lý AI bằng cách chèn văn bản độc hại. Claude Code bao gồm một số biện pháp bảo vệ chống lại các cuộc tấn công này:

### Các cơ chế bảo vệ cốt lõi

* **Hệ thống quyền hạn**: Các thao tác nhạy cảm yêu cầu phê duyệt rõ ràng
* **Phân tích theo ngữ cảnh**: Phát hiện các hướng dẫn có khả năng gây hại bằng cách phân tích toàn bộ yêu cầu
* **Làm sạch dữ liệu đầu vào (input sanitization)**: Ngăn chặn command injection bằng cách xử lý dữ liệu đầu vào của người dùng
* **Phê duyệt lệnh mạng**: Các lệnh lấy nội dung từ web như `curl` và `wget` không được tự động phê duyệt theo mặc định. Chúng sẽ hỏi quyền như bất kỳ lệnh Bash không-chỉ-đọc nào khác, vì vậy bạn vẫn có thể phê duyệt một lần hoặc thêm một quy tắc cho phép rõ ràng như `Bash(curl *)`. Để chặn hoàn toàn, hãy thêm chúng vào [`permissions.deny`](/en/permissions#tool-specific-permission-rules)

### Các biện pháp bảo vệ quyền riêng tư

Chúng tôi đã triển khai một số biện pháp bảo vệ để bảo vệ dữ liệu của bạn, bao gồm:

* Thời gian lưu giữ giới hạn đối với thông tin nhạy cảm (xem [Privacy Center](https://privacy.anthropic.com/en/articles/10023548-how-long-do-you-store-my-data) để tìm hiểu thêm)
* Hạn chế quyền truy cập vào dữ liệu phiên (session) của người dùng
* Người dùng kiểm soát tùy chọn huấn luyện dữ liệu. Người dùng gói tiêu dùng (Consumer) có thể thay đổi [thiết lập quyền riêng tư](https://claude.ai/settings/privacy) của họ bất cứ lúc nào.

Để biết đầy đủ chi tiết, vui lòng xem lại [Điều khoản Dịch vụ Thương mại](https://www.anthropic.com/legal/commercial-terms) (dành cho người dùng Team, Enterprise, và API) hoặc [Điều khoản Tiêu dùng](https://www.anthropic.com/legal/consumer-terms) (dành cho người dùng Free, Pro, và Max) và [Chính sách Quyền riêng tư](https://www.anthropic.com/legal/privacy).

### Các biện pháp bảo vệ bổ sung

* **Phê duyệt yêu cầu mạng**: Các công cụ thực hiện yêu cầu mạng yêu cầu người dùng phê duyệt theo mặc định
* **Context window cô lập**: Web fetch sử dụng một context window (cửa sổ ngữ cảnh) riêng biệt để tránh chèn các prompt có khả năng độc hại
* **Xác minh độ tin cậy (trust verification)**: Lần chạy đầu tiên trên một codebase và các MCP server mới yêu cầu xác minh độ tin cậy
  * Lưu ý: Xác minh độ tin cậy bị vô hiệu hóa khi chạy ở chế độ không tương tác với flag `-p`
  * Lưu ý: Khi bạn khởi động Claude Code trực tiếp trong thư mục home của mình, việc chấp nhận độ tin cậy chỉ được giữ cho phiên hiện tại và không được ghi ra đĩa, vì vậy lời nhắc sẽ xuất hiện lại mỗi lần khởi động. Không có thiết lập nào để lưu giữ nó. Thay vào đó hãy khởi động Claude Code từ một thư mục con của dự án, nơi việc chấp nhận độ tin cậy được lưu theo từng thư mục
* **Phát hiện command injection**: Các lệnh bash đáng ngờ yêu cầu phê duyệt thủ công ngay cả khi đã được đưa vào allowlist trước đó
* **Đối sánh fail-closed**: Các lệnh không khớp mặc định sẽ yêu cầu phê duyệt thủ công
* **Mô tả bằng ngôn ngữ tự nhiên**: Các lệnh bash phức tạp bao gồm phần giải thích để người dùng hiểu
* **Lưu trữ thông tin xác thực an toàn**: Các API key và token được lưu trong macOS Keychain khi có sẵn, và được bảo vệ bằng quyền file trên Windows và Linux. Xem [Credential Management](/en/authentication#credential-management)

<Warning>
  **Rủi ro bảo mật WebDAV trên Windows**: Khi chạy Claude Code trên Windows, chúng tôi khuyến nghị không bật WebDAV hoặc không cho phép Claude Code truy cập các đường dẫn như `\\*` có thể chứa các thư mục con WebDAV. [WebDAV đã bị Microsoft ngừng hỗ trợ (deprecated)](https://learn.microsoft.com/en-us/windows/whats-new/deprecated-features#:~:text=The%20Webclient%20\(WebDAV\)%20service%20is%20deprecated) do các rủi ro bảo mật. Việc bật WebDAV có thể cho phép Claude Code kích hoạt các yêu cầu mạng đến các host từ xa, bỏ qua hệ thống quyền hạn.
</Warning>

**Các thực hành tốt nhất khi làm việc với nội dung không đáng tin cậy**:

1. Xem xét các lệnh được đề xuất trước khi phê duyệt
2. Tránh đưa (pipe) nội dung không đáng tin cậy trực tiếp vào Claude
3. Xác minh các thay đổi được đề xuất đối với các file quan trọng
4. Sử dụng máy ảo (VM) để chạy script và thực hiện các lệnh gọi công cụ, đặc biệt khi tương tác với các dịch vụ web bên ngoài
5. Báo cáo hành vi đáng ngờ bằng `/feedback`

<Warning>
  Mặc dù các biện pháp bảo vệ này giảm đáng kể rủi ro, không có hệ thống nào miễn nhiễm hoàn toàn với mọi cuộc tấn công. Luôn duy trì các thực hành bảo mật tốt khi làm việc với bất kỳ công cụ AI nào.
</Warning>

## Bảo mật MCP

Claude Code cho phép người dùng cấu hình các MCP (Model Context Protocol) server. Danh sách các MCP server được phép được cấu hình trong mã nguồn của bạn, như một phần của thiết lập Claude Code mà các kỹ sư đưa vào quản lý phiên bản (source control).

Chúng tôi khuyến khích bạn hoặc tự viết MCP server của riêng mình, hoặc sử dụng MCP server từ các nhà cung cấp mà bạn tin tưởng. Bạn có thể cấu hình quyền hạn của Claude Code cho các MCP server. Anthropic đánh giá các connector theo [tiêu chí đăng danh mục (listing criteria)](https://claude.com/docs/connectors/building/review-criteria) trước khi thêm chúng vào [Anthropic Directory](https://claude.ai/directory), nhưng không kiểm định bảo mật hay quản lý bất kỳ MCP server nào.

## Bảo mật IDE

Xem [VS Code security and privacy](/en/vs-code#security-and-privacy) để biết thêm thông tin về việc chạy Claude Code trong một IDE.

## Bảo mật thực thi trên đám mây (cloud)

Khi sử dụng [Claude Code trên web](/en/claude-code-on-the-web), có thêm các biện pháp kiểm soát bảo mật:

* **Máy ảo cô lập**: Mỗi phiên trên đám mây chạy trong một VM cô lập, do Anthropic quản lý
* **Kiểm soát truy cập mạng**: Truy cập mạng bị giới hạn theo mặc định và có thể được cấu hình để vô hiệu hóa hoặc chỉ cho phép các domain cụ thể
* **Bảo vệ thông tin xác thực**: Việc xác thực được xử lý thông qua một proxy an toàn sử dụng một thông tin xác thực có phạm vi giới hạn (scoped credential) bên trong sandbox, sau đó được chuyển đổi thành token xác thực GitHub thực tế của bạn
* **Hạn chế nhánh (branch)**: Các thao tác git push bị giới hạn ở nhánh làm việc hiện tại
* **Ghi log kiểm toán (audit logging)**: Tất cả các thao tác trong môi trường đám mây đều được ghi log để phục vụ tuân thủ và kiểm toán
* **Tự động dọn dẹp**: Các môi trường đám mây được tự động chấm dứt sau khi phiên hoàn tất

Để biết thêm chi tiết về thực thi trên đám mây, xem [Claude Code trên web](/en/claude-code-on-the-web).

Các phiên [Remote Control](/en/remote-control) hoạt động theo cách khác: giao diện web kết nối đến một tiến trình Claude Code đang chạy trên máy cục bộ của bạn. Toàn bộ việc thực thi mã và truy cập file vẫn ở cục bộ, và cùng loại dữ liệu chảy trong bất kỳ phiên Claude Code cục bộ nào cũng đi qua Anthropic API qua TLS. Không có VM đám mây hay sandbox nào tham gia. Kết nối sử dụng nhiều thông tin xác thực có thời gian tồn tại ngắn, phạm vi hẹp, mỗi cái giới hạn cho một mục đích cụ thể và hết hạn độc lập, nhằm giới hạn phạm vi ảnh hưởng (blast radius) của bất kỳ thông tin xác thực bị xâm phạm nào.

## Các thực hành bảo mật tốt nhất

### Làm việc với mã nguồn nhạy cảm

* Xem xét tất cả các thay đổi được đề xuất trước khi phê duyệt
* Sử dụng thiết lập quyền hạn riêng cho từng dự án đối với các repository nhạy cảm
* Cân nhắc sử dụng [dev container](/en/devcontainer) để có thêm sự cô lập
* Thường xuyên kiểm tra thiết lập quyền hạn của bạn bằng `/permissions`

### Bảo mật cho nhóm (team)

* Sử dụng [managed settings](/en/settings#settings-files) để thực thi các tiêu chuẩn của tổ chức
* Chia sẻ các cấu hình quyền hạn đã được phê duyệt thông qua quản lý phiên bản (version control)
* Đào tạo các thành viên trong nhóm về các thực hành bảo mật tốt nhất
* Giám sát việc sử dụng Claude Code thông qua [số liệu OpenTelemetry](/en/monitoring-usage)
* Kiểm toán hoặc chặn các thay đổi thiết lập trong phiên bằng [`ConfigChange` hook](/en/hooks#configchange)

### Báo cáo các vấn đề bảo mật

Nếu bạn phát hiện một lỗ hổng bảo mật trong Claude Code:

1. Không tiết lộ công khai
2. Báo cáo thông qua [chương trình HackerOne](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new) của chúng tôi
3. Bao gồm các bước tái hiện chi tiết
4. Cho chúng tôi thời gian để xử lý vấn đề trước khi công bố công khai

## Tài nguyên liên quan

* [Security guidance plugin](/en/security-guidance): để Claude xem xét và sửa các lỗ hổng bảo mật trong chính các thay đổi mã nguồn của nó trong phiên làm việc
* [Sandbox environments](/en/sandbox-environments): so sánh các cách tiếp cận cô lập và chọn một cách phù hợp với mô hình mối đe dọa (threat model) của bạn
* [Sandboxing](/en/sandboxing): cô lập hệ thống file và mạng cho các lệnh Bash
* [Permissions](/en/permissions): cấu hình quyền hạn và kiểm soát truy cập
* [Monitoring usage](/en/monitoring-usage): theo dõi và kiểm toán hoạt động của Claude Code
* [Development containers](/en/devcontainer): các môi trường an toàn, cô lập
* [Anthropic Trust Center](https://trust.anthropic.com): các chứng nhận bảo mật và tuân thủ
