import 'package:flutter/material.dart';
import 'package:budget_tracker/classes/labelManager.dart';

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
                  ? labelData.color.withValues(alpha: 0.5)
                  : labelData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                // Modulate opacity instead of thickness to maintain a constant layout size
                color: isHovered
                    ? labelData.color
                    : labelData.color.withValues(alpha: 0.6),
                width:
                    1.5, // Constant width prevents container resizing on hover
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
  late FocusNode _titleFocusNode;
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
    _titleFocusNode = FocusNode();

    // Listen for focus changes to select all text securely
    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) {
        // A short delay ensures the platform keyboard (IME) is fully connected
        // before manipulating the text selection.
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _titleController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _titleController.text.length,
            );
          }
        });
      }
    });

    // Automatically focus on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });

    _keywords = List.from(widget.labelData.keywords);
    _operands = List.from(widget.labelData.operands);
    _selectedColor = widget.labelData.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
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
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: _selectedColor, width: 1.5),
                    ),
                    child: IntrinsicWidth(
                      // Adding a minWidth constraint avoids the field snapping to 0
                      // width when typing a single character over a fully selected string.
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 60),
                        child: TextField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Label Preview',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
