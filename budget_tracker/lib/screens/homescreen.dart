import 'package:budget_tracker/classes/gsheetManager.dart';
import 'package:budget_tracker/utils/category_utils.dart';
import 'package:budget_tracker/widgets/budget_pie_chart_card.dart';
import 'package:budget_tracker/widgets/monthly_pie_chart_card.dart';
import 'package:budget_tracker/widgets/selected_category_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GSheetManager _sheetManager = GSheetManager();
  late Future<GSheetData> _sheetDataFuture;

  String? _selectedCategoryKey;

  @override
  void initState() {
    super.initState();
    _sheetDataFuture = _sheetManager.fetchJaaroverzichtData();
  }

  // 1. Update callback to handle nullable CategoryBudget
  void _onCategorySelected(CategoryBudget? category) {
    setState(() {
      _selectedCategoryKey = category != null ? getCategoryKey(category) : null;
    });
  }

  // 2. Update category retriever to return null if nothing is selected
  CategoryBudget? _selectedCategoryFor(GSheetData data) {
    if (data.categories.isEmpty || _selectedCategoryKey == null) return null;

    return data.categories.firstWhere(
      (category) => getCategoryKey(category) == _selectedCategoryKey,
      orElse: () => data.categories.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes the background transparent
        surfaceTintColor:
            Colors.transparent, // Prevents Material 3 scroll tinting
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 20),
            const Icon(Icons.account_balance_wallet),
            const SizedBox(width: 10),
            FutureBuilder<GSheetData>(
              future: _sheetDataFuture,
              builder: (context, snapshot) {
                final metadata = snapshot.data?.metadata;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Budget Tracker'),
                    if (metadata != null)
                      Text(
                        '${metadata.sheetName} • ${metadata.accountNumber} • ${metadata.year}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.white70),
                      ),
                  ],
                );
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              hoverColor: Colors.white24,
              onPressed: () async {
                setState(() {
                  _sheetDataFuture = _sheetManager.fetchJaaroverzichtData();
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<GSheetData>(
        future: _sheetDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final data = snapshot.data!;
          final selectedCategory = _selectedCategoryFor(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYearlyPieCharts(data),
                const SizedBox(height: 20),
                if (selectedCategory != null &&
                    _selectedCategoryKey != null) ...[
                  SelectedCategoryCard(
                    data: data,
                    selectedCategory: selectedCategory,
                    selectedCategoryKey: _selectedCategoryKey!,
                  ),
                  const SizedBox(height: 20),
                ],

                MonthlyOverviewSection(categories: data.categories),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                _buildCategoryList(data.categories),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearlyPieCharts(GSheetData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: BudgetPieChartCard(
            title: 'Inkomsten',
            categories: data.incomeCategories,
            selectedCategoryKey: _selectedCategoryKey,
            onCategorySelected: _onCategorySelected,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BudgetPieChartCard(
            title: 'Uitgaven',
            categories: data.expenseCategories,
            selectedCategoryKey: _selectedCategoryKey,
            onCategorySelected: _onCategorySelected,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<CategoryBudget> categories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = getCategoryKey(cat) == _selectedCategoryKey;

        return Card(
          color: isSelected ? const Color(0xFF2C2C3E) : const Color(0xFF1E1E2C),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              cat.category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${cat.monthlyValues.length} months tracked',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              '€${cat.yearlyTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: cat.type == TransactionType.income
                    ? Colors.tealAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () => _onCategorySelected(cat),
          ),
        );
      },
    );
  }
}
