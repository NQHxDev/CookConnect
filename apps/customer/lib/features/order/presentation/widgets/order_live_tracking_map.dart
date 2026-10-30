import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:cookconnect/core/config/api_config.dart';
import 'package:cookconnect/features/order/data/models/order_model.dart';

class OrderLiveTrackingMap extends StatefulWidget {
  final OrderDto order;
  final double height;
  final bool isInteractive;
  final VoidCallback? onExpand;
  final String? cartoApiKey;

  const OrderLiveTrackingMap({
    super.key,
    required this.order,
    this.height = 240,
    this.isInteractive = true,
    this.onExpand,
    this.cartoApiKey,
  });

  @override
  State<OrderLiveTrackingMap> createState() => _OrderLiveTrackingMapState();
}

class _OrderLiveTrackingMapState extends State<OrderLiveTrackingMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;

  // Tọa độ các điểm: Quán ăn, Khách hàng, Tài xế
  late LatLng _restaurantLocation;
  late LatLng _customerLocation;
  late LatLng _shipperLocation;
  late List<LatLng> _routePoints;

  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _resolveCoordinates();
  }

  @override
  void didUpdateWidget(covariant OrderLiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.orderStatus != widget.order.orderStatus) {
      _resolveCoordinates();
      if (_isMapReady) {
        _fitBounds();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Khởi tạo và đồng bộ toạ độ
  void _resolveCoordinates() {
    // Tọa độ mặc định tại trung tâm TP.HCM (Quận 1 / Quận 3) nếu backend chưa cung cấp lat/lng
    // Các điểm được tính toán khoảng cách thực tế 2-3km giống đời thực giao đồ ăn
    const defaultCenterLat = 10.7769;
    const defaultCenterLng = 106.7009;

    // Giả lập toạ độ dựa trên hash của orderId để mỗi đơn hàng có vị trí cố định nhất quán
    final seed = widget.order.id.hashCode.abs();
    final latOffset = ((seed % 40) - 20) / 1000.0; // Khoảng ~1-2km
    final lngOffset = (((seed ~/ 40) % 40) - 20) / 1000.0;

    _customerLocation = LatLng(
      defaultCenterLat + latOffset,
      defaultCenterLng + lngOffset,
    );

    _restaurantLocation = LatLng(
      defaultCenterLat - latOffset * 0.8 + 0.012,
      defaultCenterLng - lngOffset * 0.8 - 0.008,
    );

    // Vị trí shipper phụ thuộc vào trạng thái đơn hàng
    final status = widget.order.orderStatus.toUpperCase();
    if (status == 'DELIVERED' || status == 'COMPLETED') {
      _shipperLocation = _customerLocation;
    } else if (status == 'PENDING' || status == 'CONFIRMED' || status == 'PROCESSING') {
      // Đang chuẩn bị món: Shipper ở gần hoặc ngay tại nhà hàng
      _shipperLocation = LatLng(
        _restaurantLocation.latitude + 0.0008,
        _restaurantLocation.longitude + 0.0006,
      );
    } else {
      // Đang giao (SHIPPING / OUT_FOR_DELIVERY): Shipper đang ở đoạn 60% từ quán đến nhà khách
      _shipperLocation = LatLng(
        _restaurantLocation.latitude +
            (_customerLocation.latitude - _restaurantLocation.latitude) * 0.65,
        _restaurantLocation.longitude +
            (_customerLocation.longitude - _restaurantLocation.longitude) * 0.65,
      );
    }

    _generateRoutePoints();
  }

  /// Tạo tuyến đường uốn lượn tự nhiên mô phỏng các ngã rẽ đường phố
  void _generateRoutePoints() {
    final start = _restaurantLocation;
    final end = _customerLocation;

    // Điểm rẽ góc phố trung gian
    final mid1 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.35,
      start.longitude + (end.longitude - start.longitude) * 0.15,
    );
    final mid2 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.7,
      start.longitude + (end.longitude - start.longitude) * 0.85,
    );

    _routePoints = [start, mid1, _shipperLocation, mid2, end];
  }

  /// Fit Camera thông minh: Gần thì zoom sâu, xa thì tự động mở rộng
  /// Luôn chặn minZoom để không bị zoom bao trùm cả nước, và maxZoom không dí sát nóc nhà
  void _fitBounds() {
    if (!_isMapReady) return;

    final points = [_restaurantLocation, _customerLocation, _shipperLocation];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    // Đệm biên độ tối thiểu để tránh zoom quá sát nếu 2 điểm gần nhau
    final latDelta = (maxLat - minLat).abs();
    final lngDelta = (maxLng - minLng).abs();
    const minSpan = 0.006; // Khoảng ~600m

    if (latDelta < minSpan) {
      final pad = (minSpan - latDelta) / 2;
      minLat -= pad;
      maxLat += pad;
    }
    if (lngDelta < minSpan) {
      final pad = (minSpan - lngDelta) / 2;
      minLng -= pad;
      maxLng += pad;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
        maxZoom: 16.5, // Khi gần: zoom vừa phải, không thấy nóc nhà
        minZoom: 12.0, // Khi xa: không bao giờ zoom lùi quá phạm vi thành phố
      ),
    );
  }

  /// Chọn Tile URL: Dùng Carto Voyager nếu có API key, mặc định dùng OpenStreetMap miễn phí 100%
  String get _tileUrlTemplate {
    final key = (widget.cartoApiKey != null && widget.cartoApiKey!.isNotEmpty)
        ? widget.cartoApiKey!
        : ApiConfig.cartoApiKey;

    if (key.isNotEmpty) {
      return 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png?key=$key';
    }

    // Nguồn bản đồ OpenStreetMap miễn phí 100%, không bao giờ đòi hỏi API Key
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(
              'Lộ trình #${widget.order.orderNumber}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            elevation: 0.5,
            scrolledUnderElevation: 0.5,
          ),
          body: OrderLiveTrackingMap(
            order: widget.order,
            height: double.infinity,
            isInteractive: true,
            cartoApiKey: widget.cartoApiKey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isShipping = widget.order.isShipping ||
        widget.order.orderStatus.toUpperCase() == 'SHIPPING' ||
        widget.order.orderStatus.toUpperCase() == 'OUT_FOR_DELIVERY';

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Bản đồ nền FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shipperLocation,
              initialZoom: 14.8,
              minZoom: 11.5,
              maxZoom: 17.5,
              interactionOptions: InteractionOptions(
                flags: widget.isInteractive
                    ? InteractiveFlag.all
                    : InteractiveFlag.none,
              ),
              onMapReady: () {
                _isMapReady = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitBounds();
                });
              },
            ),
            children: [
              // Tile Layer: Tự động dùng OpenStreetMap hoặc Carto Voyager nếu có key
              TileLayer(
                urlTemplate: _tileUrlTemplate,
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.cookconnect.app',
                maxZoom: 19,
              ),

              // Polyline viền đổ bóng (tạo chiều sâu 3D cho đường đi)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6.0,
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: primaryColor,
                  ),
                ],
              ),

              // Các Marker: Quán ăn, Tài xế, Nhà khách hàng
              MarkerLayer(
                markers: [
                  // 1. Quán ăn
                  Marker(
                    point: _restaurantLocation,
                    width: 80,
                    height: 72,
                    alignment: Alignment.topCenter,
                    child: _buildLocationPin(
                      label: 'Quán ăn',
                      icon: Iconsax.shop,
                      color: const Color(0xFFF97316),
                    ),
                  ),

                  // 2. Điểm nhận hàng của khách
                  Marker(
                    point: _customerLocation,
                    width: 80,
                    height: 72,
                    alignment: Alignment.topCenter,
                    child: _buildLocationPin(
                      label: 'Nơi nhận',
                      icon: Iconsax.location5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                  // 3. Tài xế Shipper (có hiệu ứng sóng Pulsing nếu đang giao)
                  Marker(
                    point: _shipperLocation,
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    child: _buildShipperMarker(primaryColor, isShipping),
                  ),
                ],
              ),
            ],
          ),

          // Nút bấm Reset Camera góc trên bên phải
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapActionButton(
                  icon: Iconsax.gps,
                  tooltip: 'Căn giữa lộ trình',
                  onTap: _fitBounds,
                ),
                if (widget.height != double.infinity) ...[
                  const SizedBox(width: 8),
                  _buildMapActionButton(
                    icon: Iconsax.maximize_4,
                    tooltip: 'Xem toàn màn hình',
                    onTap: widget.onExpand ?? () => _openFullScreenMap(context),
                  ),
                ],
              ],
            ),
          ),

          // Banner ước tính thời gian (ETA) nổi ở góc dưới
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildEtaBanner(isShipping, primaryColor),
          ),
        ],
      ),
    );
  }

  /// Marker dạng ghim có nhãn bên dưới
  Widget _buildLocationPin({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ],
    );
  }

  /// Marker tài xế với hiệu ứng vòng tròn tỏa sóng (Radar Pulse)
  Widget _buildShipperMarker(Color primaryColor, bool isShipping) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final progress = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (isShipping)
              Container(
                width: 32 + (progress * 26),
                height: 32 + (progress * 26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: (1.0 - progress) * 0.4),
                ),
              ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.truck_fast,
                size: 18,
                color: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Nút tiện ích trên bản đồ
  Widget _buildMapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: const Color(0xFF1E293B)),
          ),
        ),
      ),
    );
  }

  /// Floating ETA card kính mờ bên dưới bản đồ
  Widget _buildEtaBanner(bool isShipping, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isShipping
                  ? primaryColor.withValues(alpha: 0.12)
                  : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isShipping ? Iconsax.routing : Iconsax.clock,
              size: 16,
              color: isShipping ? primaryColor : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isShipping
                      ? 'Tài xế đang giao hàng đến bạn'
                      : 'Quán đang hoàn tất đóng gói món',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isShipping
                      ? 'Dự kiến: 10 - 15 phút • Khoảng cách ~2.4 km'
                      : 'Shipper sẽ nhận hàng ngay khi quán chuẩn bị xong',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
