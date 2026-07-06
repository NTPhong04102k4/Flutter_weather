> Nguồn: https://code.claude.com/docs/en/debug-your-config.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Gỡ lỗi cấu hình của bạn

> Chẩn đoán tại sao CLAUDE.md, settings, hook, MCP server hoặc skill không có hiệu lực. Dùng /context, /doctor, /hooks và /mcp để xem những gì thực sự đã được nạp.

Khi Claude bỏ qua một chỉ dẫn hoặc một tính năng bạn đã cấu hình không xuất hiện, nguyên nhân thường là file không được nạp, nó được nạp từ một vị trí khác với vị trí bạn mong đợi, hoặc một file khác đã ghi đè nó. Hướng dẫn này chỉ cho bạn cách kiểm tra những gì Claude Code thực sự đã nạp để bạn có thể thu hẹp xem trường hợp nào đang xảy ra.

Đối với các vấn đề về cài đặt, xác thực và kết nối, hãy xem [Khắc phục sự cố cài đặt và đăng nhập](/en/troubleshoot-install) thay vì trang này.

## Xem những gì đã được nạp vào context

Lệnh `/context` hiển thị mọi thứ đang chiếm dụng context window (cửa sổ ngữ cảnh) của phiên hiện tại, được phân chia theo từng danh mục: system prompt, các file bộ nhớ, skill, các subagent tùy chỉnh kèm nguồn mà mỗi cái được nạp từ đó, MCP tool, và các tin nhắn hội thoại. Hãy chạy nó đầu tiên để xác nhận xem `CLAUDE.md`, các rule, hoặc mô tả skill của bạn có hiện diện hay không.

Để xem chi tiết một danh mục cụ thể, hãy dùng tiếp lệnh chuyên biệt tương ứng:

