> Nguồn: https://code.claude.com/docs/en/permissions.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Cấu hình quyền (permissions)

> Kiểm soát những gì Claude Code có thể truy cập và thực hiện thông qua các quy tắc quyền chi tiết, các chế độ (mode), và các chính sách quản lý (managed policy).

Claude Code hỗ trợ phân quyền chi tiết để bạn có thể chỉ định chính xác agent được phép làm gì và không được làm gì. Các thiết lập quyền có thể được đưa vào hệ thống quản lý phiên bản (version control) và phân phối cho tất cả lập trình viên trong tổ chức của bạn, đồng thời cho phép từng lập trình viên tùy chỉnh riêng.

## Hệ thống phân quyền

Claude Code sử dụng hệ thống phân quyền theo bậc để cân bằng giữa sức mạnh và an toàn:

| Loại công cụ         | Ví dụ            | Cần phê duyệt     | Hành vi khi chọn "Yes, don't ask again"        |
| :------------------- | :--------------- | :---------------- | :--------------------------------------------- |
| Chỉ đọc              | Đọc file, Grep   | Không             | Không áp dụng                                  |
| Lệnh Bash            | Chạy shell       | Có                | Vĩnh viễn theo từng thư mục dự án và từng lệnh |
| Sửa đổi file         | Edit/write file  | Có                | Cho đến hết phiên làm việc                     |

## Quản lý quyền

Bạn có thể xem và quản lý quyền công cụ của Claude Code bằng `/permissions`. Giao diện này liệt kê tất cả các quy tắc quyền và file `settings.json` mà mỗi quy tắc bắt nguồn từ đó.

* Quy tắc **Allow** cho phép Claude Code sử dụng công cụ được chỉ định mà không cần phê duyệt thủ công.
* Quy tắc **Ask** yêu cầu xác nhận mỗi khi Claude Code cố gắng sử dụng công cụ được chỉ định.
* Quy tắc **Deny** ngăn Claude Code sử dụng công cụ được chỉ định.

Các quy tắc được đánh giá theo thứ tự: deny, rồi ask, rồi allow. Kết quả khớp đầu tiên theo thứ tự đó sẽ quyết định kết cục, và mức độ cụ thể của quy tắc không làm thay đổi thứ tự này.

Một quy tắc deny rộng như `Bash(aws *)` chặn mọi lệnh khớp, kể cả lệnh cũng khớp với một quy tắc allow hẹp hơn như `Bash(aws s3 ls)`, vì vậy một quy tắc deny không thể mang theo các ngoại lệ trong danh sách cho phép. Cùng thứ tự ưu tiên đó áp dụng giữa ask và allow: một quy tắc ask khớp vẫn hỏi ngay cả khi một quy tắc allow cụ thể hơn cũng khớp cùng lệnh.

Quy tắc deny hành xử khác nhau tùy theo việc nó gọi tên một công cụ hay giới hạn một pattern trong công cụ đó. Một tên công cụ trần như `Bash` loại bỏ hoàn toàn công cụ đó khỏi ngữ cảnh của Claude, nên Claude không bao giờ thấy nó. Một quy tắc có phạm vi như `Bash(rm *)` để công cụ vẫn khả dụng và chỉ chặn các lệnh khớp khi Claude cố thực hiện.

