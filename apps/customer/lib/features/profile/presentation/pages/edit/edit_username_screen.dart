import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/core/network/api_service.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';

class EditUsernameScreen extends StatefulWidget {
  const EditUsernameScreen({super.key});

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late String _initialUsername;

  Timer? _debounceTimer;
  bool _isChecking = false;
  bool? _isAvailable; // true: available, false: taken / invalid, null: unchanged or empty
  String? _validationError;
  String? _serverError;
  bool _isLoading = false;
  final int _maxLength = 30;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    String initial = user?.username ?? '';
    if (initial.isEmpty && user != null && user.email.isNotEmpty) {
      initial = user.email
          .split('@')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
          .toLowerCase();
    }
    _initialUsername = initial;
    _usernameController = TextEditingController(text: initial);
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    _debounceTimer?.cancel();

    final current = _usernameController.text.trim().toLowerCase();

    if (_serverError != null) {
      setState(() => _serverError = null);
    }

    if (current.isEmpty) {
      setState(() {
        _isChecking = false;
        _isAvailable = null;
        _validationError = 'Vui lòng nhập tên người dùng';
      });
      return;
    }

    // If matches the existing user's username
    if (current == _initialUsername.trim().toLowerCase()) {
      setState(() {
        _isChecking = false;
        _isAvailable = null;
        _validationError = null;
      });
      return;
    }

    // Format validation
    if (current.length < 3) {
      setState(() {
        _isChecking = false;
        _isAvailable = false;
        _validationError = 'Tên người dùng tối thiểu 3 ký tự';
      });
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(current)) {
      setState(() {
        _isChecking = false;
        _isAvailable = false;
        _validationError =
            'Chỉ được dùng chữ cái thường (a-z), số (0-9) và dấu gạch dưới (_)';
      });
      return;
    }

    // Valid format -> Start debounce check with backend API
    setState(() {
      _isChecking = true;
      _isAvailable = null;
      _validationError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final apiService = ApiService();
      final available = await apiService.checkUsername(current);

      if (!mounted) return;
      if (_usernameController.text.trim().toLowerCase() == current) {
        setState(() {
          _isChecking = false;
          _isAvailable = available;
          if (!available) {
            _validationError = 'Tên người dùng này đã được sử dụng';
          } else {
            _validationError = null;
          }
        });
      }
    });
  }

  bool get _hasChanged {
    final current = _usernameController.text.trim().toLowerCase();
    return current != _initialUsername.trim().toLowerCase();
  }

  bool get _canSave {
    return _hasChanged &&
        !_isLoading &&
        !_isChecking &&
        _isAvailable == true &&
        _validationError == null;
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate() || !_canSave) return;

    final newUsername = _usernameController.text.trim().toLowerCase();
    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    final token = AuthService.instance.tokens?.accessToken;

    if (token != null && token.isNotEmpty) {
      final apiService = ApiService();
      final result = await apiService.updateUsername(
        accessToken: token,
        username: newUsername,
      );

      if (!result.isSuccess) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isAvailable = false;
          _serverError = result.error ?? 'Tên người dùng đã được sử dụng';
        });
        return;
      }
    }

    // Update local session
    AuthService.instance.updateUser(username: newUsername);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currentLength = _usernameController.text.length;

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
          'Tên người dùng',
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
              onPressed: _canSave ? _saveUsername : null,
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
                'Tên người dùng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tên người dùng là duy nhất, chỉ chứa chữ thường, số và dấu gạch dưới. Dùng để tạo liên kết cá nhân của bạn.',
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
                  border: Border.all(
                    color: (_isAvailable == false || _serverError != null)
                        ? Colors.red.withValues(alpha: 0.6)
                        : (_isAvailable == true
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.6)
                            : Colors.grey.withValues(alpha: 0.2)),
                    width: (_isAvailable != null || _serverError != null) ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      maxLength: _maxLength,
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixText: '@',
                        prefixStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        hintText: 'username',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Checking spinner
                            if (_isChecking)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange,
                                  ),
                                ),
                              )
                            // Clean modern checkmark (without circle) sitting tightly next to clear button
                            else if (_isAvailable == true)
                              const Padding(
                                padding: EdgeInsets.only(right: 3),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 21,
                                ),
                              )
                            // Clean modern cross (without circle) sitting tightly next to clear button
                            else if (_isAvailable == false || _serverError != null)
                              const Padding(
                                padding: EdgeInsets.only(right: 3),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.red,
                                  size: 21,
                                ),
                              ),

                            // Clear 'x' button
                            if (_usernameController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () => _usernameController.clear(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2, right: 2),
                                  child: Icon(
                                    Iconsax.close_circle,
                                    size: 19,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập tên người dùng';
                        }
                        final clean = val.trim().toLowerCase();
                        if (clean.length < 3) {
                          return 'Tên người dùng tối thiểu 3 ký tự';
                        }
                        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(clean)) {
                          return 'Chỉ được dùng chữ cái thường, số và dấu gạch dưới (_)';
                        }
                        return null;
                      },
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'cookconnect.app/@${_usernameController.text.trim().toLowerCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

              const SizedBox(height: 10),

              // Status / Validation / Availability feedback message (được chuẩn hoá khoảng cách chuẩn 8px)
              if (_isChecking)
                _buildFeedbackMessage(
                  icon: Iconsax.refresh,
                  color: Colors.orange,
                  message: 'Đang kiểm tra tính khả dụng...',
                )
              else if (_isAvailable == true)
                _buildFeedbackMessage(
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF2E7D32),
                  message: 'Tên người dùng này có thể sử dụng!',
                )
              else if (_validationError != null || _serverError != null)
                _buildFeedbackMessage(
                  icon: Icons.cancel_rounded,
                  color: Colors.red,
                  message: _validationError ?? _serverError!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackMessage({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Center(
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
