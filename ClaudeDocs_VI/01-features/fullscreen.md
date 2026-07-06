> Nguồn: https://code.claude.com/docs/en/fullscreen.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Kết xuất toàn màn hình (Fullscreen rendering)

> Bật một chế độ kết xuất mượt mà hơn, không nhấp nháy với hỗ trợ chuột và mức sử dụng bộ nhớ ổn định trong các cuộc hội thoại dài.

<Note>
  Fullscreen rendering là một tính năng [research preview](#research-preview) (bản xem trước nghiên cứu) dạng tự chọn tham gia và yêu cầu Claude Code v2.1.89 trở lên. Chạy `/tui fullscreen` để chuyển sang chế độ này trong cuộc hội thoại hiện tại của bạn, hoặc đặt `CLAUDE_CODE_NO_FLICKER=1` trên các phiên bản trước v2.1.110. Hành vi có thể thay đổi dựa trên phản hồi.
</Note>

Fullscreen rendering là một đường kết xuất thay thế cho CLI của Claude Code, loại bỏ hiện tượng nhấp nháy, giữ mức sử dụng bộ nhớ ổn định trong các cuộc hội thoại dài, và bổ sung hỗ trợ chuột. Nó vẽ giao diện trên bộ đệm màn hình phụ (alternate screen buffer) của terminal, giống như `vim` hoặc `htop`, và chỉ kết xuất những thông báo hiện đang hiển thị. Điều này giảm lượng dữ liệu gửi đến terminal của bạn trong mỗi lần cập nhật.

Sự khác biệt dễ nhận thấy nhất trong các trình giả lập terminal nơi thông lượng kết xuất là nút thắt cổ chai, chẳng hạn như terminal tích hợp của VS Code, tmux, và iTerm2. Nếu vị trí cuộn terminal của bạn nhảy lên đầu trong khi Claude đang làm việc, hoặc màn hình nhấp nháy khi đầu ra công cụ được truyền vào, chế độ này giải quyết những vấn đề đó.

<Note>
  Thuật ngữ fullscreen (toàn màn hình) mô tả cách Claude Code chiếm lấy bề mặt vẽ của terminal, theo cách mà `vim` làm. Nó không liên quan gì đến việc phóng to cửa sổ terminal của bạn, và hoạt động ở bất kỳ kích thước cửa sổ nào.
</Note>

## Bật fullscreen rendering

Chạy `/tui fullscreen` bên trong bất kỳ cuộc hội thoại Claude Code nào. CLI lưu [cài đặt `tui`](/en/settings#available-settings) và khởi chạy lại ở chế độ fullscreen với cuộc hội thoại của bạn được giữ nguyên vẹn, vì vậy bạn có thể chuyển đổi giữa phiên mà không mất context. Chạy `/tui default` để chuyển về trình kết xuất cổ điển, hoặc `/tui` không có đối số để in ra trình kết xuất nào đang hoạt động.

Bạn cũng có thể đặt biến môi trường `CLAUDE_CODE_NO_FLICKER` trước khi khởi động Claude Code:

```bash theme={null}
CLAUDE_CODE_NO_FLICKER=1 claude
```

Cài đặt `tui` và biến môi trường là tương đương nhau. Lệnh `/tui` xóa `CLAUDE_CODE_NO_FLICKER` khỏi tiến trình được khởi chạy lại để cài đặt mà nó ghi có hiệu lực.

## Những gì thay đổi

Fullscreen rendering thay đổi cách CLI vẽ lên terminal của bạn. Ô nhập liệu (input box) được cố định ở dưới cùng màn hình thay vì di chuyển khi đầu ra được truyền vào. Nếu ô nhập liệu không di chuyển trong khi Claude đang làm việc, thì fullscreen rendering đang hoạt động. Chỉ những thông báo hiển thị được giữ trong cây kết xuất, vì vậy bộ nhớ ổn định bất kể độ dài cuộc hội thoại.

Vì cuộc hội thoại nằm trong bộ đệm màn hình phụ thay vì trong scrollback của terminal, một vài thứ hoạt động khác đi:

| Trước đây                                            | Bây giờ                                                                         | Chi tiết                                                                   |
| :-------------------------------------------------- | :----------------------------------------------------------------------------- | :------------------------------------------------------------------------ |
| `Cmd+f` hoặc tìm kiếm tmux để tìm văn bản           | `Ctrl+o` để vào chế độ transcript, sau đó `/` để tìm kiếm hoặc `[` để ghi vào scrollback | [Tìm kiếm và xem lại cuộc hội thoại](#search-and-review-the-conversation) |
| Nhấp-và-kéo native của terminal để chọn và sao chép | Chọn trong ứng dụng, tự động sao chép khi thả chuột                             | [Sử dụng chuột](#use-the-mouse)                                           |
| `Cmd`-nhấp để mở một URL                            | `Cmd`-nhấp trên macOS, `Ctrl`-nhấp ở nơi khác                                   | [Sử dụng chuột](#use-the-mouse)                                           |

Nếu việc bắt sự kiện chuột cản trở quy trình làm việc của bạn, bạn có thể [tắt nó đi](#keep-native-text-selection) trong khi vẫn giữ được kết xuất không nhấp nháy.

## Sử dụng chuột

Fullscreen rendering bắt các sự kiện chuột và xử lý chúng bên trong Claude Code:

* **Nhấp vào ô nhập prompt** để đặt con trỏ ở bất kỳ đâu trong văn bản bạn đang gõ.
* **Nhấp vào một gợi ý trong danh sách lệnh `/` hoặc danh sách tệp `@`** để chấp nhận nó. Di chuột qua sẽ làm nổi bật hàng dưới con trỏ của bạn.
* **Nhấp vào một tùy chọn trong menu chọn (select menu)** để chọn nó. Điều này áp dụng cho các lời nhắc xin quyền, `/model`, `/config`, và các hộp thoại khác hiển thị một danh sách tùy chọn. Di chuột qua sẽ hiện một con trỏ trên hàng dưới con trỏ của bạn. {/* min-version: 2.1.187 */}Yêu cầu Claude Code v2.1.187 trở lên.
* **Nhấp vào một kết quả công cụ đã thu gọn** để mở rộng nó và xem đầu ra đầy đủ. Nhấp lại để thu gọn. Lệnh gọi công cụ và kết quả của nó mở rộng cùng nhau. Chỉ những thông báo còn nội dung để hiển thị mới có thể nhấp được.
* **Giữ `Cmd` trên macOS, hoặc `Ctrl` trên Linux và Windows, rồi nhấp vào một URL hoặc đường dẫn tệp** để mở nó. Các đường dẫn tệp trong đầu ra công cụ, như những đường dẫn được in ra sau một lệnh Edit hoặc Write, mở trong ứng dụng mặc định của bạn. Các URL `http://` và `https://` thông thường mở trong trình duyệt của bạn. {/* min-version: 2.1.181 */}Kể từ v2.1.181, một cú nhấp thông thường mà không giữ `Cmd` hoặc `Ctrl` sẽ không còn mở liên kết nữa, khớp với hành vi terminal native. Một số terminal macOS chuyển tiếp `Cmd`+nhấp đến ứng dụng đang chạy thay vì tự mở liên kết, và giao thức chuột terminal không có cách nào mã hóa phím `Cmd`, vì vậy Claude Code nhận nó như một cú nhấp thông thường. Trong Ghostty, và {/* min-version: 2.1.198 */}kể từ v2.1.198 trong Warp trên macOS, Claude Code phát hiện điều này và cho phép một cú nhấp thông thường vào liên kết mở được liên kết, và giữ `Cmd` vẫn hoạt động. Trong terminal tích hợp của VS Code và các terminal tương tự dựa trên xterm.js, Claude Code nhường cho trình xử lý liên kết của chính terminal, vốn dùng cùng thao tác.
* **Nhấp và kéo** để chọn văn bản ở bất kỳ đâu trong cuộc hội thoại. Nhấp đúp chọn một từ, khớp với ranh giới từ của iTerm2 để một đường dẫn tệp được chọn như một đơn vị. {/* min-version: 2.1.198 */}Kể từ v2.1.198, nhấp đúp vào một URL sẽ chọn toàn bộ URL, bao gồm cả scheme. Nhấp ba lần chọn cả dòng.
* **Cuộn bằng bánh xe chuột** để di chuyển qua cuộc hội thoại.

Văn bản đã chọn được tự động sao chép vào clipboard của bạn khi thả chuột. Để tắt điều này, chuyển đổi tùy chọn Copy on select trong `/config`.

Với Copy on select tắt, nhấn `Ctrl+Shift+c` để sao chép thủ công. Trên các terminal hỗ trợ giao thức bàn phím kitty, chẳng hạn như kitty, WezTerm, Ghostty, và iTerm2, `Cmd+c` cũng hoạt động. Nếu bạn đang có một vùng chọn được kích hoạt, `Ctrl+c` sẽ sao chép thay vì hủy.

Với một vùng chọn được kích hoạt, giữ `Shift` và nhấn các phím mũi tên để mở rộng nó từ bàn phím. `Shift+↑` và `Shift+↓` cuộn khung nhìn khi vùng chọn chạm đến cạnh trên hoặc dưới. `Shift+Home` và `Shift+End` mở rộng đến đầu hoặc cuối dòng hiện tại.

## Cuộn cuộc hội thoại

Fullscreen rendering xử lý việc cuộn bên trong ứng dụng. Dùng các phím tắt sau để điều hướng:

| Phím tắt        | Hành động                                            |
| :-------------- | :--------------------------------------------------- |
| `PgUp` / `PgDn` | Cuộn lên hoặc xuống nửa màn hình                     |
| `Ctrl+Home`     | Nhảy đến đầu cuộc hội thoại                          |
| `Ctrl+End`      | Nhảy đến thông báo mới nhất và bật lại auto-follow   |
| Bánh xe chuột   | Cuộn từng vài dòng một                               |

Trên các bàn phím không có phím `PgUp`, `PgDn`, `Home`, hoặc `End` chuyên dụng, như bàn phím MacBook, giữ `Fn` cùng với các phím mũi tên: `Fn+↑` gửi `PgUp`, `Fn+↓` gửi `PgDn`, `Fn+←` gửi `Home`, và `Fn+→` gửi `End`. Điều đó làm cho `Ctrl+Fn+→` trở thành phím tắt nhảy-xuống-cuối. Nếu điều đó cảm thấy vụng về, hãy cuộn xuống cuối bằng bánh xe chuột để tiếp tục theo dõi, hoặc gán lại `scroll:bottom` cho một phím dễ với hơn.

Các hành động này có thể gán lại phím. Xem [Các hành động cuộn](/en/keybindings#scroll-actions) để biết danh sách đầy đủ tên hành động, bao gồm các biến thể nửa trang và cả trang không có phím gán mặc định.

### Auto-follow (tự động theo dõi)

Cuộn lên sẽ tạm dừng auto-follow để đầu ra mới không kéo bạn trở lại cuối. Nhấn `Ctrl+End` hoặc cuộn xuống cuối để tiếp tục theo dõi.

Để tắt hoàn toàn auto-follow sao cho khung nhìn ở nguyên nơi bạn để lại, hãy mở `/config` và đặt Auto-scroll thành off. Với auto-scroll bị tắt, khung nhìn không bao giờ tự nhảy xuống cuối. Các lời nhắc xin quyền và các hộp thoại khác cần phản hồi vẫn cuộn vào tầm nhìn bất kể cài đặt này.

### Cuộn bằng bánh xe chuột

Cuộn bằng bánh xe chuột yêu cầu terminal của bạn chuyển tiếp các sự kiện chuột đến Claude Code. Hầu hết các terminal làm điều này bất cứ khi nào một ứng dụng yêu cầu. iTerm2 biến nó thành một cài đặt theo từng profile: nếu bánh xe không làm gì nhưng `PgUp` và `PgDn` hoạt động, hãy mở Settings → Profiles → Terminal và bật Enable mouse reporting. Cài đặt tương tự cũng cần thiết để nhấp-để-mở-rộng và chọn văn bản hoạt động.

Nếu cuộn bằng bánh xe chuột cảm thấy chậm, terminal của bạn có thể đang gửi một sự kiện cuộn cho mỗi nấc vật lý mà không có hệ số nhân. Một số terminal, như Ghostty và iTerm2 khi bật cuộn nhanh hơn, đã khuếch đại các sự kiện bánh xe. Những terminal khác, bao gồm terminal tích hợp của VS Code, gửi chính xác một sự kiện cho mỗi nấc. Claude Code không thể phát hiện cái nào.

Đặt `CLAUDE_CODE_SCROLL_SPEED` để nhân khoảng cách cuộn cơ sở:

```bash theme={null}
export CLAUDE_CODE_SCROLL_SPEED=3
```

Giá trị `3` khớp với mặc định trong `vim` và các ứng dụng tương tự. Cài đặt này chấp nhận các giá trị từ 1 đến 20, và các giá trị phân số dưới 1 như `0.5` để làm chậm việc cuộn trackpad và bánh xe đã tăng tốc trong các terminal vốn đã khuếch đại sự kiện bánh xe.

Để điều chỉnh tốc độ cuộn một cách tương tác, chạy `/scroll-speed`. Hộp thoại hiển thị một thước kẻ mà bạn có thể cuộn trong khi nó đang mở để bạn cảm nhận thay đổi ngay lập tức. Nhấn `←` và `→` để điều chỉnh, `r` để đặt lại về mặc định tự động phát hiện, và `Enter` để lưu.

Lệnh này ghi cùng giá trị mà biến môi trường `CLAUDE_CODE_SCROLL_SPEED` đặt, được lưu bền vào `~/.claude/settings.json`. Lệnh không khả dụng trong terminal của JetBrains IDE.

Tách biệt với tốc độ cơ sở, Claude Code tăng tốc độ cuộn khi bạn xoay bánh xe nhanh, vì vậy một cú xoay nhanh bao phủ nhiều khoảng cách hơn cùng số nấc chậm. {/* min-version: 2.1.174 */}Để tắt tăng tốc và giữ tốc độ không đổi cho mỗi nấc, đặt `wheelScrollAccelerationEnabled` thành `false` trong [`settings.json`](/en/settings#available-settings). Cài đặt này yêu cầu Claude Code v2.1.174 trở lên.

### Cuộn trong terminal của JetBrains IDE

Trong terminal của JetBrains IDE, Claude Code áp dụng cơ chế xử lý cuộn riêng và bỏ qua `CLAUDE_CODE_SCROLL_SPEED`. Terminal gửi các sự kiện cuộn ở tốc độ cao hơn nhiều so với các trình giả lập khác, vì vậy một hệ số nhân được tinh chỉnh ở nơi khác sẽ vượt quá ở đây.

Trong 2025.2, terminal cũng có các lỗi bánh xe cuộn tạo ra các phím mũi tên giả và các sự kiện sai hướng. Claude Code phát hiện những lỗi này tại thời điểm chạy và tự động giảm thiểu chúng, vì vậy cuộn bằng trackpad và bánh xe chuột hoạt động mà không cần cấu hình. Để có trải nghiệm cuộn tốt nhất, hãy nâng cấp lên 2025.3 trở lên. Claude Code hiển thị một gợi ý trong lần đầu tiên bạn cuộn nếu nó phát hiện lỗi.

## Tìm kiếm và xem lại cuộc hội thoại

`Ctrl+o` chuyển đổi giữa prompt bình thường và chế độ transcript.

Để có một chế độ xem yên tĩnh hơn chỉ hiển thị prompt cuối cùng của bạn, một dòng tóm tắt các lệnh gọi công cụ với diffstat của các chỉnh sửa, và phản hồi cuối cùng, hãy chạy `/focus`. Cài đặt này được giữ bền qua các phiên. Chạy `/focus` lại để tắt nó.

Chế độ transcript có thêm điều hướng và tìm kiếm kiểu `less`:

| Phím                                 | Hành động                                                                                              |
| :----------------------------------- | :---------------------------------------------------------------------------------------------------- |
| `/`                                  | Mở tìm kiếm. Gõ để tìm các kết quả khớp, `Enter` để chấp nhận, `Esc` để hủy và khôi phục vị trí cuộn của bạn |
| `n` / `N`                            | Nhảy đến kết quả khớp tiếp theo hoặc trước đó. Hoạt động sau khi bạn đã đóng thanh tìm kiếm            |
| `j` / `k` hoặc `↑` / `↓`             | Cuộn một dòng                                                                                          |
| `g` / `G` hoặc `Home` / `End`        | Nhảy lên đầu hoặc xuống cuối                                                                           |
| `Ctrl+u` / `Ctrl+d`                  | Cuộn nửa trang                                                                                         |
| `Ctrl+b` / `Ctrl+f` hoặc `Space` / `b` | Cuộn cả trang                                                                                        |
| `Ctrl+o`, `Esc`, hoặc `q`            | Thoát chế độ transcript và quay lại prompt                                                            |

`Cmd+f` của terminal và tìm kiếm tmux không nhìn thấy cuộc hội thoại vì nó nằm trong bộ đệm màn hình phụ, không phải trong scrollback native. Để trả nội dung lại cho terminal của bạn, nhấn `Ctrl+o` để vào chế độ transcript trước, sau đó:

* **`[`**: ghi toàn bộ cuộc hội thoại vào bộ đệm scrollback native của terminal, với tất cả đầu ra công cụ được mở rộng. Cuộc hội thoại giờ là văn bản thông thường trong terminal của bạn, vì vậy `Cmd+f`, chế độ copy của tmux, và bất kỳ công cụ native nào khác có thể tìm kiếm hoặc chọn nó. Các phiên dài có thể tạm dừng một lúc trong khi điều này diễn ra. Điều này kéo dài cho đến khi bạn thoát chế độ transcript bằng `Esc` hoặc `q`, đưa bạn trở lại fullscreen rendering. Lần `Ctrl+o` tiếp theo bắt đầu lại từ đầu.
* **`v`**: ghi cuộc hội thoại vào một tệp tạm thời và mở nó trong `$VISUAL` hoặc `$EDITOR`.

Nhấn `Esc` hoặc `q` để quay lại prompt.

## Xóa cuộc hội thoại

Nhấn `Ctrl+L` hai lần trong vòng hai giây để chạy `/clear` và bắt đầu một cuộc hội thoại mới. Lần nhấn đầu tiên vẽ lại màn hình và hiển thị một gợi ý; lần nhấn thứ hai xóa cuộc hội thoại. Trên macOS, nhấn đúp `Cmd+K` cũng chạy `/clear`.

## Sử dụng với tmux

Fullscreen rendering hoạt động bên trong tmux, với ba lưu ý.

Cuộn bằng bánh xe chuột yêu cầu chế độ chuột của tmux. Nếu `~/.tmux.conf` của bạn chưa bật nó, hãy thêm dòng này và tải lại cấu hình:

```bash theme={null}
set -g mouse on
```

Không có chế độ chuột, các sự kiện bánh xe đi đến tmux thay vì Claude Code. Cuộn bằng bàn phím với `PgUp` và `PgDn` vẫn hoạt động trong cả hai trường hợp. Claude Code in ra một gợi ý một lần khi khởi động nếu nó phát hiện tmux với chế độ chuột đang tắt.

Fullscreen rendering không tương thích với chế độ tích hợp tmux của iTerm2, tức là chế độ bạn vào bằng `tmux -CC`. Ở chế độ tích hợp, iTerm2 kết xuất mỗi pane tmux như một split native thay vì để tmux vẽ lên terminal. Bộ đệm màn hình phụ và theo dõi chuột không hoạt động đúng ở đó: bánh xe chuột không làm gì, và nhấp đúp có thể làm hỏng trạng thái terminal. Đừng bật fullscreen rendering trong các phiên `tmux -CC`. tmux thông thường bên trong iTerm2, không có `-CC`, hoạt động tốt.

Không phải mọi phiên bản tmux đều áp dụng đầu ra đồng bộ (synchronized output) từ các ứng dụng, vì vậy bạn có thể thấy nhiều nhấp nháy hơn trong các lần vẽ lại dưới tmux so với khi chạy Claude Code trực tiếp trong terminal của bạn. Nếu nhấp nháy đáng chú ý, đặc biệt qua SSH, hãy nâng cấp lên tmux mới nhất hoặc chạy Claude Code trong tab terminal riêng của nó bên ngoài tmux. Kiểm tra phiên bản tmux của bạn bằng `tmux -V`.

{/* min-version: 2.1.200 */}Claude Code bật đầu ra đồng bộ tự động khi nó phát hiện tmux 3.4 trở lên từ biến `TERM_PROGRAM_VERSION`, và quay về việc truy vấn trực tiếp terminal để biết hỗ trợ đầu ra đồng bộ khi không thể xác định phiên bản. Việc các lần vẽ lại có thực sự trở nên nguyên tử (atomic) hay không phụ thuộc vào việc phiên bản tmux của bạn có tôn trọng đầu ra đồng bộ; nếu bạn vẫn thấy nhấp nháy dưới tmux 3.4 trở lên, hãy nâng cấp lên tmux mới nhất. Việc phát hiện này yêu cầu Claude Code v2.1.200 trở lên.

## Giữ chọn văn bản native

Việc bắt sự kiện chuột là điểm gây khó chịu phổ biến nhất, đặc biệt qua SSH hoặc bên trong tmux. Khi Claude Code bắt các sự kiện chuột, tính năng copy-on-select native của terminal ngừng hoạt động. Vùng chọn bạn tạo bằng nhấp-và-kéo tồn tại bên trong Claude Code, không phải trong bộ đệm chọn của terminal, vì vậy chế độ copy của tmux, Kitty hints, và các công cụ tương tự không nhìn thấy nó.

Claude Code ghi vùng chọn vào clipboard hệ thống của bạn, và đường dẫn nó sử dụng phụ thuộc vào cấu hình của bạn. Trên một phiên cục bộ, nó chạy một công cụ clipboard native:

* **macOS**: `pbcopy`
* **Linux**: `wl-copy` trên Wayland, hoặc `xclip` hoặc `xsel` trên X11, tùy cái nào được cài đặt. Claude Code ghi cả clipboard và vùng chọn PRIMARY, nên dán bằng nhấp chuột giữa hoạt động.
* **Windows và WSL**: PowerShell `Set-Clipboard`

Bên trong tmux, nó cũng ghi vào bộ đệm dán (paste buffer) của tmux. Qua SSH, nó quay về các chuỗi escape OSC 52. Claude Code in ra một toast sau mỗi lần sao chép cho bạn biết đường dẫn nào nó đã dùng.

Một số terminal chặn OSC 52 theo mặc định. iTerm2 chặn nó cho đến khi bạn bật Settings → General → Selection → Applications in terminal may access clipboard; chạy [`/terminal-setup`](/en/terminal-config) trong iTerm2 sẽ bật điều này cho bạn.

Đối với một lần chọn native một lần duy nhất, phím cần dùng phụ thuộc vào terminal của bạn:

* **Terminal.app**: `Fn`
* **iTerm2**: `Option`
* **VS Code, Cursor, và Devin Desktop**: `Shift`, hoặc `Option` trên macOS với cài đặt `terminal.integrated.macOptionClickForcesSelection` được bật
* **Hầu hết các terminal khác**: `Shift`

Giữ phím đó trong khi bạn nhấp và kéo. Terminal của bạn tự xử lý vùng chọn thay vì chuyển nó cho Claude Code, nên các phím tắt sao chép như `Cmd+C` hoạt động trên những gì bạn chọn. Claude Code cũng hiển thị phím đúng trong gợi ý trên màn hình của nó.

Qua SSH hoặc bên trong tmux, Claude Code không phải lúc nào cũng phát hiện được terminal mà bạn đang kết nối từ đó, vì vậy gợi ý liệt kê các phím ứng viên thay thế.

Nếu bạn dựa vào việc chọn native mọi lúc, hãy đặt `CLAUDE_CODE_DISABLE_MOUSE=1` để từ chối bắt sự kiện chuột trong khi vẫn giữ kết xuất không nhấp nháy và bộ nhớ ổn định:

```bash theme={null}
CLAUDE_CODE_NO_FLICKER=1 CLAUDE_CODE_DISABLE_MOUSE=1 claude
```

Với bắt sự kiện chuột bị tắt, cuộn bằng bàn phím với `PgUp`, `PgDn`, `Ctrl+Home`, và `Ctrl+End` vẫn hoạt động, và terminal của bạn xử lý việc chọn một cách native. Bạn mất tính năng nhấp-để-đặt-con-trỏ, nhấp-để-mở-rộng đầu ra công cụ, nhấp URL, và cuộn bằng bánh xe bên trong Claude Code.

Để giữ cuộn bằng bánh xe nhưng tắt xử lý nhấp, kéo, và di chuột, hãy đặt `CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1` để thay thế. Yêu cầu Claude Code v2.1.195 trở lên. `CLAUDE_CODE_DISABLE_MOUSE` được ưu tiên khi cả hai biến đều được đặt.

Với các cú nhấp bị tắt, Claude Code vẫn bắt chuột, nên bánh xe và touchpad cuộn cuộc hội thoại nhưng nhấp chuột trái không làm gì bên trong Claude Code. Bạn vẫn cần giữ phím của terminal để chọn nhấp-và-kéo native. Nhấp chuột phải và dán bằng nhấp chuột giữa tiếp tục hoạt động trên các terminal hỗ trợ chúng.

## Research preview

Fullscreen rendering là một tính năng research preview. Nó đã được kiểm thử trên các trình giả lập terminal phổ biến, nhưng bạn có thể gặp các vấn đề kết xuất trên các terminal ít phổ biến hơn hoặc các cấu hình bất thường.

Nếu bạn gặp vấn đề, hãy chạy `/feedback` bên trong Claude Code để báo cáo nó, hoặc mở một issue trên [claude-code GitHub repo](https://github.com/anthropics/claude-code/issues). Bao gồm tên và phiên bản trình giả lập terminal của bạn.

Để tắt fullscreen rendering, chạy `/tui default`, hoặc bỏ đặt `CLAUDE_CODE_NO_FLICKER` nếu bạn đã bật nó theo cách đó. Để buộc trình kết xuất cổ điển bất kể cài đặt `tui` đã lưu, hãy đặt `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`. Trình kết xuất cổ điển giữ cuộc hội thoại trong scrollback native của terminal nên `Cmd+f` và chế độ copy của tmux hoạt động như thường lệ.

Các phiên chạy nền được mở từ [agent view](/en/agent-view) hoặc `claude attach` luôn sử dụng fullscreen rendering. Terminal đang gắn kết vào bộ đệm màn hình phụ để hiển thị phiên, và trình kết xuất cổ điển không có scrollback hoặc xử lý chuột ở đó, vì vậy cài đặt `tui` và `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` không áp dụng cho chúng.