<Note>
  Quy tắc quyền được thực thi bởi Claude Code, không phải bởi mô hình (model). Các chỉ dẫn trong prompt hoặc `CLAUDE.md` của bạn định hình những gì Claude cố làm, nhưng chúng không thay đổi những gì Claude Code cho phép. Để cấp hoặc thu hồi quyền truy cập, hãy dùng `/permissions`, các quy tắc mô tả ở đây, một [permission mode](/en/permission-modes), hoặc một [PreToolUse hook](#extend-permissions-with-hooks).
</Note>

## Các chế độ quyền (permission modes)

Claude Code hỗ trợ nhiều chế độ quyền để kiểm soát cách nó phê duyệt các lệnh gọi công cụ. Xem [Permission modes](/en/permission-modes) để biết khi nào dùng chế độ nào. Thiết lập `defaultMode` trong [các file settings](/en/settings#settings-files) của bạn:

| Chế độ              | Mô tả                                                                                                                                                                                                                                                                        |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `default`           | Hành vi tiêu chuẩn: hỏi quyền ở lần sử dụng đầu tiên của mỗi công cụ. {/* min-version: 2.1.200 */}Được gán nhãn Manual trong CLI cũng như trong tiện ích mở rộng của VS Code và JetBrains, và Claude Code chấp nhận `manual` như một bí danh. Nhãn và bí danh này cần Claude Code v2.1.200 trở lên |
| `acceptEdits`       | Tự động chấp nhận các thao tác sửa file và các lệnh hệ thống file thông dụng như `mkdir`, `touch`, `mv`, và `cp` cho các đường dẫn nằm trong thư mục làm việc hoặc `additionalDirectories`                                                                                     |
| `plan`              | Plan Mode: Claude đọc file và chạy các lệnh shell chỉ đọc để khám phá nhưng không sửa file mã nguồn của bạn                                                                                                                                                                   |
| `auto`              | Tự động phê duyệt các lệnh gọi công cụ kèm kiểm tra an toàn nền để xác minh hành động phù hợp với yêu cầu của bạn. Hiện là bản xem trước nghiên cứu (research preview)                                                                                                         |
| `dontAsk`           | Tự động từ chối công cụ trừ khi đã được phê duyệt trước qua `/permissions` hoặc các quy tắc `permissions.allow`                                                                                                                                                               |
| `bypassPermissions` | Bỏ qua các lời nhắc quyền, ngoại trừ những lời nhắc bị buộc bởi các quy tắc `ask` tường minh. Việc xóa thư mục gốc và thư mục home như `rm -rf /` vẫn hỏi như một cơ chế ngắt mạch (circuit breaker)                                                                          |

<Warning>
  Chế độ `bypassPermissions` bỏ qua các lời nhắc quyền, kể cả với các thao tác ghi vào `.git`, `.config/git`, `.claude`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, và `.mvn`. Các quy tắc `ask` tường minh vẫn buộc phải hỏi, và các thao tác xóa nhắm vào thư mục gốc hệ thống file hoặc thư mục home, chẳng hạn `rm -rf /` và `rm -rf ~`, vẫn hỏi như một cơ chế ngắt mạch chống lỗi của mô hình. Chỉ dùng chế độ này trong các môi trường cô lập như container hoặc máy ảo (VM) nơi Claude Code không thể gây thiệt hại.
</Warning>

Để ngăn không cho dùng chế độ `bypassPermissions` hoặc `auto`, hãy đặt `permissions.disableBypassPermissionsMode` hoặc `permissions.disableAutoMode` thành `"disable"` trong bất kỳ [file settings](/en/settings#settings-files) nào. Những thiết lập này hữu ích nhất trong [managed settings](#managed-settings) nơi chúng không thể bị ghi đè.

## Cú pháp quy tắc quyền

Quy tắc quyền theo định dạng `Tool` hoặc `Tool(specifier)`.

### Khớp với mọi lần dùng của một công cụ

Để khớp mọi lần dùng của một công cụ, chỉ dùng tên công cụ mà không có dấu ngoặc:

| Quy tắc    | Tác dụng                              |
| :--------- | :------------------------------------ |
| `Bash`     | Khớp mọi lệnh Bash                    |
| `WebFetch` | Khớp mọi yêu cầu web fetch            |
| `Read`     | Khớp mọi thao tác đọc file            |

`Bash(*)` tương đương với `Bash` và khớp mọi lệnh Bash. Là một quy tắc deny, cả hai dạng đều loại bỏ công cụ khỏi ngữ cảnh của Claude.

### Dùng specifier để kiểm soát chi tiết

Thêm một specifier trong dấu ngoặc để khớp các lần dùng công cụ cụ thể:

| Quy tắc                        | Tác dụng                                                    |
| :----------------------------- | :--------------------------------------------------------- |
| `Bash(npm run build)`          | Khớp chính xác lệnh `npm run build`                        |
| `Read(./.env)`                 | Khớp việc đọc file `.env` trong thư mục hiện tại           |
| `WebFetch(domain:example.com)` | Khớp các yêu cầu fetch tới example.com                     |

### Khớp theo tham số đầu vào

Quy tắc deny và ask có thể khớp một tham số đầu vào cấp cao nhất trên bất kỳ công cụ nào bằng `Tool(param:value)`. Quy tắc khớp khi Claude gọi công cụ với tham số đó được đặt đúng giá trị đó. Một quy tắc allow cho một giá trị tham số không thể chứng minh rằng toàn bộ lệnh gọi là an toàn, nên các quy tắc allow tiếp tục dùng cú pháp specifier riêng của từng công cụ. Cách này áp dụng cho bất kỳ tham số vô hướng (scalar) nào mà công cụ chấp nhận:

| Quy tắc                        | Khớp với                                       |
| :----------------------------- | :--------------------------------------------- |
| `Agent(model:opus)`            | Các lệnh gọi Agent yêu cầu bậc mô hình Opus   |
| `Agent(isolation:worktree)`    | Các lệnh gọi Agent yêu cầu một git worktree   |
| `Bash(run_in_background:true)` | Các lệnh gọi Bash chạy nền                     |

Việc khớp tham số tuân theo các quy tắc sau:

* Tên tham số phải là một trường trực tiếp của đầu vào công cụ, chẳng hạn `model` trên công cụ Agent. Các trường lồng bên trong một object hoặc mảng không thể khớp được
* Mỗi quy tắc gọi tên một tham số. Để kiểm soát cả `model` và `isolation`, hãy viết hai quy tắc, `Agent(model:opus)` và `Agent(isolation:worktree)`, thay vì gộp chúng vào một quy tắc
* Giá trị hỗ trợ `*` như một ký tự đại diện (wildcard) khớp với bất kỳ chuỗi ký tự nào, nên `Agent(isolation:*)` khớp mọi giá trị isolation tường minh. Không có `*` thì phép khớp là chính xác
* Một tham số mà mô hình bỏ qua sẽ không bao giờ được khớp, nên `Agent(model:*)` không khớp một lệnh gọi để trống `model`
* Giá trị được so sánh với đầu vào nguyên văn mà Claude gửi, trước bất kỳ chuẩn hóa nào. `Agent(model:opus)` khớp bí danh `opus` nhưng không khớp một model ID đầy đủ. Chạy với [`--verbose`](/en/cli-reference) để xem chính xác tên và giá trị tham số trong mỗi lệnh gọi công cụ
* Khoảng trắng quanh dấu hai chấm được bỏ qua

Các trường mà một công cụ đã khớp bằng quy tắc chuẩn hóa riêng của nó thì không thể khớp theo cách này: `command` cho Bash và PowerShell, `file_path` cho Read, Edit, và Write, `path` cho Grep và Glob, `notebook_path` cho NotebookEdit, và `url` cho WebFetch. Một quy tắc như `Bash(command:rm *)` có thể bị vượt qua bằng một lệnh ghép (compound command), nên Claude Code bỏ qua nó và phát ra cảnh báo khi khởi động. Hãy dùng `Bash(rm *)`, `Read(./path)`, hoặc `WebFetch(domain:host)` thay thế.

### Pattern ký tự đại diện

Quy tắc Bash hỗ trợ pattern glob với `*`. Ký tự đại diện có thể xuất hiện ở bất kỳ vị trí nào trong lệnh. Cấu hình này cho phép các lệnh npm và git commit trong khi chặn git push:

```json theme={null}
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Bash(git * main)",
      "Bash(* --version)",
      "Bash(* --help *)"
    ],
    "deny": [
      "Bash(git push *)"
    ]
  }
}
```

Khoảng trắng trước `*` có ý nghĩa quan trọng: `Bash(ls *)` khớp `ls -la` nhưng không khớp `lsof`, trong khi `Bash(ls*)` khớp cả hai. Hậu tố `:*` là cách viết tương đương cho một ký tự đại diện ở cuối, nên `Bash(ls:*)` khớp cùng các lệnh như `Bash(ls *)`.

Hộp thoại quyền ghi dạng ngăn cách bằng khoảng trắng khi bạn chọn "Yes, don't ask again" cho một tiền tố lệnh. Dạng `:*` chỉ được nhận diện ở cuối một pattern. Trong một pattern như `Bash(git:* push)`, dấu hai chấm được coi là một ký tự nghĩa đen và sẽ không khớp các lệnh git.

### Ký tự đại diện cho tên công cụ

Quy tắc deny và ask cũng chấp nhận pattern glob ở vị trí tên công cụ. Pattern phải khớp toàn bộ tên công cụ: `"*"` khớp mọi công cụ, và `"mcp__*"` khớp mọi công cụ MCP trên tất cả các server. Một công cụ bị khớp bởi một quy tắc deny dạng glob tên trần sẽ bị loại khỏi ngữ cảnh của Claude, giống như một tên công cụ trần. Cấu hình này từ chối mọi công cụ MCP:

```json theme={null}
{
  "permissions": {
    "deny": [
      "mcp__*"
    ]
  }
}
```

Quy tắc allow chỉ chấp nhận glob tên công cụ sau một tiền tố `mcp__<server>__` dạng nghĩa đen. Phân đoạn server phải không có glob để quy tắc gọi tên một server cụ thể mà bạn đã cấu hình. `mcp__puppeteer__*` khớp mọi công cụ từ server `puppeteer`, và `mcp__github__get_*` khớp các công cụ `get_` của nó. Một glob allow không được neo như `"*"`, `"B*"`, hoặc `"mcp__*"` sẽ bị bỏ qua kèm cảnh báo và không tự động phê duyệt bất cứ điều gì.

Một quy tắc deny hoặc ask có tên công cụ không khớp với công cụ nào đã biết sẽ tạo ra cảnh báo khi khởi động để bắt lỗi gõ nhầm. Các tên công cụ chứa `_` hoặc `*` được miễn khỏi kiểm tra này.

Nhãn hiển thị cho một công cụ trong transcript và hộp thoại quyền có thể khác với tên chính tắc (canonical) của nó. Ví dụ, công cụ được gán nhãn `Stop Task` trong transcript có tên chính tắc là `TaskStop`. Quy tắc quyền và [hook matcher](/en/hooks) chỉ khớp với tên chính tắc, nên một quy tắc viết là `Stop Task` sẽ không khớp. Với quy tắc deny và ask, cảnh báo khởi động ở trên sẽ bắt được sự không khớp. Hãy dùng các tên chính tắc được liệt kê trong [tài liệu tham chiếu công cụ](/en/tools-reference).

## Quy tắc quyền theo từng công cụ

### Bash

Quy tắc quyền Bash hỗ trợ khớp ký tự đại diện với `*`. Ký tự đại diện có thể xuất hiện ở bất kỳ vị trí nào trong lệnh, bao gồm đầu, giữa, hoặc cuối:

* `Bash(npm run build)` khớp chính xác lệnh Bash `npm run build`
* `Bash(npm run test *)` khớp các lệnh Bash bắt đầu bằng `npm run test`
* `Bash(npm *)` khớp mọi lệnh bắt đầu bằng `npm `
* `Bash(* install)` khớp mọi lệnh kết thúc bằng ` install`
* `Bash(git * main)` khớp các lệnh như `git checkout main` và `git log --oneline main`

Một `*` đơn khớp với bất kỳ chuỗi ký tự nào kể cả khoảng trắng, nên một ký tự đại diện có thể trải qua nhiều đối số. `Bash(git *)` khớp `git log --oneline --all`, và `Bash(git * main)` khớp `git push origin main` cũng như `git merge main`.

Khi `*` xuất hiện ở cuối với một khoảng trắng phía trước (như `Bash(ls *)`), nó áp đặt một ranh giới từ (word boundary), yêu cầu tiền tố phải được theo sau bởi một khoảng trắng hoặc điểm kết thúc chuỗi. Ví dụ, `Bash(ls *)` khớp `ls -la` nhưng không khớp `lsof`. Ngược lại, `Bash(ls*)` không có khoảng trắng khớp cả `ls -la` và `lsof` vì không có ràng buộc ranh giới từ.

#### Lệnh ghép (compound commands)

<Tip>
  Claude Code nhận biết các toán tử shell, nên một quy tắc như `Bash(safe-cmd *)` sẽ không cho phép nó chạy lệnh `safe-cmd && other-cmd`. Các ký tự phân tách lệnh được nhận diện là `&&`, `||`, `;`, `|`, `|&`, `&`, và các ký tự xuống dòng. Một quy tắc phải khớp từng lệnh con một cách độc lập.
</Tip>

Khi bạn phê duyệt một lệnh ghép với "Yes, don't ask again", Claude Code lưu một quy tắc riêng cho từng lệnh con cần phê duyệt, thay vì một quy tắc duy nhất cho toàn bộ chuỗi ghép. Ví dụ, phê duyệt `git status && npm test` lưu một quy tắc cho `npm test`, nên các lần gọi `npm test` sau này được nhận diện bất kể phía trước `&&` là gì. Các lệnh con như `cd` vào một thư mục con tạo ra quy tắc Read riêng cho đường dẫn đó. Tối đa 5 quy tắc có thể được lưu cho một lệnh ghép.

#### Trình bao lệnh (process wrappers)

Trước khi khớp các quy tắc Bash, Claude Code loại bỏ một tập cố định các trình bao lệnh (process wrapper) để một quy tắc như `Bash(npm test *)` cũng khớp `timeout 30 npm test`. Các trình bao được nhận diện là `timeout`, `time`, `nice`, `nohup`, và `stdbuf`.

`xargs` trần cũng bị loại bỏ, nên `Bash(grep *)` khớp `xargs grep pattern`. Việc loại bỏ chỉ áp dụng khi `xargs` không có cờ nào: một lần gọi như `xargs -n1 grep pattern` được khớp như một lệnh `xargs`, nên các quy tắc viết cho lệnh bên trong không bao gồm nó.

Danh sách trình bao này được tích hợp sẵn và không thể cấu hình. Các trình chạy môi trường phát triển như `direnv exec`, `devbox run`, `mise exec`, `npx`, và `docker exec` không nằm trong danh sách. Vì các công cụ này thực thi các đối số của chúng như một lệnh, một quy tắc như `Bash(devbox run *)` khớp bất cứ gì đứng sau `run`, bao gồm cả `devbox run rm -rf .`. Để phê duyệt công việc bên trong một trình chạy môi trường, hãy viết một quy tắc cụ thể bao gồm cả trình chạy lẫn lệnh bên trong, chẳng hạn `Bash(devbox run npm test)`. Thêm một quy tắc cho mỗi lệnh bên trong mà bạn muốn cho phép.

Các trình bao thực thi (exec wrapper) như `watch`, `setsid`, `ionice`, và `flock` luôn hỏi và không thể tự động phê duyệt bằng một quy tắc tiền tố như `Bash(watch *)`. Điều tương tự áp dụng cho `find` với `-exec` hoặc `-delete`: một quy tắc `Bash(find *)` không bao gồm các dạng này. Để phê duyệt một lần gọi cụ thể, hãy viết một quy tắc khớp chính xác cho toàn bộ chuỗi lệnh.

#### Lệnh chỉ đọc

Claude Code nhận diện một tập lệnh Bash tích hợp sẵn là chỉ đọc và chạy chúng mà không hỏi quyền trong mọi chế độ. Các lệnh này bao gồm `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, và các dạng chỉ đọc của `git`. Tập này không thể cấu hình; để yêu cầu hỏi quyền cho một trong các lệnh này, hãy thêm một quy tắc `ask` hoặc `deny` cho nó.

Các pattern glob không đặt trong dấu ngoặc kép được cho phép với các lệnh mà mọi cờ đều là chỉ đọc, nên `ls *.ts` và `wc -l src/*.py` chạy mà không hỏi. Các lệnh có cờ có khả năng ghi hoặc thực thi, chẳng hạn `find`, `sort`, `sed`, và `git`, vẫn hỏi khi có một glob không đặt trong dấu ngoặc kép vì glob có thể mở rộng thành một cờ như `-delete`.

Một lệnh `cd` vào một đường dẫn bên trong thư mục làm việc của bạn hoặc một [thư mục bổ sung](#working-directories) cũng là chỉ đọc. Một lệnh ghép như `cd packages/api && ls` chạy mà không hỏi khi mỗi phần đủ điều kiện độc lập. Kết hợp `cd` với `git` trong một lệnh ghép luôn hỏi, bất kể thư mục đích.

<Warning>
  Các pattern quyền Bash cố gắng ràng buộc đối số lệnh rất mong manh. Ví dụ, `Bash(curl http://github.com/ *)` có ý định giới hạn curl vào các URL GitHub, nhưng sẽ không khớp các biến thể như:

  * Tùy chọn đứng trước URL: `curl -X GET http://github.com/...`
  * Giao thức khác: `curl https://github.com/...`
  * Chuyển hướng: `curl -L http://bit.ly/xyz`, chuyển hướng tới GitHub
  * Biến: `URL=http://github.com && curl $URL`
  * Khoảng trắng dư: `curl  http://github.com`

  Để lọc URL đáng tin cậy hơn, hãy cân nhắc:

  * **Hạn chế các công cụ mạng của Bash**: dùng quy tắc deny để chặn `curl`, `wget`, và các lệnh tương tự, rồi dùng công cụ WebFetch với quyền `WebFetch(domain:github.com)` cho các miền được phép
  * **Dùng PreToolUse hooks**: triển khai một hook để xác thực URL trong các lệnh Bash và chặn các miền không được phép
  * **Thêm hướng dẫn trong CLAUDE.md**: mô tả các pattern curl được phép trong `CLAUDE.md`. Điều này định hình những gì Claude cố làm nhưng không áp đặt một ranh giới, nên hãy kết hợp nó với một trong các tùy chọn ở trên

  Lưu ý rằng chỉ dùng WebFetch không ngăn được truy cập mạng. Nếu Bash được phép, Claude vẫn có thể dùng `curl`, `wget`, hoặc các công cụ khác để tiếp cận bất kỳ URL nào.
</Warning>

### PowerShell

Quy tắc quyền PowerShell dùng cùng dạng như quy tắc Bash. Ký tự đại diện với `*` khớp ở bất kỳ vị trí nào, hậu tố `:*` tương đương với một ` *` ở cuối, và một `PowerShell` hoặc `PowerShell(*)` trần khớp mọi lệnh. Cấu hình này cho phép các lệnh `Get-ChildItem` và `git commit` trong khi chặn `Remove-Item`:

```json theme={null}
{
  "permissions": {
    "allow": [
      "PowerShell(Get-ChildItem *)",
      "PowerShell(git commit *)"
    ],
    "deny": [
      "PowerShell(Remove-Item *)"
    ]
  }
}
```

Các bí danh (alias) thông dụng được chuẩn hóa trước khi khớp. Một quy tắc viết cho tên cmdlet cũng khớp các bí danh của nó, nên `PowerShell(Get-ChildItem *)` khớp cả `gci`, `ls`, và `dir`. Việc khớp không phân biệt chữ hoa/thường.

Claude Code phân tích AST của PowerShell và kiểm tra từng lệnh trong một lệnh ghép một cách độc lập. Các toán tử pipeline `|`, các ký tự phân tách câu lệnh `;`, và trên PowerShell 7+ là các toán tử chuỗi `&&` và `||`, sẽ tách một lệnh ghép thành các lệnh con. Một quy tắc phải khớp mọi lệnh con thì lệnh ghép mới được phép.

### Read và Edit

Quy tắc `Edit` áp dụng cho tất cả các công cụ tích hợp sẵn có khả năng sửa file. Claude cố gắng hết mức để áp dụng quy tắc `Read` cho tất cả các công cụ tích hợp sẵn có khả năng đọc file như Grep và Glob, cho các đề cập `@file` trong prompt của bạn, và cho phần lựa chọn cũng như ngữ cảnh file đang mở mà một [IDE](/en/vs-code#the-built-in-ide-mcp-server) đã kết nối chia sẻ với Claude.

<Warning>
  Quy tắc deny của Read và Edit áp dụng cho các công cụ file tích hợp của Claude và cho các lệnh file mà Claude Code nhận diện trong Bash, chẳng hạn `cat`, `head`, `tail`, và `sed`. Chúng không áp dụng cho các tiến trình con tùy ý mà đọc hoặc ghi file một cách gián tiếp, như một script Python hoặc Node tự mở file. Để có sự thực thi ở cấp hệ điều hành chặn mọi tiến trình truy cập một đường dẫn, hãy [bật sandbox](/en/sandboxing).
</Warning>

Quy tắc Read và Edit đều tuân theo đặc tả [gitignore](https://git-scm.com/docs/gitignore) với bốn loại pattern riêng biệt:

| Pattern            | Ý nghĩa                                   | Ví dụ                            | Khớp với                                          |
| ------------------ | ----------------------------------------- | -------------------------------- | ------------------------------------------------ |
| `//path`           | Đường dẫn tuyệt đối từ gốc hệ thống file  | `Read(//Users/alice/secrets/**)` | `/Users/alice/secrets/**`                        |
| `~/path`           | Đường dẫn từ thư mục home                  | `Read(~/Documents/*.pdf)`        | `/Users/alice/Documents/*.pdf`                   |
| `/path`            | Đường dẫn tương đối với nguồn settings     | `Edit(/src/**/*.ts)`             | `<project root>/src/**/*.ts` trong project settings |
| `path` hoặc `./path` | Đường dẫn tương đối với thư mục hiện tại | `Read(*.env)`                    | `<cwd>/*.env`                                    |

<Warning>
  Một pattern như `/Users/alice/file` không phải là đường dẫn tuyệt đối. Dấu gạch chéo đơn ở đầu neo tại nguồn settings, không phải gốc hệ thống file. Dùng `//Users/alice/file` cho đường dẫn tuyệt đối.
</Warning>

Một pattern `/path` neo tại thư mục gắn với file settings định nghĩa nó, nên cùng một quy tắc khớp các vị trí khác nhau tùy vào nơi bạn đặt nó:

| Quy tắc được định nghĩa trong                              | `/path` phân giải thành    |
| :--------------------------------------------------------- | :------------------------- |
| Project hoặc local settings, chẳng hạn `.claude/settings.json` | `<project root>/path`  |
| User settings tại `~/.claude/settings.json`                | `~/.claude/path`           |
| Một file truyền qua `--settings <file>`                    | `<thư mục của file>/path`  |
| Cờ CLI, `/permissions`, hoặc các quy tắc phiên            | `<cwd ban đầu>/path`       |

Một quy tắc deny như `Read(/secrets/**)` trong user settings chặn `~/.claude/secrets/**`, không phải một thư mục `secrets` trong dự án của bạn. Để viết một quy tắc trong user settings áp dụng bên trong mọi dự án, hãy dùng đường dẫn tuyệt đối `//` hoặc đường dẫn tương đối với home `~/` thay thế.

Trên Windows, các đường dẫn được chuẩn hóa về dạng POSIX trước khi khớp. `C:\Users\alice` trở thành `/c/Users/alice`, nên dùng `//c/**/.env` để khớp các file `.env` ở bất kỳ đâu trên ổ đĩa đó. Để khớp trên tất cả các ổ đĩa, dùng `//**/.env`.

Ví dụ:

* `Edit(/docs/**)`: sửa trong `<project>/docs/`, không phải `/docs/` hay `<project>/.claude/docs/`
* `Read(~/.zshrc)`: đọc file `.zshrc` trong thư mục home của bạn
* `Edit(//tmp/scratch.txt)`: sửa đường dẫn tuyệt đối `/tmp/scratch.txt`
* `Read(src/**)`: đọc từ `<current-directory>/src/`

Một quy tắc chỉ khớp các file nằm dưới điểm neo của nó, nên điểm neo quyết định một quy tắc deny vươn tới đâu. Các tên file trần tuân theo ngữ nghĩa gitignore và khớp ở bất kỳ độ sâu nào, nên `Read(.env)` và `Read(**/.env)` là tương đương:

| Quy tắc deny                    | Chặn                                         | Không chặn                                           |
| ------------------------------- | -------------------------------------------- | ---------------------------------------------------- |
| `Read(.env)` hoặc `Read(**/.env)` | mọi `.env` tại hoặc dưới thư mục hiện tại   | `.env` trong một thư mục cha hoặc dự án khác          |
| `Read(//**/.env)`               | mọi `.env` ở bất kỳ đâu trên hệ thống file   | không gì cả; quy tắc được neo tại gốc hệ thống file  |

<Note>
  Trong các pattern gitignore, `*` khớp trong một phân đoạn đường dẫn duy nhất và có thể xuất hiện ở bất kỳ vị trí nào trong pattern, trong khi `**` khớp xuyên qua các thư mục. Để cho phép truy cập mọi file, chỉ dùng tên công cụ mà không có dấu ngoặc: `Read`, `Edit`, hoặc `Write`.
</Note>

Khi Claude truy cập một symlink, các quy tắc quyền kiểm tra hai đường dẫn: bản thân symlink và file mà nó phân giải tới. Quy tắc allow và deny xử lý cặp đó khác nhau: quy tắc allow quay về hỏi bạn, trong khi quy tắc deny chặn thẳng.

* **Quy tắc allow**: chỉ áp dụng khi cả đường dẫn symlink lẫn đích của nó đều khớp. Một symlink bên trong một thư mục được phép nhưng trỏ ra ngoài nó vẫn hỏi bạn.
* **Quy tắc deny**: áp dụng khi hoặc đường dẫn symlink hoặc đích của nó khớp. Một symlink trỏ tới một file bị từ chối thì bản thân nó cũng bị từ chối.

Ví dụ, với `Read(./project/**)` được cho phép và `Read(~/.ssh/**)` bị từ chối, một symlink tại `./project/key` trỏ tới `~/.ssh/id_rsa` sẽ bị chặn: đích không qua được quy tắc allow và khớp quy tắc deny.

### WebFetch

Quy tắc WebFetch dùng tiền tố `domain:` và khớp với hostname của URL được yêu cầu. Việc khớp không phân biệt chữ hoa/thường, hỗ trợ ký tự đại diện `*`, và loại bỏ dấu `.` ở cuối từ cả quy tắc lẫn hostname nên `example.com.` và `example.com` được coi là như nhau.

* `WebFetch(domain:example.com)` khớp các yêu cầu tới `example.com`
* `WebFetch(domain:*.example.com)` khớp bất kỳ subdomain nào ở bất kỳ độ sâu nào, chẳng hạn `api.example.com` hoặc `a.b.example.com`, nhưng không khớp chính `example.com`
* `WebFetch(domain:*)` khớp mọi miền và tương đương với một quy tắc `WebFetch` trần

Ở bất kỳ vị trí nào khác ngoài một `*.` ở đầu hoặc một `*` trần, ký tự đại diện chỉ khớp phần văn bản giữa hai dấu chấm. `WebFetch(domain:example.*)` khớp `example.org`, nơi `*` trở thành `org`, nhưng không khớp `example.evil.com`, nơi `*` sẽ phải trở thành `evil.com` và vượt qua một dấu chấm. Điều này ngăn một ký tự đại diện ở cuối khớp các miền mà kẻ tấn công có thể đăng ký.

### MCP

Quy tắc MCP dùng tên server như đã cấu hình trong Claude Code, tùy chọn theo sau là tên của một công cụ từ server đó.

* `mcp__puppeteer` khớp mọi công cụ do server `puppeteer` cung cấp
* `mcp__puppeteer__*` dùng cú pháp ký tự đại diện và cũng khớp mọi công cụ từ server `puppeteer`
* `mcp__puppeteer__puppeteer_navigate` khớp công cụ `puppeteer_navigate` do server `puppeteer` cung cấp

### Agent (subagents)

Dùng quy tắc `Agent(AgentName)` để kiểm soát những [subagent](/en/sub-agents) nào Claude có thể dùng:

* `Agent(Explore)` khớp subagent Explore
* `Agent(Plan)` khớp subagent Plan
* `Agent(my-custom-agent)` khớp một subagent tùy chỉnh tên `my-custom-agent`

Thêm các quy tắc này vào mảng `deny` trong settings hoặc dùng cờ CLI `--disallowedTools` để vô hiệu hóa các agent cụ thể. Để vô hiệu hóa agent Explore:

```json theme={null}
{
  "permissions": {
    "deny": ["Agent(Explore)"]
  }
}
```

### Cd

Quy tắc `Cd` kiểm soát những thư mục nào mà [lệnh `/cd`](/en/commands) có thể chuyển phiên tới. `Cd` không phải là một công cụ mà mô hình có thể gọi: Claude không thể gọi nó, và các quy tắc chỉ áp dụng khi chính bạn chạy `/cd`.

Một quy tắc deny `Cd` trần vô hiệu hóa hoàn toàn `/cd`. Một quy tắc deny `Cd(<path-pattern>)` chặn các đích khớp. Quy tắc deny kiểm tra mọi cách viết của đích, kể cả từng bước symlink mà nó phân giải qua, nên một quy tắc viết cho một đường dẫn cũng chặn các đích phân giải tới nó.

Việc thêm bất kỳ quy tắc allow `Cd` nào sẽ chuyển `/cd` sang chế độ danh sách cho phép (allowlist): thư mục đích đã phân giải phải khớp một trong các quy tắc allow của bạn, nếu không `/cd` từ chối. Không có quy tắc `Cd` nào được cấu hình, `/cd` giữ hành vi mặc định và hỏi bạn để tin cậy một thư mục lạ.

Các pattern đường dẫn chia sẻ các điểm neo `//`, `~/`, và `/` từ [quy tắc Read và Edit](#read-and-edit), nhưng việc khớp được neo vào toàn bộ đường dẫn thư mục thay vì theo kiểu gitignore. `*` khớp đúng một phân đoạn đường dẫn và `**` khớp xuyên qua các phân đoạn. Một `/**` ở cuối cũng khớp gốc được đặt tên của nó.

| Quy tắc               | Khớp                                       | Không khớp                    |
| --------------------- | ------------------------------------------ | ----------------------------- |
| `Cd(~/code/*)`        | `~/code/app`                              | `~/code/app/src`, `~/code`    |
| `Cd(~/code/**)`       | `~/code` và bất kỳ thư mục nào dưới nó     | các thư mục ngoài `~/code`    |
| `Cd(**/node_modules)` | bất kỳ thư mục `node_modules` nào ở bất kỳ độ sâu nào | `node_modules/pkg`   |

## Mở rộng quyền với hooks

[Hooks của Claude Code](/en/hooks-guide) cung cấp một cách để đăng ký các lệnh shell tùy chỉnh nhằm đánh giá quyền tại thời điểm chạy (runtime). Khi Claude Code thực hiện một lệnh gọi công cụ, các PreToolUse hook chạy trước lời nhắc quyền. Đầu ra của hook có thể từ chối lệnh gọi công cụ, buộc phải hỏi, hoặc bỏ qua lời nhắc để lệnh gọi tiếp tục.

Các quyết định của hook không vượt qua các quy tắc quyền. Quy tắc deny và ask được đánh giá bất kể một PreToolUse hook trả về gì, nên một quy tắc deny khớp sẽ chặn lệnh gọi và một quy tắc ask khớp vẫn hỏi ngay cả khi hook trả về `"allow"` hoặc `"ask"`. Điều này giữ nguyên thứ tự ưu tiên deny-trước-tiên đã mô tả trong [Quản lý quyền](#manage-permissions), kể cả các quy tắc deny đặt trong managed settings.

Một hook chặn cũng có quyền ưu tiên hơn các quy tắc allow. Một hook thoát với mã lỗi 2 sẽ dừng lệnh gọi công cụ trước khi các quy tắc quyền được đánh giá, nên việc chặn có hiệu lực ngay cả khi một quy tắc allow lẽ ra sẽ cho lệnh gọi tiếp tục. Để chạy mọi lệnh Bash mà không hỏi trừ một số lệnh bạn muốn chặn, hãy thêm `"Bash"` vào danh sách allow và đăng ký một PreToolUse hook để từ chối những lệnh cụ thể đó. Xem [Chặn sửa các file được bảo vệ](/en/hooks-guide#block-edits-to-protected-files) để có một script hook bạn có thể tùy biến.

## Thư mục làm việc

Theo mặc định, Claude có quyền truy cập các file trong thư mục nơi bạn khởi chạy nó. Bạn có thể mở rộng quyền truy cập này:

* **Khi khởi động**: dùng đối số CLI `--add-dir <path>`
* **Trong phiên**: dùng lệnh `/add-dir`
* **Cấu hình bền vững**: thêm vào `additionalDirectories` trong [các file settings](/en/settings#settings-files)

Các file trong thư mục bổ sung tuân theo cùng các quy tắc quyền như thư mục làm việc gốc: chúng trở thành có thể đọc mà không hỏi, và quyền sửa file tuân theo chế độ quyền hiện tại.

Để thay đổi thư mục làm việc chính của phiên thay vì thêm một thư mục khác, hãy dùng [`/cd`](/en/commands). Lệnh `/cd` cần Claude Code v2.1.169 trở lên. Không như `/add-dir`, nó chuyển chỗ phiên: `CLAUDE.md` của thư mục mới được nạp và `--resume` tìm phiên từ đó.

### Thư mục bổ sung cấp quyền truy cập file, không phải cấu hình

Việc thêm một thư mục mở rộng nơi Claude có thể đọc và sửa file. Nó không biến thư mục đó thành một gốc cấu hình đầy đủ: hầu hết cấu hình `.claude/` không được phát hiện từ các thư mục bổ sung, dù một số loại được nạp như ngoại lệ.

Các ngoại lệ này chỉ áp dụng cho các thư mục được thêm bằng cờ `--add-dir` hoặc lệnh `/add-dir`. Các thư mục liệt kê trong `permissions.additionalDirectories` trong một file settings chỉ cấp quyền truy cập file và không nạp bất kỳ cấu hình nào dưới đây.

Các loại cấu hình sau được nạp từ các thư mục `--add-dir`:

| Cấu hình                                                                              | Được nạp từ `--add-dir`                                                                                                                                            |
| :------------------------------------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Skills](/en/skills) trong `.claude/skills/`                                          | Có, với live reload                                                                                                                                              |
| [Subagents](/en/sub-agents) trong `.claude/agents/`                                   | Có                                                                                                                                                                |
| [Settings](/en/settings) trong `.claude/settings.json` và `.claude/settings.local.json` | Chỉ các khóa `enabledPlugins` và `extraKnownMarketplaces`                                                                                                     |
| Các file [CLAUDE.md](/en/memory), `.claude/rules/`, và `CLAUDE.local.md`             | Chỉ khi `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` được đặt. `CLAUDE.local.md` còn cần thêm nguồn settings `local`, vốn được bật theo mặc định |

Commands và output styles được phát hiện từ thư mục làm việc hiện tại và các thư mục cha của nó, thư mục người dùng của bạn tại `~/.claude/`, và managed settings. Hooks và các khóa `settings.json` khác được nạp từ thư mục `.claude/` của thư mục làm việc hiện tại mà không quay về thư mục cha, cùng với `~/.claude/settings.json` của người dùng và managed settings. Để chia sẻ cấu hình đó giữa các dự án, hãy dùng một trong các cách sau:

* **Cấu hình cấp người dùng**: đặt file trong `~/.claude/agents/`, `~/.claude/output-styles/`, hoặc `~/.claude/settings.json` để chúng khả dụng trong mọi dự án
* **Plugins**: đóng gói và phân phối cấu hình dưới dạng một [plugin](/en/plugins) mà các nhóm có thể cài đặt
* **Khởi chạy từ thư mục cấu hình**: chạy Claude Code từ thư mục chứa cấu hình `.claude/` mà bạn muốn

## Cách quyền tương tác với sandboxing

Quyền và [sandboxing](/en/sandboxing) là các lớp bảo mật bổ trợ cho nhau:

* **Quyền** kiểm soát những công cụ nào Claude Code có thể dùng và những file hoặc miền nào nó có thể truy cập. Chúng áp dụng cho mọi công cụ, bao gồm Bash, Read, Edit, WebFetch, và MCP.
* **Sandboxing** cung cấp sự thực thi ở cấp hệ điều hành, giới hạn quyền truy cập hệ thống file và mạng của công cụ Bash. Nó chỉ áp dụng cho các lệnh Bash và các tiến trình con của chúng.

Dùng cả hai để phòng thủ theo chiều sâu (defense-in-depth):

* Quy tắc deny của quyền chặn Claude ngay cả khi cố gắng truy cập các tài nguyên bị hạn chế
* Các hạn chế sandbox ngăn các lệnh Bash tiếp cận tài nguyên ngoài ranh giới đã định, ngay cả khi một cuộc tấn công tiêm prompt (prompt injection) vượt qua được quyết định của Claude
* Các hạn chế hệ thống file trong sandbox kết hợp thiết lập [`sandbox.filesystem`](/en/sandboxing) với các quy tắc deny của Read và Edit; cả hai được gộp vào ranh giới sandbox cuối cùng
* Các hạn chế mạng kết hợp quy tắc quyền WebFetch với danh sách `allowedDomains` và `deniedDomains` của sandbox

Khi sandboxing được bật với `autoAllowBashIfSandboxed: true`, vốn là mặc định, các lệnh Bash được sandbox chạy mà không hỏi ngay cả khi quyền của bạn bao gồm một quy tắc ask `Bash` trần, hoặc [dạng `Bash(*)` tương đương](#match-all-uses-of-a-tool): ranh giới sandbox thay thế cho lời nhắc toàn công cụ đó. Các kiểm tra sau vẫn áp dụng:

* Các quy tắc ask có phạm vi nội dung như `Bash(git push *)` vẫn buộc phải hỏi
* Các quy tắc deny tường minh vẫn áp dụng
* Các lệnh `rm` hoặc `rmdir` nhắm vào `/`, thư mục home của bạn, hoặc các đường dẫn hệ thống quan trọng khác vẫn kích hoạt lời nhắc

Các lệnh sẽ không chạy được trong sandbox, chẳng hạn các lệnh bị loại trừ, vẫn tuân theo quy tắc ask `Bash` trần như thường lệ. Xem [chế độ sandbox](/en/sandboxing#sandbox-modes) để thay đổi hành vi này.

## Managed settings

Đối với các tổ chức cần kiểm soát tập trung cấu hình Claude Code, quản trị viên có thể triển khai managed settings không thể bị ghi đè bởi user hoặc project settings. Các thiết lập chính sách này tuân theo cùng định dạng như các file settings thông thường và có thể được phân phối qua các chính sách MDM/cấp hệ điều hành, các file managed settings, [server-managed settings](/en/server-managed-settings), hoặc một [Claude apps gateway](/en/claude-apps-gateway) tự lưu trữ. Xem [các file settings](/en/settings#settings-files) để biết các cơ chế phân phối và vị trí file.

### Các thiết lập chỉ dành cho managed

Các thiết lập sau chỉ được đọc từ managed settings. Đặt chúng trong các file user hoặc project settings sẽ không có tác dụng.

| Thiết lập                                      | Mô tả                                                                                                                                                                                                                                                                                                                                |
| :--------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `allowAllClaudeAiMcps`                         | Khi `true`, các connector của claude.ai được nạp cùng với một `managed-mcp.json` đã triển khai thay vì bị chặn bởi quyền kiểm soát độc quyền của nó. Xem [Cấu hình MCP quản lý](/en/managed-mcp)                                                                                                                                     |
| `allowedChannelPlugins`                        | Danh sách cho phép các channel plugin được phép đẩy tin nhắn. Thay thế danh sách cho phép mặc định của Anthropic khi được đặt. Cần `channelsEnabled: true`. Xem [Hạn chế những channel plugin nào có thể chạy](/en/channels#restrict-which-channel-plugins-can-run)                                                                    |
| `allowManagedHooksOnly`                        | Khi `true`, chỉ các managed hook, SDK hook, và hook từ các plugin bị buộc bật trong `enabledPlugins` của managed settings mới được nạp. Hook của user, project, và mọi plugin khác đều bị chặn                                                                                                                                       |
| `allowManagedMcpServersOnly`                   | Khi `true`, chỉ `allowedMcpServers` từ managed settings được tôn trọng. `deniedMcpServers` vẫn gộp từ mọi nguồn. Xem [Cấu hình MCP quản lý](/en/managed-mcp)                                                                                                                                                                         |
| `allowManagedPermissionRulesOnly`              | Khi `true`, ngăn user và project settings định nghĩa các quy tắc quyền `allow`, `ask`, hoặc `deny`. Chỉ các quy tắc trong managed settings áp dụng. Không ảnh hưởng đến danh sách cho phép server MCP; với điều đó, hãy đặt `allowManagedMcpServersOnly`                                                                              |
| `blockedMarketplaces`                          | Danh sách chặn các nguồn marketplace. Các nguồn bị chặn được kiểm tra trước khi tải xuống, nên chúng không bao giờ chạm vào hệ thống file. Xem [hạn chế marketplace quản lý](/en/plugin-marketplaces#managed-marketplace-restrictions)                                                                                               |
| `channelsEnabled`                              | Cho phép [channels](/en/channels) cho tổ chức. Xem [các kiểm soát doanh nghiệp](/en/channels#enterprise-controls) để biết mặc định trên từng gói                                                                                                                                                                                    |
| `disableSideloadFlags`                         | {/* min-version: 2.1.193 */}Từ chối các cờ CLI `--plugin-dir`, `--plugin-url`, `--agents`, và `--mcp-config` khi khởi động. Nếu không có nó, người dùng có thể vượt qua `strictKnownMarketplaces` cho một lần chạy đơn lẻ bằng cách truyền các cờ này. Xem [`disableSideloadFlags`](/en/settings#available-settings). Cần Claude Code v2.1.193 trở lên |
| `forceRemoteSettingsRefresh`                   | Khi `true`, chặn khởi động CLI cho đến khi remote managed settings được lấy mới và thoát nếu lấy thất bại. Xem [thực thi khởi động fail-closed](/en/server-managed-settings#enforce-fail-closed-startup)                                                                                                                             |
| `pluginTrustMessage`                           | Thông điệp tùy chỉnh được thêm vào cảnh báo tin cậy plugin hiển thị trước khi cài đặt                                                                                                                                                                                                                                              |
| `sandbox.filesystem.allowManagedReadPathsOnly` | Khi `true`, chỉ các đường dẫn `filesystem.allowRead` từ managed settings được tôn trọng. `denyRead` vẫn gộp từ mọi nguồn                                                                                                                                                                                                            |
| `sandbox.network.allowManagedDomainsOnly`      | Khi `true`, chỉ `allowedDomains` và các quy tắc allow `WebFetch(domain:...)` từ managed settings được tôn trọng. Các miền không được phép bị chặn tự động mà không hỏi người dùng. Các miền bị từ chối vẫn gộp từ mọi nguồn                                                                                                            |
| `strictKnownMarketplaces`                      | Kiểm soát những nguồn plugin marketplace nào người dùng có thể thêm và cài plugin từ đó. Xem [hạn chế marketplace quản lý](/en/plugin-marketplaces#managed-marketplace-restrictions)                                                                                                                                                |
| `strictPluginOnlyCustomization`                | Chặn skills, agents, hooks, và MCP server từ các nguồn user và project, để chúng chỉ có thể đến từ plugins hoặc managed settings. `true` khóa cả bốn bề mặt; một mảng như `["skills", "hooks"]` chỉ khóa những cái được nêu tên. Xem [`strictPluginOnlyCustomization`](/en/settings#strictpluginonlycustomization)                   |
| `wslInheritsWindowsSettings`                   | Khi `true` trong khóa registry HKLM của Windows hoặc `C:\Program Files\ClaudeCode\managed-settings.json`, WSL đọc managed settings từ chuỗi chính sách Windows bổ sung cho `/etc/claude-code`. Xem [Các file settings](/en/settings#settings-files)                                                                                  |

`disableBypassPermissionsMode` thường được đặt trong managed settings để thực thi chính sách của tổ chức, nhưng nó hoạt động từ bất kỳ phạm vi nào. Một người dùng có thể đặt nó trong settings riêng để tự khóa mình khỏi chế độ bypass.

<Note>
  Trên gói Team và Enterprise, một Owner bật hoặc tắt [Remote Control](/en/remote-control) và [web sessions](/en/claude-code-on-the-web) trên toàn tổ chức trong [Claude Code admin settings](https://claude.ai/admin-settings/claude-code). Remote Control còn có thể được tắt theo từng thiết bị bằng thiết lập [`disableRemoteControl`](/en/settings#available-settings). Web sessions không có khóa managed settings theo từng thiết bị.
</Note>

## Thứ tự ưu tiên của settings

Quy tắc quyền tuân theo cùng [thứ tự ưu tiên của settings](/en/settings#settings-precedence) như mọi thiết lập Claude Code khác:

1. **Managed settings**: không thể bị ghi đè bởi bất kỳ cấp nào khác, kể cả các đối số dòng lệnh
2. **Đối số dòng lệnh**: ghi đè tạm thời cho phiên
3. **Local project settings** (`.claude/settings.local.json`)
4. **Shared project settings** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Nếu một công cụ bị từ chối ở bất kỳ cấp nào, không cấp nào khác có thể cho phép nó. Ví dụ, một deny trong managed settings không thể bị ghi đè bởi `--allowedTools`, và `--disallowedTools` có thể thêm các hạn chế vượt quá những gì managed settings định nghĩa.

Điều tương tự đúng giữa các phạm vi settings: nếu user settings cho phép một quyền và project settings từ chối nó, quy tắc deny sẽ chặn nó. Điều ngược lại cũng đúng: một deny cấp người dùng chặn một allow cấp dự án, vì các quy tắc deny từ bất kỳ phạm vi nào được đánh giá trước các quy tắc allow.

Các host nhúng (embedding host) có thể cung cấp chính sách quản lý bổ sung qua tùy chọn `managedSettings` của SDK khi [`parentSettingsBehavior`](/en/settings#settings-precedence) được đặt thành `"merge"`; các giá trị của bên nhúng có thể siết chặt chính sách nhưng không thể nới lỏng.

## Quy tắc allow của dự án và độ tin cậy workspace

Các quy tắc `permissions.allow` và các mục `permissions.additionalDirectories` trong `.claude/settings.json` của một dự án cấp quyền năng, nên Claude Code chỉ áp dụng chúng sau khi bạn chấp nhận [hộp thoại độ tin cậy workspace](/en/security#additional-safeguards) cho workspace đó. Trước khi đó, Claude Code đọc các quy tắc nhưng không áp dụng chúng. Hộp thoại tin cậy liệt kê các quy tắc allow và thư mục bổ sung mà thư mục sẽ cấp để bạn có thể xem xét trước khi chấp nhận. Các quy tắc `deny` và `ask` không bị ảnh hưởng, vì chúng chỉ hạn chế.

Claude Code lưu độ tin cậy theo từng workspace, khóa trên gốc kho git hoặc, ngoài một kho, thư mục bạn khởi chạy Claude Code từ đó. Khi bạn khởi động trong thư mục home, độ tin cậy chỉ được giữ cho phiên hiện tại và không được ghi ra đĩa; xem ghi chú [additional safeguards](/en/security#additional-safeguards). Việc tin cậy một thư mục cha không áp dụng các quy tắc allow của một dự án lồng bên trong.

`.claude/settings.local.json` là file riêng của bạn, nên kiểm tra độ tin cậy workspace thường không áp dụng cho nó. Khi một kho có thể đã cung cấp file, chẳng hạn khi nó được commit vào git hoặc `.claude` là một symlink, các quy tắc allow và thư mục bổ sung của nó sẽ đi qua kiểm tra tin cậy như project settings.

Các quy tắc allow và thư mục bổ sung trong `.claude/settings.local.json` cũng áp dụng mà không cần độ tin cậy workspace trong hai trường hợp:

* Thư mục bạn khởi chạy Claude Code từ đó không nằm trong một kho git.
* Phiên chạy trong home cấu hình của riêng bạn: thư mục home hoặc bất kỳ thư mục nào có thư mục con `.claude` mà bạn đã đặt làm [`CLAUDE_CONFIG_DIR`](/en/env-vars).

Trong cả hai trường hợp, file là do bạn tạo chứ không phải do một kho có thể cung cấp, và một `.claude/settings.local.json` được commit vào kho vẫn cần độ tin cậy workspace. Các phiên bản 2.1.196 đến 2.1.199 coi file là do kho cung cấp trong các workspace đó, bỏ qua các quy tắc allow của nó, và in cảnh báo [`this workspace has not been trusted`](/en/errors#workspace-has-not-been-trusted) ra stderr. Hai ngoại lệ ở trên khớp với v2.1.195 và cũ hơn và đã được khôi phục trong v2.1.200.

Cũng kể từ v2.1.200, một workspace mà các quy tắc allow hoặc thư mục bổ sung vẫn chưa được áp dụng, nhưng chưa bao giờ hiển thị hộp thoại tin cậy vì một thư mục cha đã được tin cậy, sẽ hiển thị hộp thoại vào lần tiếp theo bạn khởi động Claude Code ở đó một cách tương tác. Hộp thoại cung cấp hai lựa chọn:

* **Yes, I trust this folder**: lưu độ tin cậy cho workspace đó và áp dụng các quy tắc trong cùng phiên.
* **No, continue without these permissions**: tiếp tục làm việc với các quy tắc đó bị bỏ qua. Hộp thoại lại xuất hiện trong phiên tiếp theo.

Trong [chế độ không tương tác](/en/headless) với `-p`, không có hộp thoại nào xuất hiện và các quy tắc vẫn bị bỏ qua.

## Các cấu hình mẫu

[Kho này](https://github.com/anthropics/claude-code/tree/main/examples/settings) bao gồm các cấu hình settings khởi đầu cho các kịch bản triển khai thông dụng. Dùng chúng làm điểm khởi đầu và điều chỉnh cho phù hợp với nhu cầu của bạn.

## Xem thêm

* [Settings](/en/settings): tham chiếu cấu hình đầy đủ bao gồm bảng thiết lập quyền
* [Cấu hình chế độ auto](/en/auto-mode-config): cho bộ phân loại của chế độ auto biết hạ tầng nào tổ chức của bạn tin cậy
* [Sandboxing](/en/sandboxing): cô lập hệ thống file và mạng ở cấp hệ điều hành cho các lệnh Bash
* [Authentication](/en/authentication): thiết lập quyền truy cập của người dùng vào Claude Code
* [Security](/en/security): các biện pháp bảo vệ an ninh và thực hành tốt nhất
* [Hooks](/en/hooks-guide): tự động hóa quy trình và mở rộng việc đánh giá quyền
