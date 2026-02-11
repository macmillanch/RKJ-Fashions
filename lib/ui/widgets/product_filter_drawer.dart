import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ProductFilterDrawer extends StatefulWidget {
  const ProductFilterDrawer({super.key});

  @override
  State<ProductFilterDrawer> createState() => _ProductFilterDrawerState();
}

class _ProductFilterDrawerState extends State<ProductFilterDrawer> {
  RangeValues _currentPriceRange = const RangeValues(50, 250);
  final TextEditingController _minPriceCtrl = TextEditingController(text: '50');
  final TextEditingController _maxPriceCtrl = TextEditingController(
    text: '250',
  );
  String _selectedSize = 'Adult';
  final List<Color> _selectedColors = [];

  final List<String> _sizes = ['Kids', 'Adult', 'S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // Spacer
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textUser,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  const SizedBox(height: 10),
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textUser,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(_minPriceCtrl, 'Min', (val) {
                          setState(() {
                            double min = double.tryParse(val) ?? 0;
                            _currentPriceRange = RangeValues(
                              min,
                              _currentPriceRange.end,
                            );
                          });
                        }),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: _buildPriceInput(_maxPriceCtrl, 'Max', (val) {
                          setState(() {
                            double max = double.tryParse(val) ?? 500;
                            _currentPriceRange = RangeValues(
                              _currentPriceRange.start,
                              max,
                            );
                          });
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _currentPriceRange,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    activeColor: AppColors.primaryUser,
                    inactiveColor: Colors.grey[200],
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentPriceRange = values;
                        _minPriceCtrl.text = values.start.round().toString();
                        _maxPriceCtrl.text = values.end.round().toString();
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Size Selection
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textUser,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      final isDisabled = size == 'XXL'; // Mock disabled state
                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () => setState(() => _selectedSize = size),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryUser
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryUser
                                  : Colors.grey[300]!,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryUser.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey[300]
                                  : (isSelected
                                        ? Colors.white
                                        : AppColors.textUser),
                              fontWeight: FontWeight.bold,
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Color Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Colors (Select up to 5)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textUser,
                        ),
                      ),
                      Text(
                        '${_selectedColors.length}/5',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedColors.length >= 5
                              ? Colors.red
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ..._selectedColors.map(
                        (color) => Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: -2,
                              top: -2,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _selectedColors.remove(color),
                                ),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedColors.length < 5)
                        GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primaryUser,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Reset Logic
                    setState(() {
                      _currentPriceRange = const RangeValues(0, 1000);
                      _minPriceCtrl.text = '0';
                      _maxPriceCtrl.text = '1000';
                      _selectedSize = 'Adult';
                      _selectedColors.clear();
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryUser,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(
    TextEditingController ctrl,
    String label,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showColorPicker() {
    Color pickerColor = AppColors.primaryUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => _selectedColors.add(pickerColor));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
