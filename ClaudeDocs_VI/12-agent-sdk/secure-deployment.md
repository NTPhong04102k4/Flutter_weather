> Nguồn: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
> Tài liệu Claude Code — bản dịch tiếng Việt

> ## Chỉ mục tài liệu
> Tải chỉ mục tài liệu đầy đủ tại: https://code.claude.com/docs/llms.txt
> Dùng file này để khám phá tất cả các trang có sẵn trước khi tìm hiểu sâu hơn.

# Triển khai AI agent một cách an toàn

> Hướng dẫn bảo mật cho các triển khai Claude Code và Agent SDK với cơ chế cô lập (isolation), quản lý thông tin xác thực (credential) và kiểm soát mạng

Claude Code và Agent SDK là những công cụ mạnh mẽ có thể thực thi mã, truy cập file và tương tác với các dịch vụ bên ngoài thay cho bạn. Giống như bất kỳ công cụ nào có những khả năng này, việc triển khai chúng một cách thận trọng sẽ đảm bảo bạn nhận được lợi ích trong khi vẫn duy trì các biện pháp kiểm soát phù hợp.

Khác với phần mềm truyền thống vốn đi theo các luồng mã được định trước, những công cụ này tạo ra hành động của mình một cách động dựa trên ngữ cảnh và mục tiêu. Sự linh hoạt này chính là điều khiến chúng hữu ích, nhưng nó cũng có nghĩa là hành vi của chúng có thể bị ảnh hưởng bởi nội dung mà chúng xử lý: file, trang web, hoặc dữ liệu người dùng nhập vào. Điều này đôi khi được gọi là prompt injection (chèn prompt độc hại). Ví dụ, nếu file README của một repository chứa những chỉ dẫn bất thường, Claude Code có thể đưa những chỉ dẫn đó vào hành động của mình theo cách mà người vận hành không lường trước. Hướng dẫn này trình bày các cách thực tế để giảm thiểu rủi ro đó.

Tin tốt là việc bảo mật một triển khai agent không đòi hỏi hạ tầng phức tạp bất thường. Cùng những nguyên tắc áp dụng khi chạy bất kỳ đoạn mã bán tin cậy nào cũng áp dụng ở đây: cô lập (isolation), đặc quyền tối thiểu (least privilege) và phòng thủ nhiều lớp (defense in depth). Claude Code bao gồm một số tính năng bảo mật giúp giải quyết những mối lo ngại phổ biến, và hướng dẫn này sẽ đi qua từng tính năng cùng các tùy chọn tăng cường bổ sung dành cho những ai cần đến.

Không phải mọi triển khai đều cần bảo mật ở mức tối đa. Một lập trình viên chạy Claude Code trên laptop của mình có yêu cầu khác với một công ty xử lý dữ liệu khách hàng trong môi trường đa tenant (multi-tenant). Hướng dẫn này trình bày các tùy chọn từ những tính năng bảo mật tích hợp sẵn của Claude Code cho đến các kiến trúc production được tăng cường, để bạn có thể chọn phương án phù hợp với hoàn cảnh của mình.

## Mô hình đe dọa (Threat model)

