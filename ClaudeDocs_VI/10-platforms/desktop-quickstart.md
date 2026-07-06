> Nguồn: https://code.claude.com/docs/en/desktop-quickstart.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bắt đầu với ứng dụng desktop

> Cài đặt Claude Code trên desktop và bắt đầu phiên lập trình đầu tiên của bạn

Ứng dụng desktop mang lại cho bạn Claude Code với một giao diện đồ họa được xây dựng để chạy nhiều phiên song song cạnh nhau: một thanh bên để quản lý công việc song song, một bố cục kéo-và-thả với terminal tích hợp và trình chỉnh sửa tệp, xem xét diff trực quan, xem trước ứng dụng trực tiếp, giám sát GitHub PR với tự động merge, và các tác vụ theo lịch. Không cần terminal.

<CardGroup cols={3}>
  <Card title="Tải cho macOS" icon="apple" href="https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect?utm_source=claude_code&utm_medium=docs">
    Bản universal cho Intel và Apple Silicon
  </Card>

  <Card title="Tải cho Windows" icon="windows" href="https://claude.ai/api/desktop/win32/x64/setup/latest/redirect?utm_source=claude_code&utm_medium=docs">
    Cho bộ xử lý x64
  </Card>

  <Card title="Lấy Claude cho Linux (beta)" icon="linux" href="/en/desktop-linux">
    apt hoặc .deb cho Ubuntu và Debian
  </Card>
</CardGroup>

