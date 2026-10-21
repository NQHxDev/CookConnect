class DashboardStats {
  final double totalRevenue;
  final int todayOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalDishes;

  DashboardStats({
    this.totalRevenue = 0.0,
    this.todayOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.totalDishes = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayOrders: json['todayOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      completedOrders: json['completedOrders'] as int? ?? 0,
      totalDishes: json['totalDishes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRevenue': totalRevenue,
    'todayOrders': todayOrders,
    'pendingOrders': pendingOrders,
    'completedOrders': completedOrders,
    'totalDishes': totalDishes,
  };
}
