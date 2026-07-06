> Nguồn: https://code.claude.com/docs/en/microsoft-foundry.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Claude Code trên Microsoft Foundry

> Tìm hiểu cách cấu hình Claude Code thông qua Microsoft Foundry, bao gồm cài đặt, cấu hình và xử lý sự cố.

## Yêu cầu tiên quyết

Trước khi cấu hình Claude Code với Microsoft Foundry, hãy đảm bảo bạn có:

* Một đăng ký (subscription) Azure có quyền truy cập Microsoft Foundry
* Quyền RBAC để tạo các tài nguyên và triển khai Microsoft Foundry
* Azure CLI đã được cài đặt và cấu hình (không bắt buộc — chỉ cần khi bạn không có cơ chế nào khác để lấy thông tin xác thực)

<Note>
  Nếu bạn triển khai Claude Code cho nhiều người dùng, hãy [ghim phiên bản model của bạn](#4-pin-model-versions) trước khi phát hành rộng rãi.
</Note>

## Cài đặt

### 1. Cấp phát tài nguyên Microsoft Foundry

Trước tiên, tạo một tài nguyên Claude trong Azure:

1. Điều hướng tới [Microsoft Foundry portal](https://ai.azure.com/)
2. Tạo một tài nguyên mới, ghi lại tên tài nguyên của bạn
3. Tạo các triển khai (deployment) cho các model Claude:
   * Claude Opus
   * Claude Sonnet
   * Claude Haiku

### 2. Cấu hình thông tin xác thực Azure

Claude Code hỗ trợ hai phương thức xác thực cho Microsoft Foundry. Chọn phương thức phù hợp nhất với yêu cầu bảo mật của bạn.

**Phương án A: Xác thực bằng API key**

1. Điều hướng tới tài nguyên của bạn trong Microsoft Foundry portal
2. Vào mục **Endpoints and keys**
3. Sao chép **API Key**
4. Thiết lập biến môi trường:

```bash theme={null}
export ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key
```

**Phương án B: Xác thực bằng Microsoft Entra ID**

Khi `ANTHROPIC_FOUNDRY_API_KEY` không được thiết lập, Claude Code tự động dùng [chuỗi thông tin xác thực mặc định](https://learn.microsoft.com/en-us/azure/developer/javascript/sdk/authentication/credential-chains#defaultazurecredential-overview) của Azure SDK.
Cơ chế này hỗ trợ nhiều phương pháp để xác thực các workload cục bộ và từ xa.

Trên các môi trường cục bộ, bạn thường có thể dùng Azure CLI:

```bash theme={null}
az login
```

<Note>
  Khi dùng Microsoft Foundry, lệnh `/logout` không khả dụng vì việc xác thực được xử lý qua thông tin xác thực Azure.
</Note>

### 3. Cấu hình Claude Code

Thiết lập các biến môi trường sau để bật Microsoft Foundry:

```bash theme={null}
# Bật tích hợp Microsoft Foundry
export CLAUDE_CODE_USE_FOUNDRY=1

# Tên tài nguyên Azure (thay {resource} bằng tên tài nguyên của bạn)
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# Hoặc cung cấp base URL đầy đủ:
# export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

### 4. Ghim phiên bản model

<Warning>
  Ghim phiên bản model cụ thể cho mọi triển khai. Nếu không ghim, các alias model như `sonnet` và `opus` sẽ phân giải về giá trị mặc định tích hợp sẵn của Claude Code cho Microsoft Foundry, vốn có thể chậm hơn bản phát hành mới nhất và có thể chưa khả dụng trong tài khoản của bạn. Microsoft Foundry không có kiểm tra model lúc khởi động, nên các yêu cầu sẽ thất bại khi bản mặc định không khả dụng. Khi bạn tạo các triển khai Azure, hãy chọn một phiên bản model cụ thể thay vì "auto-update to latest."
</Warning>

Thiết lập các biến model để khớp với tên triển khai bạn đã tạo ở bước 1.

Nếu không có `ANTHROPIC_DEFAULT_OPUS_MODEL`, alias `opus` trên Microsoft Foundry phân giải về Opus 4.6. Thiết lập nó tới ID của Opus 4.8 để dùng model mới nhất:

```bash theme={null}
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-5'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

Các tác vụ nền như tạo tiêu đề phiên sử dụng model nhỏ/nhanh, thường là một model dạng Haiku. Trên Microsoft Foundry, Claude Code đặt mặc định model này về model chính vì không phải mọi tài khoản đều có triển khai Haiku. Để dùng Haiku cho các tác vụ nền, thiết lập `ANTHROPIC_DEFAULT_HAIKU_MODEL` tới một triển khai Haiku có sẵn trong tài khoản của bạn, như minh họa ở trên.

Để biết ID model hiện tại và cũ, xem [Tổng quan model](https://platform.claude.com/docs/en/about-claude/models/overview). Xem [Cấu hình model](/en/model-config#pin-models-for-third-party-deployments) để có danh sách đầy đủ các biến môi trường.

[Prompt caching](/en/prompt-caching) được bật tự động. Để yêu cầu TTL cache 1 giờ thay vì mặc định 5 phút, thiết lập biến sau; các lần ghi cache với TTL 1 giờ được tính phí ở mức cao hơn:

```bash theme={null}
export ENABLE_PROMPT_CACHING_1H=1
```

### 5. Chạy Claude Code

Với các biến môi trường đã được thiết lập, khởi động Claude Code từ thư mục dự án của bạn:

```bash theme={null}
claude
```

Claude Code đọc `CLAUDE_CODE_USE_FOUNDRY` và các biến Microsoft Foundry khác từ môi trường và kết nối tới tài nguyên Azure của bạn ở lời nhắc (prompt) đầu tiên. Không giống Amazon Bedrock và Google Cloud's Agent Platform, Microsoft Foundry không có trình hướng dẫn cài đặt tương tác, nên các biến môi trường ở bước 3 và 4 là con đường cấu hình duy nhất.

## Cấu hình Azure RBAC

Các role mặc định `Azure AI User` và `Cognitive Services User` bao gồm tất cả các quyền cần thiết để gọi các model Claude.

Để có quyền hạn chế hơn, tạo một custom role với nội dung sau:

```json theme={null}
{
  "permissions": [
    {
      "dataActions": [
        "Microsoft.CognitiveServices/accounts/providers/*"
      ]
    }
  ]
}
```

Để biết chi tiết, xem [tài liệu RBAC của Microsoft Foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/concepts/rbac-azure-ai-foundry).

## Xử lý sự cố

Nếu bạn nhận được lỗi "Failed to get token from azureADTokenProvider: ChainedTokenCredential authentication failed":

* Cấu hình Entra ID trên môi trường, hoặc thiết lập `ANTHROPIC_FOUNDRY_API_KEY`.

## Tài nguyên bổ sung

* [Tài liệu Microsoft Foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/what-is-azure-ai-foundry)
* [Các model Microsoft Foundry](https://ai.azure.com/explore/models)
* [Giá Microsoft Foundry](https://azure.microsoft.com/en-us/pricing/details/ai-foundry/)
