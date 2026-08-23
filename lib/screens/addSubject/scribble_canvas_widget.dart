import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ScribbleCanvasWidget extends StatefulWidget {
  final ScribbleNotifier notifier;

  const ScribbleCanvasWidget({super.key, required this.notifier});

  @override
  State<ScribbleCanvasWidget> createState() => _ScribbleCanvasWidgetState();
}

class _ScribbleCanvasWidgetState extends State<ScribbleCanvasWidget> {
  double _strokeWidth = 4;
  Color _currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    // Use the color and stroke width from the notifier if possible
    // or set defaults
    widget.notifier.setColor(_currentColor);
    widget.notifier.setStrokeWidth(_strokeWidth);
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
                  widget.notifier.setColor(tempColor);
                  Navigator.pop(context);
                },
                child: const Text("Select"),
              ),
            ],
          ),
    );
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
            ValueListenableBuilder<ScribbleState>(
              valueListenable: widget.notifier,
              builder: (context, state, child) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed:
                          widget.notifier.canUndo ? widget.notifier.undo : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      onPressed:
                          widget.notifier.canRedo ? widget.notifier.redo : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: widget.notifier.clear,
                    ),
                    IconButton(
                      icon: Icon(Icons.color_lens, color: _currentColor),
                      onPressed: _openColorPicker,
                    ),
                  ],
                );
              },
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
                  widget.notifier.setStrokeWidth(value);
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
            child: Scribble(notifier: widget.notifier),
          ),
        ),
      ],
    );
  }
}
