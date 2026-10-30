import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cookconnect/features/auth/data/services/auth_service.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';
import 'package:cookconnect/features/order/data/services/order_api_service.dart';
import 'package:cookconnect/features/order/data/services/saved_address_service.dart';
import 'package:cookconnect/core/storage/address_storage_service.dart';
import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/services/recipe_data_service.dart';
import '../widgets/order_success_dialog.dart';
import 'order_tracking_screen.dart';

class OrderCheckoutScreen extends StatefulWidget {
  final List<ShoppingItem> items;

  const OrderCheckoutScreen({
    super.key,
    required this.items,
  });

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _labelController = TextEditingController();

  List<SavedAddress> _savedAddresses = [];
  String? _selectedAddressId;
  bool _saveAddress = true;

  late Map<String, int> _itemQuantities;
  late Map<String, num> _itemPrices;
  String _selectedPaymentMethod = 'COD';
  bool _isSubmitting = false;

  // Default supplier ID from the active store in database
  static const String _defaultSupplierId =
      '5097672a-87b6-4871-8a48-df6159b97a60';

  @override
  void initState() {
    super.initState();
    _initUserData();
    _initItems();
  }

  void _initUserData() {
    final user = AuthService.instance.currentUser;
    _nameController.text = user?.fullName ?? '';
    _phoneController.text = '';
    _addressController.text = user?.location ?? '';
    _loadSavedAddresses(autoFill: true);
  }

  Future<void> _loadSavedAddresses({bool autoFill = false}) async {
    final list = await SavedAddressService.instance.getAll();
    if (!mounted) return;
    setState(() {
      _savedAddresses = list;
      if (autoFill && list.isNotEmpty) {
        _applyAddress(list.first);
      } else if (_selectedAddressId != null &&
          !list.any((a) => a.id == _selectedAddressId)) {
        _selectedAddressId = null;
      }
    });
  }

  void _applyAddress(SavedAddress a) {
    _selectedAddressId = a.id;
    _nameController.text = a.receiverName;
    _phoneController.text = a.phone;
    _addressController.text = a.address;
    _labelController.text = a.label;
  }

