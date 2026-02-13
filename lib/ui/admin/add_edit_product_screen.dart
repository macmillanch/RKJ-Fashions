import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/storage_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _stockCtrl;
  List<String> _imageUrls = [];
  bool _isAvailable = true;
  bool _isLoading = false;

  final TextEditingController _sizesCtrl = TextEditingController();
  List<Color> _selectedColors = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _discountCtrl = TextEditingController(
      text: widget.product?.discount.toString() ?? '',
    );
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _categoryCtrl = TextEditingController(text: widget.product?.category ?? '');
    _stockCtrl = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '1',
    );
    _imageUrls = widget.product?.images ?? [];

    if (widget.product != null) {
      _sizesCtrl.text = widget.product!.sizes.join(', ');
      _selectedColors = widget.product!.colors
          .map((c) {
            try {
              if (c.startsWith('#')) {
                return Color(int.parse(c.replaceFirst('#', '0xFF')));
              }
              return Colors.transparent; // Fallback for names
            } catch (_) {
              return Colors.transparent;
            }
          })
          .where((c) => c != Colors.transparent)
          .toList();
      _isAvailable = widget.product!.isAvailable;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        String url = await StorageService().uploadImage(image, 'products');
        if (!mounted) return;
        setState(() {
          _imageUrls.add(url);
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _showUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _imageUrls.add(url);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      discount: double.tryParse(_discountCtrl.text) ?? 0,
      sizes: _sizesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      colors: _selectedColors
          .map(
            (c) =>
                '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          )
          .toList(),
      images: _imageUrls,
      description: _descCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'General'
          : _categoryCtrl.text.trim(),
      stockQuantity: int.tryParse(_stockCtrl.text) ?? 1,
      isAvailable: _isAvailable,
    );

    try {
      if (widget.product == null) {
        await context
            .read<DatabaseService>()
            .addProduct(product)
            .timeout(const Duration(seconds: 30));
      } else {
        await context
            .read<DatabaseService>()
            .updateProduct(product)
            .timeout(const Duration(seconds: 30));
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundUser, // Match HTML "background-light"
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'New Product' : 'Edit Product',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textUser),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Upload Section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _imageUrls.isEmpty
                              ? Colors.grey.shade300
                              : AppColors.primaryUser,
                          width: 2,
                          style: _imageUrls.isEmpty
                              ? BorderStyle.solid
                              : BorderStyle
                                    .solid, // Assuming straight border for filled, dashed difficult in raw container without custom paint
                        ),
                        // To simulate dashed border we would need CustomPaint or DottedBorder package
                      ),
                      child: _imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  Image.network(
                                    _imageUrls.first,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  if (_imageUrls.length > 1)
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '+${_imageUrls.length - 1} more',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryUser.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.primaryUser,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Upload Photos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textUser,
                                  ),
                                ),
                                const Text(
                                  'Tap to add from gallery',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showUrlDialog,
                                  child: const Text('Or add via URL'),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // Small list if multiple images
                  if (_imageUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageUrls.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == _imageUrls.length) {
                              // Add button
                              return GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _imageUrls[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _imageUrls.removeAt(index),
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
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Product Name
                  _buildInputLabel('Product Name'),
                  _buildPremiumInput(_nameCtrl, 'e.g. Floral Summer Dress'),

                  const SizedBox(height: 16),

                  // Price & Discount Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Price (₹)'),
                            _buildPremiumInput(
                              _priceCtrl,
                              '0.00',
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Discount (%)'),
                            _buildPremiumInput(
                              _discountCtrl,
                              '0',
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sizes
                  _buildInputLabel('Available Sizes'),

                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSizePresetChip('Kids'),
                      _buildSizePresetChip('Adult'),
                      _buildSizePresetChip('S'),
                      _buildSizePresetChip('M'),
                      _buildSizePresetChip('L'),
                      _buildSizePresetChip('XL'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPremiumInput(
                    _sizesCtrl,
                    'Enter sizes e.g. Kids, Adults or S, M, L',
                  ),

                  const SizedBox(height: 16),

                  // Colors
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel('Colors (Max 5)'),
                      Text(
                        '${_selectedColors.length}/5',
                        style: TextStyle(
                          color: _selectedColors.length >= 5
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ..._selectedColors.map(
                        (color) => Stack(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
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
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primaryUser,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Category
                  _buildInputLabel('Category'),
                  _buildPremiumInput(
                    _categoryCtrl,
                    'e.g. Kurtas, Sarees, Western',
                  ),

                  const SizedBox(height: 16),

                  // Description
                  _buildInputLabel('Description'),
                  _buildPremiumInput(
                    _descCtrl,
                    'Enter product description...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Stock Quantity
                  _buildInputLabel('Stock Quantity'),
                  _buildPremiumInput(_stockCtrl, 'e.g. 10', isNumber: true),

                  const SizedBox(height: 16),

                  // Availability
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Searchable in App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('Hide product without deleting it'),
                    value: _isAvailable,
                    activeTrackColor: AppColors.primaryUser,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),

                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryUser,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLoading ? 'SAVING...' : 'SAVE PRODUCT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    if (!_isLoading) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizePresetChip(String label) {
    final bool isSelected = _sizesCtrl.text.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        List<String> current = _sizesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (selected) {
          if (!current.contains(label)) current.add(label);
        } else {
          current.remove(label);
        }
        setState(() {
          _sizesCtrl.text = current.join(', ');
        });
      },
      selectedColor: AppColors.primaryUser.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryUser,
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textUser,
        ),
      ),
    );
  }

  Widget _buildPremiumInput(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: (v) => v!.isEmpty ? 'Required' : null,
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
            child: const Text('Add'),
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
