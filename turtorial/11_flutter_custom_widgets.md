# 📘 Bài 11: Custom Widgets & Painting Trong Flutter

> **Mục tiêu**: Tạo Custom Widget, CustomPaint, Sliver, và responsive design.

---

## 1. Custom Widget: Composition vs Inheritance

### 1.1. Composition — Ghép widget có sẵn (Ưu tiên!)

```dart
class PriceTag extends StatelessWidget {
  final double price;
  final double? originalPrice;   // Giá gốc (nếu có giảm giá)
  final String currency;

  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = '₫',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = originalPrice != null && originalPrice! > price;
    final discountPercent = hasDiscount
        ? ((1 - price / originalPrice!) * 100).round()
        : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Giá hiện tại
        Text(
          '${price.toStringAsFixed(0)}$currency',
          style: theme.textTheme.titleLarge?.copyWith(
            color: hasDiscount ? Colors.red : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (hasDiscount) ...[
          const SizedBox(width: 8),
          // Giá gốc (gạch ngang)
          Text(
            '${originalPrice!.toStringAsFixed(0)}$currency',
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          // Badge giảm giá
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-$discountPercent%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

// Sử dụng
PriceTag(price: 150000, originalPrice: 200000)
// Hiển thị: 150000₫  ~~200000₫~~  -25%
```

### 1.2. Reusable Widget Library

```dart
/// Avatar với badge trạng thái online/offline
class StatusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;
  final bool isOnline;

  const StatusAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.radius = 24,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null ? Text(initials) : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 2. CustomPaint & CustomPainter 🎨

Vẽ bất kỳ thứ gì lên canvas: shapes, paths, gradients, charts,...

### 2.1. Cơ bản

```dart
class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint = cọ vẽ (cấu hình màu, style,...)
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill   // fill hoặc stroke
      ..strokeWidth = 3;

    // Vẽ hình tròn
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),   // Tâm
      50,                                          // Bán kính
      paint,
    );

    // Vẽ hình chữ nhật
    final rectPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(10, 10, 100, 60),
      rectPaint,
    );

    // Vẽ đường thẳng
    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), linePaint);

    // Vẽ hình tròn có gradient
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.purple, Colors.orange],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;   // true nếu cần vẽ lại khi data thay đổi
  }
}

