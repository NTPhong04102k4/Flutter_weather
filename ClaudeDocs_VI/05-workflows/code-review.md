> Nguồn: https://code.claude.com/docs/en/code-review.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Code Review

> Thiết lập việc review PR tự động nhằm bắt các lỗi logic, lỗ hổng bảo mật và hồi quy (regression) bằng phân tích đa agent trên toàn bộ codebase của bạn

<Note>
  Code Review đang ở giai đoạn research preview, khả dụng cho các gói đăng ký [Team và Enterprise](https://claude.ai/admin-settings/claude-code). Nó không khả dụng cho các tổ chức đã bật [Zero Data Retention](/en/zero-data-retention).
</Note>

Code Review phân tích các pull request GitHub của bạn và đăng các phát hiện dưới dạng bình luận inline tại các dòng code nơi nó tìm thấy vấn đề. Một đội gồm các agent chuyên biệt xem xét những thay đổi của code trong ngữ cảnh của toàn bộ codebase, tìm các lỗi logic, lỗ hổng bảo mật, trường hợp biên bị hỏng và các hồi quy tinh vi.

Các phát hiện được gắn thẻ theo mức độ nghiêm trọng và không phê duyệt hay chặn PR của bạn, nên các quy trình review hiện có vẫn giữ nguyên. Bạn có thể tinh chỉnh những gì Claude gắn cờ bằng cách thêm một file `CLAUDE.md` hoặc `REVIEW.md` vào repository của mình.

Để chạy Claude trong hạ tầng CI của riêng bạn thay vì dịch vụ được quản lý này, xem [GitHub Actions](/en/github-actions) hoặc [GitLab CI/CD](/en/gitlab-ci-cd). Đối với các repository trên một instance GitHub tự lưu trữ (self-hosted), xem [GitHub Enterprise Server](/en/github-enterprise-server).

Trang này bao gồm:

* [Cách các review hoạt động](#how-reviews-work)
* [Thiết lập](#set-up-code-review)
* [Kích hoạt review thủ công](#manually-trigger-reviews) bằng `@claude review` và `@claude review once`
* [Tùy chỉnh review](#customize-reviews) bằng `CLAUDE.md` và `REVIEW.md`
* [Giá cả](#pricing)
* [Khắc phục sự cố](#troubleshooting) đối với các lần chạy thất bại và bình luận bị thiếu
* [Review một diff cục bộ](#review-a-diff-locally) bằng lệnh `/code-review`

<Note>
  Để review một diff cục bộ trong terminal của bạn mà không cài đặt GitHub App, chạy lệnh `/code-review` trong bất kỳ phiên Claude Code nào. Xem [Review một diff cục bộ](#review-a-diff-locally).
</Note>

## Cách các review hoạt động

Sau khi một Owner [bật Code Review](#set-up-code-review) cho tổ chức của bạn, các review được kích hoạt khi một PR mở, ở mỗi lần push, hoặc khi được yêu cầu thủ công, tùy vào hành vi được cấu hình của repository. Bình luận `@claude review` [khởi động các review trên một PR](#manually-trigger-reviews) ở bất kỳ chế độ nào.

Khi một review chạy, nhiều agent phân tích diff và code xung quanh song song trên hạ tầng của Anthropic. Mỗi agent tìm một lớp vấn đề khác nhau, sau đó một bước xác minh kiểm tra các ứng viên đối chiếu với hành vi thực tế của code để loại bỏ các cảnh báo sai (false positive). Kết quả được loại bỏ trùng lặp, xếp hạng theo mức độ nghiêm trọng, và đăng dưới dạng bình luận inline tại các dòng cụ thể nơi tìm thấy vấn đề, kèm một bản tóm tắt trong phần thân review. Nếu không tìm thấy vấn đề nào, Code Review cập nhật check run của GitHub để cho thấy không phát hiện vấn đề. Claude cũng có thể đăng một bình luận xác nhận ngắn trên PR.

Chi phí review tỉ lệ theo kích thước và độ phức tạp của PR, hoàn thành trong trung bình 20 phút. Các Owner có thể giám sát hoạt động review và chi tiêu qua [bảng điều khiển phân tích (analytics dashboard)](#view-usage).

### Các mức độ nghiêm trọng

Mỗi phát hiện được gắn thẻ một mức độ nghiêm trọng:

| Ký hiệu | Mức độ       | Ý nghĩa                                                             |
| :------ | :----------- | :----------------------------------------------------------------- |
| 🔴      | Important    | Một lỗi cần được sửa trước khi merge                               |
| 🟡      | Nit          | Một vấn đề nhỏ, nên sửa nhưng không chặn                           |
| 🟣      | Pre-existing | Một lỗi đã tồn tại trong codebase nhưng không do PR này gây ra     |

Các phát hiện bao gồm một phần lý giải mở rộng có thể thu gọn, bạn có thể mở ra để hiểu vì sao Claude gắn cờ vấn đề và nó đã xác minh vấn đề như thế nào.

### Đánh giá và phản hồi các phát hiện

Mỗi bình luận review từ Claude đến kèm sẵn 👍 và 👎 để cả hai nút xuất hiện trong giao diện GitHub cho việc đánh giá một-cú-nhấp. Nhấp 👍 nếu phát hiện hữu ích hoặc 👎 nếu nó sai hoặc gây nhiễu. Anthropic thu thập số lượng phản ứng sau khi PR được merge và dùng chúng để tinh chỉnh trình review. Các phản ứng không kích hoạt review lại hay thay đổi bất cứ điều gì trên PR.

Trả lời một bình luận inline không thúc đẩy Claude phản hồi hoặc cập nhật PR. Để xử lý một phát hiện, hãy sửa code và push. Nếu PR đăng ký các review kích hoạt theo push, lần chạy tiếp theo sẽ giải quyết (resolve) luồng bình luận khi vấn đề được sửa. Để yêu cầu một review mới mà không push, bình luận `@claude review once` dưới dạng một [bình luận PR cấp cao nhất](#manually-trigger-reviews).

### Đầu ra của check run

Ngoài các bình luận review inline, mỗi review điền vào check run **Claude Code Review** xuất hiện cùng với các check CI của bạn. Mở rộng liên kết **Details** của nó để xem bản tóm tắt của mọi phát hiện ở cùng một nơi, được sắp xếp theo mức độ nghiêm trọng:

| Mức độ       | File:Line                 | Vấn đề                                                          |
| ------------ | ------------------------- | -------------------------------------------------------------- |
| 🔴 Important | `src/auth/session.ts:142` | Việc làm mới token đua (race) với logout, để lại các phiên cũ vẫn hoạt động |
| 🟡 Nit       | `src/auth/session.ts:88`  | `parseExpiry` âm thầm trả về 0 khi đầu vào không đúng định dạng |

Mỗi phát hiện cũng xuất hiện dưới dạng chú thích (annotation) trong tab **Files changed**, được đánh dấu trực tiếp trên các dòng diff liên quan. Các phát hiện Important hiển thị với dấu đỏ, các nit với cảnh báo vàng, và các lỗi có sẵn (pre-existing) với thông báo màu xám. Các chú thích và bảng mức độ nghiêm trọng được ghi vào check run độc lập với các bình luận review inline, nên chúng vẫn khả dụng ngay cả khi GitHub từ chối một bình luận inline trên một dòng đã bị dịch chuyển.

Check run luôn hoàn thành với kết luận trung lập (neutral) nên nó không bao giờ chặn việc merge thông qua các quy tắc bảo vệ nhánh (branch protection). Nếu bạn muốn kiểm soát việc merge dựa trên các phát hiện của Code Review, hãy đọc phần phân tích mức độ nghiêm trọng từ đầu ra check run trong CI của riêng bạn. Dòng cuối của phần văn bản Details là một bình luận có thể đọc bằng máy mà workflow của bạn có thể phân tích bằng `gh` và jq:

```bash theme={null}
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Lệnh này trả về một đối tượng JSON với số lượng theo từng mức độ nghiêm trọng, ví dụ `{"normal": 2, "nit": 1, "pre_existing": 0}`. Khóa `normal` chứa số lượng phát hiện Important; một giá trị khác không nghĩa là Claude đã tìm thấy ít nhất một lỗi đáng sửa trước khi merge.

### Code Review kiểm tra những gì

Theo mặc định, Code Review tập trung vào tính đúng đắn (correctness): các lỗi sẽ phá vỡ production, không phải các sở thích định dạng hay việc thiếu bao phủ test. Bạn có thể mở rộng phạm vi kiểm tra bằng cách [thêm các file hướng dẫn](#customize-reviews) vào repository của mình.

## Thiết lập Code Review

Một Owner bật Code Review một lần cho tổ chức và chọn những repository nào được đưa vào.

<Steps>
  <Step title="Mở cài đặt quản trị Claude Code">
    Truy cập [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) và tìm mục Code Review. Bạn cần vai trò Owner hoặc Primary Owner trong tổ chức Claude của bạn và quyền cài đặt GitHub Apps trong tổ chức GitHub của bạn.
  </Step>

  <Step title="Bắt đầu thiết lập">
    Nhấp **Setup**. Điều này bắt đầu luồng cài đặt GitHub App.
  </Step>

  <Step title="Cài đặt Claude GitHub App">
    Làm theo các hướng dẫn để cài đặt Claude GitHub App vào tổ chức GitHub của bạn. App yêu cầu các quyền repository sau:

    * **Contents**: đọc và ghi
    * **Issues**: đọc và ghi
    * **Pull requests**: đọc và ghi

    Code Review dùng quyền đọc contents và quyền ghi pull requests. Tập quyền rộng hơn cũng hỗ trợ [GitHub Actions](/en/github-actions) nếu bạn bật tính năng đó sau này.
  </Step>

  <Step title="Chọn repository">
    Chọn những repository nào bật cho Code Review. Nếu bạn không thấy một repository, hãy đảm bảo bạn đã cấp cho Claude GitHub App quyền truy cập vào nó trong lúc cài đặt. Bạn có thể thêm nhiều repository hơn sau này.
  </Step>

  <Step title="Đặt điều kiện kích hoạt review cho từng repo">
    Sau khi thiết lập hoàn tất, mục Code Review hiển thị các repository của bạn trong một bảng. Với mỗi repository, dùng dropdown **Review Behavior** để chọn khi nào review chạy:

    * **Once after PR creation**: review chạy một lần khi một PR được mở hoặc được đánh dấu sẵn sàng review
    * **After every push**: review chạy ở mỗi lần push lên nhánh PR, bắt các vấn đề mới khi PR tiến triển và tự động giải quyết các luồng bình luận khi bạn sửa các vấn đề đã gắn cờ
    * **Manual**: review chỉ bắt đầu khi ai đó [bình luận `@claude review` hoặc `@claude review once` trên một PR](#manually-trigger-reviews); `@claude review` cũng đăng ký PR vào các review ở những lần push sau

    Review ở mỗi lần push chạy nhiều review nhất và tốn chi phí nhiều nhất. Chế độ Manual hữu ích cho các repo lưu lượng cao khi bạn muốn chọn từng PR cụ thể vào review, hoặc để chỉ bắt đầu review các PR của bạn khi chúng đã sẵn sàng.
  </Step>
</Steps>

Bảng repository cũng hiển thị chi phí trung bình mỗi review cho từng repo dựa trên hoạt động gần đây. Dùng menu hành động trên từng hàng để bật hoặc tắt Code Review cho từng repository, hoặc gỡ bỏ hoàn toàn một repository.

Để xác minh việc thiết lập, mở một PR thử nghiệm. Nếu bạn chọn một điều kiện kích hoạt tự động, một check run có tên **Claude Code Review** sẽ xuất hiện trong vài phút. Nếu bạn chọn Manual, bình luận `@claude review` trên PR để bắt đầu review đầu tiên. Nếu không có check run nào xuất hiện, hãy xác nhận repository được liệt kê trong cài đặt quản trị của bạn và Claude GitHub App có quyền truy cập vào nó.

## Kích hoạt review thủ công

Hai lệnh bình luận khởi động một review theo yêu cầu. Cả hai đều hoạt động bất kể điều kiện kích hoạt được cấu hình của repository, nên bạn có thể dùng chúng để chọn từng PR cụ thể vào review ở chế độ Manual hoặc để có một review lại ngay lập tức ở các chế độ khác.

| Lệnh                  | Nó làm gì                                                                     |
| :-------------------- | :--------------------------------------------------------------------------- |
| `@claude review`      | Bắt đầu một review và đăng ký PR vào các review kích hoạt theo push về sau     |
| `@claude review once` | Bắt đầu một review duy nhất mà không đăng ký PR vào các lần push tương lai      |

Dùng `@claude review once` khi bạn muốn phản hồi về trạng thái hiện tại của một PR nhưng không muốn mỗi lần push tiếp theo phát sinh một review. Điều này hữu ích cho các PR dài hạn với nhiều lần push, hoặc khi bạn muốn một ý kiến thứ hai một lần mà không thay đổi hành vi review của PR.

Để một trong hai lệnh kích hoạt được review:

* Đăng nó dưới dạng một bình luận PR cấp cao nhất, không phải một bình luận inline trên một dòng diff
* Đặt lệnh ở đầu bình luận, với `once` trên cùng một dòng nếu bạn dùng dạng một-lần
* Bạn phải có quyền truy cập owner, member, hoặc collaborator vào repository
* PR phải đang mở

Không giống các điều kiện kích hoạt tự động, các kích hoạt thủ công chạy trên các PR nháp (draft), vì một yêu cầu tường minh báo hiệu rằng bạn muốn review ngay bất kể trạng thái nháp.

Nếu đã có một review đang chạy trên PR đó, yêu cầu sẽ được xếp hàng cho đến khi review đang tiến hành hoàn tất. Bạn có thể giám sát tiến trình qua check run trên PR.

## Tùy chỉnh review

Code Review đọc hai file từ repository của bạn để định hướng những gì nó gắn cờ. Chúng khác nhau ở mức độ ảnh hưởng mạnh yếu đến review:

* **`CLAUDE.md`**: hướng dẫn dự án dùng chung mà Claude Code sử dụng cho mọi tác vụ, không chỉ review. Code Review đọc nó như ngữ cảnh dự án và gắn cờ các vi phạm mới được đưa vào dưới dạng nit.
* **`REVIEW.md`**: hướng dẫn chỉ dành cho review, được đưa trực tiếp vào mọi agent trong pipeline review với mức độ ưu tiên cao nhất. Dùng nó để thay đổi những gì được gắn cờ, ở mức độ nghiêm trọng nào, và các phát hiện được báo cáo như thế nào.

### CLAUDE.md

Code Review đọc các file `CLAUDE.md` của repository của bạn và coi các vi phạm mới được đưa vào là các phát hiện [ở mức nit](#severity-levels). Điều này hoạt động hai chiều: nếu PR của bạn thay đổi code theo cách làm cho một câu trong `CLAUDE.md` trở nên lỗi thời, Claude cũng gắn cờ rằng tài liệu cần được cập nhật.

Claude đọc các file `CLAUDE.md` ở mọi cấp trong cây thư mục của bạn, nên các quy tắc trong `CLAUDE.md` của một thư mục con chỉ áp dụng cho các file dưới đường dẫn đó. Xem [tài liệu về bộ nhớ (memory)](/en/memory) để biết thêm về cách `CLAUDE.md` hoạt động.

Đối với hướng dẫn dành riêng cho review mà bạn không muốn áp dụng cho các phiên Claude Code thông thường, dùng [`REVIEW.md`](#review-md) thay thế.

### REVIEW\.md

`REVIEW.md` là một file ở thư mục gốc của repository, ghi đè cách Code Review hành xử trên repo của bạn. Nội dung của nó được đưa vào system prompt của mọi agent trong pipeline review như khối hướng dẫn có mức ưu tiên cao nhất, được ưu tiên hơn hướng dẫn review mặc định.

Vì nó được dán nguyên văn, `REVIEW.md` là hướng dẫn thuần túy: [cú pháp import `@`](/en/memory#import-additional-files) không được mở rộng, và các file được tham chiếu không được đọc vào prompt. Hãy đặt các quy tắc bạn muốn thực thi trực tiếp trong file.

#### Những gì bạn có thể tinh chỉnh

`REVIEW.md` là markdown tự do, nên bất cứ điều gì bạn có thể diễn đạt thành một hướng dẫn review đều nằm trong phạm vi. Các mẫu dưới đây có tác động lớn nhất trong thực tế.

**Mức độ nghiêm trọng (Severity)**: định nghĩa lại 🔴 Important nghĩa là gì cho repo của bạn. Cách hiệu chỉnh mặc định nhắm vào code production; một repo tài liệu, một repo cấu hình, hoặc một nguyên mẫu (prototype) có thể muốn một định nghĩa hẹp hơn nhiều. Hãy nêu rõ những lớp phát hiện nào là Important và những lớp nào tối đa chỉ là Nit. Bạn cũng có thể leo thang theo hướng ngược lại, ví dụ coi mọi vi phạm `CLAUDE.md` là Important thay vì mức nit mặc định.

**Số lượng nit (Nit volume)**: giới hạn số bình luận 🟡 Nit mà một review đăng. Các file văn bản và cấu hình có thể được đánh bóng vô tận. Một giới hạn như "report at most five nits, mention the rest as a count in the summary" giữ cho các review có tính hành động.

**Quy tắc bỏ qua (Skip rules)**: liệt kê các đường dẫn, mẫu nhánh và loại phát hiện mà ở đó Claude không nên đăng phát hiện nào. Các ứng viên phổ biến là code được sinh tự động, file lock, các phụ thuộc được vendor, và các nhánh do máy tạo ra, cùng với bất cứ điều gì CI của bạn đã thực thi như lint hoặc kiểm tra chính tả. Đối với các đường dẫn cần một số review nhưng không phải soi xét đầy đủ, hãy đặt một tiêu chuẩn cao hơn thay vì bỏ qua hoàn toàn: "in `scripts/`, only report if near-certain and severe."

**Kiểm tra riêng cho repo (Repo-specific checks)**: thêm các quy tắc bạn muốn được gắn cờ trên mọi PR, như "new API routes must have an integration test." Vì `REVIEW.md` được đưa vào với mức ưu tiên cao nhất, các quy tắc này được áp dụng đáng tin cậy hơn so với cùng quy tắc đó trong một `CLAUDE.md` dài.

**Tiêu chuẩn xác minh (Verification bar)**: yêu cầu bằng chứng trước khi một lớp phát hiện được đăng. Ví dụ, "behavior claims need a `file:line` citation in the source, not an inference from naming" cắt giảm các cảnh báo sai vốn sẽ khiến tác giả mất một vòng đi lại.

**Hội tụ khi review lại (Re-review convergence)**: cho Claude biết cách hành xử khi một PR đã được review. Một quy tắc như "after the first review, suppress new nits and post Important findings only" ngăn một bản sửa một-dòng đi đến vòng thứ bảy chỉ vì phong cách.

**Hình thức bản tóm tắt (Summary shape)**: yêu cầu phần thân review mở đầu bằng một dòng thống kê như `2 factual, 4 style`, và dẫn đầu bằng "no factual issues" khi đúng là như vậy. Tác giả muốn biết hình dạng của công việc trước khi đi vào chi tiết.

#### Ví dụ

`REVIEW.md` này hiệu chỉnh lại mức độ nghiêm trọng cho một dịch vụ backend, giới hạn nit, bỏ qua các file được sinh tự động, và thêm các kiểm tra riêng cho repo.

```markdown theme={null}
# Review instructions

## What Important means here

Reserve Important for findings that would break behavior, leak data,
or block a rollback: incorrect logic, unscoped database queries, PII
in logs or error messages, and migrations that aren't backward
compatible. Style, naming, and refactoring suggestions are Nit at
most.

## Cap the nits

Report at most five Nits per review. If you found more, say "plus N
similar items" in the summary instead of posting them inline. If
everything you found is a Nit, lead the summary with "No blocking
issues."

## Do not report

- Anything CI already enforces: lint, formatting, type errors
- Generated files under `src/gen/` and any `*.lock` file
- Test-only code that intentionally violates production rules

## Always check

- New API routes have an integration test
- Log lines don't include email addresses, user IDs, or request bodies
- Database queries are scoped to the caller's tenant
```

#### Giữ nó tập trung

Độ dài có cái giá của nó: một `REVIEW.md` dài làm loãng các quy tắc quan trọng nhất. Hãy giữ nó chỉ gồm những hướng dẫn thay đổi hành vi review, và để ngữ cảnh dự án chung trong `CLAUDE.md`.

## Xem mức sử dụng

Truy cập [claude.ai/analytics/code-review](https://claude.ai/analytics/code-review) để xem hoạt động Code Review trên toàn tổ chức của bạn. Bảng điều khiển hiển thị:

| Mục                  | Nó cho thấy gì                                                                          |
| :------------------- | :-------------------------------------------------------------------------------------- |
| PRs reviewed         | Số lượng pull request được review mỗi ngày trong khoảng thời gian đã chọn                |
| Cost weekly          | Chi tiêu hằng tuần cho Code Review                                                       |
| Feedback             | Số bình luận review được tự động giải quyết vì một lập trình viên đã xử lý vấn đề         |
| Repository breakdown | Số lượng PR được review và bình luận đã giải quyết theo từng repo                        |

Bảng repository trong cài đặt quản trị cũng hiển thị chi phí trung bình mỗi review cho từng repo. Các con số chi phí trên bảng điều khiển là ước tính để giám sát hoạt động; để biết chi tiêu chính xác theo hóa đơn, hãy tham khảo hóa đơn Anthropic của bạn.

## Giá cả

Code Review được tính phí dựa trên mức sử dụng token. Mỗi review trung bình tốn \$15-25, tỉ lệ theo kích thước PR, độ phức tạp của codebase, và số vấn đề cần xác minh. Mức sử dụng Code Review được tính phí riêng qua [usage credits](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) và không tính vào mức sử dụng bao gồm trong gói của bạn.

Điều kiện kích hoạt review bạn chọn ảnh hưởng đến tổng chi phí:

* **Once after PR creation**: chạy một lần mỗi PR
* **After every push**: chạy ở mỗi lần push, nhân chi phí với số lần push
* **Manual**: không có review nào cho đến khi ai đó bình luận `@claude review` trên một PR

Ở bất kỳ chế độ nào, bình luận `@claude review` [chọn PR vào các review kích hoạt theo push](#manually-trigger-reviews), nên chi phí bổ sung phát sinh theo mỗi lần push sau bình luận đó. Để chạy một review duy nhất mà không đăng ký các lần push tương lai, bình luận `@claude review once` thay thế.

Chi phí xuất hiện trên hóa đơn Anthropic của bạn bất kể tổ chức của bạn dùng Amazon Bedrock hay Agent Platform của Google Cloud cho các tính năng Claude Code khác. Để đặt giới hạn chi tiêu hằng tháng cho Code Review, truy cập [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage) và cấu hình giới hạn cho dịch vụ Claude Code Review.

Giám sát chi tiêu qua biểu đồ chi phí hằng tuần trong [analytics](#view-usage) hoặc cột chi phí trung bình theo từng repo trong cài đặt quản trị.

## Khắc phục sự cố

Các lần chạy review là nỗ lực tốt nhất (best-effort). Một lần chạy thất bại không bao giờ chặn PR của bạn, nhưng nó cũng không tự thử lại. Phần này bao gồm cách khôi phục từ một lần chạy thất bại và nơi cần xem khi check run báo cáo các vấn đề bạn không tìm thấy.

### Kích hoạt lại một review thất bại hoặc quá thời gian

Khi hạ tầng review gặp lỗi nội bộ hoặc vượt quá giới hạn thời gian, check run hoàn thành với tiêu đề **Code review encountered an error** hoặc **Code review timed out**. Kết luận vẫn là trung lập, nên không có gì chặn việc merge của bạn, nhưng không có phát hiện nào được đăng.

Để chạy lại review, bình luận `@claude review once` trên PR. Điều này bắt đầu một review mới mà không đăng ký PR vào các lần push tương lai. Nếu PR đã đăng ký các review kích hoạt theo push, việc push một commit mới cũng bắt đầu một review mới.

Nút **Re-run** trong tab Checks của GitHub không kích hoạt lại Code Review. Dùng lệnh bình luận hoặc một lần push mới thay thế.

### Review không chạy và PR hiển thị thông báo giới hạn chi tiêu

Khi giới hạn chi tiêu hằng tháng của tổ chức bạn đạt tới, Code Review đăng một bình luận duy nhất trên PR giải thích rằng review đã bị bỏ qua. Các review tiếp tục tự động vào đầu kỳ thanh toán tiếp theo, hoặc ngay lập tức khi một quản trị viên nâng giới hạn tại [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage).

### Tìm các vấn đề không hiển thị dưới dạng bình luận inline

Nếu tiêu đề check run nói rằng đã tìm thấy vấn đề nhưng bạn không thấy các bình luận review inline trên diff, hãy xem ở những nơi khác nơi các phát hiện được hiển thị:

* **Check run Details**: nhấp **Details** bên cạnh check Claude Code Review trong tab Checks. Bảng mức độ nghiêm trọng liệt kê mọi phát hiện với file, dòng và tóm tắt của nó bất kể bình luận inline có được chấp nhận hay không.
* **Files changed annotations**: mở tab **Files changed** trên PR. Các phát hiện hiển thị dưới dạng chú thích gắn trực tiếp vào các dòng diff, tách biệt với các bình luận review.
* **Review body**: nếu bạn push lên PR trong khi một review đang chạy, một số phát hiện có thể tham chiếu các dòng không còn tồn tại trong diff hiện tại. Những phát hiện đó xuất hiện dưới tiêu đề **Additional findings** trong phần văn bản thân review thay vì dưới dạng bình luận inline.

## Review một diff cục bộ

[Lệnh `/code-review`](/en/commands) review một diff trong terminal của bạn mà không cần cài đặt GitHub App. Chạy nó trong bất kỳ phiên Claude Code nào: nó báo cáo các lỗi tính đúng đắn và {/* min-version: 2.1.151 */}các dọn dẹp về tái sử dụng, đơn giản hóa và hiệu quả. Theo mặc định, review cục bộ bao gồm các commit của nhánh của bạn đi trước upstream của nó cộng với bất kỳ thay đổi chưa commit nào trong cây làm việc (working tree). Truyền `--comment` để đăng các phát hiện dưới dạng bình luận PR inline, hoặc `--fix` để áp dụng các phát hiện vào cây làm việc của bạn sau khi review.

Các [mức nỗ lực (effort level)](/en/model-config#adjust-effort-level) thấp hơn trả về ít phát hiện hơn nhưng độ tin cậy cao hơn, trong khi `high` đến `max` cho phạm vi bao phủ rộng hơn và có thể bao gồm các phát hiện không chắc chắn. Nếu không có tham số effort, review dùng mức nỗ lực hiện tại của phiên. Để review một thứ khác với diff mặc định, truyền một mục tiêu: một đường dẫn file, một số PR, một tên nhánh, hoặc một dải ref như `main...my-feature`. Dạng dải ref review diff đã commit mà một pull request từ `my-feature` vào `main` sẽ chứa, bất kể upstream của nhánh được cấu hình như thế nào.

`/code-review ultra --fix` chạy [ultrareview](/en/ultrareview) sâu hơn trên đám mây, rồi áp dụng các phát hiện của nó vào cây làm việc của bạn khi chúng quay về phiên của bạn. Ultrareview dùng phạm vi riêng của nó: nhánh hiện tại của bạn đối chiếu với nhánh mặc định của repository, cộng với bất kỳ thay đổi chưa commit và đã staged nào trong cây làm việc.

Lệnh này có tên là `/simplify` trước v2.1.147, khi nó áp dụng các bản sửa theo mặc định. {/* min-version: 2.1.154 */}Từ v2.1.154, `/simplify` chạy một review riêng chỉ dọn dẹp, áp dụng các bản sửa mà không truy tìm lỗi. Nếu bạn đã script hóa `/simplify` để truy tìm lỗi, hãy chuyển sang `/code-review --fix`, vốn không thay đổi.

## Tài nguyên liên quan

Code Review được thiết kế để hoạt động cùng với phần còn lại của Claude Code. Nếu bạn muốn chạy các review cục bộ trước khi mở một PR, cần một thiết lập tự lưu trữ, hoặc muốn đi sâu hơn về cách `CLAUDE.md` định hình hành vi của Claude qua các công cụ, các trang này là những điểm dừng tiếp theo tốt:

* [Commands](/en/commands): chạy `/code-review` trong một phiên Claude Code cục bộ để kiểm tra một diff trước khi push
* [GitHub Actions](/en/github-actions): chạy Claude trong các workflow GitHub Actions của riêng bạn để tự động hóa tùy chỉnh vượt ra ngoài code review
* [GitLab CI/CD](/en/gitlab-ci-cd): tích hợp Claude tự lưu trữ cho các pipeline GitLab
* [Memory](/en/memory): cách các file `CLAUDE.md` hoạt động trên toàn Claude Code
* [Analytics](/en/analytics): theo dõi mức sử dụng Claude Code ngoài code review
