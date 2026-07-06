> Nguồn: https://code.claude.com/docs/en/third-party-integrations.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Tổng quan về triển khai cho doanh nghiệp

> Tìm hiểu cách Claude Code có thể tích hợp với nhiều dịch vụ và hạ tầng của bên thứ ba để đáp ứng các yêu cầu triển khai ở cấp doanh nghiệp.

export const ContactSalesCard = ({surface}) => {
  const utm = content => `utm_source=claude_code&utm_medium=docs&utm_content=${surface}_${content}`;
  const iconArrowRight = (size = 13) => <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <line x1="5" y1="12" x2="19" y2="12" />
      <polyline points="12 5 19 12 12 19" />
    </svg>;
  const STYLES = `
.cc-cs {
  --cs-slate: #141413;
  --cs-clay: #d97757;
  --cs-clay-deep: #c6613f;
  --cs-gray-000: #ffffff;
  --cs-gray-700: #3d3d3a;
  --cs-border-default: rgba(31, 30, 29, 0.15);
  font-family: inherit;
}
.dark .cc-cs {
  --cs-slate: #f0eee6;
  --cs-gray-000: #262624;
  --cs-gray-700: #bfbdb4;
  --cs-border-default: rgba(240, 238, 230, 0.14);
}
.cc-cs-card {
  display: flex; align-items: center; justify-content: space-between;
  gap: 16px; padding: 14px 16px; margin: 0;
  background: var(--cs-gray-000); border: 0.5px solid var(--cs-border-default);
  border-radius: 8px; flex-wrap: wrap;
}
.cc-cs-text { font-size: 13px; color: var(--cs-gray-700); line-height: 1.5; flex: 1; min-width: 240px; }
.cc-cs-text strong { font-weight: 550; color: var(--cs-slate); }
.cc-cs-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.cc-cs-btn-clay {
  display: inline-flex; align-items: center; gap: 8px;
  background: var(--cs-clay-deep); color: #fff; border: none;
  border-radius: 8px; padding: 8px 14px;
  font-size: 13px; font-weight: 500;
  transition: background-color 0.15s; white-space: nowrap;
}
.cc-cs-btn-clay:hover { background: var(--cs-clay); }
.cc-cs-btn-ghost {
  display: inline-flex; align-items: center; gap: 8px;
  background: transparent; color: var(--cs-gray-700);
  border: 0.5px solid var(--cs-border-default);
  border-radius: 8px; padding: 8px 14px;
  font-size: 13px; font-weight: 500;
}
.cc-cs-btn-ghost:hover { background: rgba(0, 0, 0, 0.04); }
.dark .cc-cs-btn-ghost:hover { background: rgba(255, 255, 255, 0.04); }
@media (max-width: 720px) {
  .cc-cs-actions { width: 100%; }
}
`;
  return <div className="cc-cs not-prose">
      <style>{STYLES}</style>
      <div className="cc-cs-card">
        <div className="cc-cs-text">
          <strong>Deploying Claude Code across your organization?</strong> Talk to sales about enterprise plans, SSO, and centralized billing.
        </div>
        <div className="cc-cs-actions">
          <a href={`https://claude.com/pricing?${utm('view_plans')}#plans-business`} className="cc-cs-btn-ghost">
            View plans
          </a>
          <a href={`https://claude.com/contact-sales?${utm('contact_sales')}`} className="cc-cs-btn-clay">
            Contact sales {iconArrowRight()}
          </a>
        </div>
      </div>
    </div>;
};

Các tổ chức có thể triển khai Claude Code trực tiếp thông qua Anthropic hoặc thông qua một nhà cung cấp đám mây (cloud provider). Trang này giúp bạn chọn cấu hình phù hợp.

<ContactSalesCard surface="third_party_overview" />

## So sánh các phương án triển khai

Đối với hầu hết các tổ chức, Claude for Teams hoặc Claude for Enterprise mang lại trải nghiệm tốt nhất. Thành viên nhóm được truy cập cả Claude Code lẫn Claude trên web chỉ với một gói đăng ký duy nhất, có quản lý thanh toán tập trung và không cần thiết lập hạ tầng.

