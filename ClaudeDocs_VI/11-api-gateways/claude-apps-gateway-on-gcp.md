> Nguồn: https://code.claude.com/docs/en/claude-apps-gateway-on-gcp.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Triển khai Claude apps gateway trên Google Cloud

> Một ví dụ thực hành về việc chạy Claude apps gateway trên Google Cloud: Cloud Run hoặc GKE, Cloud SQL for PostgreSQL, Secret Manager, và xác thực bằng service-account tới Agent Platform của Google Cloud.

<Note>
  Trang này hướng dẫn một cách chạy Claude apps gateway trên Google Cloud. Cấu hình này là một ví dụ đang hoạt động cho hạ tầng do khách hàng tự quản lý, chứ không phải một deployment production được hỗ trợ; hãy dùng nó để xem các mảnh ghép khớp với nhau như thế nào trước khi điều chỉnh cho môi trường của riêng bạn. Đối với các yêu cầu độc lập nền tảng, xem [hướng dẫn triển khai](/en/claude-apps-gateway-deploy).
</Note>

Ví dụ này provision Claude apps gateway trên Google Cloud với Agent Platform của Google Cloud làm model upstream, sử dụng Cloud Run hoặc GKE cho compute. Google Workspace là nhà cung cấp danh tính (IdP) ví dụ, nhưng bất kỳ IdP tuân thủ OpenID Connect (OIDC) nào đều dùng được; chỉ khối `oidc` thay đổi. Xem [Thiết lập nhà cung cấp danh tính](/en/claude-apps-gateway-deploy#identity-provider-setup) để biết chi tiết theo từng IdP.

## Những gì bạn sẽ xây dựng

<Frame>
  <img src="https://mintcdn.com/claude-code/-uq-4JE0W_JO5Er5/images/claude-gateway-gcp-architecture.svg?fit=max&auto=format&n=-uq-4JE0W_JO5Er5&q=85&s=cb705151c69128ac0da235852d5600ab" alt="Diagram of Claude apps gateway on Google Cloud: Claude Code clients connect over HTTPS to the gateway (Cloud Run or GKE), which runs inside a VPC alongside a private-IP Cloud SQL database for session state. The gateway signs users in via OIDC against Google Workspace, reads config and secrets from Secret Manager, forwards model requests to Google Cloud's Agent Platform, and pulls its image from Artifact Registry at deploy." width="760" height="400" data-path="images/claude-gateway-gcp-architecture.svg" />
</Frame>

Cấu hình tham chiếu này provision:

* Dịch vụ **Cloud Run** hoặc Deployment **GKE** chạy container gateway
* Kho **Artifact Registry** cho image gateway
* Instance **Cloud SQL for PostgreSQL**, chỉ private IP, cho [store](/en/claude-apps-gateway-config#store) của gateway
* Các secret **Secret Manager** cho `gateway.yaml`, JWT signing key, OIDC client secret, và Postgres URL
* **Service account** với `roles/aiplatform.user`, gắn trực tiếp trên Cloud Run hoặc bind qua Workload Identity trên GKE
* **Internal Application Load Balancer** trên Cloud Run, hoặc một **GKE Ingress** nội bộ lớp `gce-internal` trên GKE, cho HTTPS

## Điều kiện tiên quyết

* Một dự án GCP đã bật billing, và quyền tạo các tài nguyên ở trên
* CLI `gcloud`, đã xác thực bằng `gcloud auth login`, và Docker được cài cục bộ
* Đối với hướng GKE: `kubectl`, và một cụm GKE trên VPC được tạo trong hướng dẫn bên dưới
* Quyền truy cập các model Claude bạn cần trong Model Garden, tại một region có công bố chúng
* Một OAuth 2.0 web-application client của Google Workspace với redirect URI `https://<gateway-host>/oauth/callback`; xem [Thiết lập nhà cung cấp danh tính](/en/claude-apps-gateway-deploy#identity-provider-setup)
* Một hostname TLS cho gateway, thường là một tên DNS nội bộ trỏ tới load balancer

Đặt dự án và region một lần:

```bash theme={null}
export PROJECT_ID=<your-project>
export REGION=us-east5   # a region where the Claude models you need are published in Model Garden
gcloud config set project "$PROJECT_ID"
```

## Triển khai gateway

Các bước bên dưới provision toàn bộ deployment bằng các lệnh `gcloud`.

<Steps>
  <Step title="Bật các API">
    Bật các service API mà hướng dẫn sử dụng:

    ```bash theme={null}
    gcloud services enable \
      aiplatform.googleapis.com \
      artifactregistry.googleapis.com \
      sqladmin.googleapis.com \
      secretmanager.googleapis.com \
      iamcredentials.googleapis.com \
      iam.googleapis.com \
      compute.googleapis.com \
      servicenetworking.googleapis.com \
      run.googleapis.com \
      container.googleapis.com
    ```

    Các API bạn cần phụ thuộc vào đường triển khai:

    * `compute` và `servicenetworking`: cần cho đường Cloud SQL private-IP
    * `run`: chỉ Cloud Run
    * `container`: chỉ GKE
  </Step>

  <Step title="Tạo service account và cấp IAM">
    Gateway chạy như một service account chuyên dụng có quyền gọi Agent Platform của Google Cloud. Nó tiếp cận Cloud SQL qua VPC bằng một user mật khẩu, nên không cần role IAM Cloud SQL nào:

    ```bash theme={null}
    gcloud iam service-accounts create claude-gateway --display-name="Claude apps gateway"
    SA="claude-gateway@${PROJECT_ID}.iam.gserviceaccount.com"

    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:${SA}" --role="roles/aiplatform.user" --condition=None
    ```

    Sau đó bật các model Claude cho dự án trong Model Garden; các model công bố đến các region cụ thể, nên hãy kiểm tra từng model card.
  </Step>

  <Step title="Build và push image tới Artifact Registry">
    Build image theo [yêu cầu image container](/en/claude-apps-gateway-deploy#container-image), sử dụng binary glibc `linux-x64`, và push nó:

    ```bash theme={null}
    gcloud artifacts repositories create claude-gateway \
      --repository-format=docker --location="$REGION"
    gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

    # Cloud Run requires linux/amd64. --provenance=false avoids a buildx OCI
    # image index that Cloud Run rejects.
    docker build --platform=linux/amd64 --provenance=false \
      -t "${REGION}-docker.pkg.dev/${PROJECT_ID}/claude-gateway/gateway:<version>" .
    docker push "${REGION}-docker.pkg.dev/${PROJECT_ID}/claude-gateway/gateway:<version>"
    ```
  </Step>

  <Step title="Provision Cloud SQL for PostgreSQL">
    Tạo instance trên một VPC qua Private Services Access để nó không có public IP; điều này cũng thỏa mãn các dự án nơi `constraints/sql.restrictPublicIp` được cưỡng chế:

    ```bash theme={null}
    VPC=cc-gateway-vpc
    gcloud compute networks create "$VPC" --subnet-mode=custom
    gcloud compute networks subnets create cc-gateway-subnet \
      --network="$VPC" --region="$REGION" --range=10.0.0.0/24

    # Private Services Access: one-time per VPC
    gcloud compute addresses create "google-managed-services-${VPC}" \
      --global --purpose=VPC_PEERING --prefix-length=16 --network="$VPC"
    gcloud services vpc-peerings connect \
      --service=servicenetworking.googleapis.com \
      --ranges="google-managed-services-${VPC}" --network="$VPC"

    gcloud sql instances create claude-gateway-db \
      --database-version=POSTGRES_16 --tier=db-g1-small --region="$REGION" \
      --network="projects/${PROJECT_ID}/global/networks/${VPC}" --no-assign-ip
    gcloud sql databases create claude_gateway --instance=claude-gateway-db
    PGPASS="$(openssl rand -hex 24)"
    gcloud sql users create gateway --instance=claude-gateway-db --password="$PGPASS"

    PRIVATE_IP="$(gcloud sql instances describe claude-gateway-db \
      --format='value(ipAddresses[0].ipAddress)')"
    GATEWAY_POSTGRES_URL="postgres://gateway:${PGPASS}@${PRIVATE_IP}:5432/claude_gateway?sslmode=require"
    ```

    Runtime Cloud Run hoặc GKE phải nằm trên, hoặc được route vào, VPC này.
  </Step>

  <Step title="Viết gateway.yaml">
    Khối `upstreams` trỏ tới Agent Platform của Google Cloud với `auth: {}`, nên gateway xác thực qua Application Default Credentials từ service account của runtime. Xem [tài liệu tham chiếu cấu hình](/en/claude-apps-gateway-config) để biết mọi trường.

    Hai trường `listen` phụ thuộc vào cái gì đứng trước gateway:

    * `public_url`: bắt buộc sau Cloud Run hoặc một GKE Ingress. Gateway xây `redirect_uri` IdP và tài liệu discovery của nó chỉ từ giá trị này, không bao giờ từ các header `X-Forwarded-*`.
    * `trusted_proxies`: các dải nguồn của front end. Gateway chỉ tôn trọng `X-Forwarded-For` khi TCP peer nằm trong danh sách này, rồi đi qua chuỗi vượt các hop đáng tin cậy, nên rate limit đăng nhập theo từng IP và các sự kiện audit ghi lại IP của lập trình viên thay vì của load balancer.

    Đặt `trusted_proxies` khớp với front end của bạn. Một GKE Ingress bên ngoài lớp `gce` không được liệt kê: nó provision một địa chỉ forwarding-rule công khai, mà [kiểm tra mạng riêng](/en/claude-apps-gateway#prerequisites) của `/login` từ chối.

    | Front end                                                | `trusted_proxies`                                   |
    | -------------------------------------------------------- | --------------------------------------------------- |
    | Cloud Run được tiếp cận trực tiếp, không có load balancer | `[169.254.0.0/16]`                                  |
    | Internal Application Load Balancer ở phía trước Cloud Run | `169.254.0.0/16` cộng với CIDR của proxy-only subnet của bạn |
    | GKE internal Ingress, lớp `gce-internal`                 | CIDR của proxy-only subnet của bạn                  |

    Ví dụ bên dưới dùng các giá trị internal-load-balancer-ở-phía-trước-Cloud-Run.

    ```yaml gateway.yaml theme={null}
    listen:
      host: 0.0.0.0
      port: 8080
      public_url: https://claude-gateway.internal.example.com
      trusted_proxies: [169.254.0.0/16, <your-proxy-only-subnet-cidr>]

    oidc:
      issuer: https://accounts.google.com
      client_id: <your-oauth-client-id>
      client_secret: ${OIDC_CLIENT_SECRET}           # GKE: ${file:/secrets/oidc-client-secret}
      allowed_email_domains: [example.com]
      # Google ignores offline_access; these yield refresh tokens:
      scopes: [openid, profile, email]
      extra_auth_params: { access_type: offline, prompt: consent }

    session:
      jwt_secret: ${GATEWAY_JWT_SECRET}              # GKE: ${file:/secrets/jwt-secret}

    store:
      postgres_url: ${GATEWAY_POSTGRES_URL}          # GKE: ${file:/secrets/postgres-url}

    upstreams:
      - provider: vertex
        region: <your-region>                        # must match $REGION
        project_id: <your-project>
        auth: {}                                     # ADC via the runtime service account
    ```

    <Note>
      id\_token của Google không mang claim `groups`. Để dùng các chính sách dựa trên group trong [`managed.policies`](/en/claude-apps-gateway-config#managed) với Google Workspace làm IdP, cấu hình [`oidc.google_groups`](/en/claude-apps-gateway-config#oidc), nó tra cứu group của mỗi người dùng qua Admin SDK Directory API bằng một service account có domain-wide delegation. Nếu không có nó, hãy khớp trên `email_domain` thay vào đó.
    </Note>
  </Step>

  <Step title="Lưu trữ secret trong Secret Manager">
    Tạo bốn secret và cấp `roles/secretmanager.secretAccessor` cho service account `claude-gateway`:

    | Secret                       | Nguồn                                            |
    | ---------------------------- | ------------------------------------------------ |
    | `gateway-jwt-secret`         | `openssl rand -base64 32`                        |
    | `gateway-oidc-client-secret` | Google Cloud Console → OAuth client              |
    | `gateway-postgres-url`       | `$GATEWAY_POSTGRES_URL` từ bước Cloud SQL         |
    | `gateway-config`             | toàn bộ `gateway.yaml` từ bước trước              |

    Cách các secret đến được container khác nhau theo từng hướng:

    * Trên GKE chúng mount dưới dạng file qua Secret Manager CSI driver, và `gateway.yaml` tham chiếu `${file:/secrets/...}`.
    * Trên Cloud Run, vốn không thể mount nhiều secret vào một thư mục, `gateway.yaml` mount dưới dạng file và ba secret còn lại được inject dưới dạng biến môi trường, nên `gateway.yaml` tham chiếu `${GATEWAY_JWT_SECRET}`, `${OIDC_CLIENT_SECRET}`, và `${GATEWAY_POSTGRES_URL}` thay vào đó.
  </Step>

  <Step title="Triển khai">
    <Tabs>
      <Tab title="Cloud Run">
        Lệnh bên dưới triển khai cho production sau một internal load balancer.

        ```bash theme={null}
        gcloud run deploy claude-gateway \
          --image="${REGION}-docker.pkg.dev/${PROJECT_ID}/claude-gateway/gateway:<version>" \
          --region="$REGION" \
          --service-account="claude-gateway@${PROJECT_ID}.iam.gserviceaccount.com" \
          --min-instances=1 \
          --timeout=3600 \
          --ingress=internal-and-cloud-load-balancing \
          --network="$VPC" --subnet=cc-gateway-subnet --vpc-egress=private-ranges-only \
          --set-secrets=/etc/claude/gateway.yaml=gateway-config:latest,GATEWAY_JWT_SECRET=gateway-jwt-secret:latest,OIDC_CLIENT_SECRET=gateway-oidc-client-secret:latest,GATEWAY_POSTGRES_URL=gateway-postgres-url:latest \
          --no-invoker-iam-check
        ```

        Direct VPC egress, qua `--network`, `--subnet`, và `--vpc-egress=private-ranges-only`, cho phép dịch vụ tiếp cận private IP của Cloud SQL trực tiếp. Egress công khai tới các endpoint Agent Platform của Google Cloud và `accounts.google.com` đi thẳng ra internet thay vì qua VPC, nên không cần Cloud NAT.

        Kiểm tra invoker IAM phải mở hoặc bị vô hiệu hóa. Gateway chạy OIDC của riêng nó và các client của nó không mang token GCP, nên kiểm tra invoker của Cloud Run phải cho phép các request không xác thực. Đăng nhập OIDC của gateway xác thực request khi nó đến được container, với `allowed_email_domains` giới hạn domain nào được đăng nhập.

        Hai flag cho phép các request không xác thực:

        * `--no-invoker-iam-check`: vô hiệu hóa kiểm tra mà không có binding `allUsers` nào phải quản lý, và hoạt động dưới Domain Restricted Sharing
        * `--allow-unauthenticated`: cấp cho `allUsers` role `run.invoker`; dùng nó nếu tổ chức của bạn không cho phép `--no-invoker-iam-check`

        Hạn chế ingress qua `--ingress` là một lớp riêng biệt, độc lập với kiểm tra invoker; giữ nó được đặt để giới hạn dịch vụ trong mạng doanh nghiệp của bạn.

        Theo mặc định URL `*.run.app` của Cloud Run phân giải ra một địa chỉ công khai, mà [kiểm tra mạng riêng](/en/claude-apps-gateway#prerequisites) của `/login` từ chối. Hai topology cho lập trình viên một hostname có thể phân giải riêng tư, và Cloud Run không provision cái nào cho bạn:

        * **Internal Application Load Balancer**, topology mà lệnh deploy ở trên giả định: triển khai với `--ingress=internal-and-cloud-load-balancing`, provision một internal Application Load Balancer ở phía trước dịch vụ với một tên DNS nội bộ và chứng chỉ, và đặt `listen.public_url` thành hostname đó.
        * **Internal-only ingress không có load balancer**: triển khai với `--ingress=internal` và để `listen.public_url` là URL `*.run.app`, mặc định trong [reference asset](#terraform-reference) bên dưới. Để `*.run.app` phân giải riêng tư, nhóm mạng của bạn phải đã vận hành một Private Service Connect endpoint cho Google APIs, một Cloud DNS private zone phân giải `*.run.app` tới nó, và routing on-premises tới endpoint đó.

        [Hướng dẫn private networking cho Cloud Run](https://cloud.google.com/run/docs/securing/private-networking) của Google bao gồm hạ tầng mà cả hai tùy chọn cần. Xác minh đăng nhập một khi gateway đang phục vụ trên một hostname riêng tư; cho đến lúc đó, xác nhận container đã khởi động từ log của nó trong Cloud Run.

        Cập nhật authorized redirect URI của OAuth client thành `<public_url>/oauth/callback` trước lần đăng nhập đầu tiên. Triển khai lại sau khi thay đổi `public_url`, vì gateway xây origin công khai của nó chỉ từ cài đặt đó và bỏ qua `X-Forwarded-Host` và `X-Forwarded-Proto`. `X-Forwarded-For` chỉ được tôn trọng cho IP client khi `listen.trusted_proxies` được đặt.
      </Tab>

      <Tab title="GKE">
        Cụm phải nằm trên `$VPC` được tạo trong bước Cloud SQL để các pod có thể tiếp cận private IP của database; chỉ VPC peering không hoạt động, vì Cloud SQL private IP tự nó là một mạng peered và peering là không bắc cầu (non-transitive). Để tạo một cụm mới trên VPC đó, truyền `--network="$VPC" --subnetwork=cc-gateway-subnet` cho `gcloud container clusters create`.

        Bật Workload Identity trên cụm và các node pool của nó, rồi bind Google service account với Kubernetes service account để các pod kế thừa credential của nó:

        ```bash theme={null}
        gcloud container clusters update <cluster> --region="$REGION" \
          --workload-pool="${PROJECT_ID}.svc.id.goog"
        # On a Standard cluster, existing node pools also need GKE_METADATA;
        # Autopilot enables this by default.
        gcloud container node-pools update <pool> --cluster=<cluster> \
          --region="$REGION" --workload-metadata=GKE_METADATA

        kubectl create namespace claude-gateway
        kubectl create serviceaccount gateway -n claude-gateway

        gcloud iam service-accounts add-iam-policy-binding \
          "claude-gateway@${PROJECT_ID}.iam.gserviceaccount.com" \
          --role roles/iam.workloadIdentityUser \
          --member "serviceAccount:${PROJECT_ID}.svc.id.goog[claude-gateway/gateway]"

        kubectl annotate serviceaccount gateway -n claude-gateway \
          iam.gke.io/gcp-service-account="claude-gateway@${PROJECT_ID}.iam.gserviceaccount.com"
        ```

        Triển khai gateway như một Deployment tiêu chuẩn cộng với một Service và một internal Ingress, lớp `gce-internal`, như được mô tả trong [triển khai Kubernetes](/en/claude-apps-gateway-deploy#kubernetes), với:

        * `serviceAccountName: gateway`
        * Secret Manager CSI driver mount các secret tại `/secrets`
        * readiness probe trỏ tới `GET /readyz`

        Gắn một BackendConfig với `timeoutSec` được tăng vào Service gateway: backend service của load balancer sau GKE Ingress mặc định timeout 30 giây, vốn cắt đứt các phản hồi streaming dài.

        Đừng áp dụng một egress NetworkPolicy chặn `169.254.169.254` trên một cụm Workload Identity; pod phải tiếp cận metadata server để lấy credential. [SSRF guard](/en/claude-apps-gateway-deploy#threat-model-summary) tích hợp của gateway là biện pháp phòng thủ ở đó.

        Gateway ghi một cảnh báo khởi động rằng metadata endpoint có thể tiếp cận và đề xuất áp dụng một egress NetworkPolicy. Dưới Workload Identity cảnh báo đó là dự kiến, vì pod cần endpoint.
      </Tab>
    </Tabs>
  </Step>

  <Step title="Đẩy URL gateway tới máy của lập trình viên">
    Gateway giờ đã chạy, nhưng lập trình viên không thể tiếp cận nó từ `/login` cho đến khi URL gateway có trên máy của họ. Đặt `forceLoginMethod` và `forceLoginGatewayUrl` trong [file managed settings](/en/claude-apps-gateway#set-the-gateway-url) mà bạn triển khai tới từng thiết bị qua MDM. Không có tùy chọn gateway nào trong bộ chọn đăng nhập để lập trình viên chọn thủ công.
  </Step>
</Steps>

## Tài liệu tham chiếu Terraform

[Các reference deployment asset](https://github.com/anthropics/claude-code/tree/main/examples/gateway/gcp) tự động hóa hướng Cloud Run trên trang này; các asset config và image áp dụng cho cả hai hướng:

* `setup.sh`: một provisioner `gcloud` idempotent đi qua toàn bộ đường Cloud Run, từ bật API đến lần deploy đầu tiên
* `terraform/`: cùng deployment đó dưới dạng infrastructure-as-code, cho một triển khai greenfield: một apply có mục tiêu để tạo kho Artifact Registry, rồi build và push image, rồi một full apply
* `gateway.yaml.example` và một `Dockerfile` cho image runtime distroless

Các artifact mặc định Cloud Run ingress là `internal`, nên không cần load balancer. Để khớp với deployment production-sau-một-ALB của trang này, chạy `setup.sh` với `INGRESS=internal-and-cloud-load-balancing`, hoặc đặt biến Terraform `ingress` thành `INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER`. Các artifact cũng mặc định lớp invoker là một grant `run.invoker` cho `allUsers` thay vì `--no-invoker-iam-check`, ngược lại với hướng dẫn của trang này; cả hai đều dùng được, và lựa chọn phụ thuộc vào các ràng buộc chính sách của tổ chức bạn.

Các asset được cung cấp như các ví dụ đang hoạt động, không phải như một artifact production được hỗ trợ; hãy rà soát và điều chỉnh chúng cho môi trường của bạn.

## Khắc phục sự cố

Đối với các lỗi khởi động và đăng nhập gateway, xem [bảng khắc phục sự cố](/en/claude-apps-gateway-deploy#troubleshooting) độc lập nền tảng. Các mục bên dưới là dành riêng cho Google Cloud.

| Triệu chứng                                                                               | Nguyên nhân                                                                                                                          | Cách khắc phục                                                                                                                                                                                                              |
| ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cloud Run trả về `403 Forbidden` trước khi đến được container                             | Kiểm tra invoker IAM vẫn còn được bật                                                                                                | Triển khai với `--no-invoker-iam-check`, hoặc cấp cho `allUsers` role `run.invoker` bằng `--allow-unauthenticated`                                                                                                          |
| `--no-invoker-iam-check` bị từ chối với `invoker_iam_disabled is not currently available` | Bị chặn bởi `constraints/run.managed.requireInvokerIam`                                                                              | Dùng `--allow-unauthenticated`. Nếu Domain Restricted Sharing qua `constraints/iam.allowedPolicyMemberDomains` cũng chặn điều đó, dùng hướng GKE, vốn phơi bày gateway ở lớp mạng không có binding `allUsers`.               |
| `Container manifest type … must support amd64/linux` khi deploy                           | Image được build trên một host không phải amd64, hoặc buildx phát ra một OCI image index                                             | Build với `--platform=linux/amd64 --provenance=false`                                                                                                                                                                      |
| Khởi động gateway thoát với một lỗi connection-timeout Postgres trên Cloud Run            | Dịch vụ không được gắn vào VPC, hoặc Cloud SQL không có private IP trên VPC đó; store ngừng chờ sau 5 giây                            | Triển khai với `--network` và `--subnet` cho Direct VPC egress, và tạo instance Cloud SQL với `--no-assign-ip` và `--network` trỏ tới cùng VPC                                                                              |
| Các request Agent Platform của Google Cloud trả về `403 PERMISSION_DENIED`               | Runtime không dùng service account `claude-gateway`, hoặc model không được bật trong Model Garden cho dự án                          | Đặt `--service-account` trên Cloud Run hoặc bind Workload Identity trên GKE, và bật mỗi model Claude trong Model Garden cho region đích                                                                                      |
| Các phản hồi streaming bị cắt sau một khoảng thời gian cố định                            | Timeout request front-end: backend service của load balancer sau GKE Ingress mặc định 30 giây và Cloud Run 300 giây                 | Gắn một BackendConfig với `timeoutSec` được tăng trên GKE, hoặc triển khai với `--timeout=3600` trên Cloud Run                                                                                                              |

## Các bước tiếp theo

* [Tài liệu tham chiếu cấu hình](/en/claude-apps-gateway-config): mọi tùy chọn `gateway.yaml`, bao gồm `managed.policies` và `telemetry`
* [Triển khai và vận hành](/en/claude-apps-gateway-deploy): thiết lập IdP, health check, xoay vòng JWT secret, nâng cấp, và mô hình bảo mật
* [Tổng quan Claude apps gateway](/en/claude-apps-gateway): quickstart và kết nối lập trình viên
