> Nguồn: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
> Tài liệu Claude Code — bản dịch tiếng Việt

# Nhận structured output từ agent

> Trả về JSON đã được xác thực từ các quy trình agent bằng JSON Schema, Zod hoặc Pydantic. Nhận dữ liệu có cấu trúc, an toàn về kiểu (type-safe) sau khi dùng tool nhiều lượt.

Structured output cho phép bạn định nghĩa chính xác hình dạng của dữ liệu mà bạn muốn nhận lại từ một agent. Agent có thể dùng bất kỳ tool nào nó cần để hoàn thành tác vụ, và cuối cùng bạn vẫn nhận được JSON đã được xác thực khớp với schema của mình. Định nghĩa một [JSON Schema](https://json-schema.org/understanding-json-schema/about) cho cấu trúc bạn cần, và SDK sẽ xác thực đầu ra so với nó, gửi lại prompt (re-prompt) khi không khớp. Nếu việc xác thực không thành công trong giới hạn số lần thử lại, kết quả sẽ là một lỗi thay vì dữ liệu có cấu trúc; xem [Xử lý lỗi](#error-handling).

Để đạt độ an toàn kiểu đầy đủ, hãy dùng [Zod](#type-safe-schemas-with-zod-and-pydantic) (TypeScript) hoặc [Pydantic](#type-safe-schemas-with-zod-and-pydantic) (Python) để định nghĩa schema và nhận lại các đối tượng có kiểu mạnh (strongly-typed).

## Vì sao nên dùng structured output?

Theo mặc định, agent trả về văn bản dạng tự do, phù hợp cho chat nhưng không phù hợp khi bạn cần sử dụng đầu ra theo cách lập trình. Structured output cung cấp cho bạn dữ liệu có kiểu mà bạn có thể truyền trực tiếp vào logic ứng dụng, cơ sở dữ liệu hoặc các thành phần UI.

Hãy xét một ứng dụng công thức nấu ăn (recipe app) nơi agent tìm kiếm trên web và mang về các công thức. Không có structured output, bạn nhận được văn bản dạng tự do mà bạn phải tự phân tích (parse). Với structured output, bạn định nghĩa hình dạng bạn muốn và nhận được dữ liệu có kiểu mà bạn có thể dùng trực tiếp trong ứng dụng.

<AccordionGroup>
  <Accordion title="Without structured outputs">
    ```text theme={null}
    Here's a classic chocolate chip cookie recipe!

    **Chocolate Chip Cookies**
    Prep time: 15 minutes | Cook time: 10 minutes

    Ingredients:
    - 2 1/4 cups all-purpose flour
    - 1 cup butter, softened
    ...
    ```

    Để dùng cái này trong ứng dụng của bạn, bạn sẽ phải phân tích ra tiêu đề, chuyển "15 minutes" thành một con số, tách nguyên liệu khỏi hướng dẫn, và xử lý định dạng không nhất quán giữa các phản hồi.
  </Accordion>

  <Accordion title="With structured outputs">
    ```json theme={null}
    {
      "name": "Chocolate Chip Cookies",
      "prep_time_minutes": 15,
      "cook_time_minutes": 10,
      "ingredients": [
        { "item": "all-purpose flour", "amount": 2.25, "unit": "cups" },
        { "item": "butter, softened", "amount": 1, "unit": "cup" }
        // ...
      ],
      "steps": ["Preheat oven to 375°F", "Cream butter and sugar" /* ... */]
    }
    ```

    Dữ liệu có kiểu mà bạn có thể dùng trực tiếp trong UI của mình.
  </Accordion>
</AccordionGroup>

## Bắt đầu nhanh

Để dùng structured output, hãy định nghĩa một [JSON Schema](https://json-schema.org/understanding-json-schema/about) mô tả hình dạng dữ liệu bạn muốn, rồi truyền nó vào `query()` qua tùy chọn `outputFormat` (TypeScript) hoặc tùy chọn `output_format` (Python). Khi agent hoàn tất, tin nhắn kết quả sẽ bao gồm một trường `structured_output` chứa dữ liệu đã được xác thực khớp với schema của bạn.

Ví dụ dưới đây yêu cầu agent nghiên cứu về Anthropic và trả về tên công ty, năm thành lập và trụ sở chính dưới dạng structured output.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Define the shape of data you want back
  const schema = {
    type: "object",
    properties: {
      company_name: { type: "string" },
      founded_year: { type: "number" },
      headquarters: { type: "string" }
    },
    required: ["company_name"]
  };

  for await (const message of query({
    prompt: "Research Anthropic and provide key company information",
    options: {
      outputFormat: {
        type: "json_schema",
        schema: schema
      }
    }
  })) {
    // The result message contains structured_output with validated data
    if (message.type === "result" && message.subtype === "success" && message.structured_output) {
      console.log(message.structured_output);
      // { company_name: "Anthropic", founded_year: 2021, headquarters: "San Francisco, CA" }
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

  # Define the shape of data you want back
  schema = {
      "type": "object",
      "properties": {
          "company_name": {"type": "string"},
          "founded_year": {"type": "number"},
          "headquarters": {"type": "string"},
      },
      "required": ["company_name"],
  }


  async def main():
      async for message in query(
          prompt="Research Anthropic and provide key company information",
          options=ClaudeAgentOptions(
              output_format={"type": "json_schema", "schema": schema}
          ),
      ):
          # The result message contains structured_output with validated data
          if isinstance(message, ResultMessage) and message.structured_output:
              print(message.structured_output)
              # {'company_name': 'Anthropic', 'founded_year': 2021, 'headquarters': 'San Francisco, CA'}


  asyncio.run(main())
  ```
</CodeGroup>

## Schema an toàn kiểu với Zod và Pydantic

Thay vì viết JSON Schema bằng tay, bạn có thể dùng [Zod](https://zod.dev/) (TypeScript) hoặc [Pydantic](https://docs.pydantic.dev/latest/) (Python) để định nghĩa schema của mình. Các thư viện này tạo ra JSON Schema cho bạn và cho phép bạn phân tích phản hồi thành một đối tượng có kiểu đầy đủ mà bạn có thể dùng xuyên suốt codebase với tính năng tự động hoàn thành (autocomplete) và kiểm tra kiểu.

Ví dụ dưới đây định nghĩa một schema cho kế hoạch triển khai tính năng, gồm một bản tóm tắt, danh sách các bước (mỗi bước có mức độ phức tạp), và các rủi ro tiềm ẩn. Agent lập kế hoạch cho tính năng và trả về một đối tượng `FeaturePlan` có kiểu. Sau đó bạn có thể truy cập các thuộc tính như `plan.summary` và lặp qua `plan.steps` với độ an toàn kiểu đầy đủ.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { z } from "zod";
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Define schema with Zod
  const FeaturePlan = z.object({
    feature_name: z.string(),
    summary: z.string(),
    steps: z.array(
      z.object({
        step_number: z.number(),
        description: z.string(),
        estimated_complexity: z.enum(["low", "medium", "high"])
      })
    ),
    risks: z.array(z.string())
  });

  type FeaturePlan = z.infer<typeof FeaturePlan>;

  // Convert to JSON Schema
  const schema = z.toJSONSchema(FeaturePlan);

  // Use in query
  for await (const message of query({
    prompt:
      "Plan how to add dark mode support to a React app. Break it into implementation steps.",
    options: {
      outputFormat: {
        type: "json_schema",
        schema: schema
      }
    }
  })) {
    if (message.type === "result" && message.subtype === "success" && message.structured_output) {
      // Validate and get fully typed result
      const parsed = FeaturePlan.safeParse(message.structured_output);
      if (parsed.success) {
        const plan: FeaturePlan = parsed.data;
        console.log(`Feature: ${plan.feature_name}`);
        console.log(`Summary: ${plan.summary}`);
        plan.steps.forEach((step) => {
          console.log(`${step.step_number}. [${step.estimated_complexity}] ${step.description}`);
        });
      }
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from pydantic import BaseModel
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


  class Step(BaseModel):
      step_number: int
      description: str
      estimated_complexity: str  # 'low', 'medium', 'high'


  class FeaturePlan(BaseModel):
      feature_name: str
      summary: str
      steps: list[Step]
      risks: list[str]


  async def main():
      async for message in query(
          prompt="Plan how to add dark mode support to a React app. Break it into implementation steps.",
          options=ClaudeAgentOptions(
              output_format={
                  "type": "json_schema",
                  "schema": FeaturePlan.model_json_schema(),
              }
          ),
      ):
          if isinstance(message, ResultMessage) and message.structured_output:
              # Validate and get fully typed result
              plan = FeaturePlan.model_validate(message.structured_output)
              print(f"Feature: {plan.feature_name}")
              print(f"Summary: {plan.summary}")
              for step in plan.steps:
                  print(
                      f"{step.step_number}. [{step.estimated_complexity}] {step.description}"
                  )


  asyncio.run(main())
  ```
</CodeGroup>

**Lợi ích:**

* Suy luận kiểu đầy đủ (TypeScript) và gợi ý kiểu (type hints - Python)
* Xác thực lúc chạy (runtime validation) với `safeParse()` hoặc `model_validate()`
* Thông báo lỗi tốt hơn
* Schema có thể kết hợp (composable) và tái sử dụng

## Cấu hình định dạng đầu ra

Tùy chọn `outputFormat` (TypeScript) hoặc `output_format` (Python) nhận một đối tượng với:

* `type`: Đặt thành `"json_schema"` cho structured output
* `schema`: Một đối tượng [JSON Schema](https://json-schema.org/understanding-json-schema/about) định nghĩa cấu trúc đầu ra của bạn. Bạn có thể tạo cái này từ một Zod schema với `z.toJSONSchema()` hoặc một Pydantic model với `.model_json_schema()`

SDK hỗ trợ các tính năng JSON Schema tiêu chuẩn bao gồm tất cả các kiểu cơ bản (object, array, string, number, boolean, null), `enum`, `const`, `required`, các đối tượng lồng nhau, và các định nghĩa `$ref`. Để xem danh sách đầy đủ các tính năng được hỗ trợ và các hạn chế, xem [Các hạn chế của JSON Schema](https://platform.claude.com/docs/en/build-with-claude/structured-outputs#json-schema-limitations).

## Ví dụ: Agent theo dõi TODO

Ví dụ này minh họa cách structured output hoạt động với việc dùng tool nhiều bước. Agent cần tìm các comment TODO trong codebase, sau đó tra cứu thông tin git blame cho từng cái. Nó tự động quyết định dùng tool nào (Grep để tìm kiếm, Bash để chạy lệnh git) và kết hợp các kết quả thành một phản hồi có cấu trúc duy nhất.

Schema bao gồm các trường tùy chọn (`author` và `date`) vì thông tin git blame có thể không có sẵn cho tất cả các file. Agent điền vào những gì nó có thể tìm thấy và bỏ qua phần còn lại.

<CodeGroup>
  ```typescript TypeScript theme={null}
  import { query } from "@anthropic-ai/claude-agent-sdk";

  // Define structure for TODO extraction
  const todoSchema = {
    type: "object",
    properties: {
      todos: {
        type: "array",
        items: {
          type: "object",
          properties: {
            text: { type: "string" },
            file: { type: "string" },
            line: { type: "number" },
            author: { type: "string" },
            date: { type: "string" }
          },
          required: ["text", "file", "line"]
        }
      },
      total_count: { type: "number" }
    },
    required: ["todos", "total_count"]
  };

  // Agent uses Grep to find TODOs, Bash to get git blame info
  for await (const message of query({
    prompt: "Find all TODO comments in this codebase and identify who added them",
    options: {
      outputFormat: {
        type: "json_schema",
        schema: todoSchema
      }
    }
  })) {
    if (message.type === "result" && message.subtype === "success" && message.structured_output) {
      const data = message.structured_output as { total_count: number; todos: Array<{ file: string; line: number; text: string; author?: string; date?: string }> };
      console.log(`Found ${data.total_count} TODOs`);
      data.todos.forEach((todo) => {
        console.log(`${todo.file}:${todo.line} - ${todo.text}`);
        if (todo.author) {
          console.log(`  Added by ${todo.author} on ${todo.date}`);
        }
      });
    }
  }
  ```

  ```python Python theme={null}
  import asyncio
  from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

  # Define structure for TODO extraction
  todo_schema = {
      "type": "object",
      "properties": {
          "todos": {
              "type": "array",
              "items": {
                  "type": "object",
                  "properties": {
                      "text": {"type": "string"},
                      "file": {"type": "string"},
                      "line": {"type": "number"},
                      "author": {"type": "string"},
                      "date": {"type": "string"},
                  },
                  "required": ["text", "file", "line"],
              },
          },
          "total_count": {"type": "number"},
      },
      "required": ["todos", "total_count"],
  }


  async def main():
      # Agent uses Grep to find TODOs, Bash to get git blame info
      async for message in query(
          prompt="Find all TODO comments in this codebase and identify who added them",
          options=ClaudeAgentOptions(
              output_format={"type": "json_schema", "schema": todo_schema}
          ),
      ):
          if isinstance(message, ResultMessage) and message.structured_output:
              data = message.structured_output
              print(f"Found {data['total_count']} TODOs")
              for todo in data["todos"]:
                  print(f"{todo['file']}:{todo['line']} - {todo['text']}")
                  if "author" in todo:
                      print(f"  Added by {todo['author']} on {todo['date']}")


  asyncio.run(main())
  ```
</CodeGroup>

## Xử lý lỗi

Việc sinh structured output có thể thất bại khi agent không thể tạo ra JSON hợp lệ khớp với schema của bạn. Điều này thường xảy ra khi schema quá phức tạp so với tác vụ, khi bản thân tác vụ mơ hồ, hoặc khi agent chạm đến giới hạn số lần thử lại để cố gắng sửa các lỗi xác thực. Nó cũng có thể xảy ra mà không có bất kỳ lỗi xác thực nào: một [model fallback](/en/model-config#automatic-model-fallback) có thể rút lại (retract) một đầu ra đã hoàn thành giữa chừng của stream, và nếu không có lần thử lại nào thay thế nó thì lần chạy kết thúc với cùng một lỗi. Hãy kiểm tra trường `errors` trên tin nhắn kết quả để phân biệt hai nguyên nhân này trước khi debug schema của bạn.

Khi một lỗi xảy ra, tin nhắn kết quả có một `subtype` cho biết điều gì đã sai:

| Subtype                               | Ý nghĩa                                                                                                                        |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `success`                             | Đầu ra được sinh ra và xác thực thành công                                                                                     |
| `error_max_structured_output_retries` | Không còn đầu ra hợp lệ nào sau nhiều lần thử (lỗi xác thực, hoặc một lần rút lại do model-fallback mà không có lần thử lại thành công) |

Ví dụ dưới đây kiểm tra trường `subtype` để xác định xem đầu ra đã được sinh ra thành công hay bạn cần xử lý một thất bại:

<CodeGroup>
  ```typescript TypeScript theme={null}
  for await (const msg of query({
    prompt: "Extract contact info from the document",
    options: {
      outputFormat: {
        type: "json_schema",
        schema: contactSchema
      }
    }
  })) {
    if (msg.type === "result") {
      if (msg.subtype === "success" && msg.structured_output) {
        // Use the validated output
        console.log(msg.structured_output);
      } else if (msg.subtype === "error_max_structured_output_retries") {
        // Handle the failure - retry with simpler prompt, fall back to unstructured, etc.
        console.error("Could not produce valid output");
      }
    }
  }
  ```

  ```python Python theme={null}
  async for message in query(
      prompt="Extract contact info from the document",
      options=ClaudeAgentOptions(
          output_format={"type": "json_schema", "schema": contact_schema}
      ),
  ):
      if isinstance(message, ResultMessage):
          if message.subtype == "success" and message.structured_output:
              # Use the validated output
              print(message.structured_output)
          elif message.subtype == "error_max_structured_output_retries":
              # Handle the failure
              print("Could not produce valid output")
  ```
</CodeGroup>

**Mẹo để tránh lỗi:**

* **Giữ schema tập trung.** Các schema lồng sâu với nhiều trường bắt buộc khó thỏa mãn hơn. Bắt đầu đơn giản và thêm độ phức tạp khi cần.
* **Khớp schema với tác vụ.** Nếu tác vụ có thể không có tất cả thông tin mà schema của bạn yêu cầu, hãy làm cho các trường đó thành tùy chọn.
* **Dùng prompt rõ ràng.** Các prompt mơ hồ khiến agent khó biết cần tạo ra đầu ra gì.

## Tài nguyên liên quan

* [Tài liệu JSON Schema](https://json-schema.org/): học cú pháp JSON Schema để định nghĩa các schema phức tạp với các đối tượng lồng nhau, array, enum, và các ràng buộc xác thực
* [Structured Outputs của API](https://platform.claude.com/docs/en/build-with-claude/structured-outputs): dùng structured output với Claude API trực tiếp cho các yêu cầu một lượt (single-turn) mà không dùng tool
* [Custom tools](/en/agent-sdk/custom-tools): trao cho agent các tool tùy chỉnh để gọi trong lúc thực thi trước khi trả về structured output
