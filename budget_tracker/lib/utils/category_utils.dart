import 'package:flutter/material.dart';
import 'package:budget_tracker/classes/gsheetManager.dart';

/// Generates a unique key for a category to handle selection state.
String getCategoryKey(CategoryBudget category) {
  return '${category.type.name}:${category.category}';
}

/// Returns a consistent color based on the category's index, with a specific override for "Andere".
Color getCategoryColor(CategoryBudget category, int index) {
  List<Color> _generatePastelColors({int count = 20}) {
    final List<Color> colors = [];

    // Tuned for black text readability + clear separation
    const double saturation = 0.70; // 70%
    const double lightness = 0.58; // 58%

    for (int i = 0; i < count; i++) {
      // Evenly spaced hue wheel (0.0 to 360.0)
      final double hue = (360.0 / count) * i;

      final hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
      colors.add(hslColor.toColor());
    }

    return colors;
  }

  final normalized = category.category.toLowerCase();
  if (normalized == 'andere' || normalized.contains('andere')) {
    return Color(0xFF8A8A8A);
  }

  var palette = _generatePastelColors(count: 20);

  return palette[index % palette.length];
}
