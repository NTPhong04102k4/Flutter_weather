> Nguồn: https://code.claude.com/docs/en/permission-modes.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Chọn chế độ quyền (permission mode)

> Kiểm soát việc Claude có hỏi trước khi chỉnh sửa file hay chạy lệnh hay không. Chuyển vòng qua các chế độ bằng Shift+Tab trong CLI, hoặc dùng bộ chọn chế độ trong VS Code, Desktop và claude.ai.

Khi Claude muốn chỉnh sửa một file, chạy một lệnh shell hoặc thực hiện một yêu cầu mạng, nó sẽ tạm dừng và hỏi bạn phê duyệt hành động đó. Các chế độ quyền kiểm soát tần suất diễn ra việc tạm dừng này. Chế độ bạn chọn định hình luồng làm việc của một phiên: chế độ Manual (Thủ công) yêu cầu bạn xem xét từng hành động khi nó xuất hiện, trong khi các chế độ lỏng lẻo hơn cho phép Claude làm việc liên tục trong những khoảng dài hơn rồi báo cáo lại khi xong. Hãy chọn mức giám sát cao hơn cho công việc nhạy cảm, hoặc ít gián đoạn hơn khi bạn tin tưởng vào hướng đi.

## Các chế độ hiện có

Mỗi chế độ đưa ra một sự đánh đổi khác nhau giữa tiện lợi và giám sát. Bảng dưới đây cho thấy Claude có thể làm gì mà không cần permission prompt (lời nhắc xin quyền) trong mỗi chế độ.

