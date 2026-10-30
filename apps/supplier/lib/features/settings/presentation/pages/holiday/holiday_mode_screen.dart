import 'package:flutter/material.dart';

class HolidayModeScreen extends StatefulWidget {
  const HolidayModeScreen({super.key});

  @override
  State<HolidayModeScreen> createState() => _HolidayModeScreenState();
}

class _HolidayModeScreenState extends State<HolidayModeScreen> {
  bool _isHolidayMode = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String _autoReplyMessage = '';
  bool _hasChanges = false;

  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHolidaySettings();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadHolidaySettings() async {
    // TODO: Load holiday settings from API
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data
    setState(() {
      _isHolidayMode = false;
      _messageController.text = 'Cửa hàng đang tạm nghỉ. Chúng tôi sẽ quay lại phục vụ quý khách sau kỳ nghỉ. Xin cảm ơn!';
      _autoReplyMessage = _messageController.text;
    });
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, clear it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveSettings() async {
    // Validation
    if (_isHolidayMode) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ngày bắt đầu và kết thúc'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập thông báo tự động'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // TODO: Save holiday settings via API
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isHolidayMode 
                ? 'Đã bật chế độ nghỉ lễ'
                : 'Đã tắt chế độ nghỉ lễ',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _hasChanges = false;
        _autoReplyMessage = _messageController.text;
      });
    }
  }

  String _formatDate(DateTime date) {
    // Format: dd/MM/yyyy
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
          'Chế độ nghỉ lễ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSettings,
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
              // Section: Trạng thái
              _buildSectionHeader('Trạng thái', isFirst: true),
              _buildSectionContainer(
                children: [
                  _buildSwitchItem(
                    title: 'Bật chế độ nghỉ lễ',
                    subtitle: _isHolidayMode 
                        ? 'Cửa hàng đang tạm nghỉ'
                        : 'Cửa hàng đang hoạt động',
                    value: _isHolidayMode,
                    onChanged: (value) {
                      setState(() {
                        _isHolidayMode = value;
                        _hasChanges = true;
                      });
                    },
                  ),
                ],
              ),

              if (_isHolidayMode) ...[
                const SizedBox(height: 16),

                // Section: Thời gian nghỉ
                _buildSectionHeader('Thời gian nghỉ'),
                _buildSectionContainer(
                  children: [
                    _buildDateItem(
                      title: 'Ngày bắt đầu',
                      date: _startDate,
                      onTap: () => _selectDate(context, true),
                    ),
                    _buildDivider(),
                    _buildDateItem(
                      title: 'Ngày kết thúc',
                      date: _endDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section: Thông báo tự động
                _buildSectionHeader('Thông báo tự động'),
                _buildSectionContainer(
                  children: [
                    _buildMessageField(),
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
                          'Khi bật chế độ nghỉ lễ, cửa hàng sẽ không nhận đơn hàng mới. Thông báo tự động sẽ được gửi đến khách hàng khi họ cố gắng đặt hàng.',
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
              ],

              if (!_isHolidayMode) ...[
                const SizedBox(height: 16),

                // Info note when disabled
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
                          'Chế độ nghỉ lễ giúp bạn tạm dừng nhận đơn hàng trong các dịp nghỉ, lễ tết mà không cần đóng cửa hàng vĩnh viễn.',
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
              ],

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

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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

  Widget _buildDateItem({
    required String title,
    required DateTime? date,
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
              Text(
                date != null ? _formatDate(date) : 'Chọn ngày',
                style: TextStyle(
                  fontSize: 14.5,
                  color: date != null ? Colors.black87 : Colors.grey[400],
                  fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tin nhắn gửi khách hàng',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 4,
            maxLength: 200,
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập thông báo tự động...',
              hintStyle: TextStyle(
                fontSize: 14.5,
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            onChanged: (_) => _onFieldChanged(),
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
