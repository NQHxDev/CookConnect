import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';

enum ProductCategoryType {
  onShelf(
    id: 'on_shelf',
    label: 'Trên kệ',
    description: 'Sản phẩm đang được mở bán trên ứng dụng',
    icon: Iconsax.box_tick,
    color: AppColors.success,
  ),
  lowStock(
    id: 'low_stock',
    label: 'Còn ít',
    description: 'Sản phẩm có tồn kho thấp, cần nhập thêm hàng',
    icon: Iconsax.warning_2,
    color: AppColors.warning,
  ),
  disabled(
    id: 'disabled',
    label: 'Đã vô hiệu hóa',
    description: 'Sản phẩm đang tạm ngưng hoặc tắt hiển thị',
    icon: Iconsax.slash,
    color: AppColors.textSecondary,
  ),
  underReview(
    id: 'under_review',
    label: 'Đang xét duyệt',
    description: 'Sản phẩm đang chờ CookConnect kiểm duyệt',
    icon: Iconsax.clock,
    color: AppColors.info,
  ),
  failed(
    id: 'failed',
    label: 'Không thành công',
    description: 'Sản phẩm không đạt tiêu chuẩn phê duyệt',
    icon: Iconsax.close_circle,
    color: AppColors.error,
  ),
  frozen(
    id: 'frozen',
    label: 'Đóng băng',
    description: 'Sản phẩm tạm khóa do vi phạm hoặc điều tra',
    icon: Iconsax.lock,
    color: Color(0xFF8E24AA),
  ),
  draft(
    id: 'draft',
    label: 'Bản nháp',
    description: 'Sản phẩm chưa hoàn thiện thông tin, chưa đăng tải',
    icon: Iconsax.document_text,
    color: Color(0xFF546E7A),
  );

  const ProductCategoryType({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
}
