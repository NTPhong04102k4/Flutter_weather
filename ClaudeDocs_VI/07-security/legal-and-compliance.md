> Nguồn: https://code.claude.com/docs/en/legal-and-compliance.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Pháp lý và tuân thủ

> Các thỏa thuận pháp lý, chứng nhận tuân thủ và thông tin bảo mật cho Claude Code.

## Thỏa thuận pháp lý

### Giấy phép

Việc bạn sử dụng Claude Code phải tuân theo:

* [Điều khoản Thương mại](https://www.anthropic.com/legal/commercial-terms) - dành cho người dùng Team, Enterprise và Claude API
* [Điều khoản Dịch vụ cho Người dùng](https://www.anthropic.com/legal/consumer-terms) - dành cho người dùng Free, Pro và Max

### Thỏa thuận thương mại

Dù bạn đang sử dụng Claude API trực tiếp (1P) hay truy cập thông qua Amazon Bedrock hoặc Agent Platform của Google Cloud (3P), thỏa thuận thương mại hiện có của bạn sẽ được áp dụng cho việc sử dụng Claude Code, trừ khi chúng ta có thỏa thuận khác.

## Tuân thủ

### Tuân thủ trong lĩnh vực y tế (BAA)

Nếu một khách hàng có Thỏa thuận Đối tác Kinh doanh (Business Associate Agreement - BAA) với chúng tôi và muốn sử dụng Claude Code, BAA sẽ tự động được mở rộng để bao gồm Claude Code nếu khách hàng đã ký kết BAA và đã kích hoạt [Zero Data Retention (ZDR)](/en/zero-data-retention). BAA sẽ áp dụng cho lưu lượng API của khách hàng đó đi qua Claude Code. ZDR được kích hoạt theo từng tổ chức (per-organization), vì vậy mỗi tổ chức phải kích hoạt ZDR riêng biệt để được BAA bảo vệ.

## Chính sách sử dụng

### Sử dụng được chấp nhận

Việc sử dụng Claude Code phải tuân theo [Chính sách Sử dụng của Anthropic](https://www.anthropic.com/legal/aup). Các giới hạn sử dụng được công bố cho gói Pro và Max giả định việc sử dụng Claude Code và Agent SDK một cách thông thường, mang tính cá nhân.

### Xác thực và sử dụng thông tin đăng nhập

Claude Code xác thực với máy chủ của Anthropic bằng OAuth token hoặc API key. Các phương thức xác thực này phục vụ những mục đích khác nhau:

* **Xác thực OAuth** dành riêng cho những người mua các gói đăng ký Claude Free, Pro, Max, Team và Enterprise, và được thiết kế để hỗ trợ việc sử dụng thông thường Claude Code cùng các ứng dụng gốc khác của Anthropic. Thêm thông tin về cách người dùng có thể xác thực bằng OAuth token có thể xem tại [Đăng nhập vào tài khoản Claude của bạn](https://support.claude.com/en/articles/13189465-logging-in-to-your-claude-account).
* **Nhà phát triển (Developers)** xây dựng các sản phẩm hoặc dịch vụ tương tác với các năng lực của Claude, bao gồm những người sử dụng [Agent SDK](/en/agent-sdk/overview), nên sử dụng xác thực bằng API key thông qua [Claude Console](https://platform.claude.com/) hoặc một nhà cung cấp đám mây được hỗ trợ. Anthropic không cho phép các nhà phát triển bên thứ ba cung cấp đăng nhập Claude.ai hoặc định tuyến các yêu cầu qua thông tin đăng nhập của gói Free, Pro hay Max thay mặt cho người dùng của họ.

Anthropic bảo lưu quyền thực hiện các biện pháp để thực thi những hạn chế này và có thể làm vậy mà không cần thông báo trước.

Đối với các câu hỏi về những phương thức xác thực được phép cho trường hợp sử dụng của bạn, vui lòng [liên hệ bộ phận bán hàng](https://www.anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=legal_compliance_contact_sales).

## Bảo mật và tin cậy

### Tin cậy và an toàn

Bạn có thể tìm thêm thông tin trong [Trung tâm Tin cậy của Anthropic (Anthropic Trust Center)](https://trust.anthropic.com) và [Transparency Hub](https://www.anthropic.com/transparency).

### Báo cáo lỗ hổng bảo mật

Anthropic quản lý chương trình bảo mật của mình thông qua HackerOne. [Sử dụng biểu mẫu này để báo cáo các lỗ hổng](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new).

***

© Anthropic PBC. All rights reserved. Use is subject to applicable Anthropic Terms of Service.
