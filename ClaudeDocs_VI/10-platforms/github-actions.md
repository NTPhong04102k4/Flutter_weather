> Nguồn: https://code.claude.com/docs/en/github-actions.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Claude Code GitHub Actions

> Tìm hiểu về việc tích hợp Claude Code vào quy trình phát triển của bạn với Claude Code GitHub Actions

Claude Code GitHub Actions mang tự động hóa được hỗ trợ bởi AI vào quy trình GitHub của bạn. Với một mention `@claude` đơn giản trong bất kỳ PR hay issue nào, Claude có thể phân tích code, tạo pull request, cài đặt tính năng, và sửa lỗi - tất cả trong khi tuân theo các tiêu chuẩn của dự án bạn. Để có các đánh giá tự động được đăng trên mỗi PR mà không cần trigger, xem [GitHub Code Review](/en/code-review).

<Note>
  Claude Code GitHub Actions được xây dựng trên [Claude Agent SDK](/en/agent-sdk/overview), cho phép tích hợp Claude Code vào ứng dụng của bạn theo cách lập trình. Bạn có thể dùng SDK để xây dựng các quy trình tự động hóa tùy chỉnh vượt ra ngoài GitHub Actions.
</Note>

## Tại sao nên dùng Claude Code GitHub Actions?

* **Tạo PR tức thì**: Mô tả những gì bạn cần, và Claude tạo một PR hoàn chỉnh với tất cả thay đổi cần thiết
* **Cài đặt code tự động**: Biến các issue thành code hoạt động chỉ với một lệnh
* **Tuân theo tiêu chuẩn của bạn**: Claude tôn trọng hướng dẫn trong `CLAUDE.md` và các mẫu code hiện có của bạn
* **Thiết lập đơn giản**: Bắt đầu trong vài phút với trình cài đặt và API key của chúng tôi
* **An toàn theo mặc định**: Code của bạn ở lại trên các runner của GitHub

## Claude có thể làm gì?

Claude Code cung cấp một GitHub Action mạnh mẽ thay đổi cách bạn làm việc với code:

### Claude Code Action

GitHub Action này cho phép bạn chạy Claude Code trong các quy trình GitHub Actions của mình. Bạn có thể dùng nó để xây dựng bất kỳ quy trình tùy chỉnh nào trên nền Claude Code.

