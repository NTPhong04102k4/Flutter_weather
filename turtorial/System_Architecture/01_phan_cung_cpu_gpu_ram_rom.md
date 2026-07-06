# 🧠 Bài 01: Phần Cứng — CPU, GPU, RAM, ROM Điều Khiển Hệ Thống Ra Sao

> **Mục tiêu**: Hiểu vai trò vật lý của từng thành phần phần cứng và cách chúng phối hợp tại từng thời điểm để chạy một ứng dụng. Đây là **tầng đáy** mà mọi thứ bên trên (OS, process, thread, Flutter) đều dựa vào.

---

## 1. Kiến Trúc Phân Lớp Toàn Cảnh

Mọi thứ trong máy tính/điện thoại đều xếp thành các **tầng (layer)**. Tầng trên chỉ "ra lệnh" xuống tầng dưới, không bao giờ chạm thẳng vào phần cứng.

```
┌──────────────────────────────────────────────────────────┐
│  TẦNG 5: Ứng dụng của bạn (Flutter Weather App)          │  ← Bạn viết code ở đây
├──────────────────────────────────────────────────────────┤
│  TẦNG 4: Runtime / VM (Dart VM, JVM, ART, .NET)          │  ← Dịch & chạy code
├──────────────────────────────────────────────────────────┤
│  TẦNG 3: Thư viện hệ thống (libc, Flutter Engine, Skia)  │
├──────────────────────────────────────────────────────────┤
│  TẦNG 2: Hệ điều hành / Kernel (Linux, iOS/XNU, Windows) │  ← "Trọng tài" phần cứng
├──────────────────────────────────────────────────────────┤
│  TẦNG 1: Phần cứng (CPU · GPU · RAM · ROM · I/O)         │  ← Vật lý, chạy điện
└──────────────────────────────────────────────────────────┘
```

> 🔑 **Nguyên tắc vàng**: App KHÔNG được nói chuyện trực tiếp với CPU/RAM. Nó phải "xin phép" OS qua **System Call**. OS mới là kẻ duy nhất điều khiển phần cứng.

---

## 2. CPU — Bộ Não Xử Lý Lệnh

**CPU (Central Processing Unit)** làm đúng một việc, nhưng làm cực nhanh: **lấy lệnh → giải mã → thực thi → lưu kết quả** (chu trình *Fetch-Decode-Execute*), lặp lại hàng tỷ lần/giây.

```
        ┌──────────────────── CPU ────────────────────┐
        │  ┌─────────┐   ┌──────────┐   ┌───────────┐  │
        │  │ Control │   │   ALU    │   │ Registers │  │
        │  │  Unit   │──▶│ (tính +− │──▶│ (siêu     │  │
        │  │ (điều   │   │  ×÷ so   │   │  nhanh,   │  │
        │  │  phối)  │   │  sánh)   │   │  vài chục)│  │
        │  └─────────┘   └──────────┘   └───────────┘  │
        │  ┌────────────── Cache ──────────────────┐    │
        │  │  L1 (~ns) → L2 → L3 (chia sẻ cores)   │    │
        │  └───────────────────────────────────────┘    │
        └────────────────────┬─────────────────────────┘
                             │ Bus dữ liệu
                             ▼
                        [ RAM ]  (chậm hơn cache ~100x)
```

### 2.1 Các khái niệm cốt lõi

| Thành phần | Vai trò | Ghi nhớ |
|-----------|---------|---------|
| **Core (nhân)** | Một đơn vị xử lý độc lập. CPU 8 nhân = 8 việc *thật sự* song song | Nhiều core → parallelism thật |
| **Clock (xung nhịp)** | Số chu kỳ/giây, VD 3.0 GHz = 3 tỷ nhịp/giây | Nhanh hơn ≠ luôn tốt hơn |
| **Register** | Ô nhớ nhanh nhất, nằm *trong* CPU | Chứa dữ liệu đang tính |
| **Cache L1/L2/L3** | Bộ nhớ đệm cực nhanh, giảm việc phải ra RAM | L1 nhanh nhất, nhỏ nhất |
| **ALU** | Đơn vị tính toán số học & logic | Nơi phép `+`, `>`, `&&` xảy ra |
| **Control Unit** | Điều phối, quyết định lệnh nào chạy tiếp | "Nhạc trưởng" của CPU |

### 2.2 Phân cấp tốc độ bộ nhớ (Memory Hierarchy) — RẤT quan trọng

CPU nhanh hơn RAM rất nhiều, nên có nhiều tầng đệm để CPU không phải "ngồi chờ":

