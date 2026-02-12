import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

class ScribbleCanvasWidget extends StatefulWidget {
  final Map<String, dynamic>? initialDrawing;
  final Function(Map<String, dynamic>?) onChanged;

  const ScribbleCanvasWidget({
    super.key,
    this.initialDrawing,
    required this.onChanged,
  });

  @override
  State<ScribbleCanvasWidget> createState() =>
      _ScribbleCanvasWidgetState();
}

class _ScribbleCanvasWidgetState
    extends State<ScribbleCanvasWidget> {

  late ScribbleNotifier _notifier;

  @override
  @override
  void initState() {
    super.initState();

    _notifier = ScribbleNotifier();

    // If editing existing drawing
    if (widget.initialDrawing != null) {
      final restoredState =
      ScribbleState.fromJson(widget.initialDrawing!);

      _notifier.value = restoredState;
    }

    _notifier.addListener(_onDrawingChanged);
  }


  void _onDrawingChanged() {
    final hasLines =
        _notifier.value.lines.isNotEmpty;

    if (hasLines) {
      widget.onChanged(
          _notifier.value.toJson());
    } else {
      widget.onChanged(null);
    }
  }

  @override
  void dispose() {
    _notifier.removeListener(_onDrawingChanged);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        /// Toolbar
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Draw Something",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.undo,
                      color: primary),
                  onPressed:
                  _notifier.canUndo
                      ? _notifier.undo
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.redo,
                      color: primary),
                  onPressed:
                  _notifier.canRedo
                      ? _notifier.redo
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.clear,
                      color: primary),
                  onPressed: _notifier.clear,
                ),
              ],
            )
          ],
        ),

        const SizedBox(height: 8),

        /// Canvas
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: primary,
            ),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(14),
            child: Scribble(
              notifier: _notifier,
            ),
          ),
        ),
      ],
    );
  }
}
