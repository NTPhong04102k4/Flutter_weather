# 📘 Bài 18: Camera, Bluetooth, File Upload, Cử Chỉ & Animation

> **Mục tiêu**: Sử dụng camera, Bluetooth, upload file, gestures, và animation trong Flutter.

---

## PHẦN A: CAMERA & FILE

## 1. Camera — Chụp Ảnh & Quay Video

```yaml
dependencies:
  camera: ^0.11.0
  path_provider: ^2.1.0
  path: ^1.9.0
```

```dart
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _controller = CameraController(
      _cameras[0],   // Camera sau
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // Chụp ảnh
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      print('Ảnh lưu tại: ${photo.path}');

      // Hiển thị preview
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PhotoPreview(imagePath: photo.path),
        ));
      }
    } catch (e) {
      print('Lỗi chụp ảnh: $e');
    }
  }

  // Quay video
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final XFile video = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      print('Video: ${video.path}');
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  // Chuyển camera trước/sau
  Future<void> _switchCamera() async {
    final currentIndex = _cameras.indexOf(_controller!.description);
    final nextIndex = (currentIndex + 1) % _cameras.length;

    _controller = CameraController(_cameras[nextIndex], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_controller!),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                  onPressed: _switchCamera,
                ),
                GestureDetector(
                  onTap: _takePicture,
                  onLongPress: _toggleRecording,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 48),   // Spacer
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

---

## 2. File Upload — Image Picker & File Picker

```yaml
dependencies:
  image_picker: ^1.1.0
  file_picker: ^8.0.0
  dio: ^5.4.0   # Để upload
```

```dart
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class FileUploadService {
  final _picker = ImagePicker();
  final _dio = Dio();

  // Chọn ảnh từ gallery
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,   // Nén 80%
    );
  }

  // Chụp ảnh mới
  Future<XFile?> takePhoto() async {
    return await _picker.pickImage(source: ImageSource.camera);
  }

  // Chọn nhiều ảnh
  Future<List<XFile>> pickMultipleImages() async {
    return await _picker.pickMultiImage(imageQuality: 80);
  }

  // Chọn file bất kỳ
  Future<FilePickerResult?> pickFile() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      allowMultiple: true,
    );
  }

  // Upload file với progress
  Future<String> uploadFile(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'description': 'Uploaded from Flutter',
    });

    final response = await _dio.post(
      'https://api.example.com/upload',
      data: formData,
      onSendProgress: (sent, total) {
        final progress = (sent / total * 100).toStringAsFixed(1);
        print('Upload: $progress%');
      },
    );

    return response.data['url'];
  }
}
```

---

## PHẦN B: BLUETOOTH

## 3. Bluetooth — Scan, Connect, Read/Write

```yaml
dependencies:
  flutter_blue_plus: ^1.32.0
```

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Kiểm tra Bluetooth có bật không
  Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // Scan thiết bị
  Stream<List<ScanResult>> scanDevices() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Kết nối
  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
  }

  // Đọc services & characteristics
  Future<void> readData(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.read) {
          final value = await char.read();
          print('Data: $value');
        }
      }
    }
  }

  // Ghi dữ liệu
  Future<void> writeData(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    await characteristic.write(data);
  }

  // Ngắt kết nối
  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
```

---

## PHẦN C: CỬ CHỈ (GESTURES)

## 4. GestureDetector

```dart
class GestureDemo extends StatefulWidget {
  @override
  State<GestureDemo> createState() => _GestureDemoState();
}

class _GestureDemoState extends State<GestureDemo> {
  String _lastGesture = 'Chưa có';
  Offset _position = Offset.zero;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Cử chỉ: $_lastGesture'),

        // Tap, Double tap, Long press
        GestureDetector(
          onTap: () => setState(() => _lastGesture = 'Tap'),
          onDoubleTap: () => setState(() => _lastGesture = 'Double Tap'),
          onLongPress: () => setState(() => _lastGesture = 'Long Press'),
          child: Container(width: 200, height: 100, color: Colors.blue,
            child: const Center(child: Text('Tap me', style: TextStyle(color: Colors.white)))),
        ),

        const SizedBox(height: 20),

        // Drag (kéo thả)
        GestureDetector(
          onPanUpdate: (details) {
            setState(() => _position += details.delta);
          },
          onPanEnd: (_) => setState(() => _lastGesture = 'Drag End'),
          child: Transform.translate(
            offset: _position,
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          ),
        ),

        // Pinch to zoom
        GestureDetector(
          onScaleUpdate: (details) {
            setState(() => _scale = details.scale);
          },
          child: Transform.scale(
            scale: _scale,
            child: Image.network('https://picsum.photos/200', width: 200),
          ),
        ),
      ],
    );
  }
}
```

### Dismissible — Vuốt để xóa

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Dismissible(
      key: ValueKey(items[index].id),
      direction: DismissDirection.endToStart,   // Vuốt phải → trái
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xác nhận xóa?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        setState(() => items.removeAt(index));
      },
      child: ListTile(title: Text(items[index].name)),
    );
  },
)
```

### Draggable & DragTarget

```dart
// Draggable — widget có thể kéo
Draggable<String>(
  data: 'Hello',   // Data truyền khi drop
  feedback: Material(
    child: Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.withOpacity(0.8),
      child: const Text('Đang kéo...', style: TextStyle(color: Colors.white)),
    ),
  ),
  childWhenDragging: Container(color: Colors.grey),
  child: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.blue,
    child: const Text('Kéo tôi!', style: TextStyle(color: Colors.white)),
  ),
)

