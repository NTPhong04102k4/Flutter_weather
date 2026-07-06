> Nguồn: https://code.claude.com/docs/en/champion-kit.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Bộ công cụ cho người tiên phong (Champion kit)

> Một cẩm nang cho các kỹ sư vận động sử dụng Claude Code trong nội bộ: chia sẻ những gì, trả lời các câu hỏi ra sao, và làm thế nào để mở rộng việc áp dụng trong nhóm của bạn.

Trang này dành cho các kỹ sư cá nhân đã sử dụng Claude Code và muốn giúp nhóm của mình áp dụng nó. Nó bao gồm những gì nên chia sẻ, cách trả lời những câu hỏi bạn sẽ nhận được, một cẩm nang ba mươi ngày, và các phản hồi cho những mối lo ngại phổ biến.

Việc áp dụng một công cụ dành cho lập trình viên hiếm khi xảy ra vì một thông báo triển khai. Nó xảy ra vì một ai đó trong nhóm bắt đầu dùng công cụ đó thật tốt, nói về nó một cách cởi mở, và giúp người khác dễ dàng làm theo. Công việc bạn làm với vai trò người tiên phong có tác động lan tỏa vượt trội: mỗi ví dụ bạn chia sẻ rút ngắn đường cong học tập cho các kỹ sư đến sau, và mỗi câu hỏi bạn trả lời công khai biến trải nghiệm của một người thành thứ cả nhóm có thể tận dụng. Bạn đang đóng vai trò một bộ khuếch đại (multiplier) cho nhóm của mình, chứ không phải một quầy hỗ trợ (help desk), và hướng dẫn này được cấu trúc để giữ cho vai trò đó bền vững trên những điều khoản đó.

## Vai trò người tiên phong

Vai trò này bao gồm ba hành vi bổ trợ lẫn nhau.

| Hành vi                  | Trông như thế nào trong thực tế                                                                                                                                                            | Vì sao nó quan trọng                                                                                                                                                                    |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chia sẻ những gì bạn khám phá  | Đăng các prompt, ảnh chụp màn hình, và những thành công nhỏ từ chính công việc của bạn ở những nơi nhóm bạn vốn đã đọc, chẳng hạn một kênh kỹ thuật, một luồng standup, hoặc một mô tả pull request. | Các ví dụ rút ra từ chính codebase của bạn thuyết phục hơn bất kỳ tài liệu bên ngoài nào, vì đồng nghiệp có thể thấy chính xác công cụ áp dụng ra sao cho những vấn đề họ cùng chia sẻ với bạn. |
| Là người mà mọi người hỏi | Khi một đồng nghiệp hỏi bạn đã làm điều gì đó ra sao, hãy phản hồi bằng chính prompt bạn đã dùng để họ có thể áp dụng trực tiếp vào tác vụ của mình.                                       | Một ví dụ cụ thể, chạy được sẽ xóa bỏ khoảng cách giữa sự tò mò và lần dùng thành công đầu tiên, nơi hầu hết các nỗ lực áp dụng bị đình trệ.                                            |
| Mở rộng vòng tròn        | Thiết lập một số ít thói quen nhẹ nhàng, lặp lại, chẳng hạn một kênh riêng hoặc một luồng hằng tuần, để đà tiến tiếp tục ngay cả khi sự chú ý của bạn ở nơi khác.                          | Việc áp dụng phụ thuộc vào một cá nhân duy nhất là mong manh. Việc áp dụng được duy trì bởi các thói quen chung sẽ tự tiếp tục lan tỏa.                                                 |

Hầu hết những điều này nằm gọn một cách tự nhiên trong công việc bạn vốn đã làm. Điểm khác biệt là một chút chủ đích thêm về nơi bạn đăng những khám phá của mình và cách những câu trả lời của bạn lan truyền.

### Điều này nên tốn của bạn bao nhiêu

Hãy đặt kỳ vọng với chính mình và với người quản lý (lead) của bạn. Các hoạt động dưới đây nhằm gói gọn trong một tuần làm việc bình thường, và vai trò này nên tiếp tục là một bộ khuếch đại cho công việc hiện có của bạn chứ không phải một trách nhiệm hỗ trợ bổ sung.

