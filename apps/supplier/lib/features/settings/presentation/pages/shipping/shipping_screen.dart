import 'package:flutter/material.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  // Danh sách các phương thức giao hàng nhanh
  final Map<String, bool> _shippingOptions = {
    '30min': false,
    '1hour': false,
    '2hours': false,
    '5hours': false,
    '1day': false,
  };

  final Map<String, String> _optionTitles = {
    '30min': 'Giao hỏa tốc 30 phút',
    '1hour': 'Giao nhanh 1 giờ',
    '2hours': 'Giao nhanh 2 giờ',
    '5hours': 'Giao trong 5 giờ',
    '1day': 'Giao trong 1 ngày',
  };

  bool _hasChanges = false;

  void _toggleOption(String key) {
    setState(() {
      _shippingOptions[key] = !_shippingOptions[key]!;
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    // TODO: Implement API call to save shipping options
    final selectedOptions = _shippingOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedOptions.isEmpty
                ? 'Đã lưu: Chỉ hỗ trợ giao hàng chậm hơn'
                : 'Đã lưu ${selectedOptions.length} phương thức giao hàng',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _hasChanges = false;
      });
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
          'Giao hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
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
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Section header
              _buildSectionHeader('Phương thức giao hàng nhanh', isFirst: true),
              
              // Shipping options container
              _buildSectionContainer(
                children: _shippingOptions.entries.map((entry) {
                  return _buildShippingItem(
                    title: _optionTitles[entry.key]!,
                    isSelected: entry.value,
                    onTap: () => _toggleOption(entry.key),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Section header for slow shipping
              _buildSectionHeader('Giao hàng chậm hơn'),
              
              // Info container
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
                        'Các đơn hàng không yêu cầu giao nhanh sẽ được xử lý theo lịch trình thông thường (giao sau 1 ngày trở lên).',
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

  Widget _buildShippingItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
