import 'package:budget_tracker/classes/gsheetManager.dart';
import 'package:budget_tracker/utils/category_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPieChartCard extends StatefulWidget {
  final String title;
  final List<CategoryBudget> categories;
  final String? selectedCategoryKey;
  final ValueChanged<CategoryBudget?> onCategorySelected;
  final double cardHeight;

  const BudgetPieChartCard({
    super.key,
    required this.title,
    required this.categories,
    required this.selectedCategoryKey,
    required this.onCategorySelected,
    this.cardHeight = 520.0,
  });

  @override
  State<BudgetPieChartCard> createState() => _BudgetPieChartCardState();
}

class _BudgetPieChartCardState extends State<BudgetPieChartCard> {
  @override
  Widget build(BuildContext context) {
    final total = widget.categories.fold<double>(
      0.0,
      (sum, category) => sum + category.yearlyTotal.abs(),
    );

    return SizedBox(
      height: widget.cardHeight,
      child: Card(
        color: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          // HitTestBehavior.opaque ensures taps on empty whitespace inside the padding/column are captured
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onCategorySelected(null),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 230,
                  child: total == 0.0
                      ? const Center(
                          child: Text(
                            'No data',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                if (event is! FlTapUpEvent) return;

                                final index =
                                    response
                                        ?.touchedSection
                                        ?.touchedSectionIndex ??
                                    -1;

                                if (index >= 0 &&
                                    index < widget.categories.length) {
                                  widget.onCategorySelected(
                                    widget.categories[index],
                                  );
                                } else {
                                  // Clicked the center hole or empty chart area
                                  widget.onCategorySelected(null);
                                }
                              },
                            ),
                            sections: _buildSections(),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisExtent: 36,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      final entry = widget.categories[index];
                      final percentage = total == 0.0
                          ? 0.0
                          : (entry.yearlyTotal.abs() / total) * 100;
                      final highlighted =
                          getCategoryKey(entry) == widget.selectedCategoryKey;

                      return _LegendItem(
                        label: entry.category,
                        percentage: percentage,
                        color: getCategoryColor(entry, index),
                        highlighted: highlighted,
                        onTap: () => widget.onCategorySelected(entry),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      for (final entry in widget.categories.asMap().entries)
        PieChartSectionData(
          value: entry.value.yearlyTotal.abs(),
          color: getCategoryColor(entry.value, entry.key),
          title: '',
          radius: getCategoryKey(entry.value) == widget.selectedCategoryKey
              ? 66
              : 56,
          borderSide: getCategoryKey(entry.value) == widget.selectedCategoryKey
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;
  final bool highlighted;
  final VoidCallback onTap;

  const _LegendItem({
    required this.label,
    required this.percentage,
    required this.color,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF2C2C3E) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: highlighted ? Colors.white70 : Colors.white10,
            width: highlighted ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label ${percentage.toStringAsFixed(0)}%',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: highlighted ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
