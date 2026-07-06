# 🔀 Bài 03: Lập Lịch CPU, Concurrency vs Parallelism

> **Mục tiêu**: Hiểu OS chia CPU cho hàng trăm luồng thế nào (Scheduler + Context Switch), và phân biệt hai khái niệm hay bị nhầm: **Concurrency** (đồng thời) vs **Parallelism** (song song).

---

## 1. Vấn Đề: Ít CPU, Nhiều Việc

Máy bạn có thể chạy **hàng trăm process** cùng lúc, nhưng CPU chỉ có vài core. VD: 8 core nhưng có 300 thread muốn chạy. Làm sao?

👉 **OS Scheduler** (bộ lập lịch) luân phiên chia CPU cho từng thread một cách cực nhanh, tạo **ảo giác** mọi thứ chạy cùng lúc.

```
CPU 1 core, 3 thread muốn chạy — thực tế nó luân phiên:

Thời gian →
Core: [A][B][C][A][B][C][A][B][C]...
       ↑ mỗi ô ~vài ms (time slice / quantum)

Mắt người thấy: cả A, B, C "chạy cùng lúc" (nhưng thật ra lần lượt)
```

---

## 2. Context Switch — Chuyển Ngữ Cảnh

Khi CPU chuyển từ thread A sang thread B, nó phải:

```
(1) LƯU trạng thái thread A:
    registers, program counter, stack pointer → cất vào PCB/TCB của A

(2) NẠP trạng thái thread B:
    lấy registers, PC, SP của B ra → khôi phục

(3) CPU bắt đầu chạy tiếp thread B từ đúng chỗ nó dừng
```

> ⚠️ **Context switch tốn phí!** Mỗi lần chuyển mất thời gian cứu/nạp trạng thái + làm "nguội" cache. Tạo **quá nhiều** thread → CPU tốn thời gian chuyển qua lại hơn là làm việc thật ("thrashing"). Đây là lý do ta dùng **thread pool** thay vì tạo thread vô tội vạ (Bài 04).

---

## 3. Cách Scheduler Quyết Định Chạy Ai

Hai triết lý lập lịch:

| Loại | Cơ chế | Ưu / Nhược |
|------|--------|-----------|
| **Preemptive** (giành quyền) | OS **cưỡng chế** ngắt thread khi hết time slice | Công bằng, không bị treo bởi 1 thread tham lam. (Linux, iOS, Android, Windows dùng) |
| **Cooperative** (hợp tác) | Thread **tự nguyện** nhường CPU | Đơn giản nhưng 1 thread "ích kỷ" làm treo cả hệ thống |

Các thuật toán phổ biến: **Round Robin** (xoay vòng đều), **Priority** (ưu tiên), **CFS** (Completely Fair Scheduler của Linux), **MLFQ** (nhiều hàng đợi ưu tiên).

> 💡 **Priority (độ ưu tiên)**: UI thread thường được ưu tiên cao để app mượt. Thread tải file nền có ưu tiên thấp. OS điện thoại còn hạ ưu tiên app chạy nền để tiết kiệm pin.

---

## 4. Concurrency vs Parallelism — Phân Biệt CỐT LÕI

Đây là chỗ **rất nhiều người nhầm**. Hai khái niệm khác nhau hoàn toàn:

```
CONCURRENCY (Đồng thời) — QUẢN LÝ nhiều việc
  1 đầu bếp nấu 3 món: đảo món A → trong lúc A sôi, thái rau món B
  → tráo qua lại, KHÔNG cần 2 tay cùng lúc. Chỉ cần 1 CPU.

  Core: [A][B][A][C][B][A]...  (luân phiên trên 1 core)


PARALLELISM (Song song) — LÀM nhiều việc CÙNG LÚC
  3 đầu bếp, mỗi người 1 món, làm ĐỒNG THỜI. Cần 3 CPU (core) THẬT.

  Core 1: [A][A][A][A]
  Core 2: [B][B][B][B]   ← thật sự cùng một thời điểm
  Core 3: [C][C][C][C]
```

