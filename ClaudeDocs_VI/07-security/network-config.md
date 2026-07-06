> Nguồn: https://code.claude.com/docs/en/network-config.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Cấu hình mạng cho doanh nghiệp

> Cấu hình Claude Code cho môi trường doanh nghiệp với proxy server, Certificate Authority (CA) tùy chỉnh, và xác thực mutual Transport Layer Security (mTLS).

Claude Code hỗ trợ nhiều cấu hình mạng và bảo mật cấp doanh nghiệp thông qua các biến môi trường (environment variable). Bao gồm định tuyến lưu lượng qua proxy server của công ty, tin cậy các Certificate Authority (CA) tùy chỉnh, và xác thực bằng chứng chỉ mutual Transport Layer Security (mTLS) để tăng cường bảo mật.

<Note>
  Tất cả các biến môi trường được trình bày trên trang này cũng có thể được cấu hình trong [`settings.json`](/en/settings).
</Note>

## Cấu hình proxy

### Biến môi trường

Claude Code tuân theo các biến môi trường proxy tiêu chuẩn:

```bash theme={null}
# HTTPS proxy (khuyến nghị)
export HTTPS_PROXY=https://proxy.example.com:8080

# HTTP proxy (nếu không có HTTPS)
export HTTP_PROXY=http://proxy.example.com:8080

# Bỏ qua proxy cho các yêu cầu cụ thể - định dạng phân tách bằng dấu cách
export NO_PROXY="localhost 192.168.1.1 example.com .example.com"
# Bỏ qua proxy cho các yêu cầu cụ thể - định dạng phân tách bằng dấu phẩy
export NO_PROXY="localhost,192.168.1.1,example.com,.example.com"
# Bỏ qua proxy cho tất cả các yêu cầu
export NO_PROXY="*"
```

<Note>
  Claude Code không hỗ trợ SOCKS proxy.
</Note>

### Xác thực cơ bản (Basic authentication)

Nếu proxy của bạn yêu cầu xác thực cơ bản, hãy đưa thông tin đăng nhập vào trong URL của proxy:

```bash theme={null}
export HTTPS_PROXY=http://username:password@proxy.example.com:8080
```

<Warning>
  Tránh hardcode mật khẩu trong script. Thay vào đó hãy dùng biến môi trường hoặc kho lưu trữ thông tin đăng nhập an toàn.
</Warning>

<Tip>
  Đối với các proxy yêu cầu xác thực nâng cao (NTLM, Kerberos, v.v.), hãy cân nhắc sử dụng dịch vụ LLM Gateway hỗ trợ phương thức xác thực của bạn.
</Tip>

## Kho chứng chỉ CA (CA certificate store)

Theo mặc định, Claude Code tin cậy cả bộ chứng chỉ Mozilla CA đi kèm và kho chứng chỉ của hệ điều hành. Việc đọc kho chứng chỉ của hệ điều hành yêu cầu một runtime có `tls.getCACertificates`: bản cài đặt native luôn có sẵn tính năng này, còn các bản cài qua npm cần Node 22.15 trở lên. Trên các phiên bản Node cũ hơn, chỉ bộ chứng chỉ đi kèm và `NODE_EXTRA_CA_CERTS` được áp dụng. Các proxy kiểm tra TLS (TLS-inspection) cấp doanh nghiệp như CrowdStrike Falcon và Zscaler hoạt động mà không cần cấu hình bổ sung khi chứng chỉ gốc (root certificate) của chúng được cài đặt trong kho tin cậy của hệ điều hành và runtime có thể đọc được.

`CLAUDE_CODE_CERT_STORE` nhận một danh sách các nguồn phân tách bằng dấu phẩy. Các giá trị được nhận diện là `bundled` cho bộ Mozilla CA đi kèm với Claude Code và `system` cho kho tin cậy của hệ điều hành. Giá trị mặc định là `bundled,system`.

Để chỉ tin cậy bộ Mozilla CA đi kèm:

```bash theme={null}
export CLAUDE_CODE_CERT_STORE=bundled
```

Để chỉ tin cậy kho chứng chỉ của hệ điều hành:

```bash theme={null}
export CLAUDE_CODE_CERT_STORE=system
```

<Note>
  `CLAUDE_CODE_CERT_STORE` không có key schema dành riêng trong `settings.json`. Hãy thiết lập nó thông qua khối `env` trong `~/.claude/settings.json` hoặc trực tiếp trong môi trường tiến trình (process environment).
</Note>

## Chứng chỉ CA tùy chỉnh

Nếu môi trường doanh nghiệp của bạn sử dụng CA tùy chỉnh, hãy cấu hình Claude Code để tin cậy nó trực tiếp:

```bash theme={null}
export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem
```

## Xác thực mTLS

Đối với các môi trường doanh nghiệp yêu cầu xác thực bằng chứng chỉ client (client certificate):

