# 🎯 Bài 04: Ứng Dụng Điều Khiển Thread & Mô Hình Luồng Của Flutter

> **Mục tiêu**: Ghép tất cả lại — từ phần cứng đến app. Hiểu app *điều khiển* luồng thế nào (thread pool, Isolate), và Flutter dùng những thread nào để giữ 60/120 FPS.

---

## 1. App Điều Khiển Thread Ra Sao?

App **không tự tạo core CPU** — nó chỉ **yêu cầu OS** tạo thread/isolate, rồi OS lập lịch (Bài 03). Có 3 cách app tổ chức luồng:

```
(A) Đơn luồng (Single-thread) + Event Loop
    → 1 thread + async I/O. Dart/JavaScript dùng.
    → Đơn giản, không race condition, nhưng tính nặng sẽ khóa.

(B) Đa luồng chia sẻ bộ nhớ (Shared-memory threads)
    → Nhiều thread cùng đọc/ghi heap. Java, C++, Kotlin, Swift dùng.
    → Mạnh, parallelism thật, nhưng phải khóa (lock) → dễ deadlock/race.

(C) Đa luồng KHÔNG chia sẻ bộ nhớ (Message-passing)
    → Mỗi luồng có bộ nhớ riêng, nói chuyện qua message. Dart Isolate, Erlang.
    → An toàn (không race condition) + parallelism thật.
```

> 🔑 Dart kết hợp **(A) trong mỗi isolate** và **(C) giữa các isolate** — vừa đơn giản vừa an toàn.

---

## 2. Thread Pool — Vì Sao Không Tạo Thread Vô Tội Vạ

Tạo/hủy thread tốn phí, và quá nhiều thread gây context switch liên tục (Bài 03). Giải pháp: **Thread Pool** — tạo sẵn N thread, tái sử dụng.

```
Hàng đợi công việc:  [job1][job2][job3][job4][job5]...
                          │
                          ▼  phân phối cho các thread rảnh
   ┌─────────────────────────────────────────────┐
   │  Thread Pool (VD: N = số core - 1)           │
   │   [Thread 1] [Thread 2] [Thread 3] [Thread 4]│
   │   làm job1    làm job2    rảnh...    làm job3 │
   └─────────────────────────────────────────────┘
```

- Job xong → thread không chết, quay lại nhận job mới.
- Số thread thường ≈ số core → tránh dư thừa.
- Dart có `Isolate.spawn` thủ công, hoặc dùng package như `worker_manager` để quản lý pool isolate.

---

## 3. Mô Hình Luồng Của Flutter — 4 Loại Thread

Flutter Engine (native, C++) tổ chức công việc trên **4 runner (thread)**. Hiểu cái này là hiểu vì sao app mượt hay giật.

```
┌──────────────────────────────────────────────────────────────┐
│                     FLUTTER ENGINE                             │
│                                                                │
│  ① Platform Thread (Main)                                     │
│     • Nơi native (iOS/Android) chạy, khởi động engine         │
│     • Xử lý plugin, MethodChannel (Bài 17 của bạn)            │
│                                                                │
│  ② UI Thread (Dart)     ★ nơi code Dart của bạn chạy          │
│     • build() / setState / layout / animation logic           │
│     • Event Loop + toàn bộ isolate chính ở đây                │
│     • Tạo "layer tree" → giao cho Raster thread               │
│                                                                │
│  ③ Raster Thread (trước gọi GPU thread)                       │
│     • Nhận layer tree → dùng Skia/Impeller → lệnh cho GPU     │
│     • Rasterize thành pixel                                    │
│                                                                │
│  ④ I/O Thread                                                 │
│     • Đọc/giải mã ảnh, tài nguyên nặng (tách khỏi UI)         │
└──────────────────────────────────────────────────────────────┘
```

### Luồng vẽ 1 frame (60 FPS = 16.6ms/frame)

```
[UI Thread] build widget → layout → tạo layer tree   (CPU tính)
     │  (phải xong nhanh, nếu >16ms → giật)
     ▼
[Raster Thread] layer tree → Skia/Impeller → draw commands
     │
     ▼
[GPU] rasterize pixel → framebuffer
     │
     ▼
[Màn hình] hiển thị
```

> ⚠️ **Vì sao app giật (jank)?**
> - **UI thread** bị nghẽn: bạn chạy vòng lặp nặng / parse JSON lớn trong `build()` hay handler → frame trễ.
> - **Raster thread** bị nghẽn: hiệu ứng quá phức tạp (shadow, blur, opacity chồng nhau).
> - 👉 Giữ UI thread rảnh: đẩy tính toán nặng sang **Isolate**.

---

## 4. Isolate — Cách Dart Làm Song Song An Toàn

**Isolate** = đơn vị chạy độc lập của Dart, mỗi cái có **bộ nhớ riêng + event loop riêng**. Không chia sẻ bộ nhớ → **không bao giờ race condition**. Giao tiếp qua **message (Port)**.

```
┌── Main Isolate (UI) ──┐         ┌── Worker Isolate ──┐
│  Heap riêng           │         │  Heap riêng        │
│  Event loop riêng     │ message │  Event loop riêng  │
│  (chạy UI, build)     │ ◀─────▶ │  (tính toán nặng)  │
│                       │  (copy  │                    │
│                       │  dữ liệu)│                   │
└───────────────────────┘         └────────────────────┘
   Chạy trên core khác nhau → PARALLELISM thật (Bài 03)
```

