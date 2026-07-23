import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

enum TransactionType { income, expense }

class SheetMetadata {
  final String sheetName;
  final String accountNumber;
  final String year;

  SheetMetadata({
    required this.sheetName,
    required this.accountNumber,
    required this.year,
  });
}

class CategoryBudget {
  final String category;
  final TransactionType type;
  final List<double> monthlyValues; // Exactly 12 values (Jan - Dec)

  CategoryBudget({
    required this.category,
    required this.type,
    required this.monthlyValues,
  });

  /// Total sum for the year (ignoring averages/totals calculated in the sheet)
  double get yearlyTotal => monthlyValues.fold(0.0, (sum, val) => sum + val);
}

class GSheetData {
  final SheetMetadata metadata;
  final List<String> months;
  final List<CategoryBudget> categories;

  GSheetData({
    required this.metadata,
    required this.months,
    required this.categories,
  });

  List<CategoryBudget> get incomeCategories =>
      categories.where((c) => c.type == TransactionType.income).toList();

  List<CategoryBudget> get expenseCategories =>
      categories.where((c) => c.type == TransactionType.expense).toList();
}

class GSheetManager {
  final String spreadsheetId;
  final String gid;

  GSheetManager({
    this.spreadsheetId = '1Ha0-HzHil5mbr1TNa6dXkvU3aDJvyJQK6Phlq4PNT4g',
    this.gid = '57985379',
  });

  Future<GSheetData> fetchJaaroverzichtData() async {
    final url = Uri.parse(
      'https://docs.google.com/spreadsheets/d/$spreadsheetId/export?format=csv&gid=$gid',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load sheet data: ${response.statusCode}');
    }

    // Parse CSV
    final List<List<dynamic>> rows = csv.decode(response.body);

    if (rows.isEmpty) {
      throw Exception('Sheet is empty');
    }

    // 1. Extract Metadata from Row 0 (Google Sheets Row 1)
    final row0 = rows[0];
    final sheetName = row0.length > 1 && row0[1].toString().trim().isNotEmpty
        ? row0[1].toString().trim()
        : row0[0].toString().trim();
    final accountNumber = row0.length > 4 ? row0[4].toString().trim() : 'N/A';
    final year = row0.length > 12 ? row0[12].toString().trim() : '2026';

    final metadata = SheetMetadata(
      sheetName: sheetName,
      accountNumber: accountNumber,
      year: year,
    );

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final List<CategoryBudget> categories = [];
    TransactionType currentType = TransactionType.income;

    // 2. Loop through data rows starting from Row 1
    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      final categoryName = row[0].toString().trim();

      // Skip blank rows or net total rows
      if (categoryName.isEmpty ||
          categoryName == 'Netto' ||
          categoryName == 'Totaal') {
        continue;
      }

      // Context switch: toggle between Income and Expense sections
      if (categoryName == 'Inkomsten') {
        currentType = TransactionType.income;
        continue;
      } else if (categoryName == 'Uitgaven') {
        currentType = TransactionType.expense;
        continue;
      }

      // Extract exactly 12 months from Column B (Index 1) to Column M (Index 12)
      // Ignoring Column N (Index 13) which contains row averages/totals.
      final List<double> monthlyValues = [];

      for (int monthIdx = 1; monthIdx <= 12; monthIdx++) {
        if (monthIdx < row.length) {
          double val = _parseAmount(row[monthIdx]);

          // Ensure sign consistency based on section if necessary
          // Income = positive, Expense = negative
          if (currentType == TransactionType.expense && val > 0) {
            val = -val;
          }
          monthlyValues.add(val);
        } else {
          monthlyValues.add(0.0);
        }
      }

      // Differentiate duplicate category names (e.g., "Andere (Inkomsten)" vs "Andere (Uitgaven)")
      String finalName = categoryName;
      if (categoryName == 'Andere') {
        finalName = currentType == TransactionType.income
            ? 'Andere (Inkomsten)'
            : 'Andere (Uitgaven)';
      }

      categories.add(
        CategoryBudget(
          category: finalName,
          type: currentType,
          monthlyValues: monthlyValues,
        ),
      );
    }
    print(
      categories.map((c) => '${c.category}: ${c.monthlyValues}').join('\n'),
    );

    return GSheetData(
      metadata: metadata,
      months: months,
      categories: categories,
    );
  }

  double _parseAmount(dynamic rawValue) {
    if (rawValue == null) return 0.0;
    String str = rawValue
        .toString()
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .trim();
    if (str.isEmpty) return 0.0;

    // Handle European decimal comma notation (e.g., -237,79 -> -237.79)
    if (str.contains(',') && str.contains('.')) {
      str = str.replaceAll('.', '').replaceAll(',', '.');
    } else if (str.contains(',')) {
      str = str.replaceAll(',', '.');
    }

    return double.tryParse(str) ?? 0.0;
  }
}
