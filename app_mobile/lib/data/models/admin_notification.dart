class AdminNotification {
  final int id;
  final String title;
  final String message;
  final String category;
  final String level;
  final bool isRead;
  final DateTime createdAt;
  final String? source;
  final String? relatedRoute;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.level,
    required this.isRead,
    required this.createdAt,
    this.source,
    this.relatedRoute,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      category: (json['category'] ?? 'system').toString(),
      level: (json['level'] ?? 'info').toString(),
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(
            (json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      source: json['source']?.toString(),
      relatedRoute: json['related_route']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'level': level,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'source': source,
      'related_route': relatedRoute,
    };
  }

  AdminNotification copyWith({
    int? id,
    String? title,
    String? message,
    String? category,
    String? level,
    bool? isRead,
    DateTime? createdAt,
    String? source,
    String? relatedRoute,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      level: level ?? this.level,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      relatedRoute: relatedRoute ?? this.relatedRoute,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
