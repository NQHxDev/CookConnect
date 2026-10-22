import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

class ShippingStatusBottomSheet extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelected;

  const ShippingStatusBottomSheet({
    super.key,
    required this.selectedStatus,
    required this.onSelected,
  });

  static const List<String> statusList = [
    'Tất cả',
    'Đang chờ vận chuyển', // Chọn mặc định
    'Đang chờ lấy hàng',
    'Giao hàng không thành công',
    'Đang trung chuyển',
    'Đã giao hàng',
    'Chưa thanh toán',
    'Tạm hoãn',
    'Đã hủy',
    'Đã hoàn thành',
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
      builder: (ctx) => ShippingStatusBottomSheet(
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
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
                  const Icon(Iconsax.truck_fast, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Trạng thái vận chuyển',
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
                  final isDefault = status == 'Đang chờ vận chuyển';

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
                            child: Row(
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Mặc định',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
