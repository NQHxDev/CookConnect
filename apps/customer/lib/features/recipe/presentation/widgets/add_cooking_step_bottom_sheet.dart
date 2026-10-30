import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';

class AddCookingStepBottomSheet extends StatefulWidget {
  final CookingStep? editItem;
  final int stepNumber;

  const AddCookingStepBottomSheet({
    super.key,
    this.editItem,
    required this.stepNumber,
  });

  /// Static helper to display this bottom sheet smoothly
  static Future<CookingStep?> show(
    BuildContext context, {
    CookingStep? editItem,
    required int stepNumber,
  }) {
    return showModalBottomSheet<CookingStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCookingStepBottomSheet(
        editItem: editItem,
        stepNumber: stepNumber,
      ),
    );
  }

  @override
  State<AddCookingStepBottomSheet> createState() =>
      _AddCookingStepBottomSheetState();
}

class _AddCookingStepBottomSheetState extends State<AddCookingStepBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _tipController;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  final FocusNode _tipFocusNode = FocusNode();

  int _durationMinutes = 5;

  static const List<String> _quickStepTitles = [
    'Sơ chế nguyên liệu',
    'Ướp gia vị',
    'Phi thơm hành tỏi',
    'Xào chín tái',
    'Kho rim lửa nhỏ',
    'Ninh hầm nước dùng',
    'Chiên vàng giòn',
    'Nướng chín đều',
    'Nêm nếm hoàn tất',
    'Trình bày & Thưởng thức',
  ];

  static const List<int> _quickDurations = [1, 3, 5, 10, 15, 20, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editItem?.title ?? '');
    _descController =
        TextEditingController(text: widget.editItem?.description ?? '');
    _tipController = TextEditingController(text: widget.editItem?.tip ?? '');
    _durationMinutes = widget.editItem?.durationMinutes ?? 5;

    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tipController.dispose();
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    _tipFocusNode.dispose();
    super.dispose();
  }

  void _onQuickTitleSelected(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      _titleController.text = title;
    });
    if (_descController.text.trim().isEmpty) {
      _descFocusNode.requestFocus();
    }
  }

  void _adjustDuration(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _durationMinutes = (_durationMinutes + delta).clamp(1, 240);
    });
  }

  void _setDuration(int minutes) {
    HapticFeedback.selectionClick();
    setState(() {
      _durationMinutes = minutes.clamp(1, 240);
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final tip = _tipController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập hoặc chọn tiêu đề cho bước nấu!'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      _titleFocusNode.requestFocus();
      return;
    }

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập chi tiết thao tác thực hiện!'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      _descFocusNode.requestFocus();
      return;
    }

    final result = CookingStep(
      stepNumber: widget.stepNumber,
      title: title,
      description: desc,
      tip: tip.isEmpty ? null : tip,
      durationMinutes: _durationMinutes > 0 ? _durationMinutes : null,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final isEditing = widget.editItem != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            spreadRadius: 2,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.document_text_1,
                      color: Color(0xFFFF4D30),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isEditing
                                    ? 'Chỉnh sửa bước ${widget.stepNumber}'
                                    : 'Thêm bước nấu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECE8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Bước ${widget.stepNumber}',
                                style: const TextStyle(
                                  color: Color(0xFFFF4D30),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mô tả chi tiết thao tác để người xem dễ dàng nấu theo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 16),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick suggestion chips
                    _buildQuickSuggestions(),
                    const SizedBox(height: 16),

                    // Step Title Input
                    _buildTitleSection(),
                    const SizedBox(height: 16),

                    // Step Description Input
                    _buildDescriptionSection(),
                    const SizedBox(height: 16),

                    // Estimated Duration Selector
                    _buildDurationSection(),
                    const SizedBox(height: 16),

                    // Chef's Tip Card
                    _buildChefTipSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Iconsax.magicpen,
              size: 14,
              color: Color(0xFFFF4D30),
            ),
            const SizedBox(width: 6),
            Text(
              'Gợi ý nhanh tên bước:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickStepTitles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (ctx, index) {
              final title = _quickStepTitles[index];
              final isSelected =
                  _titleController.text.trim().toLowerCase() ==
                      title.toLowerCase();

              return InkWell(
                onTap: () => _onQuickTitleSelected(title),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFECE8)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF4D30)
                          : Colors.grey.shade200,
                      width: isSelected ? 1.2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFFF4D30)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tiêu đề bước nấu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFFF4D30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'VD: Phi thơm tỏi & xào thịt săn lại',
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: const Icon(
              Iconsax.edit_2,
              color: Color(0xFFFF4D30),
              size: 18,
            ),
            suffixIcon: _titleController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                    splashRadius: 16,
                    onPressed: () {
                      _titleController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFFF4D30),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Chi tiết thao tác thực hiện',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFFF4D30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descController,
          focusNode: _descFocusNode,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText:
                'Mô tả cụ thể cách thao tác, độ lửa lớn/nhỏ, thời gian chờ hoặc dấu hiệu nhận biết khi đạt yêu cầu...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              height: 1.4,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFFF4D30),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.clock,
                    size: 16,
                    color: Color(0xFFFF4D30),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Thời gian ước tính',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              // Display current duration badge & stepper
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepperButton(
                    icon: Icons.remove,
                    onTap: () => _adjustDuration(-1),
                    enabled: _durationMinutes > 1,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFECE8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$_durationMinutes phút',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4D30),
                      ),
                    ),
                  ),
                  _buildStepperButton(
                    icon: Icons.add,
                    onTap: () => _adjustDuration(1),
                    enabled: _durationMinutes < 240,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick duration pills
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickDurations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (ctx, index) {
                final d = _quickDurations[index];
                final isSelected = _durationMinutes == d;
                return InkWell(
                  onTap: () => _setDuration(d),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF4D30)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF4D30)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$d p',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildChefTipSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.lamp_charge,
                size: 16,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mẹo & Bí quyết đầu bếp',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kinh nghiệm nhỏ giúp món ăn dậy vị thơm hoặc nấu nhanh hơn',
            style: TextStyle(
              fontSize: 11,
              color: Colors.amber.shade900.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tipController,
            focusNode: _tipFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'VD: Đảo nhanh trên lửa lớn để thịt bò mềm ngọt, không bị dai...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade800.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFDE68A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFD97706),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Huỷ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D30),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Iconsax.tick_circle, size: 18),
              label: Text(
                isEditing ? 'Lưu thay đổi' : 'Lưu bước nấu',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
