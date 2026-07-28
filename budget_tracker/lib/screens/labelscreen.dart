import 'package:flutter/material.dart';
import 'package:budget_tracker/classes/labelManager.dart';
import 'package:budget_tracker/widgets/my_label.dart';

class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key});

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final List<LabelData> incomeLabels = [
    LabelData(
        title: 'Salary',
        color: const Color(0xFFD97706),
        keywords: ['salary', 'pay'],
        operands: []),
    LabelData(
        title: 'Freelance',
        color: const Color(0xFFD97706),
        keywords: ['client', 'project'],
        operands: []),
    LabelData(
        title: 'Investments',
        color: const Color(0xFFD97706),
        keywords: ['dividend', 'stock'],
        operands: []),
  ];

  final List<LabelData> expenseLabels = [
    LabelData(
        title: 'Food',
        color: const Color(0xFFD97706),
        keywords: ['grocery', 'restaurant'],
        operands: []),
    LabelData(
        title: 'Rent',
        color: const Color(0xFFD97706),
        keywords: ['housing', 'apartment'],
        operands: []),
    LabelData(
        title: 'Utilities',
        color: const Color(0xFFD97706),
        keywords: ['electric', 'water'],
        operands: []),
    LabelData(
        title: 'Transport',
        color: const Color(0xFFD97706),
        keywords: ['uber', 'fuel'],
        operands: []),
  ];

  void _addLabel(bool isIncome) {
    final newLabel = LabelData(
      title: isIncome
          ? 'New Income ${incomeLabels.length + 1}'
          : 'New Expense ${expenseLabels.length + 1}',
      color: const Color(0xFFD97706),
      keywords: [],
      operands: [],
    );

    setState(() {
      if (isIncome) {
        incomeLabels.add(newLabel);
      } else {
        expenseLabels.add(newLabel);
      }
    });

    _openEditor(newLabel, (updatedLabel) {
      setState(() {
        final index = isIncome
            ? incomeLabels.indexOf(newLabel)
            : expenseLabels.indexOf(newLabel);
        if (index != -1) {
          if (isIncome) {
            incomeLabels[index] = updatedLabel;
          } else {
            expenseLabels[index] = updatedLabel;
          }
        }
      });
    });
  }

  void _openEditor(LabelData labelData, ValueChanged<LabelData> onSave) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabelEditorScreen(
          labelData: labelData,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: NoticeBoard(
                title: 'Income labels',
                color: Colors.greenAccent,
                children: incomeLabels
                    .map(
                      (label) => MyLabel(
                        labelData: label,
                        onTap: () => _openEditor(label, (updated) {
                          setState(() {
                            final idx = incomeLabels.indexOf(label);
                            if (idx != -1) incomeLabels[idx] = updated;
                          });
                        }),
                      ),
                    )
                    .toList(),
                onAddPressed: () => _addLabel(true),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: NoticeBoard(
                title: 'Expense labels',
                color: Colors.redAccent,
                children: expenseLabels
                    .map(
                      (label) => MyLabel(
                        labelData: label,
                        onTap: () => _openEditor(label, (updated) {
                          setState(() {
                            final idx = expenseLabels.indexOf(label);
                            if (idx != -1) expenseLabels[idx] = updated;
                          });
                        }),
                      ),
                    )
                    .toList(),
                onAddPressed: () => _addLabel(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeBoard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onAddPressed;
  final Color color;

  const NoticeBoard({
    super.key,
    required this.title,
    required this.children,
    required this.onAddPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: color,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 45.0, 12.0, 0),
              // Changed to vertical scrolling for wrapped elements
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 8.0, // Horizontal spacing between items
                  runSpacing: 8.0, // Vertical spacing between lines
                  children: [
                    ...children,
                    HoverButtonWrapper(
                      onTap: onAddPressed,
                      builder: (isHovered) => Container(
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: color,
                            width: isHovered ? 2.0 : 1.5,
                          ),
                          color: isHovered
                              ? color.withValues(alpha: 0.2)
                              : Colors.grey[850],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: color,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -13,
            left: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                border: Border(
                  top: BorderSide(color: color, width: 2.0),
                  left: BorderSide(color: color, width: 2.0),
                  right: BorderSide(color: color, width: 2.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
