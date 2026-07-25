import 'package:flutter/material.dart';

// Model to hold comprehensive label data
class LabelData {
  String title;
  Color color;
  List<String> keywords;
  List<String> operands;

  LabelData({
    required this.title,
    required this.color,
    required this.keywords,
    required this.operands,
  });
}

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

  const NoticeBoard({
    super.key,
    required this.title,
    required this.children,
    required this.onAddPressed,
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
                color: const Color(0xFFD97706),
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
              padding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...children,
                    const SizedBox(width: 8),
                    HoverButtonWrapper(
                      onTap: onAddPressed,
                      builder: (isHovered) => Container(
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFD97706),
                            width: isHovered ? 2.0 : 1.5,
                          ),
                          color: isHovered
                              ? const Color(0xFFD97706).withValues(alpha: 0.2)
                              : Colors.grey[850],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Color(0xFFD97706),
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
                border: const Border(
                  top: BorderSide(color: Color(0xFFD97706), width: 2.0),
                  left: BorderSide(color: Color(0xFFD97706), width: 2.0),
                  right: BorderSide(color: Color(0xFFD97706), width: 2.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
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

class MyLabel extends StatelessWidget {
  final LabelData labelData;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const MyLabel({
    super.key,
    required this.labelData,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'label_${labelData.hashCode}',
      child: Material(
        color: Colors.transparent,
        child: HoverButtonWrapper(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          builder: (isHovered) => Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isHovered
                  ? const Color(0xFFD97706).withValues(alpha: 0.4)
                  : labelData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFD97706),
                width: isHovered ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              labelData.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper wrapper to handle mouse hover states cleanly for custom containers/buttons
class HoverButtonWrapper extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Widget Function(bool isHovered) builder;

  const HoverButtonWrapper({
    super.key,
    this.onTap,
    this.onDoubleTap,
    required this.builder,
  });

  @override
  State<HoverButtonWrapper> createState() => _HoverButtonWrapperState();
}

class _HoverButtonWrapperState extends State<HoverButtonWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: widget.builder(_isHovered),
      ),
    );
  }
}

class LabelEditorScreen extends StatefulWidget {
  final LabelData labelData;
  final ValueChanged<LabelData> onSave;

  const LabelEditorScreen({
    super.key,
    required this.labelData,
    required this.onSave,
  });

  @override
  State<LabelEditorScreen> createState() => _LabelEditorScreenState();
}

class _LabelEditorScreenState extends State<LabelEditorScreen> {
  late TextEditingController _titleController;
  late List<String> _keywords;
  late List<String> _operands;
  late Color _selectedColor;

  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _operandController = TextEditingController();

  List<Color> get _availableColors {
    final List<Color> colors = [
      const Color(0xFFD97706),
      const Color(0xFF8A8A8A),
    ];

    const int count = 20;
    const double saturation = 0.70;
    const double lightness = 0.58;

    for (int i = 0; i < count; i++) {
      final double hue = (360.0 / count) * i;
      final hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
      colors.add(hslColor.toColor());
    }

    return colors;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.labelData.title);
    _keywords = List.from(widget.labelData.keywords);
    _operands = List.from(widget.labelData.operands);
    _selectedColor = widget.labelData.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _keywordController.dispose();
    _operandController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    if (_keywordController.text.isNotEmpty) {
      setState(() {
        _keywords.add(_keywordController.text.trim());
        _keywordController.clear();
      });
    }
  }

  void _addOperand() {
    if (_operandController.text.isNotEmpty) {
      setState(() {
        _operands.add(_operandController.text.trim());
        _operandController.clear();
      });
    }
  }

  void _showCustomColorPicker() {
    final initialHsl = HSLColor.fromColor(_selectedColor);
    double tempHue = initialHsl.hue;
    double tempSaturation = initialHsl.saturation;
    double tempLightness = initialHsl.lightness;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentColor =
                HSLColor.fromAHSL(1.0, tempHue, tempSaturation, tempLightness)
                    .toColor();
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: const Text('Custom Color Picker',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Hue', style: TextStyle(color: Colors.white70)),
                  Slider(
                    value: tempHue,
                    min: 0.0,
                    max: 360.0,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) {
                      setDialogState(() => tempHue = val);
                    },
                  ),
                  const Text('Saturation',
                      style: TextStyle(color: Colors.white70)),
                  Slider(
                    value: tempSaturation,
                    min: 0.0,
                    max: 1.0,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) {
                      setDialogState(() => tempSaturation = val);
                    },
                  ),
                  const Text('Lightness',
                      style: TextStyle(color: Colors.white70)),
                  Slider(
                    value: tempLightness,
                    min: 0.1,
                    max: 0.9,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) {
                      setDialogState(() => tempLightness = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedColor = currentColor;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _availableColors;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text('Edit Label', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(
                LabelData(
                  title: _titleController.text,
                  color: _selectedColor,
                  keywords: _keywords,
                  operands: _operands,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'label_${widget.labelData.hashCode}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: _selectedColor, width: 1.5),
                    ),
                    child: Text(
                      _titleController.text.isEmpty
                          ? 'Label Preview'
                          : _titleController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Title',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(color: Color(0xFFD97706), width: 2.0),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Color Palette',
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706)),
                  onPressed: _showCustomColorPicker,
                  icon: const Icon(Icons.palette, size: 18),
                  label: const Text('Custom Color'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD97706)
                            : Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Keywords',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addKeyword(),
                    decoration: InputDecoration(
                      hintText: 'Add keyword & press enter...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFFD97706), width: 2.0),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addKeyword,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _keywords.map((kw) {
                return Chip(
                  label: Text(kw),
                  backgroundColor: Colors.grey[800],
                  labelStyle: const TextStyle(color: Colors.white),
                  deleteIconColor: const Color(0xFFD97706),
                  onDeleted: () => setState(() => _keywords.remove(kw)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Operands (e.g., ==100, >50)',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _operandController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addOperand(),
                    decoration: InputDecoration(
                      hintText: 'Add operand & press enter...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                            color: Color(0xFFD97706), width: 2.0),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addOperand,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _operands.map((op) {
                return Chip(
                  label: Text(op),
                  backgroundColor: Colors.grey[800],
                  labelStyle: const TextStyle(color: Colors.white),
                  deleteIconColor: const Color(0xFFD97706),
                  onDeleted: () => setState(() => _operands.remove(op)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
