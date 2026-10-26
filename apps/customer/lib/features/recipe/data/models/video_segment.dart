class VideoSegment {
  final String id;
  final String path;
  final Duration duration;
  final double speed;
  final String? filterName;
  final String? soundTrack;
  final String? label;
  final DateTime createdAt;

  VideoSegment({
    required this.id,
    required this.path,
    required this.duration,
    this.speed = 1.0,
    this.filterName,
    this.soundTrack,
    this.label,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedDuration {
    final seconds = duration.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)}s';
  }

  VideoSegment copyWith({
    String? id,
    String? path,
    Duration? duration,
    double? speed,
    String? filterName,
    String? soundTrack,
    String? label,
    DateTime? createdAt,
  }) {
    return VideoSegment(
      id: id ?? this.id,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      filterName: filterName ?? this.filterName,
      soundTrack: soundTrack ?? this.soundTrack,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
