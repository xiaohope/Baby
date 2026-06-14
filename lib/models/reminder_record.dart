class ReminderRecord {
  final String id;
  final String type;
  final String title;
  final DateTime remindTime;
  final bool isActive;
  final bool repeatDaily;
  final List<int>? repeatDays; // null=daily, [1..7]=Mon..Sun
  final DateTime createdAt;

  ReminderRecord({
    String? id,
    required this.type,
    required this.title,
    required this.remindTime,
    this.repeatDaily = true,
    this.repeatDays,
    this.isActive = true,
    DateTime? createdAt,
  }) : id = id ?? (DateTime.now().millisecondsSinceEpoch % 100000).toString(),
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

  String get repeatLabel {
    if (repeatDaily) return '每天';
    if (repeatDays != null && repeatDays!.isNotEmpty) {
      const names = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return repeatDays!.map((d) => names[d]).join(' ');
    }
    return '一次';
  }

  ReminderRecord copyWith({
    String? id,
    String? type,
    String? title,
    DateTime? remindTime,
    bool? repeatDaily,
    List<int>? repeatDays,
    bool? isActive,
  }) {
    return ReminderRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      remindTime: remindTime ?? this.remindTime,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      repeatDays: repeatDays ?? this.repeatDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