// DragTarget — vùng thả
DragTarget<String>(
  onAcceptWithDetails: (details) {
    print('Nhận: ${details.data}');
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      width: 200, height: 200,
      color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
      child: const Center(child: Text('Thả vào đây')),
    );
  },
)
```

---

## PHẦN D: ANIMATION 🔥

## 5. Implicit Animations (Đơn giản)

Flutter tự tính toán animation khi giá trị thay đổi.

```dart
class ImplicitAnimDemo extends StatefulWidget {
  @override
  State<ImplicitAnimDemo> createState() => _ImplicitAnimDemoState();
}

class _ImplicitAnimDemoState extends State<ImplicitAnimDemo> {
  bool _expanded = false;
  double _opacity = 1.0;
  Color _color = Colors.blue;
  double _borderRadius = 0;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _opacity = _expanded ? 0.5 : 1.0;
      _color = _expanded ? Colors.red : Colors.blue;
      _borderRadius = _expanded ? 50 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Column(
        children: [
          // AnimatedContainer — animate mọi property
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _expanded ? 300 : 150,
            height: _expanded ? 300 : 150,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: const Center(child: Text('Tap me')),
          ),

          const SizedBox(height: 20),

          // AnimatedOpacity
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _opacity,
            child: Container(width: 100, height: 100, color: Colors.green),
          ),

          // AnimatedPadding
          AnimatedPadding(
            duration: const Duration(milliseconds: 500),
            padding: EdgeInsets.all(_expanded ? 50 : 10),
            child: Container(width: 100, height: 100, color: Colors.orange),
          ),

          // AnimatedPositioned (trong Stack)
          SizedBox(
            width: 300, height: 100,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  left: _expanded ? 200 : 0,
                  top: _expanded ? 50 : 0,
                  child: Container(width: 50, height: 50, color: Colors.purple),
                ),
              ],
            ),
          ),

          // AnimatedCrossFade — chuyển đổi giữa 2 widget
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const Icon(Icons.play_arrow, size: 48),
            secondChild: const Icon(Icons.pause, size: 48),
          ),

          // AnimatedSwitcher — chuyển đổi bất kỳ widget
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              _expanded ? 'Expanded' : 'Collapsed',
              key: ValueKey(_expanded),   // Key PHẢI khác để trigger animation
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Explicit Animations (Nâng cao)

Kiểm soát hoàn toàn: duration, direction, repeat, reverse.

```dart
class ExplicitAnimDemo extends StatefulWidget {
  @override
  State<ExplicitAnimDemo> createState() => _ExplicitAnimDemoState();
}

class _ExplicitAnimDemoState extends State<ExplicitAnimDemo>
    with SingleTickerProviderStateMixin {   // Quan trọng!
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // AnimationController — điều khiển animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,   // Sync với refresh rate màn hình
    );

    // Tween — giá trị từ A → B
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.red).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Lặp lại
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,   // child không rebuild
            ),
          ),
        );
      },
      child: const Center(child: Text('🚀', style: TextStyle(fontSize: 40))),
    );
  }

  @override
  void dispose() {
    _controller.dispose();   // PHẢI dispose!
    super.dispose();
  }
}
```

---

## 7. Hero Animation — Chuyển trang mượt mà

```dart
// Trang danh sách
class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => DetailPage(id: index),
            ));
          },
          child: Hero(
            tag: 'image_$index',   // Tag PHẢI trùng giữa 2 trang
            child: Image.network(
              'https://picsum.photos/200?random=$index',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

// Trang chi tiết
class DetailPage extends StatelessWidget {
  final int id;
  const DetailPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'image_$id',   // Cùng tag → Flutter tự animate
          child: Image.network(
            'https://picsum.photos/200?random=$id',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Lottie & Rive — Animation Packages

```yaml
dependencies:
  lottie: ^3.1.0
  rive: ^0.13.0
```

```dart
import 'package:lottie/lottie.dart';

// Lottie animation (từ file JSON)
Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  repeat: true,
)

// Lottie từ URL
Lottie.network(
  'https://assets.lottiefiles.com/packages/lf20_xxx.json',
)

// Lottie với controller
class LottieDemo extends StatefulWidget {
  @override
  State<LottieDemo> createState() => _LottieDemoState();
}

class _LottieDemoState extends State<LottieDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isCompleted) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: Lottie.asset(
        'assets/animations/like.json',
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 9. Permissions — Xin Quyền

```yaml
dependencies:
  permission_handler: ^11.3.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Xin 1 quyền
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Xin nhiều quyền
  Future<Map<Permission, PermissionStatus>> requestMultiple() async {
    return await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.storage,
    ].request();
  }

  // Kiểm tra quyền
  Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      // Mở Settings để user bật thủ công
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Image Picker + Upload
Tạo form có chọn ảnh (gallery/camera) + hiển thị preview + giả lập upload với progress bar.

### Bài 2: Animated Todo List
Tạo Todo list với animation: thêm item (slide in), xóa item (Dismissible), checkbox (scale animation).

### Bài 3: Hero Gallery
Tạo photo gallery: grid thumbnails → tap → full-screen detail với Hero animation.

---

> **Bài tiếp theo**: [19 - Phân chia môi trường](./19_flutter_environments.md)
