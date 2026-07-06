> Nguồn: https://code.claude.com/docs/en/github-enterprise-server.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Claude Code với GitHub Enterprise Server

> Kết nối Claude Code với phiên bản GitHub Enterprise Server tự host của bạn để chạy phiên web, đánh giá code, và plugin marketplace.

<Note>
  Hỗ trợ GitHub Enterprise Server có sẵn cho các gói Team và Enterprise.
</Note>

Hỗ trợ GitHub Enterprise Server (GHES) cho phép tổ chức của bạn dùng Claude Code với các kho được host trên phiên bản GitHub tự quản lý của bạn thay vì github.com. Khi một Owner đã kết nối phiên bản GHES, các developer có thể chạy phiên web, nhận đánh giá code tự động, và cài plugin từ các marketplace nội bộ mà không cần cấu hình theo từng kho.

Với các kho trên github.com, xem [Claude Code trên nền web](/en/claude-code-on-the-web) và [Code Review](/en/code-review). Để chạy Claude trong hạ tầng CI của riêng bạn, xem [GitHub Actions](/en/github-actions).

## Những gì hoạt động với GitHub Enterprise Server

Bảng dưới đây cho thấy các tính năng Claude Code nào hỗ trợ GHES và bất kỳ khác biệt nào so với hành vi trên github.com.

