class ToothRecord {
  final String id;
  final int toothIndex;     // 1-20
  final DateTime foundDate;
  final String? note;
  final DateTime createdAt;

  ToothRecord({
    String? id,
    required this.toothIndex,
    required this.foundDate,
    this.note,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  static const toothNames = {
    1: '右上1', 2: '右上2', 3: '右上3', 4: '右上4', 5: '右上5',
    6: '左上1', 7: '左上2', 8: '左上3', 9: '左上4', 10: '左上5',
    11: '左下1', 12: '左下2', 13: '左下3', 14: '左下4', 15: '左下5',
    16: '右下1', 17: '右下2', 18: '右下3', 19: '右下4', 20: '右下5',
  };

  String get toothName => toothNames[toothIndex] ?? '未知';

  String get toothPosition {
    if (toothIndex <= 5) return '右上';
    if (toothIndex <= 10) return '左上';
    if (toothIndex <= 15) return '左下';
    return '右下';
  }

  String get toothType {
    if ([1,6,11,16].contains(toothIndex)) return '门牙1';
    if ([2,7,12,17].contains(toothIndex)) return '门牙2';
    if ([3,8,13,18].contains(toothIndex)) return '尖牙';
    if ([4,9,14,19].contains(toothIndex)) return '第一磨牙';
    return '第二磨牙';
  }
}
