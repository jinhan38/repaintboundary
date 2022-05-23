import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RepaintBoundary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey _paintKey = new GlobalKey();
  Offset _offset = Offset.zero;

  Widget _buildBackground() {
    return RepaintBoundary(
      child: CustomPaint(
        painter: MyExpensiveBackground(MediaQuery.of(context).size),
        isComplex: true,
        willChange: false,
      ),
    );
  }

  Widget _buildCursor() {
    return Listener(
      onPointerDown: _updateOffset,
      onPointerMove: _updateOffset,
      child: CustomPaint(
        painter: MyPointer(_offset),
        key: _paintKey,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
        ),
      ),
    );
  }

  _updateOffset(PointerEvent event) {
    RenderBox? referenceBox =
        _paintKey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = referenceBox.globalToLocal(event.position);
    setState(() {
      _offset = offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RepaintBoundary"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildCursor(),
        ],
      ),
    );
  }
}

class MyExpensiveBackground extends CustomPainter {
  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.orange,
  ];

  Size _size;

  MyExpensiveBackground(this._size);

  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(12345);
    for (int i = 0; i < 10000; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(random.nextDouble() * _size.width - 100,
              random.nextDouble() * _size.height),
          width: random.nextDouble() * random.nextInt(150) + 200,
          height: random.nextDouble() * random.nextInt(150) + 200,
        ),
        Paint()..color = colors[random.nextInt(colors.length)].withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(MyExpensiveBackground old) {
    return false;
  }
}

class MyPointer extends CustomPainter {
  final Offset _offset;

  MyPointer(this._offset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      _offset,
      10,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(MyPointer old) {
    return old._offset != _offset;
  }

}
