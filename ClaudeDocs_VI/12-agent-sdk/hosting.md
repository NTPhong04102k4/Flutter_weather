> Nguồn: https://code.claude.com/docs/en/agent-sdk/hosting.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Lưu trữ (Hosting) Agent SDK

> Triển khai Agent SDK ở môi trường production: kiến trúc subprocess, lưu trữ phiên (session persistence), mở rộng quy mô (scaling), khả năng quan sát (observability), và cách ly đa bên thuê (multi-tenant isolation) cho Docker, Kubernetes, và các nhà cung cấp sandbox.

Agent SDK sinh ra và giám sát một subprocess CLI `claude` sở hữu một shell, một thư mục làm việc, và các file phiên trên đĩa. Lưu trữ nó không giống như lưu trữ một wrapper API không trạng thái (stateless). Mỗi agent đang chạy là một tiến trình tồn tại lâu dài gắn với trạng thái cục bộ, điều này định hình cách bạn phân bổ tài nguyên, lưu trữ phiên, và mở rộng quy mô qua nhiều bên thuê (tenant).

Trang này bao gồm việc tự lưu trữ (self-hosting) trên hạ tầng của riêng bạn: hiểu [mô hình subprocess](#the-subprocess-model), [chọn một mẫu phiên](#choose-a-session-pattern), [cấp phát container](#provision-the-container), và [xử lý các vấn đề production](#handle-production-concerns) như lưu trữ, khả năng quan sát, xác thực, và cách ly đa bên thuê. Về các Dockerfile và Kubernetes manifest có thể triển khai được, xem [hosting cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/claude_agent_sdk/hosting).

Nếu bạn không cần kiểm soát hạ tầng, cách ly tùy chỉnh, hay data plane của riêng mình, hãy cân nhắc [Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) thay thế: một REST API được lưu trữ mà Anthropic vận hành agent và sandbox, để ứng dụng của bạn gửi các sự kiện và stream kết quả về mà không có hạ tầng lưu trữ nào phải vận hành.

<Info>
  Về việc gia cố bảo mật (security hardening) vượt ra ngoài sandbox cơ bản, bao gồm kiểm soát mạng, quản lý thông tin xác thực (credentials), và các tùy chọn cách ly, xem [Secure Deployment](/en/agent-sdk/secure-deployment).
</Info>

## Mô hình subprocess

Mỗi quyết định lưu trữ trên trang này đều xuất phát từ cách SDK chạy agent. Khi code của bạn gọi `query()`, SDK sinh ra một tiến trình CLI `claude` riêng biệt và giao tiếp với nó qua stdio. Subprocess đó sở hữu shell, thư mục làm việc, và các bản transcript phiên JSONL trên đĩa cục bộ.

<img src="https://mintcdn.com/claude-code/ikqp3_70mqIahteV/images/agent-sdk/hosting-subprocess.svg?fit=max&auto=format&n=ikqp3_70mqIahteV&q=85&s=9dac857ca9d3b1410c3734900c386004" alt="Request flow: client to your app, which spawns a claude CLI subprocess over stdio inside the container; the subprocess writes to local disk and calls api.anthropic.com over HTTPS" width="920" height="220" data-path="images/agent-sdk/hosting-subprocess.svg" />

Một phiên agent tương ứng với một subprocess. Chạy N phiên đồng thời nghĩa là N subprocess, mỗi cái có cây tiến trình (process tree) và file transcript riêng. Theo mặc định, tất cả chúng kế thừa thư mục làm việc của ứng dụng của bạn, vì vậy hãy truyền `cwd` trên mỗi lời gọi `query()` khi các phiên cần các hệ thống file riêng biệt:

<CodeGroup>
  ```typescript TypeScript theme={null}
  query({ prompt, options: { cwd: "/work/session-a" } })
  ```

  ```python Python theme={null}
  query(prompt=prompt, options=ClaudeAgentOptions(cwd="/work/session-a"))
  ```
</CodeGroup>

### Trạng thái nằm trên đĩa cục bộ

Ba loại trạng thái của agent nằm trên hệ thống file của container theo mặc định. Không loại nào tồn tại qua một lần khởi động lại container, một lần thu nhỏ quy mô (scale-down), hay một lần chuyển sang node khác.

| Trạng thái                     | Vị trí mặc định                                                                                    |
| ------------------------------ | ------------------------------------------------------------------------------------------------- |
| Transcript phiên               | `~/.claude/projects/`, hoặc thư mục `projects/` dưới `CLAUDE_CONFIG_DIR` nếu được thiết lập        |
| File bộ nhớ `CLAUDE.md`         | `~/.claude/CLAUDE.md` cho tầng user và thư mục làm việc của phiên cho tầng project                 |
| Artifact thư mục làm việc       | Thư mục làm việc của phiên                                                                         |

Để lưu trữ transcript qua nhiều host, hãy cấu hình một [adapter `SessionStore`](/en/agent-sdk/session-storage). File bộ nhớ và các artifact thư mục làm việc khác cần chiến lược lưu trữ riêng, chẳng hạn một volume được gắn (mounted) hoặc đồng bộ với object-store.

Về cách các phiên, việc tiếp tục (resumption), và phân nhánh (forking) hoạt động ở cấp API, xem [Sessions](/en/agent-sdk/sessions).

## Chọn một mẫu phiên

Bốn mẫu này bao quát vòng đời phiên: một container tồn tại bao lâu so với các phiên nó phục vụ. Về nơi container chạy, [hosting cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/claude_agent_sdk/07_Hosting_the_agent.ipynb) có [code có thể triển khai](https://github.com/anthropics/claude-cookbooks/tree/main/claude_agent_sdk/hosting) cho local Docker, Modal, và Kubernetes. Chọn một mẫu phiên ở đây và một đích triển khai từ cookbook.

### Phiên ephemeral (tạm thời)

Tạo một container cho mỗi tác vụ của người dùng và hủy nó khi tác vụ hoàn tất. Tốt nhất cho các tác vụ một lần (one-off). Người dùng vẫn có thể tương tác với AI trong khi tác vụ đang hoàn tất, nhưng khi đã hoàn tất thì container bị hủy.

Các khối lượng công việc (workload) ví dụ bao gồm điều tra và sửa lỗi (bug), trích xuất hóa đơn và biên nhận, dịch tài liệu, và biến đổi phương tiện (media transformation).

Container chạy một entrypoint một-lần (one-shot) gọi SDK và thoát. Ví dụ dưới đây cho thấy một phiên bản TypeScript tối giản. Lưu nó thành `entrypoint.mts` hoặc thiết lập `"type": "module"` trong `package.json` để `await` cấp cao nhất (top-level `await`) khả dụng.

```typescript theme={null}
import { query } from "@anthropic-ai/claude-agent-sdk";

const prompt = process.env.TASK_PROMPT!;
for await (const message of query({ prompt, options: { maxTurns: 20 } })) {
  console.log(message);
}
```

### Phiên chạy dài (long-running)

Chạy các thực thể (instance) container bền vững, thường lưu trữ nhiều tiến trình SDK mỗi container, để phục vụ công việc đang diễn ra liên tục. Tốt nhất cho các agent thực hiện hành động tự chủ (autonomous), phục vụ nội dung, hoặc xử lý các luồng thông điệp có khối lượng lớn.

Các khối lượng công việc ví dụ bao gồm một agent email phân loại (triage) và trả lời thư đến, một trình dựng site (site builder) lưu trữ một site có thể chỉnh sửa riêng cho mỗi người dùng thông qua các cổng (port) container, và một chat bot xử lý lưu lượng liên tục từ một nền tảng như Slack.

Container mở một endpoint HTTP hoặc WebSocket và ánh xạ mỗi phiên đang hoạt động tới một query tồn tại lâu dài và subprocess phía sau nó. Trong TypeScript, dùng [`streamInput()`](/en/agent-sdk/typescript#query-object) để thêm các lượt (turn) vào một phiên đang hoạt động và [`startup()`](/en/agent-sdk/typescript#startup) để làm nóng trước (pre-warm) các subprocess trước lưu lượng đến. Trong Python, dùng [`ClaudeSDKClient`](/en/agent-sdk/python#claudesdkclient) để giữ một phiên mở qua các lượt. Định cỡ container sao cho nó có thể giữ số lượng phiên đồng thời tối đa trong bộ nhớ.

### Phiên hybrid (lai)

Các container ephemeral hydrate (nạp) từ một [`SessionStore`](/en/agent-sdk/session-storage) khi khởi động và lưu các cập nhật trở lại. Tốt nhất cho các phiên trải dài qua nhiều lần tương tác nhưng nằm rảnh (idle) giữa chúng. Container thu nhỏ (spin down) trong các giai đoạn rảnh và mở lại (spin back up) khi người dùng quay lại.

Các khối lượng công việc ví dụ bao gồm một trình quản lý dự án cá nhân với các lần kiểm tra ngắt quãng, nghiên cứu sâu tạm dừng và tiếp tục qua nhiều giờ, và một agent hỗ trợ khách hàng tải lịch sử ticket qua các lần tương tác.

Điều chỉnh idle timeout của nhà cung cấp cho phù hợp với tần suất bạn dự kiến người dùng quay lại. Tắt một container mà không có `SessionStore` được cấu hình sẽ làm mất transcript theo nó, nên store là bắt buộc cho mẫu này, không phải tùy chọn.

Mẫu này xoay quanh việc tiếp tục một phiên bằng ID với một store được chia sẻ đính kèm:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query, type SessionStore } from "@anthropic-ai/claude-agent-sdk";

  declare const userInput: string;
  declare const sessionId: string;          // looked up from your database by user
  declare const sessionStore: SessionStore; // S3, Redis, Postgres, or your own adapter

  for await (const message of query({
    prompt: userInput,
    options: { resume: sessionId, sessionStore },
  })) {
    // ...
  }
  ```

  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions

  async for message in query(
      prompt=user_input,
      options=ClaudeAgentOptions(
          resume=session_id,            # looked up from your database by user
          session_store=session_store,  # S3, Redis, Postgres, or your own adapter
      ),
  ):
      ...
  ```
</CodeGroup>

Xem [Session storage](/en/agent-sdk/session-storage) để biết interface `SessionStore` đầy đủ và các adapter tham khảo.

### Container đa agent (multi-agent)

Chạy nhiều subprocess SDK bên trong một container. Tốt nhất cho các agent phải cộng tác chặt chẽ, ví dụ các mô phỏng đa agent nơi các agent tương tác với nhau trong một môi trường chung.

Cấp cho mỗi agent một thư mục làm việc riêng để chúng không ghi đè file của nhau, và cách ly việc tải settings để các file `CLAUDE.md` riêng của từng agent không rò rỉ qua các agent khác. Xem [Cách ly đa bên thuê](#multi-tenant-isolation) để biết các tùy chọn cụ thể.

## Cấp phát container

### Sandbox dựa trên container

Chạy SDK bên trong một container được sandbox để có cách ly tiến trình, giới hạn tài nguyên, kiểm soát mạng, và một hệ thống file ephemeral. Một số nhà cung cấp chuyên về các môi trường container được sandbox phù hợp với mô hình của Agent SDK.

Các câu hỏi cần trả lời khi chọn nhà cung cấp:

* **Ai vận hành sandbox**: một nhà cung cấp sandbox-as-a-service vận hành hạ tầng cho bạn, trong khi các tùy chọn tự lưu trữ (self-hosted) cung cấp phần mềm để bạn chạy trên hạ tầng của riêng mình.
* **Độ trễ khởi động lạnh (cold-start latency)**: bao lâu từ "tạo một sandbox" đến "sẵn sàng chấp nhận yêu cầu đầu tiên." Các mẫu ephemeral cần khởi động dưới một giây. Các mẫu chạy dài chịu được lâu hơn.
* **Lưu trữ bền vững (persistent storage)**: liệu nhà cung cấp có cung cấp các volume bền vững hay chỉ đĩa ephemeral. Mẫu hybrid cần lưu trữ bền vững ở đâu đó, dù là trong sandbox hay bên cạnh nó.
* **Mô hình định giá (pricing model)**: theo giây, theo yêu cầu, hoặc tính phí phẳng theo giờ. Định giá theo giây phù hợp với các khối lượng công việc ephemeral bùng nổ. Theo giờ phù hợp với các phiên chạy dài.
* **Mạng (networking)**: hỗ trợ các quy tắc egress tùy chỉnh, proxy đi ra (outbound proxy), và VPC peering riêng tư cho các môi trường bị quản lý chặt (regulated).

Các nhà cung cấp để đánh giá:

* [Modal Sandbox](https://modal.com/docs/guide/sandbox), với một [triển khai demo](https://modal.com/docs/examples/claude-slack-gif-creator)
* [Cloudflare Sandboxes](https://github.com/cloudflare/sandbox-sdk)
* [Daytona](https://www.daytona.io/)
* [E2B](https://e2b.dev/)
* [Fly Machines](https://fly.io/docs/machines/)
* [Vercel Sandbox](https://vercel.com/docs/functions/sandbox)

Về các tùy chọn tự lưu trữ như Docker, gVisor, và Firecracker, cùng cấu hình cách ly chi tiết, xem [Isolation Technologies](/en/agent-sdk/secure-deployment#isolation-technologies).

### Các phụ thuộc runtime

Container chỉ cần runtime ngôn ngữ của SDK của bạn:

* Python 3.10+ cho Python SDK, hoặc Node.js 18+ cho TypeScript SDK
* Cả hai gói SDK đều đóng gói sẵn (bundle) một binary Claude Code gốc (native) cho nền tảng host, nên không cần cài đặt riêng Claude Code hay Node.js cho CLI được sinh ra

Binary đóng gói sẵn được ghim (pinned) theo phiên bản gói SDK, nên cập nhật SDK là cách bạn cập nhật CLI. SDK tuân theo semver: nhận các bản phát hành patch liên tục và xem xét changelog [TypeScript](https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md) hoặc [Python](https://github.com/anthropics/claude-agent-sdk-python/blob/main/CHANGELOG.md) trước khi nhận một bản minor.

### Tài nguyên

1 GiB RAM, 5 GiB đĩa, và 1 CPU cho mỗi agent là một điểm khởi đầu hợp lý cho một thực thể vừa khởi động. Việc sử dụng bộ nhớ tăng theo độ dài phiên và hoạt động tool, nên hãy định cỡ theo độ dài phiên và mức đồng thời (concurrency) bạn thực sự cần thay vì mức nền lúc rảnh. Xem [Scaling and concurrency](#scaling-and-concurrency) để biết cách tính số agent mỗi host.

### Mạng

SDK cần HTTPS đi ra tới `api.anthropic.com`, hoặc tới endpoint theo vùng (regional endpoint) của nhà cung cấp của bạn khi chạy trên Amazon Bedrock hoặc Agent Platform của Google Cloud. Nếu các agent của bạn dùng [MCP server](/en/agent-sdk/mcp) hoặc các tool bên ngoài, chúng cũng cần truy cập đi ra tới các endpoint đó. Với production, hãy định tuyến lưu lượng đi ra qua một egress proxy thực thi các danh sách cho phép miền (domain allowlists), chèn thông tin xác thực, và ghi log các yêu cầu. Xem [Secure Deployment](/en/agent-sdk/secure-deployment) để biết mẫu đầy đủ.

Với lưu lượng đi vào (inbound), hãy mở một cổng HTTP hoặc WebSocket trên container. Ứng dụng của bạn xử lý các yêu cầu client trên cổng đó và gọi SDK nội bộ; bản thân subprocess không lắng nghe trên mạng.

## Xử lý các vấn đề production

Hãy làm việc qua các quyết định này trước khi phát hành một agent tự lưu trữ.

### Lưu trữ phiên và trạng thái

Đĩa cục bộ mặc định bị mất khi khởi động lại, thu nhỏ quy mô, hoặc chuyển sang node khác. Với bất kỳ phiên nào người dùng mong đợi tiếp tục được, hãy phản chiếu (mirror) transcript tới lưu trữ bền vững bằng một [adapter `SessionStore`](/en/agent-sdk/session-storage). Xem [Reference implementations](/en/agent-sdk/session-storage#reference-implementations) để biết các adapter S3, Redis, và Postgres cùng một bộ kiểm tra tuân thủ (conformance suite) cho adapter của riêng bạn.

Ba điều cần biết về cách `SessionStore` hoạt động:

* **Chỉ transcript**: `SessionStore` phản chiếu transcript, không phản chiếu file bộ nhớ `CLAUDE.md` hay các artifact thư mục làm việc khác. Hãy gắn (mount) một volume chia sẻ hoặc đồng bộ chúng riêng.
* **Phản chiếu, không thay thế**: subprocess ghi vào đĩa cục bộ trước, và store nhận một bản sao của mỗi lô (batch). Các lần ghi cục bộ vẫn là nguồn chính thức (authoritative).
* **Thông điệp `mirror_error`**: một lô mà store từ chối sẽ được gửi tối đa ba lần tổng cộng, với một khoảng lùi (backoff) ngắn trước mỗi lần thử lại; một lời gọi bị timeout thì không được thử lại. Nếu lô vẫn thất bại, SDK bỏ nó, phát ra một thông điệp `{ type: "system", subtype: "mirror_error" }`, và tiếp tục query. Hãy cảnh báo (alert) trên các thông điệp này nếu độ bền của store quan trọng.

### Khả năng quan sát (Observability)

Các agent của Agent SDK là các tiến trình tồn tại lâu dài sinh ra các lời gọi tool qua nhiều vòng gọi API (API round-trips). Không có telemetry, bạn không thể thấy tool nào đã chạy, chúng mất bao lâu, hoặc phiên bị mắc kẹt (stall) ở đâu.

SDK kế thừa cấu hình OpenTelemetry từ môi trường. Hãy thiết lập các biến môi trường OTEL ở cấp container hoặc orchestrator để mỗi lời gọi `query()` xuất các span, metric, và log event tới collector của bạn. Ví dụ dưới đây bật xuất OTLP cho cả ba tín hiệu. `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` chỉ bắt buộc cho traces; bỏ qua nó nếu bạn chỉ xuất metrics và logs.

```bash title=".env" theme={null}
CLAUDE_CODE_ENABLE_TELEMETRY=1
CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
OTEL_TRACES_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://collector.example.com:4318
```

Văn bản prompt và đầu vào tool không được bao gồm trong các bản xuất theo mặc định. Xem [Control sensitive data in exports](/en/agent-sdk/observability#control-sensitive-data-in-exports) để biết các cờ opt-in, và [Observability](/en/agent-sdk/observability) để biết danh mục tín hiệu đầy đủ.

### Xác thực và bí mật (Auth and secrets)

Ba mối quan tâm về xác thực quan trọng ở thời điểm lưu trữ:

* **Anthropic API**: subprocess đọc `ANTHROPIC_API_KEY` từ môi trường của nó. Hãy cung cấp nó từ trình quản lý bí mật (secret manager) của bạn, hoặc thiết lập `ANTHROPIC_BASE_URL` để định tuyến các lời gọi model qua một proxy chèn key bên ngoài container. Xem [Credential management](/en/agent-sdk/secure-deployment#credential-management) để biết mẫu proxy và [tổng quan SDK](/en/agent-sdk/overview#get-started) để biết các phương thức xác thực được hỗ trợ.
* **Đi vào (Inbound)**: đặt xác thực tại một gateway phía trước container agent. Agent nên nhận các yêu cầu đã được xác thực trước (pre-authenticated) và không nên là thành phần xác thực (validate) token của người dùng.
* **Tool đi ra (Outbound tools)**: giữ thông tin xác thực của tool ra khỏi môi trường agent. Định tuyến các lời gọi đi ra qua một proxy chèn API key sau khi yêu cầu rời khỏi container. Agent thực hiện lời gọi; proxy thêm thông tin xác thực.

### Mở rộng quy mô và mức đồng thời

Mỗi phiên chạy trong subprocess riêng của nó, nên mức đồng thời trên một host bị giới hạn bởi số subprocess mà RAM của nó có thể giữ.

Định cỡ mỗi host bằng công thức này:

```text theme={null}
agents per host = (host RAM - overhead) / (per-session RAM ceiling)
```

Đo trần RAM mỗi phiên (per-session ceiling) bằng cách chạy một phiên tiêu biểu đến độ dài mục tiêu dưới tải tool dự kiến của bạn và ghi lại đỉnh RSS. Điểm khởi đầu 1 GiB trong [Tài nguyên](#resources) là mức sàn, không phải mức trần.

Định tuyến mở rộng theo chiều ngang (horizontal-scale routing) phụ thuộc vào mẫu của bạn. Với các phiên chạy dài, nơi container giữ nhiều phiên, hãy chạy một pool container phía sau một load balancer và ghim (pin) mỗi phiên vào một container bằng consistent hashing trên `sessionId`. Một phiên đã được ghim sẽ tiếp tục truy cập cùng container, và do đó cùng subprocess đang chạy, cho đến khi nó bị đẩy ra (evicted) hoặc container khởi động lại.

Các fanout lớn của các [subagent](/en/agent-sdk/subagents) đồng thời từ một phiên đơn có thể chạm giới hạn tốc độ (rate limit) của API. Hãy chia công việc thành các lô nhỏ hơn thay vì phát một lệnh dispatch rộng.

### Chi phí

Chi phí token của Anthropic thường vượt trội hơn chi phí hạ tầng container một bậc độ lớn (order of magnitude) hoặc hơn. Một container được cấp phát tối thiểu chạy khoảng \$0.05 mỗi giờ, trong khi một phiên agent dài đơn lẻ có thể tiêu tốn hàng đô la về token. Xem [Cost tracking](/en/agent-sdk/cost-tracking) để biết cách hạch toán token theo phiên.

### Cách ly đa bên thuê (Multi-tenant isolation)

Hành vi mặc định của SDK đọc settings và file bộ nhớ `CLAUDE.md` từ hệ thống file. Trong một container chia sẻ phục vụ nhiều bên thuê, các file đó có thể làm rò rỉ ngữ cảnh của một bên thuê vào phiên của bên thuê khác.

Để cách ly các bên thuê bên trong một container chia sẻ:

* Truyền `settingSources: []` trong TypeScript hoặc `setting_sources=[]` trong Python để không tải settings từ hệ thống file.
* Thiết lập `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` trong `env`. [Auto memory](/en/memory#auto-memory) tại `~/.claude/projects/<project>/memory/` tải vào system prompt bất kể `settingSources`. Xem [What settingSources does not control](/en/agent-sdk/claude-code-features#what-settingsources-does-not-control) để biết các đầu vào khác được tải một cách vô điều kiện.
* Trỏ `CLAUDE_CONFIG_DIR` tới một thư mục riêng cho từng bên thuê để các bên thuê không chia sẻ cấu hình toàn cục `~/.claude.json`.
* Dùng một thư mục làm việc riêng cho từng bên thuê. Truyền `cwd` một cách tường minh trên mọi lời gọi `query()`.
* Áp dụng các quy tắc egress riêng cho từng bên thuê tại proxy của bạn, chẳng hạn các IP đi ra riêng biệt, thông tin xác thực, hoặc danh sách cho phép miền, để một bên thuê bị xâm nhập không thể trích xuất dữ liệu (exfiltrate) qua chính sách đi ra của bên thuê khác.

Ví dụ dưới đây áp dụng bốn tùy chọn cấp SDK cùng nhau. Xây dựng `tenantDir` và `configDir` sao cho mỗi bên thuê nhận một đường dẫn mà không bên thuê nào khác đọc được. Trong TypeScript, `env` thay thế môi trường của subprocess, nên hãy spread `...process.env` để giữ các biến kế thừa như `PATH` và `ANTHROPIC_API_KEY`. Trong Python, `env` được gộp (merge) lên trên môi trường kế thừa.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  declare const prompt: string;
  declare const tenantDir: string;
  declare const configDir: string;

  for await (const message of query({
    prompt,
    options: {
      cwd: tenantDir,
      settingSources: [],
      env: {
        ...process.env,
        CLAUDE_CONFIG_DIR: configDir,
        CLAUDE_CODE_DISABLE_AUTO_MEMORY: "1",
      },
    },
  })) {
    // ...
  }
  ```

  ```python Python theme={null}
  from claude_agent_sdk import query, ClaudeAgentOptions

  async for message in query(
      prompt=prompt,
      options=ClaudeAgentOptions(
          cwd=tenant_dir,
          setting_sources=[],
          env={
              "CLAUDE_CONFIG_DIR": config_dir,
              "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
          },
      ),
  ):
      ...
  ```
</CodeGroup>

Về các kiểm soát mạng riêng cho từng bên thuê, xem [Secure Deployment](/en/agent-sdk/secure-deployment).

## Các hạn chế đã biết

Hãy tính đến những điều này trong thiết kế triển khai của bạn.

| Hạn chế                                              | Việc cần làm                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Không có timeout phiên cấp cao nhất                  | Một phiên không tự động hết thời gian. Hãy thiết lập `maxTurns` trong `Options` để giới hạn số vòng gọi tool (tool-use round trips) mà agent thực hiện trước khi dừng.                                                                                                                                                                                                                              |
| Bộ nhớ tăng trưởng qua các phiên dài                | Giới hạn độ dài phiên hoặc tái chế (recycle) subprocess định kỳ. Xem [Scaling and concurrency](#scaling-and-concurrency).                                                                                                                                                                                                                                                                        |
| Fanout subagent song song lớn có thể chạm rate limit | Chia công việc thành các lô nhỏ hơn thay vì phát một lệnh dispatch rộng.                                                                                                                                                                                                                                                                                                                          |
| Không có deadline theo thời gian thực (wall-clock) cho từng subagent | Giới hạn mỗi [subagent](/en/agent-sdk/subagents) bằng `maxTurns` trong `AgentDefinition` của nó. Chỉ với các background subagent, `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` thiết lập một watchdog canh mắc kẹt (stall) kích hoạt khi một subagent `run_in_background` ngừng sinh ra đầu ra; nó không phải là deadline cho tổng thời gian chạy. |

## Các bước tiếp theo

* [Hosting cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/claude_agent_sdk/07_Hosting_the_agent.ipynb): hướng dẫn từng bước dạng notebook với [code có thể triển khai](https://github.com/anthropics/claude-cookbooks/tree/main/claude_agent_sdk/hosting) cho Docker, Modal, và Kubernetes.
* [Session storage](/en/agent-sdk/session-storage): lưu trữ transcript qua nhiều host bằng một adapter `SessionStore`.
* [Observability](/en/agent-sdk/observability): xuất OTEL traces, metrics, và logs tới collector của bạn.
* [Secure deployment](/en/agent-sdk/secure-deployment): kiểm soát mạng, quản lý thông tin xác thực, và gia cố cách ly.
* [Cost tracking](/en/agent-sdk/cost-tracking): hạch toán token và chi phí theo phiên.
