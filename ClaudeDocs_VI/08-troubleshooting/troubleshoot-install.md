> Nguồn: https://code.claude.com/docs/en/troubleshoot-install.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Xử lý sự cố cài đặt và đăng nhập

> Khắc phục các lỗi command not found, PATH, quyền truy cập, mạng và xác thực khi cài đặt hoặc đăng nhập vào Claude Code.

Nếu cài đặt thất bại hoặc bạn không đăng nhập được, hãy tìm lỗi của bạn bên dưới. Với các vấn đề khi chạy sau khi Claude Code đã hoạt động, xem [Xử lý sự cố](/en/troubleshooting). Với các vấn đề về cấu hình như cài đặt không áp dụng hoặc hook không kích hoạt, xem [Gỡ lỗi cấu hình của bạn](/en/debug-your-config).

## Tìm lỗi của bạn

So khớp thông báo lỗi hoặc triệu chứng bạn đang thấy với một cách khắc phục:

| Điều bạn thấy                                                                                          | Giải pháp                                                                                                                                      |
| :---------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| `command not found: claude` hoặc `'claude' is not recognized`                                           | [Sửa PATH của bạn](#command-not-found-claude-after-installation)                                                                                 |
| `syntax error near unexpected token '<'`                                                              | [Script cài đặt trả về HTML](#install-script-returns-html-instead-of-a-shell-script)                                                         |
| `curl: (22) The requested URL returned error: 403`                                                    | [Script cài đặt trả về 403](#install-script-returns-html-instead-of-a-shell-script)                                                          |
| `curl: (23)` hoặc `curl: (56) Failure writing output to destination`                                    | [Kiểm tra kết nối hoặc dùng trình cài đặt thay thế](#curl-56-failure-writing-output-to-destination)                                          |
| `Killed` khi cài trên Linux, hoặc `Installation was killed before it could finish (exit code 137)` | [Giải phóng bộ nhớ hoặc thêm swap space](#install-killed-on-low-memory-linux-servers)                                                                  |
| `TLS connect error` hoặc `SSL/TLS secure channel`                                                       | [Cập nhật chứng chỉ CA](#tls-or-ssl-connection-errors)                                                                                       |
| `Failed to fetch version` hoặc không kết nối được máy chủ tải xuống                                 | [Kiểm tra cài đặt mạng và proxy](#check-network-connectivity)                                                                               |
| `irm is not recognized` hoặc `&& is not valid`                                                          | [Dùng đúng lệnh cho shell của bạn](#wrong-install-command-on-windows)                                                                     |
| `Cask 'claude-code' is unavailable: No Cask with this name exists`                                    | [Cập nhật Homebrew](#homebrew-cask-unavailable-or-outdated)                                                                                     |
| `'bash' is not recognized as the name of a cmdlet`                                                    | [Dùng lệnh cài đặt cho Windows](#wrong-install-command-on-windows)                                                                        |
| `A parameter cannot be found that matches parameter name 'fsSL'`                                      | [Dùng lệnh cài đặt cho Windows](#wrong-install-command-on-windows)                                                                        |
| `Claude Code on Windows requires either Git for Windows (for bash) or PowerShell`                     | [Cài một shell](#claude-code-on-windows-requires-either-git-for-windows-for-bash-or-powershell)                                             |
| `Claude Code does not support 32-bit Windows`                                                         | [Mở Windows PowerShell, không phải mục x86](#claude-code-does-not-support-32-bit-windows)                                                    |
| `The process cannot access the file ... because it is being used by another process`                  | [Xóa thư mục downloads và thử lại](#the-process-cannot-access-the-file-during-windows-install)                                            |
| `Error loading shared library`                                                                        | [Sai biến thể binary cho hệ thống của bạn](#linux-musl-or-glibc-binary-mismatch)                                                                  |
| `Illegal instruction`                                                                                 | [Không khớp kiến trúc hoặc tập lệnh CPU](#illegal-instruction)                                                                          |
| `cannot execute binary file: Exec format error` trong WSL                                                | [Hồi quy binary native trên WSL1](#exec-format-error-on-wsl1)                                                                                   |
| Trình cài đặt PowerShell hoàn tất nhưng không tìm thấy `claude` hoặc hiện phiên bản cũ                      | [Thêm thư mục cài đặt vào PATH của bạn](#verify-your-path), rồi mở terminal mới                                                         |
| `dyld: cannot load`, `dyld: Symbol not found`, hoặc `Abort trap` trên macOS                               | [Binary không tương thích](#dyld-cannot-load-on-macos)                                                                                          |
| `Invoke-Expression: Missing argument in parameter list`                                               | [Script cài đặt trả về HTML](#install-script-returns-html-instead-of-a-shell-script)                                                         |
| `App unavailable in region`                                                                           | Claude Code không khả dụng ở quốc gia của bạn. Xem [các quốc gia được hỗ trợ](https://www.anthropic.com/supported-countries).                       |
| `unable to get local issuer certificate`                                                              | [Cấu hình chứng chỉ CA doanh nghiệp](#tls-or-ssl-connection-errors)                                                                            |
| `OAuth error` hoặc `403 Forbidden`                                                                      | [Sửa lỗi xác thực](#login-and-authentication)                                                                                               |
| `Could not load the default credentials` hoặc `Could not load credentials from any providers`           | [Thông tin xác thực Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry](#bedrock-agent-platform-or-foundry-credentials-not-loading) |
| `ChainedTokenCredential authentication failed` hoặc `CredentialUnavailableError`                        | [Thông tin xác thực Amazon Bedrock, Google Cloud's Agent Platform, hoặc Microsoft Foundry](#bedrock-agent-platform-or-foundry-credentials-not-loading) |
| `API Error: 500`, `529 Overloaded`, `429`, hoặc các lỗi 4xx và 5xx khác không liệt kê ở trên               | Xem [Tham chiếu lỗi](/en/errors)                                                                                                         |

Nếu vấn đề của bạn không được liệt kê, hãy thực hiện lần lượt các bước kiểm tra chẩn đoán bên dưới để thu hẹp nguyên nhân.

<Tip>
  Nếu bạn muốn bỏ qua hoàn toàn terminal, [ứng dụng Claude Code Desktop](/en/desktop-quickstart) cho phép bạn cài đặt và sử dụng Claude Code thông qua giao diện đồ họa. Tải về cho [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect?utm_source=claude_code\&utm_medium=docs), [Windows](https://claude.com/download?utm_source=claude_code\&utm_medium=docs), hoặc [Linux](https://claude.com/download?utm_source=claude_code\&utm_medium=docs) và bắt đầu code mà không cần bất kỳ thiết lập dòng lệnh nào.
</Tip>

## Chạy các bước kiểm tra chẩn đoán

### Kiểm tra kết nối mạng

Trình cài đặt tải xuống từ `downloads.claude.ai`. Xác minh bạn có thể truy cập được:

```bash theme={null}
curl -sI https://downloads.claude.ai/claude-code-releases/latest
```

Trong PowerShell, hãy chạy `curl.exe -sI` thay vì. PowerShell tạo alias `curl` thành `Invoke-WebRequest`, vốn từ chối các flag `-sI`.

Một dòng `HTTP/2 200` nghĩa là bạn đã kết nối tới máy chủ. Nếu bạn không thấy output nào, thấy `Could not resolve host`, hoặc kết nối bị timeout, thì mạng của bạn đang chặn kết nối. Các nguyên nhân phổ biến:

* Tường lửa hoặc proxy doanh nghiệp chặn `downloads.claude.ai`
* Hạn chế mạng theo khu vực: thử VPN hoặc mạng khác
* Vấn đề TLS/SSL: cập nhật chứng chỉ CA của hệ thống, hoặc kiểm tra xem `HTTPS_PROXY` có được cấu hình hay không

Nếu bạn ở sau một proxy doanh nghiệp, hãy đặt `HTTPS_PROXY` và `HTTP_PROXY` thành địa chỉ proxy của bạn trước khi cài đặt. Hỏi đội IT về URL proxy nếu bạn không biết, hoặc kiểm tra cài đặt proxy của trình duyệt.

Ví dụ này đặt cả hai biến proxy, rồi chạy trình cài đặt qua proxy của bạn:

<Tabs>
  <Tab title="macOS/Linux">
    ```bash theme={null}
    export HTTP_PROXY=http://proxy.example.com:8080
    export HTTPS_PROXY=http://proxy.example.com:8080
    curl -fsSL https://claude.ai/install.sh | bash
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    $env:HTTP_PROXY = 'http://proxy.example.com:8080'
    $env:HTTPS_PROXY = 'http://proxy.example.com:8080'
    irm https://claude.ai/install.ps1 | iex
    ```
  </Tab>
</Tabs>

### Xác minh PATH của bạn

Nếu cài đặt thành công nhưng bạn gặp lỗi `command not found` hoặc `not recognized` khi chạy `claude`, thì thư mục cài đặt không nằm trong PATH của bạn. Shell của bạn tìm kiếm chương trình trong các thư mục được liệt kê trong PATH, và trình cài đặt đặt `claude` tại `~/.local/bin/claude` trên macOS/Linux hoặc `%USERPROFILE%\.local\bin\claude.exe` trên Windows.

<Note>
  [Tiện ích mở rộng VS Code](/en/vs-code) không đặt `claude` ở vị trí này. Nó đóng gói một bản sao riêng của CLI bên trong thư mục tiện ích mở rộng cho panel chat của riêng nó và không thêm vào PATH. Nếu bạn chỉ cài tiện ích mở rộng, `~/.local/bin/claude` sẽ không tồn tại. Chạy [bản cài đặt độc lập](/en/setup) để dùng `claude` từ terminal, rồi tiếp tục bên dưới.
</Note>

Kiểm tra xem thư mục cài đặt có nằm trong PATH của bạn không bằng cách liệt kê các mục PATH và lọc theo `local/bin`:

<Tabs>
  <Tab title="macOS/Linux">
    ```bash theme={null}
    echo $PATH | tr ':' '\n' | grep -Fx "$HOME/.local/bin"
    ```

    Nếu lệnh này in ra `/Users/you/.local/bin` hoặc `/home/you/.local/bin`, thì thư mục đã nằm trong PATH của bạn và bạn có thể bỏ qua đến [Kiểm tra các bản cài đặt xung đột](#check-for-conflicting-installations). Nếu không có output nào, hãy thêm nó vào cấu hình shell của bạn.

    Đối với Zsh, mặc định trên macOS:

    ```bash theme={null}
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```

    Đối với Bash, mặc định trên hầu hết các bản phân phối Linux:

    ```bash theme={null}
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```

    Hoặc, đóng và mở lại terminal của bạn.

    Đối với các shell khác như fish hoặc Nushell, hãy thêm `~/.local/bin` vào PATH bằng cú pháp cấu hình riêng của shell đó, rồi khởi động lại terminal.

    Xác minh cách sửa đã có hiệu lực:

    ```bash theme={null}
    claude --version
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    $env:PATH -split ';' | Select-String '\.local\\bin'
    ```

    Nếu không có output, hãy thêm thư mục cài đặt vào User PATH của bạn:

    ```powershell theme={null}
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$env:USERPROFILE\.local\bin", 'User')
    ```

    Khởi động lại terminal để thay đổi có hiệu lực.

    Xác minh cách sửa đã có hiệu lực:

    ```powershell theme={null}
    claude --version
    ```
  </Tab>

  <Tab title="Windows CMD">
    ```batch theme={null}
    echo %PATH% | findstr /i "local\bin"
    ```

    Nếu không có output, hãy mở System Settings, vào Environment Variables, và thêm `%USERPROFILE%\.local\bin` vào biến User PATH của bạn. Khởi động lại terminal.

    Xác minh cách sửa đã có hiệu lực:

    ```batch theme={null}
    claude --version
    ```
  </Tab>
</Tabs>

### Kiểm tra các bản cài đặt xung đột

Nhiều bản cài đặt Claude Code có thể gây ra không khớp phiên bản hoặc hành vi ngoài dự kiến. Kiểm tra những gì đã được cài đặt:

<Tabs>
  <Tab title="macOS/Linux">
    Liệt kê tất cả các binary `claude` tìm thấy trong PATH của bạn:

    ```bash theme={null}
    which -a claude
    ```

    Nếu lệnh này không in gì, thì chưa có `claude` nào trong PATH của bạn. Quay lại [Xác minh PATH của bạn](#verify-your-path).

    Kiểm tra ba vị trí mà một binary `claude` có thể đến từ đó. `~/.local/bin/claude` là trình cài đặt native, `~/.claude/local/` là bản cài npm local kiểu cũ do các phiên bản Claude Code cũ hơn tạo ra, và danh sách npm global hiển thị bản cài `-g`:

    ```bash theme={null}
    ls -la ~/.local/bin/claude
    ```

    Nếu một trong hai lệnh `ls` in ra `No such file or directory`, đó không phải lỗi. Nó nghĩa là không có gì được cài ở vị trí đó, nên hãy chuyển sang bước kiểm tra tiếp theo.

    ```bash theme={null}
    ls -la ~/.claude/local/
    ```

    ```bash theme={null}
    npm -g ls @anthropic-ai/claude-code 2>/dev/null
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    Liệt kê tất cả các binary `claude` tìm thấy trong PATH của bạn:

    ```powershell theme={null}
    where.exe claude
    ```

    Kiểm tra xem trình cài đặt native có đặt một binary hay không:

    ```powershell theme={null}
    Test-Path "$env:USERPROFILE\.local\bin\claude.exe"
    ```
  </Tab>
</Tabs>

Nếu bạn tìm thấy nhiều bản cài đặt, hãy chỉ giữ lại một. Bản cài native tại `~/.local/bin/claude` trên macOS/Linux hoặc `%USERPROFILE%\.local\bin\claude.exe` trên Windows là bản được khuyến nghị. Gỡ các bản dư thừa:

Gỡ một bản cài npm global:

```bash theme={null}
npm uninstall -g @anthropic-ai/claude-code
```

Gỡ bản cài npm local kiểu cũ:

```bash theme={null}
rm -rf ~/.claude/local
```

Trên Windows, dùng PowerShell:

```powershell theme={null}
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\local"
```

Gỡ một bản cài Homebrew trên macOS. Nếu bạn đã cài cask `claude-code@latest`, hãy thay bằng tên đó:

```bash theme={null}
brew uninstall --cask claude-code
```

Gỡ một bản cài WinGet trên Windows:

```powershell theme={null}
winget uninstall Anthropic.ClaudeCode
```

### Kiểm tra quyền của thư mục

Trình cài đặt cần quyền ghi vào `~/.local/bin/` và `~/.claude/` trên macOS và Linux. Trên Windows, vị trí cài đặt nằm dưới `%USERPROFILE%`, mặc định là ghi được bởi tài khoản của bạn, nên phần này hiếm khi áp dụng ở đó.

Kiểm tra xem các thư mục có ghi được không:

```bash theme={null}
test -w ~/.local/bin && echo "writable" || echo "not writable"
test -w ~/.claude && echo "writable" || echo "not writable"
```

Nếu một trong hai thư mục không ghi được, hãy tạo thư mục cài đặt và đặt tài khoản của bạn làm chủ sở hữu:

```bash theme={null}
sudo mkdir -p ~/.local/bin
sudo chown -R $(whoami) ~/.local
```

### Xác minh binary hoạt động

Nếu `claude --version` in ra một phiên bản nhưng `claude` bị crash hoặc treo khi khởi động, hãy chạy các bước kiểm tra này để thu hẹp nguyên nhân. Nếu `claude --version` báo command not found, hãy đến [Xác minh PATH của bạn](#verify-your-path) trước; các lệnh bên dưới giả định `claude` đã có trong PATH của bạn.

Xác nhận binary tồn tại và có thể thực thi:

```bash theme={null}
ls -la "$(command -v claude)"
```

Trên Windows, dùng PowerShell:

```powershell theme={null}
Get-Command claude | Select-Object Source
```

Trên Linux, kiểm tra các shared library bị thiếu. Nếu `ldd` cho thấy các library bị thiếu, bạn có thể cần cài các gói hệ thống. Trên Alpine Linux và các bản phân phối dựa trên musl khác, xem [Thiết lập Alpine Linux](/en/setup#alpine-linux-and-musl-based-distributions).

```bash theme={null}
ldd "$(command -v claude)" | grep "not found"
```

Xác nhận binary có thể thực thi:

```bash theme={null}
claude --version
```

## Các vấn đề cài đặt thường gặp

Đây là những vấn đề cài đặt hay gặp nhất và cách giải quyết.

### Script cài đặt trả về HTML thay vì một shell script

Khi chạy lệnh cài đặt, bạn có thể thấy một trong các lỗi sau:

```text theme={null}
bash: line 1: syntax error near unexpected token `<'
bash: line 1: `<!DOCTYPE html>'
```

Trên PowerShell, cùng vấn đề đó xuất hiện dưới dạng:

```text theme={null}
Invoke-Expression: Missing argument in parameter list.
```

Tùy theo cách request được định tuyến, bạn có thể thấy một lỗi 403 không có phần thân HTML:

```text theme={null}
curl: (22) The requested URL returned error: 403
```

Tất cả những điều này nghĩa là URL cài đặt đã trả về một trang HTML hoặc một trạng thái lỗi thay vì script cài đặt. Nếu trang HTML nói "App unavailable in region," thì Claude Code không khả dụng ở quốc gia của bạn. Xem [các quốc gia được hỗ trợ](https://www.anthropic.com/supported-countries).

Một lỗi 403 trơ trọi không có phần thân thường có cùng nguyên nhân, nhưng nó cũng có thể đến từ một proxy hoặc tường lửa doanh nghiệp chặn việc tải xuống. Nếu bạn ở một quốc gia được hỗ trợ mà vẫn thấy lỗi 403, hãy thực hiện lần lượt các bước ở [Kiểm tra kết nối mạng](#check-network-connectivity) trước khi thử các trình cài đặt thay thế bên dưới, vì chúng cũng truy cập cùng các host đó.

Ngoài ra, điều này có thể xảy ra do vấn đề mạng, định tuyến theo khu vực, hoặc gián đoạn dịch vụ tạm thời.

**Giải pháp:**

1. **Dùng phương thức cài đặt thay thế**:

   Trên macOS, cài qua Homebrew:

   ```bash theme={null}
   brew install --cask claude-code
   ```

   Trên Windows, cài qua WinGet:

   ```powershell theme={null}
   winget install Anthropic.ClaudeCode
   ```

2. **Thử lại sau vài phút**: vấn đề này thường là tạm thời. Chờ một lúc rồi thử lại lệnh ban đầu.

### `command not found: claude` sau khi cài đặt

Cài đặt đã hoàn tất nhưng `claude` không hoạt động. Thông báo lỗi chính xác khác nhau theo nền tảng:

| Nền tảng    | Thông báo lỗi                                                          |
| :---------- | :-------------------------------------------------------------------- |
| macOS       | `zsh: command not found: claude`                                       |
| Linux       | `bash: claude: command not found`                                      |
| Windows CMD | `'claude' is not recognized as an internal or external command`        |
| PowerShell  | `claude : The term 'claude' is not recognized as the name of a cmdlet` |

Điều này nghĩa là thư mục cài đặt không nằm trong đường dẫn tìm kiếm của shell. Xem [Xác minh PATH của bạn](#verify-your-path) để biết cách sửa trên từng nền tảng.

### `curl: (56) Failure writing output to destination`

Lệnh `curl ... | bash` tải script xuống và chuyển (pipe) nó cho Bash để thực thi. Lỗi này, cùng lỗi liên quan `curl: (23) Failure writing output to destination`, nghĩa là Bash không nhận được script đầy đủ. Mã thoát 56 cho biết bản thân việc tải xuống bị gián đoạn, còn mã thoát 23 cho biết curl không thể ghi những gì nó nhận được vào pipe, thường là do Bash đã thoát sớm.

**Giải pháp:**

1. **Kiểm tra độ ổn định mạng**: Các binary Claude Code được lưu trữ tại `downloads.claude.ai`. Kiểm tra rằng bạn có thể truy cập được:
   ```bash theme={null}
   curl -sI https://downloads.claude.ai/claude-code-releases/latest
   ```
   Một dòng `HTTP/2 200` nghĩa là bạn đã kết nối tới máy chủ và lỗi ban đầu nhiều khả năng là gián đoạn tạm thời; hãy thử lại lệnh cài đặt. Nếu bạn thấy `Could not resolve host` hoặc kết nối bị timeout, thì mạng của bạn đang chặn việc tải xuống.

2. **Thử một phương thức cài đặt thay thế**:

   Trên macOS:

   ```bash theme={null}
   brew install --cask claude-code
   ```

   Trên Windows:

   ```powershell theme={null}
   winget install Anthropic.ClaudeCode
   ```

### Cask Homebrew không khả dụng hoặc lỗi thời

Homebrew báo `Error: Cask 'claude-code' is unavailable: No Cask with this name exists` khi bản sao chỉ mục cask Homebrew cục bộ của bạn có trước thời điểm cask được công bố. Làm mới chỉ mục và thử lại:

```bash theme={null}
brew update
brew install --cask claude-code
```

Nếu Homebrew cài phiên bản Claude Code cũ hơn bạn mong đợi, nguyên nhân thường vẫn là chỉ mục lỗi thời đó. Cask `claude-code` bám theo kênh stable và thường trễ khoảng một tuần so với bản phát hành mới nhất; để lấy phiên bản mới nhất, hãy chạy `brew install --cask claude-code@latest` thay thế. Xem [Cấu hình kênh phát hành](/en/setup#configure-release-channel) để biết sự khác biệt giữa hai cask.

### Lỗi kết nối TLS hoặc SSL

Các lỗi như `curl: (35) TLS connect error`, `schannel: next InitializeSecurityContext failed`, hoặc `Could not establish trust relationship for the SSL/TLS secure channel` của PowerShell cho biết bắt tay (handshake) TLS thất bại.

**Giải pháp:**

1. **Cập nhật chứng chỉ CA hệ thống của bạn**:

   Trên Ubuntu/Debian:

   ```bash theme={null}
   sudo apt-get update && sudo apt-get install ca-certificates
   ```

   Trên macOS, curl hệ thống dùng kho tin cậy Keychain; cập nhật bản thân macOS sẽ cập nhật các chứng chỉ gốc.

2. **Trên Windows, bật TLS 1.2** trong PowerShell trước khi chạy trình cài đặt:
   ```powershell theme={null}
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   irm https://claude.ai/install.ps1 | iex
   ```

3. **Kiểm tra sự can thiệp của proxy hoặc tường lửa**: các proxy doanh nghiệp thực hiện kiểm tra TLS (TLS inspection) có thể gây ra các lỗi này, bao gồm `unable to get local issuer certificate` và `SELF_SIGNED_CERT_IN_CHAIN`. Với bước cài đặt, hãy trỏ curl đến bundle CA của doanh nghiệp bằng `--cacert`:
   ```bash theme={null}
   curl --cacert /path/to/corporate-ca.pem -fsSL https://claude.ai/install.sh | bash
   ```
   Với bản thân Claude Code sau khi cài, hãy đặt `NODE_EXTRA_CA_CERTS` để các request API tin cậy cùng bundle đó:
   ```bash theme={null}
   export NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.pem
   ```
   Hỏi đội IT về file chứng chỉ nếu bạn không có. Bạn cũng có thể thử trên một kết nối trực tiếp để xác nhận proxy có phải là nguyên nhân không.

4. **Trên Windows, bỏ qua kiểm tra thu hồi chứng chỉ** nếu bạn thấy `CRYPT_E_NO_REVOCATION_CHECK (0x80092012)` hoặc `CRYPT_E_REVOCATION_OFFLINE (0x80092013)`. Những lỗi này nghĩa là curl đã kết nối được tới máy chủ nhưng mạng của bạn chặn việc tra cứu thu hồi chứng chỉ, điều thường gặp ở sau tường lửa doanh nghiệp. Thêm `--ssl-revoke-best-effort` vào lệnh cài đặt:
   ```batch theme={null}
   curl --ssl-revoke-best-effort -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
   ```
   Hoặc, cài bằng `winget install Anthropic.ClaudeCode`, cách này bỏ qua curl hoàn toàn.

### `Failed to fetch version from downloads.claude.ai`

Trình cài đặt không kết nối được tới máy chủ tải xuống. Điều này thường nghĩa là `downloads.claude.ai` bị chặn trên mạng của bạn.

**Giải pháp:**

1. **Kiểm tra kết nối trực tiếp**:
   ```bash theme={null}
   curl -sI https://downloads.claude.ai/claude-code-releases/latest
   ```

2. **Nếu ở sau proxy**, đặt `HTTPS_PROXY` để trình cài đặt có thể định tuyến qua nó. Xem [cấu hình proxy](/en/network-config#proxy-configuration) để biết chi tiết.
   ```bash theme={null}
   export HTTPS_PROXY=http://proxy.example.com:8080
   curl -fsSL https://claude.ai/install.sh | bash
   ```

3. **Nếu ở trên một mạng bị hạn chế**, thử một mạng khác hoặc VPN, hoặc dùng một phương thức cài đặt thay thế:

   Trên macOS:

   ```bash theme={null}
   brew install --cask claude-code
   ```

   Trên Windows:

   ```powershell theme={null}
   winget install Anthropic.ClaudeCode
   ```

### Sai lệnh cài đặt trên Windows

Nếu bạn thấy `'irm' is not recognized`, `The token '&&' is not valid`, `A parameter cannot be found that matches parameter name 'fsSL'`, hoặc `'bash' is not recognized as the name of a cmdlet`, thì bạn đã sao chép lệnh cài đặt dành cho một shell hoặc hệ điều hành khác.

* **`irm` không được nhận diện**: bạn đang ở CMD, không phải PowerShell. Bạn có hai lựa chọn:

  Mở PowerShell bằng cách tìm "PowerShell" trong Start menu, rồi chạy lệnh cài đặt ban đầu:

  ```powershell theme={null}
  irm https://claude.ai/install.ps1 | iex
  ```

  Hoặc ở lại CMD và dùng trình cài đặt CMD thay thế:

  ```batch theme={null}
  curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
  ```

* **`&&` không hợp lệ**: bạn đang ở PowerShell nhưng chạy lệnh cài đặt của CMD. Dùng trình cài đặt PowerShell:
  ```powershell theme={null}
  irm https://claude.ai/install.ps1 | iex
  ```

* **`A parameter cannot be found that matches parameter name 'fsSL'`**: bạn chạy trình cài đặt macOS/Linux `curl -fsSL ... | bash` trong Windows PowerShell, nơi `curl` là alias cho `Invoke-WebRequest` và từ chối các flag `-fsSL`. Dùng trình cài đặt PowerShell thay thế:
  ```powershell theme={null}
  irm https://claude.ai/install.ps1 | iex
  ```

* **`bash` không được nhận diện**: bạn chạy trình cài đặt macOS/Linux trên Windows. Dùng trình cài đặt PowerShell thay thế:
  ```powershell theme={null}
  irm https://claude.ai/install.ps1 | iex
  ```

### `The process cannot access the file` khi cài trên Windows

Nếu trình cài đặt PowerShell thất bại với `Failed to download binary: The process cannot access the file ... because it is being used by another process`, thì trình cài đặt không ghi được vào `%USERPROFILE%\.claude\downloads`. Điều này thường nghĩa là một lần cài đặt trước đó vẫn đang chạy, hoặc phần mềm diệt virus đang quét một binary tải xuống dở dang trong thư mục đó.

Đóng bất kỳ cửa sổ PowerShell nào khác đang chạy trình cài đặt và chờ các lượt quét diệt virus giải phóng file. Sau đó xóa thư mục downloads và chạy lại trình cài đặt:

```powershell theme={null}
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\downloads"
irm https://claude.ai/install.ps1 | iex
```

### Cài đặt bị kill trên các server Linux ít bộ nhớ

Thông báo `Killed` khi cài đặt thường nghĩa là trình kill do hết bộ nhớ (OOM) của Linux đã chấm dứt bước `claude install` vì hệ thống hết bộ nhớ trống. Điều này phổ biến trên các VPS nhỏ và cloud instance nhỏ. Script cài đặt báo cáo nguyên nhân và thoát với mã 137:

```text theme={null}
Setting up Claude Code...
bash: line 142: 34803 Killed    "$binary_path" install ${TARGET:+"$TARGET"}
Installation was killed before it could finish (exit code 137). This usually means the system ran out of memory.
Claude Code needs roughly 512MB of free memory to install. Free up memory, then run this script again.
```

Trước v2.1.200, script chỉ thoát với dòng `Killed` trơ trọi của shell mà không có giải thích.

Việc cài đặt cần khoảng 512 MB bộ nhớ trống, và việc chạy Claude Code cần nhiều hơn. Xem [yêu cầu hệ thống](/en/setup#system-requirements).

**Giải pháp:**

1. **Thêm swap space** nếu server của bạn có RAM hạn chế. Swap dùng dung lượng đĩa làm bộ nhớ tràn, cho phép việc cài đặt hoàn tất ngay cả khi RAM vật lý thấp.

   Tạo một file swap 2 GB và bật nó:

   ```bash theme={null}
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

   Sau đó thử lại việc cài đặt:

   ```bash theme={null}
   curl -fsSL https://claude.ai/install.sh | bash
   ```

2. **Đóng các tiến trình khác** để giải phóng bộ nhớ trước khi cài đặt.

3. **Dùng một instance lớn hơn** nếu có thể. Claude Code cần ít nhất 4 GB RAM.

### Cài đặt bị treo trong Docker

Khi cài Claude Code trong một container Docker, việc cài với quyền root vào `/` có thể gây treo.

**Giải pháp:**

1. **Đặt một thư mục làm việc** trước khi chạy trình cài đặt. Khi chạy từ `/`, trình cài đặt quét toàn bộ hệ thống file, dẫn đến việc dùng bộ nhớ quá mức. Đặt `WORKDIR` giới hạn phạm vi quét vào một thư mục nhỏ:
   ```dockerfile theme={null}
   WORKDIR /tmp
   RUN curl -fsSL https://claude.ai/install.sh | bash
   ```

2. **Tăng giới hạn bộ nhớ Docker** nếu dùng Docker Desktop:
   ```bash theme={null}
   docker build --memory=4g .
   ```

### Claude Desktop ghi đè lệnh `claude` trên Windows

Nếu bạn đã cài một phiên bản Claude Desktop cũ hơn, nó có thể đăng ký một `Claude.exe` trong thư mục `WindowsApps` chiếm ưu tiên PATH so với Claude Code CLI. Chạy `claude` sẽ mở ứng dụng Desktop thay vì CLI.

Cập nhật Claude Desktop lên phiên bản mới nhất để khắc phục vấn đề này.

### Claude Code trên Windows yêu cầu Git for Windows (cho bash) hoặc PowerShell

Git for Windows là tùy chọn. Claude Code dùng [tool PowerShell](/en/tools-reference#powershell-tool) khi không có Git Bash, nên lỗi này nghĩa là không tìm thấy shell nào cả.

**Nếu PowerShell thiếu trong PATH của bạn**, vị trí mặc định của nó là `C:\Windows\System32\WindowsPowerShell\v1.0\`. Thêm thư mục đó vào `PATH` của bạn, hoặc cài [PowerShell 7](https://aka.ms/powershell), vốn cung cấp `pwsh`.

**Để cài Git for Windows thay thế**, tải nó từ [git-scm.com/downloads/win](https://git-scm.com/downloads/win). Trong quá trình cài đặt, chọn "Add to PATH." Khởi động lại terminal sau khi cài. Cài nó sẽ bật tool Bash, hữu ích khi làm việc với các script và công cụ dựa trên Bash.

**Nếu Git đã được cài** nhưng Claude Code không tìm thấy, hãy đặt đường dẫn trong [file settings.json](/en/settings) của bạn:

```json theme={null}
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

Nếu Git của bạn được cài ở nơi khác, hãy tìm đường dẫn bằng cách chạy `where.exe git` trong PowerShell và dùng đường dẫn `bin\bash.exe` từ thư mục đó.

**Nếu đường dẫn đúng và file tồn tại** nhưng Claude Code vẫn báo không tìm thấy, thì phần mềm bảo mật endpoint như AppLocker, các chính sách hạn chế phần mềm Group Policy, hoặc các agent EDR có thể đang can thiệp. Trên các phiên bản trước v2.1.116, Claude Code sinh ra một tiến trình con (`cmd.exe`) để xác minh đường dẫn, mà các chính sách này có thể chặn — một dấu hiệu phổ biến là `cmd.exe /c dir "C:\Program Files\Git\bin\bash.exe"` chạy được khi bạn chạy trực tiếp trong PowerShell nhưng thất bại âm thầm khi được khởi chạy bởi `claude.exe`.

Claude Code v2.1.116 trở lên kiểm tra hệ thống file trực tiếp, nên hãy cập nhật trước. Nếu lỗi vẫn còn trên phiên bản hiện tại, hãy nhờ đội IT đưa `claude.exe` và các tiến trình nó sinh ra, bao gồm `cmd.exe` và `bash.exe`, vào danh sách cho phép trong chính sách bảo vệ endpoint của bạn.

### Claude Code không hỗ trợ Windows 32-bit

Windows có hai mục PowerShell trong Start menu: `Windows PowerShell` và `Windows PowerShell (x86)`. Mục x86 chạy dưới dạng một tiến trình 32-bit và kích hoạt lỗi này ngay cả trên một máy 64-bit. Để kiểm tra bạn thuộc trường hợp nào, hãy chạy lệnh này trong chính cửa sổ đã tạo ra lỗi:

```powershell theme={null}
[Environment]::Is64BitOperatingSystem
```

Nếu lệnh này in ra `True`, thì hệ điều hành của bạn ổn. Đóng cửa sổ đó, mở `Windows PowerShell` không có hậu tố x86, và chạy lại lệnh cài đặt.

Nếu lệnh này in ra `False`, bạn đang dùng một phiên bản Windows 32-bit. Claude Code yêu cầu một hệ điều hành 64-bit. Xem [yêu cầu hệ thống](/en/setup#system-requirements).

### Không khớp binary musl hoặc glibc trên Linux

Nếu bạn thấy các lỗi về shared library bị thiếu như `libstdc++.so.6` hoặc `libgcc_s.so.1` sau khi cài đặt, thì trình cài đặt có thể đã tải xuống sai biến thể binary cho hệ thống của bạn.

```text theme={null}
Error loading shared library libstdc++.so.6: No such file or directory
```

Điều này có thể xảy ra trên các hệ thống dựa trên glibc mà có cài các gói cross-compilation musl, khiến trình cài đặt nhận diện nhầm hệ thống là musl.

**Giải pháp:**

1. **Kiểm tra hệ thống của bạn dùng libc nào**:
   ```bash theme={null}
   ldd --version 2>&1 | head -1
   ```
   Output có đề cập `GNU libc` hoặc `GLIBC` nghĩa là glibc. Output có đề cập `musl` nghĩa là musl.

2. **Nếu bạn dùng glibc nhưng nhận được binary musl**, hãy gỡ bản cài đặt và cài lại. Bạn cũng có thể tự tải binary đúng bằng cách dùng manifest tại `https://downloads.claude.ai/claude-code-releases/{VERSION}/manifest.json`. Mở một [GitHub issue](https://github.com/anthropics/claude-code/issues) kèm output của `ldd --version` và `ls /lib/libc.musl*`.

3. **Nếu bạn thực sự dùng musl**, chẳng hạn Alpine Linux, hãy cài các gói cần thiết:
   ```bash theme={null}
   apk add libgcc libstdc++ ripgrep
   ```

### `Illegal instruction`

Nếu chạy `claude` hoặc trình cài đặt in ra `Illegal instruction`, thì binary native dùng các lệnh CPU mà bộ xử lý của bạn không hỗ trợ. Có hai nguyên nhân riêng biệt.

**Không khớp kiến trúc.** Trình cài đặt tải xuống sai binary, ví dụ x86 trên một server ARM. Kiểm tra bằng `uname -m` trên macOS hoặc Linux, hoặc `$env:PROCESSOR_ARCHITECTURE` trong PowerShell. Nếu kết quả không khớp với binary bạn nhận được, [mở một GitHub issue](https://github.com/anthropics/claude-code/issues) kèm output.

**Thiếu tập lệnh AVX.** Nếu kiến trúc của bạn đúng nhưng bạn vẫn thấy `Illegal instruction`, thì CPU của bạn nhiều khả năng thiếu AVX hoặc một lệnh khác mà binary yêu cầu. Điều này ảnh hưởng đến khoảng các bộ xử lý Intel và AMD trước năm 2013, và các máy ảo nơi hypervisor không truyền AVX xuống guest.

Trên một VPS hoặc VM, chạy `grep -m1 -ow avx /proc/cpuinfo`; kết quả rỗng nghĩa là AVX không khả dụng cho guest.

Không có cách khắc phục cho binary native; theo dõi [issue #50384](https://github.com/anthropics/claude-code/issues/50384) để biết trạng thái, và hãy đính kèm model CPU của bạn từ `grep -m1 "model name" /proc/cpuinfo` trên Linux hoặc `sysctl -n machdep.cpu.brand_string` trên macOS khi báo cáo.

Các phương thức cài đặt thay thế đều tải cùng binary native và sẽ không giải quyết được nguyên nhân nào.

### `dyld: cannot load` trên macOS

Nếu bạn thấy `dyld: cannot load`, `dyld: Symbol not found`, hoặc `Abort trap: 6` khi cài đặt, thì binary không tương thích với phiên bản macOS hoặc phần cứng của bạn.

```text theme={null}
dyld: cannot load 'claude-2.1.42-darwin-x64' (load command 0x80000034 is unknown)
Abort trap: 6
```

Một lỗi `Symbol not found` tham chiếu đến `libicucore` cũng cho biết phiên bản macOS của bạn cũ hơn mức binary hỗ trợ:

```text theme={null}
dyld: Symbol not found: _ubrk_clone
  Referenced from: claude-darwin-x64 (which was built for Mac OS X 13.0)
  Expected in: /usr/lib/libicucore.A.dylib
```

**Giải pháp:**

1. **Kiểm tra phiên bản macOS của bạn**: Claude Code yêu cầu macOS 13.0 trở lên. Mở menu Apple và chọn About This Mac để kiểm tra phiên bản của bạn.

2. **Cập nhật macOS** nếu bạn đang ở phiên bản cũ hơn. Binary dùng các load command và thư viện hệ thống mà các phiên bản macOS cũ hơn không hỗ trợ. Các phương thức cài đặt thay thế như Homebrew tải cùng binary và sẽ không giải quyết được lỗi này.

### `Exec format error` trên WSL1

Nếu chạy `claude` trong WSL in ra `cannot execute binary file: Exec format error`, thì bạn đang dùng WSL1 và gặp một hồi quy binary native đã biết được theo dõi trong [issue #38788](https://github.com/anthropics/claude-code/issues/38788). Các program header của binary đã thay đổi theo cách mà loader của WSL1 không xử lý được.

Cách khắc phục sạch nhất là chuyển đổi bản phân phối của bạn sang WSL2 từ PowerShell:

```powershell theme={null}
wsl --set-version <DistroName> 2
```

Nếu bạn cần ở lại WSL1, hãy gọi binary thông qua dynamic linker. Thêm hàm này vào `~/.bashrc` trong WSL, thay đường dẫn nếu thư mục home của bạn khác:

```bash theme={null}
claude() {
  /lib64/ld-linux-x86-64.so.2 "$(readlink -f "$HOME/.local/bin/claude")" "$@"
}
```

Sau đó chạy `source ~/.bashrc` và thử lại `claude`.

### Lỗi cài đặt npm trong WSL

Các vấn đề này áp dụng nếu bạn cài Claude Code bằng `npm install -g` bên trong WSL. Nếu bạn dùng [trình cài đặt native](/en/setup), hãy bỏ qua phần này.

**Vấn đề nhận diện OS hoặc nền tảng.** Nếu npm báo không khớp nền tảng khi cài, thì WSL nhiều khả năng đang dùng `npm` của Windows. Chạy `npm config set os linux` trước, rồi cài với `npm install -g @anthropic-ai/claude-code --force`. Không dùng `sudo`.

**`exec: node: not found` khi chạy `claude`.** Môi trường WSL của bạn nhiều khả năng đang dùng bản cài Node.js của Windows. Xác nhận bằng `which npm` và `which node`: các đường dẫn bắt đầu bằng `/mnt/c/` là binary Windows, còn các đường dẫn Linux bắt đầu bằng `/usr/`. Để khắc phục, hãy cài Node qua trình quản lý gói của bản phân phối Linux của bạn hoặc qua [`nvm`](https://github.com/nvm-sh/nvm).

**Xung đột phiên bản nvm.** Nếu bạn cài nvm ở cả WSL và Windows, việc chuyển phiên bản Node trong WSL có thể hỏng vì WSL nhập PATH của Windows theo mặc định và nvm của Windows chiếm ưu tiên. Nguyên nhân phổ biến nhất là nvm không được tải trong shell của bạn. Thêm bộ tải nvm vào `~/.bashrc` hoặc `~/.zshrc`:

```bash theme={null}
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Hoặc tải nó trong phiên hiện tại của bạn:

```bash theme={null}
source ~/.nvm/nvm.sh
```

Nếu nvm đã được tải nhưng các đường dẫn Windows vẫn chiếm ưu tiên, hãy đưa đường dẫn Node của Linux lên trước một cách tường minh:

```bash theme={null}
export PATH="$HOME/.nvm/versions/node/$(node -v)/bin:$PATH"
```

<Warning>
  Tránh vô hiệu hóa việc nhập PATH của Windows qua `appendWindowsPath = false` vì điều này phá vỡ khả năng gọi các file thực thi Windows từ WSL. Tương tự, tránh gỡ Node.js khỏi Windows nếu bạn dùng nó để phát triển trên Windows.
</Warning>

### Lỗi quyền khi cài đặt

Nếu trình cài đặt native thất bại với lỗi quyền, thì thư mục đích có thể không ghi được. Xem [Kiểm tra quyền của thư mục](#check-directory-permissions).

Nếu trước đây bạn cài bằng npm và đang gặp các lỗi quyền đặc thù của npm, hãy chuyển sang trình cài đặt native:

```bash theme={null}
curl -fsSL https://claude.ai/install.sh | bash
```

### Không tìm thấy binary native sau khi cài npm

Gói npm `@anthropic-ai/claude-code` kéo về binary native thông qua một optional dependency theo từng nền tảng như `@anthropic-ai/claude-code-darwin-arm64`. Nếu chạy `claude` sau khi cài in ra `Could not find native binary package "@anthropic-ai/claude-code-<platform>"`, hãy kiểm tra các nguyên nhân sau:

* **Optional dependency bị vô hiệu hóa.** Bỏ `--omit=optional` khỏi lệnh npm install, `--no-optional` khỏi pnpm, hoặc `--ignore-optional` khỏi yarn, và kiểm tra rằng `.npmrc` không đặt `optional=false`. Sau đó cài lại. Binary native chỉ được cung cấp dưới dạng một optional dependency, nên không có JavaScript fallback nếu nó bị bỏ qua.
* **Nền tảng không được hỗ trợ.** Các binary dựng sẵn được phát hành cho `darwin-arm64`, `darwin-x64`, `linux-x64`, `linux-arm64`, `linux-x64-musl`, `linux-arm64-musl`, `win32-x64`, và `win32-arm64`. Claude Code không cung cấp binary cho các nền tảng khác; xem [yêu cầu hệ thống](/en/setup#system-requirements).
* **Mirror npm doanh nghiệp thiếu các gói nền tảng.** Đảm bảo registry của bạn mirror cả tám gói nền tảng `@anthropic-ai/claude-code-*` bên cạnh gói meta.

Cài với `--ignore-scripts` không kích hoạt lỗi này. Bước postinstall vốn liên kết binary vào chỗ bị bỏ qua, nên Claude Code chuyển sang dùng một wrapper để định vị và sinh ra binary nền tảng trong mỗi lần khởi chạy. Cách này hoạt động nhưng khởi động chậm hơn; hãy cài lại với scripts được bật để thực thi trực tiếp.

## Đăng nhập và xác thực

Các phần này giải quyết các lỗi đăng nhập thất bại, lỗi OAuth và vấn đề token.

### Đặt lại đăng nhập của bạn

Khi đăng nhập thất bại và nguyên nhân không rõ ràng, một lần xác thực lại sạch sẽ giải quyết được hầu hết các trường hợp:

1. Chạy `/logout` để đăng xuất hoàn toàn
2. Đóng Claude Code
3. Khởi động lại với `claude` và hoàn tất lại quá trình xác thực

Nếu trình duyệt không tự động mở trong lúc đăng nhập, hãy nhấn `c` để sao chép URL OAuth vào clipboard, rồi dán vào một trình duyệt theo cách thủ công. Cách này cũng hữu ích khi URL bị xuống dòng trong một terminal hẹp hoặc SSH và không thể click trực tiếp.

### OAuth error: Invalid code

Nếu bạn thấy `OAuth error: Invalid code. Please make sure the full code was copied`, thì mã đăng nhập đã hết hạn hoặc bị cắt cụt khi sao chép-dán.

**Giải pháp:**

* Nhấn Enter để thử lại và hoàn tất đăng nhập nhanh sau khi trình duyệt mở
* Gõ `c` để sao chép toàn bộ URL nếu trình duyệt không tự động mở
* Nếu dùng phiên remote/SSH, trình duyệt có thể mở trên máy sai. Sao chép URL hiển thị trong terminal và mở nó trong trình duyệt local của bạn thay thế.

### 403 Forbidden sau khi đăng nhập

Nếu bạn thấy `API Error: 403 {"error":{"type":"forbidden","message":"Request not allowed"}}` sau khi đăng nhập:

* **Người dùng Claude Pro/Max**: xác minh gói đăng ký của bạn còn hiệu lực tại [claude.ai/settings](https://claude.ai/settings)
* **Người dùng Anthropic Console**: xác nhận tài khoản của bạn có vai trò "Claude Code" hoặc "Developer". Admin gán vai trò này trong Anthropic Console tại Settings → Members.
* **Ở sau proxy**: các proxy doanh nghiệp có thể can thiệp vào các request API. Xem [cấu hình mạng](/en/network-config) để biết cách thiết lập proxy.

### This organization has been disabled with an active subscription

Nếu bạn thấy `API Error: 400 ... "This organization has been disabled"` dù có một gói đăng ký Claude còn hiệu lực, thì một biến môi trường `ANTHROPIC_API_KEY` đang ghi đè gói đăng ký của bạn. Điều này thường xảy ra khi một API key cũ từ một nơi làm việc hoặc dự án trước đó vẫn được đặt trong shell profile của bạn.

Khi `ANTHROPIC_API_KEY` hiện diện và bạn đã phê duyệt nó, Claude Code dùng key đó thay vì thông tin xác thực OAuth của gói đăng ký. Ở chế độ non-interactive với flag `-p`, key luôn được dùng khi hiện diện. Xem [thứ tự ưu tiên xác thực](/en/authentication#authentication-precedence) để biết đầy đủ thứ tự phân giải.

Để dùng gói đăng ký của bạn thay thế, hãy hủy đặt biến môi trường và loại bỏ nó khỏi shell profile:

```bash theme={null}
unset ANTHROPIC_API_KEY
claude
```

Kiểm tra `~/.zshrc`, `~/.bashrc`, hoặc `~/.profile` để tìm các dòng `export ANTHROPIC_API_KEY=...` và loại bỏ chúng để thay đổi có hiệu lực vĩnh viễn. Trên Windows, kiểm tra PowerShell profile tại `$PROFILE` và các biến môi trường User để tìm `ANTHROPIC_API_KEY`. Chạy `/status` trong Claude Code để xác nhận phương thức xác thực nào đang hoạt động.

### Đăng nhập OAuth thất bại trong WSL2, SSH, hoặc container

Khi Claude Code chạy trong WSL2, trên một máy remote qua SSH, hoặc bên trong một container, trình duyệt thường mở trên một host khác và redirect của nó không thể tới được callback server local của Claude Code. Sau khi bạn đăng nhập, trình duyệt hiển thị một mã đăng nhập thay vì tự động chuyển hướng trở lại. Dán mã đó vào terminal tại lời nhắc `Paste code here if prompted` để hoàn tất đăng nhập.

Nếu trình duyệt không mở chút nào từ WSL2, hãy đặt biến môi trường `BROWSER` thành đường dẫn trình duyệt Windows của bạn:

```bash theme={null}
export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
claude
```

Hoặc, nhấn `c` tại lời nhắc đăng nhập tương tác để sao chép URL OAuth, hoặc sao chép URL mà `claude auth login` in ra, và mở nó trong một trình duyệt trên máy local của bạn.

Nếu dán mã vào lời nhắc tương tác không có tác dụng gì, thì phím tắt dán của terminal nhiều khả năng không tới được ô nhập liệu. Thử phím tắt dán thay thế của terminal, thường là chuột phải hoặc Shift+Insert trong Windows Terminal, hoặc dùng `claude auth login` thay thế, lệnh này đọc mã được dán từ standard input:

```bash theme={null}
claude auth login
```

Cách dự phòng này cũng áp dụng trên Windows native hoặc bất kỳ terminal nào mà việc dán vào lời nhắc tương tác thất bại.

### Chưa đăng nhập hoặc token đã hết hạn

Nếu Claude Code nhắc bạn đăng nhập lại sau một phiên làm việc, thì token OAuth của bạn có thể đã hết hạn.

Chạy `/login` để xác thực lại. Nếu điều này xảy ra thường xuyên, hãy kiểm tra rằng đồng hồ hệ thống của bạn chính xác, vì việc xác thực token phụ thuộc vào timestamp đúng.

Trên macOS, đăng nhập cũng có thể thất bại khi Keychain bị khóa hoặc mật khẩu của nó không đồng bộ với mật khẩu tài khoản của bạn, điều này ngăn Claude Code lưu thông tin xác thực. Chạy `claude doctor` để kiểm tra quyền truy cập Keychain. Để mở khóa Keychain theo cách thủ công, chạy `security unlock-keychain ~/Library/Keychains/login.keychain-db`. Nếu mở khóa không giúp được gì, hãy mở Keychain Access, chọn keychain `login`, và chọn Edit > Change Password for Keychain "login" để đồng bộ lại nó với mật khẩu tài khoản của bạn.

### Thông tin xác thực Bedrock, Agent Platform, hoặc Foundry không tải được

Nếu bạn đã cấu hình Claude Code để dùng một nhà cung cấp cloud và thấy `Could not load credentials from any providers` trên Amazon Bedrock, `Could not load the default credentials` trên Google Cloud's Agent Platform, hoặc `ChainedTokenCredential authentication failed` trên Microsoft Foundry, thì CLI của nhà cung cấp cloud của bạn nhiều khả năng chưa được xác thực trong shell hiện tại.

Với Amazon Bedrock, xác nhận thông tin xác thực AWS của bạn hợp lệ:

```bash theme={null}
aws sts get-caller-identity
```

Với Google Cloud's Agent Platform, xác nhận `ANTHROPIC_VERTEX_PROJECT_ID` và `CLOUD_ML_REGION` đã được đặt trong shell của bạn, rồi đặt application default credentials:

```bash theme={null}
gcloud auth application-default login
```

Với Microsoft Foundry, xác nhận `ANTHROPIC_FOUNDRY_API_KEY` đã được đặt, hoặc đăng nhập bằng Azure CLI để chuỗi credential mặc định có thể tìm thấy tài khoản của bạn:

```bash theme={null}
az login
```

Nếu thông tin xác thực hoạt động trong terminal của bạn nhưng không hoạt động trong tiện ích mở rộng VS Code hoặc JetBrains, thì tiến trình IDE nhiều khả năng không kế thừa môi trường shell của bạn. Hãy đặt các biến môi trường của nhà cung cấp trong phần cài đặt riêng của IDE, hoặc khởi chạy IDE từ một terminal nơi chúng đã được export.

Xem [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [Microsoft Foundry](/en/microsoft-foundry) để biết thiết lập đầy đủ cho nhà cung cấp.

## Vẫn bế tắc

Nếu không cách nào ở trên giải quyết được vấn đề của bạn:

1. Kiểm tra [kho GitHub](https://github.com/anthropics/claude-code/issues) để tìm các vấn đề đã biết, hoặc mở một vấn đề mới kèm hệ điều hành của bạn, lệnh cài đặt bạn đã chạy, và toàn bộ output lỗi
2. Nếu `claude --version` chạy được nhưng có gì đó khác bị sai, hãy chạy `claude doctor` để có một báo cáo chẩn đoán tự động
3. Nếu bạn có thể bắt đầu một phiên, hãy dùng `/feedback` trong Claude Code để báo cáo vấn đề
