> Nguồn: https://code.claude.com/docs/en/admin-setup.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Thiết lập Claude Code cho tổ chức của bạn

> Một sơ đồ ra quyết định dành cho quản trị viên triển khai Claude Code, bao gồm các nhà cung cấp API, managed settings, thực thi chính sách, giám sát mức sử dụng và xử lý dữ liệu.

Claude Code thực thi chính sách của tổ chức thông qua managed settings, vốn được ưu tiên hơn cấu hình cục bộ của lập trình viên. Bạn phân phối những thiết lập đó từ Claude admin console, từ hệ thống quản lý thiết bị di động (MDM) của bạn, hoặc từ một file trên đĩa. Các thiết lập này kiểm soát những tool, lệnh, server và đích mạng nào mà Claude có thể tiếp cận.

Trang này hướng dẫn tuần tự qua các quyết định triển khai. Mỗi hàng liên kết đến phần tương ứng bên dưới và đến trang tham chiếu cho lĩnh vực đó.

<Note>
  SSO, cấp phát tài khoản qua SCIM và gán ghế (seat) được cấu hình ở cấp tài khoản Claude. Xem [Hướng dẫn dành cho Quản trị viên Claude Enterprise](https://claude.com/resources/tutorials/claude-enterprise-administrator-guide) và [gán ghế](https://support.claude.com/en/articles/11845131-use-claude-code-with-your-team-or-enterprise-plan) cho các bước này.
</Note>

| Quyết định                                                              | Bạn đang chọn gì                                    | Tham chiếu                                                                                                                                                                     |
| :---------------------------------------------------------------------- | :-------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Chọn nhà cung cấp API của bạn](#choose-your-api-provider)              | Nơi Claude Code xác thực và cách nó được tính phí   | [Authentication](/en/authentication), [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry) |
| [Quyết định cách thiết lập đến được thiết bị](#decide-how-settings-reach-devices) | Cách chính sách được quản lý đến được máy của lập trình viên | [Server-managed settings](/en/server-managed-settings), [Settings files](/en/settings#settings-files)                                                                         |
| [Quyết định điều gì cần thực thi](#decide-what-to-enforce)              | Những tool, lệnh và tích hợp nào được cho phép      | [Permissions](/en/permissions), [Sandboxing](/en/sandboxing)                                                                                                                  |
| [Thiết lập khả năng quan sát mức sử dụng](#set-up-usage-visibility)     | Cách bạn theo dõi chi tiêu và mức độ áp dụng        | [Analytics](/en/analytics), [Monitoring](/en/monitoring-usage), [Costs](/en/costs)                                                                                            |
| [Xem xét việc xử lý dữ liệu](#review-data-handling)                     | Chính sách lưu giữ dữ liệu và trạng thái tuân thủ   | [Data usage](/en/data-usage), [Security](/en/security)                                                                                                                        |

## Chọn nhà cung cấp API của bạn

Claude Code kết nối tới Claude thông qua một trong nhiều nhà cung cấp API. Lựa chọn của bạn ảnh hưởng đến việc tính phí, xác thực, trạng thái tuân thủ mà bạn kế thừa, và những tính năng Claude Code nào mà lập trình viên của bạn có thể dùng.

| Nhà cung cấp                  | Chọn khi                                                                                                                             |
| :---------------------------- | :--------------------------------------------------------------------------------------------------------------------------------- |
| Claude for Teams / Enterprise | Bạn muốn Claude Code và claude.ai nằm chung một đăng ký tính theo ghế mà không phải vận hành hạ tầng nào. Đây là khuyến nghị mặc định. |
| Claude Console                | Bạn ưu tiên API hoặc muốn tính phí theo mức dùng (pay-as-you-go)                                                                     |
| Amazon Bedrock                | Bạn muốn kế thừa các kiểm soát tuân thủ và cách tính phí sẵn có của AWS                                                              |
| Google Cloud's Agent Platform | Bạn muốn kế thừa các kiểm soát tuân thủ và cách tính phí sẵn có của GCP                                                              |
| Microsoft Foundry             | Bạn muốn kế thừa các kiểm soát tuân thủ và cách tính phí sẵn có của Azure                                                            |

Một số tính năng Claude Code yêu cầu tài khoản claude.ai. [Claude Code on the web](/en/claude-code-on-the-web), [Routines](/en/routines), [Code Review](/en/code-review), [Remote Control](/en/remote-control), và [Chrome extension](/en/chrome) không khả dụng nếu chỉ dùng Console API keys hoặc thông tin đăng nhập của nhà cung cấp đám mây. Nếu bạn triển khai qua Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry, hãy cân nhắc xem lập trình viên có cần thêm ghế Claude for Teams hoặc Enterprise hay không. Mỗi trang tính năng liệt kê yêu cầu về gói của nó.

Để xem so sánh đầy đủ giữa các nhà cung cấp về xác thực, khu vực (regions), và tính tương đương về tính năng, xem [tổng quan triển khai doanh nghiệp](/en/third-party-integrations). Thiết lập xác thực của mỗi nhà cung cấp có trong [Authentication](/en/authentication).

Yêu cầu về proxy và firewall trong [Network configuration](/en/network-config) áp dụng bất kể nhà cung cấp nào. Nếu bạn muốn một endpoint duy nhất đứng trước nhiều nhà cung cấp hoặc ghi log yêu cầu tập trung, xem [LLM gateway](/en/llm-gateway).

## Quyết định cách thiết lập đến được thiết bị

Managed settings định nghĩa chính sách vốn được ưu tiên hơn cấu hình cục bộ của lập trình viên. Claude Code kiểm tra bốn nguồn dưới đây theo thứ tự ưu tiên và áp dụng nguồn đầu tiên trả về một cấu hình không rỗng, với một ngoại lệ: một tập nhỏ các [khóa khóa liên nguồn (cross-source lock keys)](/en/settings#settings-precedence), chẳng hạn như các khóa (lock) danh sách cho phép của sandbox, được tôn trọng khi bất kỳ nguồn nào do admin kiểm soát thiết lập chúng.

| Cơ chế                  | Cách phân phối                                                                                                                                                                                       | Ưu tiên  | Nền tảng       |
| :---------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------- | :------------- |
| Server-managed          | claude.ai admin console, hoặc một [Claude apps gateway](/en/claude-apps-gateway) tự lưu trữ cho việc đăng nhập qua gateway                                                                             | Cao nhất | Tất cả         |
| plist / registry policy | macOS: `com.anthropic.claudecode` plist<br />Windows: `HKLM\SOFTWARE\Policies\ClaudeCode`                                                                                                             | Cao      | macOS, Windows |
| File-based managed      | macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`<br />Linux và WSL: `/etc/claude-code/managed-settings.json`<br />Windows: `C:\Program Files\ClaudeCode\managed-settings.json`  | Trung bình | Tất cả       |
| Windows user registry   | `HKCU\SOFTWARE\Policies\ClaudeCode`                                                                                                                                                                   | Thấp nhất | Chỉ Windows   |

Một [`policyHelper`](/en/settings#compute-managed-settings-with-a-policy-helper) đã được cấu hình sẽ chiếm quyền trước cả bốn nguồn: đầu ra của nó trở thành cấu hình được quản lý duy nhất cho lần chạy đó. Xem [Thứ tự ưu tiên của settings](/en/settings#settings-precedence).

Server-managed settings đến được thiết bị vào thời điểm xác thực và làm mới mỗi giờ trong các phiên đang hoạt động, không cần hạ tầng endpoint. Việc phân phối qua claude.ai admin console yêu cầu gói Claude for Teams hoặc Enterprise. Các triển khai trên Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry có thể nhận cùng phương thức phân phối từ xa bằng cách chạy một [Claude apps gateway](/en/claude-apps-gateway), hoặc dùng một trong các cơ chế dựa trên file hoặc cấp hệ điều hành thay thế.

Nếu tổ chức của bạn dùng lẫn nhiều nhà cung cấp, hãy cấu hình [server-managed settings](/en/server-managed-settings) cho người dùng claude.ai cùng với một [dự phòng dựa trên file hoặc plist/registry](/en/settings#settings-files) để những người dùng khác vẫn nhận được chính sách được quản lý.

Vị trí plist và HKLM registry hoạt động với mọi nhà cung cấp và chống bị can thiệp vì chúng yêu cầu quyền admin để ghi. Windows user registry tại HKCU có thể ghi mà không cần nâng quyền, nên hãy xem nó như một mặc định tiện lợi thay vì một kênh thực thi.

Theo mặc định, WSL chỉ đọc đường dẫn file Linux tại `/etc/claude-code`. Để mở rộng chính sách của Windows registry và `C:\Program Files\ClaudeCode` sang WSL trên cùng máy, hãy đặt [`wslInheritsWindowsSettings: true`](/en/settings#available-settings) ở một trong hai nguồn Windows chỉ dành cho admin đó.

Dù bạn chọn cơ chế nào, các giá trị được quản lý vẫn được ưu tiên hơn thiết lập của người dùng và của dự án. Các thiết lập dạng mảng như `permissions.allow` và `permissions.deny` gộp các mục từ tất cả các nguồn, nên lập trình viên có thể mở rộng danh sách được quản lý nhưng không thể xóa khỏi chúng. Với [hai ngoại lệ](/en/settings#settings-precedence), `fallbackModel` và `availableModels`, giá trị được quản lý sẽ thay thế các lớp thấp hơn thay vì gộp lại.

Xem [Server-managed settings](/en/server-managed-settings) và [Settings files và thứ tự ưu tiên](/en/settings#settings-files).

## Quyết định điều gì cần thực thi

Managed settings có thể khóa chặt các tool, thực thi trong sandbox, hạn chế các MCP server và nguồn plugin, và kiểm soát những hook nào được chạy. Mỗi hàng là một bề mặt kiểm soát cùng với các khóa thiết lập điều khiển nó.

| Kiểm soát                                                                              | Chức năng                                                                                                                                                                                                                                                  | Các thiết lập chính                                                                                          |
| :------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------- |
| [Quy tắc quyền (permission rules)](/en/permissions)                                    | Cho phép, hỏi, hoặc từ chối các tool và lệnh cụ thể                                                                                                                                                                                                        | `permissions.allow`, `permissions.deny`                                                                      |
| [Khóa chặt quyền](/en/permissions#managed-only-settings)                               | Chỉ các quy tắc quyền được quản lý mới áp dụng; vô hiệu hóa `--dangerously-skip-permissions`                                                                                                                                                              | `allowManagedPermissionRulesOnly`, `permissions.disableBypassPermissionsMode`                                |
| [Sandboxing](/en/sandboxing)                                                           | Cô lập hệ thống file và mạng ở cấp hệ điều hành với danh sách cho phép tên miền                                                                                                                                                                            | `sandbox.enabled`, `sandbox.network.allowedDomains`                                                          |
| [CLAUDE.md chính sách được quản lý](/en/memory#deploy-organization-wide-claude-md)     | Hướng dẫn phạm vi toàn tổ chức được nạp trong mọi phiên, không thể loại trừ                                                                                                                                                                                | File tại đường dẫn chính sách được quản lý                                                                    |
| [Kiểm soát MCP server](/en/managed-mcp)                                                | Hạn chế những MCP server nào người dùng có thể thêm hoặc kết nối tới, hoặc triển khai một tập cố định                                                                                                                                                       | `allowedMcpServers`, `deniedMcpServers`, `allowManagedMcpServersOnly`, hoặc một file `managed-mcp.json` đã triển khai |
| [Kiểm soát plugin marketplace](/en/plugin-marketplaces#managed-marketplace-restrictions) | Hạn chế những nguồn marketplace nào người dùng có thể thêm và cài đặt từ đó, và từ chối các cờ CLI dùng để nạp thêm (sideload) plugin, agent và MCP server cho một lần chạy duy nhất                                                                        | `strictKnownMarketplaces`, `blockedMarketplaces`, `disableSideloadFlags`                                     |
| [Khóa chặt tùy biến](/en/settings#strictpluginonlycustomization)                       | Chặn skill, agent, hook và MCP server từ các nguồn của người dùng và dự án, để chúng chỉ có thể đến từ plugin hoặc managed settings                                                                                                                        | `strictPluginOnlyCustomization`                                                                              |
| [Hạn chế hook](/en/settings#hook-configuration)                                        | Chỉ các hook được quản lý mới được nạp; hạn chế URL của HTTP hook                                                                                                                                                                                          | `allowManagedHooksOnly`, `allowedHttpHookUrls`                                                               |
| [Vô hiệu hóa agent view](/en/agent-view#how-background-sessions-are-hosted)            | Tắt `claude agents`, `--bg`, `/background`, và supervisor theo yêu cầu                                                                                                                                                                                      | `disableAgentView`                                                                                           |
| [Hạn chế model](/en/model-config#restrict-model-selection)                             | `availableModels` lọc những model nào xuất hiện trong bộ chọn. Thêm `enforceAvailableModels` cũng ràng buộc model mặc định được chọn tự động. Xem [phạm vi bề mặt (surface coverage)](/en/model-config#surface-coverage) để biết cách thiết lập này đến được CLI, web và IDE | `availableModels`, `enforceAvailableModels`                                                                  |
| [Ngưỡng phiên bản tối thiểu](/en/settings)                                             | Ngăn tự động cập nhật cài đặt phiên bản thấp hơn mức tối thiểu toàn tổ chức                                                                                                                                                                                | `minimumVersion`                                                                                             |
| [Khoảng phiên bản bắt buộc](/en/settings)                                              | Từ chối khởi động hoàn toàn khi phiên bản đang chạy nằm ngoài khoảng được tổ chức phê duyệt. Mạnh hơn `minimumVersion`, vốn chỉ chặn hạ cấp                                                                                                                | `requiredMinimumVersion`, `requiredMaximumVersion`                                                           |

Các tổ chức có thành viên xác thực qua claude.ai hoặc Anthropic API cũng có thể quản trị model mà không cần triển khai thiết lập: [hạn chế model của tổ chức](/en/model-config#organization-model-restrictions) vô hiệu hóa từng model riêng lẻ, một [model mặc định của tổ chức](/en/model-config#organization-default-model) đặt model mà các phiên mới bắt đầu với nó, và [giới hạn effort của tổ chức](/en/model-config#organization-effort-limits) giới hạn mức effort theo từng vai trò. Cả ba kiểm soát này đều yêu cầu gói Claude Enterprise. Hạn chế model và giới hạn effort được thực thi ở phía server; model mặc định là điểm khởi đầu mà người dùng có thể thay đổi, trừ khi tổ chức thực thi nó. Việc thực thi chỉ khả dụng cho một số tổ chức nhất định; hãy hỏi đội ngũ phụ trách tài khoản Anthropic của bạn về khả dụng. Không kiểm soát nào trong số này đến được các phiên trên Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, hoặc [Claude Platform on AWS](/en/claude-platform-on-aws); trên những nhà cung cấp đó, hãy dùng `availableModels` ở trên để hạn chế và khóa `model` trong managed settings cho model mặc định.

Quy tắc quyền và sandboxing bao phủ các lớp khác nhau. Từ chối WebFetch chặn tool fetch của Claude, nhưng nếu Bash được cho phép, `curl` và `wget` vẫn có thể tiếp cận bất kỳ URL nào. Sandboxing bịt lỗ hổng đó bằng một danh sách cho phép tên miền mạng được thực thi ở cấp hệ điều hành.

Về mô hình mối đe dọa mà những kiểm soát này phòng vệ, xem [Security](/en/security).

## Thiết lập khả năng quan sát mức sử dụng

Chọn cách giám sát dựa trên những gì bạn cần báo cáo.

| Khả năng            | Bạn nhận được gì                                     | Khả dụng                                                                                                                                                                  | Bắt đầu từ đâu                            |
| :------------------ | :-------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------- |
| Giám sát mức sử dụng | Xuất qua OpenTelemetry các phiên, tool và token      | Tất cả nhà cung cấp                                                                                                                                                       | [Monitoring usage](/en/monitoring-usage) |
| Bảng điều khiển analytics | Số liệu theo từng người dùng, theo dõi đóng góp, bảng xếp hạng | Chỉ Anthropic                                                                                                                                                             | [Analytics](/en/analytics)               |
| Theo dõi chi phí     | Giới hạn chi tiêu, giới hạn tốc độ, và quy gán mức sử dụng | Anthropic; trên các đám mây bên thứ ba, một [Claude apps gateway](/en/claude-apps-gateway) cung cấp quy gán theo từng người dùng và [giới hạn chi tiêu](/en/claude-apps-gateway-spend-limits) | [Costs](/en/costs)                       |

Các nhà cung cấp đám mây bộc lộ chi tiêu qua AWS Cost Explorer, GCP Billing, hoặc Azure Cost Management. Các gói Claude for Teams và Enterprise bao gồm một bảng điều khiển mức sử dụng tại [claude.ai/analytics/claude-code](https://claude.ai/analytics/claude-code).

## Xem xét việc xử lý dữ liệu

Trên các gói Team, Enterprise, Claude API và nhà cung cấp đám mây, Anthropic không huấn luyện model trên mã hoặc prompt của bạn. Nhà cung cấp API của bạn quyết định chính sách lưu giữ và trạng thái tuân thủ.

| Chủ đề                    | Điều cần biết                                                                                        | Bắt đầu từ đâu                                  |
| :------------------------ | :--------------------------------------------------------------------------------------------------- | :--------------------------------------------- |
| Chính sách sử dụng dữ liệu | Anthropic thu thập những gì, lưu giữ trong bao lâu, những gì không bao giờ được dùng để huấn luyện    | [Data usage](/en/data-usage)                   |
| Zero Data Retention (ZDR) | Không lưu gì sau khi yêu cầu hoàn tất. Khả dụng cho các tài khoản đủ điều kiện trên Claude for Enterprise | [Zero data retention](/en/zero-data-retention) |
| Kiến trúc bảo mật         | Mô hình mạng, mã hóa, xác thực, dấu vết kiểm toán (audit trail)                                       | [Security](/en/security)                       |

Nếu bạn cần ghi log kiểm toán ở cấp yêu cầu hoặc định tuyến lưu lượng theo độ nhạy cảm của dữ liệu, hãy đặt một gateway giữa lập trình viên và nhà cung cấp của bạn: một [Claude apps gateway](/en/claude-apps-gateway) tự lưu trữ ghi lại log kiểm toán theo từng yêu cầu cùng danh tính IdP, hoặc dùng một [LLM gateway](/en/llm-gateway) khác. Về các yêu cầu pháp lý và chứng nhận, xem [Pháp lý và tuân thủ](/en/legal-and-compliance).

## Xác minh và giới thiệu (onboard)

Sau khi cấu hình managed settings, hãy để một lập trình viên chạy `/status` bên trong Claude Code. Trên tab **Status**, dòng `Setting sources` hiển thị `Enterprise managed settings` theo sau là nguồn trong ngoặc đơn, một trong `(remote)`, `(plist)`, `(HKLM)`, `(HKCU)`, hoặc `(file)`. Xem [Xác minh các thiết lập đang hoạt động](/en/settings#verify-active-settings).

Chia sẻ các tài nguyên sau để giúp lập trình viên bắt đầu:

* [Quickstart](/en/quickstart): hướng dẫn phiên đầu tiên từ cài đặt đến làm việc với một dự án
* [Common workflows](/en/common-workflows): các mẫu cho công việc hằng ngày như review mã, refactor và gỡ lỗi
* [Claude 101](https://anthropic.skilljar.com/claude-101) và [Claude Code in Action](https://anthropic.skilljar.com/claude-code-in-action): các khóa học tự học của Anthropic Academy

Với các vấn đề đăng nhập, hãy hướng dẫn lập trình viên đến [khắc phục sự cố xác thực](/en/troubleshoot-install#login-and-authentication). Các cách khắc phục phổ biến nhất là:

* Chạy `/logout` rồi `/login` để chuyển tài khoản
* Chạy `claude update` nếu thiếu tùy chọn xác thực doanh nghiệp
* Khởi động lại terminal sau khi cập nhật

Nếu một lập trình viên thấy "You haven't been added to your organization yet," thì ghế của họ không bao gồm quyền truy cập Claude Code và cần được cập nhật trong admin console.

## Các bước tiếp theo

Sau khi đã chọn nhà cung cấp và cơ chế phân phối, hãy chuyển sang cấu hình chi tiết:

* [Server-managed settings](/en/server-managed-settings): phân phối chính sách được quản lý từ Claude admin console
* [Settings reference](/en/settings): mọi khóa thiết lập, vị trí file và quy tắc thứ tự ưu tiên
* [Monorepos và repo lớn](/en/large-codebases): các mẫu cấu hình theo từng thư mục cho các tổ chức triển khai vào monorepo
* [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry): triển khai theo từng nhà cung cấp
* [Hướng dẫn dành cho Quản trị viên Claude Enterprise](https://claude.com/resources/tutorials/claude-enterprise-administrator-guide): SSO, SCIM, quản lý ghế và kịch bản triển khai
