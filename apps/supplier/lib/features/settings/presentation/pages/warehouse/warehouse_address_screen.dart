import 'package:flutter/material.dart';

class WarehouseAddressScreen extends StatefulWidget {
  const WarehouseAddressScreen({super.key});

  @override
  State<WarehouseAddressScreen> createState() => _WarehouseAddressScreenState();
}

class _WarehouseAddressScreenState extends State<WarehouseAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _streetController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _hasChanges = false;
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    _loadWarehouseAddress();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouseAddress() async {
    // TODO: Load warehouse address from API
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data
    setState(() {
      _streetController.text = '123 Nguyễn Văn Linh';
      _wardController.text = 'Phường Tân Phú';
      _districtController.text = 'Quận 7';
      _cityController.text = 'TP. Hồ Chí Minh';
      _postalCodeController.text = '700000';
      _notesController.text = 'Gần chợ Tân Mỹ';
    });
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Save warehouse address via API
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu địa chỉ kho hàng'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _hasChanges = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Địa chỉ kho hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveAddress,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Section: Địa chỉ chính
                _buildSectionHeader('Địa chỉ chính', isFirst: true),
                _buildSectionContainer(
                  children: [
                    _buildTextField(
                      controller: _streetController,
                      label: 'Số nhà, tên đường',
                      placeholder: 'Ví dụ: 123 Nguyễn Văn Linh',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập địa chỉ đường';
                        }
                        return null;
                      },
                    ),
                    _buildDivider(),
                    _buildTextField(
                      controller: _wardController,
                      label: 'Phường/Xã',
                      placeholder: 'Ví dụ: Phường Tân Phú',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập phường/xã';
                        }
                        return null;
                      },
                    ),
                    _buildDivider(),
                    _buildTextField(
                      controller: _districtController,
                      label: 'Quận/Huyện',
                      placeholder: 'Ví dụ: Quận 7',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập quận/huyện';
                        }
                        return null;
                      },
                    ),
                    _buildDivider(),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Tỉnh/Thành phố',
                      placeholder: 'Ví dụ: TP. Hồ Chí Minh',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Vui lòng nhập tỉnh/thành phố';
                        }
                        return null;
                      },
                    ),
                    _buildDivider(),
                    _buildTextField(
                      controller: _postalCodeController,
                      label: 'Mã bưu điện',
                      placeholder: 'Ví dụ: 700000',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section: Thông tin bổ sung
                _buildSectionHeader('Thông tin bổ sung'),
                _buildSectionContainer(
                  children: [
                    _buildTextField(
                      controller: _notesController,
                      label: 'Ghi chú',
                      placeholder: 'Ví dụ: Gần chợ Tân Mỹ',
                      maxLines: 3,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section: Tùy chọn
                _buildSectionHeader('Tùy chọn'),
                _buildSectionContainer(
                  children: [
                    _buildSwitchItem(
                      title: 'Đặt làm địa chỉ mặc định',
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                          _hasChanges = true;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info note
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Địa chỉ kho hàng sẽ được sử dụng để tính toán khoảng cách giao hàng và phí vận chuyển cho khách hàng.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 12 : 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 14.5,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: validator,
            onChanged: (_) => _onFieldChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[300],
      indent: 16,
      endIndent: 16,
    );
  }
}