```bash theme={null}
# Chứng chỉ client để xác thực
export CLAUDE_CODE_CLIENT_CERT=/path/to/client-cert.pem

# Khóa riêng (private key) của client
export CLAUDE_CODE_CLIENT_KEY=/path/to/client-key.pem

# Tùy chọn: Passphrase cho khóa riêng đã được mã hóa
export CLAUDE_CODE_CLIENT_KEY_PASSPHRASE="your-passphrase"
```

## Yêu cầu về quyền truy cập mạng

Claude Code cần quyền truy cập tới các URL sau. Hãy đưa chúng vào danh sách cho phép (allowlist) trong cấu hình proxy và các quy tắc tường lửa, đặc biệt là trong các môi trường mạng bị đóng gói container (containerized) hoặc bị hạn chế.

| URL                            | Cần thiết cho                                                                                                                                                                                 |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `api.anthropic.com`            | Các yêu cầu Claude API                                                                                                                                                                        |
| `claude.ai`                    | Xác thực tài khoản claude.ai                                                                                                                                                                  |
| `platform.claude.com`          | Xác thực tài khoản Anthropic Console                                                                                                                                                          |
| `downloads.claude.ai`          | Tải các file thực thi của plugin; bản cài đặt native và trình tự động cập nhật (auto-updater) native                                                                                          |
| `storage.googleapis.com`       | {/* max-version: 2.1.115 */}Bản cài đặt native và trình tự động cập nhật native trên các phiên bản trước 2.1.116                                                                              |
| `bridge.claudeusercontent.com` | Cầu nối WebSocket của tiện ích [Claude in Chrome](/en/chrome)                                                                                                                                 |
| `*.claudeusercontent.com`      | Xem [artifacts](/en/artifacts) trên claude.ai. Trình xem tải nội dung của từng artifact từ một tên miền phụ sandbox của origin này. Cần thiết trong trình duyệt của trình xem, không phải bản thân CLI |
| `raw.githubusercontent.com`    | Nguồn cấp changelog cho [`/release-notes`](/en/commands) và ghi chú phát hành hiển thị sau khi cập nhật; số lượt cài đặt của plugin marketplace                                               |

Nếu bạn cài đặt Claude Code thông qua npm hoặc tự quản lý việc phân phối binary của mình, người dùng cuối có thể không cần quyền truy cập tới `downloads.claude.ai` hoặc `storage.googleapis.com`.

Theo mặc định, Claude Code cũng gửi dữ liệu telemetry vận hành tùy chọn, mà bạn có thể tắt bằng các biến môi trường. Xem [Telemetry services](/en/data-usage#telemetry-services) để biết cách tắt nó trước khi hoàn thiện danh sách cho phép của bạn.

Khi sử dụng [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry), hoặc một phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, lưu lượng model và việc xác thực sẽ đi tới nhà cung cấp hoặc gateway của bạn thay vì `api.anthropic.com`, `claude.ai`, hoặc `platform.claude.com`. Công cụ WebFetch vẫn gọi `api.anthropic.com` cho [kiểm tra an toàn tên miền](/en/data-usage#webfetch-domain-safety-check) của nó trừ khi bạn thiết lập `skipWebFetchPreflight: true` trong [settings](/en/settings).

[Claude Code on the web](/en/claude-code-on-the-web) và [Code Review](/en/code-review) kết nối tới các kho lưu trữ của bạn từ hạ tầng do Anthropic quản lý. Nếu tổ chức GitHub Enterprise Cloud của bạn hạn chế quyền truy cập theo địa chỉ IP, hãy bật [tính năng kế thừa danh sách IP cho phép đối với các GitHub App đã cài đặt](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization#allowing-access-by-github-apps). Claude GitHub App đăng ký các dải IP của nó, nên việc bật thiết lập này cho phép truy cập mà không cần cấu hình thủ công. Để [thêm các dải IP vào danh sách cho phép của bạn theo cách thủ công](https://docs.github.com/en/enterprise-cloud@latest/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-allowed-ip-addresses-for-your-organization#adding-an-allowed-ip-address) thay vào đó, hoặc để cấu hình các tường lửa khác, xem [Địa chỉ IP của Anthropic API](https://platform.claude.com/docs/en/api/ip-addresses).

Đối với các phiên bản [GitHub Enterprise Server](/en/github-enterprise-server) tự lưu trữ (self-hosted) nằm sau tường lửa, hãy đưa cùng các [Địa chỉ IP của Anthropic API](https://platform.claude.com/docs/en/api/ip-addresses) vào danh sách cho phép để hạ tầng của Anthropic có thể tiếp cận host GHES của bạn nhằm clone các kho lưu trữ và đăng bình luận review.

## Tài nguyên bổ sung

* [Cài đặt Claude Code](/en/settings)
* [Tham chiếu biến môi trường](/en/env-vars)
* [Hướng dẫn khắc phục sự cố](/en/troubleshooting)