**Claude for Teams** là giải pháp tự phục vụ (self-service), bao gồm các tính năng cộng tác, công cụ quản trị và quản lý thanh toán. Phù hợp nhất cho các nhóm nhỏ cần bắt đầu nhanh chóng.

**Claude for Enterprise** bổ sung thêm SSO và tính năng thu nạp tên miền (domain capture), phân quyền theo vai trò (role-based permissions), quyền truy cập API tuân thủ (compliance API), và các cấu hình chính sách được quản lý để triển khai cấu hình Claude Code trên toàn tổ chức. Phù hợp nhất cho các tổ chức lớn có yêu cầu về bảo mật và tuân thủ.

Tìm hiểu thêm về [gói Team](https://support.claude.com/en/articles/9266767-what-is-the-team-plan) và [gói Enterprise](https://support.claude.com/en/articles/9797531-what-is-the-enterprise-plan).

Nếu tổ chức của bạn có các yêu cầu hạ tầng cụ thể, hãy so sánh các phương án dưới đây:

<table>
  <thead>
    <tr>
      <th>Tính năng</th>
      <th>Claude for Teams/Enterprise</th>
      <th>Anthropic Console</th>
      <th>Amazon Bedrock</th>
      <th>Claude Platform on AWS</th>
      <th>Google Cloud's Agent Platform, trước đây là Vertex AI</th>
      <th>Microsoft Foundry</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>Phù hợp nhất cho</td>
      <td>Hầu hết các tổ chức (khuyến nghị)</td>
      <td>Lập trình viên cá nhân</td>
      <td>Triển khai gốc trên AWS (AWS-native)</td>
      <td>Thanh toán qua AWS Marketplace với các tính năng của Claude API</td>
      <td>Triển khai gốc trên GCP (GCP-native)</td>
      <td>Triển khai gốc trên Azure (Azure-native)</td>
    </tr>

    <tr>
      <td>Thanh toán</td>
      <td><strong>Teams:</strong> \$150/chỗ ngồi (Premium) với tùy chọn trả theo mức dùng (PAYG)<br /><strong>Enterprise:</strong> <a href="https://claude.com/contact-sales?utm_source=claude_code&utm_medium=docs&utm_content=third_party_enterprise">Liên hệ bộ phận kinh doanh</a></td>
      <td>PAYG</td>
      <td>PAYG qua AWS</td>
      <td>PAYG qua AWS Marketplace</td>
      <td>PAYG qua GCP</td>
      <td>PAYG qua Azure</td>
    </tr>

    <tr>
      <td>Khu vực (Regions)</td>
      <td>Các [quốc gia được hỗ trợ](https://www.anthropic.com/supported-countries)</td>
      <td>Các [quốc gia được hỗ trợ](https://www.anthropic.com/supported-countries)</td>
      <td>Nhiều [khu vực](https://docs.aws.amazon.com/bedrock/latest/userguide/models-regions.html) của AWS</td>
      <td>Nhiều khu vực của AWS</td>
      <td>Nhiều [khu vực](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/locations) của GCP</td>
      <td>Nhiều [khu vực](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/) của Azure</td>
    </tr>

    <tr>
      <td>Prompt caching</td>
      <td>Bật sẵn theo mặc định</td>
      <td>Bật sẵn theo mặc định</td>
      <td>Bật sẵn theo mặc định</td>
      <td>Bật sẵn theo mặc định</td>
      <td>Bật sẵn theo mặc định</td>
      <td>Bật sẵn theo mặc định</td>
    </tr>

    <tr>
      <td>Xác thực</td>
      <td>SSO của Claude.ai hoặc email</td>
      <td>API key</td>
      <td>API key hoặc thông tin đăng nhập AWS</td>
      <td>API key hoặc thông tin đăng nhập AWS</td>
      <td>Thông tin đăng nhập GCP</td>
      <td>API key hoặc Microsoft Entra ID</td>
    </tr>

    <tr>
      <td>Theo dõi chi phí</td>
      <td>Bảng điều khiển sử dụng (Usage dashboard)</td>
      <td>Bảng điều khiển sử dụng (Usage dashboard)</td>
      <td>AWS Cost Explorer</td>
      <td>AWS Cost Explorer</td>
      <td>GCP Billing</td>
      <td>Azure Cost Management</td>
    </tr>

    <tr>
      <td>Bao gồm Claude trên web</td>
      <td>Có</td>
      <td>Không</td>
      <td>Không</td>
      <td>Không</td>
      <td>Không</td>
      <td>Không</td>
    </tr>

    <tr>
      <td>Tính năng doanh nghiệp</td>
      <td>Quản lý nhóm, SSO, giám sát mức sử dụng</td>
      <td>Không có</td>
      <td>Chính sách IAM, CloudTrail</td>
      <td>Chính sách IAM, CloudTrail</td>
      <td>Vai trò IAM, Cloud Audit Logs</td>
      <td>Chính sách RBAC, Azure Monitor</td>
    </tr>
  </tbody>
</table>

Để xem bảng phân tích chi tiết từng tính năng có sẵn trên mỗi phương án, hãy tham khảo [Khả năng cung cấp tính năng](/en/feature-availability).

Chọn một phương án triển khai để xem hướng dẫn thiết lập:

* [Claude for Teams hoặc Enterprise](/en/authentication#claude-for-teams-or-enterprise)
* [Anthropic Console](/en/authentication#claude-console-authentication)
* [Claude apps gateway](/en/claude-apps-gateway), một gateway tự lưu trữ (self-hosted) bổ sung tính năng đăng nhập qua IdP đứng trước Amazon Bedrock, Claude Platform on AWS, Google Cloud's Agent Platform, Microsoft Foundry, hoặc Anthropic API
* [Amazon Bedrock](/en/amazon-bedrock)
* [Claude Platform on AWS](/en/claude-platform-on-aws)
* [Google Cloud's Agent Platform](/en/google-vertex-ai)
* [Microsoft Foundry](/en/microsoft-foundry)

## Cấu hình proxy và gateway

Hầu hết các tổ chức có thể sử dụng nhà cung cấp đám mây trực tiếp mà không cần cấu hình bổ sung. Tuy nhiên, bạn có thể cần cấu hình một corporate proxy (proxy doanh nghiệp) hoặc một LLM gateway nếu tổ chức của bạn có các yêu cầu cụ thể về mạng hoặc quản lý. Đây là hai cấu hình khác nhau và có thể sử dụng cùng nhau:

* **Corporate proxy (proxy doanh nghiệp)**: Định tuyến lưu lượng thông qua một proxy HTTP/HTTPS. Dùng khi tổ chức của bạn yêu cầu toàn bộ lưu lượng ra ngoài phải đi qua một máy chủ proxy để giám sát bảo mật, tuân thủ, hoặc thực thi chính sách mạng. Cấu hình bằng các biến môi trường `HTTPS_PROXY` hoặc `HTTP_PROXY`. Tìm hiểu thêm trong [Cấu hình mạng doanh nghiệp](/en/network-config).
* **LLM Gateway**: Một dịch vụ đứng giữa Claude Code và nhà cung cấp đám mây để xử lý việc xác thực và định tuyến. Dùng khi bạn cần theo dõi mức sử dụng tập trung giữa các nhóm, giới hạn tốc độ (rate limiting) hoặc ngân sách tùy chỉnh, hoặc quản lý xác thực tập trung. Cấu hình bằng các biến môi trường `ANTHROPIC_BASE_URL`, `ANTHROPIC_BEDROCK_BASE_URL`, `ANTHROPIC_AWS_BASE_URL`, hoặc `ANTHROPIC_VERTEX_BASE_URL`. Tìm hiểu thêm trong [LLM gateways](/en/llm-gateway).

Các ví dụ sau đây cho thấy những biến môi trường cần đặt trong shell hoặc trong profile shell của bạn (`.bashrc`, `.zshrc`). Xem [Settings](/en/settings) để biết các phương thức cấu hình khác.

### Amazon Bedrock

<Tabs>
  <Tab title="Corporate proxy">
    Định tuyến lưu lượng Amazon Bedrock qua corporate proxy của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Bedrock
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-east-1

    # Configure corporate proxy
    export HTTPS_PROXY='https://proxy.example.com:8080'
    ```
  </Tab>

  <Tab title="LLM Gateway">
    Định tuyến lưu lượng Amazon Bedrock qua LLM gateway của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Bedrock
    export CLAUDE_CODE_USE_BEDROCK=1

    # Configure LLM gateway
    export ANTHROPIC_BEDROCK_BASE_URL='https://your-llm-gateway.com/bedrock'
    export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1  # If gateway handles AWS auth
    ```
  </Tab>
</Tabs>

### Microsoft Foundry

<Tabs>
  <Tab title="Corporate proxy">
    Định tuyến lưu lượng Microsoft Foundry qua corporate proxy của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Microsoft Foundry
    export CLAUDE_CODE_USE_FOUNDRY=1
    export ANTHROPIC_FOUNDRY_RESOURCE=your-resource
    export ANTHROPIC_FOUNDRY_API_KEY=your-api-key  # Or omit for Entra ID auth

    # Configure corporate proxy
    export HTTPS_PROXY='https://proxy.example.com:8080'
    ```
  </Tab>

  <Tab title="LLM Gateway">
    Định tuyến lưu lượng Microsoft Foundry qua LLM gateway của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Microsoft Foundry
    export CLAUDE_CODE_USE_FOUNDRY=1

    # Configure LLM gateway
    export ANTHROPIC_FOUNDRY_BASE_URL='https://your-llm-gateway.com'
    export ANTHROPIC_FOUNDRY_API_KEY=your-gateway-key  # Sent as x-api-key
    ```
  </Tab>
</Tabs>

### Google Cloud's Agent Platform

<Tabs>
  <Tab title="Corporate proxy">
    Định tuyến lưu lượng Google Cloud's Agent Platform qua corporate proxy của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Agent Platform
    export CLAUDE_CODE_USE_VERTEX=1
    export CLOUD_ML_REGION=us-east5
    export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id

    # Configure corporate proxy
    export HTTPS_PROXY='https://proxy.example.com:8080'
    ```
  </Tab>

  <Tab title="LLM Gateway">
    Định tuyến lưu lượng Google Cloud's Agent Platform qua LLM gateway của bạn bằng cách đặt các [biến môi trường](/en/env-vars) sau:

    ```bash theme={null}
    # Enable Agent Platform
    export CLAUDE_CODE_USE_VERTEX=1

    # Configure LLM gateway
    export ANTHROPIC_VERTEX_BASE_URL='https://your-llm-gateway.com/vertex'
    export CLAUDE_CODE_SKIP_VERTEX_AUTH=1  # If gateway handles GCP auth
    export ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project-id
    export CLOUD_ML_REGION=us-east5
    ```
  </Tab>
</Tabs>

<Tip>
  Dùng `/status` trong Claude Code để xác minh cấu hình proxy và gateway của bạn đã được áp dụng đúng.
</Tip>

## Các thực hành tốt nhất cho tổ chức

### Đầu tư vào tài liệu và bộ nhớ (memory)

Chúng tôi đặc biệt khuyến nghị đầu tư vào tài liệu để Claude Code hiểu được codebase của bạn. Các tổ chức có thể triển khai tệp CLAUDE.md ở nhiều cấp độ:

* **Toàn tổ chức**: Triển khai vào các thư mục hệ thống như `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) để áp dụng chuẩn chung cho toàn công ty
* **Cấp kho lưu trữ (repository)**: Tạo các tệp `CLAUDE.md` ở thư mục gốc của kho, chứa kiến trúc dự án, các lệnh build, và hướng dẫn đóng góp. Đưa các tệp này vào hệ thống quản lý mã nguồn để tất cả người dùng đều hưởng lợi

Tìm hiểu thêm trong [Bộ nhớ và tệp CLAUDE.md](/en/memory).

### Đơn giản hóa việc triển khai

Nếu bạn có một môi trường phát triển tùy chỉnh, chúng tôi nhận thấy rằng việc tạo ra một cách cài đặt Claude Code "chỉ một cú nhấp" (one click) là yếu tố then chốt để mở rộng mức độ áp dụng trong toàn tổ chức.

### Bắt đầu với việc sử dụng có hướng dẫn

Khuyến khích người dùng mới thử Claude Code để hỏi đáp về codebase (codebase Q&A), hoặc cho các bản sửa lỗi nhỏ hoặc yêu cầu tính năng nhỏ. Hãy yêu cầu Claude Code lập một kế hoạch. Kiểm tra các đề xuất của Claude và đưa phản hồi nếu nó đi chệch hướng. Theo thời gian, khi người dùng hiểu rõ hơn về mô hình làm việc mới này, họ sẽ hiệu quả hơn trong việc để Claude Code hoạt động một cách tự chủ (agentically) nhiều hơn.

### Ghim (pin) phiên bản model cho các nhà cung cấp đám mây

Nếu bạn triển khai qua [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), [Microsoft Foundry](/en/microsoft-foundry), hoặc [Claude Platform on AWS](/en/claude-platform-on-aws), hãy ghim các phiên bản model cụ thể bằng cách dùng `ANTHROPIC_DEFAULT_FABLE_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, và `ANTHROPIC_DEFAULT_HAIKU_MODEL`. Nếu không ghim, các bí danh model (model alias) sẽ được phân giải về mặc định tích hợp sẵn của Claude Code cho nhà cung cấp đó, vốn có thể chậm hơn so với bản phát hành mới nhất và có thể chưa được bật trong tài khoản của bạn. Việc ghim cho phép bạn kiểm soát thời điểm người dùng chuyển sang một model mới. Xem [Cấu hình model](/en/model-config#pin-models-for-third-party-deployments) để biết mỗi nhà cung cấp làm gì khi model mặc định không khả dụng.

### Cấu hình chính sách bảo mật

Các nhóm bảo mật có thể cấu hình các quyền (permission) được quản lý để quy định những gì Claude Code được phép và không được phép làm, và những quyền này không thể bị ghi đè bởi cấu hình cục bộ. [Tìm hiểu thêm](/en/security).

### Tận dụng MCP cho việc tích hợp

MCP là một cách tuyệt vời để cung cấp thêm thông tin cho Claude Code, chẳng hạn như kết nối tới các hệ thống quản lý ticket hoặc nhật ký lỗi (error logs). Chúng tôi khuyến nghị một nhóm trung tâm cấu hình các máy chủ MCP và đưa tệp cấu hình `.mcp.json` vào codebase để tất cả người dùng đều hưởng lợi. [Tìm hiểu thêm](/en/mcp).

Tại Anthropic, chúng tôi tin dùng Claude Code để hỗ trợ phát triển trên mọi codebase của Anthropic. Chúng tôi hy vọng bạn sẽ thích dùng Claude Code nhiều như chúng tôi.

## Các bước tiếp theo

Sau khi bạn đã chọn một phương án triển khai và cấu hình quyền truy cập cho nhóm của mình:

1. **Triển khai cho nhóm của bạn**: Chia sẻ hướng dẫn cài đặt và để các thành viên nhóm [cài đặt Claude Code](/en/setup) rồi xác thực bằng thông tin đăng nhập của họ.
2. **Thiết lập cấu hình dùng chung**: Tạo một [tệp CLAUDE.md](/en/memory) trong các kho lưu trữ của bạn để giúp Claude Code hiểu codebase và các chuẩn viết mã của bạn.
3. **Cấu hình quyền (permissions)**: Xem lại [thiết lập bảo mật](/en/security) để định nghĩa những gì Claude Code có thể và không thể làm trong môi trường của bạn.
