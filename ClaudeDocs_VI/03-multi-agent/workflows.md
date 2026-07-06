> Nguồn: https://code.claude.com/docs/en/workflows.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Điều phối subagent ở quy mô lớn với dynamic workflows

> Dynamic workflows điều phối nhiều subagent từ một script do Claude viết và bạn có thể chạy lại. Dùng chúng cho việc rà soát toàn codebase, di trú lớn, và nghiên cứu được kiểm chứng chéo.

{/* plan-availability: feature=workflows plans=pro,max,team,enterprise providers=all */}

<Note>
  Dynamic workflows yêu cầu Claude Code v2.1.154 trở lên và có sẵn trên mọi gói trả phí, với quyền truy cập Anthropic API, và trên Amazon Bedrock, Agent Platform của Google Cloud, và Microsoft Foundry. Trên gói Pro, hãy bật chúng từ hàng Dynamic workflows trong `/config`.
</Note>

Dynamic workflow là một script JavaScript điều phối các [subagent](/en/sub-agents) ở quy mô lớn. Claude viết script cho tác vụ bạn mô tả, và một runtime thực thi nó ở chế độ nền trong khi phiên của bạn vẫn phản hồi.

Hãy dùng đến một workflow khi một tác vụ cần nhiều agent hơn mức một cuộc hội thoại có thể điều phối, hoặc khi bạn muốn việc điều phối được mã hóa thành một script mà bạn có thể đọc và chạy lại. Ví dụ bao gồm một đợt quét bug toàn codebase, một cuộc di trú 500 file, một câu hỏi nghiên cứu cần các nguồn được kiểm chứng chéo với nhau, và một kế hoạch khó đáng được phác từ nhiều góc độ độc lập trước khi bạn cam kết theo một cái.

## Khi nào dùng một workflow

[Subagent](/en/sub-agents), [skill](/en/skills), [agent teams](/en/agent-teams), và workflow đều có thể chạy một tác vụ nhiều bước. Khác biệt nằm ở chỗ ai giữ kế hoạch:

|                                    | Subagent                        | Skill                           | Agent teams                                   | Workflow                              |
| :--------------------------------- | :------------------------------ | :------------------------------ | :-------------------------------------------- | :------------------------------------ |
| Nó là gì                           | Một worker do Claude tạo        | Chỉ dẫn Claude làm theo         | Một agent trưởng nhóm giám sát các phiên ngang hàng | Một script do runtime thực thi        |
| Ai quyết định chạy gì tiếp theo    | Claude, từng lượt               | Claude, làm theo prompt         | Agent trưởng nhóm, từng lượt                  | Script                                |
| Kết quả trung gian nằm ở đâu       | Context window của Claude       | Context window của Claude       | Một danh sách công việc chung                 | Biến của script                       |
| Cái gì có thể lặp lại              | Định nghĩa worker               | Chỉ dẫn                         | Định nghĩa nhóm                               | Chính việc điều phối                  |
| Quy mô                             | Vài tác vụ được ủy quyền mỗi lượt | Giống subagent                | Một nhúm phiên ngang hàng chạy lâu           | Hàng chục đến hàng trăm agent mỗi lần chạy |
| Gián đoạn                          | Khởi động lại lượt              | Khởi động lại lượt              | Các thành viên tiếp tục chạy                  | Có thể tiếp tục (resumable) trong cùng phiên |

Một workflow chuyển kế hoạch vào code. Với subagent, skill, và agent teams, Claude là bộ điều phối: nó quyết định từng lượt cần tạo hay giao gì tiếp theo, và mọi kết quả đều rơi vào một context window. Một workflow script tự giữ vòng lặp, các nhánh, và các kết quả trung gian, nên ngữ cảnh của Claude chỉ giữ câu trả lời cuối cùng.

Chuyển kế hoạch vào code cũng cho phép một workflow áp dụng một mẫu chất lượng có thể lặp lại, không chỉ chạy nhiều agent hơn: nó có thể để các agent độc lập rà soát đối kháng phát hiện của nhau trước khi chúng được báo cáo, hoặc phác một kế hoạch từ nhiều góc độ và cân nhắc chúng với nhau, để bạn nhận được kết quả đáng tin cậy hơn so với một lần chạy đơn.