- Dữ liệu gửi qua isolate được **sao chép** (copy), không chia sẻ tham chiếu → an toàn tuyệt đối, nhưng copy dữ liệu lớn tốn phí.
- Đây là điểm khác biệt lớn với thread của Java/Swift (vốn chia sẻ heap).

### Cách dùng trong Flutter

```dart
import 'package:flutter/foundation.dart';

// ❌ SAI: parse JSON khổng lồ ngay trên UI thread → app đơ vài giây
List<Weather> parseHeavy(String json) {
  // ... vòng lặp nặng, giải mã 10.000 phần tử ...
}

// ✅ ĐÚNG: đẩy sang isolate khác bằng compute()
Future<List<Weather>> loadWeather(String json) async {
  // compute() tự spawn 1 isolate, chạy parseHeavy ở đó, trả kết quả về
  return await compute(parseHeavy, json);
}
```

`compute()` là cách đơn giản nhất để chạy 1 hàm nặng trên isolate riêng. Muốn kiểm soát nhiều hơn, dùng `Isolate.spawn` + `ReceivePort`/`SendPort`.

> 💡 **Quy tắc**: tác vụ **> vài ms tính toán thuần** → cân nhắc Isolate. Tác vụ **chờ I/O** (mạng, file) → chỉ cần `async/await`, KHÔNG cần isolate.

---

## 5. Tổng Hợp: Từ Phần Cứng Đến Flutter (Toàn Cảnh)

Ghép tất cả 4 bài — một lần user tìm thời tiết trong app của bạn:

```
① User chạm nút (phần cứng cảm ứng → interrupt → CPU)          [Bài 01]
        │
        ▼
② OS nhận sự kiện, chuyển cho PROCESS app (user space)          [Bài 02]
        │
        ▼
③ UI Thread (Dart) chạy onTap handler                          [Bài 04]
        │  gọi http.get() → await
        ▼
④ System call socket → OS gửi qua Wi-Fi (I/O, thread BLOCKED)   [Bài 02]
        │  UI thread KHÔNG chờ → làm việc khác (concurrency)    [Bài 03]
        ▼
⑤ Data về → OS đánh thức → Event Loop nhận vào Event Queue     [Bài 03]
        │
        ▼
⑥ JSON lớn? → compute() → Worker Isolate parse (core khác)     [Bài 04]
        │  (parallelism thật, UI thread vẫn mượt)              [Bài 03]
        ▼
⑦ Kết quả copy về Main Isolate → setState → build lại UI       [Bài 04]
        │  (dữ liệu state nằm ở HEAP/RAM)                      [Bài 01]
        ▼
⑧ UI thread tạo layer tree → Raster thread → GPU vẽ pixel      [Bài 04]
        │
        ▼
⑨ Màn hình hiển thị thời tiết (framebuffer → screen 60Hz)      [Bài 01]
        │
        ▼
⑩ Lưu lịch sử tìm kiếm → SharedPreferences → ghi xuống ROM     [Bài 01]
```

---

## 6. Bảng Quyết Định Nhanh (Cheat Sheet)

| Tình huống | Dùng gì | Vì sao |
|-----------|---------|--------|
| Gọi API, đọc file, query DB | `async/await` + `Future` | I/O-bound, OS lo phần chờ |
| Nhiều sự kiện theo thời gian (search, stream data) | `Stream` | Chuỗi dữ liệu bất đồng bộ |
| Parse JSON lớn, xử lý ảnh, mã hóa | `compute()` / `Isolate` | CPU-bound, tránh khóa UI |
| Chạy nền khi app đóng (nhạc, sync, GPS) | Service / `workmanager` | Vòng đời độc lập với UI |
| Gọi API native (camera, bluetooth) | `MethodChannel` (Bài 17) | Cầu nối Platform thread |

---

## 7. Câu Hỏi Ôn Tập

1. Kể tên 4 thread của Flutter Engine và nhiệm vụ từng cái.
2. Vì sao chạy vòng lặp nặng trong `build()` làm app giật? Cách khắc phục?
3. Isolate khác thread của Java/Swift ở điểm mấu chốt nào? (gợi ý: bộ nhớ)
4. Khi nào dùng `async/await`, khi nào phải dùng `Isolate`?
5. `compute()` làm gì bên dưới? Dữ liệu truyền qua isolate được chia sẻ hay sao chép?

---

## 8. Kết Nối Với Các Bài Khác Trong Repo

- **Bài 05** (Async): Event Loop, Future, Stream, Isolate — chi tiết cú pháp.
- **Bài 07** (Race Condition & Cache): hệ quả của việc chia sẻ bộ nhớ, debounce/throttle.
- **Bài 15** (Call API): áp dụng async I/O thực tế.
- **Bài 17** (Platform Channels): cầu nối UI thread ↔ Platform thread ↔ native.

---

> ⬅️ Quay lại: [03 — Scheduling & Concurrency](./03_scheduling_va_concurrency.md)
> 🏠 [Về mục lục System Architecture](./00_index.md)
