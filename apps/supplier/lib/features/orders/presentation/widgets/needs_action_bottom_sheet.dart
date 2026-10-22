import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import 'package:cook_connect_seller/features/orders/presentation/widgets/terms_explanation_bottom_sheet.dart';

class NeedsActionBottomSheet extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelected;

  const NeedsActionBottomSheet({
    super.key,
    required this.selectedStatus,
    required this.onSelected,
  });

  static const List<String> statusList = [
    'Tất cả đơn hàng cần xử lý',
    'Cần vận chuyển trong vòng 24h',
    'Tự động hủy trong 24h trở xuống',
    'Quá hạn vận chuyển',
    'Đã hủy yêu cầu',
    'Vấn đề gửi hàng',
    'Vấn đề vận chuyển hoặc giao hàng không thành công',
    'Đã yêu cầu trả hàng - Hoàn tiền',
  ];

  static Future<String?> show({
    required BuildContext context,
    required String currentStatus,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NeedsActionBottomSheet(
        selectedStatus: currentStatus,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Iconsax.clock, size: 20, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Text(
                    'Đơn hàng cần xử lý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 22, color: AppColors.textHint),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: statusList.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final status = statusList[index];
                  final isSelected = status == selectedStatus;

                  return InkWell(
                    onTap: () {
                      onSelected(status);
                      Navigator.of(context).pop(status);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Iconsax.tick_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Phần dưới cùng: Giải thích thuật ngữ
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    TermsExplanationBottomSheet.show(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Iconsax.info_circle,
                          size: 15,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Giải thích thuật ngữ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
