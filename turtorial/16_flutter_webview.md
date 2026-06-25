# 📘 Bài 16: Tích Hợp WebView Trong Flutter

> **Mục tiêu**: Nhúng WebView, giao tiếp JavaScript ↔ Flutter, quản lý cookies & permissions.

---

## 1. Setup

```yaml
# pubspec.yaml
dependencies:
  webview_flutter: ^4.8.0

  # Platform-specific (nếu cần)
  webview_flutter_android: ^3.16.0
  webview_flutter_wkwebview: ^3.14.0
```

```dart
// Android: android/app/build.gradle
// minSdkVersion 20 (hoặc cao hơn)

// iOS: không cần config thêm (dùng WKWebView mặc định)
```

---

## 2. WebView Cơ Bản

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      // Cấu hình
      ..setJavaScriptMode(JavaScriptMode.unrestricted)   // Cho phép JS
      ..setBackgroundColor(Colors.white)
      ..setUserAgent('MyApp/1.0 Flutter')

      // Navigation delegate — kiểm soát navigation
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() => _isLoading = true);
        },
        onPageFinished: (url) {
          setState(() => _isLoading = false);
        },
        onProgress: (progress) {
          setState(() => _loadingProgress = progress);
        },
        onWebResourceError: (error) {
          print('Lỗi: ${error.description}');
        },
        // Chặn/cho phép navigation
        onNavigationRequest: (request) {
          // Chặn external links
          if (request.url.contains('youtube.com')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))

      // Load URL
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
            ),
        ],
      ),
    );
  }
}
```

---

## 3. Load Các Loại Nội Dung

```dart
// 1. Load URL
_controller.loadRequest(Uri.parse('https://flutter.dev'));

// 2. Load HTML string
_controller.loadHtmlString('''
  <!DOCTYPE html>
  <html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body { font-family: -apple-system, sans-serif; padding: 20px; }
      h1 { color: #1976D2; }
      .card { background: #f5f5f5; padding: 16px; border-radius: 8px; margin: 8px 0; }
    </style>
  </head>
  <body>
    <h1>Xin chào từ Flutter!</h1>
    <div class="card">
      <p>Đây là HTML được render bởi WebView</p>
    </div>
    <button onclick="sendToFlutter('Hello from JS!')">Gửi về Flutter</button>
  </body>
  </html>
''');

// 3. Load local HTML file (đặt trong assets/)
// Cần đọc file từ assets rồi dùng loadHtmlString
```

---

## 4. JavaScript ↔ Flutter Communication 🔥

### 4.1. Flutter gọi JavaScript

```dart
// Chạy JavaScript từ Flutter
Future<void> _runJavaScript() async {
  // Thực thi JS
  await _controller.runJavaScript('''
    document.body.style.backgroundColor = '#e3f2fd';
    document.title = 'Modified by Flutter';
  ''');

  // Thực thi JS và nhận kết quả
  final result = await _controller.runJavaScriptReturningResult('''
    JSON.stringify({
      title: document.title,
      url: window.location.href,
      scrollY: window.scrollY,
    })
  ''');
  print('JS result: $result');
}

// Inject CSS
await _controller.runJavaScript('''
  var style = document.createElement('style');
  style.textContent = `
    .ad-banner { display: none !important; }
    body { font-size: 18px !important; }
  `;
  document.head.appendChild(style);
''');
```

### 4.2. JavaScript gọi Flutter (JavaScriptChannel)

```dart
_controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)

  // Đăng ký channel — JS có thể gọi FlutterChannel.postMessage(...)
  ..addJavaScriptChannel(
    'FlutterChannel',
    onMessageReceived: (JavaScriptMessage message) {
      print('Nhận từ JS: ${message.message}');

      // Parse JSON message
      final data = jsonDecode(message.message);
      switch (data['type']) {
        case 'login':
          _handleLogin(data['payload']);
          break;
        case 'share':
          _handleShare(data['payload']);
          break;
        case 'navigate':
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => DetailPage(id: data['payload']['id']),
          ));
          break;
      }
    },
  )

  // Channel khác cho event tracking
  ..addJavaScriptChannel(
    'Analytics',
    onMessageReceived: (message) {
      final event = jsonDecode(message.message);
      AnalyticsService.trackEvent(event['name'], event['params']);
    },
  )

  ..loadRequest(Uri.parse('https://myapp.com'));

