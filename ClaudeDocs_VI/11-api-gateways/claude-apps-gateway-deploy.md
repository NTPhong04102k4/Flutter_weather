> Nguồn: https://code.claude.com/docs/en/claude-apps-gateway-deploy.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Triển khai và vận hành Claude apps gateway

> Đăng ký gateway với IdP của bạn, build container, triển khai trên Kubernetes hoặc Cloud Run, và vận hành nó: kiểm tra sức khỏe (health check), xoay vòng secret, nâng cấp và bảo mật.

Trang này bao quát khía cạnh vận hành của việc chạy [Claude apps gateway](/en/claude-apps-gateway): đăng ký một OAuth client trong nhà cung cấp danh tính (identity provider — IdP) của bạn, triển khai gateway dưới dạng container, và chạy nó hằng ngày. Để biết mọi tùy chọn trong file `gateway.yaml` mà gateway đọc lúc khởi động, xem [Tài liệu tham chiếu cấu hình](/en/claude-apps-gateway-config).

Một lần triển khai production đi theo bốn bước theo thứ tự, và các mục bên dưới khớp với chúng. Hai bước đầu là nơi bạn đưa ra lựa chọn; hai bước sau là tài liệu tham chiếu để tra cứu khi nó đã chạy.

1. [Thiết lập nhà cung cấp danh tính](#identity-provider-setup): đăng ký OAuth client và kiểm tra các ghi chú theo từng IdP cho Okta, Entra và Google
2. [Triển khai gateway](#deployment): build một image container được ghim phiên bản và chạy nó trên Kubernetes, Cloud Run hoặc nền tảng của riêng bạn. Mục này cũng bao gồm các quyết định về chi phí, bypass, nhiều gateway, và serverless
3. [Thiết lập vận hành](#operations): log, health probe, hành vi khi mất điện, xoay vòng secret, và nâng cấp. Tham khảo khi bạn đang thiết lập giám sát và runbook
4. [Rà soát tư thế bảo mật](#security): dữ liệu nào chảy đến đâu, mô hình mối đe dọa (threat model), và các câu trả lời về tuân thủ. Tham khảo cho một cuộc rà soát bảo mật

Nếu một lần đăng nhập hoặc khởi động thất bại dọc đường, hãy đến thẳng [Khắc phục sự cố](#troubleshooting), được sắp xếp theo lỗi bạn thấy.

<Note>
  **Triển khai trên mạng riêng của bạn.** Claude Code chỉ kết nối tới một gateway có địa chỉ là riêng tư. Đây là một biện pháp bảo vệ, bởi vì một gateway đáng tin cậy có thể đẩy các cài đặt chạy lệnh trên máy của lập trình viên. Đặt gateway sau một internal load balancer hoặc VPN và cho nó một hostname chỉ phân giải ra các IP riêng tư.
</Note>

## Thiết lập nhà cung cấp danh tính

Đăng ký một ứng dụng web OAuth/OpenID Connect (OIDC) dạng confidential với một redirect URI duy nhất, `https://<gateway>/oauth/callback`, và gán nó cho những người dùng hoặc nhóm cần có quyền truy cập gateway.

Bất kỳ IdP tuân thủ OIDC nào đều dùng được: Okta, Microsoft Entra ID, Google Workspace, Keycloak, Dex, PingFederate và những cái khác. IdP phải đáp ứng ba yêu cầu:

* Phục vụ `/.well-known/openid-configuration`, qua HTTPS trong production; gateway chấp nhận một [`http://` issuer](/en/claude-apps-gateway-config#oidc), và một loopback issuer bổ sung cần thêm `CLAUDE_GATEWAY_ALLOW_LOOPBACK=1`
* Hỗ trợ luồng authorization-code. PKCE (Proof Key for Code Exchange) được bật mặc định; tắt nó bằng `oidc.use_pkce: false` cho các IdP không hỗ trợ nó
* Trả về `email` và tùy chọn `groups` trong id\_token, hoặc phục vụ chúng từ userinfo endpoint với `oidc.userinfo_fallback: true`

Đối với PKI riêng, đặt `oidc.ca_cert_pem`.

Một số nhà cung cấp xử lý claim email và group khác biệt:

* **Okta**: org authorization server tại `https://example.okta.com` trả về một id\_token mỏng bỏ qua `email` và `groups`, vì vậy hãy đặt `oidc.userinfo_fallback: true` bất cứ khi nào bạn dùng nó làm `issuer`. Một custom authorization server như `https://example.okta.com/oauth2/default` có bao gồm `email` và tùy chọn `groups` trong id\_token thì phát ra chúng trực tiếp và không cần fallback. Okta chỉ phát ra `groups` khi scope `groups` được yêu cầu trong `oidc.scopes` và bộ lọc groups claim của ứng dụng cho phép; `userinfo_fallback` không thể điền một claim mà IdP không được yêu cầu.
* **Microsoft Entra ID**: `issuer` = `https://login.microsoftonline.com/<tenant-id>/v2.0`. Entra phát ra Object ID của group thay vì tên, vì vậy hãy dùng các GUID trong `managed.policies.match.groups`, hoặc dùng App Roles để có tên đọc được. Nếu tenant của bạn phát ra roles dưới `roles` thay vì `groups`, đặt `oidc.groups_claim: roles`.
* **Google Workspace**: `issuer` = `https://accounts.google.com`. id\_token của Google không mang groups. Để dùng `allowed_groups` dựa trên group hoặc `managed.policies` với Google làm IdP, cấu hình [`oidc.google_groups`](/en/claude-apps-gateway-config#oidc), nó tra cứu group của mỗi người dùng qua Admin SDK Directory API bằng một service account có domain-wide delegation. Nếu không có nó, dùng `oidc.allowed_email_domains` để giới hạn thành viên và `managed.policies.match.email_domain` để gán chính sách. Google cũng bỏ qua scope tiêu chuẩn `offline_access`. Để có refresh token, đặt `oidc.scopes: [openid, profile, email]` và `oidc.extra_auth_params: { access_type: offline, prompt: consent }`.

Để được hỗ trợ với một nhà cung cấp danh tính không được nêu ở trên, xem [Khắc phục sự cố](#troubleshooting).

<Warning>
  Refresh token cho phép gateway gia hạn phiên của lập trình viên một cách âm thầm, mà không đưa lập trình viên trở lại trình duyệt. Chúng cũng thúc đẩy việc deprovision, bởi vì khi IdP vô hiệu hóa một người dùng, lần refresh tiếp theo thất bại và phiên kết thúc trong vòng `ttl_hours`. Gateway yêu cầu `offline_access` theo mặc định để lấy refresh token. Nếu IdP của bạn yêu cầu sự đồng ý rõ ràng cho offline access, cấu hình OAuth client để cho phép nó.

  Nếu IdP của bạn hoàn toàn không thể phát refresh token, gateway vẫn hoạt động, nhưng không có gia hạn âm thầm, vì vậy lập trình viên phải chạy lại đăng nhập trình duyệt khi phiên của họ hết hạn. Để tránh việc đó xảy ra mỗi giờ, hãy tăng [`session.ttl_hours`](/en/claude-apps-gateway-config#session) lên `8` hoặc `12`. Đánh đổi là độ trễ deprovision, vì không có refresh token, một người dùng đã bị vô hiệu hóa vẫn giữ quyền truy cập cho đến khi TTL dài hơn trôi qua.
</Warning>

## Triển khai

Gateway là một binary Linux đơn lẻ. Nó mở rộng theo chiều ngang được vì các replica đều stateless và Postgres là lớp phối hợp dùng chung. Chạy nó theo cách bạn chạy các dịch vụ stateless trong môi trường của mình. Phần còn lại của mục này nêu image cần những gì, với các ghi chú ngắn cho Kubernetes và Cloud Run.

Gateway được thiết kế để chạy bên trong mạng của bạn, vì nó giữ credential upstream của bạn và đóng vai trò là điểm egress duy nhất cho inference. Nó có thể chạy ở bất cứ đâu mà lập trình viên và IdP của bạn có thể tiếp cận qua HTTPS; hãy đối xử với nó như bất kỳ dịch vụ nào khác giữ một credential production.

Một vài quyết định định hình việc triển khai ngoài chuyện nó chạy ở đâu:

* **Chi phí**: không có license riêng hay phí per-seat cho gateway; nó là một phần của binary `claude`. Bạn trả tiền cho inference thông qua cam kết cloud hoặc Anthropic hiện có của mình, cộng với compute cho container và bộ thu thập telemetry của bạn.
* **Bypass**: gateway không cưỡng chế rằng con đường duy nhất tới một model phải đi qua nó. Một lập trình viên có credential riêng vẫn có thể gọi trực tiếp nhà cung cấp, nên đóng con đường đó là một quyết định về chính sách mạng, ví dụ chặn egress tới `api.anthropic.com` ngoại trừ từ gateway. Chặn egress đó cũng phá vỡ [kiểm tra an toàn tên miền của WebFetch](/en/data-usage#webfetch-domain-safety-check), vốn gọi `api.anthropic.com` từ máy của mỗi lập trình viên; đặt `skipWebFetchPreflight: true` trong managed policy để tắt nó.
* **Nhiều gateway**: mỗi gateway là một lần triển khai riêng với cấu hình riêng. CLI lưu trữ trust fingerprint và credential của nó theo từng hostname gateway, nên các nhóm khác nhau có thể kết nối tới các gateway khác nhau mà không xung đột. Để phục vụ nhiều OIDC issuer, chạy các instance riêng biệt.
* **Serverless**: Cloud Run hoạt động; đặt `min-instances: 1` để tránh cold OIDC discovery. Lambda và Cloud Functions thì không, vì gateway là một HTTP server chạy dài.

Mọi topology production ở đây đều đặt một L7 proxy, như một Ingress, front end của Cloud Run, hoặc một ALB, ở phía trước các replica chạy HTTP thuần. Đặt [`listen.trusted_proxies`](/en/claude-apps-gateway-config#listen) thành các dải nguồn của proxy để gateway đọc IP của client từ `X-Forwarded-For`. Gateway chỉ tôn trọng header này khi TCP peer là đáng tin cậy; [ví dụ thực hành Google Cloud](/en/claude-apps-gateway-on-gcp) có các giá trị cụ thể cho từng topology. Nếu không có trusted proxy, mọi request có vẻ như đến từ IP của proxy, điều này gộp các rate limit theo từng IP vào một bucket dùng chung và ghi lại IP của proxy trong các sự kiện audit.

### Image container

Build image của riêng bạn dựa trên binary `claude` native từ bản phát hành Claude Code tiêu chuẩn:

1. Tải bản build Linux cho kiến trúc image của bạn từ một bản phát hành đã ghim; xem [Cài đặt một phiên bản cụ thể](/en/setup#install-a-specific-version) để biết URL tải về.
2. Xác minh nó so với `manifest.json` được ký GPG của bản phát hành như được mô tả trong [Tính toàn vẹn binary và ký mã (code signing)](/en/setup#binary-integrity-and-code-signing).
3. Sao chép nó vào build context.

Mirror bản phát hành vào registry nội bộ của bạn nếu các build của bạn không thể tiếp cận host phát hành, và ghim phiên bản mà fleet của bạn chạy.

Ngoài binary, image cần:

* **Một image dựa trên glibc**: dependency động duy nhất của bản build glibc là các thư viện glibc. Các image dựa trên musl cần bản build `linux-x64-musl` hoặc `linux-arm64-musl` cộng với các gói bổ sung; xem [Thiết lập Alpine Linux](/en/setup#alpine-linux-and-musl-based-distributions).
* **Một thư mục state có thể ghi**: gateway chạy dưới bất kỳ user nào, nhưng các image tối giản không có home có thể ghi. Đặt `CLAUDE_CONFIG_DIR` tới một đường dẫn có thể ghi như `/tmp/.claude`.
* **Lệnh container**: `claude gateway --config /etc/claude/gateway.yaml`, với file config được mount ở chế độ read-only và secret được cung cấp dưới dạng biến môi trường; gateway lắng nghe trên `listen.port`, mặc định `8080`.

### Kubernetes

Chạy gateway như một Deployment, giống như bất kỳ dịch vụ stateless nào:

* Mount config từ một ConfigMap và secret từ một Secret; tham chiếu secret trong YAML qua `${file:/path/to/secret}` hoặc dưới dạng biến môi trường
* Terminate TLS tại Ingress và đặt `listen.public_url` thành hostname của Ingress
* Trỏ readiness probe tới `GET /readyz` và liveness probe tới `GET /healthz`

<Note>
  **Workload identity**

  Ưu tiên workload identity của nền tảng thay vì static key: IRSA trên EKS cho Amazon Bedrock và cho Claude Platform trên AWS, Workload Identity trên GKE cho Agent Platform của Google Cloud, và workload identity trên AKS cho Microsoft Foundry. Đặt `auth: {}` trong khối upstream, hoặc `use_azure_ad: true` cho Microsoft Foundry, và gateway sẽ lấy identity của pod thông qua chuỗi credential mặc định của nhà cung cấp đó. Đối với việc ghép cross-cloud, chẳng hạn một upstream Amazon Bedrock trên GKE, hãy đặt credential rõ ràng trong khối `auth` của upstream thay vào đó. [Tài liệu tham chiếu `upstreams`](/en/claude-apps-gateway-config#upstreams) có chi tiết thiết lập theo từng nền tảng.
</Note>

### Cloud Run

Cấu hình dịch vụ như sau:

* Để `listen.port` ở mặc định `8080`, khớp với `PORT` mặc định của Cloud Run, hoặc đặt `port: ${PORT}`
* Đặt `public_url` thành origin có thể tiếp cận từ bên ngoài. Với production, đây thường là hostname của một internal load balancer, bởi vì `/login` [từ chối các địa chỉ công khai](/en/claude-apps-gateway#prerequisites) và URL `*.run.app` phân giải ra một trong số đó, nên URL Cloud Run đơn thuần chỉ hoạt động cho một smoke test bằng `curl` hoặc trình duyệt. Ngoại lệ là một mạng nơi `*.run.app` phân giải riêng tư qua Private Service Connect và một Cloud DNS private zone; trong topology đó URL Cloud Run là một `public_url` hợp lệ. [Ví dụ thực hành Google Cloud](/en/claude-apps-gateway-on-gcp#deploy-the-gateway) bao gồm cả hai.
* Mount config như một secret volume
* Đặt `min-instances: 1` để tránh cold OIDC discovery ở request đầu tiên

<Note>
  Để có một ví dụ thực hành đầy đủ trên Google Cloud, bao gồm Cloud Run hoặc GKE, Cloud SQL, và Secret Manager, xem [Triển khai trên Google Cloud](/en/claude-apps-gateway-on-gcp).
</Note>

### Đẩy URL gateway tới máy của lập trình viên

Khi gateway đã phục vụ, hãy đẩy `forceLoginMethod` và `forceLoginGatewayUrl` tới máy của mỗi lập trình viên thông qua managed settings, qua MDM hoặc bằng cách ghi trực tiếp file `managed-settings.json` theo từng OS. Nếu không có điều này, `/login` hiển thị bộ chọn tài khoản tiêu chuẩn mà không có tùy chọn gateway. Xem [Managed settings phía client](/en/claude-apps-gateway-config#client-side-managed-settings) để biết đường dẫn file.

## Vận hành

Khi gateway đã phục vụ traffic, việc vận hành hằng ngày là đọc log của nó, thăm dò sức khỏe của nó, và xoay vòng secret của nó theo lịch của bạn. Các mục con bao quát từng phần, cộng với Postgres giữ gì và cách các bản nâng cấp và rollback hành xử.

### Log

Gateway ghi hai luồng ra stderr, cả hai đều thân thiện với JSON:

* **Sự kiện audit**: JSON một dòng cho mỗi sự kiện liên quan đến bảo mật. Đưa stderr vào bộ tổng hợp log của bạn. Các sự kiện được phát ra bao gồm `config.load`, `session.mint`, `session.refresh`, `device.authorize`, `device.verify`, `auth.denied`, `access.denied`, `inference`, `managed.serve`, `spend.blocked`, và `admin.denied`. Các trường thay đổi theo sự kiện:
  * Các sự kiện mint và refresh thành công mang `sub`, `email`, `client_ip`, và kết quả
  * Các sự kiện từ chối mang lý do, path, và IP client, vì không có identity nào tồn tại tại thời điểm từ chối
  * `inference` ghi lại upstream nào phục vụ request và trạng thái phản hồi
  * `admin.denied` ghi lại một lần thử xác thực admin-API bị từ chối kèm lý do (`invalid_key` hoặc `no_credentials`), IP client, method, và path, không kèm nội dung key được trình.
* **Log vận hành**: các dòng dễ đọc có tiền tố `[gateway]` cho khởi động, cảnh báo, và lỗi upstream. Biến môi trường `CLAUDE_GATEWAY_LOG_LEVEL` điều khiển mức độ chi tiết và chấp nhận `info`, `warn`, hoặc `error`, với `info` là mặc định. Nó không ảnh hưởng đến các sự kiện audit, vốn luôn được phát ra.

### Sức khỏe (Health)

Gateway phục vụ `GET /healthz` như một liveness probe và `GET /readyz` như một readiness probe; `/readyz` xác minh store có thể tiếp cận. Cả hai đều được miễn khỏi `access_control.allow_cidrs`, nên các probe vẫn hoạt động trên một listener bị khóa chặt.

Tài liệu OAuth discovery tại `/.well-known/oauth-authorization-server` cũng chỉ trả về `200` sau khi config load, OIDC discovery, xây dựng upstream client, và migration Postgres đều thành công, nên nó kiêm luôn một kiểm tra khởi động end-to-end.

Một gateway đang chạy cũng phục vụ một mô tả về các path và hình dạng request mà nó chấp nhận tại `<public_url>/protocol`, khớp với phiên bản bạn đang chạy. Nội dung không ổn định giữa các bản phát hành.

### Hành vi khi mất điện (outage)

Nếu Postgres ngừng hoạt động, bản thân gateway vẫn tiếp tục phục vụ các lập trình viên đã đăng nhập và các lần đăng nhập mới thất bại. Việc lập trình viên có thực sự tiếp tục làm việc hay không phụ thuộc vào cách orchestrator của bạn xử lý readiness:

* **Phiên hiện có**: bearer token được xác thực cục bộ bằng JWT secret, refresh phiên không chạm đến store, và tiến trình gateway vẫn có thể phục vụ inference
* **Đăng nhập mới**: thất bại cho đến khi Postgres phục hồi, vì device flow và các bộ đếm rate-limit của nó nằm trong Postgres
* **[Cưỡng chế giới hạn chi tiêu](/en/claude-apps-gateway-spend-limits#postgres-availability)**: mặc định fail open (mở) trong lúc mất điện, nên inference vẫn chảy; chuyển sang fail closed (đóng) nếu bạn muốn chặn thay vì chạy không đo đếm
* **Readiness**: `/readyz` báo cáo not-ready trong lúc mất điện, nên các orchestrator gating traffic dựa trên readiness sẽ gỡ mọi replica ra khỏi vòng quay cùng một lúc. Trong topology đó mọi traffic, bao gồm cả inference mà gateway vẫn có thể phục vụ, đều thất bại tại load balancer cho đến khi Postgres phục hồi. Liveness probe trên `/healthz` vẫn tiếp tục pass, nên các replica không bị restart. Trỏ readiness probe tới `/healthz` thay vào đó nếu bạn muốn các lập trình viên đã đăng nhập tiếp tục làm việc xuyên qua một lần mất store; cái giá là đăng nhập mới thất bại trên một replica vẫn báo cáo ready.

Nếu IdP của bạn ngừng hoạt động, các phiên hiện có vẫn hoạt động cho đến `ttl_hours`, và các lần đăng nhập mới và refresh thất bại. Đặt `ttl_hours` dài hơn nếu IdP của bạn có các cửa sổ bảo trì thường xuyên.

### Xoay vòng JWT secret

Xoay vòng signing secret theo ba bước để các phiên hiện có vẫn hợp lệ:

1. Tạo một secret mới. Thêm nó vào đầu mảng `session.jwt_secret`.
2. Roll deployment. Các token mới ký bằng secret mới; các token cũ vẫn xác thực được.
3. Sau `ttl_hours` cộng một khoảng dư, xóa secret cũ và roll lại.

Xoay vòng cũng là cách duy nhất để buộc các phiên kết thúc trước khi chúng hết hạn: bearer token được xác thực cục bộ so với JWT secret, nên không có thu hồi (revocation) theo từng phiên. Thay thế hoàn toàn secret, mà không giữ cái cũ trong mảng, sẽ vô hiệu hóa mọi phiên đang tồn tại cùng một lúc. Đối với offboarding cá nhân, hãy deprovision người dùng trong IdP của bạn; phiên của họ kết thúc trong vòng `ttl_hours`.

### Postgres

Gateway giữ năm bảng, tất cả được tạo bởi các migration lúc khởi động của nó:

| Bảng               | Nội dung                                                                       | Thời gian lưu giữ                                              |
| ------------------ | ----------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `kv`               | Device grant (TTL 10 phút) và các bộ đếm rate-limit                            | TTL theo từng dòng                                             |
| `spend`            | Các bộ đếm chi tiêu period-to-date theo từng principal, tính bằng cent         | `admin.spend_retention_months`, mặc định 13                   |
| `spend_limits`     | Các trần chi tiêu đã cấu hình                                                  | Cho đến khi bị xóa qua API                                     |
| `admin_audit`      | Dấu vết thay đổi (mutation) của Admin API                                      | `admin.audit_retention_days`, mặc định 365                    |
| `principal_emails` | Email, tên hiển thị và group IdP được thấy gần nhất của mỗi principal. Chứa PII. | `admin.identity_retention_days` kể từ hoạt động cuối, mặc định 90 |

Một vòng lặp 30 giây làm hết hạn các dòng `kv` quá TTL, và một lượt quét hằng giờ cưỡng chế các cửa sổ lưu giữ trên các bảng spend, nên không có gì tăng trưởng vô hạn. Nếu không có [giới hạn chi tiêu](/en/claude-apps-gateway-spend-limits) được cấu hình, chỉ `kv` được ghi. Nếu chính sách bảo mật của bạn cấm DDL từ application role, hãy tạo trước các bảng này và `_migrations` bằng một admin role và cấp cho app role quyền `SELECT, INSERT, UPDATE, DELETE` trên mỗi bảng.

Khi giới hạn chi tiêu được sử dụng, mất database nghĩa là mất theo dõi chi tiêu và các trần, không chỉ là việc lập trình viên phải đăng nhập lại, nên hãy chạy backup thường xuyên. Để xóa ngay một lập trình viên đã rời đi thay vì chờ đợi thời gian lưu giữ, chạy `DELETE FROM principal_emails WHERE principal = '<sub>'` trực tiếp; điều đó xóa bảng duy nhất giữ email, tên và group của họ. Các dòng `spend` và `admin_audit` chỉ tham chiếu tới `sub` OIDC ẩn danh.

### Nâng cấp

Các replica là stateless, nên một lần rolling restart là an toàn bất cứ lúc nào. Gateway chạy các migration schema lúc khởi động, nghĩa là triển khai binary mới sẽ tự migrate database. Nếu database role không thể chạy DDL, hãy tạo trước schema, bao gồm bảng `_migrations` được seed tới phiên bản hiện tại; nếu không quá trình khởi động thất bại khi thử `CREATE TABLE`.

Các migration là append-only, nên rollback về một binary trước đó biết ít migration hơn là an toàn; nó bỏ qua các dòng thừa. Rollback cũng xác thực lại YAML so với schema của binary cũ hơn, nên một config đã áp dụng một key được giới thiệu bởi bản phát hành mới hơn sẽ thất bại khi khởi động trên bản cũ hơn. Xóa key mới trước khi rollback.

Bởi vì bạn ghim phiên bản của gateway trong image của riêng mình, các bản vá trong các bản phát hành Claude Code mới, bao gồm cả các bản vá bảo mật, chỉ đến được deployment của bạn khi bạn cập nhật ghim và triển khai lại. Hãy đưa gateway vào cùng nhịp vá lỗi mà bạn dùng cho các dịch vụ khác giữ credential production.

## Bảo mật

Mục này trả lời các câu hỏi mà một cuộc rà soát bảo mật đặt ra: dữ liệu nào chảy qua gateway và đi đâu, thiết kế phòng thủ chống lại những cuộc tấn công nào, và những câu trả lời nào thuộc về một bảng câu hỏi tuân thủ.

### Luồng dữ liệu

| Dữ liệu                                                                                            | Đường đi                                                     | Được gateway gửi tới Anthropic                     |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------- |
| Inference (prompt, completion)                                                                     | CLI → gateway → upstream của bạn                             | Chỉ khi Anthropic API là một upstream được cấu hình |
| Telemetry (OTLP metrics, cộng với [log và trace opt-in](/en/claude-apps-gateway-config#telemetry)) | CLI → gateway → bộ thu thập của bạn                          | Không bao giờ                                      |
| Danh tính (email, groups, sub)                                                                     | IdP → gateway → JWT → CLI; CLI đóng dấu nó lên các export OTLP | Không bao giờ                                      |
| Managed settings                                                                                   | YAML gateway của bạn → CLI                                   | Không bao giờ                                      |
| Log audit                                                                                          | stderr gateway → bộ tổng hợp của bạn                         | Không bao giờ                                      |

### Tóm tắt mô hình mối đe dọa (threat model)

Gateway nằm bên trong vành đai mạng của bạn, nhưng các laptop cá nhân của lập trình viên không được coi là đáng tin cậy. Thiết kế tính đến điều này theo ba cách:

* Lập trình viên giữ các JWT ngắn hạn thay vì các key upstream thô. Chặng CLI-tới-gateway dùng device grant RFC 8628, và việc trao đổi authorization-code của gateway với IdP chạy PKCE trong cấu hình mặc định, nên một authorization code IdP bị chặn cũng vô dụng.
* Trang xác minh device cưỡng chế POST same-origin và một rate limit theo từng IP theo RFC 8628 §5.1. Xem [Khả năng chống brute-force user-code](#user-code-brute-force-resistance).
* Các request đi ra ngoài đi qua một guard chống server-side request forgery (SSRF) vốn phân giải DNS, chặn các địa chỉ link-local và cloud-metadata cùng với loopback theo mặc định, và ghim kết nối vào IP đã phân giải, nên các URL do operator ảnh hưởng như đích IdP và OTLP không thể bị chuyển hướng tới các cloud metadata endpoint. Các dải riêng tư RFC 1918 được cố ý cho phép, vì IdP và OTLP collector thường nằm trên các IP riêng tư. Đối với phát triển cục bộ so với một IdP hoặc collector loopback, đặt `CLAUDE_GATEWAY_ALLOW_LOOPBACK=1` trong môi trường của gateway; để nó không được đặt trong production.

Nếu bạn thêm các kiểm soát egress của riêng mình, gateway phải tiếp cận được metadata server bất cứ khi nào nó dùng credential instance-metadata như workload identity.

Hai mối đe dọa nằm ngoài phạm vi vì chúng là hạ tầng của bạn cần bảo vệ:

* **Một host gateway bị xâm phạm**: host vừa giữ credential upstream vừa phân phối [managed settings](/en/claude-apps-gateway-config#managed) tới mọi lập trình viên đã kết nối, nên kiểm soát cấu hình của gateway tương đương với kiểm soát MDM của bạn. Hộp thoại phê duyệt một lần của CLI cho các cài đặt có khả năng chạy shell giới hạn các thay đổi âm thầm nhưng không thay thế cho bảo mật host.
* **Một nhà cung cấp OIDC độc hại**: nhà cung cấp ký các id\_token mà gateway tin cậy, nên nó có thể khẳng định bất kỳ danh tính nào. Việc thẩm định và bảo vệ IdP của bạn là trách nhiệm của bạn.

### Khả năng chống brute-force user-code

`user_code` mà lập trình viên gõ vào trang xác minh `/device` gồm 8 ký tự rút từ một bảng chữ cái 20 ký tự, cho ra 20⁸ hay khoảng 2,56×10¹⁰ tổ hợp, và nó hết hạn sau 10 phút.

Gateway áp dụng rate limit theo từng IP trên các device-grant endpoint, có thể cấu hình qua [`rate_limits`](/en/claude-apps-gateway-config#http-tuning). Tăng các giới hạn nếu nhiều lập trình viên đăng nhập từ một địa chỉ NAT doanh nghiệp dùng chung duy nhất. Các giới hạn chỉ áp dụng cho luồng đăng nhập, không cho inference.

### Tư thế tuân thủ

* **Nơi cư trú dữ liệu (data residency)**: bản thân data plane của gateway không gửi gì tới Anthropic trừ khi Anthropic API là một upstream được cấu hình; khi nó là như vậy, thỏa thuận xử lý dữ liệu hiện có của bạn áp dụng cho đường inference. Telemetry, audit, danh tính, và settings chỉ đi tới các đích bạn cấu hình.
* **Traffic của tiến trình host**: tiến trình host là Claude Code CLI, vốn có thể gửi analytics khởi động và kiểm tra cập nhật tới Anthropic. Đối với các deployment egress nghiêm ngặt, đặt `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` trong môi trường container của gateway.
* **Analytics của client**: CLI tắt analytics sử dụng của chính nó khi đã đăng nhập vào một gateway, và báo cáo lỗi được tắt theo mặc định trên các bề mặt API bên thứ ba.
* **Máy của client**: CLI của lập trình viên vẫn gửi các kiểm tra hostname WebFetch và kiểm tra phiên bản tới Anthropic trừ khi `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` và `skipWebFetchPreflight: true` được đặt. Xem [cách sử dụng dữ liệu](/en/data-usage).
* **Đánh giá khảo sát**: credential gateway tắt sink đánh giá hướng-Anthropic, nên các đánh giá không được gửi tới Anthropic.
* **Chia sẻ bản ghi (transcript)**: chọn Yes trên lời nhắc chia sẻ transcript của một khảo sát sẽ ghi một file cục bộ dưới `~/.claude/feedback-bundles/` thay vì tải lên Anthropic.
* **Cập nhật client**: kiểm tra cập nhật tách biệt với traffic gateway. Ghim phiên bản qua phân phối của riêng bạn và đặt `DISABLE_UPDATES` nếu laptop không được phép tải các bản phát hành. `DISABLE_AUTOUPDATER` chỉ dừng các cập nhật nền trong khi `claude update` vẫn hoạt động.
* **TLS**: phục vụ `public_url` qua HTTPS trong production, hoặc từ listener của chính gateway qua `listen.tls`, hoặc từ một ingress terminate TLS ở phía trước các replica HTTP thuần với `listen.public_url` được đặt. Gateway không từ chối HTTP thuần. IdP phải phục vụ HTTPS trong production, và Postgres hỗ trợ `?sslmode=require`. Đặt `Strict-Transport-Security` tại ingress của bạn.
* **Công bố lỗ hổng**: làm theo [Báo cáo các vấn đề bảo mật](/en/security#reporting-security-issues)

## Khắc phục sự cố

Với các câu hỏi và phản hồi, hãy dùng [hỗ trợ Claude Code](https://support.claude.com/en/collections/14445694-claude-code), hoặc mở một issue trên [kho GitHub Claude Code](https://github.com/anthropics/claude-code/issues). Khi báo cáo một vấn đề, hãy kèm theo:

* **Vấn đề gateway**: stderr của gateway cho khoảng thời gian liên quan, `gateway.yaml` của bạn với secret đã che, phiên bản gateway, hiển thị trên trang đích tại `/` và trong response header `x-cc-gateway-version` trên `/managed/settings`, và những gì đã thay đổi gần đây
* **Vấn đề đăng nhập**: lập trình viên chạy `claude --debug-file ./claude-debug.txt`, tái hiện, và gửi file đó cùng với log audit của gateway cho cùng khoảng thời gian
* **Vấn đề inference**: model được yêu cầu, các upstream được cấu hình, và log audit của gateway cho request, vốn ghi lại upstream nào phục vụ nó và trạng thái phản hồi

| Triệu chứng                                                                                                                                                                | Nguyên nhân                                                                                                                                                                                                                                                                                                                  | Cách khắc phục                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/login` của một lập trình viên hiển thị bộ chọn tài khoản tiêu chuẩn thay vì màn hình **Cloud gateway**                                                                    | `forceLoginMethod` hoặc `forceLoginGatewayUrl` không được đặt trong managed settings trên máy đó                                                                                                                                                                                                                            | Triển khai [file managed settings](/en/claude-apps-gateway#set-the-gateway-url) tới thiết bị; `/login` đọc URL gateway từ đó                                                                                                                                                                                                                                                                                                             |
| Khởi động hiển thị `Gateway login is configured in managed settings, but this Claude Code build does not include Cloud gateway support.`                                    | Bản build Claude Code đã cài có trước khi có hỗ trợ gateway                                                                                                                                                                                                                                                                 | Yêu cầu lập trình viên cập nhật Claude Code lên một bản phát hành có hỗ trợ Cloud gateway                                                                                                                                                                                                                                                                                                                                                |
| CLI `/login`: `Gateway hosts must be on your organization's private network; <host> resolves to the public (or unrecognized) address <ip>`                                 | Hostname gateway phân giải ra ít nhất một địa chỉ IP công khai. Claude Code kiểm tra mỗi địa chỉ đã phân giải và yêu cầu mọi địa chỉ phải là riêng tư. Một nguyên nhân phổ biến là tên dual-stack nơi một họ địa chỉ phân giải ra địa chỉ công khai, bao gồm các internal dual-stack load balancer của AWS, vốn trả về địa chỉ AAAA dải công khai | Làm cho tên gateway chỉ phân giải ra các địa chỉ riêng tư trên máy lập trình viên. Đối với tên dual-stack, bỏ bản ghi dải công khai hoặc phục vụ một tên DNS chỉ nội bộ riêng. Xem [điều kiện tiên quyết mạng riêng](/en/claude-apps-gateway#prerequisites).                                                                                                                                                                              |
| CLI `/login`: `Gateway login requires a direct connection and does not support connecting through an HTTP proxy`                                                            | Một `HTTPS_PROXY` hoặc `HTTP_PROXY` áp dụng cho host gateway và hostname của proxy phân giải ra một địa chỉ công khai. Một proxy có host chỉ phân giải ra các địa chỉ riêng tư được cho phép và không kích hoạt lỗi này                                                                                                        | Thêm host gateway vào `NO_PROXY` trên máy của lập trình viên để kết nối là trực tiếp, hoặc dùng một proxy có hostname phân giải ra các địa chỉ riêng tư                                                                                                                                                                                                                                                                                  |
| CLI `/login`: `Could not resolve gateway host <host>`                                                                                                                      | Máy không thể phân giải tên DNS nội bộ của gateway, thường vì nó không ở trên mạng doanh nghiệp                                                                                                                                                                                                                              | Yêu cầu lập trình viên kết nối vào mạng hoặc VPN của bạn, rồi thử lại `/login`                                                                                                                                                                                                                                                                                                                                                          |
| Khởi động thoát với một lỗi validation config nêu tên `store.postgres_url`                                                                                                  | Không có Postgres được cấu hình; gateway yêu cầu Postgres                                                                                                                                                                                                                                                                   | Đặt `store.postgres_url`. Đối với phát triển cục bộ, dùng một container tạm: `docker run --rm -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres`.                                                                                                                                                                                                                                                                                 |
| Khởi động thoát: `requires the native binary`                                                                                                                              | Đang chạy dưới Node thay vì binary native                                                                                                                                                                                                                                                                                  | Cài Claude Code bằng một trong các [phương pháp cài standalone](/en/setup)                                                                                                                                                                                                                                                                                                                                                              |
| Khởi động thoát với một lỗi OIDC discovery sau `config.load`                                                                                                                | `oidc.issuer` không tiếp cận được, hoặc chuỗi TLS không được tin cậy                                                                                                                                                                                                                                                        | Kiểm tra issuer có thể tiếp cận từ pod và phục vụ `/.well-known/openid-configuration`. Đặt `ca_cert_pem` cho PKI riêng.                                                                                                                                                                                                                                                                                                                 |
| Khởi động thoát với một lỗi quyền Postgres                                                                                                                                  | App role thiếu quyền `CREATE TABLE`                                                                                                                                                                                                                                                                                         | Tạo trước schema bằng một admin role và cấp DML cho app role, hoặc cấp DDL tạm thời cho các lần khởi động áp dụng migration mới                                                                                                                                                                                                                                                                                                          |
| `/oauth/callback` hiển thị "Sign-in could not be completed"                                                                                                                | Email domain bị từ chối, xác thực id\_token thất bại, hoặc `email_verified` rõ ràng là `false`, điều mà gateway luôn từ chối không có override                                                                                                                                                                               | Kiểm tra `allowed_email_domains` và rằng IdP trả về một claim `email` đã xác minh. Đối với `email_verified: false`, sửa việc xác minh phía IdP. Nếu IdP của bạn phát email dưới một tên claim khác, đặt `oidc.email_claim`.                                                                                                                                                                                                               |
| Log: `token exchange failed: id_token missing email claim`                                                                                                                 | IdP không bao gồm `email` trong id\_token theo mặc định. Việc từ chối này chỉ kích hoạt khi `allowed_email_domains` được đặt; không có nó, một email thiếu vẫn mint một phiên không có email                                                                                                                                  | Cấu hình IdP để phát `email` trong id\_token. Okta: thêm `email` vào các ID-token claim của một custom authorization server. Entra: thêm `email` như một optional claim trên app registration. PingFederate: bật một OpenID Connect Policy phát `email`. Nếu IdP phục vụ `email` từ userinfo endpoint nhưng không đưa nó vào id\_token, như Okta org authorization server, đặt `oidc.userinfo_fallback: true`.                             |
| Mọi request Amazon Bedrock trả về 502; log hiển thị `Could not load credentials from any providers`                                                                        | Trên EC2, hop limit mặc định là 1 của IMDSv2 chặn request instance-metadata từ bên trong container. Khởi động và `/readyz` vẫn pass vì AWS SDK phân giải credential instance ở request đầu tiên, không phải lúc xây dựng client                                                                                               | Tăng hop limit bằng `aws ec2 modify-instance-metadata-options --instance-id <id> --http-put-response-hop-limit 2`, hoặc đặt nó trong launch template. Thay đổi áp dụng cho mọi container trên instance. Ưu tiên ECS task role nơi có sẵn, vốn đọc credential từ ECS container-credentials endpoint và tránh thay đổi hoàn toàn, hoặc áp dụng thay đổi trên một instance gateway riêng để hạn chế phơi nhiễm.                                |
| Lỗi IdP: unknown or unsupported scope                                                                                                                                      | IdP từ chối các scope nó không nhận ra                                                                                                                                                                                                                                                                                      | Đặt `oidc.scopes` chính xác thành danh sách mà IdP của bạn chấp nhận; nó phải bao gồm `openid`. Mặc định là `openid profile email offline_access`.                                                                                                                                                                                                                                                                                      |
| Các phiên không tự động gia hạn âm thầm sau khi đặt `oidc.scopes`                                                                                                           | `offline_access` đã bị bỏ khỏi override                                                                                                                                                                                                                                                                                     | Thêm lại `offline_access` nếu IdP của bạn hỗ trợ nó. Không có refresh token, lập trình viên phải chạy lại đăng nhập trình duyệt mỗi `session.ttl_hours`.                                                                                                                                                                                                                                                                                 |
| Trình duyệt hiển thị "This request came from another site and was blocked"                                                                                                 | Form POST cross-site, bị chặn như bảo vệ CSRF. Điều này dự kiến với các trang nhúng hoặc proxy                                                                                                                                                                                                                              | Mở liên kết xác minh trực tiếp                                                                                                                                                                                                                                                                                                                                                                                                          |
| Chrome chặn nút Approve với "Refused to send form data … violates … Content Security Policy directive: form-action", nhưng cùng trang đó hoạt động trong Safari hoặc Firefox | Chrome cưỡng chế `form-action` so với toàn bộ chuỗi redirect. IdP của bạn redirect tiếp tới một host thứ hai không nằm trong allowlist.                                                                                                                                                                                       | Thêm mỗi origin bổ sung trong chuỗi redirect vào `oidc.form_action_origins`. Mở Chrome DevTools → Console trên trang Approve để xem origin nào bị chặn.                                                                                                                                                                                                                                                                                  |
| Đăng nhập hoàn tất tại IdP nhưng callback thất bại, với một lỗi CSP trong Chrome hoặc "this sign-in link has expired" trong Safari                                          | IdP trả code qua `response_mode=form_post`, vốn tự động submit nó cross-origin qua POST tới `/oauth/callback`. Chrome chặn điều đó dưới một CSP nghiêm ngặt; Safari cho phép submit nhưng callback chỉ đọc query string.                                                                                                     | Đảm bảo IdP của bạn tôn trọng `response_mode=query`, điều mà gateway yêu cầu một cách rõ ràng để callback là một redirect thuần                                                                                                                                                                                                                                                                                                          |
| Đăng nhập hoạt động cục bộ nhưng thất bại sau một ALB                                                                                                                       | `public_url` không được đặt, nên IdP nhận origin `http://` bên trong làm `redirect_uri`                                                                                                                                                                                                                                     | Đặt `listen.public_url` thành origin `https://` bên ngoài                                                                                                                                                                                                                                                                                                                                                                               |
| Lập trình viên thấy lời nhắc trust lặp đi lặp lại                                                                                                                           | Chứng chỉ TLS đang xoay vòng theo từng replica hoặc theo từng request                                                                                                                                                                                                                                                      | Dùng một chứng chỉ ổn định tại ingress, hoặc terminate TLS một lần và chạy các replica qua HTTP thuần trong nội bộ                                                                                                                                                                                                                                                                                                                       |
| CLI `/login`: "Could not verify the gateway's TLS certificate" hoặc `SELF_SIGNED_CERT_IN_CHAIN`                                                                             | Chuỗi TLS của gateway được ký bởi một CA riêng không có trong trust store của host CLI                                                                                                                                                                                                                                       | Claude Code đọc trust store của OS theo mặc định trên binary native và trên Node 22.15 trở lên; [`CLAUDE_CODE_CERT_STORE`](/en/network-config#ca-certificate-store) điều khiển hành vi này. Nếu CA đã được cài trong trust store của OS, đảm bảo lập trình viên dùng runtime hiện hành. Nếu không, đặt `NODE_EXTRA_CA_CERTS` tới file PEM chứng chỉ CA trước khi khởi chạy. Lời nhắc fingerprint lần đầu kết nối vẫn áp dụng.              |

## Liên quan

* [Tổng quan Claude apps gateway](/en/claude-apps-gateway): quickstart và kết nối lập trình viên
* [Tài liệu tham chiếu cấu hình](/en/claude-apps-gateway-config): mọi tùy chọn `gateway.yaml`
