> Nguồn: https://code.claude.com/docs/en/security-guidance.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bắt các vấn đề bảo mật khi Claude viết code

> Cài đặt plugin security-guidance để Claude review chính những thay đổi code của mình về các lỗ hổng và sửa chúng trong cùng phiên.

Plugin security guidance khiến Claude review chính những thay đổi code của mình về các lỗ hổng phổ biến khi nó làm việc và sửa những gì nó tìm thấy trong cùng phiên. Plugin bắt các vấn đề như injection, deserialization không an toàn, và các API DOM không an toàn trước khi code đến được một pull request, giảm bớt lượng review bảo mật rơi vào tay các reviewer là người ở phía sau.

Sau khi được cài đặt, plugin chạy tự động. Không có gì để gọi và không có lệnh riêng nào cần nhớ.

Plugin là đối tác trong-phiên của [Code Review](/en/code-review), vốn chạy trên các pull request. Plugin này giảm bớt lượng đến được PR. Code Review bắt những gì lọt qua. Để biết cách plugin xếp lớp với review theo yêu cầu và quét CI, xem [Cách nó khớp với các công cụ bảo mật khác](#how-this-fits-with-other-security-tools).

## Điều kiện tiên quyết

* Claude Code CLI phiên bản 2.1.144 trở lên
* Python 3.8 trở lên trên `PATH` của bạn. Plugin thử `python3`, `python`, và `py -3` theo thứ tự đó
* Một repository git cho thư mục bạn làm việc trong đó. Các review cuối lượt (end-of-turn) và review khi commit diff đối chiếu với trạng thái git và bỏ qua âm thầm bên ngoài một repository. Kiểm tra mẫu theo từng lần chỉnh sửa (per-edit) hoạt động ở bất cứ đâu

Trong lần chạy đầu tiên, plugin tạo một virtual environment dưới `~/.claude/security/` và cài đặt Claude Agent SDK vào đó, việc này yêu cầu `pip` và truy cập mạng. Nếu việc cài đặt đó thất bại, review khi commit chuyển sang một review một-lần (single-shot) thay vì review kiểu agentic. Trên Windows, bước virtual environment bị bỏ qua, nên review commit kiểu agentic chỉ chạy nếu `claude-agent-sdk` đã có thể import được và nếu không thì chuyển sang phương án dự phòng như trên.

## Cài đặt plugin

Trong một phiên Claude Code, cài đặt từ [marketplace chính thức của Anthropic](/en/discover-plugins#official-anthropic-marketplace):

```text theme={null}
/plugin install security-guidance@claude-plugins-official
```

Việc cài đặt nhắc chọn một phạm vi (scope). Chọn phạm vi user để ghi plugin vào cài đặt user của bạn, để nó tải trong mọi phiên cục bộ mới mà bạn bắt đầu trên máy này. Nếu Claude Code báo rằng không tìm thấy marketplace, chạy `/plugin marketplace add anthropics/claude-plugins-official` trước, sau đó thử cài đặt lại.

Sau đó kích hoạt nó trong phiên hiện tại bằng `/reload-plugins`, vốn áp dụng các thay đổi plugin đang chờ mà không cần khởi động lại:

```text theme={null}
/reload-plugins
```

### Bật trong các phiên đám mây và các repository dùng chung

Các plugin phạm vi user không mang theo vào [Claude Code trên web](/en/claude-code-on-the-web), vì các phiên đó chạy trên hạ tầng Anthropic thay vì máy của bạn. Để bật plugin ở đó, hoặc để bật nó cho mọi người clone một repository, hãy khai báo nó trong cài đặt được commit vào dự án:

```json .claude/settings.json theme={null}
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

Các quản trị viên có thể bật plugin trên toàn tổ chức bằng cách đặt [`enabledPlugins`](/en/settings#plugin-settings) trong [managed settings](/en/admin-setup).

## Plugin kiểm tra những gì

Plugin review công việc của Claude ở ba thời điểm, mỗi thời điểm ở một độ sâu khác nhau:

* [Ở mỗi lần chỉnh sửa file](#on-each-file-edit): một phép so khớp mẫu nhanh cho các lời gọi rủi ro, không có lời gọi model
* [Ở cuối mỗi lượt](#at-the-end-of-each-turn): một review bằng model chạy ở nền trên mọi thứ mà lượt đó đã thay đổi
* [Ở mỗi lần commit hoặc push mà Claude thực hiện](#on-each-commit-or-push-claude-makes): một review kiểu agentic sâu hơn, đọc code xung quanh

Bạn có thể mở rộng mỗi lớp bằng cách [thêm các quy tắc của riêng bạn](#add-your-own-rules). Không thể gỡ bỏ từng kiểm tra tích hợp sẵn riêng lẻ, nhưng bạn có thể [tắt từng lớp](#disable-or-uninstall) một cách độc lập.

### Ở mỗi lần chỉnh sửa file

Khi Claude ghi vào một file, plugin quét nội dung mới để tìm các mẫu rủi ro đã biết. Đây là một phép so khớp mẫu không có lời gọi model, nên nó không thêm chi phí sử dụng.

Các loại mẫu ví dụ:

* Thực thi code động: `eval(`, `new Function`, `os.system`, `child_process.exec`
* Deserialization không an toàn: `pickle`
* Injection DOM: `dangerouslySetInnerHTML`, `.innerHTML =`, `document.write`
* File workflow: các chỉnh sửa dưới `.github/workflows/`, vốn có thể cấp quyền ở cấp repository

Kiểm tra chạy sau khi chỉnh sửa được ghi và nối cảnh báo vào ngữ cảnh của Claude cho bước tiếp theo. Mỗi cảnh báo kích hoạt một lần cho mỗi mẫu cho mỗi file cho mỗi phiên, nên các lần khớp lặp lại trong cùng file không làm ngập cuộc hội thoại.

Bạn có thể [thêm các mẫu của riêng bạn](#add-custom-per-edit-patterns) vào lớp này bằng một file `security-patterns.yaml`.

### Ở cuối mỗi lượt

Một lượt (turn) là một vòng Claude phản hồi: bạn gửi một tin nhắn, Claude làm việc và trả lời, và lượt kết thúc. Sau mỗi lượt, plugin tính một git diff của mọi thứ đã thay đổi trong cây làm việc trong suốt lượt đó, bao gồm các thay đổi từ các công cụ chỉnh sửa của Claude, các lệnh Bash, và các subagent, rồi gửi nó đến một review Claude riêng biệt tập trung vào bảo mật. Review chạy ở nền, nên phản hồi của Claude không bị trì hoãn. Nếu review tìm thấy vấn đề, Claude được nhắc lại (re-prompt) với các phát hiện và xử lý chúng như một bước tiếp theo.

Điều này bắt các vấn đề mà một phép so khớp chuỗi không thể, chẳng hạn:

* Vượt qua kiểm soát ủy quyền (authorization bypass)
* Tham chiếu đối tượng trực tiếp không an toàn (insecure direct object references)
* Injection
* Giả mạo yêu cầu phía máy chủ (server-side request forgery)
* Mật mã yếu (weak cryptography)

Bạn thấy cả phát hiện và cách Claude giải quyết trực tiếp trong phiên của mình. Review bao phủ tối đa 30 file thay đổi mỗi lượt và kích hoạt tối đa ba lần liên tiếp trước khi nhường lại cho bạn.

### Ở mỗi lần commit hoặc push mà Claude thực hiện

Khi Claude chạy `git commit` hoặc `git push` qua công cụ Bash của nó, plugin chạy một review kiểu agentic sâu hơn trên thay đổi ở nền. Review này đọc code xung quanh, bao gồm các caller, các bộ làm sạch (sanitizer), và các file liên quan, để quyết định liệu một phát hiện có thực sự tồn tại trước khi báo cáo nó. Ngữ cảnh bổ sung giữ cho các cảnh báo sai (false positive) ở mức thấp đối với các mẫu trông nguy hiểm khi tách riêng nhưng an toàn trong codebase của bạn.

Lớp này chỉ kích hoạt ở các commit và push mà Claude thực hiện qua công cụ Bash của nó. Các commit bạn chạy từ shell của riêng bạn, bao gồm cả shell escape `!` bên trong một phiên, không được review. Các review commit và push bị giới hạn ở 20 lần mỗi giờ theo dạng cuốn chiếu (rolling). Nếu các phát hiện của review commit trùng với những gì review cuối lượt đã báo cáo, Claude không bị nhắc lại, nên một commit sạch không tạo ra đầu ra hiển thị nào từ lớp này.

### Tính độc lập và giới hạn của review

Plugin không yêu cầu chính instance Claude đã viết code tự chấm điểm mình. Kiểm tra per-edit là một phép so khớp chuỗi tất định (deterministic) không có model nào tham gia. Các review cuối lượt và review commit chạy như một lời gọi Claude riêng biệt với một ngữ cảnh mới và một prompt tập trung vào bảo mật: reviewer bắt đầu từ diff, không có sự đầu tư vào cách tiếp cận ban đầu, và chỉ được hướng dẫn để tìm vấn đề.

Không lớp nào chặn các lần ghi hoặc commit. Các phát hiện đến với Claude đang viết dưới dạng hướng dẫn, Claude xử lý chúng trong cuộc hội thoại, và model review có thể bỏ sót vấn đề. Hãy coi plugin là một lớp trong phòng thủ theo chiều sâu (defense in depth), không phải một giải pháp bảo mật hoàn chỉnh. Xem [Cách nó khớp với các công cụ bảo mật khác](#how-this-fits-with-other-security-tools).

## Thêm các quy tắc của riêng bạn

Plugin có hai điểm mở rộng: một file hướng dẫn Markdown cho các review dựa trên model, và một file mẫu YAML hoặc JSON cho phép so khớp chuỗi per-edit. Cả hai đều mang tính bổ sung (additive). Bạn có thể thêm kiểm tra nhưng không thể tắt các kiểm tra tích hợp sẵn từ các file này.

### Thêm hướng dẫn cho các review dựa trên model

Tạo `.claude/claude-security-guidance.md` trong dự án của bạn và mô tả mô hình mối đe dọa (threat model) cùng danh sách kiểm tra review của bạn bằng ngôn ngữ tự nhiên. Các review dựa trên model tải nó như ngữ cảnh bổ sung bên cạnh danh sách kiểm tra lỗ hổng tích hợp sẵn.

Ví dụ sau dành cho một dịch vụ web với các route admin được kiểm soát theo vai trò và một chính sách ghi log dữ liệu khách hàng:

```markdown .claude/claude-security-guidance.md theme={null}
# Security guidance for this repo

- Do not log `customer_id` or `account_number` at INFO level or above.
- All routes under `/admin` must call `require_role("admin")` before any database read.
- Use `crypto.timingSafeEqual` for token comparison instead of `===`.
```

Các quy tắc này là hướng dẫn cho reviewer, không phải các rào chắn tất định (deterministic guardrails). Plugin hiển thị các vi phạm dưới dạng phát hiện để Claude sửa, nhưng nó không chặn các lần ghi hay đảm bảo mọi vi phạm đều bị bắt. Hướng dẫn chỉ mang tính bổ sung: một quy tắc nói bỏ qua một lớp lỗ hổng không làm ngăn chặn các phát hiện đó. Để thực thi cứng, hãy ghép plugin với một [hook chặn chỉnh sửa](/en/hooks-guide#block-edits-to-protected-files) hoặc một kiểm tra CI.

### Thêm các mẫu per-edit tùy chỉnh

Tạo `.claude/security-patterns.yaml` để thêm các quy tắc regex hoặc chuỗi con vào [kiểm tra mẫu per-edit](#on-each-file-edit). Các quy tắc này chạy như các phép so khớp chuỗi tất định bên cạnh các mẫu tích hợp sẵn:

```yaml .claude/security-patterns.yaml theme={null}
patterns:
  - rule_name: internal_api_key
    substrings: ["sk_live_", "AKIA"]
    reminder: "Hardcoded API key prefix. Load credentials from the secret manager."
  - rule_name: tenant_unfiltered_query
    regex: "\\.objects\\.all\\(\\)"
    paths: ["**/src/tenants/**"]
    reminder: "Multi-tenant code must filter by org_id."
```

| Trường          | Kiểu   | Mô tả                                                                                                                                                  |
| :-------------- | :----- | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rule_name`     | string | Định danh hiển thị trong cảnh báo                                                                                                                     |
| `reminder`      | string | Văn bản cảnh báo được nối vào ngữ cảnh của Claude, giới hạn ở 1 KB                                                                                    |
| `regex`         | string | Regex Python được khớp với nội dung được chỉnh sửa                                                                                                   |
| `substrings`    | list   | Các chuỗi con nguyên văn; cung cấp trường này hoặc `regex`                                                                                           |
| `paths`         | list   | Các mẫu glob tùy chọn; quy tắc chỉ áp dụng cho các file khớp. Glob khớp với đường dẫn file đầy đủ, nên hãy tiền tố các mẫu tương đối với dự án bằng `**/` |
| `exclude_paths` | list   | Các mẫu glob tùy chọn để bỏ qua; cách khớp giống như `paths`                                                                                          |

Plugin cũng đọc `.claude/security-patterns.yml` và `.claude/security-patterns.json` với cùng lược đồ (schema). JSON hoạt động trên bất kỳ bản cài Python nào. Các dạng YAML yêu cầu PyYAML có thể import được, mà plugin không cài đặt giúp bạn. Plugin tải tối đa 50 quy tắc tùy chỉnh và bỏ qua các regex có vẻ dễ bị backtracking thảm họa (catastrophic backtracking).

### Các vị trí tra cứu file quy tắc

Plugin tìm `claude-security-guidance.md` và `security-patterns.yaml` ở cùng các vị trí, độc lập với cách plugin được bật:

| Phạm vi       | Đường dẫn                                   | Ghi chú                                    |
| :------------ | :------------------------------------------ | :--------------------------------------- |
| User          | `~/.claude/claude-security-guidance.md`     | Áp dụng cho mọi dự án trên máy của bạn    |
| Project       | `.claude/claude-security-guidance.md`       | Được commit cùng repository               |
| Project local | `.claude/claude-security-guidance.local.md` | Bị gitignore, dành cho ghi đè cá nhân     |

Plugin tải mọi vị trí tồn tại và ghép nối chúng lại, với giới hạn tổng hợp 8 KB cho file hướng dẫn. Các quản trị viên có thể phân phối các quy tắc trên toàn tổ chức bằng cách đẩy file phạm vi user tới `~/.claude/` thông qua quản lý thiết bị (device management). Các đường dẫn tương tự áp dụng cho `security-patterns.yaml`.

## Chi phí sử dụng

[Kiểm tra mẫu per-edit](#on-each-file-edit) không thực hiện lời gọi model nào và không thêm chi phí. Các review [cuối lượt](#at-the-end-of-each-turn) và [commit](#on-each-commit-or-push-claude-makes) mỗi loại tiêu tốn thêm mức sử dụng model tính vào [mức sử dụng (usage)](/en/costs) của bạn như bất kỳ yêu cầu Claude nào khác. Review commit là kiểu agentic và có thể mất vài lượt model mỗi commit, giới hạn ở 20 review mỗi giờ theo dạng cuốn chiếu. Hãy dự kiến khoảng một lời gọi review mỗi lượt có thay đổi file và một review sâu hơn mỗi commit, cả hai đều tuân theo các giới hạn trên.

Cả hai review dựa trên model dùng Claude Opus 4.7 theo mặc định. Đặt `SECURITY_REVIEW_MODEL` để chọn một model khác cho review cuối lượt và `SG_AGENTIC_MODEL` cho review commit.

Plugin khả dụng trên mọi gói.

## Tắt hoặc gỡ cài đặt

Để tắt từng lớp riêng lẻ trong khi giữ phần còn lại, đặt biến môi trường tương ứng:

| Biến                            | Tác động                                                                    |
| :------------------------------ | :------------------------------------------------------------------------- |
| `ENABLE_PATTERN_RULES=0`        | Tắt [kiểm tra mẫu per-edit](#on-each-file-edit)                             |
| `ENABLE_STOP_REVIEW=0`          | Tắt [review diff cuối lượt](#at-the-end-of-each-turn)                       |
| `ENABLE_COMMIT_REVIEW=0`        | Tắt [review commit và push](#on-each-commit-or-push-claude-makes)          |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Tắt mọi review dựa trên model cùng một lúc                                  |
| `SECURITY_GUIDANCE_DISABLE=1`   | Tắt plugin hoàn toàn mà không gỡ cài đặt                                    |

Để tạm dừng plugin trong phạm vi user của bạn:

```text theme={null}
/plugin disable security-guidance@claude-plugins-official
```

Để gỡ nó khỏi phạm vi user của bạn:

```text theme={null}
/plugin uninstall security-guidance@claude-plugins-official
```

Nếu plugin được bật thông qua `.claude/settings.json` của một dự án, việc tắt nó từ `/plugin` ghi một ghi đè vào `.claude/settings.local.json` của bạn thay vì chỉnh sửa file đã được commit, nên plugin vẫn tắt đối với bạn trong khi đồng đội không bị ảnh hưởng. Nếu nó được bật thông qua [managed settings](/en/admin-setup), chỉ một quản trị viên mới có thể tắt nó.

## Cách plugin tích hợp với Claude Code

Plugin được xây dựng hoàn toàn trên [hooks](/en/hooks), cơ chế để chạy code của riêng bạn tại các điểm cụ thể trong vòng lặp của Claude. Nó đăng ký:

| Sự kiện hook                                                     | Mục đích                                                                     |
| :--------------------------------------------------------------- | :-------------------------------------------------------------------------- |
| `SessionStart`                                                   | Khởi tạo (bootstrap) môi trường Python của plugin                           |
| `UserPromptSubmit`                                               | Ghi lại baseline của cây làm việc mà review cuối lượt diff đối chiếu       |
| `PostToolUse` trên `Edit`, `Write`, và `NotebookEdit`            | So khớp mẫu per-edit                                                        |
| `Stop`                                                           | Review diff cuối lượt, chạy ở nền                                           |
| `PostToolUse` trên `Bash`, được lọc theo `git commit` và `git push` | Review commit và push, chạy ở nền                                       |

Nếu bạn xây dựng các hook của riêng mình, [mã nguồn của plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance) là một ví dụ hoạt động về việc chạy một lời gọi model riêng biệt từ một hook và đưa kết quả trở lại phiên.

## Cách nó khớp với các công cụ bảo mật khác

Plugin là một lớp trong cách tiếp cận phòng thủ theo chiều sâu. Nó bắt các vấn đề sớm nhất, khi code còn trong trình soạn thảo, nhưng nó không phải một sự đảm bảo và không thay thế các kiểm tra sau này. Một tầng công cụ điển hình:

| Giai đoạn       | Công cụ                                                   | Nó bao phủ những gì                                                                              |
| :-------------- | :-------------------------------------------------------- | :----------------------------------------------------------------------------------------------- |
| Trong phiên     | Plugin security guidance                                  | Các lỗ hổng phổ biến trong code Claude viết, được sửa trong cùng phiên                            |
| Theo yêu cầu    | [`/security-review`](/en/commands#all-commands)           | Một lượt kiểm tra bảo mật một lần trên nhánh hiện tại, chạy khi bạn yêu cầu                        |
| Trên pull request | [Code Review](/en/code-review), gói Team và Enterprise  | Review tính đúng đắn và bảo mật đa agent với đầy đủ ngữ cảnh codebase                             |
| Trong CI        | Các bộ phân tích tĩnh và quét phụ thuộc hiện có của bạn   | Các quy tắc theo ngôn ngữ, kiểm tra chuỗi cung ứng, và thực thi chính sách mà plugin không cố làm |

Mỗi giai đoạn sau bắt những gì các giai đoạn trước bỏ sót. Giá trị của plugin là giảm lượng đến được chúng, không phải loại bỏ nhu cầu về chúng.

## Khắc phục sự cố

Plugin ghi các chẩn đoán thời gian chạy vào `~/.claude/security/log.txt`. Hãy kiểm tra ở đó trước nếu các review không xuất hiện.

Các lý do phổ biến khiến một lớp review bị bỏ qua mà không có thông báo trong cuộc hội thoại:

* Thư mục không phải một repository git: các review cuối lượt và commit yêu cầu trạng thái git và bỏ qua bên ngoài một repository
* Phiên không có xác thực Anthropic: các review dựa trên model bị bỏ qua và chỉ kiểm tra mẫu per-edit chạy
* Có một file `security-patterns.yaml` nhưng PyYAML không import được: file bị bỏ qua. Dùng `security-patterns.json` thay thế

## Tài nguyên liên quan

Để đi sâu hơn về các phần mà trang này đề cập:

* [Code Review](/en/code-review): thiết lập review đa agent tại thời điểm PR
* [Tự động hóa hành động với hooks](/en/hooks-guide): xây dựng các kiểm tra của riêng bạn tại cùng các điểm vòng đời
* [Khám phá và cài đặt plugin](/en/discover-plugins#official-anthropic-marketplace): duyệt các plugin chính thức khác
