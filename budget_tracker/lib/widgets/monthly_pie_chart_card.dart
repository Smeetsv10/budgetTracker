import 'package:budget_tracker/classes/gsheetManager.dart';
import 'package:budget_tracker/utils/category_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyPieChartCard extends StatefulWidget {
  final String monthName;
  final int monthIndex;
  final List<CategoryBudget> categories;
  final double width;

  const MonthlyPieChartCard({
    super.key,
    required this.monthName,
    required this.monthIndex,
    required this.categories,
    this.width = 340.0,
  });

  @override
  State<MonthlyPieChartCard> createState() => _MonthlyPieChartCardState();
}

class _MonthlyPieChartCardState extends State<MonthlyPieChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Only include categories that have non-zero data for this specific month
    final activeCategories = widget.categories.where((cat) {
      if (cat.monthlyValues.length <= widget.monthIndex) return false;
      return cat.monthlyValues[widget.monthIndex].abs() > 0.001;
    }).toList();

    final monthTotal = activeCategories.fold<double>(
      0.0,
      (sum, cat) => sum + cat.monthlyValues[widget.monthIndex].abs(),
    );

    // Retrieve details for the currently touched slice/item
    CategoryBudget? touchedCategory;
    double touchedValue = 0.0;
    if (_touchedIndex != null &&
        _touchedIndex! >= 0 &&
        _touchedIndex! < activeCategories.length) {
      touchedCategory = activeCategories[_touchedIndex!];
      touchedValue = touchedCategory.monthlyValues[widget.monthIndex];
    }

    return SizedBox(
      width: widget.width,
      child: Card(
        color: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _touchedIndex = null),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.monthName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '€${monthTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: monthTotal == 0.0
                      ? const Center(
                          child: Text(
                            'No data for this month',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 42,
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    if (event is! FlTapUpEvent) return;
                                    final index =
                                        response
                                            ?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1;
                                    setState(() {
                                      _touchedIndex =
                                          (index >= 0 &&
                                              index < activeCategories.length)
                                          ? index
                                          : null;
                                    });
                                  },
                                ),
                                sections: _buildSections(activeCategories),
                              ),
                            ),
                            // Center overlay showing selected category & actual value
                            IgnorePointer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (touchedCategory != null) ...[
                                    Text(
                                      touchedCategory.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '€${touchedValue.abs().toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    Text(
                                      '€${monthTotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                if (activeCategories.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            mainAxisExtent: 26,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: activeCategories.length,
                      itemBuilder: (context, index) {
                        final entry = activeCategories[index];
                        final val = entry.monthlyValues[widget.monthIndex]
                            .abs();
                        final isTouched = _touchedIndex == index;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _touchedIndex = isTouched ? null : index;
                            });
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isTouched
                                  ? const Color(0xFF2C2C3E)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isTouched
                                    ? Colors.white70
                                    : Colors.white10,
                                width: isTouched ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: getCategoryColor(entry, index),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${entry.category}: €${val.toStringAsFixed(0)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isTouched
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: isTouched
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  List<PieChartSectionData> _buildSections(
    List<CategoryBudget> activeCategories,
  ) {
    return [
      for (int i = 0; i < activeCategories.length; i++) ...[
        () {
          final cat = activeCategories[i];
          final val = cat.monthlyValues[widget.monthIndex].abs();
          final isTouched = i == _touchedIndex;

          return PieChartSectionData(
            value: val,
            color: getCategoryColor(cat, i),
            title: '',
            radius: isTouched ? 52 : 44,
            borderSide: isTouched
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          );
        }(),
      ],
    ];
  }
}

class MonthlyOverviewSection extends StatelessWidget {
  final List<CategoryBudget> categories;

  const MonthlyOverviewSection({super.key, required this.categories});

  static const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = 340;
            if (constraints.maxWidth < 360) {
              cardWidth = constraints.maxWidth;
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                for (int monthIdx = 0; monthIdx < 12; monthIdx++)
                  MonthlyPieChartCard(
                    monthName: monthNames[monthIdx],
                    monthIndex: monthIdx,
                    categories: categories,
                    width: cardWidth,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