| Hoạt động                               | Thời gian mỗi tuần | Hướng dẫn                                                                                                                        |
| --------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| Đăng các thành công và prompt           | Khoảng 15 phút     | Ghi lại chúng ngay tại chỗ bằng một ảnh chụp màn hình và một hai câu; tránh biến chúng thành các bài viết trang trọng.          |
| Trả lời câu hỏi trong một kênh chung     | Khoảng 20 phút     | Trả lời công khai một lần, sau đó liên kết lại tới câu trả lời đó khi câu hỏi tái diễn.                                         |
| Chủ trì một luồng show-and-tell hằng tuần | Khoảng 5 phút      | Bạn đăng prompt mở đầu; nhóm cung cấp nội dung.                                                                                 |
| Ghép cặp hoặc hướng dẫn tùy chọn         | 0 đến 30 phút      | Dành việc này cho những đồng nghiệp thực sự bị mắc kẹt, và hãy đưa liên kết [Bắt đầu nhanh](/en/quickstart) trước khi sắp xếp thời gian. |

## Chia sẻ những gì bạn khám phá

Trải nghiệm của chính bạn là tài liệu thuyết phục nhất mà đồng nghiệp của bạn sẽ gặp, vì nó cụ thể với codebase, quy trình làm việc và các vấn đề mà tất cả các bạn cùng chia sẻ. Tài liệu cho mọi người biết điều gì là khả thi; các bài đăng của bạn cho họ thấy điều gì đang thực sự hiệu quả trong môi trường của bạn.

### Điều gì đáng chia sẻ

Các bài đăng hữu ích nhất mô tả một kỹ thuật mà đồng nghiệp có thể tái sử dụng ngay ngày mai chứ không phải một kết quả đã hoàn tất. Kỹ thuật lan tỏa theo cấp số nhân khi chúng lan truyền trong một nhóm; các bản cập nhật trạng thái thì không.

Ví dụ về các kỹ thuật tái sử dụng được:

* "Tôi học được rằng việc @-mention một thư mục là được. Trỏ nó vào `@src/components/` và hỏi những thành phần nào còn thiếu test đã lộ ra hai cái mà tôi đã bỏ sót."
* "Chế độ Plan (`Shift+Tab`) cho thấy chính xác những tệp nào sẽ bị chạm vào trước khi có bất kỳ chỉnh sửa nào, đó là lý do tôi thoải mái dùng nó trên mã dùng chung."
* "Tôi đã cấu hình một Stop hook để nhận thông báo trên desktop khi một tác vụ dài hoàn tất. Cấu hình có trong luồng."
* "Chạy `/init` tạo ra một `CLAUDE.md` từ repository để trợ lý ngừng hỏi lại về các quy ước của chúng ta."

### Chia sẻ ở đâu

Đăng bất cứ nơi nào nhóm của bạn vốn đã đọc. Mục tiêu là đặt các ví dụ vào đường đi của công việc bình thường chứ không phải tạo ra một điểm đến.

| Vị trí                                          | Phù hợp nhất cho                                                            | Định dạng khuyến nghị                                                                          |
| ----------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Một kênh `#claude-code` hoặc kênh kỹ thuật chung | Các khám phá, prompt, và những khoảnh khắc "hôm nay tôi học được"           | Một ảnh chụp màn hình kèm một hai câu ngữ cảnh                                               |
| Mô tả pull request                              | Trình bày cách tiếp cận trên mã thật mà những người review vốn đã đang đọc   | Một dòng duy nhất như "Claude và tôi đã làm việc refactor này; sẵn lòng giải thích cách tiếp cận." |
| Standup hoặc bản cập nhật viết hằng tuần         | Bình thường hóa việc sử dụng với các lead và quản lý cấp trên              | Một câu mô tả một kết quả cụ thể                                                             |
| Wiki nhóm hoặc tài liệu nội bộ                   | Các mẫu bền vững, skill tùy chỉnh, và các ví dụ `CLAUDE.md`                | Một trang ngắn, được liên kết từ chủ đề (topic) của kênh để nó vẫn dễ tìm                    |

