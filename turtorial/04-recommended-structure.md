# Cau truc folder khuyen nghi de scale

```text
lib/
  main.dart
  app.dart
  core/
    config/
    constants/
    network/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
      auth_module.dart
    weather/
      data/
      domain/
      presentation/
```

Nguyen tac:

- Chia theo feature truoc, khong chia theo loai file toan cuc.
- Moi feature quan ly `data/domain/presentation`.
- `core/` chi de code dung chung.
