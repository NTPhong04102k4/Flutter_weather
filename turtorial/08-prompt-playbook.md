# Prompt playbook de AI lam nhanh dung module

## Cong thuc prompt

```text
Muc tieu: <ket qua mong muon>
Pham vi: <folder/file/symbol cu the>
Khong duoc sua: <danh sach cam sua>
Dau vao lien quan: <log/stacktrace/buoc tai hien>
Tieu chi xong viec: <test/lint/chuc nang pass>
Output: <root cause + file da sua + cach test lai>
```

## Mau prompt native module

```text
Chi sua Android native:
- android/app/src/main/kotlin/.../WeatherChannel.kt
Doc kem:
- MainActivity.kt
Khong sua:
- tat ca file Dart
```

## Mau prompt fix bug module

```text
Fix bug chi trong weather module:
- lib/features/weather/data/*
- lib/features/weather/presentation/*
Trieu chung: <mo ta + stacktrace>
```