```
Register   →  ~0.3 ns   (nhanh nhất, nhỏ nhất — vài KB)
   ↓
Cache L1   →  ~1 ns
Cache L2   →  ~4 ns
Cache L3   →  ~10 ns
   ↓
RAM        →  ~100 ns   (chậm hơn L1 ~300 lần!)
   ↓
SSD/Flash  →  ~100.000 ns (100 µs)
   ↓
HDD/Mạng   →  ~10.000.000 ns (10 ms) (chậm nhất)
```

> 💡 **Vì sao code chạy nhanh/chậm?** Nếu dữ liệu đã nằm trong cache → nhanh. Nếu phải ra RAM/ổ cứng/mạng → chậm. Đây là lý do vì sao **cache** (Bài 07 của bạn) và **async I/O** (Bài 05) lại quan trọng: I/O chậm gấp hàng triệu lần tính toán.

---

## 3. RAM — Bộ Nhớ Làm Việc (Volatile)

**RAM (Random Access Memory)** là nơi CPU đặt mọi thứ **đang chạy**: code của app, biến, dữ liệu. Đặc điểm:

- **Volatile (bay hơi)**: mất điện → mất sạch. Tắt app/tắt máy → dữ liệu RAM biến mất.
- **Truy cập ngẫu nhiên**: đọc ô nhớ bất kỳ đều nhanh như nhau.
- **Có địa chỉ**: mỗi byte có một địa chỉ (address). Con trỏ (pointer) chính là địa chỉ này.

### 3.1 Một process dùng RAM chia làm 4 vùng

```
Địa chỉ cao ┌─────────────────────┐
            │       STACK         │ ← Biến local, tham số hàm, địa chỉ trả về
            │   (lớn xuống ↓)     │   Tự động dọn khi hàm return. RẤT nhanh.
            ├─────────────────────┤
            │         ↕           │   (khoảng trống co giãn)
            ├─────────────────────┤
            │        HEAP         │ ← Object tạo động (new/malloc), List, Map...
            │    (lớn lên ↑)     │   Phải dọn bằng Garbage Collector (Dart) hoặc tay
            ├─────────────────────┤
            │    DATA / BSS       │ ← Biến global, static, hằng số
            ├─────────────────────┤
            │    TEXT (CODE)      │ ← Mã máy của chương trình (chỉ đọc)
Địa chỉ thấp└─────────────────────┘
```

> 🔑 **Stack vs Heap** — câu hỏi phỏng vấn kinh điển:
> - **Stack**: nhanh, tự dọn, kích thước cố định nhỏ, cho biến local. Tràn stack = *StackOverflow* (đệ quy vô hạn).
> - **Heap**: linh hoạt, lớn, chậm hơn, phải dọn rác. Rò rỉ heap = *Memory Leak*.
> - Trong Dart: object (`List`, `Map`, instance class) nằm ở **heap**, được **Garbage Collector** dọn tự động; biến `int`, tham chiếu nằm ở **stack**.

---

## 4. ROM / Bộ Nhớ Lưu Trữ (Non-volatile)

**ROM (Read-Only Memory)** theo nghĩa gốc là bộ nhớ chỉ đọc, chứa firmware khởi động (BIOS/Bootloader). Trên điện thoại, ta thường gọi chung **"ROM"** cho **bộ nhớ lưu trữ (storage / Flash / eMMC / UFS)** — nơi giữ dữ liệu **kể cả khi tắt máy**.

| | RAM | ROM / Storage |
|---|-----|---------------|
| Mất điện có mất data? | **Có** (volatile) | **Không** (non-volatile) |
| Tốc độ | Rất nhanh (~100ns) | Chậm hơn nhiều (~100µs+) |
| Vai trò | Nơi *đang chạy* | Nơi *lưu trữ lâu dài* |
| Ví dụ trong app | Biến, state đang chạy | File cài đặt app, ảnh, DB SQLite, SharedPreferences |

```
Khi mở app:
  [ROM/Storage] ──(1) OS đọc file app──▶ [RAM] ──(2) CPU thực thi──▶ chạy
       ↑                                    │
       └──────(3) Lưu data cần giữ─────────┘
             (SharedPreferences, SQLite, file cache)
```

> 💡 Liên hệ Flutter: `SharedPreferences`, `sqflite`, cache file ảnh → ghi xuống **ROM/Storage**. State trong `setState`, biến trong Provider/Bloc → nằm trong **RAM**, mất khi tắt app.

---

## 5. GPU — Bộ Xử Lý Đồ Họa (Vẽ Ra Màn Hình)

**GPU (Graphics Processing Unit)** khác CPU ở triết lý:

