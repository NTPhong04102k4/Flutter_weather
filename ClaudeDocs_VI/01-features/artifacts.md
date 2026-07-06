> Nguồn: https://code.claude.com/docs/en/artifacts.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Chia sẻ kết quả phiên làm việc dưới dạng artifact

> Artifact biến công việc của Claude Code thành các trang web động, tương tác được tại một URL riêng tư trên claude.ai.

{/* plan-availability: feature=artifacts plans=pro,max,team,enterprise providers=anthropic */}

<Note>
  Artifact có sẵn trên các gói Pro, Max, Team và Enterprise và yêu cầu một phiên đã đăng nhập bằng [`/login`](/en/setup#authenticate). Xem [Điều kiện sử dụng](#availability) để biết đầy đủ các yêu cầu.
</Note>

Một artifact là một trang web động, tương tác được mà Claude Code xuất bản từ phiên của bạn lên một URL riêng tư trên claude.ai. Bạn mở nó trong trình duyệt, và nó cập nhật tại chỗ khi phiên tiếp tục. Trên các gói Team và Enterprise, hãy chia sẻ nó từ phần đầu trang (header) khi bạn muốn một đồng nghiệp cũng xem được. Ví dụ, dùng một artifact để hướng dẫn người review đi qua một pull request với các diff được chú thích, xây một bảng điều khiển (dashboard) từ dữ liệu phiên, hoặc duy trì một dòng thời gian điều tra tự lấp đầy khi Claude làm việc.

<Frame>
  <img src="https://mintcdn.com/claude-code/kaHIYYMIYMYPxQg9/images/artifacts-viewer.png?fit=max&auto=format&n=kaHIYYMIYMYPxQg9&q=85&s=dbfd671cdb0d15f49f808b9e89778fe1" alt="Một artifact đang mở trong trình duyệt tại claude.ai/code/artifact. Header của trình xem hiển thị tiêu đề artifact acme-funnel-fix, nút Share, và avatar tác giả. Menu Share đang mở với công tắc Always share latest version, bộ chọn phiên bản ghi Sharing version 2, bộ chọn đối tượng Everyone at Acme, và nút Copy link. Bên dưới header, trang artifact hiển thị hai mockup di động cạnh nhau, một biểu đồ phễu, và một hàng các thẻ chỉ số." width="2511" height="1890" data-path="images/artifacts-viewer.png" />
</Frame>

## Khi nào dùng artifact

Dùng artifact khi văn bản trong terminal là phương tiện không phù hợp cho những gì Claude tạo ra: kết quả dễ nhìn và tương tác hơn là đọc từng dòng. Claude xây dựng trang từ bất cứ thứ gì phiên của bạn có thể tiếp cận, bao gồm codebase của bạn và dữ liệu mà nó lấy về qua các [công cụ đã kết nối](/en/mcp) của bạn, nên trang có thể hiển thị những thứ mà mô tả bằng lời sẽ tốn cả đoạn văn. Ví dụ, hãy yêu cầu Claude:

* Hướng dẫn người review đi qua một pull request với các diff được chú thích
* Kết xuất (render) một dashboard từ dữ liệu mà phiên đã lấy về
* Bày ra nhiều phương án thiết kế hoặc triển khai cạnh nhau
* Duy trì một dòng thời gian điều tra tự lấp đầy trong khi một tác vụ dài chạy
* Gửi cho đồng nghiệp một đường link thay vì dán kết quả vào Slack

Xem [Bạn có thể xây dựng gì](#what-you-can-build) để biết các prompt phù hợp với từng trường hợp.

### Artifact không phải là gì

Một artifact là một bản chụp công việc, không phải một ứng dụng. Nó là một trang duy nhất, tự chứa, không có backend, nên nó không thể lưu trữ dữ liệu nhập từ biểu mẫu, gọi API tại thời điểm xem, hoặc phục vụ nhiều route (đường dẫn). Đối với một công cụ nội bộ được host có backend, hãy triển khai nó trên hạ tầng của riêng bạn. Xem [Giới hạn của trang](#page-constraints) để biết đầy đủ các giới hạn.

## Tạo một artifact

Claude có thể tự xuất bản một artifact khi kết quả phù hợp với một trang, hoặc bạn có thể yêu cầu trực tiếp. Để yêu cầu, hãy gọi tên tính năng hoặc mô tả kết quả trực quan bạn muốn bằng ngôn ngữ tự nhiên. Một ứng viên tốt là bất cứ thứ gì dễ nhìn hơn là đọc dưới dạng văn bản, chẳng hạn một diff được chú thích, một biểu đồ, hay một tập các phương án để so sánh. Các prompt bên dưới là hai ví dụ; xem [Bạn có thể xây dựng gì](#what-you-can-build) để biết thêm các khuôn mẫu.

```text wrap theme={null}
Make an artifact that walks through this PR with the diff annotated inline.
```

```text wrap theme={null}
Build a dashboard artifact of last week's deploy failures by service and keep it updated as you investigate.
```

Claude ghi trang ra một file HTML hoặc Markdown trong dự án của bạn, rồi xuất bản nó. Trước khi xuất bản một artifact mới, Claude Code sẽ xin phép; nó có thể nói đại loại như `Claude wants to publish "Deploy failures by service" (deploy-failures.html) to a private page on claude.ai`. Việc tái xuất bản một artifact mà bạn đã phê duyệt trước đó sẽ không hỏi lại.

Chọn **Yes** để xuất bản. Claude in ra URL, và trình duyệt của bạn mở tới trang mới. Nhấn `Ctrl+]` bất cứ lúc nào để mở lại artifact gần nhất từ terminal.

Claude tự chọn tiêu đề của artifact và một emoji làm icon cho tab trình duyệt. Cả hai đều xuất hiện trong [thư viện artifact](#share-an-artifact) của bạn trên claude.ai và trong các link được chia sẻ, nên hãy yêu cầu Claude dùng một tiêu đề hoặc icon cụ thể nếu bạn muốn.

Để ngăn trình duyệt tự mở khi một artifact mới được xuất bản, hãy đặt `CLAUDE_CODE_ARTIFACT_AUTO_OPEN=0` trong môi trường của bạn.

Nếu Claude phản hồi rằng nó không thể xuất bản, hoặc ghi một file HTML cục bộ mà không có link, thì công cụ chưa được bật cho phiên của bạn. Hãy kiểm tra các yêu cầu [Điều kiện sử dụng](#availability).

## Cập nhật một artifact

Hãy yêu cầu Claude sửa trang, hoặc để một tác vụ chạy dài tái xuất bản khi nó tiến triển. Claude chỉnh sửa file nền và xuất bản lại tới cùng URL.

```text wrap theme={null}
Add a per-region breakdown below the summary chart and republish.
```

Bất kỳ ai đang mở trang sẽ thấy bản cập nhật tại chỗ. Mỗi lần xuất bản trở thành một phiên bản, và từ nút điều khiển **Share** ở header của trang bạn có thể chọn phiên bản nào người xem sẽ thấy.

Để cập nhật một artifact từ một phiên khác, hãy đưa cho Claude URL của artifact và yêu cầu nó sửa. Nếu không có URL, một phiên mới luôn tạo một artifact mới thay vì cập nhật một artifact hiện có.

```text wrap theme={null}
Update https://claude.ai/code/artifact/5fbea6f3-... with today's numbers.
```

## Chia sẻ một artifact

Một artifact mới chỉ hiển thị với riêng bạn. Trên các gói Pro và Max, artifact luôn ở chế độ riêng tư với bạn. Trên các gói Team và Enterprise, hãy mở artifact trong trình duyệt và dùng nút điều khiển **Share** ở header của trang để cấp quyền truy cập cho những người cụ thể trong tổ chức của bạn, hoặc cho tất cả mọi người trong đó. Header nêu bạn là tác giả của artifact, nên bất kỳ ai bạn chia sẻ cùng đều thấy được ai đã xuất bản trang. Nó cũng liên kết tới thư viện của bạn tại [claude.ai/code/artifacts](https://claude.ai/code/artifacts), nơi liệt kê mọi artifact bạn đã tạo.

Việc chia sẻ dừng lại trong phạm vi tổ chức của bạn. Người xem phải đăng nhập vào claude.ai với tư cách là thành viên của cùng tổ chức đã xuất bản artifact, và không có tùy chọn để làm cho một artifact xem được ngoài tổ chức đó. Để gửi nội dung nền cho ai đó ngoài tổ chức của bạn, hãy yêu cầu Claude cung cấp file HTML và chia sẻ file đó trực tiếp.

Artifact có thể xem được, chứ không đồng chỉnh sửa. Những người bạn chia sẻ cùng sẽ thấy mỗi phiên bản bạn xuất bản nhưng không thể thay đổi trang; bạn vẫn là người ghi duy nhất.

## Bạn có thể xây dựng gì

Một artifact là một trang HTML duy nhất, nên bất cứ thứ gì bạn có thể biểu đạt bằng HTML, CSS, và JavaScript nội tuyến (inline) đều nằm trong phạm vi. Các khuôn mẫu bên dưới xuất hiện thường xuyên nhất.

### Hướng dẫn đi qua một thay đổi

Hãy yêu cầu một trang kết xuất một diff hoặc một thay đổi thiết kế với chú thích cạnh các dòng liên quan, để người review có thể đọc lập luận của bạn ngay bên cạnh mã thay vì tái dựng lại nó từ một mô tả.

```text wrap theme={null}
Make an artifact that walks through this PR. Render the diff with margin annotations and color-code findings by severity.
```

### So sánh các phương án

Hãy yêu cầu nhiều biến thể trên một trang để bạn có thể đánh giá chúng với nhau. Cách này hiệu quả với bố cục, câu chữ (copy), hình dạng API, hoặc các kế hoạch triển khai.

```text wrap theme={null}
Make an artifact with four distinctly different layouts for the settings panel. Vary density and grouping, and lay them out as a grid with a one-line tradeoff under each.
```

### Tinh chỉnh với các điều khiển tương tác

Hãy yêu cầu các thanh trượt, công tắc, hoặc trường nhập liệu gắn với bất cứ thứ gì bạn đang điều chỉnh, để bạn có thể khám phá các giá trị trực tiếp thay vì mô tả chúng.

```text wrap theme={null}
Build an artifact with sliders for the easing curve, duration, and delay so I can try values on this transition. Show the animation live as I move them.
```

### Mang kết quả trở lại phiên của bạn

Một artifact có thể đóng vai trò như một trình biên tập gọn nhẹ cho một quyết định mà bạn sau đó chuyển lại cho Claude. Hãy yêu cầu một nút xuất (export) tạo ra văn bản mà bạn có thể dán vào terminal, để kết quả của việc tương tác với trang chảy ngược vào phiên thay vì ở lại trên trang.

```text wrap theme={null}
Make a triage board artifact with each open issue as a draggable card across Now, Next, Later, and Cut columns. Add a "Copy as prompt" button that gives me the final ordering to paste back here.
```

### Theo dõi công việc đang tiến hành

Hãy yêu cầu Claude giữ một artifact luôn cập nhật trong khi một tác vụ dài chạy, để bất kỳ ai có link đều có thể theo dõi mà không cần đọc terminal.

```text wrap theme={null}
Turn this migration plan into a checklist artifact. Check items off as you complete them and add a note for anything you skip.
```

## Cải thiện thiết kế trực quan

Claude áp dụng một skill (kỹ năng) thiết kế tích hợp sẵn khi nó xây một artifact, nên các trang có được bảng màu, kiểu chữ và bố cục có chủ đích mà không cần prompt thêm. Skill đó cũng tìm một hệ thống thiết kế (design system) hiện có trong dự án của bạn trước khi tự chọn theo ý mình. Để giữ cho artifact nhất quán với thương hiệu sản phẩm của bạn, hãy ghi lại các design token ở nơi Claude có thể tìm thấy, chẳng hạn [CLAUDE.md](/en/memory) của dự án hoặc một file theme trong kho lưu trữ của bạn:

```markdown theme={null}
## Design system

- Colors: primary #1a4d8f, accent #f59e0b, surface #f8fafc
- Typography: Inter for body, JetBrains Mono for code
- Spacing: 8px scale, 6px border radius
```

Claude coi hệ thống thiết kế của bạn có mức ưu tiên cao hơn các lựa chọn của riêng nó, và prompt của bạn có mức ưu tiên cao hơn cả hai. Tiêu đề và định dạng ở trên chỉ là một ví dụ; bất kỳ danh sách rõ ràng nào về màu sắc, phông chữ và khoảng cách đều hoạt động.

## Giới hạn của trang

Mỗi artifact là một trang tự chứa. Claude Code gói file bạn xuất bản trong một khung tài liệu HTML (HTML document shell) và phục vụ nó dưới một Content Security Policy (CSP) nghiêm ngặt, điều này định hình những gì trang có thể làm.

| Giới hạn              | Ảnh hưởng                                                                                                                                                                                                                                             |
| :-------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Không có yêu cầu bên ngoài | CSP chặn các script, stylesheet, phông chữ, và hình ảnh được nạp từ bất kỳ host nào khác, cùng với các lệnh gọi `fetch`, XHR, và WebSocket. Claude nội tuyến CSS và JavaScript và nhúng hình ảnh dưới dạng data URI để trang kết xuất mà không cần bất kỳ yêu cầu bên ngoài nào. |
| Không có backend      | Một artifact là một trang tĩnh. Nó không thể lưu trữ dữ liệu gửi qua biểu mẫu, tự xác thực người xem, hoặc gọi API tại thời điểm xem.                                                                                                                     |
| Trang đơn             | Các link tương đối không phân giải được, vì không có gì được triển khai kèm với trang. Đối với nội dung nhiều phần, Claude dùng các anchor trong trang thay vì các file riêng biệt.                                                                        |
| Loại file nguồn       | File được xuất bản phải là `.html`, `.htm`, hoặc `.md`. Các file Markdown được kết xuất thành HTML đã tạo kiểu.                                                                                                                                          |
| Kích thước sau kết xuất | Trang sau khi kết xuất phải nhỏ hơn hoặc bằng 16 MiB. Hình ảnh nhúng cỡ lớn thường là nguyên nhân khi một lần xuất bản thất bại vì kích thước.                                                                                                            |

Việc tạo một artifact tiêu tốn output token như bất kỳ phản hồi nào khác, và một trang đã tạo kiểu tốn nhiều token hơn cùng nội dung đó dưới dạng văn bản terminal. CSS nội tuyến, JavaScript cho các điều khiển tương tác, và đặc biệt là hình ảnh nhúng dưới dạng data URI là những yếu tố đóng góp chính. Để giảm chi phí token của một artifact:

* Ưu tiên SVG, hoặc HTML và CSS, cho các sơ đồ thay vì hình ảnh raster nhúng
* Bỏ đi tính tương tác bạn không cần
* Cho trang tóm tắt các tập dữ liệu lớn thay vì nội tuyến chúng đầy đủ

## Điều kiện sử dụng

Artifact yêu cầu mọi điều kiện bên dưới. Khi một điều kiện không được đáp ứng, Claude ghi một file HTML cục bộ hoặc nói rằng nó không thể xuất bản.

| Yêu cầu             | Có sẵn khi                                                                                                                                                                                                                                                                          |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gói (Plan)          | Pro, Max, Team, hoặc Enterprise. Trên các gói Pro và Max, artifact là riêng tư với bạn, và không áp dụng quản trị của admin. Trên các gói Team, artifact được bật mặc định. Trên các gói Enterprise, một Owner [bật chúng](#manage-artifacts-for-your-organization) trong cài đặt admin của claude.ai. |
| Xác thực            | Đã đăng nhập vào claude.ai bằng `/login`. Các phiên dùng API key, [gateway token](/en/llm-gateway), hoặc thông tin xác thực của nhà cung cấp cloud không thể xuất bản.                                                                                                              |
| Nhà cung cấp mô hình | Anthropic API. Không có sẵn trên [Amazon Bedrock](/en/amazon-bedrock), [Google Cloud's Agent Platform](/en/google-vertex-ai), hoặc [Microsoft Foundry](/en/microsoft-foundry).                                                                                                      |
| Chính sách tổ chức  | Customer-managed encryption keys (CMEK), HIPAA, và [Zero Data Retention](/en/zero-data-retention) không được bật cho tổ chức.                                                                                                                                                       |
| Bề mặt (Surface)    | Claude Code CLI, hoặc ứng dụng Claude desktop phiên bản 1.13576.0 trở lên. Tắt mặc định trong bối cảnh [Agent SDK](/en/agent-sdk/overview), GitHub Action, và MCP-server, cũng như khi [`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`](/en/env-vars) được đặt.                          |

## Tắt artifact

Để tắt artifact cho các phiên của riêng bạn bất kể cài đặt của tổ chức, dùng bất kỳ cách nào sau đây:

| Phương pháp                          | Cài đặt                              |
| :----------------------------------- | :----------------------------------- |
| [File cài đặt](/en/settings)         | `"disableArtifact": true`            |
| [Biến môi trường](/en/env-vars)      | `CLAUDE_CODE_DISABLE_ARTIFACT=1`     |
| [Luật quyền](/en/permissions)        | Thêm `Artifact` vào `permissions.deny` |

## Quản lý artifact cho tổ chức của bạn

Owner trên các gói Team và Enterprise điều khiển artifact từ [cài đặt admin của claude.ai](https://claude.ai/admin-settings/claude-code). Nội dung artifact được lưu trên hạ tầng do Anthropic vận hành và chỉ hiển thị với các thành viên đã xác thực của tổ chức xuất bản.

### Bật hoặc tắt artifact

Để bật hoặc tắt artifact cho toàn bộ tổ chức, vào **Settings > Claude Code > Capabilities** và dùng công tắc **Artifacts**. Trên các gói Enterprise có kiểm soát truy cập theo vai trò (role-based access control), bạn còn có thể giới hạn artifact cho các vai trò cụ thể: vào **Settings > Roles**, chỉnh sửa một vai trò, và đặt quyền **Artifacts** dưới nhóm **Claude Code**.

### Đặt chính sách lưu giữ

Để đặt thời gian giữ artifact trước khi tự động xóa, vào **Settings > Data & privacy controls**. Bạn có thể đặt các khoảng thời gian lưu giữ riêng cho các artifact vẫn còn riêng tư với tác giả và các artifact đã được chia sẻ.

### Xem lại nhật ký kiểm tra (audit log)

Việc xuất bản, chia sẻ, và xóa một artifact đều xuất hiện trong nhật ký kiểm tra của tổ chức bạn dưới các loại sự kiện `claude_artifact_*`, cùng nhóm được dùng cho các artifact tạo trong các cuộc trò chuyện trên claude.ai.

### Đưa domain của trình xem vào danh sách cho phép (allowlist)

Trình xem trên claude.ai nạp mỗi artifact từ một origin `*.claudeusercontent.com` được sandbox. Nếu tổ chức của bạn hạn chế truy cập mạng đi ra, hãy thêm domain đó vào danh sách cho phép cùng với `claude.ai`. Xem [Yêu cầu truy cập mạng](/en/network-config#network-access-requirements) để biết danh sách đầy đủ.

### Liệt kê và xóa artifact với Compliance API

[Compliance API](https://docs.claude.com/en/api/compliance) cung cấp các endpoint để liệt kê các artifact của một tổ chức, lấy nội dung của một phiên bản cụ thể, và xóa một artifact:

| Phương thức | Endpoint                                                            |
| :---------- | :----------------------------------------------------------------- |
| `GET`       | `/v1/compliance/code/artifacts`                                     |
| `GET`       | `/v1/compliance/code/artifacts/{artifact_id}/versions/{version_id}` |
| `DELETE`    | `/v1/compliance/code/artifacts/{artifact_id}`                       |

Để biết schema của yêu cầu và phản hồi, xem [tài liệu tham chiếu Compliance API](https://docs.claude.com/en/api/compliance/code/artifacts).

## Tài nguyên liên quan

* Duyệt qua [các khuôn mẫu prompt và quy trình làm việc](/en/prompt-library) đi kèm với artifact
* Biến một prompt artifact bạn tái sử dụng thành một [skill](/en/skills) để bạn có thể gọi nó như một lệnh
* [Kết nối các MCP server](/en/mcp) để Claude có thể lấy dữ liệu trực tiếp vào một artifact
