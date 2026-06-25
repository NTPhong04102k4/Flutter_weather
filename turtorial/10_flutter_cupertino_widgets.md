# 📘 Bài 10: Cupertino Widgets (iOS-style) Trong Flutter

> **Mục tiêu**: Thành thạo iOS-style widgets, biết khi nào dùng Material vs Cupertino.

---

## 1. Tại Sao Cần Cupertino Widgets?

```
Material Design → Google (Android)
Cupertino Design → Apple (iOS)

Khi nào dùng?
├── Chỉ target Android → Material
├── Chỉ target iOS → Cupertino
├── Cả 2 platform →
│   ├── Option 1: Material cho tất cả (phổ biến nhất)
│   ├── Option 2: Platform-adaptive (tự chuyển đổi theo OS)
│   └── Option 3: Custom design (không theo chuẩn nào)
```

---

## 2. CupertinoApp — Gốc Của App iOS-style

```dart
import 'package:flutter/cupertino.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'iOS App',
      debugShowCheckedModeBanner: false,

      // Theme iOS
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      home: const HomePage(),
    );
  }
}
```

---

## 3. CupertinoPageScaffold & CupertinoNavigationBar

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Navigation bar iOS-style
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Trang chủ'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bars),
          onPressed: () {},
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {},
        ),
        // Large title (iOS 11+ style)
        // previousPageTitle: 'Back',
      ),

      // Body
      child: SafeArea(
        child: Center(
          child: Text('Nội dung trang',
              style: CupertinoTheme.of(context).textTheme.textStyle),
        ),
      ),
    );
  }
}

// Large title navigation (scroll to collapse)
class LargeTitlePage extends StatelessWidget {
  const LargeTitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          // Large title that collapses on scroll
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Cài đặt'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: null,
              child: Text('Sửa'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => CupertinoListTile(
                title: Text('Mục $index'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. Cupertino Buttons

```dart
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Buttons')),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- CupertinoButton (cơ bản) ---
            CupertinoButton(
              onPressed: () => print('Pressed!'),
              child: const Text('Cupertino Button'),
            ),

            // --- CupertinoButton.filled ---
            CupertinoButton.filled(
              onPressed: () {},
              child: const Text('Filled Button'),
            ),

            // --- Custom styled ---
            CupertinoButton(
              color: CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              onPressed: () {},
              child: const Text('Xóa tài khoản',
                  style: TextStyle(color: CupertinoColors.white)),
            ),

            // --- Disabled ---
            const CupertinoButton(
              onPressed: null,   // Disabled
              child: Text('Disabled Button'),
            ),

            // --- Icon button ---
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.heart_fill,
                  color: CupertinoColors.systemRed, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. CupertinoTextField

```dart
class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextField iOS-style cơ bản
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Nhập tên',
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.person, color: CupertinoColors.systemGrey),
          ),
          padding: const EdgeInsets.all(12),
          clearButtonMode: OverlayVisibilityMode.editing,   // Nút xóa khi đang gõ
        ),

        const SizedBox(height: 12),

        // TextField với decoration
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
        ),

        const SizedBox(height: 12),

        // Search field iOS-style
        CupertinoSearchTextField(
          placeholder: 'Tìm kiếm...',
          onChanged: (value) => print('Search: $value'),
          onSubmitted: (value) => print('Submit: $value'),
        ),
      ],
    );
  }
}
```

---

## 6. CupertinoSwitch, CupertinoSlider, CupertinoSegmentedControl

```dart
class ControlsDemo extends StatefulWidget {
  const ControlsDemo({super.key});

  @override
  State<ControlsDemo> createState() => _ControlsDemoState();
}

