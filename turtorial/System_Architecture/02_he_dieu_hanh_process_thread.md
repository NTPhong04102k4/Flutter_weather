# ⚙️ Bài 02: Hệ Điều Hành, Process, Thread & Service

> **Mục tiêu**: Hiểu OS là "trọng tài" điều khiển phần cứng thế nào, và phân biệt **rõ ràng** Process — Thread — Service. Đây là nền tảng để hiểu vì sao app không bị treo và dữ liệu không bị lẫn lộn.

---

## 1. Hệ Điều Hành Làm Gì? — Kẻ Trung Gian Duy Nhất

App của bạn **không bao giờ** chạm trực tiếp vào CPU/RAM/ổ cứng. Mọi thứ phải đi qua **Hệ điều hành (OS)**. OS chia thành 2 không gian:

```
┌─────────────────── USER SPACE (không gian người dùng) ──────────────┐
│  App Flutter │ App Chrome │ App Zalo │ ...  ← quyền hạn THẤP, bị cô lập │
└──────────────────────────────┬──────────────────────────────────────┘
                               │  ⬇ System Call (open, read, write, socket...)
                               │  (cánh cổng DUY NHẤT để xin tài nguyên)
┌──────────────────────────────▼──────────────────────────────────────┐
│                      KERNEL SPACE (nhân hệ điều hành)                 │
│  ┌────────────┐ ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ Scheduler  │ │  Memory   │ │  File    │ │ Network  │ │ Device  │ │
│  │ (chia CPU) │ │ Manager   │ │ System   │ │  Stack   │ │ Drivers │ │
│  └────────────┘ └───────────┘ └──────────┘ └──────────┘ └─────────┘ │
│                    quyền hạn CAO — điều khiển phần cứng thật          │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
                    [ CPU · RAM · GPU · ROM · I/O ]
```

### Vì sao phải tách 2 không gian?
- **Bảo vệ (Protection)**: app lỗi/độc hại không phá được cả máy. Nó "bị nhốt" trong user space.
- **Cô lập (Isolation)**: app A không đọc được RAM của app B.
- **Công bằng (Fairness)**: OS chia CPU/RAM đều cho các app.

> 🔑 **System Call** là ranh giới. Khi Dart gọi `File.readAsString()` hay `http.get()`, cuối cùng nó gọi xuống system call (`read`, `socket`) → CPU chuyển từ *user mode* sang *kernel mode*, OS làm việc, rồi trả kết quả về. Việc chuyển mode này tốn phí → đó là lý do I/O "đắt".

---

## 2. 4 Nhiệm Vụ Cốt Lõi Của OS

| Nhiệm vụ | Làm gì | Liên quan phần cứng |
|----------|--------|---------------------|
| **Process/Thread Management** | Tạo, dừng, lên lịch (schedule) các luồng chạy | CPU |
| **Memory Management** | Cấp phát RAM, bộ nhớ ảo, phân trang | RAM, MMU |
| **File System** | Quản lý đọc/ghi file, thư mục | ROM/Storage |
| **I/O & Device** | Điều khiển màn hình, mạng, cảm biến qua driver | GPU, Wi-Fi, sensors |

---

## 3. PROCESS — Một Chương Trình Đang Chạy

**Process** = một instance của chương trình đang chạy, **được OS cấp không gian bộ nhớ RIÊNG**.

```
Khi bạn mở app Flutter Weather → OS tạo 1 PROCESS:

┌──────────── PROCESS: com.example.weather (PID 1234) ────────────┐
│  Không gian địa chỉ ẢO riêng (app khác KHÔNG chạm vào được):     │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌───────┐                           │
│  │ TEXT │ │ DATA │ │ HEAP │ │ STACK │  (xem Bài 01)             │
│  └──────┘ └──────┘ └──────┘ └───────┘                           │
│  + Tài nguyên OS cấp: file mở, socket mạng, quyền (permissions)  │
│  + PCB (Process Control Block): PID, trạng thái, con trỏ lệnh... │
└─────────────────────────────────────────────────────────────────┘
```

