import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/seller_product_item.dart';
import '../../data/models/product_category_type.dart';

class ProductCardItem extends StatelessWidget {
  final SellerProductItem product;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback? onQuickUpdateStock;
  final VoidCallback? onDelete;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleStatus,
    this.onQuickUpdateStock,
    this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    final cat = product.categoryType;
    final displayPrice = product.hasMultipleSkus
        ? (product.minPrice == product.maxPrice
            ? _formatCurrency(product.minPrice)
            : '${_formatCurrency(product.minPrice)} - ${_formatCurrency(product.maxPrice)}')
        : _formatCurrency(product.price);

    final displayStock = product.totalStock;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cat == ProductCategoryType.failed || cat == ProductCategoryType.frozen
              ? cat.color.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail
                Stack(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (product.imageUrl!.startsWith('http://') || product.imageUrl!.startsWith('https://'))
                                  ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Iconsax.box,
                                        color: AppColors.textHint,
                                        size: 32,
                                      ),
                                    )
                                  : Image.file(
                                      File(product.imageUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Iconsax.box,
                                        color: AppColors.textHint,
                                        size: 32,
                                      ),
                                    ),
                            )
                          : Center(
                              child: Icon(
                                _getCategoryPlaceholderIcon(product.foodCategory),
                                color: AppColors.primary.withValues(alpha: 0.6),
                                size: 34,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          product.sku,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Main Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Price & Original Price
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayPrice,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!product.hasMultipleSkus &&
                              product.originalPrice != null &&
                              product.originalPrice! > product.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              _formatCurrency(product.originalPrice!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stock, Sold count, SKUs badge & Category badge
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (product.hasMultipleSkus)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${product.skus.length} phân loại',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: displayStock <= 5
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Kho: $displayStock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: displayStock <= 5 ? FontWeight.w600 : FontWeight.normal,
                                color: displayStock <= 5 ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            'Đã bán: ${product.soldCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          _buildStatusBadge(cat),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Reason Banner (for Failed or Frozen items)
            if (product.rejectReason != null || product.freezeReason != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: cat.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      cat == ProductCategoryType.failed ? Iconsax.info_circle : Iconsax.warning_2,
                      size: 15,
                      color: cat.color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        product.rejectReason ?? product.freezeReason ?? '',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: cat.color,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Card Actions Divider & Row
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onQuickUpdateStock != null) ...[
                  OutlinedButton.icon(
                    onPressed: onQuickUpdateStock,
                    icon: const Icon(Iconsax.box_add, size: 14),
                    label: const Text('Kho & Giá'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      minimumSize: const Size(0, 32),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Iconsax.edit_2, size: 14),
                  label: const Text('Chỉnh sửa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (value) {
                    if (value == 'toggle') {
                      onToggleStatus();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            cat == ProductCategoryType.disabled ? Iconsax.play : Iconsax.pause,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(cat == ProductCategoryType.disabled ? 'Bật mở bán' : 'Tắt tạm ngưng'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Iconsax.share, size: 16, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('Chia sẻ sản phẩm'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Iconsax.copy, size: 16, color: AppColors.textPrimary),
                          SizedBox(width: 8),
                          Text('Sao chép sản phẩm'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Xóa sản phẩm', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProductCategoryType cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
}