class _ControlsDemoState extends State<ControlsDemo> {
  bool _darkMode = false;
  bool _notifications = true;
  double _fontSize = 16;
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: const Text('CÀI ĐẶT'),
      children: [
        // --- CupertinoSwitch ---
        CupertinoListTile(
          title: const Text('Chế độ tối'),
          leading: const Icon(CupertinoIcons.moon_fill,
              color: CupertinoColors.systemIndigo),
          trailing: CupertinoSwitch(
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),
        ),

        CupertinoListTile(
          title: const Text('Thông báo'),
          leading: const Icon(CupertinoIcons.bell_fill,
              color: CupertinoColors.systemRed),
          trailing: CupertinoSwitch(
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
        ),

        // --- CupertinoSlider ---
        CupertinoListTile(
          title: Text('Cỡ chữ: ${_fontSize.toInt()}'),
          leading: const Icon(CupertinoIcons.textformat_size,
              color: CupertinoColors.systemGreen),
          trailing: SizedBox(
            width: 150,
            child: CupertinoSlider(
              value: _fontSize,
              min: 12,
              max: 32,
              divisions: 20,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
          ),
        ),

        // --- CupertinoSegmentedControl ---
        Padding(
          padding: const EdgeInsets.all(16),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedSegment,
            onValueChanged: (value) {
              setState(() => _selectedSegment = value!);
            },
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Ngày'),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Tuần'),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Tháng'),
              ),
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 7. CupertinoAlertDialog & CupertinoActionSheet

```dart
void _showAlertDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Xóa ảnh?'),
      content: const Text('Bạn có chắc muốn xóa ảnh này? '
          'Hành động này không thể hoàn tác.'),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Hủy'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,   // Chữ đỏ — hành động nguy hiểm
          child: const Text('Xóa'),
          onPressed: () {
            Navigator.pop(context);
            // Xóa ảnh...
          },
        ),
      ],
    ),
  );
}

void _showActionSheet(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: const Text('Chia sẻ'),
      message: const Text('Chọn cách chia sẻ'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tin nhắn'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Email'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Sao chép liên kết'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
    ),
  );
}
```

---

## 8. CupertinoDatePicker & CupertinoPicker

```dart
void _showDatePicker(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          // Header với nút Done
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: const Text('Xong'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          // Date Picker
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: DateTime.now(),
              minimumDate: DateTime(2020),
              maximumDate: DateTime(2030),
              use24hFormat: true,
              onDateTimeChanged: (DateTime date) {
                print('Selected: $date');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// Picker wheel (chọn giá trị từ danh sách)
void _showPicker(BuildContext context) {
  final items = ['Hà Nội', 'TP.HCM', 'Đà Nẵng', 'Huế', 'Cần Thơ'];
  showCupertinoModalPopup(
    context: context,
    builder: (context) => Container(
      height: 250,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: CupertinoPicker(
        itemExtent: 40,
        onSelectedItemChanged: (index) {
          print('Selected: ${items[index]}');
        },
        children: items.map((item) => Center(child: Text(item))).toList(),
      ),
    ),
  );
}
```

---

## 9. CupertinoTabScaffold — Bottom Tab Navigation

```dart
class TabApp extends StatelessWidget {
  const TabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_fill),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Cá nhân',
          ),
        ],
        activeColor: CupertinoColors.systemBlue,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const HomePage();
              case 1:
                return const SearchPage();
              case 2:
                return const FavoritesPage();
              case 3:
                return const ProfilePage();
              default:
                return const HomePage();
            }
          },
        );
      },
    );
  }
}
```

---

## 10. CupertinoContextMenu

```dart
CupertinoContextMenu(
  actions: [
    CupertinoContextMenuAction(
      child: const Text('Sao chép'),
      trailingIcon: CupertinoIcons.doc_on_clipboard,
      onPressed: () => Navigator.pop(context),
    ),
    CupertinoContextMenuAction(
      child: const Text('Chia sẻ'),
      trailingIcon: CupertinoIcons.share,
      onPressed: () => Navigator.pop(context),
    ),
    CupertinoContextMenuAction(
      isDestructiveAction: true,
      child: const Text('Xóa'),
      trailingIcon: CupertinoIcons.delete,
      onPressed: () => Navigator.pop(context),
    ),
  ],
  child: Container(
    width: 200,
    height: 200,
    color: CupertinoColors.systemBlue,
    child: const Center(
      child: Text('Nhấn giữ tôi', style: TextStyle(color: CupertinoColors.white)),
    ),
  ),
)
```

---

## 11. So Sánh Material vs Cupertino

| Thành phần | Material | Cupertino |
|:-----------|:---------|:----------|
| App root | `MaterialApp` | `CupertinoApp` |
| Page scaffold | `Scaffold` | `CupertinoPageScaffold` |
| App bar | `AppBar` | `CupertinoNavigationBar` |
| Button | `ElevatedButton` | `CupertinoButton` |
| Text field | `TextField` | `CupertinoTextField` |
| Switch | `Switch` | `CupertinoSwitch` |
| Slider | `Slider` | `CupertinoSlider` |
| Dialog | `AlertDialog` | `CupertinoAlertDialog` |
| Date picker | `showDatePicker` | `CupertinoDatePicker` |
| Tab bar | `BottomNavigationBar` | `CupertinoTabBar` |
| Action sheet | `BottomSheet` | `CupertinoActionSheet` |
| Loading | `CircularProgressIndicator` | `CupertinoActivityIndicator` |
| List section | `ListView` | `CupertinoListSection` |

---

## 12. Platform-Adaptive Widget

Tự động chọn Material hoặc Cupertino dựa trên OS:

```dart
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(text),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Adaptive Dialog
Future<bool?> showAdaptiveConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Xác nhận'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: iOS Settings Page
Tạo trang cài đặt kiểu iOS với: `CupertinoListSection.insetGrouped`, switches, và navigation.

### Bài 2: Platform-Adaptive App
Tạo app hiển thị Material widgets trên Android và Cupertino widgets trên iOS.

### Bài 3: iOS Shopping App
Tạo app mua sắm iOS-style với: `CupertinoTabScaffold`, `CupertinoSearchTextField`, `CupertinoContextMenu`.

---

> **Bài tiếp theo**: [11 - Custom Widgets & Painting](./11_flutter_custom_widgets.md)