[Xem kho →](https://github.com/anthropics/claude-code-action)

## Thiết lập

## Thiết lập nhanh

Chạy `/install-github-app` trong terminal Claude Code để thiết lập tích hợp theo cách tương tác. Lệnh này cài đặt Claude GitHub App lên kho của bạn và sau đó hướng dẫn bạn thêm các workflow GitHub Actions và secret API key.

Sau khi GitHub App được cài, lệnh hỏi liệu có tiếp tục với thiết lập GitHub Actions hay không. Trong Claude Code v2.1.187 trở lên, bạn có thể chọn **Skip for now** để dừng lại chỉ với App được cài và quay lại các bước workflow và secret bằng cách chạy lại `/install-github-app`. Các phiên bản cũ hơn tiến thẳng tới việc chọn workflow.

<Note>
  * Bạn phải là admin của kho để cài GitHub app và thêm secret
  * GitHub app sẽ yêu cầu quyền đọc & ghi cho Contents, Issues, và Pull requests
  * Phương pháp quickstart này chỉ có sẵn cho người dùng Claude API trực tiếp. Nếu bạn đang dùng Amazon Bedrock hoặc Google Cloud's Agent Platform, xem mục [Sử dụng với Amazon Bedrock và Google Cloud](#using-with-amazon-bedrock-and-google-cloud).
</Note>

## Thiết lập thủ công

Nếu lệnh `/install-github-app` thất bại hoặc bạn thích thiết lập thủ công, hãy làm theo các hướng dẫn thiết lập thủ công sau:

1. **Cài đặt Claude GitHub app** lên kho của bạn: [https://github.com/apps/claude](https://github.com/apps/claude)

   Claude GitHub app yêu cầu các quyền kho sau:

   * **Contents**: Read & write (để chỉnh sửa file kho)
   * **Issues**: Read & write (để phản hồi issue)
   * **Pull requests**: Read & write (để tạo PR và đẩy thay đổi)

   Để biết thêm chi tiết về bảo mật và quyền, xem [tài liệu bảo mật](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md).
2. **Thêm ANTHROPIC\_API\_KEY** vào secret kho của bạn ([Tìm hiểu cách dùng secret trong GitHub Actions](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions))
3. **Sao chép file workflow** từ [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) vào thư mục `.github/workflows/` của kho bạn

<Tip>
  Sau khi hoàn tất quickstart hoặc thiết lập thủ công, hãy kiểm tra action bằng cách tag `@claude` trong một issue hoặc nhận xét PR.
</Tip>

## Nâng cấp từ Beta

<Warning>
  Claude Code GitHub Actions v1.0 giới thiệu các thay đổi phá vỡ tương thích (breaking changes) yêu cầu cập nhật các file workflow của bạn để nâng cấp lên v1.0 từ phiên bản beta.
</Warning>

Nếu bạn hiện đang dùng phiên bản beta của Claude Code GitHub Actions, chúng tôi khuyến nghị cập nhật các workflow của bạn để dùng phiên bản GA. Phiên bản mới đơn giản hóa cấu hình đồng thời thêm các tính năng mới mạnh mẽ như tự động phát hiện chế độ.

### Các thay đổi thiết yếu

Tất cả người dùng beta phải thực hiện các thay đổi này với file workflow của họ để nâng cấp:

1. **Cập nhật phiên bản action**: Đổi `@beta` thành `@v1`
2. **Loại bỏ cấu hình mode**: Xóa `mode: "tag"` hoặc `mode: "agent"` (giờ tự động phát hiện)
3. **Cập nhật đầu vào prompt**: Thay `direct_prompt` bằng `prompt`
4. **Chuyển các tùy chọn CLI**: Chuyển `max_turns`, `model`, `custom_instructions`, v.v. sang `claude_args`

### Tham chiếu các thay đổi phá vỡ tương thích

| Đầu vào Beta cũ        | Đầu vào v1.0 mới                        |
| --------------------- | ------------------------------------- |
| `mode`                | *(Đã loại bỏ - tự động phát hiện)*           |
| `direct_prompt`       | `prompt`                              |
| `override_prompt`     | `prompt` với các biến GitHub        |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |
| `disallowed_tools`    | `claude_args: --disallowedTools`      |
| `claude_env`          | Định dạng JSON `settings`              |

### Ví dụ Trước và Sau

**Phiên bản Beta:**

```yaml theme={null}
- uses: anthropics/claude-code-action@beta
  with:
    mode: "tag"
    direct_prompt: "Review this PR for security issues"
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    custom_instructions: "Follow our coding standards"
    max_turns: "10"
    model: "claude-sonnet-5"
```

**Phiên bản GA (v1.0):**

```yaml theme={null}
- uses: anthropics/claude-code-action@v1
  with:
    prompt: "Review this PR for security issues"
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    claude_args: |
      --append-system-prompt "Follow our coding standards"
      --max-turns 10
      --model claude-sonnet-5
```

<Tip>
  Action giờ tự động phát hiện có nên chạy ở chế độ tương tác (phản hồi các mention `@claude`) hay chế độ tự động hóa (chạy ngay lập tức với một prompt) dựa trên cấu hình của bạn.
</Tip>

## Các trường hợp sử dụng ví dụ

Claude Code GitHub Actions có thể giúp bạn với nhiều tác vụ khác nhau. [Thư mục examples](https://github.com/anthropics/claude-code-action/tree/main/examples) chứa các workflow sẵn dùng cho các kịch bản khác nhau.

### Workflow cơ bản

```yaml theme={null}
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # Responds to @claude mentions in comments
```

### Sử dụng skill

Đầu vào `prompt` chấp nhận một lời gọi [skill](/en/skills) cũng như văn bản thuần:

* Với một skill trong thư mục `.claude/skills/` của kho bạn, chạy `actions/checkout` trước bước action và truyền `/skill-name`.
* Với một skill được đóng gói trong một plugin, cài plugin đó bằng các đầu vào `plugin_marketplaces` và `plugins` rồi truyền `/plugin-name:skill-name` có namespace.

Workflow sau đây cài plugin `code-review` và chạy skill của nó trên mỗi pull request mới hoặc được cập nhật:

```yaml theme={null}
name: Code Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          plugin_marketplaces: "https://github.com/anthropics/claude-code.git"
          plugins: "code-review@claude-code-plugins"
          prompt: "/code-review:code-review ${{ github.repository }}/pull/${{ github.event.pull_request.number }}"
```

### Tự động hóa tùy chỉnh với prompt

```yaml theme={null}
name: Daily Report
on:
  schedule:
    - cron: "0 9 * * *"
jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "Generate a summary of yesterday's commits and open issues"
          claude_args: "--model opus"
```

### Các trường hợp sử dụng phổ biến

Trong nhận xét issue hoặc PR:

```text wrap theme={null}
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
```

Claude sẽ tự động phân tích ngữ cảnh và phản hồi phù hợp.

## Các thực hành tốt nhất

### Cấu hình CLAUDE.md

Tạo một file `CLAUDE.md` ở thư mục gốc của kho để định nghĩa hướng dẫn phong cách code, tiêu chí đánh giá, quy tắc riêng của dự án, và các mẫu ưa thích. File này định hướng cách Claude hiểu các tiêu chuẩn dự án của bạn.

### Cân nhắc bảo mật

<Warning>Đừng bao giờ commit API key trực tiếp vào kho của bạn.</Warning>

Để có hướng dẫn bảo mật toàn diện bao gồm quyền, xác thực, và các thực hành tốt nhất, xem [tài liệu bảo mật Claude Code Action](https://github.com/anthropics/claude-code-action/blob/main/docs/security.md).

Luôn dùng GitHub Secrets cho API key:

* Thêm API key của bạn làm một secret kho tên là `ANTHROPIC_API_KEY`
* Tham chiếu nó trong workflow: `anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}`
* Giới hạn quyền của action chỉ ở mức cần thiết
* Xem lại các đề xuất của Claude trước khi merge

Luôn dùng GitHub Secrets (ví dụ `${{ secrets.ANTHROPIC_API_KEY }}`) thay vì hard-code API key trực tiếp trong các file workflow của bạn.

### Tối ưu hiệu năng

Dùng issue template để cung cấp ngữ cảnh, giữ `CLAUDE.md` ngắn gọn và tập trung, và cấu hình timeout phù hợp cho các workflow của bạn.

### Chi phí CI

Khi dùng Claude Code GitHub Actions, hãy lưu ý các chi phí liên quan:

**Chi phí GitHub Actions:**

* Claude Code chạy trên các runner do GitHub lưu trữ, tiêu tốn phút GitHub Actions của bạn
* Xem [tài liệu billing của GitHub](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-actions/about-billing-for-github-actions) để biết giá và giới hạn phút chi tiết

**Chi phí API:**

* Mỗi tương tác Claude tiêu tốn token API dựa trên độ dài prompt và phản hồi
* Mức dùng token thay đổi theo độ phức tạp tác vụ và kích thước codebase
* Xem [trang giá của Claude](https://claude.com/platform/api) để biết mức token hiện tại

**Mẹo tối ưu chi phí:**

* Dùng các lệnh `@claude` cụ thể để giảm các lời gọi API không cần thiết
* Cấu hình `--max-turns` phù hợp trong `claude_args` để ngăn lặp quá mức
* Đặt timeout ở cấp workflow để tránh các job chạy vượt kiểm soát
* Cân nhắc dùng kiểm soát concurrency của GitHub để giới hạn số lần chạy song song

## Ví dụ cấu hình

Claude Code Action v1 đơn giản hóa cấu hình với các tham số hợp nhất:

```yaml theme={null}
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "Your instructions here" # Optional
    claude_args: "--max-turns 5" # Optional CLI arguments
```

Các tính năng chính:

* **Giao diện prompt hợp nhất** - Dùng `prompt` cho tất cả chỉ dẫn
* **Skills** - Gọi các [skill](/en/skills) đã cài trực tiếp từ prompt
* **Truyền qua CLI (passthrough)** - Bất kỳ tham số CLI Claude Code nào qua `claude_args`
* **Trigger linh hoạt** - Hoạt động với mọi sự kiện GitHub

Truy cập [thư mục examples](https://github.com/anthropics/claude-code-action/tree/main/examples) để có các file workflow hoàn chỉnh.

<Tip>
  Khi phản hồi nhận xét issue hoặc PR, Claude tự động phản hồi các mention @claude. Với các sự kiện khác, dùng tham số `prompt` để cung cấp chỉ dẫn.
</Tip>

## Sử dụng với Amazon Bedrock và Google Cloud

Đối với môi trường doanh nghiệp, bạn có thể dùng Claude Code GitHub Actions với hạ tầng đám mây của riêng mình. Cách tiếp cận này cho bạn quyền kiểm soát nơi lưu trữ dữ liệu và billing trong khi vẫn giữ nguyên chức năng.

### Điều kiện tiên quyết

Trước khi thiết lập Claude Code GitHub Actions với các nhà cung cấp đám mây, bạn cần:

#### Với Google Cloud's Agent Platform:

1. Một Google Cloud Project có Google Cloud's Agent Platform được bật
2. Workload Identity Federation được cấu hình cho GitHub Actions
3. Một service account với các quyền cần thiết
4. Một GitHub App (khuyến nghị) hoặc dùng GITHUB\_TOKEN mặc định

#### Với Amazon Bedrock:

1. Một tài khoản AWS có Amazon Bedrock được bật
2. GitHub OIDC Identity Provider được cấu hình trong AWS
3. Một IAM role với các quyền Amazon Bedrock
4. Một GitHub App (khuyến nghị) hoặc dùng GITHUB\_TOKEN mặc định

<Steps>
  <Step title="Tạo một GitHub App tùy chỉnh (Khuyến nghị cho các nhà cung cấp bên thứ ba)">
    Để có quyền kiểm soát và bảo mật tốt nhất khi dùng các nhà cung cấp bên thứ ba như Google Cloud's Agent Platform hoặc Amazon Bedrock, chúng tôi khuyến nghị tạo GitHub App của riêng bạn:

    1. Vào [https://github.com/settings/apps/new](https://github.com/settings/apps/new)
    2. Điền thông tin cơ bản:
       * **GitHub App name**: Chọn một tên duy nhất (ví dụ "YourOrg Claude Assistant")
       * **Homepage URL**: Website tổ chức của bạn hoặc URL kho
    3. Cấu hình các thiết lập app:
       * **Webhooks**: Bỏ chọn "Active" (không cần cho tích hợp này)
    4. Đặt các quyền cần thiết:
       * **Repository permissions**:
         * Contents: Read & Write
         * Issues: Read & Write
         * Pull requests: Read & Write
    5. Nhấp "Create GitHub App"
    6. Sau khi tạo, nhấp "Generate a private key" và lưu file `.pem` đã tải xuống
    7. Ghi lại App ID từ trang thiết lập app
    8. Cài app lên kho của bạn:
       * Từ trang thiết lập app của bạn, nhấp "Install App" ở thanh bên trái
       * Chọn tài khoản hoặc tổ chức của bạn
       * Chọn "Only select repositories" và chọn kho cụ thể
       * Nhấp "Install"
    9. Thêm private key làm một secret vào kho của bạn:
       * Vào Settings → Secrets and variables → Actions của kho
       * Tạo một secret mới tên `APP_PRIVATE_KEY` với nội dung của file `.pem`
    10. Thêm App ID làm một secret:

    * Tạo một secret mới tên `APP_ID` với ID GitHub App của bạn

    <Note>
      App này sẽ được dùng với action [actions/create-github-app-token](https://github.com/actions/create-github-app-token) để tạo token xác thực trong các workflow của bạn.
    </Note>

    **Thay thế cho Claude API hoặc nếu bạn không muốn thiết lập Github app của riêng mình**: Dùng app chính thức của Anthropic:

    1. Cài từ: [https://github.com/apps/claude](https://github.com/apps/claude)
    2. Không cần cấu hình bổ sung cho việc xác thực
  </Step>

  <Step title="Cấu hình xác thực nhà cung cấp đám mây">
    Chọn nhà cung cấp đám mây của bạn và thiết lập xác thực an toàn:

    <AccordionGroup>
      <Accordion title="Amazon Bedrock">
        **Cấu hình AWS để cho phép GitHub Actions xác thực an toàn mà không lưu credential.**

        > **Lưu ý bảo mật**: Dùng các cấu hình theo từng kho cụ thể và chỉ cấp các quyền tối thiểu cần thiết.

        **Thiết lập cần thiết**:

        1. **Bật Amazon Bedrock**:
           * Yêu cầu quyền truy cập các model Claude trong Amazon Bedrock
           * Với các model cross-region, yêu cầu quyền truy cập ở tất cả các vùng cần thiết

        2. **Thiết lập GitHub OIDC Identity Provider**:
           * Provider URL: `https://token.actions.githubusercontent.com`
           * Audience: `sts.amazonaws.com`

        3. **Tạo IAM Role cho GitHub Actions**:
           * Trusted entity type: Web identity
           * Identity provider: `token.actions.githubusercontent.com`
           * Permissions: chính sách `AmazonBedrockFullAccess`
           * Cấu hình trust policy cho kho cụ thể của bạn

        **Các giá trị cần thiết**:

        Sau khi thiết lập, bạn sẽ cần:

        * **AWS\_ROLE\_TO\_ASSUME**: ARN của IAM role bạn đã tạo

        <Tip>
          OIDC an toàn hơn dùng access key AWS tĩnh vì credential là tạm thời và tự động luân chuyển.
        </Tip>

        Xem [tài liệu AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) để có hướng dẫn thiết lập OIDC chi tiết.
      </Accordion>

      <Accordion title="Google Cloud's Agent Platform">
        **Cấu hình Google Cloud để cho phép GitHub Actions xác thực an toàn mà không lưu credential.**

        > **Lưu ý bảo mật**: Dùng các cấu hình theo từng kho cụ thể và chỉ cấp các quyền tối thiểu cần thiết.

        **Thiết lập cần thiết**:

        1. **Bật các API** trong dự án Google Cloud của bạn:
           * IAM Credentials API
           * Security Token Service (STS) API
           * Google Cloud's Agent Platform API

        2. **Tạo các tài nguyên Workload Identity Federation**:
           * Tạo một Workload Identity Pool
           * Thêm một GitHub OIDC provider với:
             * Issuer: `https://token.actions.githubusercontent.com`
             * Ánh xạ thuộc tính (attribute mappings) cho repository và owner
             * **Khuyến nghị bảo mật**: Dùng các điều kiện thuộc tính theo từng kho cụ thể

        3. **Tạo một Service Account**:
           * Chỉ cấp role `Vertex AI User`
           * **Khuyến nghị bảo mật**: Tạo một service account riêng cho mỗi kho

        4. **Cấu hình các IAM binding**:
           * Cho phép Workload Identity Pool mạo danh (impersonate) service account
           * **Khuyến nghị bảo mật**: Dùng các principal set theo từng kho cụ thể

        **Các giá trị cần thiết**:

        Sau khi thiết lập, bạn sẽ cần:

        * **GCP\_WORKLOAD\_IDENTITY\_PROVIDER**: Tên tài nguyên provider đầy đủ
        * **GCP\_SERVICE\_ACCOUNT**: Địa chỉ email service account

        <Tip>
          Workload Identity Federation loại bỏ nhu cầu tải service account key, cải thiện bảo mật.
        </Tip>

        Để có hướng dẫn thiết lập chi tiết, tham khảo [tài liệu Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation).
      </Accordion>
    </AccordionGroup>
  </Step>

  <Step title="Thêm các Secret cần thiết">
    Thêm các secret sau vào kho của bạn (Settings → Secrets and variables → Actions):

    #### Với Claude API (Trực tiếp):

    1. **Với Xác thực API**:
       * `ANTHROPIC_API_KEY`: Claude API key của bạn từ [console.anthropic.com](https://console.anthropic.com)

    2. **Với GitHub App (nếu dùng app của riêng bạn)**:
       * `APP_ID`: ID GitHub App của bạn
       * `APP_PRIVATE_KEY`: Nội dung private key (.pem)

    #### Với Google Cloud's Agent Platform

    1. **Với Xác thực GCP**:
       * `GCP_WORKLOAD_IDENTITY_PROVIDER`
       * `GCP_SERVICE_ACCOUNT`

    2. **Với GitHub App (nếu dùng app của riêng bạn)**:
       * `APP_ID`: ID GitHub App của bạn
       * `APP_PRIVATE_KEY`: Nội dung private key (.pem)

    #### Với Amazon Bedrock

    1. **Với Xác thực AWS**:
       * `AWS_ROLE_TO_ASSUME`

    2. **Với GitHub App (nếu dùng app của riêng bạn)**:
       * `APP_ID`: ID GitHub App của bạn
       * `APP_PRIVATE_KEY`: Nội dung private key (.pem)
  </Step>

  <Step title="Tạo các file workflow">
    Tạo các file workflow GitHub Actions tích hợp với nhà cung cấp đám mây của bạn. Các ví dụ dưới đây cho thấy cấu hình hoàn chỉnh cho cả Amazon Bedrock và Google Cloud's Agent Platform:

    <AccordionGroup>
      <Accordion title="Workflow Amazon Bedrock">
        **Điều kiện tiên quyết:**

        * Quyền truy cập Amazon Bedrock được bật với quyền model Claude
        * GitHub được cấu hình làm OIDC identity provider trong AWS
        * IAM role với quyền Amazon Bedrock tin cậy GitHub Actions

        **Các GitHub secret cần thiết:**

        | Tên Secret          | Mô tả                                       |
        | -------------------- | ------------------------------------------------- |
        | `AWS_ROLE_TO_ASSUME` | ARN của IAM role cho truy cập Amazon Bedrock     |
        | `APP_ID`             | ID GitHub App của bạn (từ thiết lập app)            |
        | `APP_PRIVATE_KEY`    | Private key bạn đã tạo cho GitHub App của mình |

        ```yaml theme={null}
        name: Claude PR Action

        permissions:
          contents: write
          pull-requests: write
          issues: write
          id-token: write

        on:
          issue_comment:
            types: [created]
          pull_request_review_comment:
            types: [created]
          issues:
            types: [opened, assigned]

        jobs:
          claude-pr:
            if: |
              (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
              (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
              (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
            runs-on: ubuntu-latest
            env:
              AWS_REGION: us-west-2
            steps:
              - name: Checkout repository
                uses: actions/checkout@v4

              - name: Generate GitHub App token
                id: app-token
                uses: actions/create-github-app-token@v2
                with:
                  app-id: ${{ secrets.APP_ID }}
                  private-key: ${{ secrets.APP_PRIVATE_KEY }}

              - name: Configure AWS Credentials (OIDC)
                uses: aws-actions/configure-aws-credentials@v4
                with:
                  role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
                  aws-region: us-west-2

              - uses: anthropics/claude-code-action@v1
                with:
                  github_token: ${{ steps.app-token.outputs.token }}
                  use_bedrock: "true"
                  claude_args: '--model us.anthropic.claude-sonnet-4-6 --max-turns 10'
        ```

        <Tip>
          Định dạng model ID cho Amazon Bedrock bao gồm tiền tố vùng (ví dụ `us.anthropic.claude-sonnet-4-6`).
        </Tip>
      </Accordion>

      <Accordion title="Workflow Google Cloud's Agent Platform">
        **Điều kiện tiên quyết:**

        * Google Cloud's Agent Platform API được bật trong dự án GCP của bạn
        * Workload Identity Federation được cấu hình cho GitHub
        * Service account với quyền Google Cloud's Agent Platform

        **Các GitHub secret cần thiết:**

        | Tên Secret                      | Mô tả                                                     |
        | -------------------------------- | --------------------------------------------------------------- |
        | `GCP_WORKLOAD_IDENTITY_PROVIDER` | Tên tài nguyên workload identity provider                        |
        | `GCP_SERVICE_ACCOUNT`            | Email service account với truy cập Google Cloud's Agent Platform |
        | `APP_ID`                         | ID GitHub App của bạn (từ thiết lập app)                          |
        | `APP_PRIVATE_KEY`                | Private key bạn đã tạo cho GitHub App của mình               |

        ```yaml theme={null}
        name: Claude PR Action

        permissions:
          contents: write
          pull-requests: write
          issues: write
          id-token: write

        on:
          issue_comment:
            types: [created]
          pull_request_review_comment:
            types: [created]
          issues:
            types: [opened, assigned]

        jobs:
          claude-pr:
            if: |
              (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
              (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
              (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
            runs-on: ubuntu-latest
            steps:
              - name: Checkout repository
                uses: actions/checkout@v4

              - name: Generate GitHub App token
                id: app-token
                uses: actions/create-github-app-token@v2
                with:
                  app-id: ${{ secrets.APP_ID }}
                  private-key: ${{ secrets.APP_PRIVATE_KEY }}

              - name: Authenticate to Google Cloud
                id: auth
                uses: google-github-actions/auth@v2
                with:
                  workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
                  service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

              - uses: anthropics/claude-code-action@v1
                with:
                  github_token: ${{ steps.app-token.outputs.token }}
                  trigger_phrase: "@claude"
                  use_vertex: "true"
                  claude_args: '--model claude-sonnet-4-5@20250929 --max-turns 10'
                env:
                  ANTHROPIC_VERTEX_PROJECT_ID: ${{ steps.auth.outputs.project_id }}
                  CLOUD_ML_REGION: us-east5
                  VERTEX_REGION_CLAUDE_4_5_SONNET: us-east5
        ```

        <Tip>
          Project ID được tự động lấy từ bước xác thực Google Cloud, nên bạn không cần hard-code nó.
        </Tip>
      </Accordion>
    </AccordionGroup>
  </Step>
</Steps>

## Khắc phục sự cố

### Claude không phản hồi các lệnh @claude

Xác minh GitHub App được cài đúng, kiểm tra rằng các workflow được bật, đảm bảo API key được đặt trong secret kho, và xác nhận nhận xét chứa `@claude` (không phải `/claude`).

### CI không chạy trên các commit của Claude

Đảm bảo bạn đang dùng GitHub App hoặc app tùy chỉnh (không phải người dùng Actions), kiểm tra các trigger workflow bao gồm các sự kiện cần thiết, và xác minh quyền của app bao gồm các trigger CI.

### Lỗi xác thực

Xác nhận API key hợp lệ và có đủ quyền. Với Amazon Bedrock hoặc Google Cloud's Agent Platform, kiểm tra cấu hình credential và đảm bảo các secret được đặt tên đúng trong workflow.

## Cấu hình nâng cao

### Tham số của Action

Claude Code Action v1 dùng cấu hình đơn giản hóa:

| Tham số             | Mô tả                                                        | Bắt buộc |
| --------------------- | ------------------------------------------------------------------ | -------- |
| `prompt`              | Chỉ dẫn cho Claude (văn bản thuần hoặc tên một [skill](/en/skills)) | Không\*     |
| `claude_args`         | Các tham số CLI được truyền cho Claude Code                                | Không       |
| `plugin_marketplaces` | Danh sách URL Git của plugin marketplace, phân tách bằng dòng mới              | Không       |
| `plugins`             | Danh sách tên plugin cần cài trước khi thực thi, phân tách bằng dòng mới | Không       |
| `anthropic_api_key`   | Claude API key                                                     | Có\*\*  |
| `github_token`        | GitHub token cho truy cập API                                        | Không       |
| `trigger_phrase`      | Cụm từ trigger tùy chỉnh (mặc định: "@claude")                         | Không       |
| `use_bedrock`         | Dùng Amazon Bedrock thay vì Claude API                           | Không       |
| `use_vertex`          | Dùng Google Cloud's Agent Platform thay vì Claude API            | Không       |

\*Prompt là tùy chọn - khi bỏ trống cho nhận xét issue/PR, Claude phản hồi cụm từ trigger\
\*\*Bắt buộc với Claude API trực tiếp, không bắt buộc với Amazon Bedrock hoặc Google Cloud's Agent Platform

#### Truyền các tham số CLI

Tham số `claude_args` chấp nhận bất kỳ tham số CLI Claude Code nào:

```yaml theme={null}
claude_args: "--max-turns 5 --model claude-sonnet-5 --mcp-config /path/to/config.json"
```

Các tham số phổ biến:

* `--max-turns`: Số lượt hội thoại tối đa (mặc định: 10)
* `--model`: Model để dùng (ví dụ `claude-sonnet-5`)
* `--mcp-config`: Đường dẫn tới cấu hình MCP
* `--allowedTools`: Danh sách các công cụ được phép, phân tách bằng dấu phẩy. Bí danh `--allowed-tools` cũng hoạt động.
* `--debug`: Bật output gỡ lỗi

### Các phương pháp tích hợp thay thế

Mặc dù lệnh `/install-github-app` là cách tiếp cận được khuyến nghị, bạn cũng có thể:

* **GitHub App tùy chỉnh**: Cho các tổ chức cần tên người dùng có thương hiệu hoặc luồng xác thực tùy chỉnh. Tạo GitHub App của riêng bạn với các quyền cần thiết (contents, issues, pull requests) và dùng action actions/create-github-app-token để tạo token trong các workflow của bạn.
* **GitHub Actions thủ công**: Cấu hình workflow trực tiếp để có độ linh hoạt tối đa
* **Cấu hình MCP**: Nạp động các máy chủ Model Context Protocol

Xem [tài liệu Claude Code Action](https://github.com/anthropics/claude-code-action/blob/main/docs) để có các hướng dẫn chi tiết về xác thực, bảo mật, và cấu hình nâng cao.

### Tùy chỉnh hành vi của Claude

Bạn có thể cấu hình hành vi của Claude theo hai cách:

1. **CLAUDE.md**: Định nghĩa các tiêu chuẩn code, tiêu chí đánh giá, và quy tắc riêng của dự án trong một file `CLAUDE.md` ở thư mục gốc của kho. Claude sẽ tuân theo các hướng dẫn này khi tạo PR và phản hồi các yêu cầu. Xem [tài liệu Memory](/en/memory) của chúng tôi để biết thêm chi tiết.
2. **Prompt tùy chỉnh**: Dùng tham số `prompt` trong file workflow để cung cấp các chỉ dẫn riêng cho workflow. Điều này cho phép bạn tùy chỉnh hành vi của Claude cho các workflow hoặc tác vụ khác nhau.

Claude sẽ tuân theo các hướng dẫn này khi tạo PR và phản hồi các yêu cầu.
