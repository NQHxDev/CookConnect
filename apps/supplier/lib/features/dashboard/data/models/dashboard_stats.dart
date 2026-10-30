/// Model representing the operational statistics and performance metrics
/// displayed on the CookConnect Supplier Dashboard.
///
/// Data is aggregated from real backend endpoints:
/// - GET /api/v1/supplier/orders (Lifecycle statuses, date filters, badges summary)
/// - GET /api/v1/suppliers/me (Store rating, verification status, active details)
class DashboardStats {
  // Legacy fields preserved for compatibility
  final double totalRevenue;
  final int todayOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalDishes;

  // Real Operational To-Do List (Việc cần xử lý)
  final int pendingConfirmationCount; // Chờ xác nhận (PENDING, AWAITING_PAYMENT)
  final int packagingCount;           // Chờ đóng gói (CONFIRMED, PROCESSING)
  final int shippingCount;            // Đang giao (SHIPPING, DELIVERED)
  final int returnsCount;             // Khiếu nại / Trả / Hủy (CANCELLED, REFUNDED)

  // Real Operational Performance Metrics (Hiệu suất hôm nay)
  final int todayCompletedOrders;     // Đơn hoàn thành hôm nay
  final int yesterdayCompletedOrders; // Đơn hoàn thành hôm qua
  final int? avgPrepMinutes;          // Thời gian chuẩn bị trung bình (phút)
  final double storeRating;           // Đánh giá gian hàng (1.0 - 5.0)
  final int chatResponseRate;         // Tỉ lệ phản hồi chat (%)
  final bool isLoading;               // Trạng thái đang tải dữ liệu

  const DashboardStats({
    this.totalRevenue = 0.0,
    this.todayOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.totalDishes = 0,
    this.pendingConfirmationCount = 0,
    this.packagingCount = 0,
    this.shippingCount = 0,
    this.returnsCount = 0,
    this.todayCompletedOrders = 0,
    this.yesterdayCompletedOrders = 0,
    this.avgPrepMinutes,
    this.storeRating = 5.0,
    this.chatResponseRate = 98,
    this.isLoading = false,
  });

  /// Factory constructor to parse from Map / JSON
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayOrders: (json['todayOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      totalDishes: (json['totalDishes'] as num?)?.toInt() ?? 0,
      pendingConfirmationCount:
          (json['pendingConfirmationCount'] as num?)?.toInt() ??
              (json['pendingOrders'] as num?)?.toInt() ??
              0,
      packagingCount: (json['packagingCount'] as num?)?.toInt() ?? 0,
      shippingCount: (json['shippingCount'] as num?)?.toInt() ?? 0,
      returnsCount: (json['returnsCount'] as num?)?.toInt() ?? 0,
      todayCompletedOrders:
          (json['todayCompletedOrders'] as num?)?.toInt() ??
              (json['completedOrders'] as num?)?.toInt() ??
              0,
      yesterdayCompletedOrders:
          (json['yesterdayCompletedOrders'] as num?)?.toInt() ?? 0,
      avgPrepMinutes: (json['avgPrepMinutes'] as num?)?.toInt(),
      storeRating: (json['storeRating'] as num?)?.toDouble() ?? 5.0,
      chatResponseRate: (json['chatResponseRate'] as num?)?.toInt() ?? 98,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalRevenue': totalRevenue,
        'todayOrders': todayOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'totalDishes': totalDishes,
        'pendingConfirmationCount': pendingConfirmationCount,
        'packagingCount': packagingCount,
        'shippingCount': shippingCount,
        'returnsCount': returnsCount,
        'todayCompletedOrders': todayCompletedOrders,
        'yesterdayCompletedOrders': yesterdayCompletedOrders,
        'avgPrepMinutes': avgPrepMinutes,
        'storeRating': storeRating,
        'chatResponseRate': chatResponseRate,
        'isLoading': isLoading,
      };

  DashboardStats copyWith({
    double? totalRevenue,
    int? todayOrders,
    int? pendingOrders,
    int? completedOrders,
    int? totalDishes,
    int? pendingConfirmationCount,
    int? packagingCount,
    int? shippingCount,
    int? returnsCount,
    int? todayCompletedOrders,
    int? yesterdayCompletedOrders,
    int? avgPrepMinutes,
    double? storeRating,
    int? chatResponseRate,
    bool? isLoading,
  }) {
    return DashboardStats(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      totalDishes: totalDishes ?? this.totalDishes,
      pendingConfirmationCount:
          pendingConfirmationCount ?? this.pendingConfirmationCount,
      packagingCount: packagingCount ?? this.packagingCount,
      shippingCount: shippingCount ?? this.shippingCount,
      returnsCount: returnsCount ?? this.returnsCount,
      todayCompletedOrders:
          todayCompletedOrders ?? this.todayCompletedOrders,
      yesterdayCompletedOrders:
          yesterdayCompletedOrders ?? this.yesterdayCompletedOrders,
      avgPrepMinutes: avgPrepMinutes ?? this.avgPrepMinutes,
      storeRating: storeRating ?? this.storeRating,
      chatResponseRate: chatResponseRate ?? this.chatResponseRate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Comparison string for today completed orders vs yesterday
  String get completedComparisonText {
    if (todayCompletedOrders == 0 && yesterdayCompletedOrders == 0) {
      return 'Chưa có đơn hôm nay';
    }
    final diff = todayCompletedOrders - yesterdayCompletedOrders;
    if (diff > 0) {
      return '+$diff đơn so với hôm qua';
    } else if (diff < 0) {
      return '$diff đơn so với hôm qua';
    } else {
      return 'Bằng hôm qua ($todayCompletedOrders đơn)';
    }
  }

  /// Formatted preparation time string
  String get prepTimeString {
    if (avgPrepMinutes != null && avgPrepMinutes! > 0) {
      return '$avgPrepMinutes phút';
    }
    return '~15 phút';
  }

  /// Subtitle explaining prep time performance vs standard benchmark
  String get prepTimeSubtext {
    if (avgPrepMinutes != null && avgPrepMinutes! > 0) {
      if (avgPrepMinutes! <= 20) {
        final diff = 20 - avgPrepMinutes!;
        return diff > 0 ? 'Nhanh hơn chuẩn ${diff}p' : 'Đúng chuẩn 20 phút';
      }
      return 'Tiêu chuẩn vận hành';
    }
    return 'Thời gian chuẩn bị dự kiến';
  }

  /// Formatted rating string with star symbol
  String get ratingString {
    return '${storeRating.toStringAsFixed(1)} ★';
  }

  /// Dynamic operational status badge
  String get operationalStatusBadge {
    if (storeRating >= 4.5 && returnsCount == 0) {
      return 'Vận hành xuất sắc';
    } else if (storeRating >= 4.0) {
      return 'Vận hành tốt';
    } else {
      return 'Đang chuẩn hóa';
    }
  }

  /// Total count of orders requiring seller action
  int get totalActionNeeded => pendingConfirmationCount + packagingCount;
}
