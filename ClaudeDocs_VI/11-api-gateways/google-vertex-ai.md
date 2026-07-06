> Nguồn: https://code.claude.com/docs/en/google-vertex-ai.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Claude Code trên Google Cloud's Agent Platform

> Tìm hiểu cách cấu hình Claude Code thông qua Google Cloud's Agent Platform, trước đây là Vertex AI, bao gồm cài đặt, cấu hình IAM và xử lý sự cố.

## Yêu cầu tiên quyết

Trước khi cấu hình Claude Code với Google Cloud's Agent Platform, trước đây là Vertex AI, hãy đảm bảo bạn có:

* Một tài khoản Google Cloud Platform (GCP) đã bật thanh toán (billing)
* Một dự án GCP đã bật Google Cloud's Agent Platform API
* Quyền truy cập vào các model Claude mong muốn (ví dụ Claude Sonnet 4.6)
* Google Cloud SDK (`gcloud`) đã được cài đặt và cấu hình
* Quota được cấp phát ở region GCP mong muốn

Để đăng nhập bằng thông tin xác thực Google Cloud's Agent Platform của riêng bạn, hãy làm theo [Đăng nhập với Google Cloud's Agent Platform](#sign-in-with-agent-platform) bên dưới. Để triển khai Claude Code cho cả một nhóm, hãy dùng các bước [cài đặt thủ công](#set-up-manually) và [ghim phiên bản model của bạn](#5-pin-model-versions) trước khi phát hành rộng rãi.

## Đăng nhập với Agent Platform

Nếu bạn có thông tin xác thực Google Cloud và muốn bắt đầu sử dụng Claude Code qua Google Cloud's Agent Platform, trình hướng dẫn đăng nhập sẽ dẫn bạn qua từng bước. Bạn hoàn tất các yêu cầu tiên quyết phía GCP một lần cho mỗi dự án; trình hướng dẫn xử lý phần phía Claude Code.

<Note>
  Trình hướng dẫn cài đặt Google Cloud's Agent Platform yêu cầu Claude Code v2.1.98 trở lên. Chạy `claude --version` để kiểm tra.
</Note>

<Steps>
  <Step title="Bật các model Claude trong dự án GCP của bạn">
    [Bật Google Cloud's Agent Platform API](#1-enable-agent-platform-api) cho dự án của bạn, rồi yêu cầu quyền truy cập các model Claude bạn muốn trong [Google Cloud's Agent Platform Model Garden](https://console.cloud.google.com/vertex-ai/model-garden). Xem [Cấu hình IAM](#iam-configuration) để biết các quyền mà tài khoản của bạn cần.
  </Step>

  <Step title="Khởi động Claude Code và chọn Google Cloud's Agent Platform">
    Chạy `claude`. Tại lời nhắc đăng nhập, chọn **3rd-party platform**, sau đó **Google Vertex AI**, nhãn mà lời nhắc đăng nhập vẫn dùng cho Google Cloud's Agent Platform.
  </Step>

  <Step title="Làm theo các lời nhắc của trình hướng dẫn">
    Chọn cách bạn xác thực với Google Cloud: Application Default Credentials từ `gcloud`, một file khóa service account, hoặc thông tin xác thực đã có sẵn trong môi trường. Trình hướng dẫn phát hiện dự án và region của bạn, xác minh những model Claude nào dự án của bạn có thể gọi, và cho phép bạn ghim chúng. Nó lưu kết quả vào khối `env` trong [file user settings của bạn](/en/settings), nên bạn không cần tự export biến môi trường.
  </Step>
</Steps>

Sau khi đã đăng nhập, chạy `/setup-vertex` bất cứ lúc nào để mở lại trình hướng dẫn và thay đổi thông tin xác thực, dự án, region hoặc các ghim model của bạn.

## Cấu hình region

Claude Code hỗ trợ các endpoint [global](https://cloud.google.com/blog/products/ai-machine-learning/global-endpoint-for-claude-models-generally-available-on-vertex-ai), đa vùng (multi-region), và theo vùng (regional) của Google Cloud's Agent Platform. Thiết lập `CLOUD_ML_REGION` thành `global`, một vị trí đa vùng như `eu` hoặc `us`, hoặc một region cụ thể như `us-east5`. Claude Code chọn đúng hostname Google Cloud's Agent Platform cho mỗi dạng, bao gồm các host `aiplatform.eu.rep.googleapis.com` và `aiplatform.us.rep.googleapis.com` cho các vị trí đa vùng.

<Note>
  Google Cloud's Agent Platform có thể không hỗ trợ các model mặc định của Claude Code trên mọi loại endpoint. Tính khả dụng của model thay đổi giữa [các region cụ thể](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/locations#genai-partner-models), các vị trí đa vùng, và [các endpoint global](https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/use-partner-models#supported_models). Bạn có thể cần chuyển sang một vị trí được hỗ trợ hoặc chỉ định một model được hỗ trợ.
</Note>

## Cài đặt thủ công

Để cấu hình Google Cloud's Agent Platform thông qua biến môi trường thay vì trình hướng dẫn, chẳng hạn trong CI hoặc một đợt phát hành doanh nghiệp có kịch bản, hãy làm theo các bước bên dưới.

### 1. Bật Agent Platform API

Bật Google Cloud's Agent Platform API trong dự án GCP của bạn:

```bash theme={null}
# Thiết lập project ID của bạn
gcloud config set project YOUR-PROJECT-ID

# Bật Agent Platform API
gcloud services enable aiplatform.googleapis.com
```

### 2. Yêu cầu quyền truy cập model

Yêu cầu quyền truy cập các model Claude trong Google Cloud's Agent Platform:

1. Điều hướng tới [Google Cloud's Agent Platform Model Garden](https://console.cloud.google.com/vertex-ai/model-garden)
2. Tìm kiếm các model "Claude"
3. Yêu cầu quyền truy cập các model Claude mong muốn (ví dụ Claude Sonnet 4.6)
4. Chờ phê duyệt (có thể mất 24-48 giờ)

### 3. Cấu hình thông tin xác thực GCP

Claude Code dùng cơ chế xác thực Google Cloud tiêu chuẩn.

Để biết thêm, xem [tài liệu xác thực Google Cloud](https://cloud.google.com/docs/authentication).

Claude Code v2.1.121 trở lên hỗ trợ [Workload Identity Federation dựa trên chứng chỉ X.509](https://cloud.google.com/iam/docs/workload-identity-federation-with-x509-certificates) thông qua cùng chuỗi Application Default Credentials. Thiết lập `GOOGLE_APPLICATION_CREDENTIALS` thành đường dẫn tới file cấu hình thông tin xác thực của bạn.

<Note>
  Claude Code dùng `ANTHROPIC_VERTEX_PROJECT_ID` làm project ID cho các yêu cầu Google Cloud's Agent Platform. Các biến môi trường `GCLOUD_PROJECT` và `GOOGLE_CLOUD_PROJECT` cùng file thông tin xác thực được tham chiếu bởi `GOOGLE_APPLICATION_CREDENTIALS` được ưu tiên hơn nó. Nếu không có biến nào trong số này được thiết lập, project ID được phân giải từ cấu hình `gcloud` của bạn hoặc service account được gắn kèm.
</Note>

#### Cấu hình thông tin xác thực nâng cao

Claude Code hỗ trợ tự động làm mới thông tin xác thực cho GCP thông qua thiết lập `gcpAuthRefresh`. Khi Claude Code phát hiện thông tin xác thực GCP của bạn đã hết hạn hoặc không thể tải, nó chạy lệnh đã cấu hình để lấy thông tin xác thực mới trước khi thử lại yêu cầu.

```json theme={null}
{
  "gcpAuthRefresh": "gcloud auth application-default login",
  "env": {
    "ANTHROPIC_VERTEX_PROJECT_ID": "your-project-id"
  }
}
```

Đầu ra của lệnh được hiển thị cho người dùng, nhưng không hỗ trợ nhập liệu tương tác. Cách này phù hợp với các luồng xác thực dựa trên trình duyệt, nơi CLI hiển thị một URL và bạn hoàn tất xác thực trong trình duyệt. Lệnh làm mới hết thời gian sau ba phút nếu việc xác thực không hoàn tất. Nếu bạn thiết lập `gcpAuthRefresh` trong project settings như `.claude/settings.json`, lệnh chỉ chạy sau khi bạn chấp nhận lời nhắc tin cậy workspace (workspace trust prompt).

### 4. Cấu hình Claude Code

Thiết lập các biến môi trường sau:

```bash theme={null}
# Bật tích hợp Agent Platform
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID

# Tùy chọn: Ghi đè URL endpoint của Agent Platform cho các endpoint tùy chỉnh hoặc gateway
# export ANTHROPIC_VERTEX_BASE_URL=https://aiplatform.googleapis.com

# Tùy chọn: Tắt prompt caching nếu cần
export DISABLE_PROMPT_CACHING=1

# Tùy chọn: Yêu cầu TTL prompt cache 1 giờ thay vì mặc định 5 phút
export ENABLE_PROMPT_CACHING_1H=1

# Khi CLOUD_ML_REGION=global, ghi đè region cho các model không hỗ trợ endpoint global
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

Hầu hết các phiên bản model đều có một biến `VERTEX_REGION_CLAUDE_*` tương ứng. Xem [Tài liệu tham chiếu biến môi trường](/en/env-vars) để có danh sách đầy đủ. Kiểm tra [Google Cloud's Agent Platform Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) để xác định model nào hỗ trợ endpoint global và model nào chỉ hỗ trợ theo vùng.

[Prompt caching](/en/prompt-caching) được bật tự động. Để tắt nó, thiết lập `DISABLE_PROMPT_CACHING=1`. Để yêu cầu TTL cache 1 giờ thay vì mặc định 5 phút, thiết lập `ENABLE_PROMPT_CACHING_1H=1`; các lần ghi cache với TTL 1 giờ được tính phí ở mức cao hơn. Để có giới hạn tần suất (rate limit) cao hơn, liên hệ hỗ trợ Google Cloud. Khi dùng Google Cloud's Agent Platform, lệnh `/logout` không khả dụng vì việc xác thực được xử lý qua thông tin xác thực Google Cloud.

Claude Code tắt [MCP tool search](/en/mcp#scale-with-mcp-tool-search) theo mặc định trên Google Cloud's Agent Platform, nên các định nghĩa công cụ MCP được tải trước (upfront). Google Cloud's Agent Platform hỗ trợ tool search cho Claude Sonnet 4.5 trở lên và Claude Opus 4.5 trở lên. Thiết lập `ENABLE_TOOL_SEARCH=true` để bật nó trên các model đó. Các model cũ hơn trên Google Cloud's Agent Platform không chấp nhận header beta cần thiết, và các yêu cầu sẽ thất bại nếu bạn bật tool search với chúng.

### 5. Ghim phiên bản model

<Warning>
  Ghim phiên bản model cụ thể khi triển khai cho nhiều người dùng. Nếu không ghim, các alias model như `sonnet` và `opus` sẽ phân giải về giá trị mặc định tích hợp sẵn của Claude Code cho Google Cloud's Agent Platform, vốn có thể chậm hơn bản phát hành mới nhất và có thể chưa được bật trong dự án của bạn. Claude Code [dự phòng](#startup-model-checks) về phiên bản trước đó khi khởi động nếu bản mặc định không khả dụng, nhưng việc ghim cho phép bạn kiểm soát thời điểm người dùng chuyển sang model mới.
</Warning>

Thiết lập các biến môi trường này tới các ID model Google Cloud's Agent Platform cụ thể.

Nếu không có `ANTHROPIC_DEFAULT_OPUS_MODEL`, alias `opus` trên Google Cloud's Agent Platform phân giải về Opus 4.6. Thiết lập nó tới ID của Opus 4.8 để dùng model mới nhất:

```bash theme={null}
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-5'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

Để biết ID model hiện tại và cũ, xem [Tổng quan model](https://platform.claude.com/docs/en/about-claude/models/overview). Xem [Cấu hình model](/en/model-config#pin-models-for-third-party-deployments) để có danh sách đầy đủ các biến môi trường.

Claude Code sử dụng các model mặc định này khi không thiết lập biến ghim nào:

| Loại model       | Giá trị mặc định             |
| :--------------- | :--------------------------- |
| Model chính      | `claude-sonnet-4-5@20250929` |
| Model nhỏ/nhanh  | Giống với model chính        |

Các tác vụ nền như tạo tiêu đề phiên sử dụng model nhỏ/nhanh, thường là một model dạng Haiku. Trên Google Cloud's Agent Platform, Claude Code đặt mặc định model này về model chính vì Haiku có thể chưa được bật trong mọi dự án hoặc region. Để dùng Haiku cho các tác vụ nền, thiết lập `ANTHROPIC_DEFAULT_HAIKU_MODEL` tới một ID model có sẵn trong dự án của bạn.

Để tùy chỉnh model sâu hơn:

```bash theme={null}
export ANTHROPIC_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

## Kiểm tra model lúc khởi động

Khi Claude Code khởi động với Google Cloud's Agent Platform đã được cấu hình, nó xác minh rằng các model mà nó dự định sử dụng có thể truy cập được trong dự án của bạn. Việc kiểm tra này yêu cầu Claude Code v2.1.98 trở lên.

Nếu bạn đã ghim một phiên bản model cũ hơn bản mặc định hiện tại của Claude Code, và dự án của bạn có thể gọi phiên bản mới hơn, Claude Code sẽ nhắc bạn cập nhật ghim. Chấp nhận sẽ ghi ID model mới vào [file user settings của bạn](/en/settings) và khởi động lại Claude Code. Việc từ chối được ghi nhớ cho tới lần thay đổi phiên bản mặc định tiếp theo.

Nếu bạn chưa ghim một model và bản mặc định hiện tại không khả dụng trong dự án của bạn, Claude Code dự phòng về phiên bản trước đó cho phiên hiện tại và hiển thị thông báo. Việc dự phòng không được lưu lại. Bật model mới hơn trong [Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) hoặc [ghim một phiên bản](#5-pin-model-versions) để lựa chọn trở nên vĩnh viễn.

## Cấu hình IAM

Gán các quyền IAM cần thiết:

Role `roles/aiplatform.user` bao gồm các quyền cần thiết:

* `aiplatform.endpoints.predict` - Bắt buộc cho việc gọi model và đếm token

Để có quyền hạn chế hơn, tạo một custom role chỉ với các quyền ở trên.

Để biết chi tiết, xem [tài liệu IAM của Google Cloud's Agent Platform](https://cloud.google.com/vertex-ai/docs/general/access-control).

<Note>
  Tạo một dự án GCP riêng cho Claude Code để đơn giản hóa việc theo dõi chi phí và kiểm soát truy cập.
</Note>

## Cửa sổ ngữ cảnh 1M token

Claude Sonnet 5, Opus 4.6 trở lên, và Sonnet 4.6 hỗ trợ [cửa sổ ngữ cảnh 1M token](https://platform.claude.com/docs/en/build-with-claude/context-windows#1m-token-context-window) trên Google Cloud's Agent Platform. Sonnet 5 luôn chạy với cửa sổ 1M, không có biến thể `[1m]` để chọn. Đối với các model còn lại, Claude Code tự động bật cửa sổ ngữ cảnh mở rộng khi bạn chọn một biến thể model 1M.

[Trình hướng dẫn cài đặt](#sign-in-with-agent-platform) cung cấp tùy chọn ngữ cảnh 1M khi nó ghim model. Để bật nó cho một model được ghim thủ công, hãy thêm `[1m]` vào cuối ID model. Xem [Ghim model cho triển khai bên thứ ba](/en/model-config#pin-models-for-third-party-deployments) để biết chi tiết.

## Xử lý sự cố

Nếu bạn gặp lỗi "Could not load the default credentials":

* Chạy `gcloud auth application-default login` để thiết lập Application Default Credentials
* Thiết lập `GOOGLE_APPLICATION_CREDENTIALS` thành đường dẫn file khóa service account
* Xem [Cấu hình thông tin xác thực GCP](#3-configure-gcp-credentials) để biết tất cả các tùy chọn

Nếu bạn gặp vấn đề về quota:

* Kiểm tra quota hiện tại hoặc yêu cầu tăng quota thông qua [Cloud Console](https://cloud.google.com/docs/quotas/view-manage)

Nếu bạn gặp lỗi 404 "model not found":

* Xác nhận model đã được Bật (Enabled) trong [Model Garden](https://console.cloud.google.com/vertex-ai/model-garden)
* Xác minh model khả dụng ở vị trí bạn đã chỉ định. Một số model chỉ được cung cấp trên các vị trí `global` hoặc đa vùng như `eu` và `us`, không có ở các region cụ thể
* Nếu dùng `CLOUD_ML_REGION=global`, kiểm tra rằng các model của bạn hỗ trợ endpoint global trong [Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) tại mục "Supported features". Đối với các model không hỗ trợ endpoint global, hãy làm một trong hai:
  * Chỉ định một model được hỗ trợ qua `ANTHROPIC_MODEL` hoặc `ANTHROPIC_DEFAULT_HAIKU_MODEL`, hoặc
  * Thiết lập một region hoặc vị trí đa vùng bằng các biến môi trường `VERTEX_REGION_<MODEL_NAME>`

Nếu bạn gặp lỗi 429:

* Đối với các endpoint theo vùng, đảm bảo model chính và model nhỏ/nhanh được hỗ trợ trong region bạn đã chọn
* Cân nhắc chuyển sang `CLOUD_ML_REGION=global` để có tính khả dụng tốt hơn

## Tài nguyên bổ sung

* [Tài liệu Google Cloud's Agent Platform](https://cloud.google.com/vertex-ai/docs)
* [Giá Google Cloud's Agent Platform](https://cloud.google.com/vertex-ai/pricing)
* [Quota và giới hạn của Google Cloud's Agent Platform](https://cloud.google.com/vertex-ai/docs/quotas)
