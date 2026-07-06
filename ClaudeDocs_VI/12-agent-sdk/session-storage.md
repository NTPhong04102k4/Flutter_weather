> Nguồn: https://code.claude.com/docs/en/agent-sdk/session-storage.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Lưu phiên (session) vào bộ nhớ ngoài

> Sao chép (mirror) bản ghi phiên sang S3, Redis, hoặc backend của riêng bạn để bất kỳ host nào cũng có thể tiếp tục (resume) chúng.

Theo mặc định, SDK ghi bản ghi phiên (transcript) vào các file JSONL nằm dưới `~/.claude/projects/` trên hệ thống file cục bộ. Một adapter `SessionStore` cho phép bạn sao chép các bản ghi đó sang backend của riêng bạn, chẳng hạn như S3, Redis, hoặc một cơ sở dữ liệu, để một phiên được tạo trên một host có thể được tiếp tục trên một host khác.

Các lý do phổ biến để dùng session store:

* **Triển khai đa host (multi-host).** Các hàm serverless, worker tự động co giãn (autoscaled), và các CI runner không dùng chung hệ thống file. Một store dùng chung cho phép bất kỳ bản sao (replica) nào cũng tiếp tục được bất kỳ phiên nào.
* **Độ bền (durability).** Các container cục bộ có tính tạm thời (ephemeral). Một store được backend bởi S3 hoặc cơ sở dữ liệu sẽ sống sót qua các lần khởi động lại và triển khai lại.
* **Tuân thủ và kiểm toán (compliance and audit).** Giữ các bản ghi trong bộ nhớ mà bạn đã quản trị, với quy tắc lưu giữ (retention), mã hóa và kiểm soát truy cập của riêng bạn.

## Giao diện `SessionStore`

Một `SessionStore` là một object có hai phương thức bắt buộc, `append` và `load`, cùng ba phương thức tùy chọn. SDK gọi `append` để ghi các mục bản ghi (transcript entries) trong khi thực hiện query và gọi `load` để đọc lại chúng khi resume.

<CodeGroup>
  ```typescript TypeScript theme={null}
  // Exported from @anthropic-ai/claude-agent-sdk as
  // SessionStore, SessionKey, SessionStoreEntry.

  type SessionKey = {
    projectKey: string;
    sessionId: string;
    subpath?: string;
  };

  type SessionStore = {
    // Required
    append(key: SessionKey, entries: SessionStoreEntry[]): Promise<void>;
    load(key: SessionKey): Promise<SessionStoreEntry[] | null>;

    // Optional
    listSessions?(
      projectKey: string,
    ): Promise<Array<{ sessionId: string; mtime: number }>>;
    delete?(key: SessionKey): Promise<void>;
    listSubkeys?(key: {
      projectKey: string;
      sessionId: string;
    }): Promise<string[]>;
  };
  ```

  ```python Python theme={null}
  # Exported from claude_agent_sdk as
  # SessionStore, SessionKey, SessionStoreEntry.

  class SessionKey(TypedDict):
      project_key: str
      session_id: str
      subpath: NotRequired[str]

  class SessionStore(Protocol):
      # Required
      async def append(
          self, key: SessionKey, entries: list[SessionStoreEntry]
      ) -> None: ...
      async def load(self, key: SessionKey) -> list[SessionStoreEntry] | None: ...

      # Optional — omit or raise NotImplementedError
      async def list_sessions(
          self, project_key: str
      ) -> list[SessionStoreListEntry]: ...
      async def delete(self, key: SessionKey) -> None: ...
      async def list_subkeys(self, key: SessionListSubkeysKey) -> list[str]: ...
  ```
</CodeGroup>

`SessionKey` định địa chỉ cho một bản ghi. `projectKey` là một cách mã hóa ổn định, an toàn với hệ thống file của thư mục làm việc; `sessionId` là UUID của phiên; và `subpath` được thiết lập khi mục đó thuộc về một bản ghi subagent hoặc file sidecar chứ không phải cuộc hội thoại chính. Hãy xem `subpath` như một hậu tố khóa (key suffix) mờ (opaque); nó tuân theo bố cục lưu trên đĩa, ví dụ `subagents/agent-<id>`. Khi `subpath` không được định nghĩa thì khóa đó trỏ tới bản ghi chính.

