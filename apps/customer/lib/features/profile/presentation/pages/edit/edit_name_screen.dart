import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _initialName;
  bool _isLoading = false;
  final int _maxLength = 50;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _initialName = user?.fullName ?? '';
    _nameController = TextEditingController(text: _initialName);
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasChanged =>
      _nameController.text.trim() != _initialName.trim() &&
      _nameController.text.trim().isNotEmpty;

  Future<void> _saveName() async {
    if (!_formKey.currentState!.validate() || !_hasChanged) return;

    final newName = _nameController.text.trim();
    setState(() => _isLoading = true);

    final token = AuthService.instance.tokens?.accessToken;

    if (token != null && token.isNotEmpty) {
      final apiService = ApiService();
      final result = await apiService.updateDisplayName(
        accessToken: token,
        displayName: newName,
      );

      if (!result.isSuccess) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Cập nhật tên hiển thị thất bại'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    // Update local session
    AuthService.instance.updateUser(fullName: newName);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentLength = _nameController.text.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: (_isLoading || !_hasChanged) ? null : _saveName,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                disabledForegroundColor: Colors.grey[400],
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tên hiển thị',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tên giúp bạn bè và người theo dõi dễ dàng tìm kiếm và nhận diện bạn trên CookConnect.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 6, 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      maxLength: _maxLength,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Chef Linh Đan',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Iconsax.close_circle,
                                  size: 19,
                                  color: Colors.grey[400],
                                ),
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                alignment: Alignment.centerRight,
                                onPressed: () => _nameController.clear(),
                              )
                            : null,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập họ và tên';
                        }
                        if (val.trim().length < 2) {
                          return 'Tên tối thiểu 2 ký tự';
                        }
                        return null;
                      },
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$currentLength/$_maxLength',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: currentLength >= _maxLength
                                  ? Colors.red
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
