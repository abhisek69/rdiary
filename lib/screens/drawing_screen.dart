// drawing_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final GlobalKey _painterKey = GlobalKey();
  late PainterController _controller;
  Color _selectedColor = Colors.black;
  Future<ui.Image> _createWhiteImage(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }

  @override
  void initState() {
    super.initState();
    _initController(); // async init
  }

  Future<void> _initController() async {
    final whiteImage = await _createWhiteImage(1000,1000);

    setState(() {
      _controller =
          PainterController()
            ..background = ImageBackgroundDrawable(
              image: whiteImage,
              // size: const Size(1000, 1000),
            )
            ..freeStyleMode = FreeStyleMode.draw
            ..freeStyleColor = _selectedColor
            ..freeStyleStrokeWidth = 4.0;
    });
  }

  Future<void> _saveDrawing() async {
    try {
      final renderBox =
          _painterKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to get canvas size')));
        return;
      }

      final Size canvasSize = renderBox.size;
      final ui.Image rendered = await _controller.renderImage(canvasSize);
      final ByteData? byteData = await rendered.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) throw Exception("Failed to convert image");

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/draw_${const Uuid().v4()}.png");
      await file.writeAsBytes(pngBytes);

      Navigator.pop(context, file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving drawing: $e')));
    }
  }

  void _pickColor() async {
    final picked = await showDialog<Color>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Pick a color"),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) => Navigator.pop(context, color),
              ),
            ),
          ),
    );

    if (picked != null) {
      setState(() {
        _selectedColor = picked;
        _controller.freeStyleColor = _selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sketch Something"),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _controller.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _controller.redo),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveDrawing),
        ],
      ),
      body: FlutterPainter(controller: _controller, key: _painterKey),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Draw Mode',
              icon: const Icon(Icons.brush),
              onPressed:
                  () => setState(
                    () => _controller.freeStyleMode = FreeStyleMode.draw,
                  ),
            ),
            IconButton(
              tooltip: 'Erase Mode',
              icon: const Icon(Icons.remove_circle),
              onPressed:
                  () => setState(
                    () => _controller.freeStyleMode = FreeStyleMode.erase,
                  ),
            ),
            IconButton(
              tooltip: 'Clear Canvas',
              icon: const Icon(Icons.clear),
              onPressed: () => _controller.clearDrawables(),
            ),
            IconButton(
              tooltip: 'Pick Color',
              icon: const Icon(Icons.color_lens),
              onPressed: _pickColor,
            ),
          ],
        ),
      ),
    );
  }
}
