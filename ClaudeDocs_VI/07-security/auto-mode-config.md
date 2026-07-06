> Nguồn: https://code.claude.com/docs/en/auto-mode-config.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Cấu hình chế độ tự động (auto mode)

> Cho bộ phân loại (classifier) của auto mode biết những repo, bucket và domain nào mà tổ chức của bạn tin cậy. Thiết lập ngữ cảnh môi trường, ghi đè các quy tắc chặn (block) và cho phép (allow) mặc định, đồng thời kiểm tra cấu hình đang có hiệu lực bằng các lệnh con auto-mode của CLI.

[Auto mode](/en/permission-modes#eliminate-prompts-with-auto-mode) cho phép Claude Code chạy mà không cần các prompt xin quyền thông thường, bằng cách định tuyến các lệnh gọi tool qua một bộ phân loại chặn mọi hành động không thể hoàn tác, mang tính phá hủy, hoặc nhắm ra ngoài môi trường của bạn. Các quy tắc từ chối (deny) và hỏi rõ ràng (explicit ask) được đánh giá trước bộ phân loại và vẫn chặn hoặc hỏi. Dùng khối cấu hình `autoMode` để cho bộ phân loại đó biết những repo, bucket và domain nào tổ chức của bạn tin cậy, để nó ngừng chặn các thao tác nội bộ thông thường.

<Note>
  Auto mode có sẵn cho tất cả người dùng trên Anthropic API. Trên Amazon Bedrock, Agent Platform của Google Cloud, Microsoft Foundry, và các phiên đã đăng nhập qua [Claude apps gateway](/en/claude-apps-gateway), trước tiên bạn phải [thiết lập `CLAUDE_CODE_ENABLE_AUTO_MODE`](/en/permission-modes#enable-auto-mode-on-bedrock-agent-platform-or-foundry). Nếu Claude Code báo rằng auto mode không khả dụng cho tài khoản của bạn, hãy kiểm tra [đầy đủ các yêu cầu](/en/permission-modes#eliminate-prompts-with-auto-mode), bao gồm cả các model được hỗ trợ và việc kích hoạt ở cấp Owner trên gói Team và Enterprise.
</Note>

Theo mặc định, bộ phân loại chỉ tin cậy thư mục làm việc (working directory) và các remote đã cấu hình của repo hiện tại. Các hành động như push lên tổ chức quản lý mã nguồn (source-control) của công ty bạn hoặc ghi vào một bucket đám mây dùng chung của nhóm sẽ bị chặn cho đến khi bạn thêm chúng vào `autoMode.environment`.

Để biết cách bật auto mode và những gì nó chặn theo mặc định, xem [Chế độ quyền (Permission modes)](/en/permission-modes#eliminate-prompts-with-auto-mode). Trang này là tài liệu tham chiếu về cấu hình.

Trang này trình bày cách:

* [Chọn nơi đặt quy tắc](#where-the-classifier-reads-configuration) trên CLAUDE.md, cấu hình người dùng (user settings), và cấu hình được quản lý (managed settings)
* [Định nghĩa hạ tầng tin cậy](#define-trusted-infrastructure) bằng `autoMode.environment`
* [Ghi đè các quy tắc chặn và cho phép](#override-the-block-and-allow-rules) khi mặc định không phù hợp với pipeline của bạn
* [Định tuyến toàn bộ lệnh shell qua bộ phân loại](#route-all-shell-commands-through-the-classifier) bằng `autoMode.classifyAllShell`
* [Kiểm tra cấu hình đang có hiệu lực](#inspect-the-defaults-and-your-effective-config) bằng các lệnh con `claude auto-mode`
* [Xem lại các lần bị từ chối](#review-denials) để biết cần thêm gì tiếp theo

## Nơi bộ phân loại đọc cấu hình

Bộ phân loại đọc chính nội dung [CLAUDE.md](/en/memory) mà bản thân Claude nạp, nên một chỉ dẫn như "never force push" trong CLAUDE.md của dự án sẽ định hướng cho cả Claude lẫn bộ phân loại cùng lúc. Hãy bắt đầu từ đó cho các quy ước dự án và các quy tắc hành vi.

Đối với các quy tắc áp dụng xuyên suốt nhiều dự án, chẳng hạn như hạ tầng tin cậy hoặc các quy tắc deny cho toàn tổ chức, hãy dùng khối cấu hình `autoMode`. Bộ phân loại đọc `autoMode` từ các phạm vi (scope) sau:

| Phạm vi                          | Tệp                                             | Dùng cho                                                  |
| :------------------------------- | :---------------------------------------------- | :------------------------------------------------------- |
| Một lập trình viên               | `~/.claude/settings.json`                       | Hạ tầng tin cậy cá nhân                                   |
| Một dự án, một lập trình viên    | `.claude/settings.local.json`                   | Bucket hoặc dịch vụ tin cậy theo từng dự án              |
| Toàn tổ chức                     | [Managed settings](/en/server-managed-settings) | Hạ tầng tin cậy phân phối tới mọi lập trình viên         |
| Cờ `--settings` hoặc Agent SDK   | JSON nội tuyến (inline)                          | Ghi đè theo từng lần gọi cho các tác vụ tự động hóa      |

Bộ phân loại không đọc `autoMode` từ cấu hình dự án dùng chung trong `.claude/settings.json`, nên một repo được commit vào không thể tự chèn các quy tắc allow của riêng nó.

Các mục từ mỗi phạm vi được gộp lại với nhau. Một lập trình viên có thể mở rộng `environment`, `allow`, `soft_deny`, và `hard_deny` bằng các mục cá nhân nhưng không thể gỡ bỏ các mục do managed settings cung cấp. Vì các quy tắc allow đóng vai trò như ngoại lệ đối với các quy tắc soft block bên trong bộ phân loại, nên một mục `allow` do lập trình viên thêm vào có thể ghi đè một mục `soft_deny` của tổ chức: sự kết hợp này mang tính bổ sung (additive), không phải là ranh giới chính sách cứng.

<Note>
  Bộ phân loại là cổng kiểm soát thứ hai, chạy sau [hệ thống quyền (permissions system)](/en/permissions). Đối với các hành động không bao giờ được phép chạy bất kể ý định của người dùng hay cấu hình bộ phân loại, hãy dùng `permissions.deny` trong managed settings, vốn chặn hành động trước khi bộ phân loại được tham vấn và không thể bị ghi đè.
</Note>

## Định nghĩa hạ tầng tin cậy

Với hầu hết các tổ chức, `autoMode.environment` là trường duy nhất bạn cần thiết lập. Nó cho bộ phân loại biết những repo, bucket và domain nào được tin cậy: bộ phân loại dùng nó để quyết định "bên ngoài" nghĩa là gì, nên bất kỳ đích đến nào không được liệt kê đều là một mục tiêu rò rỉ dữ liệu (exfiltration) tiềm tàng.

Kể từ Claude Code v2.1.198, `claude auto-mode defaults` in ra ba loại mục environment. Các phiên bản trước v2.1.195 chỉ in ra năm slot tin cậy đầu tiên.

* **Context slots** (khe ngữ cảnh): mô tả tổ chức, tech stack và tư thế bảo mật (security posture) của bạn để bộ phân loại đọc các quy tắc khác trong ngữ cảnh của bạn. Khác với hai loại còn lại, context slots không có quy tắc riêng nhắm vào chúng. Mỗi mục mặc định là `None configured` hoặc giả định thận trọng được nêu bên cạnh:
  * **Organization** (Tổ chức)
  * **Primary use of Claude Code** (Mục đích sử dụng chính của Claude Code): mặc định là phát triển phần mềm
  * **Cloud provider(s)** (Nhà cung cấp đám mây)
  * **Repository visibility** (Mức độ hiển thị của repository): một repository được mặc định coi là riêng tư (private) trừ khi host và tên remote của nó cho thấy điều ngược lại, {/* min-version: 2.1.200 */}hoặc một điều gì đó trước đó trong phiên đã cho thấy nó là công khai (public), chẳng hạn như một kết quả `gh repo view` trong bản ghi hội thoại (transcript). Việc kiểm tra bằng chứng từ transcript yêu cầu Claude Code v2.1.200 trở lên
  * **Internal sharing / snippet hosting** (Chia sẻ nội bộ / lưu trữ đoạn mã): các dịch vụ paste và gist công khai được coi là nằm ngoài ranh giới tin cậy cho đến khi bạn nêu tên một dịch vụ
  * **Org-specific CLIs** (Các CLI riêng của tổ chức)
  * **Secrets management** (Quản lý bí mật)
  * **Default / protected branches** (Nhánh mặc định / được bảo vệ): `main` và `master` được coi là được bảo vệ cho đến khi bạn nêu tên các nhánh khác
  * **CI/CD deploy targets** (Đích triển khai CI/CD)
  * **Network posture** (Tư thế mạng)
  * **Protected deployment namespaces / environments** (Namespace / môi trường triển khai được bảo vệ): quay về dùng heuristic Sensitive remote targets cho đến khi bạn nêu tên chúng
  * **Data retention / declassification** (Lưu giữ dữ liệu / giải mật)
* **Trust slots** (khe tin cậy): nêu tên những gì bộ phân loại coi là nằm trong ranh giới của bạn. Các slot gồm Trusted repo, Source control, Trusted internal domains, Trusted cloud buckets, Key internal services, và Internal package registry. Mục repo và source-control mặc định là repo đang làm việc và các remote đã cấu hình của nó. Mọi trust slot khác đều mặc định là `None configured`, nên không có gì khác được tin cậy cho đến khi bạn thêm nó vào.
* **Sensitivity slots** (khe nhạy cảm): nêu tên những gì mà các quy tắc bảo vệ coi là rủi ro cao. Các slot gồm Sensitive data locations & audiences, Sensitive remote targets, và Protected IaC scopes. Mỗi slot mặc định dùng một heuristic rộng, chẳng hạn coi bất kỳ host hoặc namespace nào có tên chứa `prod` hoặc `production` là một sensitive remote target, nên các quy tắc bảo vệ đã hoạt động trước cả khi bạn cấu hình gì. Việc nêu tên các đích cụ thể trong một sensitivity slot khiến các quy tắc đó áp dụng cho các đích đã nêu tên thay vì heuristic.

Để thêm các mục của riêng bạn cùng với các mục mặc định, hãy đưa chuỗi ký tự nguyên văn `"$defaults"` vào trong mảng. Các mục mặc định được chèn vào đúng vị trí đó, nên các mục tùy chỉnh của bạn có thể đặt trước hoặc sau chúng.

Ví dụ sau giữ lại các mục mặc định và thêm vào các repo, bucket, domain và dịch vụ của một tổ chức.

```json theme={null}
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it",
      "Trusted cloud buckets: s3://acme-build-artifacts, gs://acme-ml-datasets",
      "Trusted internal domains: *.corp.example.com, api.internal.example.com",
      "Key internal services: Jenkins at ci.example.com, Artifactory at artifacts.example.com"
    ]
  }
}
```

Các mục là văn xuôi (prose), không phải regex hay mẫu tool (tool pattern). Bộ phân loại đọc chúng như các quy tắc bằng ngôn ngữ tự nhiên. Hãy viết chúng theo cách bạn mô tả hạ tầng của mình cho một kỹ sư mới. Một phần environment đầy đủ sẽ bao gồm:

* **Organization**: tên công ty của bạn và Claude Code được dùng chủ yếu để làm gì, như phát triển phần mềm, tự động hóa hạ tầng, hay data engineering
* **Source control**: mọi tổ chức GitHub, GitLab, hoặc Bitbucket mà lập trình viên của bạn push lên
* **Cloud providers and trusted buckets**: tên bucket hoặc tiền tố (prefix) mà Claude có thể đọc và ghi vào
* **Trusted internal domains**: các hostname cho API, dashboard, và dịch vụ bên trong mạng của bạn, như `*.internal.example.com`
* **Key internal services**: CI, registry lưu trữ artifact, các chỉ mục package nội bộ, công cụ xử lý sự cố (incident tooling)
* **Internal package registry**: registry npm, PyPI, hoặc loại khác dạng riêng tư mà việc cài đặt nên định tuyến qua, để các lần cài đặt bỏ qua nó để dùng registry công khai bị chặn
* **Sensitive data locations & audiences**: các bucket, cơ sở dữ liệu, hoặc đường dẫn chứa dữ liệu cá nhân, dữ liệu kinh doanh mật, thông tin xác thực (credentials), dữ liệu chịu quản lý (regulated data), hoặc tài liệu nhạy cảm tương tự, và các đối tượng mà dữ liệu ở mỗi vị trí có thể được chia sẻ với, để bộ phân loại bảo vệ những vị trí đó thay vì đoán từ nội dung. {/* min-version: 2.1.195 */}{/* max-version: 2.1.197 */}Claude Code v2.1.195 đến v2.1.197 đặt tên mục này là PII / regulated-data locations và chỉ bao gồm các vị trí chứa dữ liệu cá nhân hoặc dữ liệu chịu quản lý, không có chiều đối tượng (audience)
* **Sensitive remote targets**: các namespace, host, hoặc container được coi là production, để các shell từ xa (remote shell) và port-forward vào chúng cần bạn phê duyệt rõ ràng
* **Protected IaC scopes**: các tài nguyên hạ tầng mà việc apply hoặc destroy chúng luôn phải yêu cầu bạn nêu rõ tên thay đổi
* **Additional context**: các ràng buộc của ngành chịu quản lý, hạ tầng đa người thuê (multi-tenant), hoặc các yêu cầu tuân thủ (compliance) ảnh hưởng đến những gì bộ phân loại nên coi là rủi ro

Các mục Internal package registry, Sensitive data locations & audiences, Sensitive remote targets, và Protected IaC scopes yêu cầu Claude Code v2.1.195 trở lên. Các phiên bản cũ hơn vẫn đọc chúng như ngữ cảnh thuần túy nhưng không có các quy tắc tích hợp sẵn nhắm vào chúng.

Một mẫu khởi đầu hữu ích: điền vào các trường trong dấu ngoặc nhọn và xóa các dòng không áp dụng.

```json theme={null}
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Organization: {COMPANY_NAME}. Primary use: {PRIMARY_USE_CASE, e.g. software development, infrastructure automation}",
      "Source control: {SOURCE_CONTROL, e.g. GitHub org github.example.com/acme-corp}",
      "Cloud provider(s): {CLOUD_PROVIDERS, e.g. AWS, GCP, Azure}",
      "Trusted cloud buckets: {TRUSTED_BUCKETS, e.g. s3://acme-builds, gs://acme-datasets}",
      "Trusted internal domains: {TRUSTED_DOMAINS, e.g. *.internal.example.com, api.example.com}",
      "Key internal services: {SERVICES, e.g. Jenkins at ci.example.com, Artifactory at artifacts.example.com}",
      "Additional context: {EXTRA, e.g. regulated industry, multi-tenant infrastructure, compliance requirements}"
    ]
  }
}
```

Bạn cung cấp ngữ cảnh càng cụ thể, bộ phân loại càng phân biệt tốt hơn giữa các thao tác nội bộ thông thường với các nỗ lực rò rỉ dữ liệu.

Bạn không cần điền hết mọi thứ ngay lập tức. Một lộ trình triển khai hợp lý: bắt đầu với các mặc định và thêm tổ chức source control cùng các dịch vụ nội bộ quan trọng, việc này giải quyết những trường hợp báo động giả (false positive) phổ biến nhất như push lên chính các repo của bạn. Tiếp theo thêm các trusted domain và cloud bucket. Điền phần còn lại khi các lần bị chặn phát sinh.

## Ghi đè các quy tắc chặn và cho phép

Ba trường bổ sung cho phép bạn thay thế các danh sách quy tắc tích hợp sẵn của bộ phân loại:

* `autoMode.hard_deny`: các ranh giới bảo mật vô điều kiện
* `autoMode.soft_deny`: các hành động phá hủy mà ý định người dùng có thể gỡ bỏ
* `autoMode.allow`: các ngoại lệ đối với các quy tắc soft block

Mỗi trường là một mảng các mô tả dạng văn xuôi, được đọc như các quy tắc ngôn ngữ tự nhiên. Đối với các hard block dựa trên mẫu tool (tool-pattern) chạy trước bộ phân loại, hãy dùng [`permissions.deny`](/en/permissions).

Bên trong bộ phân loại, thứ tự ưu tiên hoạt động theo bốn cấp:

* Các quy tắc `hard_deny` chặn vô điều kiện. Ý định người dùng và các ngoại lệ `allow` không áp dụng.
* Các quy tắc `soft_deny` chặn tiếp theo. Ý định người dùng và các ngoại lệ `allow` có thể ghi đè chúng.
* Các quy tắc `allow` sau đó ghi đè các quy tắc `soft_deny` khớp với nó, đóng vai trò ngoại lệ.
* Ý định người dùng rõ ràng ghi đè các soft block còn lại: nếu thông điệp của người dùng mô tả trực tiếp và cụ thể chính xác hành động mà Claude sắp thực hiện, bộ phân loại sẽ cho phép nó ngay cả khi có một quy tắc `soft_deny` khớp.

Các yêu cầu chung chung không được tính là ý định rõ ràng. Yêu cầu Claude "clean up the repo" không cho phép force-push, nhưng yêu cầu Claude "force-push this branch" thì có.

Để nới lỏng, hãy thêm vào `allow` khi bộ phân loại liên tục gắn cờ một mẫu thông thường mà các ngoại lệ mặc định không bao quát. Để siết chặt, hãy thêm vào `soft_deny` cho các rủi ro phá hủy đặc thù với môi trường của bạn mà mặc định bỏ sót, hoặc thêm vào `hard_deny` cho các ranh giới bảo mật không bao giờ được vượt qua.

Để giữ lại các quy tắc tích hợp sẵn trong khi thêm quy tắc của riêng bạn, hãy đưa chuỗi ký tự nguyên văn `"$defaults"` vào trong mảng. Các quy tắc mặc định được chèn vào đúng vị trí đó, nên các quy tắc tùy chỉnh của bạn có thể đặt trước hoặc sau chúng, và bạn tiếp tục nhận được các cập nhật khi danh sách tích hợp sẵn thay đổi qua các bản phát hành.

Ví dụ sau giữ các mặc định trong cả bốn danh sách và thêm các quy tắc riêng của tổ chức vào từng danh sách.

```json theme={null}
{
  "autoMode": {
    "environment": [
      "$defaults",
      "Source control: github.example.com/acme-corp and all repos under it"
    ],
    "allow": [
      "$defaults",
      "Deploying to the staging namespace is allowed: staging is isolated from production and resets nightly",
      "Writing to s3://acme-scratch/ is allowed: ephemeral bucket with a 7-day lifecycle policy"
    ],
    "soft_deny": [
      "$defaults",
      "Never run database migrations outside the migrations CLI, even against dev databases",
      "Never modify files under infra/terraform/prod/: production infrastructure changes go through the review workflow"
    ],
    "hard_deny": [
      "$defaults",
      "Never send repository contents to third-party code-review APIs"
    ]
  }
}
```

<Danger>
  Việc thiết lập bất kỳ trường nào trong số `environment`, `allow`, `soft_deny`, hoặc `hard_deny` mà không có `"$defaults"` sẽ thay thế toàn bộ danh sách mặc định của phần đó. Một mảng `soft_deny` không có `"$defaults"` sẽ loại bỏ mọi quy tắc soft block tích hợp sẵn, bao gồm force push, `curl | bash`, và các lần deploy lên production. Một mảng `hard_deny` không có `"$defaults"` sẽ loại bỏ các quy tắc chống rò rỉ dữ liệu và chống bỏ qua auto-mode tích hợp sẵn.
</Danger>

Mỗi phần được đánh giá độc lập, nên việc chỉ thiết lập `environment` sẽ giữ nguyên các danh sách `allow`, `soft_deny`, và `hard_deny` mặc định.

Chỉ bỏ qua `"$defaults"` khi bạn có ý định nắm toàn quyền sở hữu danh sách đó. Để làm điều này một cách an toàn, hãy chạy `claude auto-mode defaults` để in ra các quy tắc tích hợp sẵn, sao chép chúng vào tệp cấu hình của bạn, rồi xem xét từng quy tắc so với pipeline và mức độ chấp nhận rủi ro của riêng bạn.

## Định tuyến toàn bộ lệnh shell qua bộ phân loại

Theo mặc định, các quy tắc allow hẹp cho Bash và PowerShell như `Bash(npm test)` được chuyển tiếp vào auto mode và được giải quyết trước khi bộ phân loại chạy. Auto mode chỉ đình chỉ các quy tắc rộng cấp quyền thực thi mã tùy ý, chẳng hạn `Bash(*)` hoặc các interpreter dùng ký tự đại diện (wildcard). Điều này có nghĩa là một quy tắc hẹp vẫn có thể để lọt một tham số phá hủy mà bộ phân loại không nhìn thấy, ví dụ một đường dẫn script hoặc cờ mà tiền tố của quy tắc không lường trước.

Đặt `autoMode.classifyAllShell` thành `true` để đình chỉ mọi quy tắc allow của Bash và PowerShell trong khi auto mode đang hoạt động, để bộ phân loại đánh giá mọi lệnh shell bất kể danh sách allow của bạn.

```json theme={null}
{
  "autoMode": {
    "classifyAllShell": true
  }
}
```

Điều này đánh đổi độ trễ (latency) lấy độ bao phủ: một lệnh mà đáng lẽ một quy tắc allow đã phê duyệt ngay lập tức thì giờ phải chờ quyết định của bộ phân loại, và mỗi lệnh shell được tính là một lần gọi bộ phân loại.

Thiết lập này chỉ áp dụng trong khi auto mode đang hoạt động, và các quy tắc allow của bạn hoạt động bình thường ở các chế độ quyền khác.

<Note>
  `autoMode.classifyAllShell` yêu cầu Claude Code v2.1.193 trở lên. Các phiên bản cũ hơn bỏ qua key này và tiếp tục chuyển tiếp các quy tắc allow shell hẹp vào auto mode.
</Note>

## Kiểm tra các mặc định và cấu hình đang có hiệu lực của bạn

Ba lệnh con của CLI giúp bạn kiểm tra và xác thực cấu hình.

In ra các quy tắc `environment`, `allow`, `soft_deny`, và `hard_deny` tích hợp sẵn dưới dạng JSON:

```bash theme={null}
claude auto-mode defaults
```

In ra những gì bộ phân loại thực sự dùng dưới dạng JSON, với cấu hình của bạn được áp dụng ở nơi đã thiết lập và dùng mặc định ở những nơi còn lại:

```bash theme={null}
claude auto-mode config
```

Nhận phản hồi từ AI về các quy tắc `allow`, `soft_deny`, và `hard_deny` tùy chỉnh của bạn:

```bash theme={null}
claude auto-mode critique
```

Hãy chạy `claude auto-mode config` sau khi lưu cấu hình để xác nhận các quy tắc đang có hiệu lực đúng như bạn mong đợi, với `"$defaults"` được mở rộng tại chỗ. Nếu bạn đã viết các quy tắc tùy chỉnh, `claude auto-mode critique` sẽ xem xét chúng và gắn cờ những mục mơ hồ, dư thừa, hoặc có khả năng gây báo động giả.

Nếu bạn cần gỡ bỏ hoặc viết lại một quy tắc tích hợp sẵn thay vì thêm cạnh nó, hãy lưu kết quả của `claude auto-mode defaults` vào một tệp, chỉnh sửa các danh sách, và dán kết quả vào tệp cấu hình của bạn thay cho `"$defaults"`.

## Xem lại các lần bị từ chối

Khi auto mode từ chối một lệnh gọi tool, lần từ chối đó được ghi lại trong `/permissions` dưới tab Recently denied. Nhấn `r` trên một hành động bị từ chối để đánh dấu nó cho việc thử lại: khi bạn thoát khỏi hộp thoại, Claude Code gửi một thông điệp báo cho model rằng nó có thể thử lại lệnh gọi tool đó và tiếp tục cuộc hội thoại.

Trong Claude Code v2.1.193 trở lên, lý do của bộ phân loại cho mỗi lần từ chối sẽ xuất hiện cạnh lệnh gọi tool bị chặn trong transcript, trong thông báo từ chối, và dưới mỗi mục trong tab Recently denied. Dùng lý do đó để quyết định xem cách khắc phục là một mục `environment`, một ngoại lệ `allow`, hay thử lại với ý định rõ ràng trong thông điệp tiếp theo của bạn.

Việc bị từ chối lặp đi lặp lại cho cùng một đích đến thường có nghĩa là bộ phân loại đang thiếu ngữ cảnh. Hãy thêm đích đến đó vào `autoMode.environment`, rồi chạy `claude auto-mode config` để xác nhận nó đã có hiệu lực.

Để phản ứng với các lần từ chối theo cách lập trình, hãy dùng [hook `PermissionDenied`](/en/hooks#permissiondenied).

## Xem thêm

* [Permission modes](/en/permission-modes#eliminate-prompts-with-auto-mode): auto mode là gì, nó chặn những gì theo mặc định, và cách bật nó
* [Managed settings](/en/server-managed-settings): triển khai cấu hình `autoMode` trên toàn tổ chức của bạn
* [Permissions](/en/permissions): các quy tắc allow, ask, và deny áp dụng trước khi bộ phân loại chạy
* [Settings](/en/settings): tài liệu tham chiếu cấu hình đầy đủ, bao gồm cả key `autoMode`
