import 'package:flutter/material.dart';
import '../models/mood_model.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMoodId;
  final Function(String?) onSelected;
  final bool showLabel;
  final bool includeAll;

  const MoodSelector({
    super.key,
    required this.selectedMoodId,
    required this.onSelected,
    this.showLabel = true,
    this.includeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (includeAll)
            _buildAllChip(context, colors),

          if (includeAll)
            const SizedBox(width: 12),

          ...MoodData.moods.map((mood) {
            final isSelected = mood.id == selectedMoodId;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => onSelected(mood.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected
                        ? mood.color.withOpacity(0.15)
                        : colors.surface.withOpacity(0.5),
                    border: Border.all(
                      color: isSelected
                          ? mood.color
                          : Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mood.icon,
                        size: 16,
                        color: mood.color,
                      ),
                      if (showLabel) ...[
                        const SizedBox(width: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            color: mood.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAllChip(BuildContext context, ColorScheme colors) {
    final isSelected = selectedMoodId == null;

    return GestureDetector(
      onTap: () => onSelected(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? colors.primary.withOpacity(0.15)
              : colors.surface.withOpacity(0.5),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps_rounded,
              size: 16,
              color: isSelected
                  ? colors.primary
                  : colors.onSurface.withOpacity(0.7),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                "All",
                style: TextStyle(
                  color: isSelected
                      ? colors.primary
                      : colors.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