| Chế độ                                                              | Chạy mà không cần hỏi                                                                    | Phù hợp nhất cho                          |
| :------------------------------------------------------------------ | :-------------------------------------------------------------------------------------- | :--------------------------------------- |
| `default`                                                           | Chỉ đọc. Được gán nhãn **Manual** trong CLI và các extension IDE                         | Bắt đầu làm quen, công việc nhạy cảm      |
| [`acceptEdits`](#auto-approve-file-edits-with-acceptedits-mode)     | Đọc, chỉnh sửa file, và các lệnh hệ thống file phổ biến (`mkdir`, `touch`, `mv`, `cp`, v.v.) | Lặp lại chỉnh sửa trên code bạn đang xem xét |
| [`plan`](#analyze-before-you-edit-with-plan-mode)                   | Chỉ đọc                                                                                  | Khám phá một codebase trước khi thay đổi  |
| [`auto`](#eliminate-prompts-with-auto-mode)                         | Mọi thứ, kèm kiểm tra an toàn ở nền                                                      | Tác vụ dài, giảm mệt mỏi vì bị hỏi nhiều  |
| [`dontAsk`](#allow-only-pre-approved-tools-with-dontask-mode)       | Chỉ các tool đã được phê duyệt trước                                                     | CI và script bị khóa chặt                 |
| [`bypassPermissions`](#skip-all-checks-with-bypasspermissions-mode) | Mọi thứ                                                                                  | Chỉ dùng trong container và VM cô lập     |

Chế độ xem xét mọi hành động được đặt tên là **Manual** trong CLI, trong `claude --help`, và trong các extension VS Code và JetBrains. Giá trị cấu hình của nó là `default`, đây là giá trị mà hook và các tích hợp SDK sử dụng. CLI chấp nhận `manual` làm alias (bí danh) ở bất cứ nơi nào bạn nhập giá trị, ví dụ `claude --permission-mode manual` hoặc `"defaultMode": "manual"`. Nhãn Manual và alias `manual` yêu cầu Claude Code v2.1.200 trở lên.

Ở mọi chế độ ngoại trừ `bypassPermissions`, các thao tác ghi vào [protected paths (đường dẫn được bảo vệ)](#protected-paths) không bao giờ được tự động phê duyệt, giúp bảo vệ trạng thái repository và cấu hình của chính Claude khỏi bị hỏng do vô ý.

Các chế độ thiết lập mức cơ sở. Hãy chồng thêm [permission rules (quy tắc quyền)](/en/permissions#manage-permissions) lên trên để phê duyệt trước hoặc chặn các tool cụ thể. Quy tắc deny và quy tắc ask tường minh áp dụng ở mọi chế độ, kể cả `bypassPermissions`. Quy tắc allow không có tác dụng ở chế độ đó vì mọi thứ khác đã được phê duyệt sẵn.

## Chuyển đổi chế độ quyền

Bạn có thể chuyển chế độ giữa phiên, lúc khởi động, hoặc dưới dạng mặc định cố định. Chế độ được thiết lập qua các điều khiển này, chứ không phải bằng cách yêu cầu Claude trong khung chat. Chọn giao diện của bạn bên dưới để xem cách thay đổi.

<Tabs>
  <Tab title="CLI">
    **Trong một phiên**: nhấn `Shift+Tab` để chuyển vòng `default` → `acceptEdits` → `plan`. Chế độ hiện tại xuất hiện trên thanh trạng thái. Không phải chế độ nào cũng nằm trong vòng chuyển mặc định:

    * `auto`: xuất hiện khi tài khoản của bạn đáp ứng [các yêu cầu của chế độ auto](#eliminate-prompts-with-auto-mode); chuyển vòng tới nó sẽ đổi chế độ mà không cần lời nhắc xác nhận
    * `bypassPermissions`: xuất hiện sau khi bạn khởi động với `--permission-mode bypassPermissions`, `--dangerously-skip-permissions`, hoặc `--allow-dangerously-skip-permissions`; biến thể `--allow-` thêm chế độ này vào vòng chuyển mà không kích hoạt nó
    * `dontAsk`: không bao giờ xuất hiện trong vòng chuyển; thiết lập nó bằng `--permission-mode dontAsk`

    Các chế độ tùy chọn đã được bật được chèn vào sau `plan`, với `bypassPermissions` đứng trước và `auto` đứng cuối. Nếu bạn bật cả hai, bạn sẽ đi qua `bypassPermissions` trên đường tới `auto`.

    **Lúc khởi động**: truyền chế độ dưới dạng flag.

    ```bash theme={null}
    claude --permission-mode plan
    ```

    **Dưới dạng mặc định**: thiết lập `defaultMode` trong [settings](/en/settings#settings-files).

    ```json theme={null}
    {
      "permissions": {
        "defaultMode": "acceptEdits"
      }
    }
    ```

    Cùng flag `--permission-mode` này hoạt động với `-p` cho [các lần chạy không tương tác](/en/headless).
  </Tab>

  <Tab title="VS Code">
    **Trong một phiên**: nhấp vào chỉ báo chế độ ở cuối khung nhập prompt.

    **Dưới dạng mặc định**: thiết lập `claudeCode.initialPermissionMode` trong cài đặt VS Code, hoặc dùng bảng cài đặt của extension Claude Code.

    Chỉ báo chế độ hiển thị các nhãn này, ánh xạ tới chế độ mà mỗi nhãn áp dụng:

    | Nhãn giao diện     | Chế độ              |
    | :----------------- | :------------------ |
    | Manual             | `default`           |
    | Edit automatically | `acceptEdits`       |
    | Plan mode          | `plan`              |
    | Auto mode          | `auto`              |
    | Bypass permissions | `bypassPermissions` |

    Auto mode xuất hiện trong chỉ báo chế độ khi tài khoản của bạn đáp ứng mọi yêu cầu được liệt kê trong [phần auto mode](#eliminate-prompts-with-auto-mode). Cài đặt `claudeCode.initialPermissionMode` không chấp nhận `auto`. Để khởi động ở chế độ auto theo mặc định, thay vào đó hãy thiết lập `defaultMode` trong [user settings](/en/settings#settings-files) của bạn. Claude Code bỏ qua `defaultMode: "auto"` trong project settings và local settings.

    Bypass permissions yêu cầu bật công tắc **Allow dangerously skip permissions** trong cài đặt extension trước khi nó xuất hiện trong chỉ báo chế độ.

    Xem [hướng dẫn VS Code](/en/vs-code) để biết chi tiết riêng cho extension.
  </Tab>

  <Tab title="JetBrains">
    Plugin JetBrains chạy Claude Code trong terminal của IDE, nên việc chuyển chế độ hoạt động giống như trong CLI: nhấn `Shift+Tab` để chuyển vòng, hoặc truyền `--permission-mode` khi khởi chạy.
  </Tab>

  <Tab title="Desktop">
    Dùng bộ chọn chế độ nằm cạnh nút gửi. Auto và Bypass permissions chỉ xuất hiện sau khi bạn bật chúng trong cài đặt Desktop. Xem [hướng dẫn Desktop](/en/desktop#choose-a-permission-mode).
  </Tab>

  <Tab title="Web và mobile">
    Dùng menu thả xuống chọn chế độ nằm cạnh khung nhập prompt trên [claude.ai/code](https://claude.ai/code) hoặc trong ứng dụng di động. Permission prompt xuất hiện trong claude.ai để phê duyệt. Chế độ nào xuất hiện tùy thuộc vào nơi phiên chạy:

    * **Phiên cloud** trên [Claude Code trên web](/en/claude-code-on-the-web): Accept edits, Plan mode, và Auto mode. Accept edits tương ứng với chế độ `default`: môi trường cloud phê duyệt trước các chỉnh sửa file bất kể chế độ nào, nên menu thả xuống hiển thị Accept edits thay vì Ask permissions. `defaultMode: "acceptEdits"` từ settings vẫn được tôn trọng. Auto mode chỉ xuất hiện khi tổ chức của bạn cho phép và model được chọn hỗ trợ nó. Bypass permissions không khả dụng.
    * **Phiên [Remote Control](/en/remote-control)** trên máy cục bộ của bạn: Ask permissions, Auto accept edits, và Plan mode. Auto và Bypass permissions không khả dụng.

    Với Remote Control, bạn cũng có thể đặt chế độ khởi động khi khởi chạy host:

    ```bash theme={null}
    claude remote-control --permission-mode acceptEdits
    ```
  </Tab>
</Tabs>

## Tự động phê duyệt chỉnh sửa file với chế độ acceptEdits

Chế độ `acceptEdits` cho phép Claude tạo và chỉnh sửa file trong thư mục làm việc của bạn mà không cần hỏi. Thanh trạng thái hiển thị `⏵⏵ accept edits on` khi chế độ này đang hoạt động.

Ngoài việc chỉnh sửa file, chế độ `acceptEdits` còn tự động phê duyệt các lệnh Bash hệ thống file phổ biến: `mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, và `sed`. Các lệnh này cũng được tự động phê duyệt khi được đặt trước bởi các biến môi trường an toàn như `LANG=C` hoặc `NO_COLOR=1`, hoặc các wrapper tiến trình như `timeout`, `nice`, hoặc `nohup`. Giống như chỉnh sửa file, việc tự động phê duyệt chỉ áp dụng cho các đường dẫn nằm trong thư mục làm việc của bạn hoặc trong `additionalDirectories`. Các đường dẫn ngoài phạm vi đó, các thao tác ghi vào [protected paths](#protected-paths), và tất cả các lệnh Bash khác vẫn sẽ hỏi.

Khi [PowerShell tool](/en/tools-reference#powershell-tool) được bật, chế độ `acceptEdits` cũng tự động phê duyệt `Set-Content`, `Add-Content`, `Clear-Content`, và `Remove-Item` trên các đường dẫn nằm trong phạm vi, cùng với các alias phổ biến của chúng. Cùng các quy tắc phạm vi và protected-path áp dụng.

Dùng `acceptEdits` khi bạn muốn xem lại các thay đổi trong trình soạn thảo hoặc qua `git diff` về sau, thay vì phê duyệt từng chỉnh sửa ngay tại chỗ.

Nhấn `Shift+Tab` một lần từ chế độ Manual để vào chế độ này, hoặc khởi động trực tiếp với nó:

```bash theme={null}
claude --permission-mode acceptEdits
```

## Phân tích trước khi chỉnh sửa với plan mode

Plan mode (chế độ lập kế hoạch) yêu cầu Claude nghiên cứu và đề xuất các thay đổi mà không thực hiện chúng. Claude đọc file, chạy lệnh shell để khám phá, và viết một kế hoạch, nhưng không chỉnh sửa mã nguồn của bạn. Permission prompt vẫn áp dụng như ở chế độ Manual.

Vào plan mode bằng cách nhấn `Shift+Tab` hoặc thêm tiền tố `/plan` cho một prompt đơn lẻ. Bạn cũng có thể khởi động ở plan mode từ CLI:

```bash theme={null}
claude --permission-mode plan
```

Nhấn `Shift+Tab` lần nữa để rời plan mode mà không phê duyệt kế hoạch.

### Xem lại và phê duyệt một kế hoạch

Khi kế hoạch đã sẵn sàng, Claude trình bày nó và hỏi cách tiến hành. Từ lời nhắc đó bạn có thể:

* Phê duyệt và bắt đầu ở chế độ auto
* Phê duyệt và chấp nhận các chỉnh sửa
* Phê duyệt và xem xét thủ công từng chỉnh sửa
* Tiếp tục lập kế hoạch kèm phản hồi
* Tinh chỉnh bằng [Ultraplan](/en/ultraplan) để xem xét trên trình duyệt

Phê duyệt một kế hoạch sẽ thoát plan mode và chuyển phiên sang chế độ quyền mà mỗi tùy chọn phê duyệt mô tả, nên Claude bắt đầu chỉnh sửa. Để lập kế hoạch lại, hãy chuyển vòng về plan mode bằng `Shift+Tab`, hoặc thêm tiền tố `/plan` cho prompt tiếp theo của bạn.

Nhấn `Ctrl+G` để mở kế hoạch được đề xuất trong trình soạn thảo văn bản mặc định của bạn và chỉnh sửa nó trực tiếp trước khi Claude tiến hành. Khi [`showClearContextOnPlanAccept`](/en/settings#available-settings) được bật, mỗi tùy chọn phê duyệt cũng đề xuất xóa context (ngữ cảnh) lập kế hoạch trước.

Việc chấp nhận một kế hoạch cũng tự động đặt tên phiên dựa trên nội dung kế hoạch, trừ khi bạn đã đặt tên bằng `--name` hoặc `/rename`.

### Đặt plan mode làm mặc định

Để biến plan mode thành mặc định cho một dự án, hãy thiết lập `defaultMode` trong `.claude/settings.json`:

```json theme={null}
{
  "permissions": {
    "defaultMode": "plan"
  }
}
```

<h2 id="eliminate-prompts-with-auto-mode">
  Loại bỏ permission prompt với auto mode
</h2>

<Note>
  Auto mode yêu cầu Claude Code v2.1.83 trở lên.
</Note>

Auto mode cho phép Claude thực thi mà không có các permission prompt thường lệ. Một model phân loại (classifier) riêng biệt xem xét các hành động trước khi chúng chạy, chặn bất cứ điều gì vượt quá phạm vi yêu cầu của bạn, nhắm vào hạ tầng không được nhận diện, hoặc có vẻ bị điều khiển bởi nội dung thù địch mà Claude đã đọc. Các [ask rule](/en/permissions#manage-permissions) tường minh vẫn buộc phải hỏi.

Auto mode cũng thúc đẩy Claude tiếp tục làm việc mà không dừng lại để hỏi các câu làm rõ, mặc dù Claude vẫn hỏi khi prompt của bạn hoặc một skill (kỹ năng) rõ ràng phụ thuộc vào việc đó. Để có hành vi tự chủ mạnh hơn trong khi vẫn giữ permission prompt, thay vào đó hãy thiết lập [output style Proactive](/en/output-styles).

<Warning>
  Auto mode là một bản xem trước nghiên cứu (research preview). Nó giảm permission prompt nhưng không đảm bảo an toàn. Hãy dùng nó cho các tác vụ mà bạn tin tưởng hướng đi chung, chứ không phải như một sự thay thế cho việc xem xét các thao tác nhạy cảm.
</Warning>

Auto mode chỉ khả dụng khi tài khoản của bạn đáp ứng tất cả các yêu cầu sau:

* **Gói (Plan)**: Tất cả các gói.
* **Chủ sở hữu (Owner)**: trên Team và Enterprise, một Owner phải bật nó trong [cài đặt quản trị Claude Code](https://claude.ai/admin-settings/claude-code) trước khi người dùng có thể bật nó. Quản trị viên cũng có thể khóa tắt nó bằng cách đặt `permissions.disableAutoMode` thành `"disable"` trong [managed settings](/en/permissions#managed-settings).
* **Model**: trên Anthropic API, Claude Opus 4.6 trở lên, hoặc Sonnet 4.6 trở lên. Trên Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, và các phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, chỉ có Claude Sonnet 5, Opus 4.7, và Opus 4.8. Các model cũ hơn, bao gồm Sonnet 4.5, Opus 4.5, Haiku, và các model claude-3, không được hỗ trợ trên bất kỳ nhà cung cấp nào.
* **Nhà cung cấp (Provider)**: khả dụng mặc định trên Anthropic API. Trên Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, và các phiên Claude apps gateway đã đăng nhập, auto mode bị tắt cho đến khi bạn [thiết lập `CLAUDE_CODE_ENABLE_AUTO_MODE`](#enable-auto-mode-on-bedrock-agent-platform-or-foundry).

Nếu Claude Code báo cáo auto mode là không khả dụng, thì một trong các yêu cầu này chưa được đáp ứng; đây không phải là sự cố tạm thời. Một thông báo riêng nêu tên một model và nói rằng auto mode "cannot determine the safety" (không thể xác định độ an toàn) của một hành động là một sự cố tạm thời của classifier; xem [tài liệu tham chiếu lỗi](/en/errors#auto-mode-cannot-determine-the-safety-of-an-action).

Nếu bạn thiết lập `defaultMode: "auto"` trong [settings](/en/settings#available-settings) và phiên khởi động ở chế độ `default` mà không có lỗi, thì cài đặt đó có lẽ đang nằm trong `.claude/settings.json` hoặc `.claude/settings.local.json`. Claude Code v2.1.142 trở lên bỏ qua `auto` từ những file đó để một repository không thể tự cấp cho mình auto mode. Hãy chuyển nó sang `~/.claude/settings.json`.

### Bật auto mode trên Bedrock, Agent Platform, hoặc Foundry

Trên [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry), và các phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, auto mode không xuất hiện trong vòng chuyển `Shift+Tab` cho đến khi `CLAUDE_CODE_ENABLE_AUTO_MODE` được đặt thành `1`. Biến này hoạt động trong Claude Code v2.1.158 trở lên. Chỉ có Claude Sonnet 5, Opus 4.7, và Opus 4.8 được hỗ trợ trên các nhà cung cấp này.

Để bật nó cho một nhà phát triển, hãy thêm biến vào khối `env` trong `~/.claude/settings.json`:

```json theme={null}
{
  "env": {
    "CLAUDE_CODE_ENABLE_AUTO_MODE": "1"
  }
}
```

Để bật nó cho tổ chức của bạn, hãy thêm cùng khối `env` vào [managed settings](/en/settings#settings-files).

Khi biến này được thiết lập, auto mode xuất hiện trong vòng chuyển `Shift+Tab` cho mọi phiên. Để biến nó thành chế độ khởi động mặc định, cũng hãy thiết lập `"permissions": {"defaultMode": "auto"}` trong user settings hoặc managed settings. Trên các nhà cung cấp này, Claude Code bỏ qua `defaultMode: "auto"` trừ khi `CLAUDE_CODE_ENABLE_AUTO_MODE` cũng được thiết lập.

Để ngăn nhà phát triển bật auto mode, hãy đặt `disableAutoMode` thành `"disable"` trong managed settings. Điều này ghi đè biến bật.

Nếu bạn kết nối qua một [LLM gateway](/en/llm-gateway) được cấu hình với `ANTHROPIC_BASE_URL`, auto mode có thể đã tiếp cận được mà không cần biến bật, vì gateway định tuyến các yêu cầu qua Anthropic API. Điều này không áp dụng cho một phiên [Claude apps gateway](/en/claude-apps-gateway) đã đăng nhập, vốn là một lớp nhà cung cấp riêng và yêu cầu biến bật. Cài đặt `disableAutoMode` áp dụng theo cùng cách trong cả hai cấu hình.

### Classifier chặn gì theo mặc định

Classifier tin tưởng thư mục làm việc của bạn và các remote đã được cấu hình cho nó khi phiên khởi động. {/* min-version: 2.1.200 */}Một remote được thêm hoặc trỏ lại trong phiên bằng `git remote add` hoặc `git remote set-url` không được tin tưởng, và mọi thứ khác được coi là bên ngoài cho đến khi bạn [cấu hình hạ tầng tin cậy](/en/auto-mode-config). Trước v2.1.200, các remote được thêm giữa phiên cũng được tin tưởng.

**Bị chặn theo mặc định**:

* Tải về và thực thi mã, như `curl | bash`
* Gửi dữ liệu nhạy cảm tới các endpoint bên ngoài
* Triển khai (deploy) và migration lên production
* Xóa hàng loạt trên cloud storage
* Cấp quyền IAM hoặc quyền repo
* Sửa đổi hạ tầng dùng chung
* Phá hủy không thể khôi phục các file đã tồn tại trước khi phiên bắt đầu
* Force push, hoặc push trực tiếp lên `main`
* {/* min-version: 2.1.182 */}`git reset --hard`, `git checkout -- .`, `git restore .`, `git clean -fd`, `git stash drop`, hoặc `git stash clear`, những lệnh mà classifier cho rằng sẽ vứt bỏ các thay đổi chưa commit
* `git commit --amend` khi commit tại HEAD không được tạo trong phiên này
* {/* min-version: 2.1.198 */}Từ v2.1.198, `git commit --amend` khi commit tại HEAD đã được push. Việc chỉ đổi lại thông điệp (reword) thì không bị chặn: `--amend -m` mà không có gì mới được staged, trên một commit mà Claude đã tạo trong phiên này
* `terraform destroy`, `pulumi destroy`, `cdk destroy`, hoặc `terragrunt destroy`, và việc áp dụng một kế hoạch phá hủy tài nguyên

Claude Code v2.1.195 trở lên chặn thêm nhiều danh mục theo mặc định. Một số danh mục phụ thuộc vào các mục [environment](/en/auto-mode-config#define-trusted-infrastructure), như các mục tiêu remote nhạy cảm và các phạm vi IaC được bảo vệ, mà bạn có thể thu hẹp thành các tên cụ thể.

* Ghi vào một secret manager, hoặc thay đổi bản ghi DNS hay chứng chỉ TLS
* Merge một pull request mà chưa có con người nào phê duyệt, phê duyệt pull request của chính Claude, hoặc vô hiệu hóa các kiểm tra CI
* Đăng một comment mà bản thân nó là một lệnh cho automation, chẳng hạn `atlantis apply` hoặc `/deploy` hay `/merge` của một bot
* Bật, tăng dần (ramp), hoặc xóa một feature flag production
* Áp dụng các thay đổi hạ tầng cho một phạm vi IaC được bảo vệ, hoặc rút cạn (drain) và loại bỏ các node của cluster
* Các thao tác ghi vào một cụm tính toán (compute cluster) dùng chung vượt ra ngoài tài nguyên mà bạn đã nêu tên, chẳng hạn một label selector hoặc `--all` vô tình bắt các job của người dùng khác
* Tạo các tài nguyên Kubernetes chạy trên mọi node hoặc chặn bắt lưu lượng cluster, chẳng hạn DaemonSet và admission webhook
* Shell tương tác hoặc port-forward vào một mục tiêu remote nhạy cảm
* Mở một tunnel hoặc reverse shell khiến một dịch vụ cục bộ có thể truy cập từ internet công cộng
* In một credential (thông tin xác thực) hoặc token còn hiệu lực vào transcript hoặc một file
* Truy cập một vị trí được liệt kê là vị trí dữ liệu nhạy cảm trong [environment](/en/auto-mode-config#define-trusted-infrastructure) của bạn, hoặc sao chép dữ liệu ra khỏi đó. {/* min-version: 2.1.198 */}Kể từ v2.1.198 điều này cũng chặn việc gửi dữ liệu từ đó tới một đối tượng mà mục đó loại trừ
* Định tuyến việc cài đặt package vòng qua registry package nội bộ của bạn tới một registry công cộng. {/* min-version: 2.1.198 */}Kể từ v2.1.198, điều này cũng áp dụng khi bạn đã nói với Claude rằng tồn tại một registry hoặc mirror nội bộ trong cuộc trò chuyện, chứ không chỉ khi nó được liệt kê trong environment của bạn
* Chạy một lệnh với flag làm vô hiệu một cơ chế bảo vệ an toàn, như `--insecure`
* Khởi chạy một vòng lặp agent tự chủ chạy mà không có sự phê duyệt của con người hoặc một sandbox, chẳng hạn một vòng được khởi động với `--dangerously-skip-permissions` hoặc `--no-sandbox`. {/* min-version: 2.1.198 */}Kể từ v2.1.198 điều này cũng bao gồm việc chạy một agent bên thứ ba hoặc một eval harness với việc cô lập và phê duyệt theo từng hành động bị tắt, chẳng hạn một runner được khởi động với `--yes-always`
* Các hành động trình duyệt của [Claude in Chrome](/en/chrome) có thể gửi nội dung trang, cookie, hoặc credential ra ngoài origin (off-origin)

Claude Code v2.1.198 trở lên cũng chặn những mục này theo mặc định:

* Xóa các file trong `/tmp`, `$TMPDIR`, hoặc một thư mục scratch hay cache dùng chung khác bằng wildcard, glob, hoặc bộ lọc theo tuổi (age filter) thay vì bằng một đường dẫn cụ thể được nêu tên
* Đưa các chi tiết nhạy cảm vào nội dung được gửi, tải lên, xuất bản, hoặc ghi cho người khác hay hệ thống dùng chung, khi chính thông điệp của bạn không cho phép các chi tiết đó tới người nhận đó. {/* min-version: 2.1.200 */}Nội dung PR và issue, thông điệp commit, và comment được tính là loại nội dung gửi ra ngoài này khi repository nằm ngoài ranh giới tin cậy hoặc là công cộng, bao gồm cả các repository công cộng của chính tổ chức bạn; các đường dẫn file nội bộ, tên mã (code name), dữ liệu phản hồi API còn hiệu lực như email hoặc định danh tài khoản, và các định danh hạ tầng được tính là chi tiết nhạy cảm. Phạm vi PR, issue, và thông điệp commit yêu cầu Claude Code v2.1.200 trở lên
* Gửi các phím gõ tới chính pane tmux của Claude Code để điều khiển giao diện của chính nó, điều mà classifier coi là Claude thay đổi quyền hoặc sự giám sát của chính nó

Claude Code v2.1.200 trở lên cũng chặn những mục này theo mặc định:

* Comment lại (comment out), xóa, hoặc ép qua (force-pass) một test hay assertion bảo vệ hành vi bảo mật, chẳng hạn xác thực, kiểm soát truy cập, kiểm tra đầu vào (input validation), hoặc sandboxing
* Xóa hoặc tháo dỡ một tài nguyên có trạng thái (stateful) mà Claude không tạo trong phiên, khi không có quy tắc xóa cụ thể hơn nào áp dụng và bạn không nêu tên tài nguyên đó
* Trỏ lại một base URL của API, endpoint proxy, bộ nhận webhook, hoặc registry mirror tới một host bên thứ ba không phù hợp với tác vụ, bao gồm cả trong các file ví dụ như `.env.example`
* Thay đổi nơi các push đi tới bằng `git remote set-url` hoặc `git remote add`, trừ khi bạn nêu tên remote mới
* Push các secret tới một repository được biết là công cộng, hoặc push các tài liệu nhạy cảm/bảo mật khác tới đó mà không thuộc về công việc của chính repository đó. Khi mức hiển thị (visibility) của một repository chưa được xác lập, classifier không chặn chỉ dựa trên điều đó; nó đánh giá nội dung theo các quy tắc khác thay vào đó
* Mở một pull request nhằm vào một repository hoặc tổ chức khác, fork bằng `gh repo fork`, hoặc push tới một repository bên thứ ba, trừ khi bạn nêu tên mục tiêu bên ngoài đó

**Được phép theo mặc định**:

* Các thao tác file cục bộ trong thư mục làm việc của bạn
* Cài đặt các phụ thuộc (dependency) được khai báo trong các lock file hoặc manifest của bạn
* Đọc `.env` và gửi credential tới API tương ứng của chúng
* Các yêu cầu HTTP chỉ đọc (read-only)
* Push lên nhánh bạn đã bắt đầu hoặc một nhánh do Claude tạo

Claude Code v2.1.195 trở lên cũng cho phép những mục này theo mặc định:

* Xóa chính xác các job mà Claude đã tạo trước đó trong cùng phiên
* Đọc, xem xét, hoặc viết mã, cấu hình, và mô hình mối đe dọa (threat model) liên quan đến bảo mật như một phần của tác vụ của bạn
* Các thông điệp giữa các agent làm việc cùng nhau trong cùng một phiên đa agent (multi-agent)
* Gửi dữ liệu tới các domain, bucket, và dịch vụ tin cậy mà bạn liệt kê trong [`environment`](/en/auto-mode-config#define-trusted-infrastructure). Điều này chỉ bao gồm luồng dữ liệu, không bao gồm các thao tác phá hủy hoặc thao tác credential trên cùng hạ tầng đó
* Điều hướng của [Claude in Chrome](/en/chrome) tới một domain nội bộ tin cậy, localhost, hoặc một URL bạn đã nêu tên

Các yêu cầu truy cập mạng của sandbox được định tuyến qua classifier chứ không được cho phép theo mặc định. {/* min-version: 2.1.198 */}Kể từ v2.1.198, classifier tái sử dụng phán quyết của nó cho một host và port của mạng thay vì chạy lại trên mỗi lần kết nối:

* Một quyết định allow được tái sử dụng cho đến khi có nội dung mới đi vào cuộc trò chuyện, tại thời điểm đó host này được kiểm tra lại
* Trong CLI tương tác, một quyết định deny bị bỏ đi khi lượt (turn) kết thúc
* Trong [chế độ không tương tác](/en/headless) và các phiên Agent SDK không có ranh giới lượt, nên một quyết định deny được tái sử dụng cho phần còn lại của lần chạy
* Thay đổi chế độ quyền hoặc quy tắc của bạn sẽ bỏ đi mọi phán quyết đã được cache

Chạy `claude auto-mode defaults` để xem danh sách quy tắc đầy đủ. Nếu các hành động thường lệ bị chặn, quản trị viên có thể thêm các repo, bucket, và dịch vụ tin cậy qua cài đặt `autoMode.environment`: xem [Cấu hình auto mode](/en/auto-mode-config).

### Các ranh giới bạn nêu trong cuộc trò chuyện

Classifier coi các ranh giới bạn nêu trong cuộc trò chuyện là một tín hiệu chặn. Nếu bạn nói với Claude "đừng push" hoặc "chờ đến khi tôi xem xét trước khi deploy", classifier sẽ chặn các hành động khớp ngay cả khi các quy tắc mặc định sẽ cho phép chúng. Một ranh giới vẫn có hiệu lực cho đến khi bạn dỡ bỏ nó trong một thông điệp sau. Việc chính Claude đánh giá rằng một điều kiện đã được đáp ứng không dỡ bỏ nó.

Các ranh giới không được lưu dưới dạng quy tắc. Classifier đọc lại chúng từ transcript ở mỗi lần kiểm tra, nên một ranh giới có thể bị mất nếu [context compaction (nén ngữ cảnh)](/en/costs#reduce-token-usage) loại bỏ thông điệp đã nêu ra nó. Để có một sự đảm bảo chắc chắn, hãy thêm một [deny rule](/en/permissions#permission-rule-syntax) thay vào đó.

### Khi auto mode chuyển về dự phòng (fallback)

Mỗi hành động bị từ chối sẽ hiển thị một thông báo và xuất hiện trong `/permissions` dưới tab Recently denied, nơi bạn có thể nhấn `r` để thử lại nó với một phê duyệt thủ công.

Nếu classifier chặn một hành động 3 lần liên tiếp hoặc 20 lần tổng cộng, auto mode tạm dừng và Claude Code quay lại hỏi. Việc phê duyệt hành động được hỏi sẽ khôi phục auto mode. Các ngưỡng này không thể cấu hình. Bất kỳ hành động được cho phép nào cũng đặt lại bộ đếm liên tiếp, trong khi bộ đếm tổng cộng vẫn tồn tại cho phiên và chỉ đặt lại khi chính giới hạn của nó kích hoạt một lần fallback.

Trong [chế độ không tương tác](/en/headless) với flag `-p`, việc bị chặn nhiều lần sẽ hủy phiên vì không có người dùng để hỏi.

Việc bị chặn nhiều lần thường có nghĩa là classifier thiếu context về hạ tầng của bạn. Dùng `/feedback` để báo cáo các cảnh báo sai (false positive), hoặc nhờ quản trị viên [cấu hình hạ tầng tin cậy](/en/auto-mode-config).

<AccordionGroup>
  <Accordion title="Classifier đánh giá các hành động như thế nào">
    Mỗi hành động đi qua một thứ tự quyết định cố định. Bước khớp đầu tiên thắng:

    1. Các hành động khớp với [quy tắc allow hoặc deny](/en/permissions#manage-permissions) của bạn được giải quyết ngay lập tức, ngoại trừ các thao tác ghi vào [protected paths](#protected-paths), vốn được định tuyến tới classifier ngay cả khi có một quy tắc allow khớp
    2. Các hành động chỉ đọc và các chỉnh sửa file trong thư mục làm việc của bạn được tự động phê duyệt, ngoại trừ các thao tác ghi vào [protected paths](#protected-paths)
    3. Mọi thứ khác đi tới classifier. {/* min-version: 2.1.199 */}Kể từ v2.1.199, một tool MCP được đánh dấu bằng [`_meta["anthropic/requiresUserInteraction"]`](/en/mcp#require-approval-for-a-specific-tool) sẽ bỏ qua classifier và hỏi bạn trực tiếp, nên một bước đồng ý (consent) không bao giờ được tự động phê duyệt thay mặt tác giả tool
    4. Nếu classifier chặn, Claude nhận được lý do và thử một phương án khác

    Khi vào auto mode, các quy tắc allow rộng cấp quyền thực thi mã tùy ý sẽ bị loại bỏ:

    * `Bash(*)` hoặc `PowerShell(*)` tổng quát
    * Các trình thông dịch có wildcard như `Bash(python*)`
    * Các lệnh chạy của trình quản lý package
    * Các quy tắc allow `Agent`

    Các quy tắc hẹp như `Bash(npm test)` được giữ lại. Các quy tắc bị loại bỏ sẽ được khôi phục khi bạn rời auto mode.

    Classifier nhìn thấy các thông điệp của người dùng, các lời gọi tool, và nội dung CLAUDE.md của bạn. Các kết quả tool bị lược bỏ, nên nội dung thù địch trong một file hoặc trang web không thể thao túng nó trực tiếp. Một probe riêng phía máy chủ quét các kết quả tool đến và đánh dấu nội dung khả nghi trước khi Claude đọc. Để biết thêm về cách các lớp này hoạt động cùng nhau, xem [thông báo về auto mode](https://claude.com/blog/auto-mode) và [bài phân tích kỹ thuật chuyên sâu](https://www.anthropic.com/engineering/claude-code-auto-mode).
  </Accordion>

  <Accordion title="Auto mode xử lý subagent như thế nào">
    Classifier kiểm tra công việc của [subagent](/en/sub-agents) tại ba điểm:

    1. Trước khi một subagent khởi động, mô tả tác vụ được ủy thác sẽ được đánh giá, nên một tác vụ trông nguy hiểm sẽ bị chặn ngay tại thời điểm spawn (khởi tạo).
    2. Trong khi subagent chạy, mỗi hành động của nó đi qua classifier với cùng các quy tắc như phiên cha, và bất kỳ `permissionMode` nào trong frontmatter của subagent đều bị bỏ qua.
    3. Khi subagent kết thúc, classifier xem xét toàn bộ lịch sử hành động của nó; nếu lần kiểm tra trả về đó đánh dấu một mối lo ngại, một cảnh báo bảo mật sẽ được thêm vào đầu kết quả của subagent.

    Bước 1 yêu cầu Claude Code v2.1.178 trở lên. Các phiên bản cũ hơn áp dụng classifier ở bước 2 và 3, nhưng không đánh giá mô tả tác vụ trước khi subagent khởi động.
  </Accordion>

  <Accordion title="Chi phí và độ trễ">
    Classifier chạy trên một model được cấu hình phía máy chủ, độc lập với lựa chọn `/model` của bạn, nên việc chuyển model không thay đổi tính khả dụng của classifier. Các lời gọi classifier được tính vào mức sử dụng token của bạn. Mỗi lần kiểm tra gửi một phần của transcript cộng với hành động đang chờ, thêm một vòng round-trip trước khi thực thi. Các thao tác đọc và các chỉnh sửa trong thư mục làm việc nằm ngoài protected paths sẽ bỏ qua classifier, nên chi phí phụ trội chủ yếu đến từ các lệnh shell và các thao tác mạng. {/* min-version: 2.1.198 */}Kể từ v2.1.198, một phán quyết mạng của sandbox cho một host và port được tái sử dụng thay vì phân loại lại trên mỗi lần kết nối, nên các lần kết nối lặp lại tới cùng một host không mỗi lần đều thêm một lần kiểm tra. [Classifier chặn gì theo mặc định](#what-the-classifier-blocks-by-default) mô tả một quyết định allow và một quyết định deny kéo dài bao lâu.
  </Accordion>
</AccordionGroup>

## Chỉ cho phép các tool đã được phê duyệt trước với chế độ dontAsk

Chế độ `dontAsk` tự động từ chối mọi lời gọi tool mà lẽ ra sẽ hỏi. Thanh trạng thái hiển thị `⏵⏵ don't ask on` khi chế độ này đang hoạt động. Chỉ các hành động khớp với các quy tắc `permissions.allow` của bạn và các [lệnh Bash chỉ đọc](/en/permissions#read-only-commands) mới có thể thực thi; các [`ask` rule](/en/permissions#manage-permissions) tường minh bị từ chối thay vì hỏi. {/* min-version: 2.1.199 */}Kể từ v2.1.199, một tool MCP được đánh dấu bằng [`_meta["anthropic/requiresUserInteraction"]`](/en/mcp#require-approval-for-a-specific-tool) cũng bị từ chối trong chế độ này ngay cả khi có một quy tắc allow khớp nó, bởi vì thẻ phê duyệt của nó cần một câu trả lời mà chế độ này không bao giờ thu thập. Điều này khiến chế độ hoàn toàn không tương tác cho các pipeline CI hoặc các môi trường bị hạn chế, nơi bạn định nghĩa trước chính xác những gì Claude được phép làm. Các phiên cloud trên [Claude Code trên web](/en/claude-code-on-the-web) bỏ qua `defaultMode: "dontAsk"`; xem [bypassPermissions](#skip-all-checks-with-bypasspermissions-mode) để biết chi tiết.

Thiết lập nó lúc khởi động với flag:

```bash theme={null}
claude --permission-mode dontAsk
```

## Bỏ qua mọi kiểm tra với chế độ bypassPermissions

Chế độ `bypassPermissions` vô hiệu hóa các permission prompt và các kiểm tra an toàn để các lời gọi tool thực thi ngay lập tức. Kể từ v2.1.126, điều này bao gồm cả các thao tác ghi vào [protected paths](#protected-paths), vốn ở các phiên bản trước vẫn hỏi. Các [ask rule](/en/permissions#manage-permissions) tường minh vẫn buộc phải hỏi trong chế độ này, và các thao tác xóa nhắm vào gốc hệ thống file hoặc thư mục home, chẳng hạn `rm -rf /` và `rm -rf ~`, vẫn hỏi như một cầu dao ngắt (circuit breaker) chống lại lỗi của model. {/* min-version: 2.1.199 */}Kể từ v2.1.199, các tool MCP được đánh dấu bằng [`_meta["anthropic/requiresUserInteraction"]`](/en/mcp#require-approval-for-a-specific-tool) cũng vẫn hỏi. Chỉ dùng chế độ này trong các môi trường cô lập như container, VM, hoặc dev container không có truy cập internet, nơi Claude Code không thể làm hỏng hệ thống host của bạn.

Bạn không thể vào `bypassPermissions` từ một phiên đã khởi động mà không có một trong các flag cho phép; hãy khởi động lại với một flag để bật nó:

```bash theme={null}
claude --permission-mode bypassPermissions
```

Flag `--dangerously-skip-permissions` là tương đương.

Trên Linux và macOS, Claude Code từ chối khởi động ở chế độ này khi đang chạy dưới quyền root hoặc dưới `sudo`:

```text theme={null}
--dangerously-skip-permissions cannot be used with root/sudo privileges for security reasons
```

Việc kiểm tra được bỏ qua tự động bên trong một sandbox được nhận diện. Để chạy tự chủ trong một container, hãy dùng cấu hình [dev container](/en/devcontainer), vốn chạy Claude Code dưới một người dùng không phải root.

[Claude Code trên web](/en/claude-code-on-the-web) không tôn trọng `defaultMode: "bypassPermissions"` hoặc `"dontAsk"` từ các file settings của bạn, nên các settings được checked-in của một repository không thể khởi động một phiên cloud ở chế độ bypass-permissions. Cài đặt bị bỏ qua trong im lặng và phiên khởi động ở chế độ hiển thị trong menu thả xuống chọn chế độ. Xem [Chuyển đổi chế độ quyền](#switch-permission-modes) để biết các phiên cloud cung cấp những chế độ nào.

<Warning>
  `bypassPermissions` không cung cấp bảo vệ nào chống lại prompt injection hoặc các hành động ngoài ý muốn. Để có các kiểm tra an toàn ở nền với ít permission prompt hơn nhiều, thay vào đó hãy dùng [auto mode](#eliminate-prompts-with-auto-mode). Quản trị viên có thể chặn chế độ này bằng cách đặt `permissions.disableBypassPermissionsMode` thành `"disable"` trong [managed settings](/en/permissions#managed-settings).
</Warning>

## Protected paths (đường dẫn được bảo vệ)

Các thao tác ghi vào một tập nhỏ các đường dẫn không bao giờ được tự động phê duyệt, ở mọi chế độ ngoại trừ `bypassPermissions`. Điều này ngăn việc làm hỏng do vô ý trạng thái repository và cấu hình của chính Claude.

| Chế độ                           | Ghi vào protected-path   |
| :------------------------------- | :----------------------- |
| `default`, `acceptEdits`, `plan` | Hỏi                      |
| `auto`                           | Định tuyến tới classifier|
| `dontAsk`                        | Từ chối                  |
| `bypassPermissions`              | Cho phép                 |

Các quy tắc [`permissions.allow`](/en/permissions#manage-permissions) trong các file settings không phê duyệt trước các thao tác ghi vào protected-path. Việc kiểm tra an toàn chạy trước khi Claude Code đánh giá các quy tắc allow từ settings, nên một mục như `Edit(.claude/**)` trong `~/.claude/settings.json` hoặc `.claude/settings.json` không làm thay đổi kết quả theo từng chế độ trong bảng trên. Ở các chế độ có hỏi, lời nhắc cho một thao tác ghi vào `.claude/` cung cấp tùy chọn **Yes, and allow Claude to edit its own settings for this session**, tùy chọn này phê duyệt các thao tác ghi vào `.claude/` sau đó trong phiên đó mà không hỏi lại.

Các thư mục được bảo vệ:

* `.git`
* `.config/git`
* `.vscode`
* `.idea`
* `.husky`
* `.cargo`
* `.devcontainer`
* `.yarn`
* `.mvn`
* `.claude`, ngoại trừ `.claude/worktrees` nơi Claude lưu các git worktree của chính nó

Các file được bảo vệ:

* `.gitconfig`, `.gitmodules`
* `.bashrc`, `.bash_profile`, `.bash_login`, `.bash_aliases`, `.bash_logout`, `.zshrc`, `.zprofile`, `.zshenv`, `.zlogin`, `.zlogout`, `.profile`, `.envrc`
* `.npmrc`, `.yarnrc`, `.yarnrc.yml`, `.pnp.cjs`, `.pnp.loader.mjs`, `.pnpmfile.cjs`, `bunfig.toml`, `.bunfig.toml`
* `.bazelrc`, `.bazelversion`, `.bazeliskrc`
* `.pre-commit-config.yaml`, `lefthook.yml`, `lefthook.yaml`, `.lefthook.yml`, `.lefthook.yaml`
* `gradle-wrapper.properties`, `maven-wrapper.properties`
* `.devcontainer.json`
* `.ripgreprc`, `pyrightconfig.json`
* `.mcp.json`, `.claude.json`

## Xem thêm

* [Permissions](/en/permissions): các quy tắc allow, ask, và deny; các chính sách được quản lý (managed policies)
* [Cấu hình auto mode](/en/auto-mode-config): cho classifier biết hạ tầng nào tổ chức của bạn tin tưởng
* [Hooks](/en/hooks): logic quyền tùy chỉnh qua các hook `PreToolUse` và `PermissionRequest`
* [Ultraplan](/en/ultraplan): chạy plan mode trong một phiên Claude Code trên web với việc xem xét trên trình duyệt
* [Security](/en/security): các biện pháp bảo vệ và thực hành tốt nhất
* [Sandboxing](/en/sandboxing): cô lập hệ thống file và mạng cho các lệnh Bash
* [Chế độ không tương tác](/en/headless): chạy Claude Code với flag `-p`