### Định dạng hiệu quả

Một ảnh chụp màn hình kèm một dòng ngữ cảnh, hoặc một mô tả trước-và-sau ngắn gọn, thường là mức độ chi tiết phù hợp. Hãy giữ mỗi bài đăng đủ ngắn để người lướt qua vẫn nắm được ý chính. Một bài viết dài thường bị lưu lại để đọc sau rồi bị quên, trong khi một bài đăng ngắn kèm ảnh chụp màn hình thường được sao chép và thử ngay.

Các bài đăng ví dụ dưới đây minh họa giọng điệu và độ dài; hãy điều chỉnh chúng thay vì sao chép nguyên văn.

```text theme={null}
Learned today that @-mentioning a directory works. I pointed it at
@src/components/ and asked which components were missing tests, and it
surfaced two I had forgotten about.
```

```text theme={null}
I configured a Stop hook so I receive a desktop notification when a long
task completes. I started a refactor, stepped away, and was notified when
it finished. Configuration is in the thread.
```

```text theme={null}
Plan mode is the reason I am comfortable using this on code that matters.
Press Shift+Tab until you see "plan"; it lays out exactly which files it
intends to touch before changing anything.
```

## Là người mà mọi người hỏi

Một khi bạn đã chia sẻ một vài ví dụ, các câu hỏi sẽ theo sau. Đây là nơi vai trò người tiên phong có đòn bẩy lớn nhất, vì một câu trả lời hay cho một người thường xuyên gỡ vướng cho vài người khác đang cùng theo dõi kênh đó.

### Trả lời bằng một prompt thay vì một lời giải thích

Khi một đồng nghiệp hỏi bạn đã làm điều gì đó ra sao, phản hồi hữu ích nhất là chính prompt bạn đã dùng. Họ sẽ học được nhiều hơn từ việc chạy prompt đó cho vấn đề của chính mình so với bất kỳ mô tả nào bạn có thể viết, và nó cho họ thứ có thể hành động ngay lập tức.

```text theme={null}
Colleague: How did you get it to find that race condition?

Champion: I asked, "The test in @tests/scheduler.test.ts is flaky, figure
out why," and it traced two unjoined promises in the scheduler. Try the
same phrasing on your test.
```

### Chỉ vào tính năng thay vì tài liệu

Một phản hồi như "Try plan mode, press `Shift+Tab` until you see it" hữu ích hơn ngay tại thời điểm đó so với một liên kết đến tài liệu. Nếu người đó cần chiều sâu hơn về sau, họ sẽ tự tìm; ngay lúc này họ cần đúng một thứ để gỡ vướng.

### Các câu hỏi bạn có thể sẽ nghe

