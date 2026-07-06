> Nguồn: https://code.claude.com/docs/en/feature-availability.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tính khả dụng của tính năng

> So sánh những tính năng Claude Code nào khả dụng trên các gói đăng ký Anthropic, Anthropic Console, Amazon Bedrock, Claude Platform trên AWS, Agent Platform của Google Cloud, và Microsoft Foundry.

Claude Code CLI và mọi thứ chạy cục bộ hoạt động giống hệt nhau trên mọi nhà cung cấp (provider). Để xem hướng dẫn thiết lập cho từng nhà cung cấp, xem [Tổng quan triển khai doanh nghiệp](/en/third-party-integrations). Để đi thẳng đến những gì bị thiếu trên nhà cung cấp của bạn, xem các tab [tóm tắt theo nhà cung cấp](#summary-by-provider).

Trong các bảng dưới đây, ✓ nghĩa là khả dụng, ✗ nghĩa là không khả dụng, và "See note" liên kết tới một chú thích chân trang cho phần hỗ trợ một phần. Một điều kiện đi kèm sau ✓ thu hẹp tính khả dụng xuống tập con đó, và "Admin-enabled" nghĩa là tính năng bị tắt cho đến khi quản trị viên tổ chức bật nó lên.

## Tính khả dụng theo nhà cung cấp mô hình

Cách bạn xác thực quyết định những tính năng nào Claude Code có thể tiếp cận. Để xem một danh sách duy nhất về những gì bị thiếu trên nhà cung cấp của bạn, xem các tab [tóm tắt theo nhà cung cấp](#summary-by-provider). Để tìm cột của bạn trong các bảng:

* **Claude subscription**: bạn đăng nhập bằng tài khoản claude.ai trên gói Pro, Max, Team, hoặc Enterprise
* **Anthropic Console**: bạn xác thực bằng khóa API của Anthropic
* **Amazon Bedrock**: bạn dùng các mô hình Claude từ danh mục mô hình Amazon Bedrock và đặt `CLAUDE_CODE_USE_BEDROCK`. [Điểm cuối Mantle](/en/amazon-bedrock#use-the-mantle-endpoint) (`CLAUDE_CODE_USE_MANTLE`) được bao gồm trong cột này
* **Claude Platform trên AWS**: bạn mua Claude qua AWS Marketplace nhưng gọi Anthropic API, và đặt `CLAUDE_CODE_USE_ANTHROPIC_AWS`
* **Agent Platform của Google Cloud**: do Google vận hành; bạn đặt `CLAUDE_CODE_USE_VERTEX`
* **Microsoft Foundry**: do Anthropic vận hành trên Azure; bạn đặt `CLAUDE_CODE_USE_FOUNDRY`

### Các tính năng khả dụng trên mọi nhà cung cấp

Những tính năng này hoạt động giống hệt nhau trên mọi nhà cung cấp:

* [CLI](/en/quickstart) và [Agent SDK](/en/agent-sdk/overview)
* Tiện ích mở rộng [VS Code](/en/vs-code) và [JetBrains](/en/jetbrains)
* [Subagent](/en/sub-agents), [hook](/en/hooks-guide), [command](/en/commands), và [skill](/en/skills)
* [Bộ nhớ CLAUDE.md](/en/memory), [plugin](/en/plugins), và [MCP server](/en/mcp)
* [Checkpoint](/en/checkpointing), [sandboxing](/en/sandboxing), và [Workflows](/en/workflows)
* [Số liệu OpenTelemetry](/en/monitoring-usage) và [tệp cài đặt được quản lý (managed settings file)](/en/settings#settings-files)

### Các tính năng yêu cầu gói đăng ký Claude

Những tính năng này yêu cầu đăng nhập bằng tài khoản claude.ai và không thể tiếp cận bằng khóa API của Anthropic Console hay từ nhà cung cấp bên thứ ba:

* [Claude Code trên web](/en/claude-code-on-the-web), Claude Code trên thiết bị di động, và [Claude Code trong Slack](/en/slack)
* [Claude Code Desktop](/en/desktop)
* [Routines](/en/routines) (`/schedule`)
* [Ultraplan](/en/ultraplan) và [Ultrareview](/en/ultrareview)
* [Code Review](/en/code-review): gói Team và Enterprise
* [Remote Control](/en/remote-control)
* [Tiện ích mở rộng Chrome](/en/chrome)
* [Computer use](/en/computer-use): gói Pro và Max
* [Artifacts](/en/artifacts): gói Pro, Max, Team, và Enterprise
* [Voice dictation](/en/voice-dictation)

Desktop là ngoại lệ một phần: các triển khai Enterprise có thể định tuyến Desktop đến Agent Platform của Google Cloud hoặc một nhà cung cấp gateway thông qua [managed settings](https://support.claude.com/en/articles/12622667-enterprise-configuration), và [bản xem trước nghiên cứu Cowork trên 3P](https://claude.com/docs/cowork/3p/overview) chạy tab Code trên Amazon Bedrock, Agent Platform của Google Cloud, Microsoft Foundry, hoặc một LLM gateway tự lưu trữ. Để xem tính khả dụng theo từng gói của các tính năng này, xem [Tính khả dụng theo gói đăng ký](#availability-by-subscription-plan).

### Các khả năng CLI thay đổi theo nhà cung cấp

Những tính năng này hoạt động trong CLI cục bộ nhưng phụ thuộc vào một khả năng phía máy chủ mà không phải nhà cung cấp nào cũng cung cấp.

<table>
  <thead>
    <tr>
      <th>Tính năng</th>
      <th>Claude subscription</th>
      <th>Anthropic Console</th>
      <th>Amazon Bedrock</th>
      <th>Claude Platform trên AWS</th>
      <th>Agent Platform của Google Cloud</th>
      <th>Microsoft Foundry</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>[Web search](/en/tools-reference#websearch-tool-behavior)</td>
      <td>✓</td>
      <td>✓</td>
      <td>✗</td>
      <td>✓</td>
      <td>See note <sup><a href="#fn1">1</a></sup></td>
      <td>✓</td>
    </tr>

    <tr>
      <td>[Fast mode](/en/fast-mode)</td>
      <td>✓</td>
      <td>✓</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
    </tr>

    <tr>
      <td>[Auto mode](/en/auto-mode-config)</td>
      <td>✓</td>
      <td>✓</td>
      <td>See note <sup><a href="#fn2">2</a></sup></td>
      <td>✓</td>
      <td>See note <sup><a href="#fn2">2</a></sup></td>
      <td>See note <sup><a href="#fn2">2</a></sup></td>
    </tr>

    <tr>
      <td>[Advisor](/en/advisor)</td>
      <td>✓</td>
      <td>✓</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
    </tr>

    <tr>
      <td>[Channels](/en/channels)</td>
      <td>✓</td>
      <td>✓</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
    </tr>

    <tr>
      <td>[`/loop` scheduled tasks](/en/scheduled-tasks)</td>
      <td>✓</td>
      <td>✓</td>
      <td>See note <sup><a href="#fn3">3</a></sup></td>
      <td>✓</td>
      <td>See note <sup><a href="#fn3">3</a></sup></td>
      <td>See note <sup><a href="#fn3">3</a></sup></td>
    </tr>

    <tr>
      <td>[GitHub Actions](/en/github-actions) và [GitLab CI/CD](/en/gitlab-ci-cd)</td>
      <td>✓</td>
      <td>✓</td>
      <td>✓</td>
      <td>✓</td>
      <td>✓</td>
      <td>✗</td>
    </tr>
  </tbody>
</table>

### Quản trị và phân tích

Các quyền kiểm soát cấp tổ chức và khả năng quan sát mức sử dụng.

<table>
  <thead>
    <tr>
      <th>Tính năng</th>
      <th>Claude subscription</th>
      <th>Anthropic Console</th>
      <th>Amazon Bedrock</th>
      <th>Claude Platform trên AWS</th>
      <th>Agent Platform của Google Cloud</th>
      <th>Microsoft Foundry</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>[Bảng điều khiển và API phân tích](/en/analytics)</td>
      <td>✓ (Team và Enterprise)</td>
      <td>✓ <sup><a href="#fn5">5</a></sup></td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
    </tr>

    <tr>
      <td>[Server-managed settings](/en/server-managed-settings)</td>
      <td>✓ (Team và Enterprise)</td>
      <td>✓ (Team và Enterprise)</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
      <td>✗</td>
    </tr>

    <tr>
      <td>[Zero Data Retention](/en/zero-data-retention)</td>
      <td>✓ (tài khoản Enterprise đủ điều kiện)</td>
      <td>✓ (tài khoản đủ điều kiện)</td>
      <td>See note <sup><a href="#fn4">4</a></sup></td>
      <td>✓ (tài khoản đủ điều kiện)</td>
      <td>See note <sup><a href="#fn4">4</a></sup></td>
      <td>See note <sup><a href="#fn4">4</a></sup></td>
    </tr>
  </tbody>
</table>

<span id="fn1" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>1</sup> Trên Agent Platform của Google Cloud, web search khả dụng cho các mô hình Claude 4 trở lên.<br />
<span id="fn2" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>2</sup> Yêu cầu `CLAUDE_CODE_ENABLE_AUTO_MODE`. Xem [Cấu hình Auto mode](/en/auto-mode-config).<br />
<span id="fn3" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>3</sup> Các khoảng thời gian rõ ràng như `/loop every 2 hours` hoạt động trên mọi nhà cung cấp. Trên Amazon Bedrock, Agent Platform của Google Cloud, và Microsoft Foundry, `/loop` không thể tự chọn khoảng thời gian riêng hay cung cấp prompt bảo trì mặc định, nên một prompt không có khoảng thời gian sẽ chạy mỗi 10 phút, và `/loop` không có tham số sẽ hiển thị thông báo cách dùng. Xem [Scheduled tasks](/en/scheduled-tasks).<br />
<span id="fn4" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>4</sup> Tùy theo thỏa thuận của bạn với nhà cung cấp đám mây.<br />
<span id="fn5" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>5</sup> Chỉ bảng điều khiển và API. [Số liệu đóng góp (contribution metrics)](/en/analytics#enable-contribution-metrics) yêu cầu một tổ chức claude.ai gói Team hoặc Enterprise.

<Note>
  Nếu bạn xác thực qua một [LLM gateway](/en/llm-gateway), tính khả dụng của tính năng khớp với nhà cung cấp nền tảng mà gateway chuyển tiếp tới. Một số tính năng chỉ có ở Anthropic như [Advisor](/en/advisor) chỉ hoạt động nếu gateway chuyển tiếp yêu cầu nguyên vẹn đến Anthropic API.
</Note>

### Tóm tắt theo nhà cung cấp

Mỗi tab liệt kê những gì không khả dụng hoặc chỉ được hỗ trợ một phần trên nhà cung cấp đó, kèm các phương án thay thế nếu có. Mọi thứ không được liệt kê đều hoạt động giống như trên gói đăng ký Claude. Trên Amazon Bedrock, Agent Platform của Google Cloud, Microsoft Foundry, và Claude Platform trên AWS, việc báo lỗi và telemetry gửi về Anthropic bị tắt theo mặc định. Xem [hành vi mặc định theo nhà cung cấp API](/en/data-usage#default-behaviors-by-api-provider) để biết luồng dữ liệu nào vẫn đến Anthropic và cách từ chối tham gia.

<Tabs>
  <Tab title="Amazon Bedrock">
    **Không khả dụng:** tất cả [các tính năng yêu cầu gói đăng ký Claude](#features-that-require-a-claude-subscription), cùng với [web search](/en/tools-reference#websearch-tool-behavior), [fast mode](/en/fast-mode), [Advisor](/en/advisor), [Channels](/en/channels), [bảng điều khiển phân tích](/en/analytics), và [server-managed settings](/en/server-managed-settings).

    **Hỗ trợ một phần:**

    * [Desktop](/en/desktop): chỉ qua [bản xem trước nghiên cứu Cowork trên 3P](https://claude.com/docs/cowork/3p/overview)
    * [Auto mode](/en/auto-mode-config): đặt `CLAUDE_CODE_ENABLE_AUTO_MODE`
    * [`/loop`](/en/scheduled-tasks): chỉ với khoảng thời gian rõ ràng
    * [Zero Data Retention](/en/zero-data-retention): tùy theo thỏa thuận AWS của bạn

    **Phương án thay thế:** để lập lịch, dùng [`/loop`](/en/scheduled-tasks) với khoảng thời gian rõ ràng thay cho `/schedule`. Cho các phiên trên đám mây, dùng [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd). Cho tra cứu web, dùng [công cụ WebFetch](/en/tools-reference#webfetch-tool-behavior) với một URL cụ thể.
  </Tab>

  <Tab title="Claude Platform trên AWS">
    **Không khả dụng:** tất cả [các tính năng yêu cầu gói đăng ký Claude](#features-that-require-a-claude-subscription), cùng với [fast mode](/en/fast-mode), [Advisor](/en/advisor), [Channels](/en/channels), [bảng điều khiển phân tích](/en/analytics), và [server-managed settings](/en/server-managed-settings).

    **Khả dụng** ở những chỗ Amazon Bedrock không có: [web search](/en/tools-reference#websearch-tool-behavior), [auto mode](/en/auto-mode-config) không cần cờ chọn tham gia, và [khả năng tự điều tiết nhịp của `/loop`](/en/scheduled-tasks).

    **Phương án thay thế:** để lập lịch, dùng [`/loop`](/en/scheduled-tasks) thay cho `/schedule`. Cho các phiên trên đám mây, dùng [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd).
  </Tab>

  <Tab title="Agent Platform của Google Cloud">
    **Không khả dụng:** tất cả [các tính năng yêu cầu gói đăng ký Claude](#features-that-require-a-claude-subscription), cùng với [fast mode](/en/fast-mode), [Advisor](/en/advisor), [Channels](/en/channels), [bảng điều khiển phân tích](/en/analytics), và [server-managed settings](/en/server-managed-settings).

    **Hỗ trợ một phần:**

    * [Desktop](/en/desktop): qua [managed settings](https://support.claude.com/en/articles/12622667-enterprise-configuration) hoặc [bản xem trước nghiên cứu Cowork trên 3P](https://claude.com/docs/cowork/3p/overview)
    * [Web search](/en/tools-reference#websearch-tool-behavior): các mô hình Claude 4 trở lên
    * [Auto mode](/en/auto-mode-config): đặt `CLAUDE_CODE_ENABLE_AUTO_MODE`
    * [`/loop`](/en/scheduled-tasks): chỉ với khoảng thời gian rõ ràng
    * [Zero Data Retention](/en/zero-data-retention): tùy theo thỏa thuận Google Cloud của bạn

    **Phương án thay thế:** để lập lịch, dùng [`/loop`](/en/scheduled-tasks) với khoảng thời gian rõ ràng thay cho `/schedule`. Cho các phiên trên đám mây, dùng [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd).
  </Tab>

  <Tab title="Microsoft Foundry">
    **Không khả dụng:** tất cả [các tính năng yêu cầu gói đăng ký Claude](#features-that-require-a-claude-subscription), cùng với [fast mode](/en/fast-mode), [Advisor](/en/advisor), [Channels](/en/channels), [GitHub Actions](/en/github-actions) và [GitLab CI/CD](/en/gitlab-ci-cd), [bảng điều khiển phân tích](/en/analytics), và [server-managed settings](/en/server-managed-settings).

    **Hỗ trợ một phần:**

    * [Desktop](/en/desktop): chỉ qua [bản xem trước nghiên cứu Cowork trên 3P](https://claude.com/docs/cowork/3p/overview)
    * [Auto mode](/en/auto-mode-config): đặt `CLAUDE_CODE_ENABLE_AUTO_MODE`
    * [`/loop`](/en/scheduled-tasks): chỉ với khoảng thời gian rõ ràng
    * [Zero Data Retention](/en/zero-data-retention): tùy theo thỏa thuận Azure của bạn

    **Phương án thay thế:** để lập lịch, dùng [`/loop`](/en/scheduled-tasks) với khoảng thời gian rõ ràng thay cho `/schedule`.
  </Tab>

  <Tab title="Anthropic Console">
    **Không khả dụng:** tất cả [các tính năng yêu cầu gói đăng ký Claude](#features-that-require-a-claude-subscription).

    Mọi thứ trong [Các khả năng CLI thay đổi theo nhà cung cấp](#cli-capabilities-that-vary-by-provider) đều khả dụng, cũng như [server-managed settings](/en/server-managed-settings) khi khóa API thuộc về một tổ chức Team hoặc Enterprise.
  </Tab>
</Tabs>

## Tính khả dụng theo gói đăng ký

Nếu bạn xác thực qua Amazon Bedrock, Agent Platform của Google Cloud, Microsoft Foundry, hoặc khóa API của Anthropic Console, phần này không áp dụng cho bạn. Khi bạn đăng nhập bằng tài khoản claude.ai, gói của bạn quyết định những tính năng nào dưới đây khả dụng.

| Tính năng                                                                               | Pro | Max | Team          | Enterprise                        |
| :-------------------------------------------------------------------------------------- | :-- | :-- | :------------ | :-------------------------------- |
| [Claude Code trên web](/en/claude-code-on-the-web)                                      | ✓   | ✓   | ✓             | ✓ <sup><a href="#fn6">6</a></sup> |
| [Routines](/en/routines)                                                                | ✓   | ✓   | ✓             | ✓                                 |
| [Remote Control](/en/remote-control)                                                    | ✓   | ✓   | Admin-enabled | Admin-enabled                     |
| [Channels](/en/channels)                                                                | ✓   | ✓   | Admin-enabled | Admin-enabled                     |
| [Computer use](/en/computer-use)                                                        | ✓   | ✓   | ✗             | ✗                                 |
| Dispatch ([Desktop](/en/desktop#sessions-from-dispatch))                                | ✓   | ✓   | ✗             | ✗                                 |
| [Code Review](/en/code-review)                                                          | ✗   | ✗   | ✓             | ✓                                 |
| [Artifacts](/en/artifacts)                                                              | ✓   | ✓   | ✓             | Admin-enabled                     |
| [Bảng điều khiển, API phân tích, và số liệu đóng góp](/en/analytics)                    | ✗   | ✗   | ✓             | ✓                                 |
| [Server-managed settings](/en/server-managed-settings)                                  | ✗   | ✗   | ✓             | ✓                                 |
| [SSO](https://support.claude.com/en/articles/9266767-what-is-the-team-plan)             | ✗   | ✗   | ✓             | ✓                                 |
| SCIM                                                                                    | ✗   | ✗   | ✗             | ✓                                 |
| [Compliance API](https://platform.claude.com/docs/en/api/admin-api/compliance/overview) | ✗   | ✗   | ✗             | ✓                                 |
| [Zero Data Retention](/en/zero-data-retention)                                          | ✗   | ✗   | ✗             | ✓ <sup><a href="#fn7">7</a></sup> |

<span id="fn6" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>6</sup> Trên Enterprise, yêu cầu một chỗ ngồi (seat) premium hoặc chỗ ngồi Chat + Claude Code. Xem [Claude Code trên web](/en/claude-code-on-the-web).<br />
<span id="fn7" style={{display: 'block', position: 'relative', top: '-120px'}} /><sup>7</sup> Không bao gồm trong gói Enterprise tiêu chuẩn. Yêu cầu Anthropic bật riêng cho các tài khoản đủ điều kiện. Xem [Zero Data Retention](/en/zero-data-retention).<br />

Để xem giá và bảng so sánh gói đầy đủ, xem [Gói Team](https://support.claude.com/en/articles/9266767-what-is-the-team-plan) và [Gói Enterprise](https://support.claude.com/en/articles/9797531-what-is-the-enterprise-plan).

## Tính khả dụng của mô hình

Để biết mô hình Claude nào và kích thước context window (cửa sổ ngữ cảnh) nào khả dụng theo từng nhà cung cấp và khu vực, xem [Cấu hình mô hình](/en/model-config) và [Tổng quan về mô hình](https://platform.claude.com/docs/en/about-claude/models/overview). Vision, đầu vào PDF, và extended thinking là khả năng của mô hình chứ không phải tính năng của Claude Code, và hoạt động trên mọi nhà cung cấp có mô hình đó. [Prompt caching](/en/prompt-caching) hoạt động theo cùng một cách trên hầu hết các nhà cung cấp; trên Amazon Bedrock, mức hỗ trợ thay đổi tùy theo mô hình.

## Tài nguyên liên quan

* [Tổng quan triển khai doanh nghiệp](/en/third-party-integrations): so sánh xác thực, thanh toán, và khu vực giữa các nhà cung cấp
* Hướng dẫn thiết lập nhà cung cấp: [Amazon Bedrock](/en/amazon-bedrock), [Claude Platform trên AWS](/en/claude-platform-on-aws), [Agent Platform của Google Cloud](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry)
* [Nền tảng và tích hợp](/en/platforms): nơi Claude Code chạy, bao gồm CLI, Desktop, tiện ích mở rộng IDE, web, di động, và CI/CD
