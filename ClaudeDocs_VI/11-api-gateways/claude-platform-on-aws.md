> Nguồn: https://code.claude.com/docs/en/claude-platform-on-aws.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Claude Code trên Claude Platform on AWS

> Cấu hình Claude Code để sử dụng Claude API do Anthropic vận hành với xác thực AWS, kiểm soát truy cập IAM, và thanh toán qua AWS Marketplace.

Claude Platform on AWS là Claude API do Anthropic vận hành với xác thực AWS, kiểm soát truy cập IAM, và thanh toán qua AWS Marketplace. Các yêu cầu đi thẳng tới API của Anthropic, nên bạn có được cùng các model và tính năng như [Claude API](https://platform.claude.com/docs) trên cùng lịch phát hành. Bạn xác thực bằng thông tin xác thực AWS hoặc một workspace API key, và thanh toán qua AWS Marketplace.

Dùng hướng dẫn này để trỏ Claude Code tới một workspace mà bạn đã cấp phát qua Claude Platform on AWS. Đối với phần đăng ký AWS và cài đặt workspace diễn ra trước bước này, xem [tài liệu Claude Platform on AWS](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws).

<Note>
  Việc đăng ký qua AWS Marketplace sẽ cấp phát một tổ chức Anthropic mới gắn với tài khoản AWS của bạn. Tổ chức này tách biệt với bất kỳ tổ chức nào bạn đã có với Anthropic, và thông tin xác thực không chuyển giao giữa chúng. Dùng workspace ID và API keys từ tổ chức gắn với AWS, không phải từ tài khoản Claude Console đã có sẵn.
</Note>

## Yêu cầu tiên quyết

Trước khi cấu hình Claude Code, bạn cần:

* Một đăng ký Claude Platform on AWS đang hoạt động thông qua AWS Marketplace
* Một workspace trong tổ chức Anthropic gắn với AWS của bạn, cùng với workspace ID của nó
* Một IAM principal có quyền gọi dịch vụ Anthropic, hoặc một API key được giới hạn phạm vi trong workspace
* Thông tin xác thực AWS trong môi trường của bạn, trong `~/.aws/credentials`, hoặc từ một IAM role được gắn kèm nếu bạn muốn xác thực SigV4. AWS CLI chỉ bắt buộc cho luồng đăng nhập SSO.

## Cài đặt

### 1. Cấu hình thông tin xác thực AWS

Claude Code hỗ trợ hai phương thức xác thực cho Claude Platform on AWS. Chọn phương thức phù hợp với cách nhóm của bạn quản lý truy cập.

**Phương án A: Thông tin xác thực AWS với SigV4**

Claude Code ký các yêu cầu bằng SigV4 sử dụng chuỗi thông tin xác thực AWS tiêu chuẩn: biến môi trường, thông tin xác thực chia sẻ trong `~/.aws/credentials`, IAM roles, phiên AWS SSO, và bất kỳ nguồn nào khác mà AWS SDK hỗ trợ.

Để dùng cục bộ, đăng nhập bằng AWS CLI trước khi khởi động Claude Code. Ví dụ dưới đây dùng một SSO profile, nhưng bất kỳ phương pháp nào tạo ra thông tin xác thực ở các vị trí tiêu chuẩn đều hoạt động.

```bash theme={null}
aws sso login --profile my-profile
export AWS_PROFILE=my-profile
```

Đối với CI và tự động hóa, hãy cấp cho runner một IAM role có quyền gọi dịch vụ Anthropic và thiết lập `AWS_REGION`. Chuỗi thông tin xác thực tự động nhận role đó.

Nếu thông tin xác thực SSO của bạn hết hạn giữa phiên, hãy cấu hình [`awsAuthRefresh`](/en/amazon-bedrock#advanced-credential-configuration) để Claude Code chạy lại lệnh đăng nhập của bạn và thử lại thay vì thất bại. Tự động làm mới trên Claude Platform on AWS yêu cầu Claude Code v2.1.198 trở lên; các phiên bản cũ hơn dừng lại với lời nhắc chạy `/login`, vốn không thể làm mới thông tin xác thực AWS. Thêm lệnh vào `settings.json` của bạn:

```json theme={null}
{
  "awsAuthRefresh": "aws sso login --profile my-profile"
}
```

Khi `awsAuthRefresh` được cấu hình, `/login` hiển thị tùy chọn **Claude Platform on AWS · refresh credentials** bên dưới **Using 3rd-party platforms**. Chọn nó sẽ chạy lệnh đã cấu hình và đọc lại thông tin xác thực AWS của bạn mà không cần khởi động lại Claude Code.

**Phương án B: Workspace API key**

Một workspace API key là một bí mật tồn tại lâu dài, hữu ích khi bạn không muốn quản lý thông tin xác thực AWS federated. Tạo một key trong AWS Console tại **Claude Platform on AWS → API keys** và thiết lập nó thành `ANTHROPIC_AWS_API_KEY`:

```bash theme={null}
export ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx
```

Key được gửi dưới dạng `x-api-key` và được ưu tiên hơn SigV4, nên mọi thông tin xác thực AWS trong môi trường của bạn đều bị bỏ qua. Các API key từ một tổ chức Claude Console riêng biệt sẽ không hoạt động ở đây.

Đối xử với workspace API key như bất kỳ thông tin xác thực production nào khác. Khối `env` của [file user settings](/en/settings) là một cách tiện lợi để giới hạn phạm vi key vào máy của bạn mà không export nó ra toàn cục.

<Note>
  Các lệnh `/login` và `/logout` không đăng nhập bạn vào một đăng ký Claude.ai đối với Claude Platform on AWS. Việc xác thực chạy qua thông tin xác thực AWS hoặc workspace API key của bạn. Ngoại lệ là tùy chọn **refresh credentials** mà `/login` hiển thị khi `awsAuthRefresh` được cấu hình, vốn đọc lại thông tin xác thực AWS của bạn như mô tả ở trên.
</Note>

### 2. Cấu hình Claude Code

Thiết lập các biến môi trường để định tuyến Claude Code qua Claude Platform on AWS thay vì Anthropic API mặc định.

```bash theme={null}
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
```

`ANTHROPIC_AWS_WORKSPACE_ID` là bắt buộc và được gửi trên mỗi yêu cầu dưới dạng header `anthropic-workspace-id`. Base URL được tính từ `AWS_REGION` là `https://aws-external-anthropic.{region}.api.aws`. Để ghi đè URL trực tiếp, thiết lập `ANTHROPIC_AWS_BASE_URL`.

Claude Platform on AWS là tùy chọn bật (opt-in) ngay cả khi thông tin xác thực AWS có sẵn trong môi trường của bạn. Amazon Bedrock và Microsoft Foundry được ưu tiên trong việc định tuyến provider, nên hãy bỏ thiết lập `CLAUDE_CODE_USE_BEDROCK` và `CLAUDE_CODE_USE_FOUNDRY` nếu chúng đang được thiết lập.

### 3. Ghim phiên bản model

Claude Platform on AWS dùng cùng các ID model như Claude API trực tiếp. Các alias mặc định `fable`, `opus`, `sonnet`, và `haiku` phân giải về các giá trị mặc định tích hợp sẵn của Claude Code cho Claude Platform on AWS, vốn có thể chậm hơn bản phát hành mới nhất. Nếu không có `ANTHROPIC_DEFAULT_OPUS_MODEL`, alias `opus` phân giải về Opus 4.7.

Nếu bạn triển khai Claude Code cho cả một nhóm, hãy ghim các ID model một cách rõ ràng để một bản phát hành mới không di chuyển tất cả mọi người cùng một lúc:

```bash theme={null}
export ANTHROPIC_DEFAULT_FABLE_MODEL=claude-fable-5
export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-7
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-5
export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5
```

Để có danh sách đầy đủ ID model và alias, xem [Tổng quan model](https://platform.claude.com/docs/en/about-claude/models/overview). Đối với các biến liên quan đến model khác, xem [Cấu hình model](/en/model-config).

[Prompt caching](/en/prompt-caching) được bật tự động. Để yêu cầu TTL cache 1 giờ thay vì mặc định 5 phút, thiết lập `ENABLE_PROMPT_CACHING_1H=1`. API tính phí ghi cache 1 giờ ở mức cao hơn. Xem [giá prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching#pricing) để biết các mức giá.

## Sử dụng Agent SDK

[Agent SDK](/en/agent-sdk/overview) đọc cùng các biến môi trường như CLI, nên bất kỳ chương trình nào sinh ra tiến trình con (subprocess) Claude Code đều có thể nhắm tới Claude Platform on AWS bằng cách export `CLAUDE_CODE_USE_ANTHROPIC_AWS`, `ANTHROPIC_AWS_WORKSPACE_ID`, và một trong hai `ANTHROPIC_AWS_API_KEY` hoặc thông tin xác thực AWS trước lời gọi.

```typescript theme={null}
import { query } from "@anthropic-ai/claude-agent-sdk";

process.env.CLAUDE_CODE_USE_ANTHROPIC_AWS = "1";
process.env.ANTHROPIC_AWS_WORKSPACE_ID = "wrkspc_01ABCDEFGHIJKLMN";
process.env.AWS_REGION = "us-east-1";

for await (const msg of query({ prompt: "What's in this repo?" })) {
  console.log(msg);
}
```

Ví dụ này dựa vào chuỗi thông tin xác thực AWS có sẵn trong môi trường cho SigV4. Để xác thực bằng một workspace API key thay thế, thiết lập `ANTHROPIC_AWS_API_KEY` theo cùng cách. Để biết toàn bộ bề mặt của Agent SDK, xem [Tổng quan Agent SDK](/en/agent-sdk/overview).

## Định tuyến qua proxy doanh nghiệp

Để định tuyến lưu lượng qua một proxy hoặc [LLM gateway](/en/llm-gateway), thiết lập `ANTHROPIC_AWS_BASE_URL` thành địa chỉ của proxy. Claude Code gửi các yêu cầu tới URL đó với cùng các header workspace và xác thực, nên bất kỳ gateway nào chuyển tiếp chúng nguyên trạng đều hoạt động.

```bash theme={null}
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export ANTHROPIC_AWS_BASE_URL=https://anthropic-proxy.example.com
```

Nếu gateway của bạn tự ký các yêu cầu, thiết lập `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` để Claude Code gửi các yêu cầu chưa ký và để gateway thêm các header SigV4 trước khi chuyển tiếp tới AWS. Nếu gateway yêu cầu token riêng của nó, thiết lập nó trong `ANTHROPIC_AUTH_TOKEN`.

```bash theme={null}
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export ANTHROPIC_AWS_BASE_URL=https://anthropic-proxy.example.com
```

## Xử lý sự cố

Chạy `/status` để xem provider đã được phân giải cùng với bất kỳ workspace ID, region, ghi đè base URL, và thiết lập bỏ qua xác thực (auth-skip) nào được cấu hình rõ ràng. Đây là cách nhanh nhất để xác nhận Claude Code đang nhắm tới Claude Platform on AWS hay không.

### `403 Forbidden` hoặc `AccessDenied` trên mọi yêu cầu

IAM principal mà Claude Code đã phân giải có khả năng thiếu quyền gọi dịch vụ Anthropic trong workspace của bạn. Kiểm tra role được gắn với AWS profile của bạn hoặc runner đã khởi động Claude Code, và xác minh nó có các action `aws-external-anthropic` được ghi trong [tài liệu tham chiếu IAM action](https://platform.claude.com/docs/en/api/claude-platform-on-aws-iam-actions).

Nếu bạn thiết lập `ANTHROPIC_AWS_API_KEY`, key được ưu tiên hơn SigV4 và một key cũ (stale) sẽ tạo ra cùng lỗi. Tạo lại key trong AWS Console tại **Claude Platform on AWS → API keys** hoặc bỏ thiết lập biến để dự phòng về thông tin xác thực AWS của bạn.

### Các yêu cầu thất bại với lỗi thiếu workspace

`ANTHROPIC_AWS_WORKSPACE_ID` có khả năng chưa được thiết lập hoặc rỗng. Mỗi yêu cầu Claude Platform on AWS phải bao gồm workspace ID. Nó không được ngầm định từ thông tin xác thực AWS của bạn. Tìm ID tại **Workspaces** trên trang dịch vụ AWS Console và export nó trước khi khởi động Claude Code.

### Các yêu cầu vẫn đi tới `api.anthropic.com`

`CLAUDE_CODE_USE_ANTHROPIC_AWS` có khả năng chưa được thiết lập hoặc được đặt thành một giá trị không phân giải thành giá trị đúng (truthy). Đặt nó thành `1` và chạy `/status` để xác nhận provider đã được phân giải. Nếu `CLAUDE_CODE_USE_BEDROCK` hoặc `CLAUDE_CODE_USE_FOUNDRY` cũng được thiết lập, chúng được ưu tiên hơn Claude Platform on AWS.

## Tài nguyên bổ sung

Phần đăng ký Claude Platform on AWS, workspace, và cài đặt IAM diễn ra trước khi cấu hình Claude Code được đề cập trong tài liệu nền tảng:

* [Tổng quan Claude Platform on AWS](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws): đăng ký, cài đặt workspace, và tài liệu tham chiếu sản phẩm
* [Tài liệu tham chiếu IAM action](https://platform.claude.com/docs/en/api/claude-platform-on-aws-iam-actions): quyền và các chính sách được quản lý (managed policies)