Đối với Windows ARM64, hãy tải [trình cài đặt ARM64](https://claude.ai/api/desktop/win32/arm64/setup/latest/redirect?utm_source=claude_code\&utm_medium=docs). Trên Linux, cài đặt bằng apt; xem [Claude Desktop trên Linux](/en/desktop-linux).

<Note>
  Claude Code yêu cầu một [gói đăng ký Pro, Max, Team, hoặc Enterprise](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=desktop_quickstart_pricing).
</Note>

Trang này hướng dẫn qua việc cài đặt ứng dụng và khởi động phiên đầu tiên của bạn. Nếu bạn đã thiết lập xong, xem [Dùng Claude Code Desktop](/en/desktop) để biết tài liệu tham khảo đầy đủ.

Ứng dụng desktop có ba tab:

* **Chat**: Trò chuyện chung không có quyền truy cập tệp, tương tự như claude.ai.
* **Cowork**: Một agent nền tự chủ làm việc trên các tác vụ trong một VM đám mây với môi trường riêng của nó. Nó có thể chạy độc lập trong khi bạn làm việc khác.
* **Code**: Một trợ lý lập trình tương tác với quyền truy cập trực tiếp vào các tệp cục bộ của bạn. Bạn xem xét và phê duyệt từng thay đổi theo thời gian thực.

Chat và Cowork được đề cập trong các [bài viết hỗ trợ Claude Desktop](https://support.claude.com/en/collections/16163169-claude-desktop). Trang này tập trung vào tab **Code**.

## Cài đặt

<Steps>
  <Step title="Cài đặt và đăng nhập">
    Trên macOS và Windows, tải trình cài đặt từ các liên kết ở trên và chạy nó. Trên Linux, làm theo các bước cài đặt trong [Claude Desktop trên Linux](/en/desktop-linux). Khởi chạy Claude từ thư mục Applications trên macOS, menu Start trên Windows, hoặc trình khởi chạy ứng dụng của bạn trên Linux, sau đó đăng nhập bằng tài khoản Anthropic của bạn.
  </Step>

  <Step title="Mở tab Code">
    Nhấp tab **Code** ở trên cùng chính giữa. Nếu nhấp Code nhắc bạn nâng cấp, bạn cần [đăng ký một gói trả phí](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=desktop_quickstart_upgrade) trước. Nếu nó nhắc bạn đăng nhập trực tuyến, hãy hoàn tất đăng nhập và khởi động lại ứng dụng. Nếu bạn thấy lỗi 403, xem [khắc phục sự cố xác thực](/en/desktop#403-or-authentication-errors-in-the-code-tab).
  </Step>
</Steps>

Ứng dụng desktop bao gồm Claude Code. Bạn không cần cài đặt Node.js hoặc CLI riêng. Để dùng `claude` từ terminal, hãy cài đặt CLI riêng. Xem [Bắt đầu với CLI](/en/quickstart).

## Bắt đầu phiên đầu tiên của bạn

Với tab Code đang mở, hãy chọn một dự án và giao cho Claude việc gì đó để làm.

<Steps>
  <Step title="Chọn một môi trường và thư mục">
    Chọn **Local** để chạy Claude trên máy của bạn dùng trực tiếp các tệp của bạn. Nhấp **Select folder** và chọn thư mục dự án của bạn.

    <Tip>
      Bắt đầu với một dự án nhỏ mà bạn biết rõ. Đó là cách nhanh nhất để thấy Claude Code có thể làm gì. Trên Windows, [Git](https://git-scm.com/downloads/win) phải được cài đặt để các phiên cục bộ hoạt động. Hầu hết các máy Mac bao gồm Git theo mặc định.
    </Tip>

    Bạn cũng có thể chọn:

    * **Remote**: Chạy các phiên trên hạ tầng đám mây của Anthropic vẫn tiếp tục ngay cả khi bạn đóng ứng dụng. Các phiên đám mây dùng cùng hạ tầng như [Claude Code trên web](/en/claude-code-on-the-web).
    * **SSH**: Kết nối tới một máy từ xa qua SSH, chẳng hạn như máy chủ của riêng bạn, VM đám mây, hoặc dev container. Desktop cài đặt Claude Code trên máy từ xa tự động vào lần đầu tiên bạn kết nối.
  </Step>

  <Step title="Chọn một model">
    Chọn một model từ menu thả xuống bên cạnh nút gửi. Xem [models](/en/model-config#available-models) để so sánh các model có sẵn. Bạn có thể thay đổi model sau từ cùng menu thả xuống.
  </Step>

  <Step title="Cho Claude biết cần làm gì">
    Gõ những gì bạn muốn Claude làm:

    * `Find a TODO comment and fix it`
    * `Add tests for the main function`
    * `Create a CLAUDE.md with instructions for this codebase`

    Một [phiên](/en/desktop#work-in-parallel-with-sessions) là một cuộc trò chuyện với Claude về mã của bạn. Mỗi phiên theo dõi ngữ cảnh và các thay đổi riêng của nó, nên bạn có thể làm việc trên nhiều tác vụ mà chúng không can thiệp lẫn nhau.
  </Step>

  <Step title="Xem xét và chấp nhận các thay đổi">
    Theo mặc định, tab Code bắt đầu ở [chế độ quyền Ask](/en/desktop#choose-a-permission-mode), nơi Claude đề xuất các thay đổi và chờ sự phê duyệt của bạn trước khi áp dụng chúng. Bạn sẽ thấy:

    1. Một [chế độ xem diff](/en/desktop#review-changes-with-diff-view) hiển thị chính xác những gì sẽ thay đổi trong mỗi tệp
    2. Các nút Accept/Reject để phê duyệt hoặc từ chối mỗi thay đổi
    3. Cập nhật theo thời gian thực khi Claude xử lý yêu cầu của bạn

    Nếu bạn từ chối một thay đổi, Claude sẽ hỏi bạn muốn tiến hành khác đi thế nào. Các tệp của bạn không bị sửa đổi cho đến khi bạn chấp nhận.
  </Step>
</Steps>

## Giờ thì sao?

Bạn đã thực hiện chỉnh sửa đầu tiên. Để biết tài liệu tham khảo đầy đủ về mọi thứ Desktop có thể làm, xem [Dùng Claude Code Desktop](/en/desktop). Đây là một số điều để thử tiếp theo.

**Ngắt và điều hướng.** Bạn có thể chuyển hướng Claude tại bất kỳ điểm nào. Nhấp nút stop để ngắt ngay lập tức, hoặc gõ một chỉnh sửa và nhấn **Enter** để gửi nó mà không dừng hành động đang chạy. Dù cách nào, bạn không phải chờ nó hoàn thành hoặc bắt đầu lại.

**Cho Claude thêm ngữ cảnh.** Gõ `@filename` trong ô prompt để kéo một tệp cụ thể vào cuộc trò chuyện, đính kèm hình ảnh và PDF bằng nút đính kèm, hoặc kéo và thả các tệp trực tiếp vào prompt. Càng nhiều ngữ cảnh Claude có, kết quả càng tốt. Xem [Thêm tệp và ngữ cảnh](/en/desktop#add-files-and-context-to-prompts).

**Dùng skill cho các tác vụ lặp lại.** Gõ `/` hoặc nhấp **+** → **Slash commands** để duyệt [các lệnh dựng sẵn](/en/commands), [skill tùy chỉnh](/en/skills), và các skill plugin. Skill là các prompt tái sử dụng mà bạn có thể gọi bất cứ khi nào cần, như danh sách kiểm tra đánh giá mã hoặc các bước triển khai.

**Xem xét các thay đổi trước khi commit.** Sau khi Claude sửa các tệp, một chỉ báo `+12 -1` xuất hiện. Nhấp vào nó để mở [chế độ xem diff](/en/desktop#review-changes-with-diff-view), xem xét các sửa đổi theo từng tệp, và bình luận trên các dòng cụ thể. Claude đọc các bình luận của bạn và sửa lại. Nhấp **Review code** để cho Claude tự đánh giá các diff và để lại các đề xuất nội tuyến.

**Điều chỉnh mức độ kiểm soát của bạn.** [Chế độ quyền](/en/desktop#choose-a-permission-mode) của bạn kiểm soát sự cân bằng. Ask permissions (mặc định) yêu cầu phê duyệt trước mỗi chỉnh sửa. Auto accept edits tự động chấp nhận các chỉnh sửa tệp để lặp nhanh hơn. Plan mode cho Claude vạch ra một cách tiếp cận mà không đụng vào bất kỳ tệp nào, hữu ích trước một cuộc tái cấu trúc lớn.

**Thêm plugin để có thêm khả năng.** Nhấp nút **+** bên cạnh ô prompt và chọn **Plugins** để duyệt và cài đặt [các plugin](/en/desktop#install-plugins) bổ sung skill, agent, máy chủ MCP, và nhiều hơn nữa.

**Sắp xếp không gian làm việc của bạn.** Kéo các ô chat, diff, terminal, tệp, và preview vào bất kỳ bố cục nào bạn muốn. Mở terminal bằng **Ctrl+\`** để chạy các lệnh cùng với phiên của bạn, hoặc nhấp vào một đường dẫn tệp để mở nó trong ô tệp. Xem [Sắp xếp không gian làm việc của bạn](/en/desktop#arrange-your-workspace).

**Xem trước ứng dụng của bạn.** Nhấp menu thả xuống **Preview** để chạy dev server của bạn trực tiếp trong desktop. Claude có thể xem ứng dụng đang chạy, kiểm thử các endpoint, kiểm tra log, và lặp lại trên những gì nó thấy. Xem [Xem trước ứng dụng của bạn](/en/desktop#preview-your-app).

**Theo dõi pull request của bạn.** Sau khi mở một PR, Claude Code giám sát kết quả kiểm tra CI và có thể tự động sửa các lỗi hoặc merge PR khi tất cả các kiểm tra vượt qua. Xem [Giám sát trạng thái pull request](/en/desktop#monitor-pull-request-status).

**Đặt Claude theo lịch.** Thiết lập [các tác vụ theo lịch](/en/desktop-scheduled-tasks) để chạy Claude tự động trên cơ sở lặp lại: một lần đánh giá mã hàng ngày mỗi sáng, một cuộc kiểm toán phụ thuộc hàng tuần, hoặc một bản tóm tắt lấy từ các công cụ được kết nối của bạn.

**Mở rộng quy mô khi bạn sẵn sàng.** Mở [các phiên song song](/en/desktop#work-in-parallel-with-sessions) từ thanh bên để làm việc trên nhiều tác vụ cùng lúc, mỗi tác vụ trong Git worktree riêng của nó, và mở [ô tasks](/en/desktop#watch-background-tasks) để theo dõi các subagent và các lệnh nền mà một phiên đang chạy. Mở một [side chat](/en/desktop#ask-a-side-question-without-derailing-the-session) để hỏi một câu hỏi mà không làm chệch hướng luồng chính. Gửi [công việc chạy lâu lên đám mây](/en/desktop#run-long-running-tasks-remotely) để nó tiếp tục ngay cả khi bạn đóng ứng dụng, hoặc [tiếp tục một phiên trên web hoặc trong IDE của bạn](/en/desktop#continue-in-another-surface) nếu một tác vụ mất nhiều thời gian hơn dự kiến. [Kết nối các công cụ bên ngoài](/en/desktop#extend-claude-code) như GitHub, Slack, và Linear để đưa quy trình làm việc của bạn lại với nhau.

## Đến từ CLI?

Desktop chạy cùng engine như CLI với một giao diện đồ họa. Bạn có thể chạy cả hai đồng thời trên cùng một dự án, và chúng chia sẻ cấu hình (các tệp CLAUDE.md, máy chủ MCP, hook, skill, và thiết lập). Để so sánh đầy đủ về tính năng, các tương đương của flag, và những gì không có trong Desktop, xem [So sánh CLI](/en/desktop#coming-from-the-cli).

## Tiếp theo là gì

* [Dùng Claude Code Desktop](/en/desktop): các chế độ quyền, phiên song song, chế độ xem diff, connector, và cấu hình doanh nghiệp
* [Khắc phục sự cố](/en/desktop#troubleshooting): giải pháp cho các lỗi thường gặp và vấn đề thiết lập
* [Thực hành tốt nhất](/en/best-practices): mẹo để viết prompt hiệu quả và tận dụng tối đa Claude Code
* [Quy trình làm việc thường gặp](/en/common-workflows): hướng dẫn cho việc gỡ lỗi, tái cấu trúc, kiểm thử, và nhiều hơn nữa
