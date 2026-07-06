> Nguồn: https://code.claude.com/docs/en/setup.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Cài đặt nâng cao

> Yêu cầu hệ thống, cách cài đặt theo từng nền tảng, quản lý phiên bản và gỡ cài đặt Claude Code.

Trang này trình bày yêu cầu hệ thống, chi tiết cài đặt theo từng nền tảng, cách cập nhật và gỡ cài đặt. Để có hướng dẫn từng bước cho phiên làm việc đầu tiên, xem [quickstart](/en/quickstart). Nếu bạn chưa từng dùng terminal, xem [hướng dẫn terminal](/en/terminal-guide).

## Yêu cầu hệ thống

Claude Code chạy trên các nền tảng và cấu hình sau:

* **Hệ điều hành**:
  * macOS 13.0+
  * Windows 10 1809+ hoặc Windows Server 2019+
  * Ubuntu 20.04+
  * Debian 10+
  * Alpine Linux 3.19+
* **Phần cứng**: RAM 4 GB trở lên, bộ xử lý x64 hoặc ARM64
* **Mạng**: cần có kết nối internet. Xem [cấu hình mạng](/en/network-config#network-access-requirements).
* **Shell**: Bash, Zsh, PowerShell hoặc CMD.
* **Vị trí**: [các quốc gia được Anthropic hỗ trợ](https://www.anthropic.com/supported-countries)

### Phụ thuộc bổ sung

* **ripgrep**: thường được kèm sẵn với Claude Code. Nếu tìm kiếm thất bại, xem [khắc phục sự cố tìm kiếm](/en/troubleshooting#search-and-discovery-issues).

## Cài đặt Claude Code

<Tip>
  Muốn dùng giao diện đồ họa? [Ứng dụng Desktop](/en/desktop-quickstart) cho phép bạn sử dụng Claude Code mà không cần terminal. Tải về cho [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect?utm_source=claude_code\&utm_medium=docs), [Windows](https://claude.com/download?utm_source=claude_code\&utm_medium=docs) hoặc [Linux](https://claude.com/download?utm_source=claude_code\&utm_medium=docs).

  Mới làm quen với terminal? Xem [hướng dẫn terminal](/en/terminal-guide) để có hướng dẫn từng bước.
</Tip>

Để cài đặt Claude Code, dùng một trong các phương pháp sau:

<Tabs>
  <Tab title="Cài đặt gốc (Khuyến nghị)">
    **macOS, Linux, WSL:**

    ```bash theme={null}
    curl -fsSL https://claude.ai/install.sh | bash
    ```

    **Windows PowerShell:**

    ```powershell theme={null}
    irm https://claude.ai/install.ps1 | iex
    ```

    **Windows CMD:**

    ```batch theme={null}
    curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
    ```

    Nếu bạn thấy `The token '&&' is not a valid statement separator`, nghĩa là bạn đang ở PowerShell chứ không phải CMD. Nếu bạn thấy `'irm' is not recognized as an internal or external command`, nghĩa là bạn đang ở CMD chứ không phải PowerShell. Dấu nhắc hiển thị `PS C:\` khi bạn ở PowerShell và `C:\` không có `PS` khi bạn ở CMD.

    Nếu lệnh cài đặt thất bại với `syntax error near unexpected token '<'`, lỗi `403` hoặc lỗi curl khác, xem [Khắc phục sự cố cài đặt](/en/troubleshoot-install#find-your-error) để đối chiếu lỗi với cách khắc phục và tìm các phương pháp cài đặt thay thế.

    [Git for Windows](https://git-scm.com/downloads/win) được khuyến nghị trên Windows gốc để Claude Code có thể dùng công cụ Bash. Nếu Git for Windows chưa được cài, Claude Code sẽ dùng PowerShell làm công cụ shell thay thế. Các thiết lập WSL không cần Git for Windows.

    <Info>
      Các bản cài đặt gốc tự động cập nhật ở chế độ nền để giữ bạn luôn ở phiên bản mới nhất.
    </Info>
  </Tab>

  <Tab title="Homebrew">
    ```bash theme={null}
    brew install --cask claude-code
    ```

    Homebrew cung cấp hai cask. `claude-code` theo dõi kênh phát hành ổn định (stable), thường chậm hơn khoảng một tuần và bỏ qua các bản phát hành có lỗi hồi quy nghiêm trọng. `claude-code@latest` theo dõi kênh latest và nhận các phiên bản mới ngay khi phát hành.

    <Info>
      Các bản cài đặt Homebrew không tự động cập nhật. Chạy `brew upgrade claude-code` hoặc `brew upgrade claude-code@latest`, tùy theo cask bạn đã cài, để nhận các tính năng mới và bản vá bảo mật mới nhất.
    </Info>
  </Tab>

  <Tab title="WinGet">
    ```powershell theme={null}
    winget install Anthropic.ClaudeCode
    ```

    <Info>
      Các bản cài đặt WinGet không tự động cập nhật. Chạy `winget upgrade Anthropic.ClaudeCode` định kỳ để nhận các tính năng mới và bản vá bảo mật mới nhất.
    </Info>
  </Tab>
</Tabs>

Bạn cũng có thể cài đặt bằng [apt, dnf, hoặc apk](/en/setup#install-with-linux-package-managers) trên Debian, Fedora, RHEL và Alpine.

Sau khi cài đặt hoàn tất, mở terminal trong dự án bạn muốn làm việc và khởi động Claude Code:

```bash theme={null}
claude
```

Nếu bạn gặp bất kỳ sự cố nào trong quá trình cài đặt, xem [Khắc phục sự cố cài đặt và đăng nhập](/en/troubleshoot-install).

### Thiết lập trên Windows

Bạn có thể chạy Claude Code trực tiếp trên Windows (native) hoặc bên trong WSL. Chọn dựa trên nơi đặt các dự án của bạn và những tính năng bạn cần:

| Lựa chọn       | Yêu cầu                                                                | [Sandboxing](/en/sandboxing) | Khi nào nên dùng                                     |
| -------------- | --------------------------------------------------------------------- | ---------------------------- | --------------------------------------------------- |
| Windows gốc    | Không có; [Git for Windows](https://git-scm.com/downloads/win) là tùy chọn | Không hỗ trợ                 | Dự án và công cụ native của Windows                  |
| WSL 2          | Đã bật WSL 2                                                          | Hỗ trợ                       | Chuỗi công cụ Linux hoặc thực thi lệnh trong sandbox |
| WSL 1          | Đã bật WSL 1                                                          | Không hỗ trợ                 | Khi không dùng được WSL 2                            |

**Lựa chọn 1: Windows gốc**

Chạy lệnh cài đặt từ PowerShell hoặc CMD. Bạn không cần chạy với quyền Administrator. Việc cài [Git for Windows](https://git-scm.com/downloads/win) là tùy chọn. Nó bật [công cụ Bash](/en/tools-reference#bash-tool-behavior) bằng cách cung cấp Git Bash.

Việc bạn cài từ PowerShell hay CMD chỉ ảnh hưởng đến lệnh cài đặt nào bạn chạy. Dấu nhắc hiển thị `PS C:\Users\YourName>` trong PowerShell và `C:\Users\YourName>` không có `PS` trong CMD. Nếu bạn mới làm quen với terminal, [hướng dẫn terminal](/en/terminal-guide#windows) sẽ hướng dẫn từng bước.

Sau khi cài đặt, khởi chạy `claude` từ bất kỳ terminal nào.

* **Không có Git for Windows**, Claude Code chạy các lệnh shell qua [công cụ PowerShell](/en/tools-reference#powershell-tool).
* **Có Git for Windows**, Claude Code dùng Git Bash cho [công cụ Bash](/en/tools-reference#bash-tool-behavior). Nếu Claude Code không tìm được Git Bash, hãy đặt đường dẫn trong [file settings.json](/en/settings) của bạn:

  ```json theme={null}
  {
    "env": {
      "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
    }
  }
  ```

Khi Git for Windows được cài, công cụ PowerShell đang được triển khai dần như một lựa chọn bổ sung bên cạnh Bash. Đặt `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` để bật hoặc `0` để tắt. Xem [công cụ PowerShell](/en/tools-reference#powershell-tool) để biết cách thiết lập và các hạn chế.

**Lựa chọn 2: WSL**

Mở bản phân phối WSL của bạn và chạy trình cài đặt Linux theo [hướng dẫn cài đặt](#install-claude-code) ở trên. Bạn cài và khởi chạy `claude` bên trong terminal WSL, không phải từ PowerShell hay CMD.

### Alpine Linux và các bản phân phối dựa trên musl

Trình cài đặt gốc trên Alpine và các bản phân phối dựa trên musl/uClibc khác yêu cầu `libgcc`, `libstdc++`, và `ripgrep`. Cài các gói này bằng trình quản lý gói của bản phân phối, sau đó đặt `USE_BUILTIN_RIPGREP=0`.

Ví dụ này cài các gói cần thiết trên Alpine:

```bash theme={null}
apk add libgcc libstdc++ ripgrep
```

Sau đó đặt `USE_BUILTIN_RIPGREP` thành `0` trong file [`settings.json`](/en/settings#available-settings) của bạn:

```json theme={null}
{
  "env": {
    "USE_BUILTIN_RIPGREP": "0"
  }
}
```

## Xác minh bản cài đặt

Sau khi cài đặt, xác nhận Claude Code hoạt động:

```bash theme={null}
claude --version
```

Nếu lệnh này thất bại với `command not found` hoặc lỗi khác, xem [Khắc phục sự cố cài đặt và đăng nhập](/en/troubleshoot-install).

Để kiểm tra chi tiết hơn về bản cài đặt và cấu hình của bạn, chạy [`claude doctor`](/en/troubleshooting#get-more-help):

```bash theme={null}
claude doctor
```

## Xác thực

Claude Code yêu cầu tài khoản Pro, Max, Team, Enterprise hoặc Console. Gói Claude.ai miễn phí không bao gồm quyền truy cập Claude Code. Bạn cũng có thể dùng Claude Code với nhà cung cấp API bên thứ ba như [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [Microsoft Foundry](/en/microsoft-foundry).

Sau khi cài đặt, đăng nhập bằng cách chạy `claude` và làm theo các hướng dẫn trên trình duyệt. Xem [Xác thực](/en/authentication) để biết tất cả loại tài khoản và các tùy chọn thiết lập cho nhóm.

## Cập nhật Claude Code

Các bản cài đặt gốc tự động cập nhật ở chế độ nền. Bạn có thể [cấu hình kênh phát hành](#configure-release-channel) để kiểm soát việc nhận cập nhật ngay lập tức hay theo lịch stable trì hoãn, hoặc [tắt tự động cập nhật](#disable-auto-updates) hoàn toàn. Các bản cài đặt Homebrew, WinGet và [trình quản lý gói Linux](#install-with-linux-package-managers) mặc định yêu cầu cập nhật thủ công.

### Tự động cập nhật

Claude Code kiểm tra cập nhật khi khởi động và định kỳ trong lúc chạy. Bản cập nhật được tải và cài ở chế độ nền, sau đó có hiệu lực ở lần tiếp theo bạn khởi động Claude Code.

Chạy `claude doctor` để xem kết quả của lần cập nhật gần nhất.

Nếu một bản cài npm global không thể tự động cập nhật vì thư mục global của npm không ghi được, Claude Code sẽ hiển thị một thông báo một lần khi khởi động, và `claude doctor` liệt kê các cách khắc phục hiện có. Xem [lỗi quyền trong quá trình cài đặt](/en/troubleshoot-install#permission-errors-during-installation) để biết chi tiết.

<Note>
  Các bản cài đặt Homebrew, WinGet, apt, dnf và apk mặc định không tự động cập nhật; xem bên dưới để bật cho Homebrew và WinGet. Để nâng cấp Homebrew thủ công, chạy `brew upgrade claude-code` hoặc `brew upgrade claude-code@latest`, tùy theo cask bạn đã cài. Với WinGet, chạy `winget upgrade Anthropic.ClaudeCode`. Với các trình quản lý gói Linux, xem các lệnh nâng cấp trong [Cài đặt bằng trình quản lý gói Linux](#install-with-linux-package-managers).

  Để Claude Code tự chạy lệnh nâng cấp giúp bạn trên Homebrew hoặc WinGet, đặt [`CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE`](/en/env-vars) thành `1`. Khi đó Claude Code sẽ chạy nâng cấp ở chế độ nền khi có phiên bản mới và hiển thị lời nhắc khởi động lại khi thành công. Việc nâng cấp chỉ nhắm vào gói Claude Code và không ảnh hưởng đến phần mềm khác bạn đã cài.

  Trên WinGet, việc nâng cấp có thể thất bại khi Claude Code đang chạy vì Windows khóa tệp thực thi. Trong trường hợp đó Claude Code sẽ hiển thị lệnh thủ công thay thế. apt, dnf và apk vẫn yêu cầu nâng cấp thủ công vì các lệnh đó cần đặc quyền nâng cao.

  **Vấn đề đã biết:** Claude Code có thể thông báo cập nhật cho bạn trước khi phiên bản mới có sẵn trong các trình quản lý gói này. Nếu nâng cấp thất bại, hãy đợi và thử lại sau.

  Homebrew giữ lại các phiên bản cũ trên đĩa sau khi nâng cấp. Chạy `brew cleanup` định kỳ để giải phóng dung lượng đĩa.
</Note>

### Cấu hình kênh phát hành

Kiểm soát kênh phát hành mà Claude Code theo dõi cho việc tự động cập nhật và `claude update` bằng cài đặt `autoUpdatesChannel`:

* `"latest"`, mặc định: nhận các tính năng mới ngay khi chúng được phát hành
* `"stable"`: dùng phiên bản thường cũ khoảng một tuần, bỏ qua các bản phát hành có lỗi hồi quy nghiêm trọng

Cấu hình việc này qua `/config` → **Auto-update channel**, hoặc thêm vào [file settings.json](/en/settings) của bạn:

```json theme={null}
{
  "autoUpdatesChannel": "stable"
}
```

Với các triển khai doanh nghiệp, bạn có thể áp đặt một kênh phát hành nhất quán trên toàn tổ chức bằng [managed settings](/en/permissions#managed-settings).

Các bản cài đặt Homebrew chọn kênh theo tên cask thay vì cài đặt này: `claude-code` theo dõi stable và `claude-code@latest` theo dõi latest.

### Ghim phiên bản tối thiểu

Cài đặt `minimumVersion` thiết lập một ngưỡng sàn. Tự động cập nhật ở chế độ nền và `claude update` sẽ từ chối cài bất kỳ phiên bản nào thấp hơn giá trị này, nên việc chuyển sang kênh `"stable"` sẽ không hạ cấp bạn nếu bạn đã ở một bản `"latest"` mới hơn.

Chuyển từ `"latest"` sang `"stable"` qua `/config` sẽ nhắc bạn hoặc giữ nguyên phiên bản hiện tại, hoặc cho phép hạ cấp. Chọn giữ nguyên sẽ đặt `minimumVersion` thành phiên bản đó. Chuyển ngược lại `"latest"` sẽ xóa nó.

Thêm vào [file settings.json](/en/settings) của bạn để ghim ngưỡng sàn một cách rõ ràng:

```json theme={null}
{
  "autoUpdatesChannel": "stable",
  "minimumVersion": "2.1.100"
}
```

Trong [managed settings](/en/permissions#managed-settings), giá trị này áp đặt một mức tối thiểu trên toàn tổ chức mà cài đặt của người dùng và dự án không thể ghi đè.

Việc ghim `minimumVersion` chỉ ràng buộc các bản cập nhật. Để khiến Claude Code từ chối khởi động ngoài một khoảng phiên bản, hãy dùng managed settings `requiredMinimumVersion` và `requiredMaximumVersion` thay thế. Các bản cập nhật cũng tôn trọng trần `requiredMaximumVersion`. Xem [các cài đặt hiện có](/en/settings#available-settings).

### Tắt tự động cập nhật

Đặt `DISABLE_AUTOUPDATER` thành `"1"` trong khóa `env` của file [`settings.json`](/en/settings#available-settings) của bạn:

```json theme={null}
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

`DISABLE_AUTOUPDATER` chỉ dừng việc kiểm tra ở chế độ nền; `claude update` và `claude install` vẫn hoạt động. Để chặn tất cả các đường dẫn cập nhật, bao gồm cả cập nhật thủ công, hãy đặt [`DISABLE_UPDATES`](/en/env-vars) thay thế. Dùng cách này khi bạn phân phối Claude Code qua các kênh riêng của mình và cần người dùng giữ ở phiên bản bạn cung cấp.

### Cập nhật thủ công

Để áp dụng một bản cập nhật ngay lập tức mà không cần đợi lần kiểm tra nền tiếp theo, chạy:

```bash theme={null}
claude update
```

## Các tùy chọn cài đặt nâng cao

Các tùy chọn này dành cho việc ghim phiên bản, trình quản lý gói Linux, npm và xác minh tính toàn vẹn của tệp nhị phân.

### Cài một phiên bản cụ thể

Trình cài đặt gốc chấp nhận hoặc một số phiên bản cụ thể hoặc một kênh phát hành (`latest` hoặc `stable`). Kênh bạn chọn khi cài đặt sẽ trở thành mặc định cho việc tự động cập nhật. Xem [cấu hình kênh phát hành](#configure-release-channel) để biết thêm thông tin.

Để cài phiên bản mới nhất (mặc định):

<Tabs>
  <Tab title="macOS, Linux, WSL">
    ```bash theme={null}
    curl -fsSL https://claude.ai/install.sh | bash
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    irm https://claude.ai/install.ps1 | iex
    ```
  </Tab>

  <Tab title="Windows CMD">
    ```batch theme={null}
    curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
    ```
  </Tab>
</Tabs>

Để cài phiên bản stable:

<Tabs>
  <Tab title="macOS, Linux, WSL">
    ```bash theme={null}
    curl -fsSL https://claude.ai/install.sh | bash -s stable
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    & ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable
    ```
  </Tab>

  <Tab title="Windows CMD">
    ```batch theme={null}
    curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd stable && del install.cmd
    ```
  </Tab>
</Tabs>

Để cài một số phiên bản cụ thể:

<Tabs>
  <Tab title="macOS, Linux, WSL">
    ```bash theme={null}
    curl -fsSL https://claude.ai/install.sh | bash -s 2.1.89
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    & ([scriptblock]::Create((irm https://claude.ai/install.ps1))) 2.1.89
    ```
  </Tab>

  <Tab title="Windows CMD">
    ```batch theme={null}
    curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd 2.1.89 && del install.cmd
    ```
  </Tab>
</Tabs>

### Cài đặt bằng trình quản lý gói Linux

Claude Code phát hành các kho apt, dnf và apk đã ký. Mỗi kho cung cấp hai kênh: `stable` phục vụ phiên bản thường cũ khoảng một tuần, bỏ qua các bản phát hành có lỗi hồi quy nghiêm trọng, và `latest` phục vụ mọi bản phát hành ngay khi ra mắt. Các lệnh dưới đây cấu hình kênh `stable`, phù hợp với hầu hết người dùng; mỗi tab cũng hiển thị URL kho `latest`. Các bản cài đặt qua trình quản lý gói không tự động cập nhật thông qua Claude Code; cập nhật đến qua quy trình nâng cấp hệ thống thông thường của bạn.

Tất cả các kho đều được ký bằng [khóa ký phát hành của Claude Code](#binary-integrity-and-code-signing). Trước khi tin tưởng khóa, hãy xác minh nó như mô tả trong từng tab.

<Tabs>
  <Tab title="apt">
    Dành cho Debian và Ubuntu. Các lệnh sau cấu hình kênh `stable`:

    ```bash theme={null}
    sudo install -d -m 0755 /etc/apt/keyrings
    sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
      -o /etc/apt/keyrings/claude-code.asc
    echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
      | sudo tee /etc/apt/sources.list.d/claude-code.list
    sudo apt update
    sudo apt install claude-code
    ```

    Để dùng kênh `latest` thay thế, cả đường dẫn URL và tên suite đều thay đổi. Dùng dòng `deb` này:

    ```bash theme={null}
    echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/latest latest main" \
      | sudo tee /etc/apt/sources.list.d/claude-code.list
    ```

    Xác minh dấu vân tay khóa GPG trước khi tin tưởng nó: `gpg --show-keys /etc/apt/keyrings/claude-code.asc` phải báo cáo `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`.

    Để nâng cấp sau này, chạy `sudo apt update && sudo apt upgrade claude-code`.
  </Tab>

  <Tab title="dnf">
    Dành cho Fedora và RHEL. Các lệnh sau cấu hình kênh `stable`:

    ```bash theme={null}
    sudo tee /etc/yum.repos.d/claude-code.repo <<'EOF'
    [claude-code]
    name=Claude Code
    baseurl=https://downloads.claude.ai/claude-code/rpm/stable
    enabled=1
    gpgcheck=1
    gpgkey=https://downloads.claude.ai/keys/claude-code.asc
    EOF
    sudo dnf install claude-code
    ```

    Để dùng kênh `latest` thay thế, đặt `baseurl` thành kho `latest`:

    ```ini theme={null}
    baseurl=https://downloads.claude.ai/claude-code/rpm/latest
    ```

    dnf tải khóa xuống ở lần cài đầu tiên và nhắc bạn xác nhận dấu vân tay. Xác minh nó khớp `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE` trước khi chấp nhận.

    Để nâng cấp sau này, chạy `sudo dnf upgrade claude-code`.
  </Tab>

  <Tab title="apk">
    Dành cho Alpine Linux. Các lệnh sau cấu hình kênh `stable`:

    ```sh theme={null}
    wget -O /etc/apk/keys/claude-code.rsa.pub \
      https://downloads.claude.ai/keys/claude-code.rsa.pub
    echo "https://downloads.claude.ai/claude-code/apk/stable" >> /etc/apk/repositories
    apk add claude-code
    ```

    Để chuyển sang kênh `latest`, xóa dòng kho `stable` và thêm kho `latest`:

    ```sh theme={null}
    sed -i '\|downloads.claude.ai/claude-code/apk/stable|d' /etc/apk/repositories
    echo "https://downloads.claude.ai/claude-code/apk/latest" >> /etc/apk/repositories
    ```

    Xác minh khóa đã tải bằng `sha256sum /etc/apk/keys/claude-code.rsa.pub`, lệnh này phải báo cáo `395759c1f7449ef4cdef305a42e820f3c766d6090d142634ebdb049f113168b6`.

    Để nâng cấp sau này, chạy `apk update && apk upgrade claude-code`.
  </Tab>
</Tabs>

### Cài đặt bằng npm

Bạn cũng có thể cài Claude Code như một gói npm global. Kể từ v2.1.198, gói npm yêu cầu [Node.js 22 trở lên](https://nodejs.org/en/download). Trên phiên bản Node.js cũ hơn, npm in ra cảnh báo `EBADENGINE` trong quá trình cài thay vì thất bại; việc cài vẫn hoàn tất và `claude` vẫn chạy, vì gói này tải xuống một tệp nhị phân native không dùng Node.js của bạn lúc chạy.

```bash theme={null}
npm install -g @anthropic-ai/claude-code
```

Gói npm cài cùng tệp nhị phân native như trình cài đặt độc lập. npm kéo tệp nhị phân vào thông qua một phụ thuộc tùy chọn theo từng nền tảng như `@anthropic-ai/claude-code-darwin-arm64`, và một bước postinstall liên kết nó vào đúng chỗ. Tệp nhị phân `claude` đã cài không tự gọi Node.

Các nền tảng cài đặt npm được hỗ trợ là `darwin-arm64`, `darwin-x64`, `linux-x64`, `linux-arm64`, `linux-x64-musl`, `linux-arm64-musl`, `win32-x64`, và `win32-arm64`. Trình quản lý gói của bạn phải cho phép các phụ thuộc tùy chọn. Xem [khắc phục sự cố](/en/troubleshoot-install#native-binary-not-found-after-npm-install) nếu tệp nhị phân bị thiếu sau khi cài.

Để nâng cấp một bản cài npm, chạy `npm install -g @anthropic-ai/claude-code@latest`. Tránh dùng `npm update -g`, vì lệnh này tôn trọng khoảng semver từ lần cài ban đầu và có thể không đưa bạn lên bản phát hành mới nhất.

<Warning>
  KHÔNG dùng `sudo npm install -g` vì điều này có thể dẫn đến các vấn đề về quyền và rủi ro bảo mật. Nếu bạn gặp lỗi quyền, xem [khắc phục sự cố lỗi quyền](/en/troubleshoot-install#permission-errors-during-installation).
</Warning>

### Tính toàn vẹn của tệp nhị phân và ký mã

Mỗi bản phát hành công bố một `manifest.json` chứa các checksum SHA256 cho mọi tệp nhị phân theo từng nền tảng. Manifest được ký bằng một khóa GPG của Anthropic, nên việc xác minh chữ ký trên manifest sẽ xác minh gián tiếp mọi tệp nhị phân mà nó liệt kê.

#### Xác minh chữ ký của manifest

Các bước 1-3 yêu cầu một shell POSIX với `gpg` và `curl`. Trên Windows, chạy chúng trong Git Bash hoặc WSL. Bước 4 bao gồm một tùy chọn PowerShell.

<Steps>
  <Step title="Tải xuống và nhập khóa công khai">
    Khóa ký phát hành được công bố tại một URL cố định.

    ```bash theme={null}
    curl -fsSL https://downloads.claude.ai/keys/claude-code.asc | gpg --import
    ```

    Hiển thị dấu vân tay của khóa đã nhập.

    ```bash theme={null}
    gpg --fingerprint security@anthropic.com
    ```

    Xác nhận đầu ra bao gồm dấu vân tay này:

    ```text theme={null}
    31DD DE24 DDFA B679 F42D  7BD2 BAA9 29FF 1A7E CACE
    ```
  </Step>

  <Step title="Tải xuống manifest và chữ ký">
    Đặt `VERSION` thành bản phát hành bạn muốn xác minh.

    ```bash theme={null}
    REPO=https://downloads.claude.ai/claude-code-releases
    VERSION=2.1.89
    curl -fsSLO "$REPO/$VERSION/manifest.json"
    curl -fsSLO "$REPO/$VERSION/manifest.json.sig"
    ```
  </Step>

  <Step title="Xác minh chữ ký">
    Xác minh chữ ký tách rời (detached) so với manifest.

    ```bash theme={null}
    gpg --verify manifest.json.sig manifest.json
    ```

    Kết quả hợp lệ báo cáo `Good signature from "Anthropic Claude Code Release Signing <security@anthropic.com>"`.

    `gpg` cũng in ra `WARNING: This key is not certified with a trusted signature!` đối với bất kỳ khóa nào vừa mới nhập. Điều này là bình thường. Dòng `Good signature` xác nhận việc kiểm tra mật mã đã vượt qua. Việc so sánh dấu vân tay ở Bước 1 xác nhận bản thân khóa là xác thực.
  </Step>

  <Step title="Kiểm tra tệp nhị phân so với manifest">
    So sánh checksum SHA256 của tệp nhị phân với giá trị được liệt kê dưới `platforms.<platform>.checksum` trong `manifest.json`. Các lệnh dưới đây giả định có một tệp nhị phân `claude` trong thư mục hiện tại. Để xác minh một tệp nhị phân native đã cài thay thế, chạy lệnh với `~/.local/share/claude/versions/VERSION`, thay VERSION bằng bản phát hành bạn đã đặt ở Bước 2.

    <Tabs>
      <Tab title="Linux">
        ```bash theme={null}
        sha256sum claude
        ```
      </Tab>

      <Tab title="macOS">
        ```bash theme={null}
        shasum -a 256 claude
        ```
      </Tab>

      <Tab title="Windows PowerShell">
        ```powershell theme={null}
        (Get-FileHash claude.exe -Algorithm SHA256).Hash.ToLower()
        ```
      </Tab>
    </Tabs>
  </Step>
</Steps>

<Note>
  Chữ ký manifest có sẵn cho các bản phát hành từ `2.1.89` trở đi. Các bản phát hành trước đó công bố checksum trong `manifest.json` mà không có chữ ký tách rời.
</Note>

#### Chữ ký mã theo nền tảng

Ngoài manifest đã ký, các tệp nhị phân riêng lẻ còn mang chữ ký mã native theo nền tảng ở nơi được hỗ trợ.

* **macOS**: được ký bởi "Anthropic PBC" và được Apple công chứng (notarized). Xác minh bằng `codesign --verify --verbose ./claude`.
* **Windows**: được ký bởi "Anthropic, PBC". Xác minh bằng `Get-AuthenticodeSignature .\claude.exe`.
* **Linux**: các tệp nhị phân không được ký mã riêng lẻ. Nếu bạn tải trực tiếp từ bucket `claude-code-releases` hoặc dùng trình cài đặt gốc, hãy xác minh tính toàn vẹn bằng chữ ký manifest ở trên. Nếu bạn cài bằng [apt, dnf, hoặc apk](#install-with-linux-package-managers), trình quản lý gói của bạn tự động xác minh chữ ký bằng khóa ký của kho.

## Gỡ cài đặt Claude Code

Để gỡ bỏ Claude Code, hãy làm theo hướng dẫn cho phương pháp cài đặt của bạn. Nếu `claude` vẫn chạy sau đó, có thể bạn có một bản cài đặt thứ hai hoặc một alias shell còn sót lại từ trình cài đặt cũ. Xem [Kiểm tra các bản cài đặt xung đột](/en/troubleshoot-install#check-for-conflicting-installations) để tìm và gỡ bỏ nó.

### Bản cài đặt gốc

Gỡ bỏ tệp nhị phân Claude Code và các tệp phiên bản:

<Tabs>
  <Tab title="macOS, Linux, WSL">
    ```bash theme={null}
    rm -f ~/.local/bin/claude
    rm -rf ~/.local/share/claude
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    Remove-Item -Path "$env:USERPROFILE\.local\bin\claude.exe" -Force
    Remove-Item -Path "$env:USERPROFILE\.local\share\claude" -Recurse -Force
    ```
  </Tab>
</Tabs>

### Bản cài đặt Homebrew

Gỡ bỏ cask Homebrew bạn đã cài. Nếu bạn đã cài cask stable:

```bash theme={null}
brew uninstall --cask claude-code
```

Nếu bạn đã cài cask latest:

```bash theme={null}
brew uninstall --cask claude-code@latest
```

### Bản cài đặt WinGet

Gỡ bỏ gói WinGet:

```powershell theme={null}
winget uninstall Anthropic.ClaudeCode
```

### apt / dnf / apk

Gỡ bỏ gói và cấu hình kho:

<Tabs>
  <Tab title="apt">
    ```bash theme={null}
    sudo apt remove claude-code
    sudo rm /etc/apt/sources.list.d/claude-code.list /etc/apt/keyrings/claude-code.asc
    ```
  </Tab>

  <Tab title="dnf">
    ```bash theme={null}
    sudo dnf remove claude-code
    sudo rm /etc/yum.repos.d/claude-code.repo
    ```
  </Tab>

  <Tab title="apk">
    ```sh theme={null}
    apk del claude-code
    sed -i '\|downloads.claude.ai/claude-code/apk|d' /etc/apk/repositories
    rm /etc/apk/keys/claude-code.rsa.pub
    ```
  </Tab>
</Tabs>

### npm

Gỡ bỏ gói npm global:

```bash theme={null}
npm uninstall -g @anthropic-ai/claude-code
```

### Gỡ bỏ các tệp cấu hình

<Warning>
  Việc gỡ bỏ các tệp cấu hình sẽ xóa tất cả cài đặt, các công cụ được phép, cấu hình máy chủ MCP và lịch sử phiên làm việc của bạn.
</Warning>

Tiện ích mở rộng VS Code, plugin JetBrains và ứng dụng Desktop cũng ghi vào `~/.claude/`. Nếu bất kỳ cái nào trong số đó vẫn còn được cài, thư mục sẽ được tạo lại vào lần tiếp theo nó chạy. Để gỡ bỏ Claude Code hoàn toàn, hãy gỡ [tiện ích mở rộng VS Code](/en/vs-code#uninstall-the-extension), plugin JetBrains và ứng dụng Desktop trước khi xóa các tệp này.

Để gỡ bỏ cài đặt và dữ liệu đệm của Claude Code:

<Tabs>
  <Tab title="macOS, Linux, WSL">
    ```bash theme={null}
    # Remove user settings and state
    rm -rf ~/.claude
    rm ~/.claude.json

    # Remove project-specific settings (run from your project directory)
    rm -rf .claude
    rm -f .mcp.json
    ```
  </Tab>

  <Tab title="Windows PowerShell">
    ```powershell theme={null}
    # Remove user settings and state
    Remove-Item -Path "$env:USERPROFILE\.claude" -Recurse -Force
    Remove-Item -Path "$env:USERPROFILE\.claude.json" -Force

    # Remove project-specific settings (run from your project directory)
    Remove-Item -Path ".claude" -Recurse -Force
    Remove-Item -Path ".mcp.json" -Force
    ```
  </Tab>
</Tabs>
