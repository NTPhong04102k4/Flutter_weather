> Nguồn: https://code.claude.com/docs/en/fast-mode.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Tăng tốc phản hồi với fast mode

> Nhận phản hồi Opus nhanh hơn trong Claude Code bằng cách bật/tắt fast mode.

<Note>
  Fast mode đang trong [bản xem trước nghiên cứu (research preview)](#research-preview). Tính năng, giá cả, và tính khả dụng có thể thay đổi dựa trên phản hồi.
</Note>

Fast mode là một cấu hình tốc độ cao cho Claude Opus, làm cho mô hình nhanh hơn tới 2.5x với chi phí cao hơn trên mỗi token. Bật nó bằng `/fast` khi bạn cần tốc độ cho công việc tương tác như lặp lại nhanh (rapid iteration) hoặc gỡ lỗi trực tiếp (live debugging), và tắt nó đi khi chi phí quan trọng hơn độ trễ (latency).

Fast mode không phải là một mô hình khác. Nó dùng Claude Opus với một cấu hình API khác ưu tiên tốc độ hơn hiệu quả chi phí. Bạn nhận được chất lượng và khả năng y hệt với phản hồi nhanh hơn. Fast mode được hỗ trợ trên Opus 4.8 và Opus 4.7. Nó không có sẵn trên Sonnet, Haiku, hoặc các mô hình khác.

<Warning>
  Fast mode cho Opus 4.7 bị ngừng hỗ trợ (deprecated) kể từ ngày 25 tháng 6, 2026, và sẽ bị loại bỏ vào ngày 24 tháng 7, 2026. Sau khi loại bỏ, các yêu cầu fast mode trên Opus 4.7 trả về một lỗi và không quay về (fall back) Opus 4.7 tiêu chuẩn. Hãy chuyển sang Opus 4.8 để giữ tốc độ tăng.
</Warning>

<Note>
  Fast mode yêu cầu Claude Code v2.1.36 trở lên. Kiểm tra phiên bản của bạn bằng `claude --version`.
</Note>

Những điều cần biết:

* Dùng `/fast` để bật fast mode trong Claude Code CLI. Fast mode không được hỗ trợ trong tiện ích mở rộng VS Code.
* Giá fast mode trên mỗi MTok input/output là \$10/\$50 trên Opus 4.8 và \$30/\$150 trên Opus 4.7.
* Có sẵn cho mọi người dùng Claude Code trên các gói đăng ký (Pro/Max/Team/Enterprise) và Claude Console.
* Đối với người dùng Claude Code trên các gói đăng ký (Pro/Max/Team/Enterprise), fast mode có sẵn chỉ thông qua usage credits và không được bao gồm trong các giới hạn tốc độ (rate limit) của gói đăng ký.

## Bật/tắt fast mode

Bật/tắt fast mode theo một trong hai cách này:

* Gõ `/fast` và nhấn Tab để bật hoặc tắt
* Đặt `"fastMode": true` trong [file cài đặt người dùng](/en/settings) của bạn

Mặc định, fast mode giữ nguyên qua các phiên. Quản trị viên có thể cấu hình fast mode để reset lại mỗi phiên. Xem [yêu cầu tự chọn bật theo từng phiên](#require-per-session-opt-in) để biết chi tiết.

Để có hiệu quả chi phí tốt nhất, hãy bật fast mode ở đầu một phiên thay vì chuyển đổi giữa chừng cuộc trò chuyện. Xem [hiểu về đánh đổi chi phí](#understand-the-cost-tradeoff) để biết chi tiết.

Khi bạn bật fast mode:

* Nếu bạn đang ở một mô hình khác, Claude Code tự động chuyển sang Opus
* Bạn sẽ thấy một tin nhắn xác nhận: "Fast mode ON"
* Một icon `↯` nhỏ xuất hiện cạnh prompt khi fast mode đang hoạt động
* Chạy `/fast` lại bất cứ lúc nào để kiểm tra fast mode đang bật hay tắt

Khi bạn tắt fast mode bằng `/fast` lại, bạn vẫn ở Opus. Mô hình không quay về mô hình trước đó của bạn. Để chuyển sang một mô hình khác, dùng `/model`.

Opus 4.8 là mặc định của fast mode trong Claude Code v2.1.154 trở lên. Trên v2.1.142 đến v2.1.153, fast mode mặc định là Opus 4.7.

## Hiểu về đánh đổi chi phí

Fast mode có giá trên mỗi token cao hơn Opus tiêu chuẩn, với hệ số nhân thay đổi theo mô hình:

| Mô hình  | Input (MTok) | Output (MTok) |
| -------- | ------------ | ------------- |
| Opus 4.8 | \$10         | \$50          |
| Opus 4.7 | \$30         | \$150         |

Giá fast mode là cố định (flat) trên toàn bộ cửa sổ ngữ cảnh (context window) 1M token. Để biết mức giá Opus tiêu chuẩn để so sánh, xem [tài liệu tham chiếu giá Claude](https://platform.claude.com/docs/en/about-claude/pricing).

Lần đầu tiên bạn bật fast mode trong một cuộc trò chuyện, bạn trả giá input token chưa cache (uncached) đầy đủ của fast mode cho toàn bộ ngữ cảnh cuộc trò chuyện. Bạn càng đi sâu vào một cuộc trò chuyện, cái này càng tốn kém, nên việc bật fast mode ngay từ đầu rẻ hơn. Chi phí áp dụng một lần cho mỗi cuộc trò chuyện, nên việc tắt fast mode rồi bật lại sau đó không lặp lại nó. Để biết cơ chế, xem [cách fast mode tương tác với prompt cache](/en/prompt-caching#turning-on-fast-mode).

## Quyết định khi nào dùng fast mode

Fast mode tốt nhất cho công việc tương tác nơi độ trễ phản hồi quan trọng hơn chi phí:

* Lặp lại nhanh trên các thay đổi mã
* Các phiên gỡ lỗi trực tiếp
* Công việc nhạy thời gian với hạn chót gấp

Chế độ tiêu chuẩn tốt hơn cho:

* Các tác vụ tự động dài nơi tốc độ ít quan trọng hơn
* Xử lý theo lô (batch) hoặc các pipeline CI/CD
* Các khối lượng công việc nhạy chi phí

### Fast mode so với mức nỗ lực (effort level)

Fast mode và mức nỗ lực đều ảnh hưởng tới tốc độ phản hồi, nhưng theo cách khác nhau:

| Cài đặt                     | Ảnh hưởng                                                                        |
| --------------------------- | -------------------------------------------------------------------------------- |
| **Fast mode**               | Cùng chất lượng mô hình, độ trễ thấp hơn, chi phí cao hơn                          |
| **Mức nỗ lực thấp hơn**     | Ít thời gian suy nghĩ hơn, phản hồi nhanh hơn, có thể chất lượng thấp hơn ở các tác vụ phức tạp |

Bạn có thể kết hợp cả hai: dùng fast mode với một [mức nỗ lực](/en/model-config#adjust-effort-level) thấp hơn để có tốc độ tối đa trên các tác vụ đơn giản.

## Yêu cầu

Fast mode yêu cầu tất cả những điều sau:

* **Chỉ Anthropic API hoặc gói đăng ký**: fast mode có sẵn thông qua Anthropic Console API và cho các gói đăng ký Claude dùng usage credits. Nó không có sẵn trên Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, hoặc Claude Platform trên AWS.
* **Bật usage credits**: tài khoản của bạn phải được bật usage credits, cho phép thanh toán vượt quá mức sử dụng đã bao gồm trong gói của bạn. Đối với tài khoản cá nhân, bật điều này trong [cài đặt thanh toán Console](https://platform.claude.com/settings/organization/billing) của bạn. Đối với Team và Enterprise, một admin phải bật usage credits cho tổ chức.

<Note>
  Việc sử dụng fast mode rút trực tiếp từ usage credits, ngay cả khi bạn còn dư mức sử dụng trên gói của mình. Điều này có nghĩa là các token fast mode không tính vào mức sử dụng đã bao gồm trong gói của bạn và được tính phí theo mức giá fast mode từ token đầu tiên.
</Note>

* **Owner bật cho Team và Enterprise**: fast mode bị tắt mặc định cho các tổ chức Team và Enterprise. Một Owner phải [bật fast mode](#enable-fast-mode-for-your-organization) một cách rõ ràng trước khi người dùng có thể truy cập nó.

<Note>
  Nếu fast mode chưa được bật cho tổ chức của bạn, lệnh `/fast` sẽ hiển thị "Fast mode has been disabled by your organization." Nếu danh sách cho phép [`availableModels`](/en/model-config#restrict-model-selection) của tổ chức bạn loại trừ mô hình Opus dùng cho fast mode, `/fast` bị từ chối với "is not in your organization's allowed models". Ngoại lệ là một phiên đã chạy trên một mô hình Opus được phép và hỗ trợ fast mode: `/fast` bật fast mode trên mô hình hiện tại của bạn thay vì chuyển đổi mô hình.
</Note>

### Bật fast mode cho tổ chức của bạn

Nơi bạn bật fast mode phụ thuộc vào sản phẩm nào tổ chức của bạn dùng:

* **Console** (khách hàng API): một admin bật nó trong [tùy chọn Claude Code](https://platform.claude.com/claude-code/preferences)
* **Claude AI** (Team và Enterprise): một Owner bật nó tại [Admin Settings > Claude Code](https://claude.ai/admin-settings/claude-code)

Một tùy chọn khác để tắt fast mode hoàn toàn là đặt `CLAUDE_CODE_DISABLE_FAST_MODE=1`. Xem [Biến môi trường](/en/env-vars).

### Yêu cầu tự chọn bật theo từng phiên

Mặc định, fast mode giữ nguyên qua các phiên: nếu một người dùng bật fast mode, nó vẫn bật trong các phiên tương lai. Quản trị viên trên các gói [Team](https://claude.com/pricing?utm_source=claude_code\&utm_medium=docs\&utm_content=fast_mode_teams#team-&-enterprise) hoặc [Enterprise](https://anthropic.com/contact-sales?utm_source=claude_code\&utm_medium=docs\&utm_content=fast_mode_enterprise) có thể ngăn điều này bằng cách đặt `fastModePerSessionOptIn` thành `true` trong [managed settings](/en/settings#settings-files) hoặc [server-managed settings](/en/server-managed-settings). Điều này khiến mỗi phiên bắt đầu với fast mode tắt, yêu cầu người dùng bật nó một cách rõ ràng bằng `/fast`.

```json theme={null}
{
  "fastModePerSessionOptIn": true
}
```

Điều này hữu ích để kiểm soát chi phí trong các tổ chức nơi người dùng chạy nhiều phiên đồng thời. Người dùng vẫn có thể bật fast mode bằng `/fast` khi họ cần tốc độ, nhưng nó reset lại ở đầu mỗi phiên mới. Tùy chọn fast mode của người dùng vẫn được lưu, nên việc gỡ bỏ cài đặt này khôi phục hành vi giữ nguyên mặc định.

## Xử lý giới hạn tốc độ (rate limit)

Fast mode có các giới hạn tốc độ riêng biệt so với Opus tiêu chuẩn. Fast mode trên Opus 4.8 và Opus 4.7 chia sẻ cùng một hồ (pool) giới hạn tốc độ: việc sử dụng trên một trong hai đều rút từ cùng các giới hạn. Khi bạn chạm giới hạn tốc độ của fast mode hoặc hết usage credits:

1. Fast mode tự động quay về tốc độ tiêu chuẩn
2. Icon `↯` chuyển sang màu xám để cho thấy đang trong thời gian nghỉ (cooldown)
3. Bạn tiếp tục làm việc ở tốc độ và giá tiêu chuẩn
4. Khi thời gian nghỉ hết, fast mode tự động bật lại

Để tắt fast mode thủ công thay vì chờ thời gian nghỉ, chạy `/fast` lại.

## Bản xem trước nghiên cứu (Research preview)

Fast mode là một tính năng bản xem trước nghiên cứu. Điều này có nghĩa là:

* Tính năng có thể thay đổi dựa trên phản hồi
* Tính khả dụng và giá cả có thể thay đổi
* Cấu hình API nền tảng có thể tiến hóa

Báo cáo vấn đề hoặc phản hồi qua các kênh hỗ trợ Anthropic thông thường của bạn.

## Xem thêm

* [Cấu hình mô hình](/en/model-config): chuyển đổi mô hình và điều chỉnh mức nỗ lực
* [Quản lý chi phí hiệu quả](/en/costs): theo dõi mức sử dụng token và giảm chi phí
* [Cấu hình status line](/en/statusline): hiển thị thông tin mô hình và ngữ cảnh
