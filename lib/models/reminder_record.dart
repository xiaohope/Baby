class ReminderRecord {
  final String id;
  final String type;      // feeding / diaper / medicine / water / custom
  final String title;
  final DateTime remindTime;  // 每日提醒时间
  final bool repeat;         // 是否每天重复
  final bool isActive;
  final DateTime createdAt;

  ReminderRecord({
    String? id,
    required this.type,
    required this.title,
    required this.remindTime,
    this.repeat = true,
    this.isActive = true,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  String get typeName {
    switch (type) {
      case 'feeding': return '喂奶';
      case 'diaper': return '换尿布';
      case 'medicine': return '用药';
      case 'water': return '喝水';
      case 'custom': return '自定义';
      default: return type;
    }
  }

  ReminderRecord copyWith({
    String? id,
    String? type,
    String? title,
    DateTime? remindTime,
    bool? repeat,
    bool? isActive,
  }) {
    return ReminderRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      remindTime: remindTime ?? this.remindTime,
      repeat: repeat ?? this.repeat,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