| Câu hỏi                                            | Phản hồi gợi ý                                                                                                                                                                                                              | Tài nguyên bổ sung                                      |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| "Tôi nên thử nó trên cái gì trước?"                | Đề xuất một tác vụ thật nhưng gọn, lý tưởng là một lỗi hoặc việc vặt mà người đó đã trì hoãn vì nó tẻ nhạt chứ không phải vì khó.                                                                                            | [Các quy trình làm việc phổ biến](/en/common-workflows)                |
| "Làm sao tôi tin tưởng giao mã cho nó?"            | Giới thiệu chế độ plan: nhấn `Shift+Tab` để chuyển vào chế độ đó, Claude đề xuất chính xác những gì nó định thay đổi, và không có gì bị sửa đổi cho đến khi người dùng phê duyệt.                                            | [Quyền (Permissions)](/en/permissions)                          |
| "Việc thiết lập có đáng công không?"               | Cài đặt mất khoảng hai phút, chạy trong terminal, và không cần tiện ích mở rộng IDE. Chạy `/init` một lần là đủ để bắt đầu làm việc.                                                                                        | [Bắt đầu nhanh](/en/quickstart)                            |
| "Nó cho ra kết quả sai."                           | Khuyến khích họ đưa phần thất bại lại cho Claude. Dán thông báo lỗi hoặc bài test đang fail hiệu quả hơn nhiều so với việc diễn đạt lại yêu cầu ban đầu.                                                                     | [Các quy trình làm việc phổ biến](/en/common-workflows)                |
| "Nó không hiểu các quy ước codebase của chúng ta." | Đề xuất chạy `/init` để tạo một tệp `CLAUDE.md`, sau đó thêm các quy ước của nhóm, các lệnh test, và bất kỳ thư mục nào cần tránh.                                                                                          | [Memory](/en/memory)                                    |
| "Đây có phải chỉ là autocomplete?"                 | Trình diễn ngắn gọn trong đó Claude giải thích một tệp lạ, truy vết một lỗi xuyên qua các dịch vụ, hoặc soạn thảo một kế hoạch di trú. Các tác vụ này đòi hỏi suy luận xuyên suốt repository chứ không phải hoàn thành một dòng đơn lẻ. | Một buổi trình diễn trực tiếp hai phút                         |
| "Còn về bảo mật và xử lý dữ liệu thì sao?"         | Chuyển câu hỏi này đến quản trị viên của bạn. Chính sách triển khai và xử lý dữ liệu của tổ chức bạn đã được cấu hình sẵn, và người tiên phong không nên tự ứng biến câu trả lời này.                                       | [Bảo mật](/en/security) · [Sử dụng dữ liệu](/en/data-usage) |

## Mở rộng vòng tròn

Mục tiêu không phải là xây dựng một chương trình hay sở hữu một đợt triển khai. Đó là thiết lập một số ít thói quen nhẹ nhàng cho phép đà tiến tiếp tục sau khi bạn đã ngừng chủ động dẫn dắt. Khi các câu hỏi trong kênh được trả lời bởi những người khác ngoài bạn, vai trò này đã hoàn thành nhiệm vụ.

### Những mô hình thường hiệu quả

| Mô hình                                    | Cách vận hành                                                                                                                                                                                                                                    | Công sức yêu cầu                            |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| Một kênh riêng                             | Tạo một kênh `#claude-code` (hoặc một luồng lặp lại trong một kênh hiện có), ghim liên kết [Bắt đầu nhanh](/en/quickstart) và một ví dụ mạnh, và trả lời câu hỏi công khai để mỗi câu trả lời có lợi cho tất cả những người đang theo dõi.        | Khoảng năm phút để thiết lập, sau đó tự nhiên duy trì |
| Một luồng show-and-tell hằng tuần          | Mỗi thứ Sáu, đăng "Claude đã giúp bạn với việc gì tuần này?" Không cần chuẩn bị, slide, hay cuộc họp; ảnh chụp màn hình và mô tả ngắn là đủ.                                                                                                     | Khoảng hai phút mỗi tuần                    |
| Chia sẻ một skill tùy chỉnh                | Đăng tệp `.claude/skills/<name>/SKILL.md` hữu ích nhất của bạn, ví dụ một skill `/ship` chạy test và lint trước khi commit, kèm một mô tả một dòng. Vì skill là Markdown thuần, đồng nghiệp có thể áp dụng chúng ngay lập tức.                    | Khoảng năm phút mỗi skill                   |
| Tạo một hướng dẫn thiết lập từ chính cách dùng của bạn | Chạy `/team-onboarding` trong một dự án bạn đã dành thời gian thực sự. Claude quét các phiên, lệnh, và MCP server gần đây của bạn, rồi tạo ra một hướng dẫn mà một đồng đội mới có thể dán làm tin nhắn đầu tiên để tái hiện thiết lập của bạn. Ghim nó trong kênh. | Khoảng hai phút                     |
| Ghép cặp cho một tác vụ đầu tiên           | Đề nghị một buổi ghép cặp mười lăm phút cho bất kỳ ai đang bắt đầu. Một kết quả thành công trên chính mã của họ thuyết phục hơn bất kỳ bài thuyết trình nào.                                                                                     | Khoảng mười lăm phút mỗi người              |
| Xác định người tiên phong tiếp theo        | Đồng nghiệp hỏi bạn nhiều câu hỏi nhất thường đã sẵn sàng đảm nhận vai trò này. Chuyển tiếp cho họ trang này và chia sẻ trách nhiệm kênh giữa hai người.                                                                                        | Không đáng kể                              |

