> Nguồn: https://code.claude.com/docs/en/amazon-bedrock.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải toàn bộ chỉ mục tài liệu tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Claude Code trên Amazon Bedrock

> Tìm hiểu cách cấu hình Claude Code thông qua Amazon Bedrock, bao gồm cài đặt, cấu hình IAM và xử lý sự cố.

## Yêu cầu tiên quyết

Trước khi cấu hình Claude Code với Amazon Bedrock, hãy đảm bảo bạn có:

* Một tài khoản AWS đã bật quyền truy cập Amazon Bedrock
* Quyền truy cập vào các model Claude mong muốn (ví dụ Claude Sonnet 4.6) trong Amazon Bedrock
* AWS CLI đã được cài đặt và cấu hình (không bắt buộc — chỉ cần khi bạn không có cơ chế nào khác để lấy thông tin xác thực)
* Quyền IAM phù hợp

Để đăng nhập bằng thông tin xác thực Amazon Bedrock của riêng bạn, hãy làm theo [Đăng nhập với Amazon Bedrock](#sign-in-with-bedrock) bên dưới. Để triển khai Claude Code cho cả một nhóm, hãy dùng các bước [cài đặt thủ công](#set-up-manually) và [ghim phiên bản model của bạn](#4-pin-model-versions) trước khi phát hành rộng rãi.

## Đăng nhập với Bedrock

Nếu bạn có thông tin xác thực AWS và muốn bắt đầu sử dụng Claude Code qua Amazon Bedrock, trình hướng dẫn đăng nhập (login wizard) sẽ dẫn bạn qua từng bước. Bạn hoàn tất các yêu cầu tiên quyết phía AWS một lần cho mỗi tài khoản; trình hướng dẫn xử lý phần phía Claude Code.

<Steps>
  <Step title="Bật các model Anthropic trong tài khoản AWS của bạn">
    Trong [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/), mở Model catalog, chọn một model Anthropic, rồi gửi biểu mẫu use case. Quyền truy cập được cấp ngay sau khi gửi. Xem [Gửi thông tin use case](#1-submit-use-case-details) đối với AWS Organizations và [Cấu hình IAM](#iam-configuration) để biết các quyền mà role của bạn cần.
  </Step>

  <Step title="Khởi động Claude Code và chọn Amazon Bedrock">
    Chạy `claude`. Tại lời nhắc đăng nhập, chọn **3rd-party platform**, sau đó **Amazon Bedrock**.
  </Step>

  <Step title="Làm theo các lời nhắc của trình hướng dẫn">
    Chọn cách bạn xác thực với AWS: một AWS profile được phát hiện từ thư mục `~/.aws`, một Amazon Bedrock API key, một access key cùng secret, hoặc thông tin xác thực đã có sẵn trong môi trường. Trình hướng dẫn sẽ lấy region của bạn, xác minh những model Claude nào tài khoản của bạn có thể gọi, và cho phép bạn ghim chúng. Nó lưu kết quả vào khối `env` trong [file user settings của bạn](/en/settings), nên bạn không cần tự export biến môi trường.
  </Step>
</Steps>

Sau khi đã đăng nhập, chạy `/setup-bedrock` bất cứ lúc nào để mở lại trình hướng dẫn và thay đổi thông tin xác thực, region hoặc các ghim model của bạn.

## Cài đặt thủ công

Để cấu hình Amazon Bedrock thông qua biến môi trường thay vì trình hướng dẫn, chẳng hạn trong CI hoặc một đợt phát hành doanh nghiệp có kịch bản (scripted), hãy làm theo các bước bên dưới.

### 1. Gửi thông tin use case

Người dùng lần đầu của các model Anthropic bắt buộc phải gửi thông tin use case trước khi gọi một model. Việc này thực hiện một lần cho mỗi tài khoản AWS.

1. Đảm bảo bạn có đúng các quyền IAM được mô tả bên dưới
2. Điều hướng tới [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/)
3. Chọn một model Anthropic từ **Model catalog**
4. Hoàn tất biểu mẫu use case. Quyền truy cập được cấp ngay sau khi gửi.

Nếu bạn dùng AWS Organizations, bạn có thể gửi biểu mẫu một lần từ management account bằng [`PutUseCaseForModelAccess` API](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_PutUseCaseForModelAccess.html). Lời gọi này yêu cầu quyền IAM `bedrock:PutUseCaseForModelAccess`. Việc phê duyệt tự động mở rộng tới các tài khoản con.

### 2. Cấu hình thông tin xác thực AWS

Claude Code sử dụng chuỗi thông tin xác thực (credential chain) mặc định của AWS SDK. Thiết lập thông tin xác thực của bạn bằng một trong các phương pháp sau:

**Phương án A: Cấu hình AWS CLI**

```bash theme={null}
aws configure
```

**Phương án B: Biến môi trường (access key)**

```bash theme={null}
export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-access-key
export AWS_SESSION_TOKEN=your-session-token
```

**Phương án C: Biến môi trường (SSO profile)**

```bash theme={null}
aws sso login --profile=<your-profile-name>

export AWS_PROFILE=your-profile-name
```

**Phương án D: Thông tin xác thực AWS Management Console**

```bash theme={null}
aws login
```

[Tìm hiểu thêm](https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html) về `aws login`.

**Phương án E: Amazon Bedrock API keys**

```bash theme={null}
export AWS_BEARER_TOKEN_BEDROCK=your-bedrock-api-key
```

Amazon Bedrock API keys cung cấp một phương thức xác thực đơn giản hơn mà không cần đầy đủ thông tin xác thực AWS. [Tìm hiểu thêm về Amazon Bedrock API keys](https://aws.amazon.com/blogs/machine-learning/accelerate-ai-development-with-amazon-bedrock-api-keys/).

#### Cấu hình thông tin xác thực nâng cao

Claude Code hỗ trợ tự động làm mới thông tin xác thực cho AWS SSO và các nhà cung cấp danh tính (identity provider) doanh nghiệp. Thêm các thiết lập này vào file settings của Claude Code (xem [Settings](/en/settings) để biết vị trí file).

Hai thiết lập này có điều kiện kích hoạt khác nhau:

* **`awsAuthRefresh`**: chỉ chạy khi Claude Code phát hiện thông tin xác thực AWS của bạn đã hết hạn, dựa trên timestamp cục bộ hoặc khi API trả về lỗi thông tin xác thực, rồi thử lại yêu cầu với thông tin xác thực đã làm mới.
* **`awsCredentialExport`**: chạy khi bắt đầu phiên và mỗi lần tải lại thông tin xác thực, ngay cả khi thông tin xác thực trong chuỗi credential provider mặc định của AWS vẫn còn hợp lệ. Dùng thiết lập này khi tài khoản Amazon Bedrock của bạn yêu cầu thông tin xác thực liên tài khoản (cross-account) khác với những gì chuỗi provider mặc định sẽ phân giải.

##### Ví dụ cấu hình

```json theme={null}
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": {
    "AWS_PROFILE": "myprofile"
  }
}
```

##### Giải thích các thiết lập cấu hình

**`awsAuthRefresh`**: Dùng cho các lệnh sửa đổi thư mục `.aws`, chẳng hạn cập nhật thông tin xác thực, cache SSO, hoặc file config. Đầu ra của lệnh được hiển thị cho người dùng, nhưng không hỗ trợ nhập liệu tương tác. Cách này phù hợp với các luồng SSO dựa trên trình duyệt, nơi CLI hiển thị một URL hoặc mã và bạn hoàn tất xác thực trong trình duyệt.

**`awsCredentialExport`**: Chỉ dùng nếu bạn không thể sửa đổi `.aws` và buộc phải trả về thông tin xác thực trực tiếp. Lệnh này chạy bất cứ khi nào cần làm mới thông tin xác thực, không chỉ khi thông tin xác thực đã hết hạn. Đầu ra được thu thập một cách âm thầm và không hiển thị cho người dùng. Lệnh phải xuất JSON theo định dạng này:

```json theme={null}
{
  "Credentials": {
    "AccessKeyId": "value",
    "SecretAccessKey": "value",
    "SessionToken": "value",
    "Expiration": "2026-01-01T00:00:00Z"
  }
}
```

{/* min-version: 2.1.181 */}Kể từ Claude Code v2.1.181, đầu ra dạng phẳng từ `aws configure export-credentials --format process` cũng được chấp nhận, với các key tương tự ở cấp cao nhất thay vì lồng bên dưới `Credentials`.

`Expiration` là tùy chọn. {/* min-version: 2.1.176 */}Kể từ Claude Code v2.1.176, khi lệnh trả về một `Expiration` ISO 8601 hợp lệ, Claude Code cache thông tin xác thực cho tới năm phút trước thời điểm đó. Nếu không có nó, hoặc trên các phiên bản cũ hơn, thông tin xác thực được cache trong một giờ.

### 3. Cấu hình Claude Code

Thiết lập các biến môi trường sau để bật Amazon Bedrock:

```bash theme={null}
# Bật tích hợp Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1  # không bắt buộc nếu AWS profile của bạn đã thiết lập region

# Tùy chọn: Ghi đè AWS region cho model nhỏ/nhanh (Bedrock và Mantle).
# Trên Bedrock, không có tác dụng nếu chưa thiết lập ANTHROPIC_DEFAULT_HAIKU_MODEL
# hoặc biến ANTHROPIC_SMALL_FAST_MODEL đã lỗi thời.
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2

# Tùy chọn: Ghi đè URL endpoint của Bedrock cho các endpoint tùy chỉnh hoặc gateway
# export ANTHROPIC_BEDROCK_BASE_URL=https://bedrock-runtime.us-east-1.amazonaws.com
```

Khi bật Amazon Bedrock cho Claude Code, hãy lưu ý những điều sau:

* {/* min-version: 2.1.172 */}Kể từ v2.1.172, bạn chỉ cần thiết lập `AWS_REGION` để ghi đè region của AWS profile hoặc khi profile của bạn không có region. Claude Code phân giải region theo thứ tự này:

  * `AWS_REGION`
  * `AWS_DEFAULT_REGION`
  * `region` được thiết lập trên AWS profile đang hoạt động của bạn, được đọc từ file AWS shared credentials trước rồi tới file shared config, khớp với thứ tự ưu tiên của AWS SDK
  * `us-east-1`

  Profile đang hoạt động là `AWS_PROFILE` nếu được thiết lập, ngược lại là `default`. Thiết lập `AWS_SHARED_CREDENTIALS_FILE` hoặc `AWS_CONFIG_FILE` để trỏ tới các đường dẫn file không mặc định. Chạy `/status` để xem region đã được phân giải. Khi region đến từ file config AWS hoặc phương án dự phòng mặc định, `/status` cũng ghi chú nguồn. Trên v2.1.171 trở về trước, Claude Code không đọc các file config AWS, nên hãy thiết lập `AWS_REGION` một cách rõ ràng.
* Khi dùng Amazon Bedrock, lệnh `/logout` không khả dụng vì việc xác thực được xử lý qua thông tin xác thực AWS.
* Công cụ WebSearch không khả dụng trên Amazon Bedrock. Xem [hành vi của công cụ WebSearch](/en/tools-reference#websearch-tool-behavior).
* Bạn có thể dùng file settings cho các biến môi trường như `AWS_PROFILE` mà bạn không muốn rò rỉ sang các tiến trình khác. Xem [Settings](/en/settings) để biết thêm.

### 4. Ghim phiên bản model

<Warning>
  Ghim phiên bản model cụ thể khi triển khai cho nhiều người dùng. Nếu không ghim, các alias model như `sonnet` và `opus` sẽ phân giải về giá trị mặc định tích hợp sẵn của Claude Code cho Amazon Bedrock, vốn có thể chậm hơn bản phát hành mới nhất và có thể chưa khả dụng trong tài khoản của bạn. Claude Code [dự phòng](#startup-model-checks) về phiên bản trước đó khi khởi động nếu bản mặc định không khả dụng, nhưng việc ghim cho phép bạn kiểm soát thời điểm người dùng chuyển sang model mới.
</Warning>

Thiết lập các biến môi trường này tới các ID model Amazon Bedrock cụ thể.

Nếu không có `ANTHROPIC_DEFAULT_OPUS_MODEL`, alias `opus` trên Amazon Bedrock phân giải về Opus 4.6. Thiết lập nó tới ID của Opus 4.8 để dùng model mới nhất:

```bash theme={null}
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Các biến này dùng ID inference profile liên vùng (cross-region) (với tiền tố `us.`). Nếu bạn dùng tiền tố region khác hoặc application inference profile, hãy điều chỉnh cho phù hợp. Ở các region AWS GovCloud, dùng tiền tố `us-gov.`. Để biết ID model hiện tại và cũ, xem [Tổng quan model](https://platform.claude.com/docs/en/about-claude/models/overview). Xem [Cấu hình model](/en/model-config#pin-models-for-third-party-deployments) để có danh sách đầy đủ các biến môi trường.

Claude Code sử dụng các model mặc định này khi không thiết lập biến ghim nào:

| Loại model       | Giá trị mặc định                               |
| :--------------- | :--------------------------------------------- |
| Model chính      | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Model nhỏ/nhanh  | Giống với model chính                          |

Các tác vụ nền như tạo tiêu đề phiên sử dụng model nhỏ/nhanh, thường là một model dạng Haiku. Trên Amazon Bedrock, Claude Code đặt mặc định model này về model chính vì Haiku có thể chưa được bật trong mọi tài khoản hoặc region. Để dùng Haiku cho các tác vụ nền, thiết lập `ANTHROPIC_DEFAULT_HAIKU_MODEL` tới một ID model có sẵn trong tài khoản của bạn.

Để tùy chỉnh model sâu hơn, dùng một trong các phương pháp sau:

```bash theme={null}
# Dùng ID inference profile
export ANTHROPIC_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'

# Dùng ARN của application inference profile
export ANTHROPIC_MODEL='arn:aws:bedrock:us-east-2:your-account-id:application-inference-profile/your-model-id'

# Tùy chọn: Tắt prompt caching nếu cần
export DISABLE_PROMPT_CACHING=1

# Tùy chọn: Yêu cầu TTL prompt cache 1 giờ thay vì mặc định 5 phút
export ENABLE_PROMPT_CACHING_1H=1
```

TTL cache 1 giờ được tính phí ở mức cao hơn so với mặc định 5 phút. Xem [thời gian tồn tại của cache](/en/prompt-caching#cache-lifetime).

<Note>Prompt caching có thể không khả dụng ở mọi region Amazon Bedrock. Nếu số lượng cache token vẫn ở mức 0, hãy kiểm tra [các model, region và giới hạn được hỗ trợ](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html#prompt-caching-models) trong tài liệu Amazon Bedrock.</Note>

#### Ánh xạ mỗi phiên bản model tới một inference profile

Các biến môi trường `ANTHROPIC_DEFAULT_*_MODEL` cấu hình một inference profile cho mỗi họ model. Nếu tổ chức của bạn cần hiển thị nhiều phiên bản của cùng một họ trong bộ chọn `/model`, mỗi phiên bản định tuyến tới ARN application inference profile riêng, hãy dùng thiết lập `modelOverrides` trong [file settings của bạn](/en/settings#settings-files).

Ví dụ này ánh xạ bốn phiên bản Opus tới các ARN riêng biệt để người dùng có thể chuyển đổi giữa chúng mà không bỏ qua các inference profile của tổ chức bạn:

```json theme={null}
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod",
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod",
    "claude-opus-4-5-20251101": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-45-prod",
    "claude-opus-4-1-20250805": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-41-prod"
  }
}
```

Khi người dùng chọn một trong các phiên bản này trong `/model`, Claude Code gọi Amazon Bedrock với ARN đã ánh xạ. {/* min-version: 2.1.200 */}Cùng ánh xạ đó được áp dụng khi bạn truyền trực tiếp ID model Anthropic qua `--model` hoặc `ANTHROPIC_MODEL`. Các phiên bản không có override sẽ dự phòng về ID model Amazon Bedrock tích hợp sẵn hoặc bất kỳ inference profile khớp nào được phát hiện lúc khởi động. Trước v2.1.200, các giá trị `--model` và `ANTHROPIC_MODEL` đến Amazon Bedrock nguyên trạng mà không đi qua bản đồ override. Xem [Ghi đè ID model theo phiên bản](/en/model-config#override-model-ids-per-version) để biết chi tiết cách các override tương tác với `availableModels` và các thiết lập model khác.

## Kiểm tra model lúc khởi động

Khi Claude Code khởi động với Amazon Bedrock đã được cấu hình, nó xác minh rằng các model mà nó dự định sử dụng có thể truy cập được trong tài khoản của bạn. Việc kiểm tra này yêu cầu Claude Code v2.1.94 trở lên.

Nếu bạn đã ghim một phiên bản model cũ hơn bản mặc định hiện tại của Claude Code, và tài khoản của bạn có thể gọi phiên bản mới hơn, Claude Code sẽ nhắc bạn cập nhật ghim. Chấp nhận sẽ ghi ID model mới vào [file user settings của bạn](/en/settings) và khởi động lại Claude Code. Việc từ chối được ghi nhớ cho tới lần thay đổi phiên bản mặc định tiếp theo. Các ghim trỏ tới một [ARN application inference profile](#map-each-model-version-to-an-inference-profile) sẽ được bỏ qua, vì những cái đó do quản trị viên của bạn quản lý.

Nếu bạn chưa ghim một model và bản mặc định hiện tại không khả dụng trong tài khoản của bạn, Claude Code dự phòng về phiên bản trước đó cho phiên hiện tại và hiển thị thông báo. Việc dự phòng không được lưu lại. Bật model mới hơn trong tài khoản Amazon Bedrock của bạn hoặc [ghim một phiên bản](#4-pin-model-versions) để lựa chọn trở nên vĩnh viễn.

## Cấu hình IAM

Tạo một chính sách IAM với các quyền cần thiết cho Claude Code:

```json theme={null}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowModelAndInferenceProfileAccess",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*",
        "arn:aws:bedrock:*:*:foundation-model/*"
      ]
    },
    {
      "Sid": "AllowMarketplaceSubscription",
      "Effect": "Allow",
      "Action": [
        "aws-marketplace:ViewSubscriptions",
        "aws-marketplace:Subscribe"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:CalledViaLast": "bedrock.amazonaws.com"
        }
      }
    }
  ]
}
```

Để có quyền hạn chế hơn, bạn có thể giới hạn Resource về các ARN inference profile cụ thể.

`bedrock:GetInferenceProfile` cho phép Claude Code phân giải một [ARN application inference profile](#map-each-model-version-to-an-inference-profile) về foundation model hỗ trợ nó, dùng để chọn đúng hình dạng yêu cầu (request shape) cho model đó.

Nếu token thiếu quyền này, Claude Code tự phục hồi bằng cách thử lại một lần với hình dạng thay thế, nên các yêu cầu vẫn thành công nhưng mỗi model mới thêm một lượt round-trip. Cấp quyền này sẽ tránh việc thử lại. Điều này thường áp dụng nhất cho các triển khai `AWS_BEARER_TOKEN_BEDROCK`, nơi chính sách của token thường hẹp hơn so với một IAM role đầy đủ.

Để biết chi tiết, xem [tài liệu IAM của Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/security-iam.html).

<Note>
  Tạo một tài khoản AWS riêng cho Claude Code để đơn giản hóa việc theo dõi chi phí và kiểm soát truy cập.
</Note>

## Cửa sổ ngữ cảnh 1M token

Claude Sonnet 5, Opus 4.6 trở lên, và Sonnet 4.6 hỗ trợ [cửa sổ ngữ cảnh 1M token](https://platform.claude.com/docs/en/build-with-claude/context-windows#1m-token-context-window) trên Amazon Bedrock. Sonnet 5 được phục vụ qua [endpoint Mantle](#use-the-mantle-endpoint) và luôn chạy với cửa sổ 1M, không có biến thể `[1m]` để chọn. Đối với các model còn lại, Claude Code tự động bật cửa sổ ngữ cảnh mở rộng khi bạn chọn một biến thể model 1M.

[Trình hướng dẫn cài đặt](#sign-in-with-bedrock) cung cấp tùy chọn ngữ cảnh 1M khi nó ghim model. Để bật nó cho một model được ghim thủ công, hãy thêm `[1m]` vào cuối ID model. Xem [Ghim model cho triển khai bên thứ ba](/en/model-config#pin-models-for-third-party-deployments) để biết chi tiết.

## Service tiers (tầng dịch vụ)

[Service tiers của Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/service-tiers-inference.html) cho phép bạn đánh đổi giữa chi phí và độ trễ. Thiết lập `ANTHROPIC_BEDROCK_SERVICE_TIER` thành `default`, `flex`, hoặc `priority`:

```bash theme={null}
export ANTHROPIC_BEDROCK_SERVICE_TIER=priority
```

Claude Code gửi cái này dưới dạng header `X-Amzn-Bedrock-Service-Tier` trên mỗi yêu cầu. Tính khả dụng của tầng thay đổi theo model và region. Dung lượng dành riêng (reserved capacity) dùng một ARN [provisioned throughput](https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html) làm ID model thay vì thiết lập này.

## AWS Guardrails

[Amazon Bedrock Guardrails](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) cho phép bạn triển khai lọc nội dung cho Claude Code. Tạo một Guardrail trong [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/), phát hành một phiên bản, rồi thêm các header Guardrail vào [file settings của bạn](/en/settings). Bật Cross-Region inference trên Guardrail của bạn nếu bạn đang dùng các inference profile liên vùng.

Ví dụ cấu hình:

```json theme={null}
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

