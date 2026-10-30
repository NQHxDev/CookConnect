import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/market/data/product_detail_model.dart';
import 'package:cookconnect/features/recipe/data/models/product_search_model.dart';
import 'package:cookconnect/features/recipe/data/services/product_search_service.dart';

/// Bottom sheet showing full product details and seller info.
class ProductDetailBottomSheet extends StatefulWidget {
  final ProductSearchItemDto product;
  final ProductSearchService service;
  final VoidCallback? onAdd;

  const ProductDetailBottomSheet({
    super.key,
    required this.product,
    required this.service,
    this.onAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductSearchItemDto product,
    required ProductSearchService service,
    VoidCallback? onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailBottomSheet(
        product: product,
        service: service,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  ProductDetailDto? _detail;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final d = await widget.service.getProductDetail(widget.product.productId);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String _price(num v) {
    final f = v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$f đ';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final p = widget.product;
    final d = _detail;
    final images = (d?.images.isNotEmpty ?? false) ? d!.images : p.images;
    final description = d?.description ?? p.description;
    final origin = d?.origin ?? p.origin;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              images[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Iconsax.image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    p.productName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.minPrice != null && p.minPrice! > 0
                        ? (p.maxPrice != null && p.maxPrice != p.minPrice
                              ? '${_price(p.minPrice!)} - ${_price(p.maxPrice!)}'
                              : _price(p.minPrice!))
                        : 'Liên hệ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  if (d != null &&
                      ((d.soldCount ?? 0) > 0 || (d.orderCount ?? 0) > 0))
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Đã bán ${d.soldCount ?? 0} • ${d.orderCount ?? 0} đơn hàng',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (p.variants.isNotEmpty) ...[
                    _sectionTitle('Phân loại'),
                    ...p.variants.map((v) => _variantTile(v, primary)),
                    const SizedBox(height: 12),
                  ],
                  _sectionTitle('Thông tin sản phẩm'),
                  if (origin != null && origin.isNotEmpty)
                    _infoRow(Iconsax.location, 'Xuất xứ', origin),
                  if (d?.storageCondition?.isNotEmpty ?? false)
                    _infoRow(Iconsax.box, 'Bảo quản', d!.storageCondition!),
                  if (d?.shelfLifeDays != null)
                    _infoRow(
                      Iconsax.calendar,
                      'Hạn sử dụng',
                      '${d!.shelfLifeDays} ngày',
                    ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _sectionTitle('Người bán'),
                  _supplierSection(primary),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: widget.onAdd == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onAdd!();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Iconsax.add, size: 18),
                    label: const Text('Thêm vào danh sách mua sắm'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Widget _variantTile(ProductVariantDto v, Color primary) {
    final name = (v.variantName?.isNotEmpty ?? false)
        ? v.variantName!
        : [v.packSize, v.unit].where((e) => e?.isNotEmpty ?? false).join(' ');
    final out = v.status == 'OUT_OF_STOCK' || v.status == 'DISCONTINUED';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (out)
                  const Text(
                    'Hết hàng',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(
            v.price != null ? _price(v.price!) : 'Liên hệ',
            style: TextStyle(fontWeight: FontWeight.bold, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _supplierSection(Color primary) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final s = _detail?.supplier;
    if (_error || s == null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _error
                  ? 'Không tải được thông tin người bán.'
                  : 'Chưa có thông tin người bán.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          if (_error)
            TextButton(onPressed: _load, child: const Text('Thử lại')),
        ],
      );
    }
    final address = [s.address, s.city].where((e) => e?.isNotEmpty ?? false);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primary.withValues(alpha: 0.1),
            backgroundImage: (s.supplierLogoUrl?.isNotEmpty ?? false)
                ? NetworkImage(s.supplierLogoUrl!)
                : null,
            child: (s.supplierLogoUrl?.isNotEmpty ?? false)
                ? null
                : Icon(Iconsax.shop, color: primary),
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
                        s.supplierName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (s.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 16, color: Colors.blue),
                    ],
                  ],
                ),
                if (s.rating != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(s.rating!.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                if (address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      address.join(', '),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
