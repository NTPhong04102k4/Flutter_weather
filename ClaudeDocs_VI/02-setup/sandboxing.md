> Nguồn: https://code.claude.com/docs/en/sandboxing.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Cấu hình công cụ Bash chạy trong sandbox

> Tìm hiểu cách công cụ Bash chạy trong sandbox của Claude Code cung cấp sự cô lập hệ thống file và mạng để thực thi agent an toàn và tự chủ hơn.

Sandbox của Bash cho phép Claude chạy hầu hết các lệnh shell mà không cần dừng lại để hỏi quyền. Thay vì phê duyệt từng lệnh, bạn định nghĩa những file và miền mạng nào mà các lệnh có thể chạm tới, và hệ điều hành thực thi ranh giới đó cho mọi lệnh Bash và các tiến trình con của nó.

<Note>
  Để so sánh các cách tiếp cận cô lập khác như dev container, container tùy chỉnh, và máy ảo, xem [Sandbox environments](/en/sandbox-environments). Để giảm lời nhắc quyền cho các công cụ khác ngoài Bash, xem [permission modes](/en/permission-modes).
</Note>

## Bắt đầu

Sandbox được tích hợp sẵn trong Claude Code và chạy trên macOS, Linux, và WSL2. Windows gốc không được hỗ trợ. Trên Windows, hãy chạy Claude Code bên trong một bản phân phối WSL2.