| Lệnh             | Hiển thị                                                                                                                                                                                                                                    |
| :--------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/memory`        | Các file `CLAUDE.md` và file rule nào đã được nạp, cộng với các mục auto-memory                                                                                                                                                            |
| `/skills`        | Các skill khả dụng từ nguồn project, user và plugin                                                                                                                                                                                        |
| `/hooks`         | Các cấu hình hook đang hoạt động                                                                                                                                                                                                          |
| `/mcp`           | Các MCP server đã kết nối và trạng thái của chúng                                                                                                                                                                                          |
| `/permissions`   | Các quy tắc allow và deny đã được phân giải và đang có hiệu lực                                                                                                                                                                            |
| `/doctor`        | Chẩn đoán cấu hình: các key không hợp lệ, lỗi schema, tình trạng cài đặt. {/* min-version: 2.1.196 */}Kể từ v2.1.196, cũng báo cáo các tên [subagent](/en/sub-agents) trùng lặp được định nghĩa trong cùng một phạm vi và đánh dấu cái nào đang hoạt động |
| `/debug [issue]` | Bật ghi log gỡ lỗi cho phiên và yêu cầu Claude chẩn đoán bằng cách dùng đầu ra log và các đường dẫn settings                                                                                                                             |
| `/status`        | Các nguồn settings đang hoạt động, bao gồm cả việc managed settings có đang có hiệu lực hay không                                                                                                                                        |

Nếu một file bộ nhớ bị thiếu trong `/memory`, hãy kiểm tra vị trí của nó so với [cách các file CLAUDE.md được nạp](/en/memory#how-claude-md-files-load). Các file `CLAUDE.md` ở thư mục con được nạp theo yêu cầu khi Claude đọc một file trong thư mục đó bằng công cụ Read, chứ không phải lúc bắt đầu phiên.

Nếu `/memory` xác nhận file đã được nạp nhưng Claude vẫn không tuân theo một chỉ dẫn cụ thể, thì vấn đề nhiều khả năng nằm ở cách viết chỉ dẫn chứ không phải việc nó có được nạp hay không. CLAUDE.md hoạt động tốt cho những loại hướng dẫn mà bạn sẽ đưa cho một đồng đội mới, chẳng hạn như quy ước của dự án, lệnh build, và nơi các file nên đặt.

Mức độ tuân thủ giảm khi một chỉ dẫn mơ hồ đến mức có thể diễn giải theo nhiều cách khác nhau, khi hai file đưa ra hướng dẫn xung đột nhau, hoặc khi file đã dài đến mức từng quy tắc riêng lẻ được chú ý ít hơn. [Viết chỉ dẫn hiệu quả](/en/memory#write-effective-instructions) trình bày các mô hình về tính cụ thể, kích thước và cấu trúc giúp giữ mức độ tuân thủ cao.

<Note>
  CLAUDE.md và permissions giải quyết những vấn đề khác nhau. CLAUDE.md cho Claude biết dự án của bạn hoạt động thế nào để nó ra quyết định tốt. [Permissions](/en/permissions) và [hook](/en/hooks) áp đặt giới hạn bất kể Claude quyết định thế nào. Dùng CLAUDE.md cho "chúng tôi làm theo cách này ở đây". Dùng permissions hoặc hook cho các ranh giới bảo mật và bất cứ điều gì tuyệt đối không được xảy ra, nơi bạn cần một sự đảm bảo thay vì hướng dẫn.
</Note>

## Kiểm tra settings đã được phân giải

Settings được hợp nhất qua các phạm vi managed, user, project và local. Managed settings luôn thắng khi có mặt. Trong số các phạm vi còn lại, phạm vi gần hơn ghi đè phạm vi rộng hơn theo thứ tự local, rồi project, rồi user. Một số settings cũng có thể được thiết lập bằng các flag dòng lệnh hoặc [biến môi trường](/en/env-vars), đóng vai trò như một lớp ghi đè khác. Khi một setting dường như không có hiệu lực, giá trị bạn đặt thường đang bị ghi đè bởi một phạm vi khác hoặc một biến môi trường.

Chạy `/doctor` để kiểm tra tính hợp lệ của các file cấu hình và làm nổi bật các key không hợp lệ hoặc lỗi schema. Khi `/doctor` báo cáo vấn đề, nhấn `f` để gửi báo cáo chẩn đoán cho Claude và để nó cùng bạn đi qua các bước sửa lỗi.

Chạy `/status` để xem những nguồn settings nào đang hoạt động, bao gồm cả việc managed settings có đang có hiệu lực hay không. Để hiểu phạm vi nào thắng cho một key nhất định, hãy xem [Cách các phạm vi tương tác](/en/settings#how-scopes-interact).

## Kiểm tra MCP server

Chạy `/mcp` để xem mọi server đã cấu hình, trạng thái kết nối của nó, và liệu bạn đã phê duyệt nó cho dự án hiện tại hay chưa. Một server có thể được định nghĩa đúng nhưng vẫn không cung cấp tool vì một vài lý do phổ biến:

* Các server phạm vi project trong `.mcp.json` yêu cầu một lần phê duyệt duy nhất. Nếu lời nhắc đã bị bỏ qua, server sẽ vẫn bị vô hiệu hóa cho đến khi bạn phê duyệt nó từ `/mcp`.
* Một server khởi động thất bại sẽ hiển thị là failed trong `/mcp`. Đường dẫn file tương đối trong `command` hoặc `args` là một nguyên nhân thường gặp, vì chúng được phân giải tương đối với thư mục nơi bạn khởi chạy Claude Code chứ không phải vị trí của `.mcp.json`.
* Một server hiển thị là connected nhưng liệt kê zero tool nghĩa là nó đã khởi động thành công nhưng không trả về danh sách tool. Chọn **Reconnect** từ `/mcp`. Nếu số lượng vẫn ở mức zero, hãy chạy `claude --debug mcp` để xem đầu ra stderr của server.

Để biết các vị trí cấu hình và quy tắc phạm vi, hãy xem [MCP](/en/mcp).

## Kiểm tra hook

Chạy `/hooks` để liệt kê mọi hook đã được đăng ký cho phiên hiện tại, được nhóm theo sự kiện. Nếu một hook bạn đã định nghĩa không xuất hiện, nghĩa là nó không được đọc: hook nằm dưới key `"hooks"` trong một file settings, chứ không phải trong một file độc lập.

Nếu hook xuất hiện nhưng không kích hoạt, matcher thường là nguyên nhân. Trường `matcher` là một chuỗi đơn dùng `|` để khớp nhiều tên tool, ví dụ `"Edit|Write"`. {/* min-version: 2.1.191 */}Trên Claude Code v2.1.191 trở lên, `,` cũng hoạt động như một dấu phân tách, nên `"Edit,Write"` là tương đương. Trên các phiên bản cũ hơn, một dấu phẩy sẽ rơi vào đánh giá regex và matcher sẽ không bao giờ khớp, vì vậy hãy dùng `|` nếu bạn chưa dùng v2.1.191. Một tên tool viết sai chính tả sẽ thất bại âm thầm vì lý do tương tự. Một giá trị dạng array là lỗi schema: Claude Code hiển thị thông báo lỗi settings, `/doctor` báo cáo lỗi kiểm tra hợp lệ, và mục hook bị loại bỏ nên nó sẽ không xuất hiện trong `/hooks`.

Các chỉnh sửa `settings.json` có hiệu lực trong phiên đang chạy sau một khoảng trễ ngắn để file ổn định. Bạn không cần khởi động lại. Nếu `/hooks` vẫn hiển thị định nghĩa cũ sau vài giây kể từ khi lưu, hãy chạy `/hooks` lại để làm mới hiển thị.

Nếu `/hooks` hiển thị hook nhưng nó vẫn không kích hoạt, bước tiếp theo là quan sát trực tiếp quá trình đánh giá hook. Khởi động một phiên với `claude --debug hooks` và kích hoạt lệnh gọi tool. Log gỡ lỗi ghi lại mỗi sự kiện, các matcher nào đã được kiểm tra, và mã thoát cùng đầu ra của hook. Xem [Gỡ lỗi hook](/en/hooks#debug-hooks) để biết định dạng log và [khắc phục sự cố hook](/en/hooks-guide#limitations-and-troubleshooting) để biết các mô hình lỗi phổ biến.

## Kiểm thử với một cấu hình sạch

{/* min-version: 2.1.169 */}Hãy bắt đầu với [`claude --safe-mode`](/en/cli-reference#cli-flags), lệnh này khởi chạy một phiên với tất cả tùy chỉnh bị vô hiệu hóa, bao gồm `CLAUDE.md`, skill, plugin, hook, MCP server, và các lệnh cùng agent tùy chỉnh. Xác thực, chọn model, các built-in tool, và permissions vẫn hoạt động bình thường. Nếu vấn đề biến mất trong safe mode, thì một trong các bề mặt đó là nguyên nhân; hãy dùng các kiểm tra có mục tiêu ở trên để tìm ra cái nào. Safe mode vẫn áp dụng các managed hook và chính sách settings từ tổ chức của bạn. Các plugin, skill, CLAUDE.md và MCP server được quản lý (managed) sẽ bị tắt.

Nếu vấn đề vẫn tồn tại trong safe mode, hoặc chính settings của bạn đang bị nghi ngờ, hãy so sánh với một phiên không nạp bất cứ thứ gì từ thiết lập thông thường của bạn. Trỏ [`CLAUDE_CONFIG_DIR`](/en/env-vars) đến một thư mục rỗng để bỏ qua mọi thứ dưới `~/.claude`, và khởi chạy từ một thư mục không có thư mục `.claude`, file `.mcp.json`, hoặc `CLAUDE.md` để cấu hình project cũng được bỏ qua.

```bash theme={null}
cd /tmp && CLAUDE_CONFIG_DIR=/tmp/claude-clean claude
```

Phiên sạch không có settings, hook, MCP server, plugin, hoặc bộ nhớ của user hay project.

* Managed settings vẫn áp dụng nếu tổ chức của bạn triển khai chúng, vì chúng nằm ở một đường dẫn hệ thống bên ngoài `~/.claude`
* Trên Linux và Windows, bạn sẽ được nhắc đăng nhập lại vì thông tin đăng nhập được lưu trữ dưới thư mục cấu hình
* Trên macOS, thông tin đăng nhập nằm trong Keychain và được mang theo sang phiên sạch

Nếu vấn đề biến mất ở đây, nguyên nhân nằm ở đâu đó trong các file `~/.claude` thực sự của bạn hoặc trong file `.claude` của project. Hãy đưa chúng trở lại từng cái một, bằng cách sao chép file vào thư mục tạm hoặc bằng cách khởi chạy từ project của bạn, để tìm ra cái nào. Nếu vấn đề vẫn tồn tại trong phiên sạch, nguyên nhân nằm ngoài cấu hình user và project của bạn. Chạy `/status` để kiểm tra xem managed settings có đang có hiệu lực không, tìm các [biến môi trường](/en/env-vars) có ảnh hưởng đến Claude Code, rồi xem [Khắc phục sự cố](/en/troubleshooting).

## Kiểm tra các nguyên nhân phổ biến

Hầu hết các bất ngờ về cấu hình đều bắt nguồn từ một tập hợp nhỏ các quy tắc về vị trí và cú pháp. Hãy kiểm tra những điều này trước khi cho rằng đó là một lỗi:

| Triệu chứng                                                          | Nguyên nhân                                                                                                                | Cách khắc phục                                                                                                                                                                                                                                                          |
| :------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hook không bao giờ kích hoạt                                         | `matcher` là một mảng JSON thay vì một chuỗi                                                                              | Dùng một chuỗi đơn với `\|` để khớp nhiều tool, ví dụ `"Edit\|Write"`. Xem [mô hình matcher](/en/hooks#matcher-patterns).                                                                                                                      |
| Hook không bao giờ kích hoạt                                         | `matcher` dùng `,` làm dấu phân tách trên phiên bản trước v2.1.191                                                        | {/* min-version: 2.1.191 */}Claude Code v2.1.191 trở lên xử lý `,` như một dấu phân tách danh sách giống `\|`. Các phiên bản cũ hơn đánh giá dấu phẩy như một ký tự nghĩa đen, nên `"Edit,Write"` không khớp gì cả. Hãy dùng `\|` thay thế, hoặc nâng cấp Claude Code.                   |
| Hook không bao giờ kích hoạt                                         | Giá trị `matcher` viết thường, ví dụ `"bash"`                                                                             | Việc khớp phân biệt chữ hoa chữ thường. Tên tool viết hoa chữ đầu: `Bash`, `Edit`, `Write`, `Read`.                                                                                                                                                                     |
| Hook không bao giờ kích hoạt                                         | Hook được định nghĩa trong một file độc lập thay vì `settings.json`                                                       | Không có file hook độc lập cho cấu hình project hoặc user. Định nghĩa hook dưới key `"hooks"` trong `settings.json`. Chỉ [plugin](/en/plugins-reference#hooks) mới nạp một file `hooks/hooks.json` riêng. Xem [cấu hình hook](/en/hooks).                  |
| Permissions, hook, hoặc env đặt toàn cục bị bỏ qua                   | Cấu hình được thêm vào `~/.claude.json`                                                                                   | `~/.claude.json` chứa trạng thái ứng dụng và các công tắc UI. `permissions`, `hooks`, và `env` thuộc về `~/.claude/settings.json`. Đây là hai file khác nhau.                                                                                                       |
| Một giá trị trong `settings.json` dường như bị bỏ qua               | Cùng key đó được đặt trong `settings.local.json`                                                                          | `settings.local.json` ghi đè `settings.json`, và cả hai đều ghi đè `~/.claude/settings.json`. Xem [thứ tự ưu tiên settings](/en/settings#how-scopes-interact).                                                                                                   |
| Skill không xuất hiện trong `/skills`                                | File skill nằm ở `.claude/skills/name.md` thay vì trong một thư mục                                                       | Dùng một thư mục với `SKILL.md` bên trong: `.claude/skills/name/SKILL.md`.                                                                                                                                                                                         |
| Skill xuất hiện trong `/skills` nhưng Claude không bao giờ gọi nó   | Skill có `disable-model-invocation: true` trong frontmatter của nó, hoặc mô tả của nó không khớp với cách bạn diễn đạt yêu cầu | Kiểm tra nhãn (badge) trong `/skills`: nhãn "user-only" nghĩa là Claude sẽ không tự kích hoạt nó. Xem [gọi skill](/en/skills).                                                                                                                              |
| Chỉ dẫn của `CLAUDE.md` ở thư mục con dường như bị bỏ qua           | Các file ở thư mục con được nạp theo yêu cầu, không phải lúc bắt đầu phiên                                                | Chúng được nạp khi Claude đọc một file trong thư mục đó bằng công cụ Read, không phải lúc khởi chạy và không phải khi ghi hay tạo file ở đó. Xem [cách các file CLAUDE.md được nạp](/en/memory#how-claude-md-files-load).                                    |
| Subagent bỏ qua các chỉ dẫn của `CLAUDE.md`                          | Các agent built-in Explore và Plan bỏ qua `CLAUDE.md`. Các subagent tùy chỉnh nạp nó theo cách giống hội thoại chính     | Với Explore hoặc Plan, hãy nêu lại chỉ dẫn trong prompt ủy thác của bạn. Với một subagent tùy chỉnh, hãy đặt các chỉ dẫn quan trọng vào phần thân file agent, phần này trở thành system prompt của agent. Xem [những gì được nạp lúc khởi động](/en/sub-agents#what-loads-at-startup). |
| Logic dọn dẹp không bao giờ chạy khi kết thúc phiên                 | Không có hook `SessionEnd` được cấu hình                                                                                  | Thêm một hook `SessionEnd` trong `settings.json`. Xem [danh sách sự kiện hook](/en/hooks#hook-events).                                                                                                                                                             |
| Các MCP server trong `.mcp.json` không bao giờ được nạp             | File nằm dưới `.claude/` hoặc dùng định dạng cấu hình của Claude Desktop                                                  | Cấu hình MCP của project đặt ở gốc kho lưu trữ với tên `.mcp.json`, không phải bên trong `.claude/`. Xem [cấu hình MCP](/en/mcp).                                                                                                                               |
| Các MCP server được thêm dưới `mcpServers` trong `settings.json` không bao giờ xuất hiện | `settings.json` không đọc key `mcpServers`                                                            | Định nghĩa các server của project trong `.mcp.json` ở gốc kho lưu trữ, hoặc chạy `claude mcp add --scope user` cho các server phạm vi user. Xem [cấu hình MCP](/en/mcp).                                                                                        |
| MCP server của project đã được thêm nhưng không xuất hiện          | Lời nhắc phê duyệt một lần đã bị bỏ qua                                                                                   | Các server phạm vi project yêu cầu phê duyệt. Chạy `/mcp` để xem trạng thái và phê duyệt.                                                                                                                                                                          |
| MCP server khởi động thất bại từ một số thư mục                     | `command` hoặc `args` dùng một đường dẫn file tương đối                                                                   | Dùng đường dẫn tuyệt đối cho các script cục bộ. Các file thực thi trên `PATH` của bạn như `npx` hoặc `uvx` hoạt động như bình thường.                                                                                                                             |
| MCP server khởi động mà không có các biến môi trường mong đợi       | Các biến nằm trong `env` của `settings.json`, thứ không lan truyền đến các tiến trình con của MCP                          | Đặt `env` cho từng server bên trong `.mcp.json` thay vào đó.                                                                                                                                                                                                       |
| Quy tắc deny `Bash(rm *)` không chặn `/bin/rm` hoặc `find -delete`  | Các quy tắc theo tiền tố khớp với chuỗi lệnh nghĩa đen, không phải file thực thi bên dưới                                | Thêm các mô hình rõ ràng cho từng biến thể, hoặc dùng một [PreToolUse hook](/en/hooks-guide) hoặc [sandbox](/en/sandboxing) để có sự đảm bảo chắc chắn.                                                                                                          |

## Tài nguyên liên quan

Để có tài liệu tham khảo đầy đủ về từng bề mặt cấu hình, hãy xem trang chuyên biệt:

* **[Tài liệu tham khảo thư mục `.claude`](/en/claude-directory)**: mọi vị trí file cấu hình và cái gì đọc nó
* **[Settings](/en/settings)**: thứ tự ưu tiên và danh sách key đầy đủ
* **[Tài liệu tham khảo hook](/en/hooks)**: tên sự kiện, payload, và định dạng đầu ra `--debug hooks`
* **[MCP](/en/mcp)**: cấu hình server, phê duyệt, và đầu ra `/mcp`
* **[Khắc phục sự cố cài đặt và đăng nhập](/en/troubleshoot-install)**: các vấn đề `command not found`, PATH, và xác thực
* **[Khắc phục sự cố](/en/troubleshooting)**: các vấn đề về hiệu năng, treo, và tìm kiếm