| Phương thức    | Bắt buộc | Được gọi khi                                                                                                                                                                                    |
| :------------- | :------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `append`       | Có       | Sau mỗi lô (batch) các mục bản ghi được ghi cục bộ. Các mục là các object an toàn với JSON, mỗi mục một dòng trong file JSONL cục bộ.                                                          |
| `load`         | Có       | Một lần trước khi subprocess được sinh ra, khi `resume` được thiết lập. Trả về `null` nếu phiên không xác định.                                                                               |
| `listSessions` | Không    | Bởi `listSessions({ sessionStore })` và bởi `query()`/`startup()` với `continue: true`. Nếu không được định nghĩa, các lệnh gọi đó sẽ ném lỗi (throw).                                        |
| `delete`       | Không    | Bởi `deleteSession({ sessionStore })`. Xóa khóa chính (không có `subpath`) phải lan tỏa (cascade) tới tất cả các subkey của phiên đó. Nếu không được định nghĩa, việc xóa là no-op, phù hợp với các backend chỉ-thêm (append-only). |
| `listSubkeys`  | Không    | Trong khi resume, để phát hiện các bản ghi subagent. Nếu không được định nghĩa, chỉ có bản ghi chính được khôi phục.                                                                          |

## Bắt đầu nhanh

SDK cung cấp sẵn một `InMemorySessionStore` cho việc phát triển và kiểm thử. Ví dụ dưới đây chạy một query với store được gắn kèm, thu lấy session ID từ message kết quả, rồi resume từ store trong một lệnh gọi `query()` thứ hai. Lệnh gọi thứ hai truyền cùng một instance store cộng với `resume`, nên SDK tải bản ghi từ store thay vì từ hệ thống file cục bộ:

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query, InMemorySessionStore } from "@anthropic-ai/claude-agent-sdk";

  const store = new InMemorySessionStore();

  let sessionId: string | undefined;
  for await (const message of query({
    prompt: "List the TypeScript files under src/",
    options: { sessionStore: store },
  })) {
    if (message.type === "result") {
      sessionId = message.session_id;
    }
  }

  // Resume from the store. The agent has full context from the first call.
  for await (const message of query({
    prompt: "Summarize what those files do",
    options: { sessionStore: store, resume: sessionId },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import (
      ClaudeAgentOptions,
      InMemorySessionStore,
      ResultMessage,
      query,
  )

  store = InMemorySessionStore()


  async def main():
      session_id = None
      async for message in query(
          prompt="List the Python files under src/",
          options=ClaudeAgentOptions(session_store=store),
      ):
          if isinstance(message, ResultMessage):
              session_id = message.session_id

      # Resume from the store. The agent has full context from the first call.
      async for message in query(
          prompt="Summarize what those files do",
          options=ClaudeAgentOptions(session_store=store, resume=session_id),
      ):
          if isinstance(message, ResultMessage) and message.subtype == "success":
              print(message.result)


  asyncio.run(main())
  ```
</CodeGroup>

Query thứ hai in ra bản tóm tắt của các file từ query đầu tiên, cho thấy agent đã resume với đầy đủ ngữ cảnh từ store.

## Viết adapter của riêng bạn

Cài đặt `append` và `load` cho backend của bạn. Thêm `listSessions`, `delete`, và `listSubkeys` nếu bạn muốn `listSessions()`, `deleteSession()`, và resume subagent hoạt động được với store.

Các mục truyền vào `append` được định kiểu là `SessionStoreEntry` (một object `{ type: string; ... }`). Hãy xem chúng như các giá trị an toàn với JSON, mờ (opaque): lưu chúng theo đúng thứ tự và trả chúng về từ `load` theo cùng thứ tự đó. `load` phải trả về các mục sâu-bằng (deep-equal) với những gì đã được append; không yêu cầu tuần tự hóa (serialization) byte-bằng, nên các backend như Postgres `jsonb` vốn sắp xếp lại các khóa object vẫn ổn.

## Các cài đặt tham chiếu

Kho lưu trữ (repository) của TypeScript SDK bao gồm các adapter tham chiếu có thể chạy được cho S3, Redis, và Postgres dưới [`examples/session-stores/`](https://github.com/anthropics/claude-agent-sdk-typescript/tree/main/examples/session-stores). Chúng không được xuất bản lên npm; hãy sao chép file `src/` mà bạn cần vào dự án của bạn và cài đặt client backend tương ứng.

| Adapter                                                                                                                        | Client backend       | Mô hình lưu trữ                                                              |
| :----------------------------------------------------------------------------------------------------------------------------- | :------------------- | :-------------------------------------------------------------------------- |
| [`S3SessionStore`](https://github.com/anthropics/claude-agent-sdk-typescript/tree/main/examples/session-stores/s3)             | `@aws-sdk/client-s3` | Một file phần (part file) JSONL cho mỗi `append()`; `load()` liệt kê, sắp xếp và nối lại. |
| [`RedisSessionStore`](https://github.com/anthropics/claude-agent-sdk-typescript/tree/main/examples/session-stores/redis)       | `ioredis`            | Danh sách `RPUSH`/`LRANGE` cho mỗi bản ghi, cộng với một chỉ mục phiên dạng sorted-set. |
| [`PostgresSessionStore`](https://github.com/anthropics/claude-agent-sdk-typescript/tree/main/examples/session-stores/postgres) | `pg`                 | Một hàng cho mỗi mục trong bảng `jsonb`, được sắp thứ tự bởi `BIGSERIAL`.    |

Mỗi adapter nhận vào một instance client đã được cấu hình sẵn, nên bạn kiểm soát thông tin đăng nhập (credentials), TLS, region, và pooling. Ví dụ, với S3:

```typescript TypeScript theme={null}
import { query } from "@anthropic-ai/claude-agent-sdk";
import { S3Client } from "@aws-sdk/client-s3";
import { S3SessionStore } from "./S3SessionStore"; // copied from examples/session-stores/s3

const store = new S3SessionStore({
  bucket: "my-claude-sessions",
  prefix: "transcripts",
  client: new S3Client({ region: "us-east-1" }),
});

for await (const message of query({
  prompt: "Hello!",
  options: { sessionStore: store },
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}

// Later, possibly on a different host:
for await (const message of query({
  prompt: "Continue where we left off",
  options: { sessionStore: store, resume: "previous-session-id" },
})) {
  // ...
}
```

### Kiểm định adapter của bạn

Cả hai SDK đều cung cấp một bộ kiểm tra tính tuân thủ (conformance suite) khẳng định giao ước hành vi (behavioral contract) mà `append`, `load`, và các phương thức tùy chọn phải thỏa mãn. Các bài kiểm tra cho những phương thức tùy chọn sẽ tự động bỏ qua khi các phương thức đó không được cài đặt.

Trong TypeScript, sao chép [`shared/conformance.ts`](https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/examples/session-stores/shared/conformance.ts) từ thư mục ví dụ vào bộ kiểm thử của bạn. Trong Python, bộ kiểm tra đó đi kèm trong package:

```python Python theme={null}
import pytest
from claude_agent_sdk.testing import run_session_store_conformance


@pytest.mark.asyncio
async def test_my_store_conformance():
    await run_session_store_conformance(MyRedisStore)
```

## Ghi chú về hành vi

### Kiến trúc ghi kép (dual-write)

Store là một bản sao (mirror), không phải bản thay thế. Subprocess Claude Code luôn ghi vào đĩa cục bộ trước; sau đó SDK chuyển tiếp mỗi lô tới `append()`. Nếu bạn muốn bản sao cục bộ có tính tạm thời, hãy trỏ `CLAUDE_CONFIG_DIR` tới một thư mục tạm trong `options.env`. Vì bản sao (mirror) phụ thuộc vào các lần ghi cục bộ, `sessionStore` không thể kết hợp với `persistSession: false`; SDK sẽ ném lỗi nếu bạn thiết lập cả hai. Nó cũng ném lỗi nếu kết hợp với `enableFileCheckpointing`, vì các blob sao lưu lịch sử file (file-history backup) được ghi trực tiếp vào đĩa cục bộ và không được sao chép sang store.

### Việc ghi vào bản sao là nỗ-lực-tốt-nhất (best-effort)

Nếu `append()` bị từ chối (reject), SDK sẽ thử lại lô đó tối đa hai lần nữa với một khoảng lùi (backoff) ngắn, tổng cộng tối đa ba lần thử. Một lệnh gọi bị hết thời gian (time out) sẽ không được thử lại, vì lệnh gọi ban đầu vẫn có thể đã tới nơi. Nếu lô vẫn thất bại, lỗi được ghi log, một message `{ type: "system", subtype: "mirror_error" }` được phát ra vào iterator, lô bị bỏ đi, và query tiếp tục. Bản ghi cục bộ đã bền vững trên đĩa, nên một sự cố của store không làm gián đoạn agent hay mất dữ liệu cục bộ. Hãy giám sát `mirror_error` nếu bạn cần phát hiện mất dữ liệu ở store. Vì một lô được thử lại có thể chuyển giao lại các mục đã tới nơi, hãy khử trùng lặp (deduplicate) theo `entry.uuid` trong phần cài đặt `append()` của bạn.

### `getSessionMessages` trả về chuỗi sau nén (post-compaction chain)

`getSessionMessages({ sessionStore })` trả về chuỗi message liên kết mà agent sẽ thấy khi resume. Sau khi tự động nén (auto-compaction), các lượt trước đó được thay thế bằng một bản tóm tắt, nên một phiên mà store giữ 503 mục thô có thể trả về 18 message từ `getSessionMessages`. Để lấy toàn bộ lịch sử thô, bao gồm các lượt trước khi nén và các mục siêu dữ liệu (metadata), hãy gọi trực tiếp `store.load(key)`.

### `forkSession` không phải là bản sao theo byte

`forkSession({ sessionStore })` đọc các mục nguồn, ghi lại mọi trường `sessionId` và ánh xạ lại (remap) các UUID của message, rồi append các mục đã biến đổi dưới một khóa mới. Một bản sao ở cấp adapter hoặc một lối tắt `CopyObject` sẽ tạo ra một bản ghi vẫn tham chiếu tới session ID cũ, nên SDK không dùng cách đó.

### Bản ghi subagent

Các bản ghi subagent được sao chép dưới `subpath: "subagents/agent-<id>"`. `listSubagents({ sessionStore })` yêu cầu adapter cài đặt `listSubkeys`; `getSubagentMessages({ sessionStore })` dùng nó khi có sẵn nhưng quay về (fall back) dùng trực tiếp subpath khi nó không được định nghĩa. Resume cũng gọi `listSubkeys` để khôi phục các file subagent; nếu không có nó, chỉ bản ghi chính được hiện thực hóa.

### Lưu giữ (retention)

SDK không bao giờ tự xóa khỏi store của bạn. Việc lưu giữ là trách nhiệm của adapter: hãy cài đặt TTL, các chính sách vòng đời (lifecycle) của S3, hoặc dọn dẹp theo lịch tùy theo yêu cầu tuân thủ của bạn. Các bản ghi cục bộ dưới `CLAUDE_CONFIG_DIR` được quét dọn độc lập bởi thiết lập `cleanupPeriodDays`.

## Được hỗ trợ trên

Các hàm SDK sau đây chấp nhận một tùy chọn `sessionStore` và vận hành với store thay vì hệ thống file cục bộ khi nó được cung cấp:

* [`query()`](/en/agent-sdk/typescript#query)
* [`startup()`](/en/agent-sdk/typescript#startup)
* [`listSessions()`](/en/agent-sdk/typescript#listsessions)
* [`getSessionInfo()`](/en/agent-sdk/typescript#getsessioninfo)
* [`getSessionMessages()`](/en/agent-sdk/typescript#getsessionmessages)
* [`renameSession()`](/en/agent-sdk/typescript#renamesession)
* [`tagSession()`](/en/agent-sdk/typescript#tagsession)
* [`deleteSession()`](/en/agent-sdk/typescript)
* [`forkSession()`](/en/agent-sdk/typescript)
* [`listSubagents()`](/en/agent-sdk/typescript)
* [`getSubagentMessages()`](/en/agent-sdk/typescript)

## Tài nguyên liên quan

* [Làm việc với các phiên (sessions)](/en/agent-sdk/sessions): Tiếp tục (continue), resume, và fork mà không cần store tùy chỉnh
* [Host SDK](/en/agent-sdk/hosting): Các mẫu triển khai cho môi trường đa host
* [`Options` của TypeScript](/en/agent-sdk/typescript#options): Tham chiếu tùy chọn đầy đủ
* [`examples/session-stores/`](https://github.com/anthropics/claude-agent-sdk-typescript/tree/main/examples/session-stores): Các adapter tham chiếu S3, Redis, và Postgres có thể chạy được