Agent có thể thực hiện các hành động ngoài ý muốn do prompt injection (các chỉ dẫn nhúng trong nội dung mà chúng xử lý) hoặc do lỗi của mô hình. Các mô hình Claude được thiết kế để chống lại điều này; xem [tổng quan về mô hình](https://platform.claude.com/docs/en/about-claude/models/overview) và system card của mô hình bạn triển khai để biết chi tiết đánh giá.

Tuy vậy, phòng thủ nhiều lớp vẫn là thông lệ tốt. Ví dụ, nếu một agent xử lý một file độc hại chỉ dẫn nó gửi dữ liệu khách hàng đến một máy chủ bên ngoài, các biện pháp kiểm soát mạng có thể chặn hoàn toàn yêu cầu đó.

## Các tính năng bảo mật tích hợp sẵn

Claude Code bao gồm một số tính năng bảo mật giải quyết những mối lo ngại phổ biến. Xem [tài liệu bảo mật](/en/security) để biết đầy đủ chi tiết.

* **Hệ thống permissions (quyền)**: Mọi công cụ và câu lệnh bash đều có thể được cấu hình để cho phép, chặn, hoặc hỏi người dùng phê duyệt. Dùng các mẫu glob để tạo các quy tắc như "cho phép tất cả câu lệnh npm" hoặc "chặn mọi câu lệnh có sudo". Các tổ chức có thể đặt chính sách áp dụng cho toàn bộ người dùng. Xem [permissions](/en/permissions).
* **Phân tích cú pháp câu lệnh cho permissions**: Trước khi thực thi câu lệnh bash, Claude Code phân tích chúng thành một AST và so khớp kết quả với các quy tắc permission của bạn. Những câu lệnh không thể phân tích cú pháp một cách rõ ràng, hoặc không khớp với quy tắc cho phép nào, sẽ yêu cầu phê duyệt tường minh. Một tập nhỏ các cấu trúc như `eval` luôn yêu cầu phê duyệt bất kể các quy tắc cho phép. Đây là một cổng permission, không phải một sandbox; nó không suy luận xem một câu lệnh có nguy hiểm hay không dựa trên đường dẫn đích hoặc tác động của nó.
* **Tóm tắt kết quả tìm kiếm web**: Kết quả tìm kiếm được tóm tắt thay vì đưa nội dung thô trực tiếp vào context, giảm rủi ro prompt injection từ nội dung web độc hại.
* **Chế độ sandbox**: Câu lệnh bash có thể chạy trong môi trường sandbox nhằm hạn chế truy cập filesystem và mạng. Xem [tài liệu sandboxing](/en/sandboxing) để biết chi tiết.

## Các nguyên tắc bảo mật

Đối với những triển khai cần tăng cường thêm vượt trên mặc định của Claude Code, các nguyên tắc sau đây định hướng cho các tùy chọn hiện có.

### Ranh giới bảo mật (Security boundaries)

Một ranh giới bảo mật ngăn cách các thành phần có mức độ tin cậy khác nhau. Đối với những triển khai bảo mật cao, bạn có thể đặt các tài nguyên nhạy cảm (như credential) bên ngoài ranh giới chứa agent. Nếu có điều gì đó sai sót trong môi trường của agent, các tài nguyên nằm ngoài ranh giới đó vẫn được bảo vệ.

Ví dụ, thay vì cấp cho agent quyền truy cập trực tiếp vào một API key, bạn có thể chạy một proxy nằm ngoài môi trường của agent để chèn key vào các yêu cầu. Agent có thể thực hiện lệnh gọi API, nhưng nó không bao giờ nhìn thấy chính credential đó. Mẫu hình này hữu ích cho các triển khai đa tenant hoặc khi xử lý nội dung không tin cậy.

### Đặc quyền tối thiểu (Least privilege)

Khi cần, bạn có thể giới hạn agent chỉ ở những khả năng cần thiết cho nhiệm vụ cụ thể của nó:

| Tài nguyên          | Tùy chọn hạn chế                                     |
| ------------------- | --------------------------------------------------- |
| Filesystem          | Chỉ mount những thư mục cần thiết, ưu tiên read-only |
| Mạng                | Giới hạn ở các endpoint cụ thể thông qua proxy       |
| Credential          | Chèn qua proxy thay vì phơi bày trực tiếp            |
| Khả năng hệ thống   | Loại bỏ các Linux capability trong container         |

### Phòng thủ nhiều lớp (Defense in depth)

Đối với môi trường bảo mật cao, xếp chồng nhiều biện pháp kiểm soát mang lại lớp bảo vệ bổ sung. Các tùy chọn bao gồm:

* Cô lập bằng container
* Hạn chế mạng
* Kiểm soát filesystem
* Kiểm định (validation) yêu cầu tại proxy

Sự kết hợp phù hợp phụ thuộc vào mô hình đe dọa và yêu cầu vận hành của bạn.

## Các công nghệ cô lập

Các công nghệ cô lập khác nhau mang lại những đánh đổi khác nhau giữa độ mạnh bảo mật, hiệu năng và độ phức tạp vận hành.

<Info>
  Trong tất cả các cấu hình này, Claude Code (hoặc ứng dụng Agent SDK của bạn) chạy bên trong ranh giới cô lập (sandbox, container, hoặc VM). Các biện pháp kiểm soát bảo mật mô tả dưới đây hạn chế những gì agent có thể truy cập từ bên trong ranh giới đó.
</Info>

| Công nghệ               | Độ mạnh cô lập                    | Chi phí hiệu năng     | Độ phức tạp    |
| ----------------------- | -------------------------------- | --------------------- | -------------- |
| Sandbox runtime         | Tốt (mặc định an toàn)           | Rất thấp              | Thấp           |
| Container (Docker)      | Phụ thuộc vào cấu hình           | Thấp                  | Trung bình     |
| gVisor                  | Xuất sắc (nếu thiết lập đúng)     | Trung bình/Cao        | Trung bình     |
| VM (Firecracker, QEMU)  | Xuất sắc (nếu thiết lập đúng)     | Cao                   | Trung bình/Cao |

### Sandbox runtime

Để cô lập nhẹ mà không cần container, [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) áp đặt các hạn chế về filesystem và mạng ở cấp độ hệ điều hành.

Ưu điểm chính là sự đơn giản: không cần cấu hình Docker, image container, hay thiết lập mạng. Proxy và các hạn chế filesystem đã được tích hợp sẵn. Bạn cung cấp một file settings chỉ định các domain và path được phép.

**Cách hoạt động:**

* **Filesystem**: Sử dụng các primitive của hệ điều hành (`bubblewrap` trên Linux, `sandbox-exec` trên macOS) để hạn chế quyền đọc/ghi vào các path đã cấu hình
* **Mạng**: Loại bỏ network namespace (Linux) hoặc dùng các profile Seatbelt (macOS) để định tuyến lưu lượng mạng qua một proxy tích hợp sẵn
* **Cấu hình**: Danh sách cho phép (allowlist) dựa trên JSON cho các domain và path filesystem

**Thiết lập:**

```bash theme={null}
npm install @anthropic-ai/sandbox-runtime
```

Sau đó tạo một file cấu hình chỉ định các path và domain được phép.

**Lưu ý về bảo mật:**

1. **Chung kernel với host**: Khác với VM, các tiến trình được sandbox chia sẻ kernel của host. Một lỗ hổng kernel về lý thuyết có thể cho phép thoát khỏi sandbox (escape). Với một số mô hình đe dọa, điều này chấp nhận được, nhưng nếu bạn cần cô lập ở cấp kernel, hãy dùng gVisor hoặc một VM riêng.

2. **Không kiểm tra TLS**: Proxy đưa domain vào allowlist dựa trên hostname do client cung cấp và không kết thúc (terminate) hay kiểm tra lưu lượng đã mã hóa. Mã chạy bên trong sandbox có thể sử dụng [domain fronting](https://en.wikipedia.org/wiki/Domain_fronting) hoặc các kỹ thuật tương tự để tiếp cận các host nằm ngoài allowlist. Nếu mô hình đe dọa của bạn đòi hỏi đảm bảo mạnh hơn, hãy cấu hình một [proxy kết thúc TLS (TLS-terminating proxy)](#traffic-forwarding). Xem [các giới hạn bảo mật của sandboxing](/en/sandboxing#security-limitations) để biết thêm chi tiết. Ngoài ra, nếu agent có credential với quyền rộng cho một domain được phép, hãy đảm bảo nó không thể dùng domain đó để kích hoạt các yêu cầu mạng khác hoặc để rò rỉ dữ liệu.

Với nhiều trường hợp một-lập-trình-viên và CI/CD, sandbox-runtime nâng cao đáng kể rào cản bảo mật với thiết lập tối thiểu. Các phần dưới đây trình bày container và VM cho các triển khai đòi hỏi cô lập mạnh hơn.

### Container

Container cung cấp cơ chế cô lập thông qua Linux namespace. Mỗi container có góc nhìn riêng về filesystem, cây tiến trình và ngăn xếp mạng, trong khi vẫn chia sẻ kernel của host.

Một cấu hình container được tăng cường bảo mật có thể trông như thế này:

```bash theme={null}
docker run \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --security-opt seccomp=/path/to/seccomp-profile.json \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /home/agent:rw,noexec,nosuid,size=500m \
  --network none \
  --memory 2g \
  --cpus 2 \
  --pids-limit 100 \
  --user 1000:1000 \
  -v /path/to/code:/workspace:ro \
  -v /var/run/proxy.sock:/var/run/proxy.sock:ro \
  agent-image
```

Đây là tác dụng của từng tùy chọn:

| Tùy chọn                           | Mục đích                                                                                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--cap-drop ALL`                   | Loại bỏ các Linux capability như `NET_ADMIN` và `SYS_ADMIN` vốn có thể tạo điều kiện leo thang đặc quyền                                                     |
| `--security-opt no-new-privileges` | Ngăn tiến trình giành thêm đặc quyền thông qua các binary setuid                                                                                            |
| `--security-opt seccomp=...`       | Hạn chế các syscall khả dụng; mặc định của Docker chặn \~44, các profile tùy chỉnh có thể chặn nhiều hơn                                                     |
| `--read-only`                      | Làm cho filesystem gốc của container thành bất biến, ngăn agent lưu giữ (persist) các thay đổi                                                               |
| `--tmpfs /tmp:...`                 | Cung cấp một thư mục tạm có thể ghi, được xóa sạch khi container dừng                                                                                        |
| `--network none`                   | Loại bỏ tất cả interface mạng; agent giao tiếp thông qua Unix socket được mount bên dưới                                                                     |
| `--memory 2g`                      | Giới hạn mức sử dụng bộ nhớ để ngăn cạn kiệt tài nguyên                                                                                                      |
| `--pids-limit 100`                 | Giới hạn số lượng tiến trình để ngăn fork bomb                                                                                                              |
| `--user 1000:1000`                 | Chạy dưới quyền một người dùng không phải root                                                                                                              |
| `-v ...:/workspace:ro`             | Mount mã ở chế độ read-only để agent có thể phân tích nhưng không sửa đổi. **Tránh mount các thư mục nhạy cảm của host như `~/.ssh`, `~/.aws`, hoặc `~/.config`** |
| `-v .../proxy.sock:...`            | Mount một Unix socket kết nối tới một proxy chạy bên ngoài container (xem bên dưới)                                                                          |

**Kiến trúc Unix socket:**

Với `--network none`, container hoàn toàn không có interface mạng nào. Cách duy nhất để agent tiếp cận thế giới bên ngoài là thông qua Unix socket được mount, vốn kết nối tới một proxy chạy trên host. Proxy này có thể áp đặt allowlist domain, chèn credential và ghi log toàn bộ lưu lượng.

Đây chính là kiến trúc được [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) sử dụng. Ngay cả khi agent bị xâm phạm qua prompt injection, nó cũng không thể rò rỉ dữ liệu ra các máy chủ tùy ý. Nó chỉ có thể giao tiếp thông qua proxy, vốn kiểm soát những domain nào có thể tiếp cận được. Để biết thêm chi tiết, xem [bài blog về sandboxing của Claude Code](https://www.anthropic.com/engineering/claude-code-sandboxing).

**Các tùy chọn tăng cường bổ sung:**

| Tùy chọn         | Mục đích                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| `--userns-remap` | Ánh xạ root của container sang một người dùng host không có đặc quyền; đòi hỏi cấu hình daemon nhưng hạn chế thiệt hại khi thoát khỏi container |
| `--ipc private`  | Cô lập giao tiếp liên tiến trình (IPC) để ngăn các cuộc tấn công xuyên container                                     |

### gVisor

Container tiêu chuẩn chia sẻ kernel của host: khi mã bên trong container thực hiện một lệnh gọi hệ thống, nó đi thẳng đến chính kernel đang chạy host. Điều này có nghĩa một lỗ hổng kernel có thể cho phép thoát khỏi container. gVisor giải quyết vấn đề này bằng cách chặn các lệnh gọi hệ thống trong userspace trước khi chúng chạm tới kernel của host, triển khai một lớp tương thích riêng xử lý hầu hết các syscall mà không cần đến kernel thật.

Nếu một agent chạy mã độc (có thể do prompt injection), mã đó chạy trong container và có thể cố khai thác kernel. Với gVisor, bề mặt tấn công nhỏ hơn nhiều: mã độc trước tiên phải khai thác được lớp triển khai userspace của gVisor và sẽ có quyền truy cập hạn chế vào kernel thật.

Để dùng gVisor với Docker, cài đặt runtime `runsc` và cấu hình daemon:

```json theme={null}
// /etc/docker/daemon.json
{
  "runtimes": {
    "runsc": {
      "path": "/usr/local/bin/runsc"
    }
  }
}
```

Sau đó chạy container với:

```bash theme={null}
docker run --runtime=runsc agent-image
```

**Lưu ý về hiệu năng:**

| Loại workload         | Chi phí phụ trội                                          |
| --------------------- | -------------------------------------------------------- |
| Tính toán nặng CPU    | \~0% (không chặn syscall)                                |
| Syscall đơn giản      | Chậm hơn \~2×                                            |
| I/O file cường độ cao | Chậm hơn tới 10-200× với các mẫu open/close nặng          |

Đối với môi trường đa tenant hoặc khi xử lý nội dung không tin cậy, lớp cô lập bổ sung này thường xứng đáng với chi phí phụ trội.

### Máy ảo (Virtual machines)

VM cung cấp cô lập ở cấp phần cứng thông qua các phần mở rộng ảo hóa CPU. Mỗi VM chạy kernel riêng của nó, tạo nên một ranh giới mạnh. Một lỗ hổng trong kernel guest không trực tiếp xâm phạm host. Tuy nhiên, VM không tự động "an toàn hơn" các phương án như gVisor. Bảo mật của VM phụ thuộc nhiều vào hypervisor và mã mô phỏng thiết bị (device emulation).

Firecracker được thiết kế cho cô lập microVM nhẹ. Nó có thể khởi động VM trong dưới 125ms với chi phí bộ nhớ phụ trội dưới 5 MiB, loại bỏ các phần mô phỏng thiết bị không cần thiết nhằm giảm bề mặt tấn công.

Với cách tiếp cận này, VM của agent không có interface mạng bên ngoài. Thay vào đó, nó giao tiếp thông qua `vsock` (virtual sockets). Toàn bộ lưu lượng được định tuyến qua vsock đến một proxy trên host, vốn áp đặt allowlist và chèn credential trước khi chuyển tiếp yêu cầu.

### Triển khai trên cloud

Đối với triển khai trên cloud, bạn có thể kết hợp bất kỳ công nghệ cô lập nào ở trên với các biện pháp kiểm soát mạng cloud-native:

1. Chạy các container agent trong một private subnet không có internet gateway
2. Cấu hình các quy tắc tường lửa cloud (AWS Security Groups, GCP VPC firewall) để chặn mọi lưu lượng ra (egress) ngoại trừ đến proxy của bạn
3. Chạy một proxy (chẳng hạn [Envoy](https://www.envoyproxy.io/) với filter `credential_injector`) để kiểm định yêu cầu, áp đặt allowlist domain, chèn credential và chuyển tiếp đến các API bên ngoài
4. Gán các quyền IAM tối thiểu cho service account của agent, định tuyến các truy cập nhạy cảm qua proxy khi có thể
5. Ghi log toàn bộ lưu lượng tại proxy phục vụ mục đích kiểm toán

## Quản lý credential

Agent thường cần credential để gọi API, truy cập repository, hoặc tương tác với các dịch vụ cloud. Thách thức là cung cấp quyền truy cập này mà không phơi bày chính các credential.

### Mẫu hình proxy (The proxy pattern)

Cách tiếp cận được khuyến nghị là chạy một proxy nằm ngoài ranh giới bảo mật của agent để chèn credential vào các yêu cầu đi ra. Agent gửi yêu cầu không kèm credential, proxy bổ sung chúng, rồi chuyển tiếp yêu cầu đến đích.

Mẫu hình này có một số lợi ích:

1. Agent không bao giờ nhìn thấy credential thật
2. Proxy có thể áp đặt một allowlist các endpoint được phép
3. Proxy có thể ghi log toàn bộ yêu cầu phục vụ kiểm toán
4. Credential được lưu tại một vị trí an toàn duy nhất thay vì phân tán tới từng agent

### Cấu hình Claude Code để dùng proxy

Claude Code hỗ trợ hai phương pháp định tuyến các yêu cầu sampling qua proxy:

**Tùy chọn 1: ANTHROPIC\_BASE\_URL (đơn giản nhưng chỉ dành cho các yêu cầu API sampling)**

```bash theme={null}
export ANTHROPIC_BASE_URL="http://localhost:8080"
```

Điều này báo cho Claude Code và Agent SDK gửi các yêu cầu sampling đến proxy của bạn thay vì gửi trực tiếp đến Claude API. Proxy của bạn nhận các yêu cầu HTTP dạng plaintext, có thể kiểm tra và sửa đổi chúng (bao gồm việc chèn credential), rồi chuyển tiếp đến API thật.

**Tùy chọn 2: HTTP\_PROXY / HTTPS\_PROXY (toàn hệ thống)**

```bash theme={null}
export HTTP_PROXY="http://localhost:8080"
export HTTPS_PROXY="http://localhost:8080"
```

Claude Code và Agent SDK tôn trọng các biến môi trường tiêu chuẩn này, định tuyến toàn bộ lưu lượng HTTP qua proxy. Với HTTPS, proxy tạo một đường hầm CONNECT được mã hóa: nó không thể nhìn thấy hay sửa đổi nội dung yêu cầu nếu không thực hiện chặn bắt TLS (TLS interception).

### Triển khai một proxy

Bạn có thể tự xây dựng proxy của mình hoặc dùng một proxy có sẵn:

* [Envoy Proxy](https://www.envoyproxy.io/): proxy cấp production với filter `credential_injector` để thêm các header xác thực
* [mitmproxy](https://mitmproxy.org/): proxy kết thúc TLS để kiểm tra và sửa đổi lưu lượng HTTPS
* [Squid](http://www.squid-cache.org/): proxy có bộ nhớ đệm (caching) với các access control list
* [LiteLLM](https://github.com/BerriAI/litellm): gateway LLM với tính năng chèn credential và giới hạn tốc độ (rate limiting)

### Credential cho các dịch vụ khác

Ngoài việc sampling từ Claude API, agent thường cần quyền truy cập đã xác thực đến các dịch vụ khác, chẳng hạn git repository, cơ sở dữ liệu và các API nội bộ. Có hai cách tiếp cận chính:

#### Công cụ tùy chỉnh (Custom tools)

Cung cấp quyền truy cập thông qua một MCP server hoặc một công cụ tùy chỉnh định tuyến các yêu cầu tới một dịch vụ chạy bên ngoài ranh giới bảo mật của agent. Agent gọi công cụ, nhưng yêu cầu đã xác thực thực sự lại diễn ra bên ngoài. Công cụ gọi tới một proxy để proxy chèn credential.

Ví dụ, một MCP server cho git có thể nhận lệnh từ agent nhưng chuyển tiếp chúng đến một git proxy chạy trên host, nơi bổ sung xác thực trước khi liên hệ với remote repository. Agent không bao giờ nhìn thấy credential.

Ưu điểm:

* **Không cần chặn bắt TLS**: Dịch vụ bên ngoài tự thực hiện các yêu cầu đã xác thực trực tiếp
* **Credential ở lại bên ngoài**: Agent chỉ nhìn thấy giao diện công cụ, không thấy credential bên dưới

#### Chuyển tiếp lưu lượng (Traffic forwarding)

Đối với các lệnh gọi Claude API, `ANTHROPIC_BASE_URL` cho phép bạn định tuyến yêu cầu đến một proxy có thể kiểm tra và sửa đổi chúng ở dạng plaintext. Nhưng với các dịch vụ HTTPS khác (GitHub, npm registry, API nội bộ), lưu lượng thường được mã hóa đầu-cuối. Ngay cả khi bạn định tuyến nó qua một proxy bằng `HTTP_PROXY`, proxy cũng chỉ nhìn thấy một đường hầm TLS mờ đục và không thể chèn credential.

Để sửa đổi lưu lượng HTTPS tới các dịch vụ tùy ý mà không dùng công cụ tùy chỉnh, bạn cần một proxy kết thúc TLS để giải mã lưu lượng, kiểm tra hoặc sửa đổi nó, rồi mã hóa lại trước khi chuyển tiếp. Điều này đòi hỏi:

1. Chạy proxy bên ngoài container của agent
2. Cài chứng chỉ CA của proxy vào trust store của agent (để agent tin tưởng các chứng chỉ của proxy)
3. Cấu hình `HTTP_PROXY`/`HTTPS_PROXY` để định tuyến lưu lượng qua proxy

Cách tiếp cận này xử lý được bất kỳ dịch vụ dựa trên HTTP nào mà không cần viết công cụ tùy chỉnh, nhưng thêm độ phức tạp trong việc quản lý chứng chỉ.

Lưu ý rằng không phải mọi chương trình đều tôn trọng `HTTP_PROXY`/`HTTPS_PROXY`. Hầu hết các công cụ (curl, pip, npm, git) đều tôn trọng, nhưng một số có thể bỏ qua các biến này và kết nối trực tiếp. Ví dụ, `fetch()` của Node.js mặc định bỏ qua các biến này; trong Node 24+ bạn có thể đặt `NODE_USE_ENV_PROXY=1` để bật hỗ trợ. Để bao phủ toàn diện, bạn có thể dùng [proxychains](https://github.com/haad/proxychains) để chặn bắt các lệnh gọi mạng, hoặc cấu hình iptables để chuyển hướng lưu lượng đi ra đến một transparent proxy.

<Info>
  Một **transparent proxy** chặn bắt lưu lượng ở cấp mạng, nên client không cần được cấu hình để dùng nó. Các proxy thông thường yêu cầu client kết nối tường minh và nói giao thức HTTP CONNECT hoặc SOCKS. Transparent proxy (như Squid hoặc mitmproxy ở chế độ transparent) có thể xử lý các kết nối TCP được chuyển hướng thô.
</Info>

Cả hai cách tiếp cận vẫn đòi hỏi proxy kết thúc TLS và một chứng chỉ CA được tin tưởng. Chúng chỉ đảm bảo rằng lưu lượng thực sự đến được proxy.

## Cấu hình filesystem

Các biện pháp kiểm soát filesystem quyết định những file nào agent có thể đọc và ghi.

### Mount mã ở chế độ read-only

Khi agent cần phân tích mã nhưng không sửa đổi nó, hãy mount thư mục ở chế độ read-only:

```bash theme={null}
docker run -v /path/to/code:/workspace:ro agent-image
```

<Warning>
  Ngay cả quyền truy cập read-only vào một thư mục mã cũng có thể phơi bày credential. Các file phổ biến cần loại bỏ hoặc làm sạch trước khi mount:

  | File                                                    | Rủi ro                                    |
  | ------------------------------------------------------- | ---------------------------------------- |
  | `.env`, `.env.local`                                    | API key, mật khẩu database, secret        |
  | `~/.git-credentials`                                    | Mật khẩu/token git ở dạng plaintext       |
  | `~/.aws/credentials`                                    | AWS access key                            |
  | `~/.config/gcloud/application_default_credentials.json` | Token Google Cloud ADC                    |
  | `~/.azure/`                                             | Credential Azure CLI                      |
  | `~/.docker/config.json`                                 | Token xác thực Docker registry            |
  | `~/.kube/config`                                        | Credential cụm Kubernetes                 |
  | `.npmrc`, `.pypirc`                                     | Token package registry                    |
  | `*-service-account.json`                                | Key service account GCP                   |
  | `*.pem`, `*.key`                                        | Private key (khóa riêng)                  |

  Hãy cân nhắc chỉ sao chép những file nguồn cần thiết, hoặc dùng cách lọc kiểu `.dockerignore`.
</Warning>

### Các vị trí có thể ghi

Nếu agent cần ghi file, bạn có một số tùy chọn tùy vào việc bạn có muốn các thay đổi được lưu giữ (persist) hay không:

Với các workspace tạm thời (ephemeral) trong container, hãy dùng các mount `tmpfs` chỉ tồn tại trong bộ nhớ và bị xóa sạch khi container dừng:

```bash theme={null}
docker run \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --tmpfs /workspace:rw,noexec,size=500m \
  agent-image
```

Nếu bạn muốn xem xét các thay đổi trước khi lưu giữ chúng, một overlay filesystem cho phép agent ghi mà không sửa đổi các file bên dưới. Các thay đổi được lưu trong một lớp riêng mà bạn có thể kiểm tra, áp dụng, hoặc loại bỏ. Để có output lưu giữ hoàn toàn, hãy mount một volume chuyên dụng nhưng giữ nó tách biệt khỏi các thư mục nhạy cảm.

## Đọc thêm

* [Tài liệu bảo mật Claude Code](/en/security)
* [Hosting Agent SDK](/en/agent-sdk/hosting)
* [Xử lý permissions](/en/agent-sdk/permissions)
* [Sandbox runtime](https://github.com/anthropic-experimental/sandbox-runtime)
* [The Lethal Trifecta for AI Agents](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/)
* [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
* [Docker Security Best Practices](https://docs.docker.com/engine/security/)
* [gVisor Documentation](https://gvisor.dev/docs/)
* [Firecracker Documentation](https://firecracker-microvm.github.io/)
