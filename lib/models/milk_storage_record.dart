class MilkStorageRecord {
  final String id;
  final String type;      // 'breast' 母乳 / 'formula' 奶粉
  final DateTime dateTime;
  final int? amountMl;    // 母乳毫升
  final String? brand;    // 奶粉品牌
  final int? amountG;     // 奶粉克数
  final String? note;
  final DateTime createdAt;

  MilkStorageRecord({
    String? id,
    required this.type,
    required this.dateTime,
    this.amountMl,
    this.brand,
    this.amountG,
    this.note,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  String get typeName => type == 'breast' ? '母乳' : '奶粉';

  String get displayAmount {
    if (type == 'breast' && amountMl != null) return '${amountMl}ml';
    if (type == 'formula') {
      final parts = <String>[];
      if (brand != null && brand!.isNotEmpty) parts.add(brand!);
      if (amountG != null) parts.add('${amountG}g');
      return parts.isNotEmpty ? parts.join(' ') : '未知';
    }
    return '未知';
  }
}
