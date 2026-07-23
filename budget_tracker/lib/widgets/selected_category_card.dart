import 'package:budget_tracker/classes/gsheetManager.dart';
import 'package:budget_tracker/utils/category_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SelectedCategoryCard extends StatelessWidget {
  final GSheetData data;
  final CategoryBudget selectedCategory;
  final String selectedCategoryKey;
  // final ValueChanged<String?> onCategoryDropdownChanged;

  const SelectedCategoryCard({
    super.key,
    required this.data,
    required this.selectedCategory,
    required this.selectedCategoryKey,
    // required this.onCategoryDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    final values = selectedCategory.monthlyValues;

    // First, try to find the index in the income categories
    int catIndex = data.incomeCategories.indexWhere(
      (cat) => getCategoryKey(cat) == selectedCategoryKey,
    );

    // If it's not an income category, find its index in the expense categories
    if (catIndex == -1) {
      catIndex = data.expenseCategories.indexWhere(
        (cat) => getCategoryKey(cat) == selectedCategoryKey,
      );
    }

    // Get the color using the local index to match the pie chart
    final color = getCategoryColor(
      selectedCategory,
      catIndex >= 0 ? catIndex : 0,
    );

    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Category',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        selectedCategory.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Yearly total: €${selectedCategory.yearlyTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: selectedCategory.type == TransactionType.income
                    ? Colors.tealAccent
                    : Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // Fixes duplicate month labels
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (val != idx.toDouble())
                            return const SizedBox.shrink();

                          if (idx >= 0 && idx < data.months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data.months[idx].substring(0, 3),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        values.length,
                        (index) =>
                            FlSpot(index.toDouble(), values[index].abs()),
                      ),
                      isCurved: false,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 12),
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: List.generate(data.months.length, (index) {
            //     return Chip(
            //       backgroundColor: const Color(0xFF2C2C3E),
            //       label: Text(
            //         '${data.months[index]}: €${values[index].toStringAsFixed(2)}',
            //         style: const TextStyle(color: Colors.white),
            //       ),
            //     );
            //   }),
            // ),
          ],
        ),
      ),
    );
  }
}
