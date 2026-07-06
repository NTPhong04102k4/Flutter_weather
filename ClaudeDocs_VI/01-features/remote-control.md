> Nguồn: https://code.claude.com/docs/en/remote-control.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tiếp tục các phiên cục bộ từ bất kỳ thiết bị nào với Remote Control

> Tiếp tục một phiên Claude Code cục bộ từ điện thoại, máy tính bảng, hoặc bất kỳ trình duyệt nào bằng Remote Control. Hoạt động với claude.ai/code và ứng dụng di động Claude.

<Note>
  Remote Control đang ở dạng research preview và khả dụng trên mọi gói dịch vụ. Trên Team và Enterprise, nó bị tắt theo mặc định cho đến khi một Owner bật nút chuyển Remote Control trong [cài đặt quản trị Claude Code](https://claude.ai/admin-settings/claude-code).
</Note>

Remote Control kết nối [claude.ai/code](https://claude.ai/code) hoặc ứng dụng Claude cho [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) và [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude) với một phiên Claude Code đang chạy trên máy của bạn. Bắt đầu một tác vụ tại bàn làm việc, sau đó tiếp tục nó từ điện thoại trên ghế sofa hoặc từ một trình duyệt trên máy tính khác.

Khi bạn bắt đầu một phiên Remote Control trên máy của mình, Claude tiếp tục chạy cục bộ suốt thời gian đó, nên không có gì chuyển lên cloud. Với Remote Control bạn có thể:

* **Sử dụng toàn bộ môi trường cục bộ của bạn từ xa**: hệ thống tệp, các [máy chủ MCP](/en/mcp), công cụ, và cấu hình dự án của bạn đều vẫn khả dụng, và gõ `@` tự động hoàn thành các đường dẫn tệp từ dự án cục bộ của bạn
* **Làm việc từ cả hai bề mặt cùng lúc**: cuộc hội thoại được đồng bộ trên tất cả các thiết bị được kết nối, nên bạn có thể gửi tin nhắn từ terminal, trình duyệt, và điện thoại của bạn một cách hoán đổi
* **Sống sót qua các gián đoạn**: nếu laptop của bạn ngủ hoặc mạng của bạn rớt, phiên tự động kết nối lại khi máy của bạn trở lại trực tuyến

Không giống như [Claude Code trên web](/en/claude-code-on-the-web), vốn chạy trên hạ tầng cloud, các phiên Remote Control chạy trực tiếp trên máy của bạn và tương tác với hệ thống tệp cục bộ của bạn. Các giao diện web và di động chỉ là một cửa sổ nhìn vào phiên cục bộ đó.

<Note>
  Remote Control yêu cầu Claude Code v2.1.51 trở lên. Kiểm tra phiên bản của bạn bằng `claude --version`.
</Note>

Trang này bao gồm thiết lập, cách bắt đầu và kết nối đến các phiên, và cách Remote Control so sánh với Claude Code trên web.

## Yêu cầu

Trước khi sử dụng Remote Control, hãy xác nhận rằng môi trường của bạn đáp ứng các điều kiện sau:

* **Gói đăng ký**: khả dụng trên các gói Pro, Max, Team, và Enterprise. Các API key không được hỗ trợ. Trên Team và Enterprise, một Owner phải bật nút chuyển Remote Control trong [cài đặt quản trị Claude Code](https://claude.ai/admin-settings/claude-code) trước.
* **Xác thực**: chạy `claude` và dùng `/login` để đăng nhập qua claude.ai nếu bạn chưa làm.
* **Endpoint API**: không khả dụng trên Amazon Bedrock, Agent Platform của Google Cloud, hay Microsoft Foundry. {/* min-version: 2.1.196 */}Kể từ v2.1.196, Remote Control cũng bị vô hiệu hóa khi [`ANTHROPIC_BASE_URL`](/en/env-vars) trỏ đến một host khác `api.anthropic.com`, chẳng hạn như một [LLM gateway](/en/llm-gateway) hoặc proxy. Bỏ đặt biến để sử dụng Remote Control.
* **Tin cậy workspace**: chạy `claude` trong thư mục dự án của bạn ít nhất một lần để chấp nhận hộp thoại tin cậy workspace.

## Bắt đầu một phiên Remote Control

Bạn có thể bắt đầu một phiên Remote Control từ CLI hoặc từ tiện ích mở rộng VS Code. CLI cung cấp ba chế độ gọi; VS Code sử dụng lệnh `/remote-control`.

<Tabs>
  <Tab title="Chế độ máy chủ (Server mode)">
    Điều hướng đến thư mục dự án của bạn và chạy:

    ```bash theme={null}
    claude remote-control
    ```

    Tiến trình tiếp tục chạy trong terminal của bạn ở chế độ máy chủ, chờ các kết nối từ xa. Nó hiển thị một URL phiên mà bạn có thể dùng để [kết nối từ một thiết bị khác](#connect-from-another-device), và bạn có thể nhấn phím cách để hiển thị mã QR để truy cập nhanh từ điện thoại của bạn. Trong khi một phiên từ xa đang hoạt động, terminal hiển thị trạng thái kết nối và hoạt động của công cụ.

    Các flag khả dụng:

    | Flag                                            | Mô tả                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `--name "My Project"`                           | Đặt tiêu đề phiên tùy chỉnh hiển thị trong danh sách phiên tại claude.ai/code.                                                                                                                                                                                                                                                                                                                                                                                                     |
    | `--remote-control-session-name-prefix <prefix>` | Tiền tố cho tên phiên tự động tạo khi không đặt tên rõ ràng. Mặc định là hostname của máy bạn, tạo ra các tên như `myhost-graceful-unicorn`. Đặt `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` cho cùng hiệu ứng.                                                                                                                                                                                                                                                                    |
    | `-c`, `--continue`                              | {/* min-version: 2.1.200 */}Tiếp tục phiên Remote Control gần nhất được bắt đầu từ thư mục này thay vì tạo một phiên mới. Không thể kết hợp với `--session-id`, `--spawn`, `--capacity`, hoặc `--create-session-in-dir`. Yêu cầu Claude Code v2.1.200 trở lên; các phiên bản trước từ chối flag này như một đối số không xác định.                                                                                                                                                    |
    | `--session-id <id>`                             | {/* min-version: 2.1.200 */}Tiếp tục một phiên Remote Control cụ thể theo ID của nó. Không thể kết hợp với `--continue`, `--spawn`, `--capacity`, hoặc `--create-session-in-dir`. Yêu cầu Claude Code v2.1.200 trở lên; các phiên bản trước từ chối flag này như một đối số không xác định.                                                                                                                                                                                          |
    | `--spawn <mode>`                                | Cách máy chủ tạo các phiên.<br />• `same-dir` (mặc định): tất cả các phiên chia sẻ thư mục làm việc hiện tại, nên chúng có thể xung đột nếu chỉnh sửa cùng các tệp.<br />• `worktree`: mỗi phiên theo yêu cầu nhận một [git worktree](/en/worktrees) riêng. Yêu cầu một kho git.<br />• `session`: chế độ phiên đơn. Phục vụ đúng một phiên và từ chối các kết nối bổ sung. Chỉ đặt được khi khởi động.<br />Nhấn `w` tại thời điểm chạy để chuyển đổi giữa `same-dir` và `worktree`. |
    | `--capacity <N>`                                | Số phiên đồng thời tối đa. Mặc định là 32. Không thể dùng với `--spawn=session`.                                                                                                                                                                                                                                                                                                                                                                                                   |
    | `--[no-]create-session-in-dir`                  | Tạo trước một phiên trong thư mục hiện tại khi máy chủ khởi động, để bạn có nơi để gõ ngay lập tức. Ở chế độ `worktree`, phiên này ở lại thư mục hiện tại trong khi các phiên theo yêu cầu nhận các worktree riêng biệt. Bật theo mặc định; truyền `--no-create-session-in-dir` để khởi động mà không có phiên nào.                                                                                                                                                                  |
    | `--verbose`                                     | Hiển thị nhật ký kết nối và phiên chi tiết.                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    | `--sandbox` / `--no-sandbox`                    | Bật hoặc tắt [sandboxing](/en/sandboxing) để cô lập hệ thống tệp và mạng. Tắt theo mặc định.                                                                                                                                                                                                                                                                                                                                                                                       |
  </Tab>

  <Tab title="Phiên tương tác (Interactive session)">
    Để bắt đầu một phiên Claude Code tương tác bình thường với Remote Control được bật, dùng flag `--remote-control` (hoặc `--rc`):

    ```bash theme={null}
    claude --remote-control
    ```

    Tùy chọn truyền một tên cho phiên:

    ```bash theme={null}
    claude --remote-control "My Project"
    ```

    Điều này cho bạn một phiên tương tác đầy đủ trong terminal của bạn mà bạn cũng có thể điều khiển từ claude.ai hoặc ứng dụng Claude. Không giống `claude remote-control` (chế độ máy chủ), bạn có thể gõ tin nhắn cục bộ trong khi phiên cũng khả dụng từ xa.
  </Tab>

  <Tab title="Từ một phiên đang có">
    Nếu bạn đang ở trong một phiên Claude Code và muốn tiếp tục nó từ xa, dùng lệnh `/remote-control` (hoặc `/rc`):

    ```text theme={null}
    /remote-control
    ```

    Truyền một tên làm đối số để đặt tiêu đề phiên tùy chỉnh:

    ```text theme={null}
    /remote-control My Project
    ```

    Điều này bắt đầu một phiên Remote Control mang theo lịch sử cuộc hội thoại hiện tại của bạn.

    Các flag `--verbose`, `--sandbox`, và `--no-sandbox` không khả dụng với lệnh này.
  </Tab>

  <Tab title="VS Code">
    Trong [tiện ích mở rộng Claude Code VS Code](/en/vs-code), gõ `/remote-control` hoặc `/rc` trong ô prompt, hoặc mở menu lệnh bằng `/` và chọn nó. Yêu cầu Claude Code v2.1.79 trở lên.

    ```text theme={null}
    /remote-control
    ```

    Một banner xuất hiện phía trên ô prompt hiển thị trạng thái kết nối. Sau khi kết nối, nhấp **Open in browser** trong banner để đi trực tiếp đến phiên, hoặc tìm nó trong danh sách phiên tại [claude.ai/code](https://claude.ai/code). URL phiên cũng được đăng trong cuộc hội thoại.

    Để ngắt kết nối, nhấp biểu tượng đóng trên banner hoặc chạy `/remote-control` lại.

    Không giống CLI, lệnh VS Code không chấp nhận đối số tên hoặc hiển thị mã QR. Tiêu đề phiên được suy ra từ lịch sử cuộc hội thoại hoặc prompt đầu tiên của bạn.
  </Tab>
</Tabs>

### Kiểm tra trạng thái kết nối

Trong một phiên terminal tương tác, một chỉ báo `/rc active` nằm ở footer bên dưới ô nhập liệu trong khi kết nối đang hoạt động, và bị ẩn nếu terminal quá hẹp để vừa nó. Văn bản chỉ báo là một liên kết đến phiên trên claude.ai. Chọn nó bằng phím mũi tên xuống và nhấn Enter, hoặc chạy `/remote-control` lại, để mở một bảng trạng thái với URL phiên và mã QR mà bạn có thể dùng để [kết nối từ một thiết bị khác](#connect-from-another-device).

Nếu kết nối thất bại, một thông báo xuất hiện với lý do thất bại và chỉ báo biến mất khỏi footer. Chạy `/remote-control` lại để thử lại.

### Kết nối từ một thiết bị khác

Khi một phiên Remote Control đang hoạt động, bạn có một vài cách để kết nối từ một thiết bị khác:

* **Mở URL phiên** trong bất kỳ trình duyệt nào để đi trực tiếp đến phiên trên [claude.ai/code](https://claude.ai/code).
* **Quét mã QR** hiển thị bên cạnh URL phiên để mở nó trực tiếp trong ứng dụng Claude. Với `claude remote-control`, nhấn phím cách để bật/tắt hiển thị mã QR.
* **Mở [claude.ai/code](https://claude.ai/code) hoặc ứng dụng Claude** và tìm phiên theo tên trong danh sách phiên. Trong ứng dụng di động Claude, chạm **Code** trong thanh điều hướng để đến danh sách phiên. Các phiên Remote Control hiển thị một biểu tượng máy tính với một chấm trạng thái xanh khi trực tuyến.

Tiêu đề phiên từ xa được chọn theo thứ tự này:

1. Tên bạn đã truyền cho `--name`, `--remote-control`, hoặc `/remote-control`
2. Tiêu đề bạn đặt bằng `/rename`
3. Tin nhắn có ý nghĩa cuối cùng trong lịch sử cuộc hội thoại hiện có
4. Một tên tự động tạo như `myhost-graceful-unicorn`, trong đó `myhost` là hostname của máy bạn hoặc tiền tố bạn đặt bằng `--remote-control-session-name-prefix`

Nếu bạn không đặt một tên rõ ràng, tiêu đề cập nhật để phản ánh prompt của bạn sau khi bạn gửi một cái. {/* min-version: 2.1.176 */}Kể từ Claude Code v2.1.176, các tiêu đề tự động tạo khớp với ngôn ngữ cuộc hội thoại của bạn, hoặc cài đặt [`language`](/en/settings#available-settings) nếu một cái được cấu hình. Đổi tên một phiên từ claude.ai hoặc ứng dụng Claude cũng cập nhật tiêu đề cục bộ hiển thị trong `claude --resume`.

Nếu môi trường đã có một phiên đang hoạt động, bạn sẽ được hỏi có muốn tiếp tục nó hay bắt đầu một phiên mới.

Nếu bạn chưa có ứng dụng Claude, dùng lệnh `/mobile` bên trong Claude Code để hiển thị một mã QR tải xuống cho [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) hoặc [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude).

### Bật Remote Control cho tất cả các phiên

Remote Control chỉ kích hoạt khi bạn chạy rõ ràng `claude remote-control`, `claude --remote-control`, hoặc `/remote-control`, trừ khi auto-connect được bật. Để bật nó tự động cho mọi phiên tương tác, chạy `/config` bên trong Claude Code và đặt **Enable Remote Control for all sessions** thành `true`. Đặt nó thành `false` để không bao giờ tự động kết nối, hoặc để trống nó để tuân theo mặc định của tổ chức bạn. Trong ứng dụng Desktop, bạn cũng có thể bật/tắt điều này từ **Settings → Claude Code → Enable remote control by default**.

Với cài đặt này bật, mỗi tiến trình Claude Code tương tác đăng ký một phiên từ xa. Nếu bạn chạy nhiều instance, mỗi cái nhận môi trường và phiên riêng của nó. Để chạy nhiều phiên đồng thời từ một tiến trình duy nhất, dùng [chế độ máy chủ](#start-a-remote-control-session) thay thế.

## Kết nối và bảo mật

Phiên Claude Code cục bộ của bạn chỉ thực hiện các yêu cầu HTTPS đi ra và không bao giờ mở các cổng đi vào trên máy của bạn. Khi bạn bắt đầu Remote Control, nó đăng ký với Anthropic API và thăm dò công việc. Khi bạn kết nối từ một thiết bị khác, máy chủ định tuyến các tin nhắn giữa client web hoặc di động và phiên cục bộ của bạn qua một kết nối streaming.

Tất cả lưu lượng đi qua Anthropic API qua TLS, cùng độ bảo mật vận chuyển như bất kỳ phiên Claude Code nào. Kết nối sử dụng nhiều thông tin xác thực ngắn hạn, mỗi cái được giới hạn phạm vi cho một mục đích duy nhất và hết hạn độc lập.

## Trusted Devices (Thiết bị được tin cậy)

<Note>
  Trusted Devices hiện đang ở dạng beta. Các tính năng và chức năng có thể phát triển khi trải nghiệm được tinh chỉnh.

  Trusted Devices khả dụng trên các gói Team và Enterprise. Nó bị tắt theo mặc định cho đến khi một quản trị viên bật nó.
</Note>

Trusted Devices là một cài đặt phạm vi toàn tổ chức yêu cầu các thành viên xác minh thiết bị của họ trước khi họ có thể xem hoặc điều khiển các phiên Remote Control từ claude.ai, các ứng dụng di động Claude, hoặc Claude Desktop. Nó ràng buộc quyền truy cập Remote Control với một thiết bị đã biết và một lần xác thực gần đây, không chỉ là một tài khoản đã đăng nhập.

Khi cài đặt này bật, việc tương tác với một phiên Remote Control yêu cầu cả hai điều sau:

* **Một thiết bị đã đăng ký (enrolled)**: mỗi trình duyệt, điện thoại, hoặc ứng dụng desktop mà một thành viên sử dụng cho Remote Control đăng ký thông tin xác thực riêng của nó. Việc đăng ký chỉ được đề nghị ngay sau một lần đăng nhập đầy đủ, nên một thiết bị gia nhập danh sách tin cậy như một phần của một lần xác thực thực sự thay vì âm thầm ở nền.
* **Một lần đăng nhập gần đây**: lần đăng nhập của thành viên phải không quá 18 giờ tuổi. Thay vì đăng nhập lại mỗi ngày, các thành viên xác nhận sự hiện diện bằng Face ID, Touch ID, Windows Hello, hoặc một passkey. Bước nâng cấp sinh trắc học này làm mới phiên ngay lập tức.

Các kiểm tra sinh trắc học chạy trên thiết bị thông qua hệ điều hành hoặc trình duyệt, cùng cơ chế như đăng nhập bằng passkey. Anthropic không bao giờ nhận hoặc lưu trữ dấu vân tay, dữ liệu khuôn mặt, hoặc bất kỳ thông tin sinh trắc học nào khác. Chỉ khóa công khai của thiết bị và siêu dữ liệu cơ bản như tên hiển thị, nền tảng, và thời gian đăng ký được lưu trữ.

Cài đặt chỉ áp dụng cho Remote Control. Trò chuyện Claude thông thường, Claude Code trong terminal, và việc sử dụng API không bị ảnh hưởng.

### Bật Trusted Devices cho tổ chức của bạn

Các quản trị viên bật cài đặt từ bảng điều khiển quản trị Claude Code.

<Steps>
  <Step title="Mở cài đặt quản trị Claude Code">
    Truy cập [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Nút chuyển **Require trusted devices** xuất hiện dưới cài đặt Remote Control.
  </Step>

  <Step title="Bật Require trusted devices">
    Cài đặt áp dụng cho mọi thành viên của tổ chức và cho các phiên Remote Control bắt đầu sau khi bạn bật nó. Các phiên đã đang chạy trước khi nút chuyển được bật không được bảo vệ hồi tố và tiếp tục mà không có yêu cầu thiết bị cho đến khi chúng kết thúc. Phạm vi theo từng nhóm hoặc từng dự án không khả dụng.
  </Step>

  <Step title="Cho các thành viên biết điều gì sẽ xảy ra">
    Lần đầu tiên một thành viên xem hoặc điều khiển một phiên Remote Control mới từ một trình duyệt, điện thoại, hoặc ứng dụng desktop sau khi cài đặt được bật, họ được nhắc đăng ký thiết bị đó. Cho họ biết trước sẽ tránh nhầm lẫn.
  </Step>
</Steps>

### Những gì các thành viên nhìn thấy

Việc đăng ký là một bước một lần cho mỗi thiết bị. Sau đó, thay đổi hiển thị duy nhất là một lời nhắc sinh trắc học thỉnh thoảng.

* **Lần đầu sử dụng trên mỗi thiết bị**: thành viên được yêu cầu đăng ký. Nếu lần đăng nhập của họ không gần đây, họ đăng nhập trước qua luồng thông thường của bạn, bao gồm SSO nếu được cấu hình, sau đó xác nhận đăng ký.
* **Hàng ngày**: các thành viên có một thiết bị đã đăng ký và một lần đăng nhập gần đây không thấy lời nhắc nào. Khi lần đăng nhập vượt quá 18 giờ tuổi, lần tương tác Remote Control tiếp theo hiển thị một lời nhắc Face ID, Touch ID, Windows Hello, hoặc passkey duy nhất.
* **Các thiết bị chưa đăng ký**: các phiên Remote Control không thể được xem hoặc điều khiển cho đến khi thiết bị được đăng ký. Trò chuyện Claude thông thường trên thiết bị đó không bị ảnh hưởng.
* **Không có trình xác thực nền tảng**: các thành viên trên một máy không có Face ID, Touch ID, hoặc Windows Hello có thể dùng một khóa bảo mật phần cứng, hoặc đăng nhập lại thay vì nâng cấp.
* **Trong terminal**: máy chạy Claude Code nhận thông tin xác thực riêng của nó một cách tự động khi nhà phát triển đăng nhập vào CLI. Không có bước đăng ký riêng biệt trong terminal.

### Quản lý các thiết bị đã đăng ký

Các thành viên có thể xem lại và thu hồi các thiết bị của chính họ từ cài đặt tài khoản.

Mở [claude.ai/settings/account](https://claude.ai/settings/account#trusted-devices) và tìm phần **Trusted devices** để xem mọi thiết bị đã đăng ký với tên, nền tảng, và ngày đăng ký của nó. Xóa một thiết bị sẽ thu hồi thông tin xác thực của nó ngay lập tức, và thiết bị có thể đăng ký lại sau đó sau một lần đăng nhập mới. Các thông tin xác thực cũng tự hết hạn nếu không được gia hạn, nên một thiết bị không dùng đến sẽ tự động rời khỏi danh sách tin cậy.

Đối với một thiết bị bị mất hoặc bị đánh cắp, thành viên xóa nó khỏi trang này. Nếu thành viên không thể đăng nhập, một quản trị viên có thể dùng **Sign out everywhere** trong bảng điều khiển quản trị để thu hồi mọi phiên và thiết bị đã đăng ký cho thành viên đó, sau đó thành viên đăng ký lại các thiết bị mà họ vẫn còn giữ.

## Remote Control so với Claude Code trên web

Remote Control và [Claude Code trên web](/en/claude-code-on-the-web) đều sử dụng giao diện claude.ai/code. Khác biệt chính là nơi phiên chạy: Remote Control thực thi trên máy của bạn, nên các máy chủ MCP, công cụ, và cấu hình dự án cục bộ của bạn vẫn khả dụng. Claude Code trên web thực thi trong hạ tầng cloud do Anthropic quản lý.

Dùng Remote Control khi bạn đang ở giữa công việc cục bộ và muốn tiếp tục từ một thiết bị khác. Dùng Claude Code trên web khi bạn muốn khởi động một tác vụ mà không cần bất kỳ thiết lập cục bộ nào, làm việc trên một repo bạn chưa clone, hoặc chạy nhiều tác vụ song song.

## Thông báo đẩy trên di động (Mobile push notifications)

Khi Remote Control đang hoạt động, Claude có thể gửi thông báo đẩy đến điện thoại của bạn.

Claude quyết định khi nào đẩy. Nó thường gửi một cái khi một tác vụ chạy lâu hoàn thành hoặc khi nó cần một quyết định từ bạn để tiếp tục. Bạn cũng có thể yêu cầu một thông báo đẩy trong prompt của bạn, ví dụ `notify me when the tests finish`. Ngoài hai nút bật/tắt bên dưới, không có cấu hình theo từng sự kiện.

<Note>
  Thông báo đẩy trên di động yêu cầu Claude Code v2.1.110 trở lên.
</Note>

Để thiết lập thông báo đẩy trên di động:

<Steps>
  <Step title="Cài đặt ứng dụng di động Claude">
    Tải ứng dụng Claude cho [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) hoặc [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude).
  </Step>

  <Step title="Đăng nhập bằng tài khoản Claude Code của bạn">
    Dùng cùng tài khoản và tổ chức bạn dùng cho Claude Code trong terminal.
  </Step>

  <Step title="Cho phép thông báo">
    Chấp nhận lời nhắc xin quyền thông báo từ hệ điều hành.
  </Step>

  <Step title="Bật đẩy trong Claude Code">
    Trong terminal của bạn, chạy `/config` và bật **Push when Claude decides** cho các thông báo chủ động, **Push when actions required** cho các lời nhắc xin quyền và các câu hỏi, hoặc cả hai.
  </Step>
</Steps>

Nếu thông báo không đến:

* Nếu `/config` hiển thị **No mobile registered**, hãy mở ứng dụng Claude trên điện thoại của bạn để nó có thể làm mới push token của nó. Cảnh báo sẽ được xóa trong lần tiếp theo Remote Control kết nối.
* Trên iOS, các chế độ Focus và các bản tóm tắt thông báo có thể chặn hoặc trì hoãn các thông báo đẩy. Kiểm tra Settings → Notifications → Claude.
* Trên Android, việc tối ưu hóa pin mạnh có thể trì hoãn việc gửi. Miễn trừ ứng dụng Claude khỏi tối ưu hóa pin trong cài đặt hệ thống.

Claude Code bỏ qua các thông báo đẩy trên di động khi bạn đang gõ trong hoặc đang tập trung vào terminal được kết nối. {/* min-version: 2.1.181 */}Kể từ v2.1.181, bạn có thể đặt [`CLAUDE_CLIENT_PRESENCE_FILE`](/en/env-vars) thành một đường dẫn tệp đánh dấu để mở rộng điều này đến bất kỳ lúc nào bạn đang ở máy, ngay cả trong một cửa sổ khác: các thông báo bị bỏ qua khi tệp tồn tại. Cấu hình một trình lắng nghe khóa màn hình hoặc công cụ tương tự để tạo tệp khi màn hình của bạn mở khóa và xóa nó khi màn hình của bạn khóa.

## Giới hạn

* **Một phiên từ xa cho mỗi tiến trình tương tác**: ngoài chế độ máy chủ, mỗi instance Claude Code hỗ trợ một phiên từ xa tại một thời điểm. Dùng [chế độ máy chủ](#start-a-remote-control-session) để chạy nhiều phiên đồng thời từ một tiến trình duy nhất.
* **Tiến trình cục bộ phải tiếp tục chạy**: Remote Control chạy như một tiến trình cục bộ. Nếu bạn đóng terminal, thoát VS Code, hoặc dừng tiến trình `claude` bằng cách khác, phiên kết thúc.
* **Sự cố mạng kéo dài**: nếu máy của bạn đang thức nhưng không thể tiếp cận mạng trong hơn khoảng 10 phút, phiên hết thời gian chờ và tiến trình thoát. Chạy `claude remote-control` lại để bắt đầu một phiên mới.
* **Ultraplan ngắt kết nối Remote Control**: bắt đầu một phiên [ultraplan](/en/ultraplan) sẽ ngắt kết nối bất kỳ phiên Remote Control đang hoạt động nào vì cả hai tính năng đều chiếm giao diện claude.ai/code và chỉ một cái có thể được kết nối tại một thời điểm.
* **Một số lệnh chỉ chạy cục bộ**: các lệnh mở một trình chọn tương tác trong terminal, chẳng hạn như `/plugin` hoặc `/resume`, chỉ hoạt động từ CLI cục bộ. Các lệnh sau hoạt động từ di động và web:
  * Các lệnh xuất văn bản: `/compact`, `/clear`, `/context`, `/usage`, `/exit`, `/usage-credits`, `/recap`, `/reload-plugins`
  * {/* min-version: 2.1.166 */}`/mcp`, từ v2.1.166: trả về một bản tóm tắt văn bản về trạng thái máy chủ thay vì mở trình chọn, và chấp nhận các [lệnh con (subcommand)](/en/commands#all-commands) `reconnect`, `enable`, và `disable`. Không giống CLI cục bộ, `/mcp reconnect` không có tên máy chủ sẽ kết nối lại mọi máy chủ đã thất bại hoặc cần xác thực.
  * {/* min-version: 2.1.181 */}`/config`, từ v2.1.181: truyền `key=value` để đặt một cài đặt, hoặc chạy nó không có đối số để liệt kê các khóa bạn có thể đặt.

## Xử lý sự cố

### "Remote Control requires a claude.ai subscription"

Bạn chưa được xác thực với một tài khoản claude.ai. Chạy `claude auth login` và chọn tùy chọn claude.ai. Nếu `ANTHROPIC_API_KEY` được đặt trong môi trường của bạn, hãy bỏ đặt nó trước.

### "Remote Control requires a full-scope login token"

Bạn được xác thực với một token dài hạn từ `claude setup-token` hoặc biến môi trường `CLAUDE_CODE_OAUTH_TOKEN`. Các token này bị giới hạn ở chỉ suy luận (inference-only) và không thể thiết lập các phiên Remote Control. Chạy `claude auth login` để xác thực với một session token phạm vi đầy đủ thay thế.

### "Unable to determine your organization for Remote Control eligibility"

Thông tin tài khoản được lưu bộ nhớ đệm của bạn đã cũ hoặc không đầy đủ. Chạy `claude auth login` để làm mới nó.

### "Remote Control is not yet enabled for your account"

Việc triển khai Remote Control chưa đến tài khoản của bạn, hoặc các quyền lợi được lưu bộ nhớ đệm của bạn đã lỗi thời. Nếu bạn gần đây đã đổi gói, hãy chạy `claude auth logout` rồi `claude auth login` để làm mới chúng. Chạy `claude doctor` để xem kiểm tra điều kiện cụ thể nào đã thất bại. Các xung đột biến môi trường, các kiểm tra không tiếp cận được, và chính sách tổ chức mỗi cái tạo ra thông báo riêng của nó, nên lỗi này có nghĩa là chính cổng triển khai (rollout gate).

### "Couldn't verify Remote Control eligibility"

Claude Code không thể tiếp cận dịch vụ feature-flag để kiểm tra xem Remote Control có được bật cho tài khoản của bạn hay không, thường vì bạn đang ngoại tuyến hoặc một proxy đang chặn yêu cầu. Thử lại khi bạn có quyền truy cập mạng, hoặc chạy `claude doctor` để biết chi tiết. Thông báo liên quan "Couldn't verify your organization's Remote Control policy" có cùng nguyên nhân và cùng cách khắc phục. Cả hai thông báo được thêm vào trong v2.1.178.

### "Remote Control is only available when using Claude via api.anthropic.com"

Phiên không nói chuyện trực tiếp với Anthropic API, nên không có backend claude.ai để ghép nối. Điều này xảy ra trên Amazon Bedrock, Agent Platform của Google Cloud, và Microsoft Foundry. {/* min-version: 2.1.196 */}Kể từ v2.1.196 nó cũng xảy ra khi [`ANTHROPIC_BASE_URL`](/en/env-vars) trỏ đến một host khác `api.anthropic.com`, chẳng hạn như một [LLM gateway](/en/llm-gateway) hoặc proxy, ngay cả khi bạn đăng nhập với claude.ai. Bỏ đặt `ANTHROPIC_BASE_URL` và khởi động lại phiên để sử dụng Remote Control.

### "Remote Control is disabled by your organization's policy"

Lỗi này có bốn nguyên nhân riêng biệt. Chạy `/status` trước để xem phương thức đăng nhập và gói đăng ký nào bạn đang dùng.

* **Bạn được xác thực với một API key hoặc tài khoản Console**: Remote Control yêu cầu claude.ai OAuth. Chạy `/login` và chọn tùy chọn claude.ai. Nếu `ANTHROPIC_API_KEY` được đặt trong môi trường của bạn, hãy bỏ đặt nó.
* **Một Owner chưa bật nó cho tổ chức của bạn**: Remote Control bị tắt theo mặc định trên các gói Team và Enterprise. Một Owner có thể bật nó tại [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) bằng cách bật nút chuyển **Remote Control**. Nút chuyển này là một cài đặt tổ chức phía máy chủ.
* **Nút chuyển quản trị bị làm mờ (grayed out)**: tổ chức của bạn có một cấu hình lưu giữ dữ liệu hoặc tuân thủ không tương thích với Remote Control. Điều này không thể được thay đổi từ bảng điều khiển quản trị. Liên hệ bộ phận hỗ trợ Anthropic để thảo luận các lựa chọn.
* **Lỗi đề cập đến `disableRemoteControl`**: quản trị viên IT của bạn đã tắt Remote Control trên thiết bị này thông qua [các cài đặt được quản lý (managed settings)](/en/settings#settings-files), độc lập với nút chuyển toàn tổ chức.

### "Remote credentials fetch failed"

Claude Code không thể lấy được một thông tin xác thực ngắn hạn từ Anthropic API để thiết lập kết nối. Chạy lại với `--verbose` để xem lỗi đầy đủ:

```bash theme={null}
claude remote-control --verbose
```

Các nguyên nhân phổ biến:

* Chưa đăng nhập: chạy `claude` và dùng `/login` để xác thực với tài khoản claude.ai của bạn. Xác thực bằng API key không được hỗ trợ cho Remote Control.
* Vấn đề mạng hoặc proxy: một tường lửa hoặc proxy có thể đang chặn yêu cầu HTTPS đi ra. Remote Control yêu cầu quyền truy cập đến Anthropic API trên cổng 443.
* Tạo phiên thất bại: nếu bạn cũng thấy `Session creation failed — see debug log`, sự cố đã xảy ra sớm hơn trong quá trình thiết lập. Kiểm tra rằng gói đăng ký của bạn đang hoạt động.

### "Couldn't reconnect to your Remote Control session"

Khi bạn tiếp tục một cuộc hội thoại bằng `claude --resume` hoặc `claude --continue`, Claude Code kết nối lại với phiên Remote Control được ghi lại trong cuộc hội thoại đó. Thông báo này có nghĩa là việc kết nối lại thất bại vì một lý do có thể là tạm thời, chẳng hạn như một gián đoạn mạng hoặc một lỗi máy chủ, nên Claude Code không thể xác nhận liệu phiên từ xa còn tồn tại hay không. Khi máy chủ xác nhận phiên trước đó không còn tồn tại, Claude Code tạo một phiên Remote Control mới mà không hiển thị thông báo này.

Phiên cục bộ của bạn tiếp tục chạy mà không có Remote Control. Chạy `/remote-control` để thử lại kết nối, hoặc khởi động Claude Code mà không có `--resume` để tạo một phiên Remote Control mới.

{/* min-version: 2.1.200 */}Trước v2.1.200, một lần thất bại kết nối lại sẽ tạo một phiên Remote Control mới thay vì hiển thị thông báo này, để lại các phiên thừa trong danh sách phiên tại claude.ai/code.

### "Your organization requires Trusted Devices for Remote Control, but this device is not enrolled"

Tổ chức của bạn đã bật [Trusted Devices](#trusted-devices) và máy này chưa đăng ký. Chạy `/login` trong Claude Code. Việc đăng ký diễn ra như một phần của đăng nhập, và không có lệnh đăng ký riêng biệt.

### "session expired for trusted-device check"

Lần đăng nhập của bạn đã hơn 18 giờ tuổi. Chạy `/login` trong Claude Code, hoặc xác nhận bằng Face ID, Touch ID, Windows Hello, hoặc một passkey khi claude.ai hoặc ứng dụng di động nhắc bạn. Xem [Trusted Devices](#trusted-devices).

## Chọn cách tiếp cận phù hợp

Claude Code cung cấp một số cách để làm việc khi bạn không ở terminal của mình. Chúng khác nhau ở điều gì kích hoạt công việc, nơi Claude chạy, và bạn cần thiết lập bao nhiêu.

|                                                | Kích hoạt                                                                                      | Claude chạy trên                                                                             | Thiết lập                                                                                                                             | Phù hợp nhất cho                                              |
| :--------------------------------------------- | :-------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------- |
| [Dispatch](/en/desktop#sessions-from-dispatch) | Nhắn một tác vụ từ ứng dụng di động Claude                                                     | Máy của bạn (Desktop)                                                                        | [Ghép ứng dụng di động với Desktop](https://support.claude.com/en/articles/13947068)                                                 | Ủy thác công việc khi bạn vắng mặt, thiết lập tối thiểu       |
| [Remote Control](/en/remote-control)           | Điều khiển một phiên đang chạy từ [claude.ai/code](https://claude.ai/code) hoặc ứng dụng di động Claude | Máy của bạn (CLI hoặc VS Code)                                                       | Chạy `claude remote-control`                                                                                                        | Điều khiển công việc đang tiến hành từ một thiết bị khác      |
| [Channels](/en/channels)                       | Đẩy các sự kiện từ một ứng dụng chat như Telegram hoặc Discord, hoặc máy chủ của riêng bạn     | Máy của bạn (CLI)                                                                            | [Cài đặt một channel plugin](/en/channels#quickstart) hoặc [tự xây dựng](/en/channels-reference)                                    | Phản ứng với các sự kiện bên ngoài như lỗi CI hoặc tin nhắn chat |
| [Slack](/en/slack)                             | Nhắc `@Claude` trong một kênh nhóm                                                             | Anthropic cloud                                                                              | [Cài đặt ứng dụng Slack](/en/slack#setting-up-claude-code-in-slack) với [Claude Code trên web](/en/claude-code-on-the-web) được bật | PR và review từ chat nhóm                                     |
| [Scheduled tasks](/en/scheduled-tasks)         | Đặt một lịch                                                                                   | [CLI](/en/scheduled-tasks), [Desktop](/en/desktop-scheduled-tasks), hoặc [cloud](/en/routines) | Chọn một tần suất                                                                                                                    | Tự động hóa định kỳ như các bản review hàng ngày             |

## Tài nguyên liên quan

* [Claude Code trên web](/en/claude-code-on-the-web): chạy các phiên trong các môi trường cloud do Anthropic quản lý thay vì trên máy của bạn
* [Ultraplan](/en/ultraplan): khởi chạy một phiên lập kế hoạch trên cloud từ terminal của bạn và xem lại kế hoạch trong trình duyệt của bạn
* [Channels](/en/channels): chuyển tiếp Telegram, Discord, hoặc iMessage vào một phiên để Claude phản ứng với các tin nhắn khi bạn vắng mặt
* [Dispatch](/en/desktop#sessions-from-dispatch): nhắn một tác vụ từ điện thoại của bạn và nó có thể sinh ra một phiên Desktop để xử lý nó
* [Xác thực](/en/authentication): thiết lập `/login` và quản lý thông tin xác thực cho claude.ai
* [Tham chiếu CLI](/en/cli-reference): danh sách đầy đủ các flag và lệnh bao gồm `claude remote-control`
* [Bảo mật](/en/security): cách các phiên Remote Control phù hợp với mô hình bảo mật của Claude Code
* [Sử dụng dữ liệu](/en/data-usage): dữ liệu nào chảy qua Anthropic API trong các phiên cục bộ và từ xa
