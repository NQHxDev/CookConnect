import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/models/product_category_type.dart';

class ProductActionBottomSheet extends StatelessWidget {
  final SellerProductItem product;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback? onQuickUpdateStock;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;

  const ProductActionBottomSheet({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleStatus,
    this.onQuickUpdateStock,
    this.onDelete,
    this.onDuplicate,
    this.onShare,
  });

  static Future<void> show({
    required BuildContext context,
    required SellerProductItem product,
    required VoidCallback onEdit,
    required VoidCallback onToggleStatus,
    VoidCallback? onQuickUpdateStock,
    VoidCallback? onDelete,
    VoidCallback? onDuplicate,
    VoidCallback? onShare,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductActionBottomSheet(
        product: product,
        onEdit: () {
          Navigator.of(ctx).pop();
          onEdit();
        },
        onToggleStatus: () {
          Navigator.of(ctx).pop();
          onToggleStatus();
        },
        onQuickUpdateStock: onQuickUpdateStock != null
            ? () {
                Navigator.of(ctx).pop();
                onQuickUpdateStock();
              }
            : null,
        onDelete: onDelete != null
            ? () {
                Navigator.of(ctx).pop();
                onDelete();
              }
            : null,
        onDuplicate: onDuplicate != null
            ? () {
                Navigator.of(ctx).pop();
                onDuplicate();
              }
            : null,
        onShare: onShare != null
            ? () {
                Navigator.of(ctx).pop();
                onShare();
              }
            : null,
      ),
    );
  }

  String _formatCurrency(double amount) {
    final int val = amount.round();
    final str = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }

  IconData _getCategoryPlaceholderIcon(String foodCategory) {
    final lower = foodCategory.toLowerCase();
    if (lower.contains('bò') || lower.contains('heo') || lower.contains('cừu') || lower.contains('gia cầm')) {
      return Iconsax.reserve;
    }
    if (lower.contains('thủy hải sản') || lower.contains('tôm') || lower.contains('cá')) {
      return Icons.set_meal;
    }
    if (lower.contains('trứng')) {
      return Icons.egg_outlined;
    }
    if (lower.contains('rau')) {
      return Icons.eco_outlined;
    }
    if (lower.contains('nấm') || lower.contains('đậu hũ')) {
      return Iconsax.box_1;
    }
    if (lower.contains('trái cây')) {
      return Icons.apple;
    }
    if (lower.contains('chế biến') || lower.contains('xúc xích')) {
      return Iconsax.archive_book;
    }
    if (lower.contains('gia vị')) {
      return Iconsax.magic_star;
    }
    if (lower.contains('đông lạnh')) {
      return Icons.ac_unit;
    }
    if (lower.contains('đồ hộp')) {
      return Iconsax.box_1;
    }
    if (lower.contains('sữa') || lower.contains('bơ') || lower.contains('đồ uống')) {
      return Iconsax.cup;
    }
    return Iconsax.box;
  }

  @override
  Widget build(BuildContext context) {
    final cat = product.categoryType;
    final displayPrice = product.hasMultipleSkus
        ? (product.minPrice == product.maxPrice
            ? _formatCurrency(product.minPrice)
            : '${_formatCurrency(product.minPrice)} - ${_formatCurrency(product.maxPrice)}')
        : _formatCurrency(product.price);

    final isInactive = cat == ProductCategoryType.disabled;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // 2. Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Iconsax.element_4,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tùy chọn sản phẩm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Quản lý trạng thái và thao tác nhanh',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Iconsax.close_circle, size: 22, color: AppColors.textHint),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),

            // 3. Mini Product Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Thumbnail
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: product.imageUrl != null
                                ? ((product.imageUrl!.startsWith('http://') || product.imageUrl!.startsWith('https://'))
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) => const Icon(
                                          Iconsax.box,
                                          color: AppColors.textHint,
                                          size: 26,
                                        ),
                                      )
                                    : Image.file(
                                        File(product.imageUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) => const Icon(
                                          Iconsax.box,
                                          color: AppColors.textHint,
                                          size: 26,
                                        ),
                                      ))
                                : Center(
                                    child: Icon(
                                      _getCategoryPlaceholderIcon(product.foodCategory),
                                      color: AppColors.primary,
                                      size: 26,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayPrice,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _buildCategoryBadge(cat),
                              Text(
                                'SKU: ${product.sku}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '• Kho: ${product.totalStock}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
            const SizedBox(height: 6),

            // 4. Action List Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Iconsax.edit_2,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                    title: 'Chỉnh sửa sản phẩm',
                    subtitle: 'Cập nhật tên, mô tả, ảnh, nhóm danh mục & phân loại',
                    onTap: onEdit,
                  ),
                  if (onQuickUpdateStock != null)
                    _buildActionTile(
                      icon: Iconsax.box_add,
                      iconColor: const Color(0xFF0288D1),
                      iconBgColor: const Color(0xFF0288D1).withValues(alpha: 0.1),
                      title: 'Kho hàng & Giá bán',
                      subtitle: 'Điều chỉnh nhanh số lượng tồn kho và giá bán lẻ',
                      onTap: onQuickUpdateStock!,
                    ),
                  _buildActionTile(
                    icon: isInactive ? Iconsax.play : Iconsax.pause,
                    iconColor: isInactive ? AppColors.success : const Color(0xFFF57C00),
                    iconBgColor: isInactive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : const Color(0xFFF57C00).withValues(alpha: 0.1),
                    title: isInactive ? 'Bật mở bán lại' : 'Tạm ngưng kinh doanh',
                    subtitle: isInactive
                        ? 'Đưa sản phẩm lên kệ để khách hàng tiếp tục mua sắm'
                        : 'Tạm ẩn sản phẩm khỏi gian hàng trên ứng dụng',
                    onTap: onToggleStatus,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isInactive
                            ? AppColors.textHint.withValues(alpha: 0.12)
                            : AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isInactive ? 'Đang tắt' : 'Đang bán',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isInactive ? AppColors.textSecondary : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  if (onDuplicate != null)
                    _buildActionTile(
                      icon: Iconsax.copy,
                      iconColor: const Color(0xFF7E57C2),
                      iconBgColor: const Color(0xFF7E57C2).withValues(alpha: 0.1),
                      title: 'Sao chép sản phẩm',
                      subtitle: 'Tạo sản phẩm mới nhanh chóng từ mẫu sản phẩm này',
                      onTap: onDuplicate!,
                    ),
                  if (onShare != null)
                    _buildActionTile(
                      icon: Iconsax.share,
                      iconColor: const Color(0xFF00897B),
                      iconBgColor: const Color(0xFF00897B).withValues(alpha: 0.1),
                      title: 'Chia sẻ sản phẩm',
                      subtitle: 'Sao chép thông tin hoặc chia sẻ tới khách hàng',
                      onTap: onShare!,
                    ),
                  if (onDelete != null)
                    _buildActionTile(
                      icon: Iconsax.trash,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.error.withValues(alpha: 0.1),
                      title: 'Ngừng bán & Xóa sản phẩm',
                      subtitle: 'Vô hiệu hóa hoặc ngừng bán vĩnh viễn sản phẩm này',
                      titleColor: AppColors.error,
                      subtitleColor: AppColors.error.withValues(alpha: 0.7),
                      isDestructive: true,
                      onTap: onDelete!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ProductCategoryType cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cat.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cat.color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: cat.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            cat.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cat.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? subtitleColor,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isDestructive ? AppColors.error.withValues(alpha: 0.04) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: subtitleColor ?? AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDestructive ? AppColors.error.withValues(alpha: 0.6) : AppColors.textHint,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
