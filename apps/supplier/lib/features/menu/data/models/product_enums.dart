/// Swagger-compliant product operational and moderation review statuses
/// based on Backend OpenAPI spec at `/api/v1/products` (listProducts).
library;

import 'product_category_type.dart';

/// Operational status for products (`status` parameter).
/// Swagger enum: ['DRAFT', 'ACTIVE', 'INACTIVE']
enum ProductStatus {
  draft('DRAFT'),
  active('ACTIVE'),
  inactive('INACTIVE');

  final String value;
  const ProductStatus(this.value);

  /// Safe parser with fallback
  static ProductStatus fromValue(
    String? val, {
    ProductStatus fallback = ProductStatus.active,
  }) {
    if (val == null || val.trim().isEmpty) return fallback;
    final normalized = val.trim().toUpperCase();
    for (final s in ProductStatus.values) {
      if (s.value == normalized) return s;
    }
    return fallback;
  }

  /// All supported status strings
  static List<String> get allValues =>
      ProductStatus.values.map((e) => e.value).toList();
}

/// Moderation review status for products (`moderationStatus` parameter).
/// Swagger enum: ['DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'EDIT_PENDING_APPROVAL', 'SUSPENDED']
enum ProductModerationStatus {
  draft('DRAFT'),
  pendingApproval('PENDING_APPROVAL'),
  approved('APPROVED'),
  rejected('REJECTED'),
  editPendingApproval('EDIT_PENDING_APPROVAL'),
  suspended('SUSPENDED');

  final String value;
  const ProductModerationStatus(this.value);

  /// Safe parser with fallback
  static ProductModerationStatus fromValue(
    String? val, {
    ProductModerationStatus fallback = ProductModerationStatus.approved,
  }) {
    if (val == null || val.trim().isEmpty) return fallback;
    final normalized = val.trim().toUpperCase();
    for (final s in ProductModerationStatus.values) {
      if (s.value == normalized) return s;
    }
    return fallback;
  }

  /// All supported moderation status strings
  static List<String> get allValues =>
      ProductModerationStatus.values.map((e) => e.value).toList();
}

/// Pair of (status, moderationStatus) that maps to a specific category/tab
class ProductStatusQueryPair {
  final String status;
  final String moderationStatus;
  final String label;

  const ProductStatusQueryPair({
    required this.status,
    required this.moderationStatus,
    required this.label,
  });

  /// Standard operational pairs for merchant catalog
  static const onShelf = ProductStatusQueryPair(
    status: 'ACTIVE',
    moderationStatus: 'APPROVED',
    label: 'Trên kệ / Còn ít',
  );

  static const disabled = ProductStatusQueryPair(
    status: 'INACTIVE',
    moderationStatus: 'APPROVED',
    label: 'Đã vô hiệu hóa',
  );

  static const pendingApproval = ProductStatusQueryPair(
    status: 'DRAFT',
    moderationStatus: 'PENDING_APPROVAL',
    label: 'Đang xét duyệt',
  );

  static const editPendingApproval = ProductStatusQueryPair(
    status: 'ACTIVE',
    moderationStatus: 'EDIT_PENDING_APPROVAL',
    label: 'Đang xét duyệt cập nhật',
  );

  static const rejected = ProductStatusQueryPair(
    status: 'DRAFT',
    moderationStatus: 'REJECTED',
    label: 'Không thành công (Nháp)',
  );

  static const rejectedActive = ProductStatusQueryPair(
    status: 'ACTIVE',
    moderationStatus: 'REJECTED',
    label: 'Không thành công (Active)',
  );

  static const suspended = ProductStatusQueryPair(
    status: 'ACTIVE',
    moderationStatus: 'SUSPENDED',
    label: 'Đóng băng',
  );

  static const draft = ProductStatusQueryPair(
    status: 'DRAFT',
    moderationStatus: 'DRAFT',
    label: 'Bản nháp',
  );

  /// All query pairs needed to fetch full supplier product inventory
  static const List<ProductStatusQueryPair> allSupplierPairs = [
    onShelf,
    disabled,
    pendingApproval,
    editPendingApproval,
    rejected,
    rejectedActive,
    suspended,
    draft,
  ];

  /// Returns the minimal query pairs needed for a specific ProductCategoryType tab.
  /// Minimizes requests to avoid 429 Too Many Requests when refreshing a single category.
  static List<ProductStatusQueryPair> pairsForCategory(ProductCategoryType cat) {
    switch (cat) {
      case ProductCategoryType.onShelf:
      case ProductCategoryType.lowStock:
        return const [onShelf];
      case ProductCategoryType.disabled:
        return const [disabled];
      case ProductCategoryType.underReview:
        return const [pendingApproval, editPendingApproval];
      case ProductCategoryType.failed:
        return const [rejected, rejectedActive];
      case ProductCategoryType.frozen:
        return const [suspended];
      case ProductCategoryType.draft:
        return const [draft];
    }
  }
}
