class InventoryItem {
  final String id;
  final String categoryId;
  final String name;
  final int total;
  final int remaining;
  final String unit;
  final int threshold;
  final String? note;

  InventoryItem({
    String? id,
    required this.categoryId,
    required this.name,
    this.total = 0,
    this.remaining = 0,
    this.unit = '个',
    this.threshold = 1,
    this.note,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isLow => remaining <= threshold;
}
