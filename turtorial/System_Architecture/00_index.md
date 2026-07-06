# 🏛️ System Architecture — Phần Cứng, Hệ Điều Hành, Process & Thread

> **Mục tiêu bộ tài liệu**: Hiểu **từ tầng đáy** — CPU, GPU, RAM, ROM điều khiển hệ thống ra sao; OS đứng giữa làm trọng tài thế nào; phân biệt rõ **Process — Thread — Service**; và cuối cùng app (đặc biệt Flutter/Dart) *điều khiển* luồng ra sao để chạy mượt.
>
> Đọc bộ này giúp bạn hiểu **bản chất phần dưới** của các bài Async (05), Race Condition (07), Call API (15), Platform Channels (17).

---

## 🗺️ Bản Đồ Tư Duy

```
┌─────────────────────────────────────────────────────────────┐
│  BÀI 01: PHẦN CỨNG                                           │
│  CPU (xử lý) · RAM (đang chạy) · ROM (lưu trữ) · GPU (vẽ)   │
├─────────────────────────────────────────────────────────────┤
│  BÀI 02: HỆ ĐIỀU HÀNH — TRỌNG TÀI                           │
│  User/Kernel space · System Call · Process vs Thread vs Svc │
├─────────────────────────────────────────────────────────────┤
│  BÀI 03: LẬP LỊCH CPU                                        │
│  Scheduler · Context Switch · Concurrency vs Parallelism    │
├─────────────────────────────────────────────────────────────┤
│  BÀI 04: APP ĐIỀU KHIỂN LUỒNG                               │
│  Thread Pool · 4 thread của Flutter · Isolate · Cheat Sheet │
└─────────────────────────────────────────────────────────────┘
```

---

## 📖 Danh Sách Bài

| # | Bài học | Nội dung chính |
|:--|:--------|:---------------|
| 01 | [Phần cứng: CPU, GPU, RAM, ROM](./01_phan_cung_cpu_gpu_ram_rom.md) | Kiến trúc phân lớp, memory hierarchy, stack vs heap, GPU vẽ frame |
| 02 | [Hệ điều hành, Process & Thread](./02_he_dieu_hanh_process_thread.md) | User/Kernel space, system call, **phân biệt Process/Thread/Service**, vòng đời thread |
| 03 | [Scheduling & Concurrency](./03_scheduling_va_concurrency.md) | Context switch, scheduler, **concurrency vs parallelism** |
| 04 | [App điều khiển thread & Flutter](./04_ung_dung_dieu_khien_thread_flutter.md) | Thread pool, 4 thread Flutter, **Isolate**, toàn cảnh từ chạm màn hình → hiển thị |

---

## 🎯 Sau Khi Học Xong Bạn Sẽ Trả Lời Được

- Vì sao app **không** được điều khiển CPU trực tiếp mà phải qua OS?
- **Process** khác **Thread** ở bộ nhớ ra sao? **Service** là gì?
- Tại từng thời điểm, **CPU / GPU / RAM / ROM** đang làm gì khi app chạy?
- **Concurrency** và **Parallelism** khác nhau thế nào? Dart thuộc loại nào?
- Vì sao app **giật (jank)** và cách dùng **Isolate** để giữ 60 FPS?

---

## 🔗 Liên Kết Với Lộ Trình Chính

Bộ này là **nền tảng hệ thống** bổ trợ cho:
- [Bài 05 — Lập trình bất đồng bộ](../05_dart_async_programming.md)
- [Bài 07 — Race Condition & Cache](../07_dart_race_condition_and_cache.md)
- [Bài 15 — Gọi API](../15_flutter_call_api.md)
- [Bài 17 — Platform Channels](../17_flutter_platform_channels.md)

> 🏠 [Về mục lục tổng](../00_index.md)
