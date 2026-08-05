import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ScribbleCanvasWidget extends StatefulWidget {
  final Function(Uint8List?) onImageExported;

  const ScribbleCanvasWidget({super.key, required this.onImageExported});

  @override
  State<ScribbleCanvasWidget> createState() => _ScribbleCanvasWidgetState();
}

class _ScribbleCanvasWidgetState extends State<ScribbleCanvasWidget> {
  late ScribbleNotifier _notifier;

  double _strokeWidth = 4;
  Color _currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _notifier = ScribbleNotifier();
  }

  /// Export drawing as PNG
  Future<void> _exportDrawing() async {
    final imageBytes = await _notifier.renderImage();

    if (imageBytes != null) {
      widget.onImageExported(imageBytes as Uint8List?);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Drawing saved as image 🎨"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openColorPicker() {
    Color tempColor = _currentColor;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Pick Color"),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tempColor,
                enableAlpha: false,
                onColorChanged: (color) {
                  tempColor = color;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentColor = tempColor;
                  });
                  _notifier.setColor(tempColor);
                  Navigator.pop(context);
                },
                child: const Text("Select"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canvasColor = isDark ? Colors.grey.shade900 : Colors.white;

    final borderColor = isDark ? Colors.white24 : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Draw Something",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _notifier.canUndo ? _notifier.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: _notifier.canRedo ? _notifier.redo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _notifier.clear,
                ),
                IconButton(
                  icon: Icon(Icons.color_lens, color: _currentColor),
                  onPressed: _openColorPicker,
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _exportDrawing,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// Brush Size
        Row(
          children: [
            const Text("Brush"),
            Expanded(
              child: Slider(
                min: 1,
                max: 20,
                value: _strokeWidth,
                onChanged: (value) {
                  setState(() {
                    _strokeWidth = value;
                  });
                  _notifier.setStrokeWidth(value);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// Canvas
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Scribble(notifier: _notifier),
          ),
        ),
      ],
    );
  }
}