- Mỗi process có **PID** (Process ID) duy nhất.
- Các process **cô lập** nhau — muốn nói chuyện phải qua **IPC** (Inter-Process Communication): pipe, socket, shared memory, message.
- Tạo process **tốn kém** (cấp bộ nhớ mới, sao chép tài nguyên).

> 💡 Trên điện thoại: mỗi app thường là 1 process riêng. iOS/Android còn "sandbox" mỗi process để app này không đọc dữ liệu app kia.

---

## 4. THREAD — Luồng Thực Thi Bên Trong Process

**Thread (luồng)** = một dòng thực thi lệnh bên trong process. Một process có **ít nhất 1 thread** (main thread) và có thể có nhiều thread.

```
┌──────────────── PROCESS (1 không gian bộ nhớ) ─────────────────┐
│                                                                 │
│   CHIA SẺ CHUNG:  [ TEXT ] [ DATA ] [ HEAP ]  ← mọi thread thấy │
│                                                                 │
│   RIÊNG mỗi thread:                                             │
│   ┌─ Thread 1 (main)─┐ ┌─ Thread 2 ────┐ ┌─ Thread 3 ────┐    │
│   │ Stack riêng      │ │ Stack riêng   │ │ Stack riêng   │    │
│   │ Registers riêng  │ │ Registers     │ │ Registers     │    │
│   │ Con trỏ lệnh(PC) │ │ PC riêng      │ │ PC riêng      │    │
│   └──────────────────┘ └───────────────┘ └───────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

- Các thread trong cùng process **chia sẻ HEAP + DATA** → giao tiếp nhanh (chung bộ nhớ).
- Nhưng mỗi thread có **STACK + Registers + Program Counter (PC)** riêng.
- Tạo thread **rẻ hơn** tạo process nhiều (không cần cấp không gian bộ nhớ mới).

> ⚠️ **Cái giá của việc chia sẻ HEAP**: hai thread cùng sửa một biến → **Race Condition** (Bài 07 của bạn). Phải dùng khóa (lock/mutex) để đồng bộ → phức tạp, dễ deadlock.

---

## 5. PROCESS vs THREAD — Phân Biệt Rõ Ràng

```
        PROCESS                              THREAD
   ┌───────────────┐                  ┌───────────────────────┐
   │ ┌───┐  ┌───┐  │  Nhiều process   │  Nhiều thread TRONG   │
   │ │Th │  │Th │  │  = nhiều "nhà"    │  1 process = nhiều    │
   │ └───┘  └───┘  │  riêng biệt       │  "người" TRONG 1 nhà  │
   │  bộ nhớ riêng │                  │  DÙNG CHUNG nhà        │
   └───────────────┘                  └───────────────────────┘
```

| Tiêu chí | **Process** | **Thread** |
|----------|-------------|------------|
| Định nghĩa | Chương trình đang chạy | Luồng thực thi trong process |
| Bộ nhớ | **Riêng biệt**, cô lập | **Chia sẻ** heap/data của process |
| Chi phí tạo | Nặng (cấp bộ nhớ mới) | Nhẹ |
| Giao tiếp | Qua IPC (chậm, phức tạp) | Qua biến chung (nhanh) |
| Một cái crash | Không kéo cái khác chết | Có thể làm sập cả process |
| Cô lập/An toàn | Cao | Thấp (dễ race condition) |
| Ví dụ | Mở 2 app khác nhau | 1 app có UI thread + network thread |

> 🔑 **Câu chốt để nhớ**:
> - *Process* = **cô lập** nhưng **tốn kém**.
> - *Thread* = **nhẹ & nhanh** nhưng **nguy hiểm** (chia sẻ bộ nhớ → race condition).
> - **Dart chọn con đường thứ 3 — Isolate** (Bài 04): nhẹ như thread nhưng **KHÔNG chia sẻ bộ nhớ** → an toàn như process. Đây là điểm độc đáo của Dart.

---

## 6. SERVICE — Tác Vụ Chạy Nền

**Service** không phải khái niệm CPU/OS cơ bản như process/thread, mà là **mô hình chạy nền** do nền tảng cung cấp. Nó là **một process (hoặc thread) chạy lâu dài, thường không có giao diện**, làm việc kể cả khi user không nhìn màn hình.

```
┌─────────── App đang mở (foreground) ───────────┐
│  UI hiển thị, user tương tác trực tiếp          │
└─────────────────────────────────────────────────┘
              ⇅  (app có thể bị đóng, nhưng...)