## Sử dụng endpoint Mantle

Mantle là một endpoint Amazon Bedrock phục vụ các model Claude thông qua hình dạng native của Anthropic API thay vì Amazon Bedrock Invoke API. Nó dùng chung thông tin xác thực AWS, quyền IAM và cấu hình `awsAuthRefresh` đã mô tả ở phần trước trong trang này.

<Note>
  Mantle yêu cầu Claude Code v2.1.94 trở lên. Chạy `claude --version` để kiểm tra.
</Note>

### Bật Mantle

Với thông tin xác thực AWS đã được cấu hình, thiết lập `CLAUDE_CODE_USE_MANTLE` để định tuyến các yêu cầu tới endpoint Mantle:

```bash theme={null}
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
```

Claude Code dựng URL endpoint từ AWS region. {/* min-version: 2.1.172 */}Kể từ v2.1.172, region được phân giải với cùng thứ tự ưu tiên như [Amazon Bedrock ở trên](#3-configure-claude-code); các phiên bản cũ hơn chỉ dùng `AWS_REGION`. Để ghi đè URL cho một endpoint hoặc gateway tùy chỉnh, thiết lập `ANTHROPIC_BEDROCK_MANTLE_BASE_URL`.

Chạy `/status` bên trong Claude Code để xác nhận. Dòng provider hiển thị `Amazon Bedrock (Mantle)` khi Mantle đang hoạt động.

### Chọn một model Mantle

Mantle dùng các ID model có tiền tố `anthropic.` và không có hậu tố phiên bản, ví dụ `anthropic.claude-sonnet-5` hoặc `anthropic.claude-haiku-4-5`. Các model khả dụng cho tài khoản của bạn phụ thuộc vào những gì tổ chức của bạn được cấp; các ID model bổ sung được liệt kê trong tài liệu onboarding của bạn từ AWS. Liên hệ đội ngũ tài khoản AWS của bạn để yêu cầu quyền truy cập các model trong danh sách cho phép.

Thiết lập model bằng cờ `--model` hoặc bằng `/model` bên trong Claude Code:

```bash theme={null}
claude --model anthropic.claude-haiku-4-5
```

### Chạy Mantle song song với Invoke API

Các model khả dụng cho bạn trên Mantle có thể không bao gồm mọi model bạn dùng hôm nay. Thiết lập cả `CLAUDE_CODE_USE_BEDROCK` và `CLAUDE_CODE_USE_MANTLE` cho phép Claude Code gọi cả hai endpoint từ cùng một phiên. Các ID model khớp với định dạng Mantle được định tuyến tới Mantle, và tất cả các ID model khác đi tới Amazon Bedrock Invoke API.

```bash theme={null}
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_USE_MANTLE=1
```

Để hiển thị một model Mantle trong bộ chọn `/model`, liệt kê ID của nó trong `availableModels` trong [file settings của bạn](/en/settings). Thiết lập này cũng giới hạn bộ chọn về các mục được liệt kê. Việc liệt kê `anthropic.claude-haiku-4-5` sẽ loại bỏ alias `haiku` trần khỏi bộ chọn, nên cũng hãy liệt kê các tiền tố phiên bản hoặc ID đầy đủ cho các phiên bản mà bạn muốn giữ lại để có thể chọn. ID Mantle và alias `haiku` phân giải về cùng một họ model, nên việc gộp chỉ giữ lại mục cụ thể hơn. Xem [Hành vi gộp](/en/model-config#merge-behavior):

```json theme={null}
{
  "availableModels": ["opus", "sonnet", "claude-haiku-4-5", "anthropic.claude-haiku-4-5"]
}
```

Các mục có tiền tố `anthropic.` được thêm vào như các tùy chọn bộ chọn tùy chỉnh và định tuyến tới Mantle. Thay `anthropic.claude-haiku-4-5` bằng ID model mà tài khoản của bạn được cấp. Xem [Giới hạn lựa chọn model](/en/model-config#restrict-model-selection) để biết cách `availableModels` tương tác với các thiết lập model khác.

Khi cả hai provider đang hoạt động, `/status` hiển thị `Amazon Bedrock + Amazon Bedrock (Mantle)`.

### Định tuyến Mantle qua một gateway

Nếu tổ chức của bạn định tuyến lưu lượng model qua một [LLM gateway](/en/llm-gateway) tập trung có tiêm thông tin xác thực AWS phía máy chủ (server-side), hãy tắt xác thực phía client để Claude Code gửi các yêu cầu mà không có chữ ký SigV4 hoặc header `x-api-key`:

```bash theme={null}
export CLAUDE_CODE_USE_MANTLE=1
export CLAUDE_CODE_SKIP_MANTLE_AUTH=1
export ANTHROPIC_BEDROCK_MANTLE_BASE_URL=https://your-gateway.example.com
```

### Biến môi trường của Mantle

Các biến này dành riêng cho endpoint Mantle. Xem [Biến môi trường](/en/env-vars) để có danh sách đầy đủ.

| Biến                                    | Mục đích                                                                       |
| :-------------------------------------- | :---------------------------------------------------------------------------- |
| `CLAUDE_CODE_USE_MANTLE`                | Bật endpoint Mantle. Đặt thành `1` hoặc `true`.                               |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL`     | Ghi đè URL endpoint Mantle mặc định                                           |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH`          | Bỏ qua xác thực phía client cho các cài đặt proxy                             |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Ghi đè AWS region cho model dạng Haiku (dùng chung với Amazon Bedrock)        |

## Xử lý sự cố

### Vòng lặp xác thực với SSO và proxy doanh nghiệp

Nếu các tab trình duyệt liên tục xuất hiện khi dùng AWS SSO, hãy xóa thiết lập `awsAuthRefresh` khỏi [file settings của bạn](/en/settings). Điều này có thể xảy ra khi VPN doanh nghiệp hoặc proxy kiểm tra TLS làm gián đoạn luồng SSO trên trình duyệt. Claude Code coi kết nối bị gián đoạn là một lỗi xác thực, chạy lại `awsAuthRefresh`, và lặp vô hạn.

Nếu môi trường mạng của bạn cản trở các luồng SSO tự động dựa trên trình duyệt, hãy dùng `aws sso login` thủ công trước khi khởi động Claude Code thay vì dựa vào `awsAuthRefresh`.

### Vấn đề về region

Nếu bạn gặp vấn đề về region:

* Kiểm tra tính khả dụng của model: `aws bedrock list-inference-profiles --region your-region`
* Chuyển sang một region được hỗ trợ: `export AWS_REGION=us-east-1`
* Cân nhắc dùng inference profile để truy cập liên vùng

Nếu bạn nhận được lỗi "on-demand throughput isn't supported":

* Chỉ định model dưới dạng ID [inference profile](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)

Claude Code dùng Amazon Bedrock [Invoke API](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_InvokeModelWithResponseStream.html) và không hỗ trợ Converse API.

### Số lượng token bằng 0 trong /context

Lệnh `/context` đếm token cho mỗi nhóm công cụ bằng cách gửi schema công cụ tới API count-tokens của Amazon Bedrock. {/* min-version: 2.1.196 */}Trên các phiên bản Claude Code trước v2.1.196, Amazon Bedrock từ chối yêu cầu đó vì các schema mang những trường mà API count-tokens của nó không chấp nhận, nên mọi nhóm công cụ hiển thị 0 token. Các hàng khác trong bảng phân tích, chẳng hạn tin nhắn và file bộ nhớ, không bị ảnh hưởng.

Cập nhật lên v2.1.196 trở lên.

### Lỗi endpoint Mantle

Nếu `/status` không hiển thị `Amazon Bedrock (Mantle)` sau khi bạn thiết lập `CLAUDE_CODE_USE_MANTLE`, biến này không đến được tiến trình. Xác nhận rằng nó đã được export trong shell nơi bạn khởi chạy `claude`, hoặc thiết lập nó trong khối `env` của [file settings của bạn](/en/settings).

Một lỗi `403` từ endpoint Mantle với thông tin xác thực hợp lệ nghĩa là tài khoản AWS của bạn chưa được cấp quyền truy cập model bạn yêu cầu. Liên hệ đội ngũ tài khoản AWS của bạn để yêu cầu quyền truy cập.

Một lỗi `400` nêu tên ID model nghĩa là model đó không được phục vụ trên Mantle. Mantle có danh mục model riêng tách biệt với danh mục Amazon Bedrock tiêu chuẩn, nên các ID inference profile như `us.anthropic.claude-sonnet-4-6` sẽ không hoạt động. Dùng một ID định dạng Mantle, hoặc bật [cả hai endpoint](#run-mantle-alongside-the-invoke-api) để Claude Code định tuyến mỗi yêu cầu tới endpoint nơi model khả dụng.

## Tài nguyên bổ sung

* [Tài liệu Amazon Bedrock](https://docs.aws.amazon.com/bedrock/)
* [Giá Amazon Bedrock](https://aws.amazon.com/bedrock/pricing/)
* [Amazon Bedrock inference profiles](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-profiles-support.html)
* [Amazon Bedrock token burndown và quotas](https://docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html)
* [Claude Code trên Amazon Bedrock: Hướng dẫn cài đặt nhanh](https://community.aws/content/2tXkZKrZzlrlu0KfH8gST5Dkppq/claude-code-on-amazon-bedrock-quick-setup-guide)
* [Triển khai giám sát Claude Code (Amazon Bedrock)](https://github.com/aws-solutions-library-samples/guidance-for-claude-code-with-amazon-bedrock/blob/main/assets/docs/MONITORING.md)
