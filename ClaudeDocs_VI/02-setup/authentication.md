> Nguồn: https://code.claude.com/docs/en/authentication.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Xác thực (Authentication)

> Đăng nhập vào Claude Code và cấu hình xác thực cho cá nhân, nhóm và tổ chức.

Claude Code hỗ trợ nhiều phương thức xác thực khác nhau tùy theo thiết lập của bạn. Người dùng cá nhân có thể đăng nhập bằng tài khoản Claude.ai, trong khi các nhóm có thể dùng Claude for Teams hoặc Enterprise, Claude Console, hoặc một nhà cung cấp đám mây như Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry.

## Đăng nhập vào Claude Code

Sau khi [cài đặt Claude Code](/en/setup#install-claude-code), chạy `claude` trong terminal của bạn. Ở lần khởi chạy đầu tiên, Claude Code mở một cửa sổ trình duyệt để bạn đăng nhập.

Nếu trình duyệt không tự động mở, nhấn `c` để sao chép URL đăng nhập vào clipboard, rồi dán vào trình duyệt.

Nếu trình duyệt hiển thị một mã đăng nhập thay vì chuyển hướng trở lại sau khi bạn đăng nhập, hãy dán mã đó vào terminal tại dấu nhắc `Paste code here if prompted`. Điều này xảy ra khi trình duyệt không thể kết nối tới máy chủ callback cục bộ của Claude Code, thường gặp trong WSL2, các phiên SSH và container.

Bạn có thể xác thực bằng bất kỳ loại tài khoản nào sau đây:

* **Đăng ký Claude Pro hoặc Max**: đăng nhập bằng tài khoản Claude.ai của bạn. Đăng ký tại [claude.com/pricing](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=authentication_pro_max).
* **Claude for Teams hoặc Enterprise**: đăng nhập bằng tài khoản Claude.ai mà quản trị viên nhóm của bạn đã mời bạn tham gia.
* **Claude Console**: đăng nhập bằng thông tin đăng nhập Console của bạn. Quản trị viên của bạn phải [mời bạn](#claude-console-authentication) trước.
* **Nhà cung cấp đám mây**: nếu tổ chức của bạn dùng [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [Microsoft Foundry](/en/microsoft-foundry), hãy thiết lập các biến môi trường cần thiết trước khi chạy `claude`. Không cần đăng nhập qua trình duyệt.
* **Cloud gateway**: nếu tổ chức của bạn vận hành một [Claude apps gateway](/en/claude-apps-gateway) tự lưu trữ (self-hosted), hãy đăng nhập bằng SSO của doanh nghiệp thông qua `/login`. Token do gateway cấp là thông tin xác thực duy nhất của phiên làm việc.

Để đăng xuất và xác thực lại, gõ `/logout` tại dấu nhắc của Claude Code.

Nếu bạn gặp khó khăn khi đăng nhập, xem [khắc phục sự cố xác thực](/en/troubleshoot-install#login-and-authentication).

## Thiết lập xác thực cho nhóm

Đối với các nhóm và tổ chức, bạn có thể cấu hình quyền truy cập Claude Code theo một trong các cách sau:

* [Claude for Teams hoặc Enterprise](#claude-for-teams-or-enterprise), khuyến nghị cho hầu hết các nhóm
* [Claude Console](#claude-console-authentication)
* [Claude apps gateway](/en/claude-apps-gateway), một gateway tự lưu trữ giúp đăng nhập cho lập trình viên bằng IdP của bạn và định tuyến suy luận (inference) tới nhà cung cấp đám mây mà bạn cấu hình
* [Amazon Bedrock](/en/amazon-bedrock)
* [Google Cloud's Agent Platform](/en/google-vertex-ai)
* [Microsoft Foundry](/en/microsoft-foundry)

### Claude for Teams hoặc Enterprise

[Claude for Teams](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=authentication_teams#team-&-enterprise) và [Claude for Enterprise](https://anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=authentication_enterprise) mang lại trải nghiệm tốt nhất cho các tổ chức sử dụng Claude Code. Thành viên nhóm có quyền truy cập cả Claude Code và Claude trên web, với thanh toán tập trung và quản lý nhóm.

* **Claude for Teams**: gói tự phục vụ (self-service) với các tính năng cộng tác, công cụ quản trị và quản lý thanh toán. Phù hợp nhất cho các nhóm nhỏ.
* **Claude for Enterprise**: bổ sung SSO, domain capture, phân quyền theo vai trò (role-based permissions), compliance API, và cài đặt chính sách được quản lý (managed policy) cho các cấu hình Claude Code trên toàn tổ chức. Phù hợp nhất cho các tổ chức lớn có yêu cầu về bảo mật và tuân thủ.

<Steps>
  <Step title="Đăng ký">
    Đăng ký [Claude for Teams](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=authentication_teams_step#team-&-enterprise) hoặc liên hệ bộ phận kinh doanh (sales) để dùng [Claude for Enterprise](https://anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=authentication_enterprise_step).
  </Step>

  <Step title="Mời thành viên nhóm">
    Mời thành viên nhóm từ bảng điều khiển quản trị (admin dashboard).
  </Step>

  <Step title="Cài đặt và đăng nhập">
    Các thành viên nhóm cài đặt Claude Code và đăng nhập bằng tài khoản Claude.ai của họ.
  </Step>
</Steps>

### Xác thực qua Claude Console

Đối với các tổ chức ưu tiên thanh toán dựa trên API, bạn có thể thiết lập quyền truy cập thông qua Claude Console.

<Steps>
  <Step title="Tạo hoặc dùng tài khoản Console">
    Dùng tài khoản Claude Console hiện có của bạn hoặc tạo tài khoản mới.
  </Step>

  <Step title="Thêm người dùng">
    Bạn có thể thêm người dùng bằng một trong hai cách:

    * Mời hàng loạt người dùng ngay trong Console: Settings -> Members -> Invite
    * [Thiết lập SSO](https://support.claude.com/en/articles/13132885-setting-up-single-sign-on-sso)
  </Step>

  <Step title="Gán vai trò">
    Khi mời người dùng, hãy gán một trong các vai trò:

    * Vai trò **Claude Code**: người dùng chỉ có thể tạo API key cho Claude Code
    * Vai trò **Developer**: người dùng có thể tạo bất kỳ loại API key nào
  </Step>

  <Step title="Người dùng hoàn tất thiết lập">
    Mỗi người dùng được mời cần:

    * Chấp nhận lời mời Console
    * [Kiểm tra yêu cầu hệ thống](/en/setup#system-requirements)
    * [Cài đặt Claude Code](/en/setup#install-claude-code)
    * Đăng nhập bằng thông tin đăng nhập tài khoản Console
  </Step>
</Steps>

### Xác thực qua nhà cung cấp đám mây

Đối với các nhóm sử dụng Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry:

<Steps>
  <Step title="Làm theo hướng dẫn thiết lập của nhà cung cấp">
    Làm theo [tài liệu Amazon Bedrock](/en/amazon-bedrock), [tài liệu Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [tài liệu Microsoft Foundry](/en/microsoft-foundry).
  </Step>

  <Step title="Phân phối cấu hình">
    Phân phối các biến môi trường và hướng dẫn tạo thông tin đăng nhập đám mây (cloud credentials) cho người dùng của bạn. Tìm hiểu thêm về cách [quản lý cấu hình tại đây](/en/settings).
  </Step>

  <Step title="Cài đặt Claude Code">
    Người dùng có thể [cài đặt Claude Code](/en/setup#install-claude-code).
  </Step>
</Steps>

## Quản lý thông tin đăng nhập

Claude Code quản lý thông tin xác thực của bạn một cách an toàn:

* **Vị trí lưu trữ**:
  * Trên macOS, thông tin đăng nhập được lưu trong macOS Keychain đã mã hóa.
  * Trên Linux, thông tin đăng nhập được lưu trong `~/.claude/.credentials.json` với chế độ file `0600`.
  * Trên Windows, thông tin đăng nhập được lưu trong `%USERPROFILE%\.claude\.credentials.json` và kế thừa các kiểm soát truy cập của thư mục hồ sơ người dùng (user profile) của bạn, mặc định giới hạn file chỉ cho tài khoản người dùng của bạn.
  * Nếu bạn đã thiết lập biến môi trường `CLAUDE_CONFIG_DIR` trên Linux hoặc Windows, file `.credentials.json` sẽ nằm trong thư mục đó thay vì vị trí trên.
  * Claude Code quản lý `.credentials.json` thông qua `/login` và `/logout`. Để định tuyến các yêu cầu qua một endpoint API tùy chỉnh, hãy thiết lập biến môi trường [`ANTHROPIC_BASE_URL`](/en/env-vars) thay vào đó.
* **Các loại xác thực được hỗ trợ**: thông tin đăng nhập Claude.ai, thông tin đăng nhập Claude API, Azure Auth, Bedrock Auth, Vertex Auth, và session token của [Claude apps gateway](/en/claude-apps-gateway).
* **Script thông tin đăng nhập tùy chỉnh**: cài đặt [`apiKeyHelper`](/en/settings#available-settings) có thể được cấu hình để chạy một shell script trả về một API key.
* **Khoảng thời gian làm mới**: mặc định, `apiKeyHelper` được gọi sau 5 phút hoặc khi có phản hồi HTTP 401. Thiết lập biến môi trường `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` để tùy chỉnh khoảng thời gian làm mới.
* **Thông báo helper chậm**: nếu `apiKeyHelper` mất hơn 10 giây để trả về một key, Claude Code sẽ hiển thị thông báo cảnh báo trên thanh nhắc (prompt bar) cho biết thời gian đã trôi qua. Nếu bạn thường xuyên thấy thông báo này, hãy kiểm tra xem script thông tin đăng nhập của bạn có thể tối ưu được không.

`apiKeyHelper`, `ANTHROPIC_API_KEY`, và `ANTHROPIC_AUTH_TOKEN` áp dụng cho CLI và các bề mặt (surfaces) bao bọc nó, bao gồm tiện ích mở rộng VS Code, Agent SDK, và GitHub Actions. Claude Desktop và các phiên trên đám mây không gọi `apiKeyHelper` cũng như không đọc các biến môi trường này: chúng dùng OAuth, ngoại trừ các phiên desktop chạy một [cấu hình suy luận bên thứ ba do tổ chức phân phối](/en/llm-gateway-connect#desktop-app), vốn xác thực bằng thông tin đăng nhập của cấu hình đó.

### Thứ tự ưu tiên xác thực

Khi có nhiều thông tin đăng nhập cùng lúc, Claude Code chọn một theo thứ tự sau:

1. Thông tin đăng nhập của nhà cung cấp đám mây, khi `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, hoặc `CLAUDE_CODE_USE_FOUNDRY` được thiết lập. Xem [tích hợp bên thứ ba](/en/third-party-integrations) để biết cách thiết lập.
2. Biến môi trường `ANTHROPIC_AUTH_TOKEN`. Được gửi dưới dạng header `Authorization: Bearer`. Dùng cách này khi định tuyến qua một [LLM gateway hoặc proxy](/en/llm-gateway) xác thực bằng bearer token thay vì Anthropic API key.
3. Biến môi trường `ANTHROPIC_API_KEY`. Được gửi dưới dạng header `X-Api-Key`. Dùng cách này để truy cập trực tiếp Anthropic API với một key từ [Claude Console](https://platform.claude.com). Ở chế độ tương tác (interactive mode), bạn được nhắc một lần để phê duyệt hoặc từ chối key, và lựa chọn của bạn được ghi nhớ. Để thay đổi sau này, dùng công tắc "Use custom API key" trong `/config`. Ở chế độ không tương tác (`-p`), key luôn được sử dụng khi có mặt.
4. Kết quả đầu ra của script [`apiKeyHelper`](/en/settings#available-settings). Dùng cách này cho thông tin đăng nhập động hoặc luân phiên (rotating), chẳng hạn các token ngắn hạn lấy từ một vault.
5. Biến môi trường `CLAUDE_CODE_OAUTH_TOKEN`. Một OAuth token dài hạn được tạo bởi [`claude setup-token`](#generate-a-long-lived-token). Dùng cách này cho các pipeline CI và script nơi không thể đăng nhập qua trình duyệt.
6. Thông tin đăng nhập OAuth theo đăng ký (subscription) từ `/login`. Đây là mặc định cho người dùng Claude Pro, Max, Team, và Enterprise.

Một phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập nằm ngoài danh sách này: nó là một lựa chọn nhà cung cấp giống như Amazon Bedrock hoặc Google Cloud's Agent Platform, và nó có mức ưu tiên cao hơn chúng. Khi tồn tại một phiên gateway, CLI xác thực bằng gateway token ngay cả khi `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, hoặc `CLAUDE_CODE_USE_FOUNDRY` được thiết lập, và các mục bearer token, API key, cùng `apiKeyHelper` ở trên sẽ không được dùng.

Nếu bạn có một gói đăng ký Claude đang hoạt động nhưng đồng thời có `ANTHROPIC_API_KEY` được thiết lập trong môi trường, thì API key sẽ được ưu tiên một khi đã được phê duyệt. Điều này có thể gây ra lỗi xác thực nếu key thuộc về một tổ chức đã bị vô hiệu hóa hoặc hết hạn. Chạy `unset ANTHROPIC_API_KEY` để quay về dùng gói đăng ký của bạn, và kiểm tra `/status` để xác nhận phương thức nào đang hoạt động.

[Claude Code on the Web](/en/claude-code-on-the-web) luôn dùng thông tin đăng nhập theo gói đăng ký của bạn. `ANTHROPIC_API_KEY` và `ANTHROPIC_AUTH_TOKEN` trong môi trường sandbox không ghi đè chúng.

### Tạo token dài hạn

Đối với các pipeline CI, script, hoặc các môi trường khác nơi không thể đăng nhập tương tác qua trình duyệt, hãy tạo một OAuth token có thời hạn một năm bằng `claude setup-token`:

```bash theme={null}
claude setup-token
```

Lệnh này sẽ hướng dẫn bạn qua quá trình cấp quyền OAuth và in ra một token trong terminal. Nó không lưu token ở bất kỳ đâu; hãy sao chép token và thiết lập nó làm biến môi trường `CLAUDE_CODE_OAUTH_TOKEN` ở bất kỳ nơi nào bạn muốn xác thực:

```bash theme={null}
export CLAUDE_CODE_OAUTH_TOKEN=your-token
```

Token này xác thực bằng gói đăng ký Claude của bạn và yêu cầu gói Pro, Max, Team, hoặc Enterprise. Nó chỉ có phạm vi dành cho suy luận (inference) và không thể thiết lập các phiên [Remote Control](/en/remote-control).

[Bare mode](/en/headless#start-faster-with-bare-mode) không đọc `CLAUDE_CODE_OAUTH_TOKEN`. Nếu script của bạn truyền `--bare`, hãy xác thực bằng `ANTHROPIC_API_KEY` hoặc một `apiKeyHelper` thay thế.