┌─────────── SERVICE / Background ───────────────┐
│  • Chơi nhạc khi tắt màn hình                   │
│  • Tải file, đồng bộ dữ liệu                    │
│  • Nhận thông báo đẩy (push)                    │
│  • Định vị GPS liên tục                          │
└─────────────────────────────────────────────────┘
```

| Khái niệm | Có UI? | Vòng đời | Ví dụ |
|-----------|--------|----------|-------|
| **Process** | Có thể | Do OS quản lý theo app | App bạn đang mở |
| **Thread** | Không (chỉ là luồng) | Trong process | Network thread |
| **Service** | Thường không | Sống lâu, chạy nền | Nhạc nền, sync, push |
| **Daemon** (server/Linux) | Không | Chạy suốt nền | `sshd`, `cron` |

### Trên các nền tảng
- **Android**: `Service`, `Foreground Service` (có thông báo), `WorkManager` (tác vụ định kỳ). Chạy trong process của app.
- **iOS**: giới hạn nghiêm ngặt — `Background Tasks`, `BGProcessingTask`, background audio/location. iOS "đóng băng" app nền để tiết kiệm pin.
- **Flutter**: dùng plugin như `workmanager`, `flutter_background_service`, `just_audio` (nhạc nền). Bản chất vẫn là service của nền tảng bên dưới.

> ⚠️ Điện thoại rất khắt khe với service nền để tiết kiệm **pin**. OS có thể "giết" service của bạn bất cứ lúc nào khi thiếu tài nguyên.

---

## 7. Vòng Đời & Trạng Thái Của Một Thread/Process

OS quản lý mỗi luồng qua một máy trạng thái. CPU chỉ chạy được thread ở trạng thái **RUNNING**.

```
      tạo mới
        │
        ▼
   ┌─────────┐   được scheduler chọn   ┌──────────┐
   │  READY  │ ──────────────────────▶ │ RUNNING  │
   │ (sẵn    │ ◀────────────────────── │(đang chạy│
   │  sàng)  │   hết lượt (time slice) │ trên CPU)│
   └─────────┘                         └────┬─────┘
        ▲                                   │ chờ I/O
        │ I/O xong,                          │ (đọc file/mạng)
        │ đánh thức                          ▼
        │                             ┌──────────────┐
        └──────────────────────────── │   BLOCKED    │
                                      │ (chờ, ngủ)   │
                                      └──────────────┘
                                            │ xong việc
                                            ▼
                                       ┌──────────┐
                                       │TERMINATED│
                                       └──────────┘
```

- **READY**: sẵn sàng, đang xếp hàng chờ CPU.
- **RUNNING**: đang thực sự chạy trên một core CPU.
- **BLOCKED/WAITING**: đang chờ I/O (mạng, file). **Không chiếm CPU** — CPU đi làm việc khác. *Đây chính là bản chất của async!*
- **TERMINATED**: xong.

> 💡 Async/await của Dart (Bài 05) chính là cơ chế đưa công việc vào trạng thái "chờ I/O" mà **không khóa CPU**. Khi mạng trả về, event loop đánh thức nó dậy.

---

## 8. Câu Hỏi Ôn Tập

1. System call là gì? Vì sao I/O lại "đắt" hơn tính toán thuần?
2. Process và Thread khác nhau ở **bộ nhớ** ra sao? Cái nào dễ gây race condition?
3. Vì sao một thread crash có thể làm sập cả process, còn một process crash thì không?
4. Service khác thread thường ở điểm nào? Vì sao điện thoại hạn chế service nền?
5. Khi thread đang chờ mạng (BLOCKED), CPU làm gì? Điều này liên hệ với async thế nào?

---

> ➡️ **Bài tiếp theo**: [03 — Lập lịch CPU, Concurrency vs Parallelism](./03_scheduling_va_concurrency.md)
> ⬅️ Quay lại: [01 — Phần cứng](./01_phan_cung_cpu_gpu_ram_rom.md)
