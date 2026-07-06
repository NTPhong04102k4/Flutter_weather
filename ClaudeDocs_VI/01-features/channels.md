> Nguồn: https://code.claude.com/docs/en/channels.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Đẩy sự kiện vào một phiên đang chạy với channel

> Dùng channel để đẩy tin nhắn, cảnh báo, và webhook vào phiên Claude Code của bạn từ một MCP server. Chuyển tiếp kết quả CI, tin nhắn chat, và các sự kiện giám sát để Claude có thể phản ứng trong khi bạn vắng mặt.

<Note>
  Channel đang trong [bản xem trước nghiên cứu (research preview)](#research-preview) và yêu cầu Claude Code v2.1.80 trở lên. Chúng yêu cầu xác thực Anthropic thông qua claude.ai hoặc một Console API key, và không có sẵn trên Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry. Các tổ chức Team và Enterprise phải [bật chúng một cách rõ ràng](#enterprise-controls).
</Note>

Một channel là một MCP server đẩy các sự kiện vào phiên Claude Code đang chạy của bạn, để Claude có thể phản ứng với những điều xảy ra khi bạn không ở terminal. Channel có thể là hai chiều: Claude đọc sự kiện và trả lời lại qua cùng channel đó, giống như một cầu nối chat. Sự kiện chỉ đến khi phiên đang mở, nên để có một thiết lập luôn bật, bạn chạy Claude trong một tiến trình nền hoặc một terminal thường trực.

Không giống các tích hợp sinh ra một phiên cloud mới hoặc chờ được thăm dò (poll), sự kiện đến ngay trong phiên bạn đã mở sẵn: xem [so sánh các channel](#how-channels-compare).

Bạn cài đặt một channel dưới dạng một plugin và cấu hình nó bằng thông tin xác thực của riêng bạn. Telegram, Discord, và iMessage được bao gồm trong bản xem trước nghiên cứu.

Khi Claude trả lời qua một channel, bạn thấy tin nhắn đến trong terminal nhưng không thấy nội dung trả lời. Terminal hiển thị lệnh gọi công cụ và một xác nhận (như "sent"), và câu trả lời thực tế xuất hiện trên nền tảng bên kia.

Nếu bạn quản lý một tổ chức Team, Enterprise, hoặc Console, xem [Bật channel cho tổ chức của bạn](#enterprise-controls). Để tự xây dựng channel của riêng bạn, xem [Tài liệu tham chiếu channel](/en/channels-reference).

## Các channel được hỗ trợ

Mỗi channel được hỗ trợ là một plugin yêu cầu [Bun](https://bun.sh). Để xem thực hành luồng plugin trước khi kết nối một nền tảng thật, hãy thử [quickstart fakechat](#quickstart).

<Tabs>
  <Tab title="Telegram">
    Xem đầy đủ [mã nguồn plugin Telegram](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/telegram).

    <Steps>
      <Step title="Tạo một bot Telegram">
        Mở [BotFather](https://t.me/BotFather) trong Telegram và gửi `/newbot`. Đặt cho nó một tên hiển thị và một username duy nhất kết thúc bằng `bot`. Sao chép token mà BotFather trả về.
      </Step>

      <Step title="Cài đặt plugin">
        Trong Claude Code, chạy:

        ```
        /plugin install telegram@claude-plugins-official
        ```

        Nếu Claude Code báo rằng không tìm thấy plugin trong bất kỳ marketplace nào, thì marketplace của bạn đang thiếu hoặc lỗi thời. Chạy `/plugin marketplace update claude-plugins-official` để làm mới nó, hoặc `/plugin marketplace add anthropics/claude-plugins-official` nếu bạn chưa từng thêm nó trước đây. Sau đó thử cài lại.

        Sau khi cài đặt, chạy `/reload-plugins` để kích hoạt lệnh configure của plugin.
      </Step>

      <Step title="Cấu hình token của bạn">
        Chạy lệnh configure với token từ BotFather:

        ```
        /telegram:configure <token>
        ```

        Việc này lưu nó vào `~/.claude/channels/telegram/.env`. Bạn cũng có thể đặt `TELEGRAM_BOT_TOKEN` trong môi trường shell của bạn trước khi khởi chạy Claude Code.
      </Step>

      <Step title="Khởi động lại với channel được bật">
        Thoát Claude Code và khởi động lại với cờ channel. Việc này khởi động plugin Telegram, bắt đầu thăm dò các tin nhắn từ bot của bạn:

        ```bash theme={null}
        claude --channels plugin:telegram@claude-plugins-official
        ```
      </Step>

      <Step title="Ghép nối tài khoản của bạn">
        Mở Telegram và gửi bất kỳ tin nhắn nào tới bot của bạn. Bot trả lời với một mã ghép nối (pairing code).

        <Note>Nếu bot không phản hồi, hãy đảm bảo Claude Code đang chạy với `--channels` từ bước trước. Bot chỉ có thể trả lời khi channel đang hoạt động.</Note>

        Quay lại Claude Code, chạy:

        ```
        /telegram:access pair <code>
        ```

        Sau đó khóa quyền truy cập để chỉ tài khoản của bạn mới có thể gửi tin nhắn:

        ```
        /telegram:access policy allowlist
        ```
      </Step>
    </Steps>
  </Tab>

  <Tab title="Discord">
    Xem đầy đủ [mã nguồn plugin Discord](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/discord).

    <Steps>
      <Step title="Tạo một bot Discord">
        Vào [Discord Developer Portal](https://discord.com/developers/applications), nhấp **New Application**, và đặt tên cho nó. Trong phần **Bot**, tạo một username, sau đó nhấp **Reset Token** và sao chép token.
      </Step>

      <Step title="Bật Message Content Intent">
        Trong cài đặt bot của bạn, cuộn xuống **Privileged Gateway Intents** và bật **Message Content Intent**.
      </Step>

      <Step title="Mời bot vào server của bạn">
        Vào **OAuth2 > URL Generator**. Chọn scope `bot` và bật các quyền sau:

        * View Channels
        * Send Messages
        * Send Messages in Threads
        * Read Message History
        * Attach Files
        * Add Reactions

        Mở URL được tạo ra để thêm bot vào server của bạn.
      </Step>

      <Step title="Cài đặt plugin">
        Trong Claude Code, chạy:

        ```
        /plugin install discord@claude-plugins-official
        ```

        Nếu Claude Code báo rằng không tìm thấy plugin trong bất kỳ marketplace nào, thì marketplace của bạn đang thiếu hoặc lỗi thời. Chạy `/plugin marketplace update claude-plugins-official` để làm mới nó, hoặc `/plugin marketplace add anthropics/claude-plugins-official` nếu bạn chưa từng thêm nó trước đây. Sau đó thử cài lại.

        Sau khi cài đặt, chạy `/reload-plugins` để kích hoạt lệnh configure của plugin.
      </Step>

      <Step title="Cấu hình token của bạn">
        Chạy lệnh configure với bot token bạn đã sao chép:

        ```
        /discord:configure <token>
        ```

        Việc này lưu nó vào `~/.claude/channels/discord/.env`. Bạn cũng có thể đặt `DISCORD_BOT_TOKEN` trong môi trường shell của bạn trước khi khởi chạy Claude Code.
      </Step>

      <Step title="Khởi động lại với channel được bật">
        Thoát Claude Code và khởi động lại với cờ channel. Việc này kết nối plugin Discord để bot của bạn có thể nhận và phản hồi tin nhắn:

        ```bash theme={null}
        claude --channels plugin:discord@claude-plugins-official
        ```
      </Step>

      <Step title="Ghép nối tài khoản của bạn">
        Nhắn tin trực tiếp (DM) cho bot của bạn trên Discord. Bot trả lời với một mã ghép nối.

        <Note>Nếu bot không phản hồi, hãy đảm bảo Claude Code đang chạy với `--channels` từ bước trước. Bot chỉ có thể trả lời khi channel đang hoạt động.</Note>

        Quay lại Claude Code, chạy:

        ```
        /discord:access pair <code>
        ```

        Sau đó khóa quyền truy cập để chỉ tài khoản của bạn mới có thể gửi tin nhắn:

        ```
        /discord:access policy allowlist
        ```
      </Step>
    </Steps>
  </Tab>

  <Tab title="iMessage">
    Xem đầy đủ [mã nguồn plugin iMessage](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/imessage).

    Channel iMessage đọc trực tiếp cơ sở dữ liệu Messages của bạn và gửi trả lời thông qua AppleScript. Nó yêu cầu macOS và không cần bot token hay dịch vụ bên ngoài nào.

    <Steps>
      <Step title="Cấp quyền Full Disk Access">
        Cơ sở dữ liệu Messages tại `~/Library/Messages/chat.db` được macOS bảo vệ. Lần đầu tiên server đọc nó, macOS nhắc cấp quyền: nhấp **Allow**. Lời nhắc nêu tên ứng dụng nào đã khởi chạy Bun, chẳng hạn Terminal, iTerm, hoặc IDE của bạn.

        Nếu lời nhắc không xuất hiện hoặc bạn đã nhấp Don't Allow, hãy cấp quyền thủ công dưới **System Settings > Privacy & Security > Full Disk Access** và thêm terminal của bạn. Nếu không có việc này, server thoát ngay lập tức với `authorization denied`.
      </Step>

      <Step title="Cài đặt plugin">
        Trong Claude Code, chạy:

        ```
        /plugin install imessage@claude-plugins-official
        ```

        Nếu Claude Code báo rằng không tìm thấy plugin trong bất kỳ marketplace nào, thì marketplace của bạn đang thiếu hoặc lỗi thời. Chạy `/plugin marketplace update claude-plugins-official` để làm mới nó, hoặc `/plugin marketplace add anthropics/claude-plugins-official` nếu bạn chưa từng thêm nó trước đây. Sau đó thử cài lại.
      </Step>

      <Step title="Khởi động lại với channel được bật">
        Thoát Claude Code và khởi động lại với cờ channel:

        ```bash theme={null}
        claude --channels plugin:imessage@claude-plugins-official
        ```
      </Step>

      <Step title="Nhắn tin cho chính bạn">
        Mở Messages trên bất kỳ thiết bị nào đã đăng nhập Apple ID của bạn và gửi một tin nhắn cho chính mình. Nó đến Claude ngay lập tức: tự-chat (self-chat) bỏ qua kiểm soát truy cập mà không cần thiết lập gì.

        <Note>Câu trả lời đầu tiên Claude gửi kích hoạt một lời nhắc Automation của macOS hỏi liệu terminal của bạn có thể điều khiển Messages hay không. Nhấp **OK**.</Note>
      </Step>

      <Step title="Cho phép những người gửi khác">
        Mặc định, chỉ tin nhắn của chính bạn mới đi qua. Để cho phép một liên hệ khác tiếp cận Claude, hãy thêm handle của họ:

        ```
        /imessage:access allow +15551234567
        ```

        Handle là số điện thoại ở định dạng `+country` hoặc email Apple ID như `user@example.com`.
      </Step>
    </Steps>
  </Tab>
</Tabs>

Bạn cũng có thể [tự xây dựng channel của riêng bạn](/en/channels-reference) cho các hệ thống chưa có plugin.

## Quickstart

Fakechat là một channel demo được hỗ trợ chính thức, chạy một giao diện chat trên localhost, không có gì để xác thực và không có dịch vụ bên ngoài nào để cấu hình.

Sau khi bạn cài đặt và bật fakechat, bạn có thể gõ trong trình duyệt và tin nhắn đến phiên Claude Code của bạn. Claude trả lời, và câu trả lời hiển thị lại trong trình duyệt. Sau khi đã thử giao diện fakechat, hãy thử [Telegram](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/telegram), [Discord](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/discord), hoặc [iMessage](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/imessage).

Để thử demo fakechat, bạn cần:

* Claude Code [đã cài đặt và xác thực](/en/quickstart#step-1-install-claude-code) với một tài khoản claude.ai hoặc một Claude Console API key
* [Bun](https://bun.sh) đã cài đặt. Các plugin channel dựng sẵn là các script Bun. Kiểm tra bằng `bun --version`; nếu lệnh đó thất bại, [cài đặt Bun](https://bun.sh/docs/installation).
* **Tổ chức Team, Enterprise, hoặc Console được quản lý**: admin của bạn phải [bật channel](#enterprise-controls) trong managed settings

<Steps>
  <Step title="Cài đặt plugin channel fakechat">
    Bắt đầu một phiên Claude Code và chạy lệnh cài đặt:

    ```text theme={null}
    /plugin install fakechat@claude-plugins-official
    ```

    Nếu Claude Code báo rằng không tìm thấy plugin trong bất kỳ marketplace nào, thì marketplace của bạn đang thiếu hoặc lỗi thời. Chạy `/plugin marketplace update claude-plugins-official` để làm mới nó, hoặc `/plugin marketplace add anthropics/claude-plugins-official` nếu bạn chưa từng thêm nó trước đây. Sau đó thử cài lại.
  </Step>

  <Step title="Khởi động lại với channel được bật">
    Thoát Claude Code, sau đó khởi động lại với `--channels` và truyền plugin fakechat bạn đã cài:

    ```bash theme={null}
    claude --channels plugin:fakechat@claude-plugins-official
    ```

    Server fakechat khởi động tự động.

    <Tip>
      Bạn có thể truyền nhiều plugin cho `--channels`, cách nhau bằng dấu cách.
    </Tip>
  </Step>

  <Step title="Đẩy một tin nhắn vào">
    Mở giao diện fakechat tại [http://localhost:8787](http://localhost:8787) và gõ một tin nhắn:

    ```text theme={null}
    hey, what's in my working directory?
    ```

    Tin nhắn đến phiên Claude Code của bạn dưới dạng một sự kiện `<channel source="fakechat">`. Claude đọc nó, làm việc, và gọi công cụ `reply` của fakechat. Câu trả lời hiển thị trong giao diện chat.
  </Step>
</Steps>

Nếu Claude gặp một lời nhắc xin quyền trong khi bạn không ở terminal, phiên tạm dừng cho đến khi bạn phản hồi. Các channel server khai báo [khả năng chuyển tiếp lời nhắc quyền (permission relay)](/en/channels-reference#relay-permission-prompts) có thể chuyển tiếp các lời nhắc này tới bạn để bạn có thể phê duyệt hoặc từ chối từ xa. Đối với việc dùng không giám sát, [`--dangerously-skip-permissions`](/en/permission-modes#skip-all-checks-with-bypasspermissions-mode) bỏ qua các lời nhắc ngoài các luật ask rõ ràng, nhưng chỉ dùng nó trong các môi trường bạn tin tưởng.

Khi bạn chạy channel ở chế độ không tương tác với `-p`, các công cụ cần đầu vào từ terminal, chẳng hạn câu hỏi trắc nghiệm và phê duyệt plan mode, bị vô hiệu hóa để phiên không bao giờ bị treo chờ đầu vào.

## Bảo mật

Mỗi plugin channel được phê duyệt duy trì một danh sách cho phép người gửi (sender allowlist): chỉ những ID bạn đã thêm mới có thể đẩy tin nhắn, và mọi người khác đều bị âm thầm bỏ qua.

Telegram và Discord khởi tạo danh sách bằng cách ghép nối:

1. Tìm bot của bạn trong Telegram hoặc Discord và gửi cho nó bất kỳ tin nhắn nào
2. Bot trả lời với một mã ghép nối
3. Trong phiên Claude Code của bạn, phê duyệt mã khi được nhắc
4. ID người gửi của bạn được thêm vào danh sách cho phép

iMessage hoạt động khác: nhắn tin cho chính bạn tự động bỏ qua cổng kiểm soát, và bạn thêm các liên hệ khác bằng handle với `/imessage:access allow`.

Trên hết, bạn kiểm soát server nào được bật trong mỗi phiên với `--channels`, và tổ chức của bạn kiểm soát tính khả dụng với [`channelsEnabled`](#enterprise-controls) trên các gói Team và Enterprise của claude.ai và trên các tổ chức Console triển khai managed settings.

Việc có mặt trong `.mcp.json` là chưa đủ để đẩy tin nhắn: một server còn phải được nêu tên trong `--channels`.

Danh sách cho phép cũng kiểm soát [permission relay](/en/channels-reference#relay-permission-prompts) nếu channel khai báo nó. Bất kỳ ai có thể trả lời qua channel đều có thể phê duyệt hoặc từ chối việc dùng công cụ trong phiên của bạn, nên chỉ đưa vào danh sách cho phép những người gửi mà bạn tin tưởng với quyền đó.

## Kiểm soát cho doanh nghiệp (Enterprise controls)

Admin kiểm soát tính khả dụng thông qua hai [managed settings](/en/settings) mà người dùng không thể ghi đè. Mặc định phụ thuộc vào cách bạn xác thực:

* **claude.ai Team và Enterprise**: channel bị chặn cho đến khi một Owner bật chúng.
* **Anthropic Console với xác thực API key**: channel được cho phép mặc định. Bạn chỉ cần cài đặt này nếu tổ chức của bạn triển khai managed settings.

Trong mọi trường hợp, không channel nào chạy cho đến khi một người dùng tự chọn bật nó cho phiên với `--channels`.

| Cài đặt                 | Mục đích                                                                                                                                                                                                                                                     | Khi không được cấu hình                                                                                                                                                                    |
| :---------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `channelsEnabled`       | Công tắc chính. Phải là `true` để bất kỳ channel nào chuyển tin nhắn. Đặt qua công tắc [Admin console của claude.ai](https://claude.ai/admin-settings/claude-code) hoặc trực tiếp trong managed settings. Chặn tất cả channel bao gồm cả cờ phát triển khi tắt. | claude.ai Team và Enterprise: channel bị chặn. Console: channel được cho phép trừ khi tổ chức của bạn triển khai managed settings, trong trường hợp đó channel bị chặn cho đến khi key này được đặt |
| `allowedChannelPlugins` | Những plugin nào có thể đăng ký một khi channel được bật. Thay thế danh sách do Anthropic duy trì khi được đặt. Chỉ áp dụng khi `channelsEnabled` là `true`.                                                                                                | Danh sách mặc định của Anthropic được áp dụng                                                                                                                                          |

Người dùng Pro và Max không thuộc tổ chức nào bỏ qua hoàn toàn các kiểm tra này: channel có sẵn và người dùng tự chọn bật theo từng phiên với `--channels`.

### Bật channel cho tổ chức của bạn

Bật channel cho tổ chức của bạn từ [**claude.ai → Admin settings → Claude Code → Channels**](https://claude.ai/admin-settings/claude-code), yêu cầu vai trò Owner, hoặc bằng cách đặt `channelsEnabled` thành `true` trong managed settings.

Sau khi được bật, người dùng trong tổ chức của bạn có thể dùng `--channels` để tự chọn bật các channel server vào từng phiên. Nếu cài đặt bị tắt hoặc chưa đặt, MCP server vẫn kết nối và các công cụ của nó vẫn hoạt động, nhưng tin nhắn channel sẽ không đến. Một cảnh báo khi khởi động sẽ bảo người dùng nhờ admin bật cài đặt.

### Hạn chế những plugin channel nào có thể chạy

Mặc định, bất kỳ plugin nào trên danh sách cho phép do Anthropic duy trì đều có thể đăng ký làm một channel. Admin trên các gói Team và Enterprise có thể thay thế danh sách cho phép đó bằng danh sách của riêng họ bằng cách đặt `allowedChannelPlugins` trong managed settings. Dùng cái này để hạn chế những plugin chính thức nào được phép, phê duyệt các channel từ marketplace nội bộ của riêng bạn, hoặc cả hai. Mỗi mục nêu tên một plugin và marketplace nó đến từ:

```json theme={null}
{
  "channelsEnabled": true,
  "allowedChannelPlugins": [
    { "marketplace": "claude-plugins-official", "plugin": "telegram" },
    { "marketplace": "claude-plugins-official", "plugin": "discord" },
    { "marketplace": "acme-corp-plugins", "plugin": "internal-alerts" }
  ]
}
```

Khi `allowedChannelPlugins` được đặt, nó thay thế hoàn toàn danh sách cho phép của Anthropic: chỉ các plugin được liệt kê mới có thể đăng ký. Để trống nó để quay về danh sách cho phép mặc định của Anthropic. Một mảng rỗng chặn tất cả plugin channel khỏi danh sách cho phép, nhưng `--dangerously-load-development-channels` vẫn có thể bỏ qua nó cho việc thử nghiệm cục bộ. Để chặn channel hoàn toàn bao gồm cả cờ phát triển, hãy để `channelsEnabled` chưa đặt.

Cài đặt này yêu cầu `channelsEnabled: true`. Nếu một người dùng truyền một plugin cho `--channels` mà không nằm trong danh sách của bạn, Claude Code khởi động bình thường nhưng channel không đăng ký, và thông báo khởi động giải thích rằng plugin không nằm trong danh sách đã phê duyệt của tổ chức.

## Bản xem trước nghiên cứu (Research preview)

Channel là một tính năng bản xem trước nghiên cứu. Tính khả dụng đang được triển khai dần, và cú pháp cờ `--channels` cũng như hợp đồng giao thức (protocol contract) có thể thay đổi dựa trên phản hồi.

Trong thời gian xem trước, `--channels` chỉ chấp nhận các plugin từ một danh sách cho phép do Anthropic duy trì, hoặc từ danh sách cho phép của tổ chức bạn nếu một admin đã đặt [`allowedChannelPlugins`](#restrict-which-channel-plugins-can-run). Các plugin channel trong [claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins) là tập được phê duyệt mặc định. Nếu bạn truyền thứ gì đó không nằm trong danh sách cho phép hiệu lực, Claude Code khởi động bình thường nhưng channel không đăng ký, và thông báo khởi động cho bạn biết lý do.

Để thử nghiệm một channel bạn đang xây dựng, dùng `--dangerously-load-development-channels`. Xem [Thử nghiệm trong thời gian xem trước nghiên cứu](/en/channels-reference#test-during-the-research-preview) để biết thông tin về việc thử nghiệm các channel tùy chỉnh mà bạn xây dựng.

Báo cáo vấn đề hoặc phản hồi trên [kho lưu trữ GitHub của Claude Code](https://github.com/anthropics/claude-code/issues).

## So sánh các channel

Nhiều tính năng của Claude Code kết nối tới các hệ thống bên ngoài terminal, mỗi tính năng phù hợp với một loại công việc khác nhau:

| Tính năng                                            | Nó làm gì                                                              | Tốt cho                                                    |
| ---------------------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------- |
| [Claude Code trên web](/en/claude-code-on-the-web)   | Chạy tác vụ trong một sandbox cloud mới, được clone từ GitHub          | Giao phó công việc bất đồng bộ tự chứa mà bạn kiểm tra sau |
| [Claude trong Slack](/en/slack)                      | Sinh ra một phiên web từ một lượt nhắc `@Claude` trong channel hoặc thread | Bắt đầu tác vụ trực tiếp từ ngữ cảnh trò chuyện của nhóm    |
| [MCP server](/en/mcp) tiêu chuẩn                     | Claude truy vấn nó trong một tác vụ; không có gì được đẩy vào phiên    | Cho Claude quyền truy cập theo yêu cầu để đọc hoặc truy vấn một hệ thống  |
| [Remote Control](/en/remote-control)                 | Bạn điều khiển phiên cục bộ của mình từ claude.ai hoặc ứng dụng di động Claude | Lái một phiên đang tiến hành khi rời khỏi bàn làm việc |

Channel lấp đầy khoảng trống trong danh sách đó bằng cách đẩy các sự kiện từ những nguồn không phải Claude vào phiên cục bộ đang chạy sẵn của bạn.

* **Cầu nối chat**: hỏi Claude điều gì đó từ điện thoại của bạn qua Telegram, Discord, hoặc iMessage, và câu trả lời quay lại trong cùng cuộc trò chuyện trong khi công việc chạy trên máy của bạn với các file thật.
* **[Bộ nhận webhook](/en/channels-reference#example-build-a-webhook-receiver)**: một webhook từ CI, trình theo dõi lỗi (error tracker), một pipeline triển khai, hoặc dịch vụ bên ngoài khác đến ngay nơi Claude đã mở sẵn các file của bạn và nhớ những gì bạn đang gỡ lỗi.

## Các bước tiếp theo

Sau khi bạn có một channel đang chạy, hãy khám phá các tính năng liên quan này:

* [Tự xây dựng channel của riêng bạn](/en/channels-reference) cho các hệ thống chưa có plugin
* [Remote Control](/en/remote-control) để lái một phiên cục bộ từ điện thoại của bạn thay vì chuyển tiếp sự kiện vào nó
* [Tác vụ theo lịch (Scheduled tasks)](/en/scheduled-tasks) để thăm dò theo một bộ hẹn giờ thay vì phản ứng với các sự kiện được đẩy vào