// JavaScript bên trong WebView:
// FlutterChannel.postMessage(JSON.stringify({
//   type: 'login',
//   payload: { email: 'user@test.com', token: 'abc123' }
// }));
//
// Analytics.postMessage(JSON.stringify({
//   name: 'button_click',
//   params: { button: 'buy_now' }
// }));
```

### 4.3. Two-way Communication Pattern

```dart
// Inject bridge function vào web page
Future<void> _setupBridge() async {
  await _controller.runJavaScript('''
    // Flutter → JS: nhận message từ Flutter
    window.addEventListener('flutter-message', function(event) {
      var data = JSON.parse(event.detail);
      console.log('Received from Flutter:', data);
      // Xử lý...
    });

    // JS → Flutter: gửi message về Flutter
    window.sendToFlutter = function(type, payload) {
      FlutterChannel.postMessage(JSON.stringify({
        type: type,
        payload: payload,
        timestamp: Date.now()
      }));
    };

    // Thông báo bridge đã sẵn sàng
    window.sendToFlutter('bridge_ready', {});
  ''');
}

// Flutter gửi message cho JS
Future<void> _sendToJs(String type, Map<String, dynamic> payload) async {
  final json = jsonEncode({'type': type, 'payload': payload});
  await _controller.runJavaScript('''
    window.dispatchEvent(new CustomEvent('flutter-message', {
      detail: '$json'
    }));
  ''');
}

// Sử dụng
await _sendToJs('update_user', {'name': 'Phong', 'theme': 'dark'});
```

---

## 5. Cookie Management

```dart
import 'package:webview_flutter/webview_flutter.dart';

final cookieManager = WebViewCookieManager();

// Set cookie
await cookieManager.setCookie(
  const WebViewCookie(
    name: 'session_id',
    value: 'abc123',
    domain: 'example.com',
    path: '/',
  ),
);

// Clear cookies
await cookieManager.clearCookies();
```

---

## 6. WebView Trong Bottom Sheet

```dart
void _showWebViewBottomSheet(BuildContext context, String url) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // URL bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(url, overflow: TextOverflow.ellipsis)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // WebView
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(url)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
```

---

## 7. Xử Lý Permissions Trong WebView

```dart
// Android: cần thêm permissions trong AndroidManifest.xml
// <uses-permission android:name="android.permission.CAMERA" />
// <uses-permission android:name="android.permission.RECORD_AUDIO" />
// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

// Xử lý file input (upload file từ WebView)
// webview_flutter tự xử lý file input trên Android
// Trên iOS, WKWebView hỗ trợ sẵn
```

---

## 8. Debug WebView

```dart
// Android: Chrome DevTools
// 1. Kết nối device qua USB
// 2. Mở Chrome → chrome://inspect
// 3. Tìm WebView của app → Inspect

// iOS: Safari Web Inspector
// 1. Kết nối device qua USB
// 2. Safari → Develop → [Device name] → [WebView]

// Enable debug trong code
if (kDebugMode) {
  // Android
  // AndroidWebViewController.enableDebugging(true);
}
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: In-app Browser
Tạo in-app browser với: URL bar, back/forward, refresh, progress bar, share button.

### Bài 2: JS ↔ Flutter Bridge
Tạo HTML form trong WebView. Khi user submit → gửi data về Flutter → hiển thị trong native dialog.

### Bài 3: Payment WebView
Giả lập payment flow: Flutter mở WebView → user "thanh toán" → WebView gửi kết quả về Flutter → Flutter hiển thị thành công/thất bại.

---

> **Bài tiếp theo**: [17 - Giao tiếp Native (Platform Channels)](./17_flutter_platform_channels.md)