// Sử dụng
CustomPaint(
  size: const Size(300, 200),
  painter: MyCustomPainter(),
)
```

### 2.2. Vẽ Path — Hình phức tạp

```dart
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height * 0.75);

    // Bezier curve tạo sóng
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.5);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Sử dụng
ClipPath(
  clipper: WaveClipper(),
  child: Container(
    height: 200,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
)
```

### 2.3. Progress Ring (Animated)

```dart
class ProgressRingPainter extends CustomPainter {
  final double progress;   // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    this.color = Colors.blue,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,                    // Bắt đầu từ 12h (- π/2)
      progress * 2 * 3.14159,     // Góc quét
      false,
      progressPaint,
    );

    // Text phần trăm
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

---

## 3. Clipping — Cắt hình

```dart
// ClipRRect — Bo tròn góc
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: Image.network('https://picsum.photos/200', fit: BoxFit.cover),
)

// ClipOval — Hình tròn/ellipse
ClipOval(
  child: Image.network(
    'https://picsum.photos/200',
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  ),
)

// ClipPath — Cắt theo path tùy chỉnh
ClipPath(
  clipper: WaveClipper(),   // Custom clipper
  child: Container(height: 200, color: Colors.blue),
)
```

---

## 4. CustomScrollView & Slivers 🔥

Slivers = các phần tử cuộn (scroll) với hành vi tùy chỉnh.

```dart
class SliverDemo extends StatelessWidget {
  const SliverDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- SliverAppBar (co dãn khi scroll) ---
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,   // Giữ lại khi scroll
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Weather App'),
              background: Image.network(
                'https://picsum.photos/800/400',
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),

          // --- SliverToBoxAdapter (widget đơn) ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tiêu đề phần',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- SliverList (danh sách) ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Item $index'),
                leading: CircleAvatar(child: Text('$index')),
              ),
              childCount: 10,
            ),
          ),

          // --- SliverGrid ---
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                child: Center(child: Text('Grid $index')),
              ),
              childCount: 6,
            ),
          ),

          // --- SliverPadding ---
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Thêm nội dung'),
                const SizedBox(height: 100),
              ]),
            ),
          ),

          // --- SliverFillRemaining (chiếm hết phần còn lại) ---
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Hết nội dung')),
          ),
        ],
      ),
    );
  }
}
```

### 4.1. ScrollController — điều khiển & quan sát cuộn

`ScrollController` cho phép đọc vị trí, cuộn tới điểm bất kỳ, và phát hiện chạm đáy (để phân trang):

```dart
class _FeedState extends State<Feed> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final pos = _controller.position;
      // Cách vị trí đáy < 300px → tải thêm (infinite scroll)
      if (pos.pixels >= pos.maxScrollExtent - 300 && !_loading) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();   // BẮT BUỘC
    super.dispose();
  }

  void _scrollToTop() => _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );   // hoặc _controller.jumpTo(0) để nhảy tức thì

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: _controller,      // gắn controller
        itemCount: _items.length,
        itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
      );
}
```

### 4.2. NotificationListener — nghe sự kiện cuộn không cần controller

```dart
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    if (n is ScrollStartNotification) {} // bắt đầu cuộn (ẩn FAB...)
    if (n is ScrollEndNotification)   {} // ngừng cuộn
    if (n is OverscrollNotification)  {} // cuộn quá mép
    return false;   // false = cho notification tiếp tục nổi lên trên
  },
  child: ListView(children: const [/* ... */]),
)
```

### 4.3. Pull-to-refresh & physics

```dart
RefreshIndicator(
  onRefresh: () async {           // PHẢI trả Future — spinner ẩn khi future xong
    await _reload();
  },
  child: ListView(
    // Luôn cuộn được để kéo refresh, kể cả khi ít item:
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [/* ... */],
  ),
)

// ScrollPhysics thường dùng:
// BouncingScrollPhysics       → nảy kiểu iOS
// ClampingScrollPhysics       → dừng cứng kiểu Android
// NeverScrollableScrollPhysics→ khóa cuộn (VD ListView trong ListView)
```

### 4.4. NestedScrollView — SliverAppBar + TabBar cuộn đồng bộ

Header co lại khi cuộn, phần thân là các tab cuộn độc lập (giống trang profile):

```dart
NestedScrollView(
  headerSliverBuilder: (context, innerBoxScrolled) => [
    SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: const FlexibleSpaceBar(title: Text('Hồ sơ')),
      bottom: const TabBar(tabs: [Tab(text: 'Bài viết'), Tab(text: 'Ảnh')]),
    ),
  ],
  body: const TabBarView(children: [PostsTab(), PhotosTab()]),
)
```

> 💡 **Hiệu năng**: luôn dùng `ListView.builder`/`GridView.builder` (lazy — chỉ dựng item trong tầm nhìn) thay cho `ListView(children: [...])` khi danh sách dài. `ListView.separated` khi cần dải phân cách.

---

## 5. Responsive Design

### 5.1. MediaQuery

```dart
@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  final height = size.height;
  final padding = MediaQuery.of(context).padding;   // Safe area
  final orientation = MediaQuery.of(context).orientation;
  final textScale = MediaQuery.of(context).textScaleFactor;

  // Breakpoints phổ biến
  bool isMobile = width < 600;
  bool isTablet = width >= 600 && width < 1200;
  bool isDesktop = width >= 1200;

  if (isMobile) {
    return MobileLayout();
  } else if (isTablet) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

### 5.2. LayoutBuilder

```dart
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth = chiều rộng tối đa có sẵn
        int crossAxisCount;
        if (constraints.maxWidth < 400) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 800) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 20,
          itemBuilder: (context, index) => Card(
            child: Center(child: Text('Item $index')),
          ),
        );
      },
    );
  }
}
```

### 5.3. Responsive Helper Class

```dart
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200 && desktop != null) return desktop!;
    if (width >= 600 && tablet != null) return tablet!;
    return mobile;
  }
}

// Sử dụng
Responsive(
  mobile: MobileHomePage(),
  tablet: TabletHomePage(),
  desktop: DesktopHomePage(),
)
```

---

## 6. AspectRatio & FractionallySizedBox

```dart
// AspectRatio — giữ tỷ lệ
AspectRatio(
  aspectRatio: 16 / 9,   // Tỷ lệ video
  child: Container(color: Colors.blue),
)

// FractionallySizedBox — kích thước theo % parent
FractionallySizedBox(
  widthFactor: 0.8,    // 80% chiều rộng parent
  heightFactor: 0.5,   // 50% chiều cao parent
  child: Container(color: Colors.red),
)

// ConstrainedBox — giới hạn kích thước
ConstrainedBox(
  constraints: const BoxConstraints(
    minWidth: 100,
    maxWidth: 400,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: Container(color: Colors.green),
)
```

---

## 📝 Bài Tập Thực Hành

### Bài 1: Custom Rating Widget
Tạo widget hiển thị rating (1-5 sao) có thể tap để chọn. Hỗ trợ half-star.

### Bài 2: CustomPaint Chart
Dùng `CustomPaint` vẽ bar chart đơn giản từ `List<double>`.

### Bài 3: Sliver Profile Page
Tạo trang profile với `SliverAppBar` (ảnh bìa co dãn), avatar, và danh sách bài viết.

### Bài 4: Responsive Dashboard
Tạo dashboard responsive: 1 cột trên mobile, 2 cột trên tablet, 4 cột trên desktop.

---

> **Bài tiếp theo**: [12 - Navigation & Routing](./12_flutter_navigation.md)