  Future<void> _openAddressPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> refresh() async {
            await _loadSavedAddresses();
            setSheet(() {});
          }

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Địa chỉ đã lưu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: _savedAddresses.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Chưa có địa chỉ nào được lưu'),
                          )
                        : ListView(
                            shrinkWrap: true,
                            children: [
                              for (final a in _savedAddresses)
                                ListTile(
                                  leading: Icon(
                                    a.id == _selectedAddressId
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                  ),
                                  title: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          a.label.isNotEmpty
                                              ? a.label
                                              : a.receiverName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (a.isDefault) ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Mặc định',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${a.receiverName} • ${a.phone}\n${a.address}',
                                  ),
                                  isThreeLine: true,
                                  onTap: () {
                                    setState(() => _applyAddress(a));
                                    Navigator.of(ctx).pop();
                                  },
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      if (v == 'default') {
                                        await SavedAddressService.instance
                                            .setDefault(a.id);
                                      } else {
                                        await SavedAddressService.instance
                                            .delete(a.id);
                                      }
                                      await refresh();
                                    },
                                    itemBuilder: (_) => [
                                      if (!a.isDefault)
                                        const PopupMenuItem(
                                          value: 'default',
                                          child: Text('Đặt làm mặc định'),
                                        ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Xóa'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Nhập địa chỉ mới (đặt hộ bạn bè...)'),
                    onTap: () {
                      setState(() {
                        _selectedAddressId = null;
                        _nameController.clear();
                        _phoneController.clear();
                        _addressController.clear();
                        _labelController.clear();
                        _saveAddress = true;
                      });
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _initItems() {
    _itemQuantities = {};
    _itemPrices = {};

    for (final item in widget.items) {
      _itemQuantities[item.id] = 1;
      // Default to 35.000 VND if price is not specified for a custom item
      _itemPrices[item.id] = item.price ?? 35000;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  num get _subtotal {
    num total = 0;
    for (final item in widget.items) {
      final qty = _itemQuantities[item.id] ?? 1;
      final price = _itemPrices[item.id] ?? 35000;
      total += qty * price;
    }
    return total;
  }

  num get _shippingFee {
    if (_subtotal >= 300000 || _subtotal == 0) {
      return 0;
    }
    return 20000;
  }

  num get _totalAmount => _subtotal + _shippingFee;

  String _formatCurrency(num value) {
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có sản phẩm nào để đặt hàng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Detect supplier ID from items or default store
    String supplierId = _defaultSupplierId;
    for (final item in widget.items) {
      if (item.supplierId != null && item.supplierId!.isNotEmpty) {
        supplierId = item.supplierId!;
        break;
      }
    }

    final orderItems = widget.items.map((item) {
      final qty = _itemQuantities[item.id] ?? 1;
      final price = _itemPrices[item.id] ?? 35000;
      final productId = (item.productId != null && item.productId!.isNotEmpty)
          ? item.productId!
          : 'custom_${item.id}';

      return CreateOrderItemDto(
        productId: productId,
        productName: item.name,
        quantity: qty,
        unitPrice: price,
        note: item.amount.isNotEmpty ? item.amount : null,
      );
    }).toList();

    final orderDto = CreateOrderDto(
      paymentMethod: _selectedPaymentMethod,
      shippingAddress: _addressController.text.trim(),
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      shippingFee: _shippingFee,
      supplierId: supplierId,
      items: orderItems,
    );

    final result = await OrderApiService.instance.createOrder(orderDto);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result.isSuccess && result.data != null) {
      final createdOrder = result.data!;

      // Mark the ordered items as completed in shopping list
      final orderedIds = widget.items.map((i) => i.id).toList();
      RecipeDataService.instance.markShoppingItemsCompleted(orderedIds);

      // Remember the shipping info for next time
      if (_saveAddress) {
        final name = _nameController.text.trim();
        await SavedAddressService.instance.upsert(
          id: _selectedAddressId,
          label: _labelController.text.trim().isNotEmpty
              ? _labelController.text.trim()
              : name,
          receiverName: name,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
      }

      final action = await _showSuccessDialog(createdOrder);
      if (mounted) {
        if (action == 'track') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(
                orderId: createdOrder.id,
                initialOrder: createdOrder,
              ),
            ),
          );
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Đặt hàng thất bại. Vui lòng thử lại sau!',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _showSuccessDialog(OrderDto order) {
    return OrderSuccessDialog.show<String>(context, order);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Xác nhận đặt hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildDeliveryAddressSection(theme),
              const SizedBox(height: 16),
              _buildProductListSection(theme),
              const SizedBox(height: 16),
              _buildPaymentMethodSection(theme),
              const SizedBox(height: 16),
              _buildOrderSummarySection(theme),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomCheckoutBar(theme),
    );
  }

  Widget _buildDeliveryAddressSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.location5, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ nhận hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openAddressPicker,
                icon: const Icon(Icons.bookmarks_outlined, size: 18),
                label: Text(
                  _savedAddresses.isEmpty
                      ? 'Đã lưu'
                      : 'Đã lưu (${_savedAddresses.length})',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên người nhận *',
              prefixIcon: const Icon(Iconsax.user, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên người nhận';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Số điện thoại *',
              prefixIcon: const Icon(Iconsax.call, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.trim().length < 9) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Địa chỉ nhận hàng chi tiết *',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Icon(Iconsax.building_3, size: 20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ nhận hàng';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Ghi chú cho shipper / nhà cung cấp',
              prefixIcon: const Icon(Iconsax.note_text, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Lưu địa chỉ này cho lần sau'),
              value: _saveAddress,
              onChanged: (v) => setState(() => _saveAddress = v),
            ),
          ),
          if (_saveAddress)
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Tên gợi nhớ (VD: Nhà, Công ty, Bạn Lan)',
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductListSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.shopping_cart5,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sản phẩm cần mua (${widget.items.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.items.length} món',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, _) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final qty = _itemQuantities[item.id] ?? 1;
              final price = _itemPrices[item.id] ?? 35000;
              final itemSubtotal = qty * price;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                        ? Icon(
                            Iconsax.bag_2,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                            size: 28,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.recipeSource.isNotEmpty
                              ? item.recipeSource
                              : item.amount,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatCurrency(price),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (qty > 1) ...[
                              const SizedBox(width: 6),
                              Text(
                                '= ${_formatCurrency(itemSubtotal)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Quantity Stepper
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (qty > 1) {
                            setState(() {
                              _itemQuantities[item.id] = qty - 1;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: qty > 1 ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$qty',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _itemQuantities[item.id] = qty + 1;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme) {
    final methods = [
      {
        'id': 'COD',
        'title': 'Thanh toán tiền mặt khi nhận hàng (COD)',
        'subtitle': 'Thanh toán trực tiếp cho nhân viên giao hàng',
        'icon': Iconsax.money_3,
      },
      {
        'id': 'MOMO',
        'title': 'Ví điện tử MoMo',
        'subtitle': 'Thanh toán nhanh qua ứng dụng MoMo',
        'icon': Iconsax.wallet_2,
      },
      {
        'id': 'VNPAY',
        'title': 'Cổng VNPAY-QR',
        'subtitle': 'Hỗ trợ tất cả ngân hàng nội địa',
        'icon': Iconsax.scan_barcode,
      },
      {
        'id': 'CREDIT_CARD',
        'title': 'Thẻ tín dụng / Ghi nợ quốc tế',
        'subtitle': 'Visa, Mastercard, JCB',
        'icon': Iconsax.card,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.card_pos, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...methods.map((m) {
            final isSelected = _selectedPaymentMethod == m['id'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = m['id'] as String;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.03)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiền hàng (${widget.items.length} món)',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Text(
                _formatCurrency(_subtotal),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              Text(
                _shippingFee == 0 ? 'Miễn phí' : _formatCurrency(_shippingFee),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _shippingFee == 0 ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          if (_subtotal < 300000 && _subtotal > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• Mua thêm ${_formatCurrency(300000 - _subtotal)} để được miễn phí giao hàng',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                _formatCurrency(_totalAmount),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tiền thanh toán',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _formatCurrency(_totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitOrder,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Đặt hàng ngay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