```
CPU:  vài core MẠNH   →  giỏi việc tuần tự, logic phức tạp, rẽ nhánh
      [🐘][🐘][🐘][🐘]

GPU:  hàng nghìn core YẾU  →  giỏi làm CÙNG một phép tính trên NHIỀU dữ liệu
      [🐜][🐜][🐜]...[🐜]  (tính màu cho hàng triệu pixel cùng lúc)
```

- CPU: "làm nhiều loại việc khác nhau, tuần tự, thông minh".
- GPU: "làm một loại việc lặp đi lặp lại, song song hàng loạt" — hoàn hảo cho **vẽ pixel, ma trận, đồ họa, ML**.

### 5.1 GPU vẽ một khung hình (frame) thế nào

```
[CPU] tính toán layout, widget nào ở đâu (Flutter: build + layout)
   │  tạo ra danh sách lệnh vẽ (draw commands / display list)
   ▼
[GPU] rasterize: biến hình học → pixel màu cụ thể
   │  (Flutter dùng Skia/Impeller để nói chuyện với GPU)
   ▼
[Framebuffer trong RAM/VRAM] chứa ảnh khung hình
   ▼
[Màn hình] quét ra 60/120 lần mỗi giây (60Hz/120Hz)
```

> 🔑 **60 FPS = mỗi frame chỉ có ~16.6 ms** để CPU + GPU làm xong việc. Nếu quá hạn → **jank** (giật hình). Đây là lý do Flutter tách riêng **UI thread** (CPU tính) và **Raster thread** (đẩy lên GPU) — xem Bài 04.

---

## 6. Toàn Cảnh: Một Cái Chạm Màn Hình Đi Qua Phần Cứng Ra Sao

Ví dụ bạn **chạm nút "Tìm thời tiết"** trong app:

```
(1) NGÓN TAY chạm màn hình
      │
      ▼
(2) Bộ cảm ứng (touch controller) → gửi tín hiệu điện → CPU (qua interrupt)
      │
      ▼
(3) OS nhận sự kiện, chuyển cho app đang hiển thị
      │
      ▼
(4) CPU chạy code Dart: handler onTap → gọi API
      │   (code + biến nằm trong RAM, CPU đọc qua cache)
      ▼
(5) Cần dữ liệu mạng → OS gửi request qua Wi-Fi/4G (I/O, chậm)
      │   → CPU KHÔNG ngồi chờ, chuyển sang việc khác (async — Bài 05)
      ▼
(6) Data về → CPU parse JSON → cập nhật state (RAM)
      │
      ▼
(7) Flutter build lại UI (CPU) → tạo draw commands
      │
      ▼
(8) GPU rasterize → framebuffer → MÀN HÌNH hiển thị kết quả
      │
      ▼
(9) Nếu cần lưu (lịch sử tìm kiếm) → ghi xuống ROM/Storage
```

Mỗi bước là sự phối hợp: **CPU điều phối**, **RAM giữ dữ liệu tạm**, **GPU vẽ**, **ROM lưu lâu dài**, và **OS là trọng tài** đứng giữa tất cả.

---

## 7. Bảng Tổng Kết Vai Trò

| Thành phần | Ví von | Vai trò chính | Mất điện? |
|-----------|--------|--------------|-----------|
| **CPU** | Bộ não | Thực thi lệnh, điều phối, logic | — |
| **GPU** | Đội thợ vẽ | Song song hàng loạt, vẽ pixel, ML | — |
| **RAM** | Bàn làm việc | Chứa cái *đang* chạy | ❌ mất |
| **ROM/Storage** | Tủ hồ sơ | Lưu trữ lâu dài | ✅ giữ |
| **Cache** | Ghi chú dán sẵn | Đệm cho CPU khỏi chờ RAM | ❌ mất |
| **Bus** | Đường vận chuyển | Nối các thành phần | — |

---

## 8. Câu Hỏi Ôn Tập

1. Vì sao app không được điều khiển CPU trực tiếp mà phải qua OS?
2. Kể tên 4 vùng bộ nhớ của một process. Object Dart nằm ở vùng nào?
3. Vì sao đọc mạng/ổ cứng lại là "kẻ thù" của hiệu năng? (gợi ý: memory hierarchy)
4. GPU khác CPU ở điểm triết lý nào? Vì sao GPU hợp với vẽ đồ họa?
5. `SharedPreferences` lưu vào RAM hay ROM? Còn `setState` thì sao?

---

> ➡️ **Bài tiếp theo**: [02 — Hệ điều hành, Process & Thread](./02_he_dieu_hanh_process_thread.md) — kẻ trung gian điều khiển tất cả.