Trên macOS, không có gì phải cài đặt: sandboxing dùng framework Seatbelt tích hợp sẵn. Trên Linux và WSL2, sandbox dựa vào hai gói, được trình bày trong [Thiết lập Linux và WSL2](#set-up-linux-and-wsl2). Ngay cả khi bạn chưa cài chúng, bạn vẫn có thể bắt đầu với `/sandbox`, vì bảng điều khiển của nó cho biết có thiếu gì không.

<Steps>
  <Step title="Chạy /sandbox">
    Bắt đầu một phiên Claude Code và chạy lệnh `/sandbox`:

    ```text theme={null}
    /sandbox
    ```

    Lệnh này mở bảng sandbox với ba tab:

    * **Mode**: chọn cách phê duyệt các lệnh chạy trong sandbox, được trình bày ở bước tiếp theo
    * **Overrides**: chọn xem các lệnh thất bại trong sandbox có được phép quay về chạy ngoài sandbox hay không. Đây là thiết lập [`allowUnsandboxedCommands`](/en/settings#sandbox-settings)
    * **Config**: xem các thiết lập sandbox đã được phân giải

    Nếu bảng chỉ hiển thị một tab Dependencies, một gói bắt buộc đang bị thiếu. Hãy cài nó như mô tả trong [Thiết lập Linux và WSL2](#set-up-linux-and-wsl2), khởi động lại Claude Code, và chạy lại `/sandbox`.
  </Step>

  <Step title="Chọn một chế độ">
    Trong tab Mode, chọn auto-allow hoặc regular permissions. Auto-allow chạy các lệnh sandbox mà không hỏi, còn regular permissions giữ nguyên các lời nhắc quyền thông thường ngay cả khi lệnh được sandbox. Xem [Chế độ sandbox](#sandbox-modes) để biết lệnh nào vẫn hỏi trong chế độ auto-allow.
  </Step>

  <Step title="Chạy một lệnh Bash">
    Yêu cầu Claude chạy một lệnh, chẳng hạn một bản build hoặc một bộ test. Theo mặc định, các lệnh bên trong sandbox chỉ có thể ghi vào thư mục làm việc và thư mục tạm của phiên. Lần đầu tiên một lệnh cần một miền mạng mới, Claude Code sẽ hỏi để phê duyệt.

    Các lệnh không thể chạy trong sandbox sẽ quay về luồng quyền thông thường. Để nới rộng hay thu hẹp các ranh giới này, xem [Cấu hình sandboxing](#configure-sandboxing).
  </Step>
</Steps>

Việc chọn một chế độ trong bảng ghi vào local settings của dự án tại `.claude/settings.local.json`, vốn áp dụng cho dự án hiện tại và không được commit vào git. Để bật sandbox trên tất cả các dự án của bạn, đặt [`sandbox.enabled`](/en/settings#sandbox-settings) thành `true` trong user settings tại `~/.claude/settings.json`. Để thực thi sandboxing cho mọi lập trình viên trong một tổ chức, hãy dùng [managed settings](#enforce-sandboxing-with-managed-settings).

<Warning>
  Theo mặc định, nếu sandbox không thể khởi động vì thiếu dependency hoặc nền tảng không được hỗ trợ, Claude Code hiển thị một cảnh báo và chạy các lệnh mà không có sandbox. Để biến điều này thành lỗi cứng thay thế, hãy đặt [`sandbox.failIfUnavailable`](/en/settings#sandbox-settings) thành `true`. Điều này dành cho các triển khai quản lý yêu cầu sandboxing như một cổng bảo mật.
</Warning>

### Thiết lập Linux và WSL2

Trên Linux và WSL2, sandbox dựa vào hai gói:

* [`bubblewrap`](https://github.com/containers/bubblewrap): công cụ sandboxing không cần đặc quyền, thực thi sự cô lập hệ thống file
* [`socat`](http://www.dest-unreach.org/socat/): bộ chuyển tiếp dùng để định tuyến lưu lượng mạng qua sandbox proxy

Cài chúng bằng trình quản lý gói của bản phân phối:

<Tabs>
  <Tab title="Ubuntu/Debian">
    ```bash theme={null}
    sudo apt-get install bubblewrap socat
    ```
  </Tab>

  <Tab title="Fedora">
    ```bash theme={null}
    sudo dnf install bubblewrap socat
    ```
  </Tab>
</Tabs>

Sau khi cài, tab Dependencies trong `/sandbox` cho biết `ripgrep`, `bubblewrap`, `socat`, và bộ lọc seccomp có khả dụng trên nền tảng của bạn hay không. Ripgrep được đóng gói kèm với binary Claude Code gốc. Bộ lọc seccomp là tùy chọn và thêm khả năng chặn Unix domain socket. Cài nó bằng `npm install -g @anthropic-ai/sandbox-runtime` nếu nó bị thiếu.

Khi một dependency bắt buộc bị thiếu, tab Dependencies là tab duy nhất được hiển thị cho đến khi bạn cài nó. Việc kiểm tra dependency chạy lúc khởi động, nên hãy khởi động lại Claude Code sau khi cài gói để `/sandbox` phát hiện chúng.

<AccordionGroup>
  <Accordion title="Ubuntu 24.04 trở lên: cho phép bubblewrap tạo user namespace">
    Trên Ubuntu 24.04 trở lên, chính sách AppArmor mặc định ngăn bubblewrap tạo các user namespace mà nó cần để cô lập.

    Để kiểm tra xem môi trường của bạn có thực thi hạn chế này không, kể cả bên trong WSL2, hãy chạy `sysctl kernel.apparmor_restrict_unprivileged_userns`. Nếu khóa không tồn tại hoặc trả về `0`, bỏ qua bước này. Nếu nó trả về `1`, hãy thêm một profile AppArmor cấp cho `bwrap` khả năng này:

    ```bash theme={null}
    sudo tee /etc/apparmor.d/bwrap > /dev/null <<'EOF'
    abi <abi/4.0>,
    include <tunables/global>

    profile bwrap /usr/bin/bwrap flags=(unconfined) {
      userns,
      include if exists <local/bwrap>
    }
    EOF
    ```

    Profile chỉ áp dụng cho chính `bwrap`, không áp dụng cho các lệnh nó chạy bên trong sandbox. Nạp lại AppArmor để áp dụng nó:

    ```bash theme={null}
    sudo systemctl reload apparmor
    ```
  </Accordion>

  <Accordion title="Ghi chú về WSL2">
    Kiểm tra phiên bản WSL của bạn bằng `wsl -l -v` từ PowerShell. Nếu bạn thấy `Sandboxing requires WSL2`, bản phân phối của bạn đang chạy WSL1. Nâng cấp nó lên WSL2 hoặc chạy Claude Code mà không có sandbox.

    Trên WSL2, các lệnh sandbox không thể khởi chạy các binary Windows như `cmd.exe`, `powershell.exe`, hoặc bất cứ gì dưới `/mnt/c/`. WSL chuyển giao những cái này cho host Windows qua một Unix socket, vốn bị sandbox chặn. Nếu một lệnh cần gọi một binary Windows, hãy thêm nó vào [`excludedCommands`](/en/settings#sandbox-settings) để nó chạy ngoài sandbox.
  </Accordion>
</AccordionGroup>

### Chế độ sandbox

Claude Code cung cấp hai chế độ sandbox:

**Chế độ auto-allow**: Các lệnh Bash sẽ cố chạy bên trong sandbox và được tự động cho phép mà không cần quyền. Các lệnh không thể sandbox, chẳng hạn những lệnh cần truy cập mạng tới các host không được phép, sẽ quay về luồng quyền thông thường, nơi Claude Code kiểm tra [các quy tắc quyền](/en/permissions) của bạn và hỏi bạn về bất kỳ lệnh nào các quy tắc chưa cho phép sẵn.

Ngay cả trong chế độ auto-allow, những điều sau vẫn áp dụng:

* Các [quy tắc deny](/en/permissions) tường minh luôn được tôn trọng
* Các lệnh `rm` hoặc `rmdir` nhắm vào `/`, thư mục home của bạn, hoặc các đường dẫn hệ thống quan trọng khác vẫn kích hoạt lời nhắc quyền
* Các [quy tắc ask](/en/permissions) có phạm vi nội dung như `Bash(git push *)` vẫn buộc phải hỏi ngay cả với các lệnh sandbox
* Một quy tắc ask `Bash` trần, hoặc dạng `Bash(*)` tương đương, được bỏ qua cho các lệnh chạy trong sandbox; nó vẫn áp dụng cho các lệnh quay về luồng quyền thông thường

**Chế độ regular permissions**: Tất cả các lệnh Bash đi qua luồng quyền thông thường, ngay cả khi được sandbox. Điều này cho nhiều kiểm soát hơn nhưng cần nhiều phê duyệt hơn.

Trong cả hai chế độ, sandbox thực thi cùng các hạn chế hệ thống file và mạng. Khác biệt chỉ ở việc các lệnh sandbox được tự động phê duyệt hay cần quyền tường minh.

Thư mục tạm của phiên có thể ghi được bên trong sandbox theo mặc định, cùng với thư mục làm việc. Claude Code đặt `$TMPDIR` thành thư mục này cho các lệnh sandbox, nên các công cụ ghi file tạm hoạt động mà không cần cấu hình thêm. Các lệnh không sandbox kế thừa `$TMPDIR` của shell mà không thay đổi, nghĩa là các lệnh sandbox và không sandbox phân giải `$TMPDIR` tới các thư mục khác nhau. Để truyền file tạm giữa hai loại, hãy ghi chúng dưới thư mục làm việc thay thế.

Một số lệnh không thể chạy bên trong sandbox chút nào, chẳng hạn các công cụ không tương thích với nó hoặc cần một host bạn chưa cho phép. Thay vì làm hỏng tác vụ hoặc buộc bạn tắt sandboxing, Claude Code có một cửa thoát: khi một lệnh thất bại vì các hạn chế sandbox, Claude phân tích lỗi và có thể thử lại lệnh với tham số `dangerouslyDisableSandbox`. Lệnh được thử lại chạy ngoài sandbox, nên nó đi qua luồng quyền thông thường và cần bạn phê duyệt.

Bạn có thể vô hiệu hóa cửa thoát này bằng cách đặt `"allowUnsandboxedCommands": false` trong [sandbox settings](/en/settings#sandbox-settings) của bạn. Khi bị vô hiệu, mà tab Overrides của `/sandbox` hiển thị là **Strict sandbox mode**, tham số `dangerouslyDisableSandbox` bị bỏ qua hoàn toàn và mọi lệnh phải chạy trong sandbox hoặc được liệt kê tường minh trong `excludedCommands`.

<Info>
  Chế độ auto-allow hoạt động độc lập với thiết lập chế độ quyền của bạn. Ngay cả khi bạn không ở chế độ "accept edits", các lệnh Bash sandbox sẽ chạy tự động khi auto-allow được bật. Điều này nghĩa là các lệnh Bash sửa file trong ranh giới sandbox sẽ thực thi mà không hỏi, ngay cả khi các công cụ sửa file thông thường sẽ cần phê duyệt.
</Info>

## Cấu hình sandboxing

Tùy chỉnh hành vi sandbox qua file `settings.json` của bạn. Xem [Settings](/en/settings#sandbox-settings) để có tham chiếu cấu hình đầy đủ.

Theo mặc định, các lệnh sandbox chỉ có thể ghi vào thư mục làm việc hiện tại và thư mục tạm của phiên. Nếu các lệnh tiến trình con như `kubectl`, `terraform`, hoặc `npm` cần ghi ra ngoài các thư mục đó, hãy dùng `sandbox.filesystem.allowWrite` để cấp quyền cho các đường dẫn cụ thể:

```json theme={null}
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"]
    }
  }
}
```

Các đường dẫn này được thực thi ở cấp hệ điều hành, nên tất cả các lệnh chạy bên trong sandbox, kể cả các tiến trình con của chúng, đều tôn trọng chúng. Đây là cách tiếp cận được khuyến nghị khi một công cụ cần quyền ghi vào một vị trí cụ thể, thay vì loại trừ hẳn công cụ khỏi sandbox bằng `excludedCommands`.

Khi cùng một mảng hệ thống file được định nghĩa trong nhiều [phạm vi settings](/en/settings#settings-precedence), các mảng được gộp lại: các đường dẫn từ mọi phạm vi được kết hợp, không phải thay thế.

Các tiền tố đường dẫn kiểm soát cách phân giải đường dẫn:

| Tiền tố           | Ý nghĩa                                                                                | Ví dụ                                                                      |
| :---------------- | :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------ |
| `/`               | Đường dẫn tuyệt đối từ gốc hệ thống file                                               | `/tmp/build` giữ nguyên `/tmp/build`                                       |
| `~/`              | Tương đối với thư mục home                                                             | `~/.kube` trở thành `$HOME/.kube`                                          |
| `./` hoặc không có tiền tố | Tương đối với gốc dự án đối với project settings, hoặc với `~/.claude` đối với user settings | `./output` trong `.claude/settings.json` phân giải thành `<project-root>/output` |

Cú pháp này khác với [quy tắc quyền Read và Edit](/en/permissions#read-and-edit), vốn dùng `//path` cho đường dẫn tuyệt đối và `/path` cho đường dẫn tương đối với dự án. Đường dẫn hệ thống file của sandbox dùng quy ước tiêu chuẩn: `/tmp/build` là tuyệt đối.

Bạn cũng có thể từ chối quyền ghi hoặc đọc bằng `sandbox.filesystem.denyWrite` và `sandbox.filesystem.denyRead`, và cho phép lại các đường dẫn cụ thể trong một vùng bị từ chối bằng `sandbox.filesystem.allowRead`.

Ví dụ dưới đây chặn đọc từ toàn bộ thư mục home trong khi vẫn cho phép đọc từ dự án hiện tại. Đặt nó trong `.claude/settings.json` của dự án, vì đường dẫn tương đối `.` chỉ phân giải tới gốc dự án khi cấu hình nằm trong project settings:

```json theme={null}
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "denyRead": ["~/"],
      "allowRead": ["."]
    }
  }
}
```

`.` trong `allowRead` phân giải tới gốc dự án vì cấu hình này nằm trong project settings. Nếu bạn đặt cùng cấu hình trong `~/.claude/settings.json`, `.` sẽ phân giải tới `~/.claude` thay thế, và các file dự án vẫn bị chặn bởi quy tắc `denyRead`.

### Bảo vệ thông tin xác thực (credentials)

Thiết lập `sandbox.credentials` khai báo các file credential và biến môi trường cần bảo vệ khỏi các lệnh sandbox. Mỗi mục đặt tên một đường dẫn file hoặc một biến môi trường và một `mode`. Khối `credentials` riêng biệt giữ các quy tắc credential được nhóm lại với nhau và tách khỏi các quy tắc hệ thống file chung. Cần Claude Code v2.1.187 trở lên.

Đối với các mục có `"mode": "deny"`, các đường dẫn file bị từ chối đọc bên trong sandbox, cùng hạn chế mà `filesystem.denyRead` áp dụng, và các biến môi trường bị hủy đặt (unset) trước mỗi lệnh sandbox chạy.

Ví dụ dưới đây chặn đọc file credential của AWS và thư mục SSH, và loại bỏ `GITHUB_TOKEN` và `NPM_TOKEN` khỏi môi trường của các lệnh sandbox:

```json theme={null}
{
  "sandbox": {
    "enabled": true,
    "credentials": {
      "files": [
        { "path": "~/.aws/credentials", "mode": "deny" },
        { "path": "~/.ssh", "mode": "deny" }
      ],
      "envVars": [
        { "name": "GITHUB_TOKEN", "mode": "deny" },
        { "name": "NPM_TOKEN", "mode": "deny" }
      ]
    }
  }
}
```

Các mục file chỉ hỗ trợ `"mode": "deny"`. Các mục biến môi trường còn chấp nhận `"mode": "mask"`, được mô tả dưới đây.

Các đường dẫn file tuân theo cùng [quy tắc tiền tố](/en/settings#sandbox-path-prefixes) như các thiết lập `sandbox.filesystem.*`, và các mục `deny` từ mọi [phạm vi settings](/en/settings#settings-precedence) được gộp lại. Một mục `deny` chỉ luôn làm hẹp quyền truy cập, nên bất kỳ phạm vi nào cũng có thể thêm một mục, nhưng không phạm vi nào có thể gỡ bỏ một mục mà phạm vi khác đã thêm.

Không có danh sách từ chối credential tích hợp sẵn, nên chỉ các file và biến bạn liệt kê mới bị hạn chế. Thiết lập này chỉ ảnh hưởng đến các lệnh Bash sandbox. Để loại bỏ các credential của Anthropic và nhà cung cấp đám mây khỏi mọi tiến trình con bất kể sandboxing, hãy đặt [`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`](/en/env-vars).

#### Che (mask) biến môi trường

`"mode": "mask"` bảo vệ một credential trong khi vẫn giữ các công cụ xác thực bằng nó hoạt động. `deny` loại bỏ biến hoàn toàn, điều này cũng làm hỏng các công cụ cần nó, chẳng hạn `gh` hoặc `npm`. Cần Claude Code v2.1.199 trở lên.

Với `mask`, lệnh sandbox thấy một giá trị canh (sentinel) theo từng phiên thay vì giá trị thực. Khi một yêu cầu rời sandbox tới một trong các `injectHosts` của credential, [sandbox proxy](#network-isolation) thay giá trị canh bằng giá trị thực. Lệnh và bất cứ gì nó ghi log không bao giờ giữ credential thực, nhưng các yêu cầu của nó vẫn xác thực.

Proxy thay credential bên trong nội dung yêu cầu, nên nó phải nhìn thấy chúng. Đặt [`network.tlsTerminate`](/en/settings#sandbox-settings) để proxy tự chấm dứt (terminate) HTTPS. Không có nó, masking thất bại theo hướng an toàn (fail closed): lệnh vẫn chỉ thấy giá trị canh, nhưng giá trị canh tới máy chủ không thay đổi và xác thực thất bại. Claude Code báo cáo lỗi cấu hình này lúc khởi động và trong `/doctor`.

Ví dụ dưới đây che hai token. `GH_TOKEN` chỉ được thay trên các yêu cầu tới `api.github.com`, trong khi `NPM_TOKEN` không có `injectHosts` và được thay trên các yêu cầu tới mọi host trong `network.allowedDomains`. Mỗi mục `injectHosts` bản thân nó phải được bao trùm bởi `network.allowedDomains`.

```json theme={null}
{
  "sandbox": {
    "enabled": true,
    "network": {
      "tlsTerminate": {},
      "allowedDomains": ["*.github.com", "registry.npmjs.org"]
    },
    "credentials": {
      "envVars": [
        { "name": "GH_TOKEN", "mode": "mask", "injectHosts": ["api.github.com"] },
        { "name": "NPM_TOKEN", "mode": "mask" }
      ]
    }
  }
}
```

Không như `deny`, masking cho phép proxy gửi credential thực của bạn tới các host được liệt kê, nên nó chỉ được tôn trọng từ các settings mà bạn hoặc quản trị viên kiểm soát: user settings, managed settings, và cờ CLI `--settings`. Các mục `mask`, `network.tlsTerminate`, và [`credentials.allowPlaintextInject`](/en/settings#sandbox-settings) trong `.claude/settings.json` hoặc `.claude/settings.local.json` của một kho đều bị bỏ qua.

Khi cùng một biến được liệt kê với `deny` ở bất kỳ phạm vi nào, `deny` được ưu tiên.

## Cách sandboxing hoạt động

### Cô lập hệ thống file

Công cụ Bash chạy trong sandbox hạn chế quyền truy cập hệ thống file vào các thư mục cụ thể:

* **Hành vi ghi mặc định**: quyền đọc và ghi vào thư mục làm việc hiện tại và các thư mục con của nó, cộng với thư mục tạm của phiên mà `$TMPDIR` trỏ tới
* **Hành vi đọc mặc định**: quyền đọc toàn bộ máy tính, trừ một số thư mục bị từ chối. Lưu ý rằng mặc định này vẫn cho phép đọc các file credential như `~/.aws/credentials` và `~/.ssh/`. Dùng [`sandbox.credentials`](#protect-credentials) để chặn đọc các file này và hủy đặt các biến môi trường bí mật, hoặc thêm các đường dẫn vào `denyRead`.
* **Truy cập bị chặn**: không thể sửa các file ngoài thư mục làm việc hiện tại và thư mục tạm của phiên nếu không có quyền tường minh, bao gồm các file cấu hình shell như `~/.bashrc` và các binary hệ thống trong `/bin/`
* **Git worktrees**: khi thư mục làm việc là một [git worktree được liên kết](/en/worktrees), sandbox cũng cho phép ghi vào thư mục `.git` được chia sẻ của kho chính để các lệnh như `git commit` có thể cập nhật ref và index. Việc ghi vào `hooks/` và `config` bên trong thư mục đó vẫn bị từ chối.
* **Có thể cấu hình**: định nghĩa các đường dẫn được phép và bị từ chối tùy chỉnh qua settings

Bạn có thể cấp quyền ghi cho các đường dẫn bổ sung bằng `sandbox.filesystem.allowWrite` trong settings của bạn. Các hạn chế này được thực thi ở cấp hệ điều hành, nên chúng áp dụng cho mọi lệnh tiến trình con, bao gồm các công cụ như `kubectl`, `terraform`, và `npm`, không chỉ các công cụ file của Claude.

### Cô lập mạng

Quyền truy cập mạng được kiểm soát qua một máy chủ proxy chạy ngoài sandbox:

* **Hạn chế miền**: không có miền nào được cho phép trước. Lần đầu tiên một lệnh cần một miền mới, Claude Code hỏi để phê duyệt. {/* min-version: 2.1.191 */}Kể từ v2.1.191, chọn Yes cho phép host trong phần còn lại của phiên hiện tại, nên các kết nối sau tới cùng host không hỏi lại. Cho phép trước các miền bằng [`allowedDomains`](/en/settings#sandbox-settings) để tránh hoàn toàn việc hỏi.
* **Khóa quản lý (managed lockdown)**: nếu [`allowManagedDomainsOnly`](/en/settings#sandbox-settings) được đặt trong managed settings, các miền không được phép bị chặn tự động thay vì hỏi, và chỉ `allowedDomains` từ managed settings được tôn trọng.
* **Hỗ trợ proxy tùy chỉnh**: người dùng nâng cao có thể triển khai các quy tắc tùy chỉnh trên lưu lượng đi ra
* **Bao phủ toàn diện**: các hạn chế áp dụng cho mọi script, chương trình, và tiến trình con được sinh ra bởi các lệnh

<Note>
  Proxy tích hợp thực thi danh sách cho phép dựa trên hostname được yêu cầu và, theo mặc định, không chấm dứt hay kiểm tra lưu lượng TLS. {/* min-version: 2.1.199 */}Thiết lập thử nghiệm [`network.tlsTerminate`](/en/settings#sandbox-settings), có trong Claude Code v2.1.199 trở lên, làm cho proxy tích hợp tự chấm dứt TLS, điều mà [các mục credential `mask`](#protect-credentials) yêu cầu. Xem [Hạn chế bảo mật](#security-limitations) để biết hệ quả của mặc định, và [Cấu hình proxy tùy chỉnh](#custom-proxy-configuration) nếu mô hình đe dọa của bạn yêu cầu kiểm tra TLS.
</Note>

### Thực thi ở cấp hệ điều hành

Công cụ Bash chạy trong sandbox tận dụng các nguyên thủy bảo mật của hệ điều hành:

* **macOS**: dùng Seatbelt để thực thi sandbox
* **Linux**: dùng [bubblewrap](https://github.com/containers/bubblewrap) để cô lập
* **WSL2**: dùng bubblewrap, giống Linux

WSL1 không được hỗ trợ vì bubblewrap cần các tính năng kernel chỉ có trong WSL2. Các hạn chế cấp hệ điều hành này đảm bảo rằng mọi tiến trình con được sinh ra bởi các lệnh của Claude Code kế thừa cùng ranh giới bảo mật.

Cùng các nguyên thủy này cũng có sẵn dưới dạng gói độc lập [`@anthropic-ai/sandbox-runtime`](https://github.com/anthropic-experimental/sandbox-runtime), mà trang [Sandbox environments](/en/sandbox-environments#sandbox-runtime) trình bày như một cách tiếp cận riêng để bao bọc toàn bộ tiến trình Claude Code.

## Cách sandboxing liên quan đến quyền và chế độ quyền

Sandboxing, [quy tắc quyền](/en/permissions), và [chế độ quyền](/en/permission-modes) là các lớp bổ trợ. Các phần dưới đây trình bày cách sandbox tương tác với từng lớp.

### Quy tắc quyền

Quy tắc quyền và sandboxing kiểm soát những thứ khác nhau:

* **Quy tắc quyền** kiểm soát những công cụ nào Claude Code có thể dùng và được đánh giá trước khi bất kỳ công cụ nào chạy. Chúng áp dụng cho mọi công cụ: Bash, Read, Edit, WebFetch, MCP, và các công cụ khác.
* **Sandboxing** cung cấp sự thực thi ở cấp hệ điều hành, hạn chế những gì các lệnh Bash có thể truy cập ở cấp hệ thống file và mạng. Nó chỉ áp dụng cho các lệnh Bash và các tiến trình con của chúng.

Hai lớp cũng khác nhau ở cách chúng được thực thi. Claude Code đánh giá các quyết định quyền trước khi một lệnh chạy, dựa trên chuỗi lệnh và, trong chế độ auto, dựa trên phán đoán của một bộ phân loại riêng về việc lệnh có an toàn hay không. Hệ điều hành thực thi ranh giới sandbox trên tiến trình đang chạy, nên nó giữ vững bất kể mô hình chọn chạy gì và ngay cả khi một lệnh được phép làm nhiều hơn tên của nó gợi ý.

Các hạn chế hệ thống file và mạng được cấu hình qua cả sandbox settings lẫn quy tắc quyền:

| Thiết lập hoặc quy tắc                                            | Nó làm gì                                                                                          |
| :--------------------------------------------------------------- | :------------------------------------------------------------------------------------------------ |
| `sandbox.filesystem.allowWrite`                                  | Cấp cho tiến trình con quyền ghi vào các đường dẫn ngoài thư mục làm việc                          |
| `sandbox.filesystem.denyWrite` và `sandbox.filesystem.denyRead`  | Chặn tiến trình con truy cập các đường dẫn cụ thể                                                  |
| `sandbox.filesystem.allowRead`                                   | Cho phép lại việc đọc các đường dẫn cụ thể trong một vùng `denyRead`                               |
| Quy tắc allow của `Edit`                                         | Cấp quyền ghi cho các đường dẫn cụ thể, cùng cách như `sandbox.filesystem.allowWrite`             |
| Quy tắc deny của `Read` và `Edit`                                | Chặn truy cập các file hoặc thư mục cụ thể                                                         |
| Quy tắc allow và deny của `WebFetch`                             | Kiểm soát quyền truy cập miền                                                                      |
| `allowedDomains` của sandbox                                     | Kiểm soát những miền nào các lệnh Bash có thể tiếp cận                                            |
| `deniedDomains` của sandbox                                      | Chặn các miền cụ thể ngay cả khi một ký tự đại diện `allowedDomains` rộng hơn lẽ ra sẽ cho phép   |

Các đường dẫn từ cả thiết lập `sandbox.filesystem` lẫn quy tắc quyền được gộp lại thành cấu hình sandbox cuối cùng.

[Thư mục examples của kho claude-code](https://github.com/anthropics/claude-code/tree/main/examples/settings) bao gồm các cấu hình settings khởi đầu cho các kịch bản triển khai thông dụng, kể cả các ví dụ riêng cho sandbox. Dùng chúng làm điểm khởi đầu và điều chỉnh cho phù hợp với nhu cầu của bạn.

### Chế độ quyền

`/sandbox` không phải là một [chế độ quyền](/en/permission-modes). Chế độ quyền quyết định liệu một lệnh gọi công cụ có chạy hay không và liệu bạn có được hỏi trước hay không, trong khi sandbox hạn chế những gì một lệnh Bash có thể truy cập một khi nó chạy. Chúng khác nhau ở những gì chúng kiểm soát và những gì thay thế cho lời nhắc theo từng hành động:

|                                                                    | Nó kiểm soát gì                             | Cái gì thay thế lời nhắc                                                                                                                                                                                    |
| :----------------------------------------------------------------- | :------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/sandbox`                                                         | Những gì một lệnh Bash có thể truy cập một khi nó chạy | Chính ranh giới sandbox, trong [chế độ auto-allow](#sandbox-modes)                                                                                                                            |
| [Chế độ auto](/en/permission-modes#eliminate-prompts-with-auto-mode) | Liệu mỗi lệnh gọi công cụ có chạy hay không | Một bộ phân loại xem xét các hành động                                                                                                                                                                    |
| `--dangerously-skip-permissions`                                   | Liệu mỗi lệnh gọi công cụ có chạy hay không | Không có gì. Các kiểm tra [đường dẫn được bảo vệ](/en/permission-modes#protected-paths) cũng bị bỏ qua; chỉ các [quy tắc ask](/en/permissions#manage-permissions) tường minh và việc xóa `/` hoặc thư mục home của bạn vẫn hỏi |

Chế độ [auto-allow](#sandbox-modes) của sandbox tách biệt với [chế độ auto](/en/permission-modes#eliminate-prompts-with-auto-mode): auto-allow phê duyệt các lệnh Bash vì ranh giới sandbox chứa chúng, trong khi chế độ auto dùng một bộ phân loại để xem xét các hành động. Hai cái này hoạt động độc lập và có thể kết hợp. Để chọn một ranh giới cô lập cho các lần chạy không giám sát, xem [Sandbox environments](/en/sandbox-environments#how-isolation-relates-to-permission-modes).

## Cấu hình sandbox cho tổ chức của bạn

Quản trị viên có thể yêu cầu sandboxing cho mọi người dùng, ngăn lập trình viên nới rộng chính sách, và định tuyến lưu lượng sandbox qua một proxy doanh nghiệp.

### Thực thi sandboxing với managed settings

Để yêu cầu sandbox cho mọi lập trình viên, hãy phân phối các khóa `sandbox` qua [managed settings](/en/settings#settings-files), hoặc dưới dạng một file được quản lý bởi MDM của bạn hoặc qua [server-managed settings](/en/server-managed-settings) trên Claude.ai.

Cấu hình managed settings sau đây bật sandbox, từ chối khởi động Claude Code nếu sandbox không thể khởi tạo, và ngăn mô hình thử lại các lệnh ngoài sandbox:

```json theme={null}
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false
  }
}
```

Hai khóa ngoài `enabled` kiểm soát điều gì xảy ra khi sandbox không thể chạy một lệnh:

* **`failIfUnavailable`**: một dependency thiếu như bubblewrap trên Linux sẽ chặn Claude Code khởi động thay vì hiển thị cảnh báo và quay về thực thi ngoài sandbox
* **`allowUnsandboxedCommands: false`**: cửa thoát `dangerouslyDisableSandbox` bị bỏ qua, nên các lệnh thất bại trong sandbox không thể được thử lại ngoài nó

Có hai bổ sung đáng cân nhắc kèm theo chúng. Thêm `excludedCommands` cho bất kỳ công cụ được tổ chức phê duyệt nào phải chạy không cô lập. Thêm các mục [`sandbox.credentials`](#protect-credentials) cho các thư mục credential như `~/.aws` và `~/.ssh` và cho các biến môi trường bí mật, vì chính sách đọc mặc định vẫn cho phép chúng.

Sandbox không chạy trên Windows gốc, nên nếu đội máy của bạn bao gồm các host Windows, hãy giới hạn cấu hình này cho macOS và Linux hoặc để những người dùng đó chạy Claude Code bên trong WSL2 hoặc một container.

### Ngăn lập trình viên nới rộng chính sách

Đối với các khóa boolean như `enabled` và `failIfUnavailable`, Claude Code dùng giá trị managed và bỏ qua bất cứ gì một lập trình viên đặt cục bộ. Đối với các khóa mảng như `excludedCommands` và `allowRead`, Claude Code gộp các mục từ mọi phạm vi, nên một lập trình viên có thể thêm các mục nới rộng chính sách.

Đặt `allowManagedReadPathsOnly` thành `true` trong managed settings để chỉ các mục `allowRead` từ managed settings được tôn trọng. Các mục `allowRead` của user, project, và local bị bỏ qua. Điều này ngăn lập trình viên nới rộng quyền đọc vượt quá các đường dẫn được tổ chức phê duyệt. Để khóa các miền mạng theo giá trị managed cùng cách, hãy đặt [`allowManagedDomainsOnly`](/en/settings#sandbox-settings).

`excludedCommands` không có khóa managed-only tương đương, nên một lập trình viên luôn có thể thêm các mục để chạy thêm lệnh ngoài sandbox. Hãy giữ danh sách managed hẹp.

### Cấu hình proxy tùy chỉnh

Đối với các tổ chức yêu cầu bảo mật mạng nâng cao, bạn có thể triển khai một proxy tùy chỉnh để:

* Giải mã và kiểm tra lưu lượng HTTPS
* Áp dụng các quy tắc lọc tùy chỉnh
* Ghi log mọi yêu cầu mạng
* Tích hợp với hạ tầng bảo mật hiện có

Để trỏ Claude Code tới proxy của bạn, hãy đặt các cổng proxy trong [sandbox settings](/en/settings#sandbox-settings):

```json theme={null}
{
  "sandbox": {
    "network": {
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    }
  }
}
```

## Khắc phục sự cố

Một số lệnh thất bại bên trong sandbox dù chúng hoạt động ngoài nó. Các cách khắc phục dưới đây bao quát các trường hợp phổ biến nhất.

* **Lệnh thất bại với lỗi host-not-allowed**: nhiều công cụ CLI cần tiếp cận các host cụ thể. Cấp quyền khi được hỏi sẽ thêm host vào danh sách được phép để công cụ chạy bên trong sandbox trong tương lai.
* **`jest` treo hoặc thất bại**: `watchman` không tương thích với sandbox. Chạy `jest --no-watchman` thay thế.
* **Các CLI dựa trên Go thất bại xác minh TLS trên macOS**: các công cụ như `gh`, `gcloud`, và `terraform` có thể thất bại xác minh TLS dưới Seatbelt. Liệt kê các công cụ này trong `excludedCommands` để chạy chúng ngoài sandbox. Nếu bạn đang dùng `httpProxyPort` với một proxy MITM và CA tùy chỉnh, hãy đặt [`enableWeakerNetworkIsolation`](/en/settings#sandbox-settings) thành `true` thay thế.
* **`open`, `osascript`, hoặc các luồng xác thực dựa trên trình duyệt thất bại với lỗi `-600` trên macOS**: sandbox chặn Apple Events theo mặc định. Đặt [`allowAppleEvents`](/en/settings#sandbox-settings) thành `true` trong settings của user, managed, hoặc CLI của bạn để cho phép chúng. Project settings bị bỏ qua đối với khóa này. Bật nó loại bỏ sự cô lập thực thi mã, vì các lệnh sandbox khi đó có thể khởi chạy các ứng dụng khác ngoài sandbox mà không hỏi người dùng và gửi lệnh AppleScript tới các ứng dụng đang chạy, tùy thuộc lời nhắc đồng ý tự động hóa của macOS (TCC). Cách khác, thêm lệnh vào `excludedCommands` để chạy nó ngoài sandbox.
* **Lệnh `docker` thất bại**: `docker` không tương thích với sandbox. Thêm `docker *` vào `excludedCommands` để chạy nó ngoài sandbox.
* **Bubblewrap không khởi động được bên trong một container**: trong một container không đặc quyền, bubblewrap không thể mount một hệ thống file `/proc` mới. Đặt [`enableWeakerNestedSandbox`](/en/settings#sandbox-settings) thành `true` để sandbox bên trong bind-mount `/proc` hiện có của container thay thế. Chỉ dùng thiết lập này khi container bên ngoài đã cung cấp ranh giới cô lập bạn cần, vì nó phơi bày thông tin tiến trình cho các lệnh sandbox mà một mount `/proc` mới sẽ ẩn đi.
* **Bộ lọc seccomp trên Linux**: bộ lọc seccomp là bắt buộc để chặn Unix domain socket. Tab Dependencies trong `/sandbox` cho biết nó có khả dụng không. Nếu nó bị thiếu, chạy `npm install -g @anthropic-ai/sandbox-runtime` để cài helper.
* **`--dangerously-skip-permissions` thất bại khi chạy dưới root**: cờ này bị chặn khi chạy dưới root hoặc qua sudo trên Linux và macOS, vì quyền root kết hợp với không có lời nhắc quyền có thể sửa bất kỳ file hoặc dịch vụ nào trên hệ thống. Kiểm tra được bỏ qua tự động bên trong một sandbox được nhận diện. Để chạy tự chủ trong một container, dùng cấu hình [dev container](/en/devcontainer), vốn chạy Claude Code với tư cách người dùng không phải root.

## Hạn chế

Sandboxing giảm rủi ro nhưng không phải là một ranh giới cô lập hoàn chỉnh. Hãy xem xét các hạn chế dưới đây trước khi dựa vào nó như một kiểm soát bảo mật cứng.

### Hạn chế bảo mật

* **Lọc mạng**: sandbox hạn chế những miền nào các tiến trình có thể kết nối tới. Theo mặc định proxy tích hợp không chấm dứt hay kiểm tra TLS trên lưu lượng đi ra, nên nội dung của các kết nối được mã hóa không được kiểm tra. Thiết lập thử nghiệm [`network.tlsTerminate`](/en/settings#sandbox-settings) chấm dứt TLS tại proxy cho [việc thay thế credential `mask`](#protect-credentials) nhưng không thêm việc lọc nội dung. Bạn chịu trách nhiệm đảm bảo rằng chỉ các miền đáng tin cậy được phép trong chính sách của bạn.

<Warning>
  Cho phép các miền rộng như `github.com` có thể tạo đường cho việc rò rỉ dữ liệu (data exfiltration). Vì proxy đưa ra quyết định cho phép từ hostname do client cung cấp mà không kiểm tra TLS, mã chạy bên trong sandbox có thể tiềm tàng dùng [domain fronting](https://en.wikipedia.org/wiki/Domain_fronting) hoặc các kỹ thuật tương tự để tiếp cận các host ngoài danh sách cho phép. Nếu mô hình đe dọa của bạn yêu cầu các đảm bảo mạnh hơn, hãy cấu hình một [proxy tùy chỉnh](#custom-proxy-configuration) chấm dứt TLS và kiểm tra lưu lượng, và cài chứng chỉ CA của nó bên trong sandbox. Sự cô lập mạng nhận biết TLS mạnh hơn là một lĩnh vực đang được phát triển tích cực.
</Warning>

* **Leo thang đặc quyền qua Unix socket**: cấu hình `allowUnixSockets` có thể vô tình cấp quyền truy cập các dịch vụ hệ thống mạnh mẽ dẫn tới việc vượt qua sandbox. Ví dụ, cho phép truy cập `/var/run/docker.sock` thực tế cấp quyền truy cập hệ thống host qua Docker socket. Hãy cân nhắc kỹ bất kỳ Unix socket nào bạn cho phép qua sandbox.
* **Leo thang quyền hệ thống file**: quyền ghi hệ thống file quá rộng có thể cho phép các cuộc tấn công leo thang đặc quyền. Cho phép ghi vào các thư mục chứa file thực thi trong `$PATH`, các thư mục cấu hình hệ thống, hoặc các file cấu hình shell của người dùng như `.bashrc` hoặc `.zshrc` có thể dẫn tới thực thi mã trong các ngữ cảnh bảo mật khác khi những người dùng hoặc tiến trình hệ thống khác truy cập các file này.
* **Độ mạnh của sandbox trên Linux**: bản triển khai Linux cung cấp sự cô lập hệ thống file và mạng mạnh nhưng bao gồm một chế độ `enableWeakerNestedSandbox` cho phép nó hoạt động bên trong các môi trường Docker không có namespace đặc quyền, hoặc trên các host Linux nơi user namespace không đặc quyền bị vô hiệu hóa bởi sysctl. Tùy chọn này làm yếu bảo mật đáng kể và chỉ nên dùng khi có sự cô lập bổ sung được thực thi bằng cách khác.
* **Apple Events trên macOS**: sandbox macOS chặn Apple Events theo mặc định. Thiết lập `allowAppleEvents` gỡ bỏ hạn chế này để các công cụ như `open` và `osascript` hoạt động, nhưng nó loại bỏ sự cô lập thực thi mã: các lệnh sandbox có thể khởi chạy các ứng dụng khác ngoài sandbox mà không hỏi người dùng, và có thể gửi lệnh AppleScript tới các ứng dụng đang chạy, tùy thuộc lời nhắc đồng ý tự động hóa của macOS theo từng ứng dụng (TCC). Nó chỉ được tôn trọng từ settings của user, managed, hoặc CLI. Project settings không thể bật nó.
* **File settings được bảo vệ**: sandbox tự động từ chối quyền ghi vào các file `settings.json` của Claude Code ở mọi phạm vi và vào thư mục managed settings, nên một lệnh sandbox không thể sửa chính sách của chính nó.

### Tương thích nền tảng và công cụ

* **Hỗ trợ nền tảng**: hỗ trợ macOS, Linux, và WSL2. WSL1 và Windows gốc không được hỗ trợ.
* **Chi phí hiệu năng**: tối thiểu, nhưng một số thao tác hệ thống file có thể chậm hơn đôi chút.
* **Tương thích công cụ**: một số công cụ yêu cầu các mẫu truy cập hệ thống cụ thể có thể cần điều chỉnh cấu hình, hoặc có thể cần chạy ngoài sandbox.

### Phạm vi

Sandbox cô lập các tiến trình con Bash. Các công cụ khác hoạt động dưới các ranh giới khác:

* **Các công cụ file tích hợp**: Read, Edit, và Write dùng hệ thống quyền trực tiếp thay vì chạy qua sandbox. Xem [permissions](/en/permissions).
* **Computer use**: khi Claude mở ứng dụng và điều khiển màn hình của bạn, nó chạy trên desktop thật của bạn thay vì trong một môi trường cô lập. Các lời nhắc quyền theo từng ứng dụng kiểm soát mỗi ứng dụng. Xem [computer use in the CLI](/en/computer-use) hoặc [computer use in Desktop](/en/desktop#let-claude-use-your-computer).
* **Biến môi trường**: các lệnh Bash sandbox kế thừa môi trường tiến trình cha theo mặc định, bao gồm bất kỳ credential nào được đặt ở đó. Dùng [`sandbox.credentials`](#protect-credentials) để hủy đặt hoặc che các biến cụ thể cho các lệnh sandbox, hoặc đặt [`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB`](/en/env-vars) để loại bỏ các credential của Anthropic và nhà cung cấp đám mây khỏi mọi tiến trình con.
* **Subagents**: [subagents](/en/sub-agents) chạy trong cùng tiến trình như phiên cha và dùng cùng cấu hình sandbox. Các lệnh Bash bên trong một subagent được sandbox khi sandboxing được bật trong phiên cha.

<Warning>
  Sandboxing hiệu quả cần cả sự cô lập hệ thống file lẫn mạng. Không có cô lập mạng, một agent bị xâm phạm có thể rò rỉ các file nhạy cảm như khóa SSH. Không có cô lập hệ thống file, một agent bị xâm phạm có thể cài cửa hậu (backdoor) vào các tài nguyên hệ thống để giành quyền truy cập mạng. Khi bạn nới rộng các mặc định, hãy kiểm tra rằng một đường dẫn `allowWrite`, một mục `allowedDomains` rộng, hoặc một ngoại lệ `excludedCommands` không phá bỏ một hạn chế ở phía bên kia.
</Warning>

## Xem thêm

* [Sandbox environments](/en/sandbox-environments): so sánh sandbox tích hợp với dev container, container, và VM
* [Security](/en/security): các tính năng bảo mật toàn diện và thực hành tốt nhất
* [Permissions](/en/permissions): cấu hình quyền và kiểm soát truy cập
* [Settings](/en/settings): tham chiếu cấu hình đầy đủ
* [CLI reference](/en/cli-reference): các tùy chọn dòng lệnh