| | **Concurrency** | **Parallelism** |
|---|-----------------|-----------------|
| Câu hỏi | "Xử lý nhiều việc *cùng giai đoạn*?" | "Chạy nhiều việc *cùng khoảnh khắc*?" |
| Cần bao nhiêu core? | 1 core cũng được | Bắt buộc nhiều core |
| Bản chất | *Cấu trúc* — cách tổ chức việc | *Thực thi* — chạy vật lý song song |
| Ví dụ Dart | **async/await + Event Loop** | **Isolate** trên nhiều core |

> 🔑 **Câu nói kinh điển (Rob Pike)**: *"Concurrency is about dealing with lots of things at once. Parallelism is about doing lots of things at once."*
> - **Concurrency** = *cách bạn thiết kế* để xử lý nhiều việc.
> - **Parallelism** = *chạy thật* nhiều việc cùng lúc nhờ nhiều core.
> - Bạn có thể có concurrency mà không parallelism (Dart single-thread + async), và ngược lại.

---

## 5. Liên Hệ Dart: Vì Sao Single-Thread Vẫn Xử Lý Được Nhiều Việc?

Dart mặc định chạy trên **1 thread** với **Event Loop** (Bài 05). Đây là **concurrency KHÔNG parallelism**:

```
┌──────────────── 1 Thread Dart ────────────────┐
│                                                │
│  Chạy code đồng bộ                             │
│     │                                          │
│     ├─ Gặp await http.get() → I/O              │
│     │   → GIAO cho OS lo (mạng), KHÔNG chờ    │
│     │   → quay lại làm việc khác NGAY          │
│     │                                          │
│     ▼                                          │
│  ┌─────────────┐   ┌──────────────┐           │
│  │ Microtask Q │   │  Event Queue │           │
│  │ (.then)     │   │ (Future,I/O) │           │
│  └─────────────┘   └──────────────┘           │
│       ↑ Event Loop lấy việc ra chạy lần lượt   │
└────────────────────────────────────────────────┘
```

- Việc **chờ mạng/file** (I/O) do **OS + phần cứng** lo — Dart không "bận" chờ.
- Nhờ vậy 1 thread vẫn xử lý được hàng trăm request đồng thời (concurrency).
- Nhưng nếu bạn làm **tính toán nặng** (vòng lặp 1 tỷ lần, xử lý ảnh) ngay trên thread này → nó **khóa cả UI** vì không có việc gì "nhường CPU" → app giật.
  👉 Giải pháp: đẩy sang **Isolate** để có parallelism thật (Bài 04).

---

## 6. Khi Nào Dùng Cái Gì?

```
Việc CHỜ I/O (mạng, file, DB)  →  async/await   (concurrency, 1 thread đủ)
   "chờ nhiều, tính ít"

Việc TÍNH TOÁN NẶNG (CPU-bound) →  Isolate/thread (parallelism, cần core)
   "tính nhiều, chờ ít"
   VD: parse JSON khổng lồ, xử lý ảnh, mã hóa, ML
```

| Loại tác vụ | Bản chất | Giải pháp Dart/Flutter |
|-------------|----------|------------------------|
| Gọi API, đọc file, query DB | **I/O-bound** (chờ) | `async/await`, `Future`, `Stream` |
| Xử lý ảnh, parse JSON lớn, tính toán | **CPU-bound** (tính) | `Isolate`, `compute()` |

> ⚠️ **Sai lầm phổ biến**: dùng `async/await` cho việc tính toán nặng. `async` KHÔNG làm việc chạy song song — nó vẫn trên UI thread → vẫn giật! Chỉ **Isolate** mới cho parallelism thật.

---

## 7. Câu Hỏi Ôn Tập

1. Context switch là gì và vì sao tạo quá nhiều thread lại phản tác dụng?
2. Phân biệt Preemptive vs Cooperative scheduling.
3. Nêu định nghĩa và ví dụ đời thường cho Concurrency vs Parallelism.
4. Dart single-thread mà vẫn xử lý nhiều request — nhờ cơ chế nào? Đó là concurrency hay parallelism?
5. Vì sao dùng `async` cho vòng lặp tính toán 1 tỷ lần vẫn làm giật UI? Phải làm gì?

---

> ➡️ **Bài tiếp theo**: [04 — App điều khiển thread & mô hình luồng Flutter](./04_ung_dung_dieu_khien_thread_flutter.md)
> ⬅️ Quay lại: [02 — Hệ điều hành, Process & Thread](./02_he_dieu_hanh_process_thread.md)
