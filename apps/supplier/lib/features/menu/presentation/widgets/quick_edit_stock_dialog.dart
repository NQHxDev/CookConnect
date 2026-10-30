import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cook_connect_seller/core/theme/app_colors.dart';
import '../../data/models/seller_product_item.dart';

/// Formatter that automatically inserts dots as thousands separators in Vietnamese currency
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final number = int.tryParse(digits) ?? 0;
    final formatted = formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatNumber(int val) {
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
    return buffer.toString().split('').reversed.join('');
  }
}

class QuickEditStockBottomSheet extends StatefulWidget {
  final SellerProductItem product;
  final void Function(int newStock, double newPrice) onSave;

  const QuickEditStockBottomSheet({
    super.key,
    required this.product,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required SellerProductItem product,
    required void Function(int newStock, double newPrice) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickEditStockBottomSheet(
        product: product,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickEditStockBottomSheet> createState() => _QuickEditStockBottomSheetState();
}

// Backward compatibility alias
typedef QuickEditStockDialog = QuickEditStockBottomSheet;

class _QuickEditStockBottomSheetState extends State<QuickEditStockBottomSheet> {
  late TextEditingController _stockController;
  late TextEditingController _priceController;

  late final int _initialStock;
  late final double _initialPrice;

  int _currentStock = 0;
  double _currentPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initialStock = widget.product.stock;
    _initialPrice = widget.product.price;

    _currentStock = _initialStock;
    _currentPrice = _initialPrice;

    _stockController = TextEditingController(text: _initialStock.toString());
    _priceController = TextEditingController(
      text: ThousandsSeparatorInputFormatter.formatNumber(_initialPrice.round()),
    );

    _stockController.addListener(_onStockChanged);
    _priceController.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    _stockController.removeListener(_onStockChanged);
    _priceController.removeListener(_onPriceChanged);
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onStockChanged() {
    final parsed = _parseStock(_stockController.text);
    if (parsed != _currentStock) {
      setState(() {
        _currentStock = parsed;
      });
    }
  }

  void _onPriceChanged() {
    final parsed = _parsePrice(_priceController.text);
    if (parsed != _currentPrice) {
      setState(() {
        _currentPrice = parsed;
      });
    }
  }

  int _parseStock(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }

  double _parsePrice(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(digits) ?? 0.0;
  }

  String _formatCurrency(double amount) {
    return '${ThousandsSeparatorInputFormatter.formatNumber(amount.round())} đ';
  }

  void _adjustStock(int delta) {
    HapticFeedback.selectionClick();
    final next = (_currentStock + delta).clamp(0, 999999);
    _stockController.text = next.toString();
    _stockController.selection = TextSelection.collapsed(offset: _stockController.text.length);
  }

  void _setStock(int value) {
    HapticFeedback.selectionClick();
    _stockController.text = value.toString();
    _stockController.selection = TextSelection.collapsed(offset: _stockController.text.length);
  }

  void _adjustPrice(double delta) {
    HapticFeedback.selectionClick();
    final next = (_currentPrice + delta).clamp(0, 999999999).toDouble();
    _setPrice(next);
  }

  void _setPrice(double newPrice) {
    HapticFeedback.selectionClick();
    final formatted = ThousandsSeparatorInputFormatter.formatNumber(newPrice.round());
    _priceController.text = formatted;
    _priceController.selection = TextSelection.collapsed(offset: formatted.length);
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final stock = _parseStock(_stockController.text);
    final price = _parsePrice(_priceController.text);

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giá bán lớn hơn 0'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSave(stock, price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final priceDifference = _currentPrice - _initialPrice;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardBottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // 2. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.edit,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cập nhật Kho & Giá bán',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Điều chỉnh nhanh số lượng tồn kho và giá niêm yết',
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: widget.product.imageUrl != null
                                ? ((widget.product.imageUrl!.startsWith('http://') ||
                                        widget.product.imageUrl!.startsWith('https://'))
                                    ? Image.network(
                                        widget.product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) => const Icon(
                                          Iconsax.box,
                                          color: AppColors.textHint,
                                          size: 24,
                                        ),
                                      )
                                    : Image.file(
                                        File(widget.product.imageUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, _, _) => const Icon(
                                          Iconsax.box,
                                          color: AppColors.textHint,
                                          size: 24,
                                        ),
                                      ))
                                : Center(
                                    child: Icon(
                                      _getCategoryPlaceholderIcon(widget.product.foodCategory),
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'SKU: ${widget.product.sku}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textHint,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '• Đang bán: ${_formatCurrency(_initialPrice)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
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

                // 4. Price Section (Customized Modal Bottom Sheet Style)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.tag,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Giá bán niêm yết (VNĐ)',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ĐVT: ${widget.product.unit.isNotEmpty ? widget.product.unit : 'Sản phẩm'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price Input Field Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: priceDifference != 0 ? AppColors.primary : Colors.grey.shade300,
                              width: priceDifference != 0 ? 1.5 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '₫',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: AppColors.textHint),
                                  ),
                                ),
                              ),
                              if (_priceController.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _priceController.clear();
                                    setState(() {
                                      _currentPrice = 0;
                                    });
                                  },
                                  icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.textHint),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                        // Price Difference Alert
                        if (priceDifference != 0 && _initialPrice > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                priceDifference > 0 ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                                size: 14,
                                color: priceDifference > 0 ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                priceDifference > 0
                                    ? '+${_formatCurrency(priceDifference)} (+${((priceDifference / _initialPrice) * 100).toStringAsFixed(1)}%) so với giá gốc'
                                    : '-${_formatCurrency(-priceDifference)} (-${(((-priceDifference) / _initialPrice) * 100).toStringAsFixed(1)}%) so với giá gốc',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: priceDifference > 0 ? AppColors.success : AppColors.warning,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => _setPrice(_initialPrice),
                                child: const Text(
                                  'Khôi phục',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Quick price buttons
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildQuickPriceChip('+5.000đ', 5000),
                            _buildQuickPriceChip('+10.000đ', 10000),
                            _buildQuickPriceChip('+20.000đ', 20000),
                            _buildQuickPriceChip('+50.000đ', 50000),
                            _buildQuickPriceChip('-5.000đ', -5000),
                            _buildQuickPriceChip('-10.000đ', -10000),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Stock Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0288D1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.box,
                                size: 16,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Số lượng tồn kho',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            _buildStockStatusBadge(_currentStock),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stepper row
                        Row(
                          children: [
                            Material(
                              color: _currentStock > 0 ? Colors.grey.shade100 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: _currentStock > 0 ? () => _adjustStock(-1) : null,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: _currentStock > 0 ? AppColors.textPrimary : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: '0',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Material(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _adjustStock(1),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Quick stock chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildQuickStockChip('+1', 1),
                            _buildQuickStockChip('+5', 5),
                            _buildQuickStockChip('+10', 10),
                            _buildQuickStockChip('+20', 20),
                            _buildQuickStockChip('+50', 50),
                            _buildQuickSetStockChip('Hết hàng (0)', 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Multi-SKU Hint (if applicable)
                if (widget.product.hasMultipleSkus) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Iconsax.info_circle, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sản phẩm này có ${widget.product.skus.length} phân loại. Để sửa chi tiết từng phân loại, vui lòng chọn "Chỉnh sửa sản phẩm".',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.blue.shade800,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 7. Action Buttons
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Iconsax.tick_circle, size: 18),
                          label: const Text(
                            'Lưu thay đổi',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatusBadge(int stock) {
    Color bg;
    Color fg;
    String label;
    if (stock <= 0) {
      bg = AppColors.error.withValues(alpha: 0.1);
      fg = AppColors.error;
      label = 'Hết hàng';
    } else if (stock <= 5) {
      bg = AppColors.warning.withValues(alpha: 0.1);
      fg = AppColors.warning;
      label = 'Sắp hết';
    } else {
      bg = AppColors.success.withValues(alpha: 0.1);
      fg = AppColors.success;
      label = 'Còn hàng';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildQuickPriceChip(String label, double delta) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _adjustPrice(delta),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStockChip(String label, int delta) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _adjustStock(delta),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSetStockChip(String label, int value) {
    final isSelected = _currentStock == value;
    return Material(
      color: isSelected ? AppColors.error.withValues(alpha: 0.1) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _setStock(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ),
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