### Cẩm nang ba mươi ngày

Nếu một kế hoạch lỏng lẻo hữu ích, trình tự dưới đây phản ánh những gì thường hiệu quả với hầu hết các nhóm. Hãy điều chỉnh thoải mái cho phù hợp với bối cảnh của bạn.

<Steps>
  <Step title="Tuần 1: Gieo mầm cho kênh">
    Tạo kênh, ghim [Bắt đầu nhanh](/en/quickstart), và đăng hai hoặc ba ví dụ của chính bạn kèm các prompt.

    **Dấu hiệu cho thấy nó đang hiệu quả:** một vài đồng nghiệp phản ứng hoặc trả lời, và ít nhất một câu hỏi được đặt ra trong kênh.
  </Step>

  <Step title="Tuần 2: Bắt đầu nhịp điệu">
    Bắt đầu luồng show-and-tell hằng tuần, trả lời mọi câu hỏi công khai, và chia sẻ một skill tùy chỉnh hoặc một đoạn `CLAUDE.md`.

    **Dấu hiệu cho thấy nó đang hiệu quả:** một ai đó ngoài bạn đăng một ví dụ của riêng họ.
  </Step>

  <Step title="Tuần 3: Ghép cặp và củng cố">
    Đề nghị hai hoặc ba buổi ghép cặp ngắn và củng cố các câu hỏi và câu trả lời phổ biến nhất thành một tin nhắn FAQ được ghim.

    **Dấu hiệu cho thấy nó đang hiệu quả:** bạn thấy việc sử dụng lặp lại, với cùng những đồng nghiệp quay lại thay vì thử một lần rồi dừng.
  </Step>

  <Step title="Tuần 4: Bàn giao">
    Xác định một người tiên phong thứ hai và chia sẻ một bản tóm tắt ngắn gọn về những gì đang hiệu quả và không hiệu quả với lead hoặc quản trị viên của bạn.

    **Dấu hiệu cho thấy nó đang hiệu quả:** các câu hỏi trong kênh đang được trả lời bởi những người khác ngoài bạn.
  </Step>
</Steps>

### Khi ai đó muốn đi sâu hơn

Bạn là lời giới thiệu thân thiện chứ không phải chương trình onboarding. Khi một đồng nghiệp vượt qua "tôi có nên thử cái này không" để đến "làm sao tôi trở nên hiệu quả với nó," hãy chỉ họ đến các trang [Bắt đầu nhanh](/en/quickstart) và [Các quy trình làm việc phổ biến](/en/common-workflows). Chúng chứa các phần ngắn bao quát những tính năng thực sự hữu ích nhưng khó tự khám phá.

## Phản hồi các mối lo ngại phổ biến

Sự hoài nghi lành mạnh là điều được mong đợi; các kỹ sư nên thận trọng với những công cụ chạm vào mã của họ. Phản hồi hiệu quả nhất hiếm khi là tranh luận về trường hợp chung. Thay vào đó, hãy thừa nhận mối lo ngại, đưa ra một góc nhìn lại ngắn gọn, và đề xuất một buổi trình diễn cụ thể trên chính mã của người đó. Hầu hết các mối lo ngại được giải quyết bởi một trải nghiệm thành công duy nhất.

