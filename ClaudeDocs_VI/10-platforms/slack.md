> Nguồn: https://code.claude.com/docs/en/slack.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Claude Code trong Slack

> Giao phó các tác vụ lập trình trực tiếp từ workspace Slack của bạn

<Note>
  Claude Code trong Slack đang được thay thế bởi [Claude Tag](https://claude.com/docs/claude-tag/overview) cho các workspace Team và Enterprise. Claude Tag chạy @Claude như một danh tính chung của tổ chức với quyền truy cập do admin cấu hình, dưới cùng một ứng dụng Slack, nên không có gì phải cài lại và các thiết lập hiện có tiếp tục hoạt động trong quá trình chuyển đổi. Để chuyển một workspace, xem [Chuyển từ phiên bản Claude in Slack trước đó](https://claude.com/docs/claude-tag/admins/migrate-from-earlier).
</Note>

Claude Code trong Slack mang sức mạnh của Claude Code trực tiếp vào workspace Slack của bạn. Khi bạn mention `@Claude` với một tác vụ lập trình, Claude tự động phát hiện ý định và tạo một phiên (session) Claude Code trên nền web, cho phép bạn giao phó công việc phát triển mà không rời khỏi các cuộc trò chuyện nhóm.

Tích hợp này được xây dựng trên ứng dụng Claude for Slack sẵn có nhưng bổ sung định tuyến thông minh tới Claude Code trên nền web cho các yêu cầu liên quan đến lập trình. Mỗi phiên chạy dưới tài khoản Claude của chính bạn, dùng các kho đã kết nối và giới hạn của gói (plan) của bạn.

## Trường hợp sử dụng

* **Điều tra và sửa lỗi**: Yêu cầu Claude điều tra và sửa lỗi ngay khi chúng được báo cáo trong các kênh Slack.
* **Xem xét và chỉnh sửa code nhanh**: Để Claude cài đặt các tính năng nhỏ hoặc refactor code dựa trên phản hồi của nhóm.
* **Gỡ lỗi cộng tác**: Khi các cuộc thảo luận nhóm cung cấp ngữ cảnh then chốt (ví dụ: cách tái hiện lỗi hoặc báo cáo của người dùng), Claude có thể dùng thông tin đó để định hướng cách gỡ lỗi.
* **Thực thi tác vụ song song**: Khởi động các tác vụ lập trình trong Slack trong khi bạn tiếp tục công việc khác, nhận thông báo khi hoàn tất.

## Điều kiện tiên quyết

Trước khi dùng Claude Code trong Slack, hãy đảm bảo bạn có những điều sau:

| Yêu cầu            | Chi tiết                                                                                           |
| :--------------------- | :------------------------------------------------------------------------------------------------ |
| Gói Claude            | Pro, Max, Team, hoặc Enterprise có quyền truy cập Claude Code (premium seat hoặc Chat + Claude Code seat) |
| Claude Code trên nền web | Phải được bật quyền truy cập [Claude Code trên nền web](/en/claude-code-on-the-web)                    |
| Tài khoản GitHub         | Đã kết nối với Claude Code trên nền web với ít nhất một kho đã được xác thực                                  |
| Xác thực Slack   | Tài khoản Slack của bạn được liên kết với tài khoản Claude qua ứng dụng Claude                               |

## Thiết lập Claude Code trong Slack

<Steps>
  <Step title="Cài đặt Claude App trong Slack">
    Một quản trị viên workspace phải cài đặt ứng dụng Claude từ Slack App Marketplace. Truy cập [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4) và nhấp "Add to Slack" để bắt đầu quá trình cài đặt.
  </Step>

  <Step title="Kết nối tài khoản Claude của bạn">
    Sau khi ứng dụng được cài, hãy xác thực tài khoản Claude cá nhân của bạn:

    1. Mở ứng dụng Claude trong Slack bằng cách nhấp vào "Claude" trong mục Apps của bạn
    2. Điều hướng tới tab App Home
    3. Nhấp "Connect" để liên kết tài khoản Slack của bạn với tài khoản Claude
    4. Hoàn tất luồng xác thực trong trình duyệt của bạn
  </Step>

  <Step title="Cấu hình Claude Code trên nền web">
    Đảm bảo Claude Code trên nền web của bạn được cấu hình đúng:

    * Truy cập [claude.ai/code](https://claude.ai/code) và đăng nhập bằng cùng tài khoản bạn đã kết nối với Slack
    * Kết nối tài khoản GitHub nếu chưa kết nối
    * Xác thực ít nhất một kho mà bạn muốn Claude làm việc cùng
  </Step>

  <Step title="Chọn chế độ định tuyến">
    Sau khi kết nối các tài khoản, hãy cấu hình cách Claude xử lý tin nhắn của bạn trong Slack. Điều hướng tới Claude App Home trong Slack để tìm thiết lập **Routing Mode**.

    | Chế độ            | Hành vi                                                                                                                                                                                                                                 |
    | :-------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | **Code only**   | Claude định tuyến tất cả @mention tới các phiên Claude Code. Tốt nhất cho các nhóm dùng Claude trong Slack chỉ cho các tác vụ phát triển.                                                                                             |
    | **Code + Chat** | Claude phân tích mỗi tin nhắn và định tuyến thông minh giữa Claude Code (cho tác vụ lập trình) và Claude Chat (cho viết lách, phân tích, và câu hỏi chung). Tốt nhất cho các nhóm muốn một điểm vào @Claude duy nhất cho mọi loại công việc. |

    <Note>
      Trong chế độ Code + Chat, nếu Claude định tuyến một tin nhắn tới Chat nhưng bạn muốn một phiên lập trình, bạn có thể nhấp "Retry as Code" để tạo một phiên Claude Code thay thế. Tương tự, nếu nó được định tuyến tới Code nhưng bạn muốn một phiên Chat, bạn có thể chọn tùy chọn đó trong thread đó.
    </Note>
  </Step>

  <Step title="Thêm Claude vào các kênh">
    Claude không tự động được thêm vào bất kỳ kênh nào sau khi cài đặt. Để dùng Claude trong một kênh, mời nó bằng cách gõ `/invite @Claude` trong kênh đó. Claude chỉ có thể phản hồi các @mention trong các kênh nơi nó đã được thêm vào.
  </Step>
</Steps>

## Cách hoạt động

### Phát hiện tự động

Khi bạn mention @Claude trong một kênh hoặc thread Slack, Claude tự động phân tích tin nhắn của bạn để xác định đó có phải là một tác vụ lập trình hay không. Nếu Claude phát hiện ý định lập trình, nó sẽ định tuyến yêu cầu của bạn tới Claude Code trên nền web thay vì phản hồi như một trợ lý chat thông thường.

Bạn cũng có thể chỉ dẫn Claude một cách rõ ràng để xử lý một yêu cầu như một tác vụ lập trình, ngay cả khi nó không tự động phát hiện.

<Note>
  Claude Code trong Slack chỉ hoạt động trong các kênh (công khai hoặc riêng tư). Nó không hoạt động trong tin nhắn trực tiếp (DM).
</Note>

### Thu thập ngữ cảnh

**Từ thread**: Khi bạn @mention Claude trong một thread, nó thu thập ngữ cảnh từ tất cả tin nhắn trong thread đó để hiểu toàn bộ cuộc hội thoại.

**Từ kênh**: Khi được mention trực tiếp trong một kênh, Claude xem các tin nhắn gần đây của kênh để lấy ngữ cảnh liên quan.

Ngữ cảnh này giúp Claude hiểu vấn đề, chọn kho phù hợp, và định hướng cách tiếp cận tác vụ.

<Warning>
  Khi @Claude được gọi trong Slack, Claude được cấp quyền truy cập ngữ cảnh cuộc hội thoại để hiểu rõ hơn yêu cầu của bạn. Claude có thể làm theo chỉ dẫn từ các tin nhắn khác trong ngữ cảnh, nên người dùng cần đảm bảo chỉ dùng Claude trong các cuộc hội thoại Slack đáng tin cậy.
</Warning>

### Luồng phiên

1. **Khởi tạo**: Bạn @mention Claude với một yêu cầu lập trình
2. **Phát hiện**: Claude phân tích tin nhắn của bạn và phát hiện ý định lập trình
3. **Tạo phiên**: Một phiên Claude Code mới được tạo trên claude.ai/code
4. **Cập nhật tiến độ**: Claude đăng các cập nhật trạng thái vào thread Slack của bạn khi công việc tiến triển
5. **Hoàn tất**: Khi xong, Claude @mention bạn với một bản tóm tắt và các nút hành động
6. **Xem lại**: Nhấp "View Session" để xem toàn bộ transcript, hoặc "Create PR" để mở một pull request

## Các thành phần giao diện người dùng

### App Home

Tab App Home hiển thị trạng thái kết nối của bạn và cho phép bạn kết nối hoặc ngắt kết nối tài khoản Claude khỏi Slack.

### Hành động trên tin nhắn

* **View Session**: Mở toàn bộ phiên Claude Code trong trình duyệt của bạn, nơi bạn có thể xem tất cả công việc đã thực hiện, tiếp tục phiên, hoặc đưa ra các yêu cầu bổ sung.
* **Create PR**: Tạo một pull request trực tiếp từ các thay đổi của phiên.
* **Retry as Code**: Nếu Claude ban đầu phản hồi như một trợ lý chat nhưng bạn muốn một phiên lập trình, nhấp nút này để thử lại yêu cầu như một tác vụ Claude Code.
* **Change Repo**: Cho phép bạn chọn một kho khác nếu Claude chọn không đúng.

### Chọn kho

Claude tự động chọn một kho dựa trên ngữ cảnh từ cuộc hội thoại Slack của bạn. Nếu nhiều kho có thể phù hợp, Claude có thể hiển thị một menu thả xuống cho phép bạn chọn kho đúng.

## Truy cập và quyền

### Truy cập ở cấp người dùng

| Loại truy cập          | Yêu cầu                                                     |
| :------------------- | :-------------------------------------------------------------- |
| Phiên Claude Code | Mỗi người dùng chạy phiên dưới tài khoản Claude của chính mình          |
| Sử dụng & Giới hạn tần suất  | Các phiên tính vào giới hạn gói của từng người dùng        |
| Truy cập kho    | Người dùng chỉ có thể truy cập các kho họ đã tự kết nối |
| Lịch sử phiên      | Các phiên xuất hiện trong lịch sử Claude Code của bạn trên claude.ai/code   |

### Truy cập ở cấp workspace

Quản trị viên workspace Slack kiểm soát liệu ứng dụng Claude có sẵn trong workspace của họ hay không:

| Kiểm soát                      | Mô tả                                                                                                       |
| :--------------------------- | :---------------------------------------------------------------------------------------------------------------- |
| Cài đặt ứng dụng             | Admin workspace quyết định có cài ứng dụng Claude từ Slack App Marketplace hay không                          |
| Phân phối Enterprise Grid | Với các tổ chức Enterprise Grid, admin tổ chức có thể kiểm soát workspace nào có quyền truy cập ứng dụng Claude |
| Gỡ ứng dụng                  | Gỡ ứng dụng khỏi một workspace ngay lập tức thu hồi quyền truy cập của tất cả người dùng trong workspace đó      |

### Kiểm soát truy cập dựa trên kênh

Claude không tự động được thêm vào bất kỳ kênh nào sau khi cài đặt. Người dùng phải mời Claude vào các kênh nơi họ muốn dùng nó một cách rõ ràng:

* **Cần mời**: Gõ `/invite @Claude` trong bất kỳ kênh nào để thêm Claude vào kênh đó
* **Thành viên kênh kiểm soát truy cập**: Claude chỉ có thể phản hồi các @mention trong các kênh nơi nó đã được thêm vào
* **Kiểm soát truy cập qua kênh**: Admin có thể kiểm soát ai dùng Claude Code bằng cách quản lý những kênh nào Claude được mời vào và ai có quyền truy cập những kênh đó
* **Hỗ trợ kênh riêng tư**: Claude hoạt động trong cả kênh công khai và riêng tư, cho các nhóm sự linh hoạt trong việc kiểm soát khả năng hiển thị

Mô hình dựa trên kênh này cho phép các nhóm giới hạn việc sử dụng Claude Code trong các kênh cụ thể, cung cấp thêm một lớp kiểm soát truy cập ngoài các quyền ở cấp workspace.

## Cái gì truy cập được ở đâu

**Trong Slack**: Bạn sẽ thấy các cập nhật trạng thái, bản tóm tắt hoàn tất, và các nút hành động. Toàn bộ transcript được giữ lại và luôn có thể truy cập.

**Trên web**: Toàn bộ phiên Claude Code với lịch sử hội thoại đầy đủ, tất cả thay đổi code, thao tác file, và khả năng tiếp tục phiên hoặc tạo pull request.

Với các tài khoản Enterprise và Team, các phiên được tạo từ Claude in Slack tự động hiển thị với tổ chức. Xem [Chia sẻ Claude Code trên nền Web](/en/claude-code-on-the-web#share-sessions) để biết thêm chi tiết.

## Các thực hành tốt nhất

### Viết yêu cầu hiệu quả

* **Hãy cụ thể**: Bao gồm tên file, tên hàm, hoặc thông báo lỗi khi có liên quan.
* **Cung cấp ngữ cảnh**: Nêu kho hoặc dự án nếu nó không rõ ràng từ cuộc hội thoại.
* **Xác định thành công**: Giải thích "hoàn thành" trông như thế nào—Claude có nên viết test không? Cập nhật tài liệu? Tạo PR?
* **Dùng thread**: Trả lời trong thread khi thảo luận về lỗi hoặc tính năng để Claude có thể thu thập đầy đủ ngữ cảnh.

### Khi nào dùng Slack so với web

**Dùng Slack khi**: Ngữ cảnh đã có sẵn trong một cuộc thảo luận Slack, bạn muốn khởi động một tác vụ bất đồng bộ, hoặc bạn đang cộng tác với đồng đội cần khả năng quan sát.

**Dùng web trực tiếp khi**: Bạn cần tải file lên, muốn tương tác thời gian thực trong quá trình phát triển, hoặc đang làm việc trên các tác vụ dài hơn, phức tạp hơn.

## Khắc phục sự cố

### "Claude Code is not enabled for your account"

Lỗi này nghĩa là tài khoản Claude của bạn chưa có môi trường đám mây, không phải rằng cần admin bật gì đó. Đăng nhập tại [claude.ai/code](https://claude.ai/code) một lần với cùng tài khoản bạn đã kết nối với Slack. Lần truy cập đầu tiên tạo môi trường đám mây mặc định của bạn, và lỗi biến mất ở lần mention tiếp theo. Mỗi người dùng phải tự làm việc này.

### Phiên không khởi động

1. Xác minh tài khoản Claude của bạn đã được kết nối trong Claude App Home
2. Kiểm tra bạn đã bật quyền truy cập Claude Code trên nền web
3. Đảm bảo bạn có ít nhất một kho GitHub được kết nối với Claude Code

### Kho không hiển thị

1. Kết nối kho trong Claude Code trên nền web tại [claude.ai/code](https://claude.ai/code)
2. Xác minh quyền GitHub của bạn cho kho đó
3. Thử ngắt kết nối và kết nối lại tài khoản GitHub của bạn

### Chọn sai kho

1. Nhấp nút "Change Repo" để chọn một kho khác
2. Bao gồm tên kho trong yêu cầu của bạn để chọn chính xác hơn

### Lỗi xác thực

1. Ngắt kết nối và kết nối lại tài khoản Claude của bạn trong App Home
2. Đảm bảo bạn đã đăng nhập đúng tài khoản Claude trong trình duyệt của bạn
3. Kiểm tra gói Claude của bạn bao gồm quyền truy cập Claude Code

### Phiên hết hạn

1. Các phiên vẫn có thể truy cập trong lịch sử Claude Code của bạn trên web
2. Bạn có thể tiếp tục hoặc tham chiếu các phiên trước đây từ [claude.ai/code](https://claude.ai/code)

## Các giới hạn hiện tại

* **Chỉ GitHub**: Hiện chỉ hỗ trợ các kho trên GitHub.
* **Một PR một lúc**: Mỗi phiên có thể tạo một pull request.
* **Áp dụng giới hạn tần suất**: Các phiên dùng giới hạn tần suất của gói Claude cá nhân của bạn.
* **Cần quyền truy cập web**: Người dùng phải có quyền truy cập Claude Code trên nền web; những người không có nó sẽ chỉ nhận được phản hồi chat Claude tiêu chuẩn.

## Tài nguyên liên quan

<CardGroup>
  <Card title="Claude Code trên nền web" icon="globe" href="/en/claude-code-on-the-web">
    Tìm hiểu thêm về Claude Code trên nền web
  </Card>

  <Card title="Claude for Slack" icon="slack" href="https://claude.com/claude-and-slack">
    Tài liệu chung về Claude for Slack
  </Card>

  <Card title="Claude Tag" icon="users" href="https://claude.com/docs/claude-tag/overview">
    @Claude trong Slack do tổ chức quản lý với quyền truy cập do admin cấu hình
  </Card>

  <Card title="Slack App Marketplace" icon="store" href="https://slack.com/marketplace/A08SF47R6P4">
    Cài ứng dụng Claude từ Slack Marketplace
  </Card>

  <Card title="Trung tâm Trợ giúp Claude" icon="circle-question" href="https://support.claude.com">
    Nhận thêm hỗ trợ
  </Card>
</CardGroup>
