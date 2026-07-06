> Nguồn: https://code.claude.com/docs/en/web-quickstart.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bắt đầu với Claude Code trên nền web

> Chạy Claude Code trên đám mây từ trình duyệt hoặc điện thoại của bạn. Kết nối một kho GitHub, gửi một tác vụ, và xem lại PR mà không cần cài đặt cục bộ.

<Note>
  Claude Code trên nền web đang trong giai đoạn research preview cho người dùng Pro, Max và Team, cũng như cho người dùng Enterprise có premium seat hoặc Chat + Claude Code seat.
</Note>

Claude Code trên nền web chạy trên hạ tầng đám mây do Anthropic quản lý thay vì trên máy của bạn. Gửi tác vụ từ [claude.ai/code](https://claude.ai/code) trong trình duyệt hoặc trong ứng dụng di động Claude.

Bạn cần một kho GitHub để [bắt đầu](#connect-github-and-create-an-environment). Claude clone kho đó vào một máy ảo (virtual machine) được cách ly, thực hiện thay đổi, và đẩy (push) một nhánh để bạn xem lại. Các phiên (session) được lưu xuyên suốt các thiết bị, nên một tác vụ bạn bắt đầu trên laptop có thể được xem lại từ điện thoại sau đó.

Claude Code trên nền web hoạt động tốt cho:

* **Tác vụ song song**: chạy nhiều tác vụ độc lập cùng lúc, mỗi tác vụ trong phiên và nhánh riêng, mà không phải quản lý nhiều worktree
* **Kho bạn không có sẵn ở cục bộ**: Claude clone kho mới mỗi phiên, nên bạn không cần checkout sẵn
* **Tác vụ không cần điều hướng thường xuyên**: gửi một tác vụ được định nghĩa rõ ràng, làm việc khác, rồi xem kết quả khi Claude xong
* **Câu hỏi và khám phá code**: hiểu một codebase hoặc lần theo cách một tính năng được cài đặt mà không cần checkout cục bộ

Với công việc cần cấu hình, công cụ hoặc môi trường cục bộ của bạn, chạy Claude Code cục bộ hoặc dùng [Remote Control](/en/remote-control) là lựa chọn phù hợp hơn.

## Cách các phiên chạy

Khi bạn gửi một tác vụ:

1. **Clone và chuẩn bị**: kho của bạn được clone vào một VM do Anthropic quản lý, và [setup script](/en/claude-code-on-the-web#setup-scripts) của bạn chạy nếu được cấu hình.
2. **Cấu hình mạng**: truy cập internet được thiết lập dựa trên [mức truy cập (access level)](/en/claude-code-on-the-web#access-levels) của môi trường bạn.
3. **Làm việc**: Claude phân tích code, thực hiện thay đổi, chạy test, và kiểm tra lại công việc của mình. Bạn có thể theo dõi và điều hướng suốt quá trình, hoặc rời đi rồi quay lại khi nó xong.
4. **Đẩy nhánh**: khi Claude đạt tới điểm dừng, nó đẩy nhánh của mình lên GitHub. Bạn xem lại diff, để lại nhận xét inline, tạo PR, hoặc gửi thêm một tin nhắn để tiếp tục.

Phiên không đóng lại khi nhánh được đẩy. Việc tạo PR và các chỉnh sửa tiếp theo đều diễn ra trong cùng cuộc hội thoại.

## So sánh các cách chạy Claude Code

Claude Code hành xử giống nhau ở mọi nơi. Điều thay đổi là code chạy ở đâu và liệu cấu hình cục bộ của bạn có sẵn hay không. Ứng dụng Desktop cung cấp cả phiên cục bộ lẫn phiên đám mây, nên các câu trả lời bên dưới phụ thuộc vào loại bạn chọn:

|                                              | Trên nền web                                                                                                     | Remote Control               | Terminal CLI           | Ứng dụng Desktop                 |
| :------------------------------------------- | :-------------------------------------------------------------------------------------------------------------- | :--------------------------- | :--------------------- | :-------------------------- |
| **Code chạy trên**                             | VM đám mây của Anthropic                                                                                             | Máy của bạn                 | Máy của bạn           | Máy của bạn hoặc VM đám mây    |
| **Bạn chat từ**                            | claude.ai hoặc ứng dụng di động                                                                                        | claude.ai hoặc ứng dụng di động      | Terminal của bạn          | Giao diện Desktop              |
| **Dùng cấu hình cục bộ của bạn**                   | Không, chỉ kho                                                                                                  | Có                          | Có                    | Có với cục bộ, không với đám mây |
| **Yêu cầu GitHub**                          | Có, hoặc [đóng gói một kho cục bộ](/en/claude-code-on-the-web#send-local-repositories-without-github) qua `--cloud` | Không                           | Không                     | Chỉ với phiên đám mây     |
| **Vẫn chạy nếu bạn ngắt kết nối**          | Có                                                                                                            | Trong khi terminal còn mở    | Không                     | Tùy loại phiên     |
| **[Chế độ quyền (permission modes)](/en/permission-modes)** | Accept edits, Plan, Auto                                                                                       | Ask, Auto accept edits, Plan | Tất cả các chế độ              | Tùy loại phiên     |
| **Truy cập mạng**                           | Cấu hình được theo từng môi trường                                                                                   | Mạng của máy bạn      | Mạng của máy bạn | Tùy loại phiên     |

Xem tài liệu [quickstart terminal](/en/quickstart), [ứng dụng Desktop](/en/desktop), hoặc [Remote Control](/en/remote-control) để thiết lập những cách đó.

## Kết nối GitHub và tạo một môi trường

Việc thiết lập là quy trình chỉ làm một lần. Nếu bạn đã dùng GitHub CLI, bạn có thể [làm việc này từ terminal của mình](#connect-from-your-terminal) thay vì trình duyệt.

<Steps>
  <Step title="Truy cập claude.ai/code">
    Vào [claude.ai/code](https://claude.ai/code) và đăng nhập bằng tài khoản Anthropic của bạn.
  </Step>

  <Step title="Cài đặt Claude GitHub App">
    Sau khi đăng nhập, claude.ai/code nhắc bạn kết nối GitHub. Làm theo hướng dẫn để cài đặt Claude GitHub App và cấp cho nó quyền truy cập vào các kho của bạn. Phiên đám mây hoạt động với các kho GitHub sẵn có, nên để bắt đầu một dự án mới, hãy [tạo một kho trống trên GitHub](https://github.com/new) trước.
  </Step>

  <Step title="Tạo môi trường của bạn">
    Sau khi kết nối GitHub, bạn sẽ được nhắc tạo một môi trường đám mây. Môi trường kiểm soát Claude có quyền truy cập mạng nào trong các phiên và điều gì chạy khi một phiên mới được tạo. Xem [Công cụ được cài đặt sẵn](/en/claude-code-on-the-web#installed-tools) để biết những gì có sẵn mà không cần cấu hình.

    Biểu mẫu có các trường sau:

    * **Name**: nhãn hiển thị. Hữu ích khi bạn có nhiều môi trường cho các dự án hoặc mức truy cập khác nhau.
    * **Network access**: kiểm soát những gì phiên có thể truy cập trên internet. Mặc định `Trusted` cho phép kết nối tới [các package registry phổ biến](/en/claude-code-on-the-web#default-allowed-domains) như npm, PyPI và RubyGems trong khi chặn truy cập internet chung.
    * **Environment variables**: các biến tùy chọn có sẵn trong mọi phiên, theo định dạng `.env`. Đừng bọc giá trị trong dấu ngoặc kép, vì dấu ngoặc kép được lưu như một phần của giá trị. Những biến này hiển thị với bất kỳ ai có thể chỉnh sửa môi trường này.
    * **Setup script**: một Bash script tùy chọn chạy trước khi Claude Code khởi động. Dùng nó để cài các công cụ hệ thống mà VM đám mây không có sẵn, như `apt install -y gh`. Kết quả được [cache](/en/claude-code-on-the-web#environment-caching), nên script không chạy lại ở mỗi phiên. Xem [Setup scripts](/en/claude-code-on-the-web#setup-scripts) để có ví dụ và mẹo gỡ lỗi.

    Với dự án đầu tiên, hãy để nguyên mặc định và nhấp **Create environment**. Bạn có thể [chỉnh sửa sau hoặc tạo thêm môi trường](/en/claude-code-on-the-web#configure-your-environment) cho các dự án khác nhau.
  </Step>
</Steps>

### Kết nối từ terminal của bạn

Nếu bạn đã dùng GitHub CLI (`gh`), bạn có thể thiết lập Claude Code trên nền web mà không cần mở trình duyệt. Việc này yêu cầu [Claude Code CLI](/en/quickstart). `/web-setup` đọc token `gh` cục bộ của bạn, liên kết nó với tài khoản Claude của bạn, và tạo một môi trường đám mây mặc định nếu bạn chưa có.

<Note>
  Các tổ chức bật [Zero Data Retention](/en/zero-data-retention) không thể dùng `/web-setup` hoặc các tính năng phiên đám mây khác. Nếu GitHub CLI chưa được cài đặt hoặc chưa xác thực, `/web-setup` sẽ mở luồng onboarding trên trình duyệt thay thế.
</Note>

<Steps>
  <Step title="Xác thực với GitHub CLI">
    Trong shell, xác thực GitHub CLI nếu bạn chưa làm:

    ```bash theme={null}
    gh auth login
    ```
  </Step>

  <Step title="Đăng nhập vào Claude">
    Trong Claude Code CLI, chạy `/login` để đăng nhập bằng tài khoản claude.ai của bạn. Bỏ qua bước này nếu bạn đã đăng nhập.
  </Step>

  <Step title="Chạy /web-setup">
    Trong Claude Code CLI, chạy:

    ```text theme={null}
    /web-setup
    ```

    Lệnh này đồng bộ token `gh` của bạn vào tài khoản Claude. Nếu bạn chưa có môi trường đám mây, `/web-setup` sẽ tạo một môi trường với mức truy cập mạng Trusted và không có setup script. Bạn có thể [chỉnh sửa môi trường hoặc thêm biến](/en/claude-code-on-the-web#configure-your-environment) sau đó. Khi `/web-setup` hoàn tất, bạn có thể bắt đầu các phiên đám mây từ terminal với [`--cloud`](/en/claude-code-on-the-web#from-terminal-to-web) hoặc thiết lập các tác vụ định kỳ với [`/schedule`](/en/routines).
  </Step>
</Steps>

## Bắt đầu một tác vụ

Với GitHub đã kết nối và một môi trường đã được tạo, bạn đã sẵn sàng gửi tác vụ.

<Steps>
  <Step title="Chọn một kho và nhánh">
    Từ [claude.ai/code](https://claude.ai/code) hoặc tab Code trong ứng dụng di động Claude, nhấp bộ chọn kho bên dưới ô nhập và chọn một kho để Claude làm việc. Mỗi kho hiển thị một bộ chọn nhánh. Thay đổi nó để bắt đầu Claude từ một nhánh tính năng thay vì nhánh mặc định. Bạn có thể thêm nhiều kho để làm việc trên chúng trong cùng một phiên.
  </Step>

  <Step title="Chọn một chế độ quyền">
    Menu chế độ bên cạnh ô nhập mặc định là **Accept edits**, tại đó Claude thực hiện thay đổi và đẩy một nhánh mà không dừng để chờ phê duyệt. Chuyển sang **Plan mode** nếu bạn muốn Claude đề xuất một hướng tiếp cận và chờ bạn đồng ý trước khi chỉnh sửa file. Phiên đám mây không cung cấp chế độ quyền Ask hay Bypass. Xem [Chế độ quyền (Permission modes)](/en/permission-modes) để có danh sách đầy đủ.
  </Step>

  <Step title="Mô tả tác vụ và gửi">
    Nhập mô tả những gì bạn muốn và nhấn Enter. Hãy cụ thể:

    * Nêu tên file hoặc hàm: "Add a README with setup instructions" hoặc "Fix the failing auth test in `tests/test_auth.py`" tốt hơn là "fix tests"
    * Dán output lỗi nếu bạn có
    * Mô tả hành vi mong muốn, không chỉ triệu chứng

    Claude clone các kho, chạy setup script nếu được cấu hình, và bắt đầu làm việc. Mỗi tác vụ có phiên riêng và nhánh riêng, nên bạn không cần chờ tác vụ này xong trước khi bắt đầu tác vụ khác.
  </Step>
</Steps>

## Điền sẵn cho phiên

Bạn có thể điền sẵn prompt, các kho, và môi trường cho một phiên mới bằng cách thêm các tham số query vào URL [claude.ai/code](https://claude.ai/code). Dùng cách này để xây dựng các tích hợp, chẳng hạn một nút trong công cụ theo dõi issue mở Claude Code với mô tả issue làm prompt.

| Tham số      | Mô tả                                                                                                                                                      |
| :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `prompt`       | Nội dung prompt điền sẵn trong ô nhập. Bí danh `q` cũng được chấp nhận.                                                                                         |
| `prompt_url`   | URL để lấy nội dung prompt, dành cho các prompt quá dài không thể nhúng vào query string. URL phải cho phép các yêu cầu cross-origin. Bị bỏ qua khi `prompt` cũng được đặt. |
| `repositories` | Danh sách các slug `owner/repo` phân tách bằng dấu phẩy để chọn sẵn. Bí danh `repo` cũng được chấp nhận.                                                      |
| `environment`  | Tên hoặc ID của [môi trường](#connect-github-and-create-an-environment) để chọn sẵn.                                                                         |

URL-encode từng giá trị. Ví dụ dưới đây mở biểu mẫu với một prompt và một kho đã được chọn sẵn:

```text theme={null}
https://claude.ai/code?prompt=Fix%20the%20login%20bug&repositories=acme/webapp
```

## Xem lại và lặp

Khi Claude hoàn tất, xem lại các thay đổi, để lại phản hồi trên các dòng cụ thể, và tiếp tục cho đến khi diff trông đúng.

<Steps>
  <Step title="Mở chế độ xem diff">
    Một chỉ báo diff hiển thị số dòng được thêm và xóa trong toàn phiên, ví dụ `+42 -18`. Chọn nó để mở chế độ xem diff, với danh sách file bên trái và các thay đổi bên phải.
  </Step>

  <Step title="Để lại nhận xét inline">
    Chọn bất kỳ dòng nào trong diff, gõ phản hồi của bạn, và nhấn Enter. Các nhận xét xếp hàng cho đến khi bạn gửi tin nhắn tiếp theo, rồi chúng được gộp cùng tin nhắn đó. Claude thấy "tại `src/auth.ts:47`, đừng bắt lỗi ở đây" cùng với chỉ dẫn chính của bạn, nên bạn không phải mô tả vấn đề ở đâu.
  </Step>

  <Step title="Tạo một pull request">
    Khi diff trông đúng, chọn **Create PR** ở đầu chế độ xem diff. Bạn có thể mở nó như một PR đầy đủ, một bản nháp (draft), hoặc chuyển tới trang compose của GitHub với tiêu đề và mô tả được tạo sẵn.
  </Step>

  <Step title="Tiếp tục lặp sau khi tạo PR">
    Phiên vẫn hoạt động sau khi PR được tạo. Dán output lỗi CI hoặc nhận xét của reviewer vào chat và yêu cầu Claude xử lý chúng. Để Claude tự động giám sát PR, xem [Tự động sửa pull request](/en/claude-code-on-the-web#auto-fix-pull-requests).
  </Step>
</Steps>

## Khắc phục sự cố khi thiết lập

### Không có kho nào xuất hiện sau khi kết nối GitHub

Một phiên đám mây có thể dùng bất kỳ kho nào mà tài khoản GitHub đã kết nối có thể thấy, bất kể Claude GitHub App được cài trên những kho nào. Nếu thiếu một kho, hãy xác minh tài khoản GitHub đã kết nối có quyền truy cập vào nó trên GitHub. Nếu bạn cũng muốn có [Tự động sửa (Auto-fix)](/en/claude-code-on-the-web#auto-fix-pull-requests) cho một kho, hãy cài App lên nó: trên github.com, mở **Settings → Applications → Claude → Configure** và xác minh kho được liệt kê dưới **Repository access**. Các kho riêng tư cần cùng ủy quyền như kho công khai.

### Trang chỉ hiển thị một nút đăng nhập GitHub

Phiên đám mây yêu cầu một tài khoản GitHub đã kết nối. Kết nối qua luồng trình duyệt ở trên, hoặc chạy `/web-setup` từ terminal nếu bạn dùng GitHub CLI. Nếu bạn không muốn kết nối GitHub, xem [Remote Control](/en/remote-control) để chạy Claude Code trên máy của mình và giám sát nó từ web.

### "Not available for the selected organization"

Các tổ chức Enterprise có thể cần một Owner bật Claude Code trên nền web. Liên hệ đội ngũ tài khoản Anthropic của bạn.

### `/web-setup` hiện "No commands match" hoặc "Unknown command"

`/web-setup` chạy bên trong Claude Code CLI, không phải shell của bạn. Khởi động `claude` trước, rồi gõ `/web-setup` tại dấu nhắc.

Nếu bạn gõ nó trong Claude Code và menu lệnh hiển thị `No commands match "/web-setup"`, hoặc khi gửi trả về `Unknown command: /web-setup`, lệnh bị ẩn vì một yêu cầu chưa được đáp ứng. Nguyên nhân thường là CLI của bạn cũ hơn v2.1.80 hoặc bạn đang xác thực bằng API key hay nhà cung cấp bên thứ ba thay vì subscription claude.ai. Chạy `claude update`, rồi `/login` để đăng nhập bằng tài khoản claude.ai của bạn.

### "Could not create a cloud environment" hoặc "No cloud environment available" khi dùng `--cloud` hoặc ultraplan

Các tính năng phiên từ xa tự động tạo một môi trường đám mây mặc định nếu bạn chưa có. Nếu bạn thấy "Could not create a cloud environment", việc tạo tự động đã thất bại. {/* max-version: 2.1.100 */}Nếu bạn thấy "No cloud environment available", CLI của bạn cũ hơn tính năng tạo tự động. Trong cả hai trường hợp, chạy `/web-setup` trong Claude Code CLI để tạo thủ công, hoặc truy cập [claude.ai/code](https://claude.ai/code) và làm theo bước **Create your environment** ở trên.

### Setup script thất bại

Setup script thoát với trạng thái khác không, điều này chặn phiên khởi động. Nguyên nhân phổ biến:

* Việc cài một package thất bại vì registry không nằm trong [mức truy cập mạng](/en/claude-code-on-the-web#access-levels) của bạn. `Trusted` bao phủ hầu hết các trình quản lý package; `None` chặn tất cả.
* Script tham chiếu một file hoặc đường dẫn không tồn tại trong bản clone mới.
* Một lệnh chạy được ở cục bộ cần cách gọi khác trên Ubuntu.

Để gỡ lỗi, thêm `set -x` ở đầu script để xem lệnh nào thất bại. Với các lệnh không quan trọng, thêm `|| true` để chúng không chặn phiên khởi động.

### Phiên mới bị treo hoặc hết thời gian khi thiết lập

Nếu các phiên mới đứng ở bước setup script hoặc thất bại với lỗi container chung chung trước khi script hoàn tất, script có khả năng vượt quá ngân sách thời gian khoảng năm phút để xây dựng [environment cache](/en/claude-code-on-the-web#environment-caching). Các bước nặng như kéo (pull) các Docker image lớn, đồng bộ toàn bộ cây phụ thuộc, hoặc tải model weight thường đẩy tổng vượt giới hạn, đặc biệt khi chúng chạy nối tiếp nhau.

Để khắc phục, hãy tinh gọn script để nó chắc chắn hoàn tất trong dưới năm phút:

* Chạy các bước cài độc lập song song với `&` và một `wait` cuối cùng thay vì chạy nối tiếp.
* Chuyển các bước tải lớn nhất ra khỏi setup script và vào một [SessionStart hook](/en/claude-code-on-the-web#setup-scripts-vs-sessionstart-hooks) để khởi chạy chúng ở nền, nhờ đó phiên trở nên dùng được trong khi chúng hoàn tất.
* Loại bỏ các vòng lặp retry ngủ (sleep) dài khỏi setup script, vì một vòng lặp retry bị kẹt sẽ tính vào ngân sách.

### Phiên vẫn chạy sau khi đóng tab

Đây là hành vi có chủ đích. Đóng tab hoặc điều hướng đi không dừng phiên. Nó tiếp tục chạy ở nền cho đến khi Claude hoàn tất tác vụ hiện tại, rồi ở trạng thái nghỉ. Từ thanh bên, bạn có thể [lưu trữ (archive) một phiên](/en/claude-code-on-the-web#archive-sessions) để ẩn nó khỏi danh sách, hoặc [xóa nó](/en/claude-code-on-the-web#delete-sessions) để loại bỏ vĩnh viễn.

## Các bước tiếp theo

Giờ khi bạn đã có thể gửi và xem lại tác vụ, các trang này bao quát những gì đến tiếp theo: bắt đầu phiên đám mây từ terminal, lên lịch công việc định kỳ, và cung cấp cho Claude các chỉ dẫn thường trực.

* [Sử dụng Claude Code trên nền web](/en/claude-code-on-the-web): tài liệu tham khảo đầy đủ, gồm teleport phiên về terminal, setup scripts, biến môi trường, và cấu hình mạng
* [Routines](/en/routines): tự động hóa công việc theo lịch, qua lời gọi API, hoặc phản hồi các sự kiện GitHub
* [CLAUDE.md](/en/memory): cung cấp cho Claude các chỉ dẫn và ngữ cảnh bền vững được nạp ở đầu mỗi phiên
* Cài đặt ứng dụng di động Claude cho [iOS](https://apps.apple.com/us/app/claude-by-anthropic/id6473753684) hoặc [Android](https://play.google.com/store/apps/details?id=com.anthropic.claude) để giám sát phiên từ điện thoại. Từ Claude Code CLI, `/mobile` hiển thị một mã QR.
