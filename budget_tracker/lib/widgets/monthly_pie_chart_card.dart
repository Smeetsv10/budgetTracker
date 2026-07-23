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

  Color _getCategoryColor(CategoryBudget category, int index) {
    List<Color> generatePastelColors({int count = 20}) {
      final List<Color> colors = [];
      const double saturation = 0.70;
      const double lightness = 0.58;

      for (int i = 0; i < count; i++) {
        final double hue = (360.0 / count) * i;
        final hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
        colors.add(hslColor.toColor());
      }
      return colors;
    }

    final normalized = category.category.toLowerCase();
    if (normalized == 'andere' || normalized.contains('andere')) {
      return const Color(0xFF8A8A8A);
    }

    var palette = generatePastelColors(count: 20);
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final activeCategories = widget.categories.where((cat) {
      if (cat.type != TransactionType.expense) return false;
      if (cat.monthlyValues.length <= widget.monthIndex) return false;
      return cat.monthlyValues[widget.monthIndex].abs() > 0.001;
    }).toList();

    final monthTotal = activeCategories.fold<double>(
      0.0,
      (sum, cat) => sum + cat.monthlyValues[widget.monthIndex].abs(),
    );

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
        clipBehavior: Clip.none,
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
                      'Expenses ${widget.monthName}',
                      style: const TextStyle(
                        fontSize: 15,
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
                const SizedBox(height: 16),
                SizedBox(
                  height: 210,
                  child: monthTotal == 0.0
                      ? const Center(
                          child: Text(
                            'No expenses for this month',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 45,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      if (event is! FlTapUpEvent) return;
                                      final index = response?.touchedSection
                                              ?.touchedSectionIndex ??
                                          -1;
                                      setState(() {
                                        if (index >= 0 &&
                                            index < activeCategories.length) {
                                          // Toggle: if already selected, set to null. Otherwise select it.
                                          _touchedIndex =
                                              (_touchedIndex == index)
                                                  ? null
                                                  : index;
                                        } else {
                                          _touchedIndex = null;
                                        }
                                      });
                                    },
                                  ),
                                  sections: _buildSections(activeCategories),
                                ),
                              ),
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
                        final val =
                            entry.monthlyValues[widget.monthIndex].abs();
                        final isTouched = _touchedIndex == index;
                        final masterIndex = widget.categories.indexOf(entry);

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
                                color:
                                    isTouched ? Colors.white70 : Colors.white10,
                                width: isTouched ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                      entry,
                                      masterIndex >= 0 ? masterIndex : index,
                                    ),
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
      List<CategoryBudget> activeCategories) {
    return [
      for (int i = 0; i < activeCategories.length; i++) ...[
        () {
          final cat = activeCategories[i];
          final val = cat.monthlyValues[widget.monthIndex].abs();
          final isTouched = i == _touchedIndex;
          final masterIndex = widget.categories.indexOf(cat);

          return PieChartSectionData(
            value: val,
            color: _getCategoryColor(
              cat,
              masterIndex >= 0 ? masterIndex : i,
            ),
            title: '',
            radius: isTouched ? 46 : 38,
            borderSide: isTouched
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          );
        }()
      ]
    ];
  }
}

class MonthlyOverviewSection extends StatelessWidget {
  final List<CategoryBudget> categories;

  const MonthlyOverviewSection({
    super.key,
    required this.categories,
  });

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
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    // Filter categories using cat.type
    final expenseCategories =
        categories.where((c) => c.type == TransactionType.expense).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Expenses Breakdown',
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
                    categories: expenseCategories,
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