## Chạy một workflow đóng gói sẵn (bundled)

Cách nhanh nhất để thấy một workflow hoạt động là chạy `/deep-research`, [workflow dựng sẵn](#bundled-workflows) mà Claude Code có sẵn để điều tra một câu hỏi trên nhiều nguồn. Bạn sẽ thấy các agent làm việc qua một chuỗi giai đoạn (phase) ở chế độ nền trong khi phiên của bạn vẫn rảnh, và nhận được một báo cáo ở cuối thay vì một transcript từng lượt.

<Steps>
  <Step title="Chạy workflow">
    Chạy `/deep-research` với một câu hỏi bạn muốn điều tra. Nó tỏa ra (fan out) các tìm kiếm web trên nhiều góc độ, tải và kiểm chứng chéo các nguồn nó tìm được, và tổng hợp một báo cáo có trích dẫn.

    ```text theme={null}
    /deep-research What changed in the Node.js permission model between v20 and v22?
    ```
  </Step>

  <Step title="Cho phép workflow">
    Claude Code hỏi có cho phép workflow hay không. Chọn **Yes** để tiếp tục. Lời nhắc chính xác phụ thuộc vào chế độ quyền của bạn. Xem [Phê duyệt kế hoạch trước khi nó chạy](#approve-the-plan-before-it-runs) để biết các lựa chọn theo từng chế độ.
  </Step>

  <Step title="Theo dõi tiến độ">
    Lần chạy bắt đầu ở chế độ nền. Chạy `/workflows`, dùng phím mũi tên để chọn lần chạy, và nhấn Enter để mở khung xem tiến độ:

    ```text theme={null}
    /workflows
    ```

    Khung xem hiển thị từng giai đoạn với số lượng agent, tổng token, và thời gian đã trôi qua. Đi sâu vào bất kỳ giai đoạn nào để xem các agent của nó và mỗi agent tìm được gì. Xem [Theo dõi lần chạy](#watch-the-run) để biết bộ điều khiển đầy đủ.

    Bạn cũng có thể theo dõi từ bảng nhiệm vụ (task panel) bên dưới ô nhập: một dòng tóm tắt tiến độ xuất hiện ở đó trong khi lần chạy đang diễn ra. Nhấn mũi tên xuống để tập trung vào nó, rồi Enter để mở rộng.
  </Step>

  <Step title="Đọc báo cáo">
    Khi lần chạy kết thúc, báo cáo rơi vào phiên của bạn. Nó trích dẫn các nguồn mà mỗi luận điểm bắt nguồn, với các luận điểm không sống sót qua kiểm chứng chéo đã được lọc bỏ.

    {/* min-version: 2.1.196 */}Kể từ v2.1.196, khi các agent kiểm chứng không thể kiểm tra một luận điểm, chẳng hạn sau một giới hạn tốc độ (rate limit) hay lỗi API, báo cáo liệt kê luận điểm đó là chưa được xác minh (unverified) thay vì tính nó là đã bị bác bỏ.
  </Step>
</Steps>

Để chạy một workflow cho tác vụ của riêng bạn, [hãy để Claude viết một cái](#have-claude-write-a-workflow), và một khi một lần chạy làm đúng điều bạn muốn, bạn có thể [lưu nó](#save-the-workflow-for-reuse) thành một lệnh của riêng bạn.

### Các workflow đóng gói sẵn

Claude Code có sẵn `/deep-research` như một workflow dựng sẵn:

| Lệnh                        | Nó làm gì                                                                                                                                                                                                                                                                                                            |
| :-------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/deep-research <question>` | Tỏa ra các tìm kiếm web về một câu hỏi trên nhiều góc độ, tải và kiểm chứng chéo các nguồn nó tìm được, bỏ phiếu (vote) cho từng luận điểm, và trả về một báo cáo có trích dẫn với các luận điểm không sống sót qua kiểm chứng chéo đã được lọc bỏ. Yêu cầu [công cụ WebSearch](/en/tools-reference#websearch-tool-behavior) phải có sẵn |

[Các workflow bạn tự lưu](#save-the-workflow-for-reuse) trở thành lệnh theo cùng cách và xuất hiện trong autocomplete `/` bên cạnh các workflow dựng sẵn.

### Theo dõi lần chạy

Workflow chạy ở chế độ nền, nên phiên vẫn phản hồi trong khi các agent làm việc. Chạy `/workflows` bất cứ lúc nào để liệt kê các workflow đang chạy và đã hoàn thành, rồi chọn một cái để mở khung xem tiến độ của nó.

```text theme={null}
/workflows
```

Khung xem tiến độ hiển thị từng giai đoạn với số lượng agent, tổng token, và thời gian đã trôi qua. Chân trang liệt kê phím cho từng hành động:

| Phím           | Hành động                                                                                                |
| :------------- | :------------------------------------------------------------------------------------------------------ |
| `↑` / `↓`      | Chọn một giai đoạn hoặc agent                                                                           |
| `Enter` hoặc `→` | Đi sâu vào giai đoạn đã chọn, rồi vào một agent để đọc prompt, các lệnh gọi công cụ gần đây, và kết quả của nó |
| `Esc`          | Lùi ra một cấp                                                                                          |
| `j` / `k`      | Cuộn trong phần chi tiết agent khi nó tràn                                                              |
| `f`            | {/* min-version: 2.1.186 */}Lọc danh sách agent trong giai đoạn đã chọn theo trạng thái. Nhấn lại để luân phiên |
| `p`            | Tạm dừng hoặc tiếp tục lần chạy                                                                         |
| `x`            | Dừng agent đã chọn, hoặc dừng toàn bộ workflow khi tiêu điểm ở lần chạy                                  |
| `r`            | Khởi động lại agent đang chạy đã chọn                                                                   |
| `s`            | [Lưu](#save-the-workflow-for-reuse) script của lần chạy thành một lệnh                                  |

## Để Claude viết một workflow

Bạn có thể để Claude viết một workflow cho tác vụ của bạn theo hai cách:

* [Yêu cầu một workflow](#ask-for-a-workflow-in-your-prompt) trong prompt của bạn, hoặc bằng lời của chính bạn hoặc bằng cách thêm từ khóa `ultracode`, và Claude viết một cái cho tác vụ.
* [Để Claude quyết định với ultracode](#let-claude-decide-with-ultracode): đặt `/effort ultracode` và Claude lập một workflow cho mọi tác vụ đáng kể trong phiên.

Bạn cũng có thể chạy một lệnh workflow đã tồn tại: một [workflow đóng gói sẵn](#bundled-workflows) như `/deep-research`, hoặc một cái bạn đã [lưu](#save-the-workflow-for-reuse).

### Yêu cầu một workflow trong prompt của bạn

Để chạy một tác vụ đơn lẻ dưới dạng một workflow mà không thay đổi mức effort của phiên, hãy thêm từ khóa `ultracode` vào prompt của bạn. Yêu cầu bằng lời của chính bạn, ví dụ "use a workflow" hoặc "run a workflow", cũng được: Claude coi một yêu cầu trực tiếp là cùng một sự chọn tham gia (opt-in). Trước v2.1.160 từ khóa kích hoạt theo nghĩa đen là `workflow`; các yêu cầu bằng ngôn ngữ tự nhiên hoạt động trong cả hai phiên bản.

```text theme={null}
ultracode: audit every API endpoint under src/routes/ for missing auth checks
```

Claude Code làm nổi bật từ khóa trong đầu vào của bạn và Claude viết một workflow script cho tác vụ thay vì làm việc qua nó từng lượt. Nếu bạn không có ý định bắt đầu một workflow, hãy nhấn `Option+W` trên macOS hoặc `Alt+W` trên Windows và Linux để hủy phần nổi bật cho prompt này, hoặc nhấn backspace khi con trỏ ở ngay sau từ khóa được làm nổi bật. Để ngăn từ khóa kích hoạt hoàn toàn, hãy tắt Ultracode keyword trigger trong `/config`.

Nếu lần chạy làm đúng điều bạn muốn, bạn có thể [lưu nó thành một lệnh](#save-the-workflow-for-reuse) sau đó.

Nếu bạn đã có một bộ điều phối được xây bằng cách khác, chẳng hạn một thư mục chứa các prompt subagent hoặc một skill tỏa công việc ra, bạn có thể chỉ Claude đến nó và yêu cầu một workflow làm điều tương tự.

### Để Claude quyết định với ultracode

Ultracode là một cài đặt của Claude Code kết hợp mức [nỗ lực suy luận (reasoning effort)](/en/model-config#adjust-effort-level) `xhigh` với việc điều phối workflow tự động. Khi bật nó, Claude lập một workflow cho mỗi tác vụ đáng kể thay vì chờ bạn yêu cầu.

```text theme={null}
/effort ultracode
```

Khi bật ultracode, Claude quyết định khi nào một tác vụ đáng để dùng một workflow. Một yêu cầu đơn lẻ có thể biến thành nhiều workflow liên tiếp: một để hiểu code, một để thực hiện thay đổi, và một để xác minh nó. Điều này áp dụng cho mọi tác vụ trong phiên, nên mỗi yêu cầu dùng nhiều token hơn và mất nhiều thời gian hơn so với các mức effort thấp hơn.

Ultracode tồn tại trong phiên hiện tại và đặt lại khi bạn bắt đầu một phiên mới. Quay lại với `/effort high` khi bạn trở về công việc thường quy. Nó có sẵn trên các model hỗ trợ mức [effort](/en/model-config#adjust-effort-level) `xhigh`; trên các model khác, menu `/effort` không cung cấp nó.

### Phê duyệt kế hoạch trước khi nó chạy

Trong CLI, lời nhắc theo từng lần chạy hiển thị các giai đoạn được lập kế hoạch và các lựa chọn này:

* **Yes, run it**: bắt đầu lần chạy
* **Yes, and don't ask again for `<name>` in `<path>`**: bắt đầu, và bỏ qua lời nhắc này cho workflow này trong dự án này từ nay về sau
* **View raw script**: đọc script trước khi quyết định
* **No**: hủy

`Ctrl+G` mở script trong trình biên tập của bạn. `Tab` cho phép bạn điều chỉnh prompt trước khi lần chạy bắt đầu.

Việc bạn có thấy lời nhắc này hay không phụ thuộc vào [chế độ quyền](/en/permission-modes) của bạn:

| Chế độ quyền                               | Khi nào bạn được nhắc                                                                                                                                    |
| :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Default, accept edits                      | Mọi lần chạy, trừ khi bạn đã chọn **Yes, and don't ask again** cho workflow đó trong dự án này                                                          |
| Auto                                       | Chỉ lần khởi chạy đầu tiên. Bất kỳ **Yes** nào cũng ghi lại sự đồng ý vào cài đặt người dùng của bạn, và các lần khởi chạy sau bắt đầu mà không nhắc. Bị bỏ qua hoàn toàn khi ultracode được bật |
| Bypass permissions, `claude -p`, Agent SDK | Không bao giờ. Lần chạy bắt đầu ngay lập tức                                                                                                             |

Trong ứng dụng Desktop, một thẻ phê duyệt hiển thị tên workflow, danh sách giai đoạn, và một lưu ý cẩn trọng về mức sử dụng token, với các hành động **Once**, **Always**, và **Deny**. Khung xem tiến độ xuất hiện trong ngăn Background tasks.

Chế độ quyền của bạn chỉ kiểm soát lời nhắc khởi chạy ở trên. Các subagent mà workflow tạo ra luôn chạy ở chế độ `acceptEdits` và thừa hưởng [danh sách công cụ cho phép (tool allowlist)](/en/settings#permission-settings) của bạn, bất kể chế độ của phiên bạn. Các chỉnh sửa file được tự động phê duyệt.

Các lệnh shell, web fetch, và công cụ MCP không nằm trong allowlist của bạn vẫn có thể nhắc bạn giữa lần chạy. Để tránh điều này trong một lần chạy dài, hãy thêm các lệnh mà các agent cần vào allowlist của bạn trước khi bắt đầu.

Trong `claude -p` và Agent SDK không có ai để nhắc, nên các lệnh gọi công cụ đi theo quy tắc quyền bạn đã cấu hình mà không có xác nhận tương tác.

### Lưu workflow để tái sử dụng

Khi Claude viết một workflow cho một tác vụ bạn sẽ lặp lại, bạn có thể lưu script của lần chạy đó thành một lệnh. Một quy trình như một cuộc rà soát bạn chạy trên mỗi nhánh sau đó chạy cùng một việc điều phối mỗi lần.

Chạy `/workflows`, chọn lần chạy bạn muốn giữ, và nhấn `s`. Trong hộp thoại lưu, Tab chuyển đổi giữa hai vị trí lưu:

* `.claude/workflows/` trong dự án của bạn: chia sẻ với mọi người clone repo
* `~/.claude/workflows/` trong thư mục home của bạn: có sẵn trong mọi dự án, chỉ bạn thấy

Nhấn Enter để lưu. Workflow chạy dưới dạng `/<name>` trong các phiên tương lai từ một trong hai vị trí.

{/* min-version: 2.1.178 */}Trong một monorepo với nhiều thư mục `.claude/`, bạn có thể giữ các workflow bên cạnh gói (package) mà chúng áp dụng. Kể từ v2.1.178, lưu vào vị trí dự án sẽ ghi vào thư mục `.claude/workflows/` gần nhất đã tồn tại giữa thư mục làm việc của bạn và gốc repository, hoặc vào gốc repository nếu chưa có cái nào. Các workflow dự án cũng nạp từ mọi `.claude/workflows/` dọc theo đường dẫn đó, và khi có nhiều hơn một cái định nghĩa cùng một tên, Claude Code chạy cái gần thư mục làm việc nhất.

Nếu một workflow dự án và một workflow cá nhân trùng tên, cái của dự án chạy.

### Truyền đầu vào cho một workflow đã lưu

Một workflow đã lưu có thể nhận đầu vào qua tham số `args`. Script đọc nó như một biến toàn cục (global) tên `args`. Dùng điều này để cung cấp một câu hỏi nghiên cứu, một danh sách đường dẫn mục tiêu, hoặc một đối tượng cấu hình tại thời điểm gọi thay vì chỉnh sửa script cho mỗi lần chạy.

Prompt sau chạy một workflow đã lưu với một danh sách số issue:

```text theme={null}
> Run /triage-issues on issues 1024, 1025, and 1030
```

Claude truyền danh sách dưới dạng dữ liệu có cấu trúc, nên script có thể gọi các phương thức mảng và đối tượng trên `args` trực tiếp mà không cần phân tích nó trước. Nếu `args` bị bỏ qua, biến toàn cục là `undefined` bên trong script.

## Các ví dụ prompt workflow

Một workflow phù hợp nhất khi tác vụ lớn hơn mức một agent có thể giữ trong ngữ cảnh, hoặc khi cùng một bước cần chạy trên nhiều mục. Các prompt dưới đây cho thấy các dạng thường gặp. Mỗi cái yêu cầu Claude viết và chạy một workflow cho tác vụ đó; bạn không tự viết script.

### Rà soát nhiều file cho cùng một vấn đề

Tỏa một agent cho mỗi file, sau đó thu thập và xác minh các phát hiện.

```text theme={null}
> use a workflow to audit every route handler under src/routes/ for missing authentication checks, and adversarially verify each finding before reporting it
```

### Tiếp tục sửa cho đến khi một kiểm tra vượt qua

Chạy một trình kiểm tra, sửa cái nào thất bại, và lặp lại cho đến khi nó vượt qua hoặc ngừng tiến bộ.

```text theme={null}
> use a workflow to run npx tsc --noEmit and keep fixing the reported errors until the type check passes or two rounds in a row make no progress
```

### Di trú nhiều file song song

Khám phá các file cần di trú, biến đổi từng file trong một bản sao cô lập để các chỉnh sửa không xung đột, và xác minh từng kết quả.

```text theme={null}
> use a workflow to migrate every component under src/components/ from styled-components to Tailwind, working on each file in its own isolated copy
```

### Rà soát mọi file đã thay đổi và viết một bản tóm tắt

Chạy một người rà soát cho mỗi file, sau đó giao tất cả phát hiện cho một agent xếp hạng và loại trùng chúng.

```text theme={null}
> use a workflow to review every file changed in this PR for correctness issues, then merge the per-file findings into one ranked summary
```

### Nghiên cứu một chủ đề trên nhiều nguồn

Tỏa các trình đọc trên các changelog, issue, và tài liệu, sau đó tổng hợp. Workflow đóng gói sẵn `/deep-research` làm điều này; bạn cũng có thể mô tả một phiên bản hẹp hơn.

```text theme={null}
> use a workflow to research how our three competitors handle rate limiting: read their public docs and recent changelog entries in parallel, then compare the approaches
```

### Tìm vấn đề cho đến khi danh sách ngừng tăng

Tiếp tục tìm kiếm theo từng vòng và dừng khi các vòng mới không tìm ra gì mới.

```text theme={null}
> use a workflow to find flaky tests in this repo: run the suite repeatedly, record which tests fail intermittently, and stop once two rounds in a row find nothing new
```

### Script đã lưu trông như thế nào

Khi bạn [lưu một workflow](#save-the-workflow-for-reuse), file trong `.claude/workflows/` giữ một khối `meta` theo sau bởi một phần thân script điều phối các subagent. Bạn thường không cần chỉnh sửa nó, nhưng đây là hình dạng của một cái nhỏ để bạn có thể nhận ra Claude đã tạo ra gì:

```javascript theme={null}
export const meta = {
  name: 'audit-routes',
  description: 'Audit every route handler for missing auth checks',
}

const found = await agent('List every .ts file under src/routes/.', {
  schema: { type: 'object', required: ['files'], properties: { files: { type: 'array', items: { type: 'string' } } } },
})

const audits = await pipeline(found.files, file =>
  agent(`Audit ${file} for missing authentication checks.`, { label: file }),
)

return audits.filter(Boolean)
```

Phần thân là JavaScript thuần với `await` ở cấp cao nhất (top-level). `agent()` tạo một subagent và `pipeline()` chạy một cái cho mỗi mục trong một danh sách. Nếu bạn muốn chỉnh sửa một script bằng tay, hãy yêu cầu Claude hướng dẫn bạn qua thay đổi, hoặc xem mục Workflow tool trong [tài liệu tham khảo Agent SDK](/en/agent-sdk/typescript) để có bộ lựa chọn đầy đủ.

## Một workflow chạy như thế nào

Runtime của workflow thực thi script trong một môi trường cô lập, tách biệt với cuộc hội thoại của bạn. Các kết quả trung gian ở lại trong biến của script thay vì rơi vào ngữ cảnh của Claude.

Mỗi lần chạy ghi script của nó ra một file dưới thư mục của phiên bạn trong `~/.claude/projects/`. Claude nhận đường dẫn khi lần chạy bắt đầu, nên bạn có thể yêu cầu nó. Bạn có thể mở file đó để đọc việc điều phối mà Claude đã viết, so sánh (diff) nó với script của một lần chạy trước, hoặc chỉnh sửa nó và yêu cầu Claude khởi chạy lại từ phiên bản đã chỉnh sửa.

Runtime theo dõi kết quả của từng agent khi lần chạy tiến triển, đó là điều khiến một lần chạy có thể [tiếp tục (resumable)](#resume-after-a-pause) trong cùng một phiên.

### Hành vi và giới hạn

Runtime áp dụng các ràng buộc sau:

| Ràng buộc                                                            | Lý do                                                                                                          |
| :------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------- |
| Không có đầu vào của người dùng giữa lần chạy                        | Chỉ các lời nhắc quyền của agent mới có thể tạm dừng một lần chạy. Để có sự phê chuẩn giữa các giai đoạn, hãy chạy mỗi giai đoạn như một workflow riêng |
| Không truy cập trực tiếp filesystem hoặc shell từ chính workflow     | Các agent đọc, ghi, và chạy lệnh. Script điều phối các agent                                                  |
| Tối đa 16 agent đồng thời, ít hơn trên máy có ít lõi CPU            | Giới hạn việc sử dụng tài nguyên cục bộ                                                                       |
| Tổng cộng 1.000 agent mỗi lần chạy                                   | Ngăn các vòng lặp chạy quá đà (runaway loop)                                                                  |

## Quản lý các lần chạy

Một khi một lần chạy bắt đầu, bạn quản lý nó từ khung xem `/workflows`, hoặc bằng cách mở rộng dòng tiến độ của nó trong task panel bên dưới ô nhập.

### Tiếp tục sau khi tạm dừng

Nếu bạn dừng một lần chạy, bạn có thể tiếp tục nó: các agent đã hoàn thành trả về kết quả được lưu bộ nhớ đệm (cached) của chúng, và phần còn lại chạy trực tiếp. Tiếp tục một lần chạy đã tạm dừng từ `/workflows` bằng cách chọn nó và nhấn `p`, hoặc yêu cầu Claude khởi chạy lại workflow với cùng script.

Tiếp tục hoạt động trong cùng một phiên Claude Code. Nếu bạn thoát Claude Code trong khi một workflow đang chạy, phiên tiếp theo sẽ bắt đầu workflow từ đầu.

### Chi phí

Một workflow tạo nhiều agent, nên một lần chạy đơn có thể dùng nhiều token hơn đáng kể so với làm việc qua cùng tác vụ trong hội thoại. Các lần chạy tính vào mức sử dụng và giới hạn tốc độ của gói bạn giống như bất kỳ phiên nào khác.

Để ước lượng mức chi tiêu trước khi cam kết cho một tác vụ lớn, hãy chạy workflow trên một lát cắt nhỏ trước: một thư mục thay vì cả repo, hoặc một câu hỏi hẹp thay vì một câu hỏi rộng. Khung xem `/workflows` hiển thị mức sử dụng token của từng agent khi lần chạy tiến triển, và bạn có thể dừng lần chạy ở đó bất cứ lúc nào mà không mất công việc đã hoàn thành. Các [giới hạn agent](#behavior-and-limits) của runtime giới hạn số agent một lần chạy đơn có thể tạo, điều này giới hạn chi phí của một script chạy quá đà.

Mỗi agent trong một workflow dùng model của phiên bạn trừ khi script định tuyến một giai đoạn sang một model khác. Để kiểm soát chi phí model:

* Kiểm tra `/model` trước một lần chạy lớn nếu bạn thường chuyển sang một model nhỏ hơn cho công việc thường quy
* Yêu cầu Claude dùng một model nhỏ hơn cho các giai đoạn không cần model mạnh nhất khi bạn mô tả tác vụ

### Tắt workflow

Workflow có sẵn trong CLI, ứng dụng Desktop, các phần mở rộng IDE, [chế độ không tương tác (non-interactive)](/en/headless) với `claude -p`, và [Agent SDK](/en/agent-sdk/overview). Cùng các cài đặt tắt áp dụng trên mọi bề mặt.

Để tắt workflow cho bản thân bạn:

* Bật/tắt Dynamic workflows tắt trong `/config`. Duy trì qua các phiên.
* Đặt `"disableWorkflows": true` trong `~/.claude/settings.json`. Duy trì qua các phiên.
* Đặt `CLAUDE_CODE_DISABLE_WORKFLOWS=1`. Được đọc lúc khởi động, nên nó áp dụng ở bất cứ nơi nào bạn đặt.

Để tắt workflow cho toàn bộ tổ chức của bạn, đặt `"disableWorkflows": true` trong [managed settings](/en/server-managed-settings), hoặc dùng công tắc trên trang [Claude Code admin settings](https://claude.ai/admin-settings/claude-code).

Khi workflow bị tắt, các lệnh workflow đóng gói sẵn không có sẵn, từ khóa `ultracode` không còn kích hoạt một lần chạy, và `ultracode` bị loại khỏi menu `/effort`.

## Tài nguyên liên quan

* [Chạy các agent song song](/en/agents): so sánh subagent, agent view, agent teams, và workflow
* [Tạo subagent tùy chỉnh](/en/sub-agents): nguyên hàm worker mà workflow điều phối
* [Quản lý chi phí](/en/costs): cách các lần chạy đa agent tính vào giới hạn sử dụng