| Tính năng                | Hỗ trợ GHES    | Ghi chú                                                                                                          |
| :--------------------- | :-------------- | :----------------------------------------------------------------------------------------------------------------------------- |
| Claude Code trên nền web | ✅ Được hỗ trợ     | Một Owner kết nối phiên bản GHES một lần; developer dùng `claude --cloud` hoặc [claude.ai/code](https://claude.ai/code) như thường lệ |
| Code Review            | ✅ Được hỗ trợ     | Đánh giá PR tự động giống như github.com                                                                                        |
| Claude Security        | ✅ Được hỗ trợ     | Có sẵn ở bản public beta cho các gói Enterprise tại [claude.ai/security](https://claude.ai/security)                              |
| Phiên teleport      | ✅ Được hỗ trợ     | Di chuyển phiên giữa web và terminal với `--teleport`                                                                       |
| Plugin marketplace    | ✅ Được hỗ trợ     | Dùng URL git đầy đủ thay vì dạng viết tắt `owner/repo`                                                                            |
| Chỉ số đóng góp   | ✅ Được hỗ trợ     | Được gửi qua webhook tới [dashboard analytics](/en/analytics)                                                             |
| GitHub Actions         | ✅ Được hỗ trợ     | Cần thiết lập workflow thủ công; `/install-github-app` chỉ dành cho github.com                                                       |
| GitHub MCP server      | ❌ Không hỗ trợ | GitHub MCP server không hoạt động với các phiên bản GHES                                                        |

## Thiết lập cho admin

Một Owner kết nối phiên bản GHES của bạn với Claude Code một lần. Sau đó, các developer trong tổ chức của bạn có thể dùng các kho GHES mà không cần cấu hình bổ sung. Bạn cần vai trò Owner hoặc Primary Owner trong tổ chức Claude của mình và quyền tạo GitHub App trên phiên bản GHES của bạn.

Thiết lập có hướng dẫn tạo một GitHub App manifest và chuyển hướng bạn tới phiên bản GHES để tạo app chỉ trong một cú nhấp. Nếu môi trường của bạn chặn luồng chuyển hướng, có một [thiết lập thủ công thay thế](#manual-setup).

<Steps>
  <Step title="Mở thiết lập admin Claude Code">
    Vào [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) và tìm mục GitHub Enterprise Server.
  </Step>

  <Step title="Bắt đầu thiết lập có hướng dẫn">
    Nhấp **Connect**. Nhập một tên hiển thị cho kết nối và hostname GHES của bạn, ví dụ `github.example.com`. Nếu phiên bản GHES của bạn dùng chứng chỉ tự ký hoặc certificate authority riêng, hãy dán chứng chỉ CA vào trường tùy chọn.
  </Step>

  <Step title="Tạo GitHub App">
    Nhấp **Continue to GitHub Enterprise**. Trình duyệt của bạn chuyển hướng tới phiên bản GHES với một app manifest được điền sẵn. Xem lại cấu hình và nhấp **Create GitHub App**. GHES chuyển hướng bạn trở lại Claude với credential của app được lưu tự động.
  </Step>

  <Step title="Cài app lên các kho của bạn">
    Từ trang GitHub App trên phiên bản GHES của bạn, cài app lên các kho hoặc tổ chức bạn muốn Claude truy cập. Bạn có thể bắt đầu với một tập con và thêm nhiều hơn sau.
  </Step>

  <Step title="Bật các tính năng">
    Quay lại [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) và bật [Code Review](/en/code-review#set-up-code-review), Claude Security, và [chỉ số đóng góp](/en/analytics#enable-contribution-metrics) cho các kho GHES của bạn dùng cùng cấu hình như github.com.
  </Step>
</Steps>

### Quyền của GitHub App

Manifest cấu hình GitHub App với các quyền và sự kiện webhook mà Claude cần cho phiên web, Code Review, Claude Security, và chỉ số đóng góp:

| Quyền       | Truy cập         | Dùng cho                                    |
| :--------------- | :------------- | :------------------------------------------ |
| Contents         | Read and write | Clone kho và đẩy nhánh   |
| Pull requests    | Read and write | Tạo PR và đăng nhận xét đánh giá    |
| Issues           | Read and write | Phản hồi các mention issue                |
| Checks           | Read and write | Đăng các check run Code Review              |
| Actions          | Read           | Đọc trạng thái CI cho auto-fix              |
| Repository hooks | Read and write | Nhận webhook cho chỉ số đóng góp |
| Metadata         | Read           | Bắt buộc bởi GitHub cho tất cả các app             |

App đăng ký (subscribe) các sự kiện `pull_request`, `issue_comment`, `pull_request_review_comment`, `pull_request_review`, và `check_run`.

### Thiết lập thủ công

Nếu luồng chuyển hướng có hướng dẫn bị chặn bởi cấu hình mạng của bạn, hãy nhấp **Add manually** thay vì Connect. Tạo một GitHub App trên phiên bản GHES của bạn với [các quyền và sự kiện ở trên](#github-app-permissions), rồi nhập credential của app vào biểu mẫu: hostname, OAuth client ID và secret, GitHub App ID, client ID, client secret, webhook secret, và private key.

### Yêu cầu về mạng

Phiên bản GHES của bạn phải tiếp cận được từ hạ tầng Anthropic để Claude có thể clone kho và đăng nhận xét đánh giá. Nếu phiên bản GHES của bạn nằm sau tường lửa, hãy đưa vào danh sách cho phép (allowlist) các [địa chỉ IP của Anthropic API](https://platform.claude.com/docs/en/api/ip-addresses).

## Quy trình làm việc của developer

Khi một Owner đã kết nối phiên bản GHES, không cần cấu hình phía developer. Claude Code tự động phát hiện hostname GHES của bạn từ git remote trong thư mục làm việc của bạn.

Clone một kho từ phiên bản GHES của bạn như bình thường:

```bash theme={null}
git clone git@github.example.com:platform/api-service.git
cd api-service
```

Sau đó bắt đầu một phiên web. Claude phát hiện host GHES từ git remote của bạn và định tuyến phiên qua phiên bản đã cấu hình của tổ chức bạn:

```bash theme={null}
claude --cloud "Add retry logic to the payment webhook handler"
```

Phiên chạy trên hạ tầng Anthropic, clone kho của bạn từ GHES, và đẩy các thay đổi trở lại một nhánh. Theo dõi tiến độ với `/tasks` hoặc tại [claude.ai/code](https://claude.ai/code). Xem [Claude Code trên nền web](/en/claude-code-on-the-web) để có quy trình phiên đám mây đầy đủ bao gồm xem lại diff, auto-fix, và routines.

### Teleport phiên về terminal của bạn

Kéo một phiên web vào terminal cục bộ của bạn với `claude --teleport`. Teleport xác minh bạn đang ở trong một bản checkout của cùng kho GHES trước khi lấy nhánh và nạp lịch sử phiên. Xem [yêu cầu teleport](/en/claude-code-on-the-web#teleport-requirements) để biết chi tiết.

## Plugin marketplace trên GHES

Host các plugin marketplace trên phiên bản GHES của bạn để phân phối công cụ nội bộ trong toàn tổ chức. Cấu trúc marketplace giống hệt các marketplace được host trên github.com; khác biệt duy nhất là cách bạn tham chiếu chúng.

### Thêm một marketplace GHES

Dạng viết tắt `owner/repo` luôn trỏ tới github.com. Với các marketplace được host trên GHES, dùng URL git đầy đủ:

```bash theme={null}
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

URL HTTPS cũng hoạt động:

```bash theme={null}
/plugin marketplace add https://github.example.com/platform/claude-plugins.git
```

Xem [Tạo và phân phối một plugin marketplace](/en/plugin-marketplaces) để có hướng dẫn đầy đủ về việc xây dựng marketplace.

### Đưa các marketplace GHES vào allowlist trong managed settings

Nếu tổ chức của bạn dùng [managed settings](/en/settings) để giới hạn các marketplace mà developer có thể thêm, hãy dùng loại nguồn `hostPattern` để cho phép tất cả các marketplace từ phiên bản GHES của bạn mà không cần liệt kê từng kho:

```json theme={null}
{
  "strictKnownMarketplaces": [
    {
      "source": "hostPattern",
      "hostPattern": "^github\\.example\\.com$"
    }
  ]
}
```

Bạn cũng có thể đăng ký trước các marketplace cho developer để chúng xuất hiện mà không cần thiết lập thủ công. Ví dụ này làm cho một marketplace công cụ nội bộ có sẵn trong toàn tổ chức:

```json theme={null}
{
  "extraKnownMarketplaces": {
    "internal-tools": {
      "source": {
        "source": "git",
        "url": "git@github.example.com:platform/claude-plugins.git"
      }
    }
  }
}
```

Xem tài liệu tham khảo thiết lập [strictKnownMarketplaces](/en/settings#strictknownmarketplaces) và [extraKnownMarketplaces](/en/settings#extraknownmarketplaces) để có schema đầy đủ.

## Giới hạn

Một vài tính năng hành xử khác trên GHES so với github.com. [Bảng tính năng](#what-works-with-github-enterprise-server) tóm tắt mức hỗ trợ; mục này bao quát các giải pháp thay thế.

* **Lệnh `/install-github-app`**: làm theo luồng [thiết lập admin](#admin-setup) trên claude.ai thay thế. Nếu bạn cũng muốn có các workflow GitHub Actions trên GHES, hãy điều chỉnh [workflow ví dụ](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) một cách thủ công.
* **GitHub MCP server**: dùng `gh` CLI được cấu hình cho host GHES của bạn thay thế. Chạy `gh auth login --hostname github.example.com` để xác thực, rồi Claude có thể dùng các lệnh `gh` trong các phiên.

## Khắc phục sự cố

### Phiên web thất bại khi clone kho

Nếu `claude --cloud` thất bại với lỗi clone, hãy xác minh rằng một Owner đã hoàn tất thiết lập cho phiên bản GHES của bạn và rằng GitHub App được cài trên kho bạn đang làm việc. Yêu cầu Owner đã kết nối phiên bản đó xác nhận rằng hostname được đăng ký trong thiết lập Claude khớp với hostname trong git remote của bạn.

### Thêm marketplace thất bại với lỗi chính sách

Nếu `/plugin marketplace add` bị chặn với URL GHES của bạn, tổ chức của bạn đã giới hạn các nguồn marketplace. Yêu cầu admin của bạn thêm một mục `hostPattern` cho hostname GHES của bạn trong [managed settings](#allowlist-ghes-marketplaces-in-managed-settings).

### Phiên bản GHES không tiếp cận được

Nếu các đánh giá hoặc phiên web hết thời gian, phiên bản GHES của bạn có thể không tiếp cận được từ hạ tầng Anthropic. Xác nhận tường lửa của bạn cho phép các kết nối đến từ các [địa chỉ IP của Anthropic API](https://platform.claude.com/docs/en/api/ip-addresses).

## Tài nguyên liên quan

Các trang này bao quát sâu hơn các tính năng được tham chiếu xuyên suốt hướng dẫn này:

* [Claude Code trên nền web](/en/claude-code-on-the-web): chạy các phiên Claude Code trên hạ tầng đám mây
* [Code Review](/en/code-review): đánh giá PR tự động
* [Plugin marketplace](/en/plugin-marketplaces): xây dựng và phân phối các danh mục plugin
* [Analytics](/en/analytics): theo dõi mức sử dụng và chỉ số đóng góp
* [Managed settings](/en/settings): cấu hình chính sách trong toàn tổ chức
* [Cấu hình mạng](/en/network-config): yêu cầu về tường lửa và allowlist IP