| Mối lo ngại                                    | Phản hồi gợi ý                                                                                                                                                                                    | Bằng chứng để đưa ra                                       |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| "Tôi nhanh hơn khi không có nó."              | Điều đó có lẽ đúng với mã mà người đó viết thường xuyên. Đề xuất thử nó trên công việc họ hay né tránh: các tệp cũ (legacy), các dịch vụ lạ, hoặc dàn khung test (test scaffolding), nơi đòn bẩy là cao nhất. | Đo thời gian một tác vụ tẻ nhạt theo cả hai cách và so sánh. |
| "Tôi không tin AI chạm vào mã production."     | Đồng ý rằng không thay đổi nào nên được đưa vào mà không được đọc. Chế độ plan kết hợp với việc review diff thông thường nghĩa là không có gì được áp dụng mà kỹ sư chưa kiểm tra, cùng tiêu chuẩn như bất kỳ pull request nào. | Trình diễn chế độ plan trên một tệp thật.                     |
| "Nó sẽ khiến các kỹ sư mới yếu đi."            | Nếu dùng tốt, nó là một công cụ giải thích hiệu quả. Khuyến khích các kỹ sư mới yêu cầu Claude giải thích một tệp và các nơi gọi nó trước khi yêu cầu nó thay đổi bất cứ điều gì.                 | Cùng chạy "Explain @file and where it is called from". |
| "Tôi đã thử một lần và nó bịa (hallucinate)."  | Đây thường là vấn đề về ngữ cảnh chứ không phải vấn đề về mô hình. @-mention các tệp liên quan, chạy `/init`, và cung cấp đầu ra lỗi thực tế thường giải quyết được.                             | Chạy lại prompt ban đầu của họ với ngữ cảnh `@` phù hợp.     |
| "Chúng tôi không có thời gian học thêm một công cụ nữa." | Claude Code là một lệnh terminal chứ không phải một nền tảng. Nếu nó không mang lại giá trị trong phiên đầu tiên, việc gác nó lại là hợp lý.                                            | Cài đặt hai phút, tiếp theo là một lỗi thật.            |

## Bảng tham chiếu nhanh

Các kỹ thuật dưới đây là những kỹ thuật đáng tin cậy nhất trong việc đưa một người từ lần thử đầu tiên đến việc dùng hằng ngày. Hãy ghim bảng này trong một kênh hoặc chia sẻ riêng nó.

| Kỹ thuật                         | Cách áp dụng                                                                                                                                                       |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cung cấp đúng ngữ cảnh           | Dùng các tham chiếu `@file` hoặc `@directory/`, hoặc dán trực tiếp đầu ra lỗi hay log. Cung cấp ngữ cảnh liên quan hiệu quả hơn việc viết prompt cầu kỳ.         |
| Review kế hoạch trước khi chỉnh sửa | Nhấn `Shift+Tab` để vào chế độ plan. Claude sẽ mô tả các thay đổi dự định để bạn phê duyệt trước khi thực thi.                                                 |
| Dạy nó về repository của bạn      | Chạy `/init` để tạo một tệp `CLAUDE.md`, sau đó thêm các quy ước, lệnh test, và bất kỳ thư mục nào không nên sửa đổi. Xem [Memory](/en/memory).                 |
| Tái sử dụng một quy trình làm việc | Lưu một tệp `SKILL.md` trong `.claude/skills/<name>/` để tạo một skill `/name` mà cả nhóm có thể dùng. Xem [Skill](/en/skills).                               |
| Luôn được cập nhật trong các tác vụ dài | Cấu hình một Stop hook để nhận thông báo trên desktop khi một tác vụ chạy lâu hoàn tất. Xem [Hook](/en/hooks-guide).                                       |
| Khôi phục từ một kết quả sai      | Thay vì diễn đạt lại yêu cầu, hãy dán bài test đang fail hoặc stack trace lại cho Claude và yêu cầu nó xử lý đúng thất bại đó.                                  |
| Giữ các chỉnh sửa gọn gàng        | Yêu cầu một diff, hoặc chỉ định "only change X." Claude tôn trọng phạm vi khi phạm vi được nêu rõ.                                                              |

<Tip>
  Claude Code được cập nhật thường xuyên. Hãy kiểm chứng các chi tiết theo phiên bản cụ thể so với [trang chủ tài liệu](/en/overview) trước khi phân phối tài liệu này trong nội bộ.
</Tip>
