import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;
  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _selectedState;
  bool _isDefault = false;
  bool _isLoadingPincode = false;

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  @override
  void initState() {
    super.initState();
    _pincodeController.addListener(_onPincodeChanged);

    if (widget.existingAddress != null) {
      final addr = widget.existingAddress!;
      _nameController.text = addr['name'] ?? '';
      _phoneController.text = addr['phone'] ?? '';
      _pincodeController.text = (addr['zip'] ?? addr['pincode'] ?? '')
          .toString();
      _cityController.text = addr['city'] ?? '';
      _selectedState = addr['state'];
      _isDefault = addr['is_default'] ?? false;

      // Parsing street address back into parts is tricky as it's stored as one string.
      // We will put the full street into address1 and let the user edit it.
      // address2 and landmark will be empty initially in edit mode unless we parse logic.
      // For simplicity, we put everything in Address 1 for now or try to split if CSV.
      String fullStreet = addr['street'] ?? '';
      List<String> parts = fullStreet.split(', ');

      if (parts.isNotEmpty) {
        _address1Controller.text = parts[0];
        if (parts.length > 1) _address2Controller.text = parts[1];
        if (parts.length > 2)
          _landmarkController.text = parts.sublist(2).join(', ');
      }
    }
  }

  void _onPincodeChanged() {
    if (_pincodeController.text.length == 6) {
      _fetchPincodeDetails(_pincodeController.text);
    }
  }

  Future<void> _fetchPincodeDetails(String pincode) async {
    setState(() => _isLoadingPincode = true);
    try {
      final response = await http.get(
        Uri.parse('http://www.postalpincode.in/api/pincode/$pincode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Status'] == 'Success') {
          final postOffices = data['PostOffice'] as List;
          if (postOffices.isNotEmpty) {
            final first = postOffices.first;
            final district = first['District'];
            final state = first['State'];

            if (mounted) {
              setState(() {
                _cityController.text = district;

                // Try to match state case-insensitively or exact match
                final matchedState = _states.firstWhere(
                  (s) => s.toLowerCase() == state.toString().toLowerCase(),
                  orElse: () => '',
                );

                if (matchedState.isNotEmpty) {
                  _selectedState = matchedState;
                } else if (_states.contains(state)) {
                  _selectedState = state;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Details found: $district, $state')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Invalid Pincode')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Pincode fetch error: $e');
        // Silent fail or notify
      }
    } finally {
      if (mounted) setState(() => _isLoadingPincode = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _address1Controller.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) return;

      final addressData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address1': _address1Controller.text,
        'address2': _address2Controller.text,
        'landmark': _landmarkController.text,
        'pincode': _pincodeController.text,
        'city': _cityController.text,
        'state': _selectedState,
        'isDefault': _isDefault,
      };

      if (widget.existingAddress != null) {
        await context.read<DatabaseService>().updateAddress(
          user.id,
          widget.existingAddress!['id'].toString(),
          addressData,
        );
      } else {
        addressData['createdAt'] = DateTime.now().toIso8601String();
        await context
            .read<DatabaseService>()
            .addAddress(user.id, addressData)
            .timeout(const Duration(seconds: 10));
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving address: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingAddress != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundUser,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        title: Text(
          isEditing ? 'Edit Address' : 'Add Delivery Address',
          style: const TextStyle(
            color: AppColors.textUser,
            fontWeight: FontWeight.bold,
            fontFamily: 'Epilogue',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textUser),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0DA79086),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'Full Name',
                    'Enter your full name',
                    _nameController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Phone Number',
                    '10-digit mobile number',
                    _phoneController,
                    inputType: TextInputType.phone,
                    icon: Icons.call,
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 0, color: Colors.transparent),
                  _buildTextField(
                    'Flat, House no., Building',
                    'e.g. Flat 402, Rose Apartments',
                    _address1Controller,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Area, Colony, Street',
                    'e.g. Sector 12, Main Street',
                    _address2Controller,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Landmark',
                    'e.g. Near City Center Mall',
                    _landmarkController,
                    isOptional: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Pincode',
                          '000000',
                          _pincodeController,
                          inputType: TextInputType.number,
                          isLoading: _isLoadingPincode,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('City', 'City', _cityController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _isDefault = !_isDefault),
              child: Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val!),
                    activeColor: AppColors.primaryUser,
                  ),
                  const Text(
                    'Use as default address',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: AppColors.backgroundUser.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: AppColors.primaryUser.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryUser,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: AppColors.primaryUser.withValues(alpha: 0.4),
            elevation: 8,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller, {
    IconData? icon,
    TextInputType inputType = TextInputType.text,
    bool isOptional = false,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textUser,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryUser.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ],
            if (isLoading) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textMuted)
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryUser),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textUser,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              isExpanded: true,
              hint: Text(
                'Select State',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
              icon: const Icon(Icons.expand_more, color: AppColors.textMuted),
              items: _states.map((String state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedState = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
