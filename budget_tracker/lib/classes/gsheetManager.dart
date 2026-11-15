import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

  double get yearlyTotal =>
      monthlyValues.fold(0.0, (sum, val) => sum + val).abs();
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
  String? _spreadsheetId;
  String? _gid;
  String? _apiKey;

  GSheetManager({String? spreadsheetId, String? gid, String? apiKey}) {
    // 1. Check if defined via GitHub Secrets / build flags (--dart-define)
    const envSpreadsheetId = String.fromEnvironment('SPREADSHEET_ID');
    const envGid = String.fromEnvironment('SHEET_GID');
    const envApiKey = String.fromEnvironment('API_KEY');

    _spreadsheetId =
        envSpreadsheetId.isNotEmpty ? envSpreadsheetId : spreadsheetId;
    _gid = envGid.isNotEmpty ? envGid : gid;
    _apiKey = envApiKey.isNotEmpty ? envApiKey : apiKey;
  }

  /// Ensures configuration parameters are loaded from assets/config.json if not set via environment
  Future<void> _ensureConfigLoaded() async {
    if (_spreadsheetId != null && _gid != null && _apiKey != null) return;

    try {
      final jsonString = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> config = json.decode(jsonString);

      _spreadsheetId ??= config['SPREADSHEET_ID'] as String?;
      _gid ??= config['SHEET_GID'] as String?;
      _apiKey ??= config['API_KEY'] as String?;
    } catch (e) {
      throw Exception(
        'Failed to load config from assets/config.json and environment variables are missing: $e',
      );
    }

    if (_spreadsheetId == null || _gid == null || _apiKey == null) {
      throw Exception(
          'SPREADSHEET_ID, SHEET_GID, or API_KEY missing in configuration');
    }
  }

  Future<GSheetData> fetchJaaroverzichtData() async {
    await _ensureConfigLoaded();

    // Step 1: Fetch spreadsheet metadata to map the numeric gid to the correct sheet title
    final metaUrl = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId?key=$_apiKey',
    );
    final metaResponse = await http.get(metaUrl);

    if (metaResponse.statusCode != 200) {
      throw Exception(
          'Failed to load sheet metadata: ${metaResponse.statusCode}');
    }

    final metaData = json.decode(metaResponse.body);
    final sheets = metaData['sheets'] as List<dynamic>;

    String? sheetTitle;
    for (var sheet in sheets) {
      final props = sheet['properties'];
      if (props['sheetId'].toString() == _gid) {
        sheetTitle = props['title'];
        break;
      }
    }

    if (sheetTitle == null) {
      throw Exception('Could not find sheet tab with gid: $_gid');
    }

    // Step 2: Fetch cell values using the resolved sheet title (fully CORS compatible)
    final valuesUrl = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$_spreadsheetId/values/${Uri.encodeComponent(sheetTitle)}?key=$_apiKey',
    );
    final valuesResponse = await http.get(valuesUrl);

    if (valuesResponse.statusCode != 200) {
      throw Exception(
          'Failed to load sheet values: ${valuesResponse.statusCode}');
    }

    final valuesData = json.decode(valuesResponse.body);
    final List<dynamic>? rawRows = valuesData['values'];

    if (rawRows == null || rawRows.isEmpty) {
      throw Exception('Sheet is empty');
    }

    // Convert dynamic list to List<List<dynamic>> for parsing compatibility
    final List<List<dynamic>> rows =
        rawRows.map((row) => row as List<dynamic>).toList();

    // 3. Extract Metadata from Row 0 (Google Sheets Row 1)
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

    // 4. Loop through data rows starting from Row 1
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
      final List<double> monthlyValues = [];

      for (int monthIdx = 1; monthIdx <= 12; monthIdx++) {
        if (monthIdx < row.length) {
          double val = _parseAmount(row[monthIdx]);

          if (currentType == TransactionType.expense && val > 0) {
            val = -val;
          }
          monthlyValues.add(val);
        } else {
          monthlyValues.add(0.0);
        }
      }

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

    return GSheetData(
      metadata: metadata,
      months: months,
      categories: categories,
    );
  }

  double _parseAmount(dynamic rawValue) {
    if (rawValue == null) return 0.0;
    String str =
        rawValue.toString().replaceAll('€', '').replaceAll(' ', '').trim();
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
