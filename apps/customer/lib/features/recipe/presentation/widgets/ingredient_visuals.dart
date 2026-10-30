/// Bộ trợ giúp hiển thị nguyên liệu (emoji minh hoạ, định dạng định lượng...)
/// dùng chung giữa Feed và trang Đi chợ.
class IngredientVisuals {
  IngredientVisuals._();

  // Thứ tự quan trọng: từ khoá cụ thể hơn đặt trước.
  static const List<MapEntry<String, String>> _emojiKeywords = [
    MapEntry('bánh mì', '🥖'),
    MapEntry('xúc xích', '🌭'),
    MapEntry('phô mai', '🧀'),
    MapEntry('cà chua', '🍅'),
    MapEntry('cà rốt', '🥕'),
    MapEntry('nước mắm', '🫙'),
    MapEntry('dầu', '🫒'),
    MapEntry('trứng', '🥚'),
    MapEntry('bò', '🥩'),
    MapEntry('heo', '🥓'),
    MapEntry('lợn', '🥓'),
    MapEntry('sườn', '🍖'),
    MapEntry('ba chỉ', '🥓'),
    MapEntry('thịt', '🥩'),
    MapEntry('gà', '🍗'),
    MapEntry('vịt', '🍗'),
    MapEntry('tôm', '🦐'),
    MapEntry('cua', '🦀'),
    MapEntry('mực', '🦑'),
    MapEntry('cá', '🐟'),
    MapEntry('pate', '🥫'),
    MapEntry('bơ', '🧈'),
    MapEntry('sữa', '🥛'),
    MapEntry('hành', '🧅'),
    MapEntry('tỏi', '🧄'),
    MapEntry('ớt', '🌶️'),
    MapEntry('gừng', '🫚'),
    MapEntry('sả', '🌿'),
    MapEntry('rau', '🥬'),
    MapEntry('cải', '🥬'),
    MapEntry('húng', '🌿'),
    MapEntry('ngò', '🌿'),
    MapEntry('nấm', '🍄'),
    MapEntry('khoai', '🥔'),
    MapEntry('bắp', '🌽'),
    MapEntry('ngô', '🌽'),
    MapEntry('chanh', '🍋'),
    MapEntry('dưa', '🥒'),
    MapEntry('gạo', '🍚'),
    MapEntry('cơm', '🍚'),
    MapEntry('bún', '🍜'),
    MapEntry('mì', '🍜'),
    MapEntry('phở', '🍜'),
    MapEntry('bột', '🌾'),
    MapEntry('muối', '🧂'),
    MapEntry('tiêu', '🧂'),
    MapEntry('đường', '🍬'),
    MapEntry('mật ong', '🍯'),
    MapEntry('nước', '💧'),
  ];

  static String emojiFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _emojiKeywords) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '🥄';
  }

  /// Định dạng định lượng theo hệ số khẩu phần (x1, x2...).
  static String scaledAmount(num? amount, String? unit, int multiplier) {
    if (amount == null) return '';
    final value = amount * multiplier;
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    if (unit != null && unit.trim().isNotEmpty)
      return '$formatted ${unit.trim()}';
    return formatted;
  }
}
