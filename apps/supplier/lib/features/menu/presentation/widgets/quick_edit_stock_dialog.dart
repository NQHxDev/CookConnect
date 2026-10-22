import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/seller_product_item.dart';

class QuickEditStockDialog extends StatefulWidget {
  final SellerProductItem product;
  final void Function(int newStock, double newPrice) onSave;

  const QuickEditStockDialog({
    super.key,
    required this.product,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required SellerProductItem product,
    required void Function(int newStock, double newPrice) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => QuickEditStockDialog(
        product: product,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickEditStockDialog> createState() => _QuickEditStockDialogState();
}

class _QuickEditStockDialogState extends State<QuickEditStockDialog> {
  late TextEditingController _stockController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final stock = int.tryParse(_stockController.text.trim()) ?? widget.product.stock;
    final price = double.tryParse(_priceController.text.trim()) ?? widget.product.price;
    widget.onSave(stock, price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Iconsax.box_add, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Cập nhật nhanh kho & giá',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Mã SKU: ${widget.product.sku}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 16),
            const Text(
              'Số lượng tồn kho',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    final cur = int.tryParse(_stockController.text) ?? 0;
                    if (cur > 0) {
                      _stockController.text = (cur - 1).toString();
                    }
                  },
                  icon: const Icon(Icons.remove, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () {
                    final cur = int.tryParse(_stockController.text) ?? 0;
                    _stockController.text = (cur + 1).toString();
                  },
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Giá bán (VNĐ)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixText: 'đ',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Lưu thay đổi'),
        ),
      ],
    );
  }
}
