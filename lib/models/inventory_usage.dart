class InventoryUsage {
  final String id;
  final String itemId;
  final int usedCount;
  final DateTime usedAt;
  final String? note;

  InventoryUsage({
    String? id,
    required this.itemId,
    required this.usedCount,
    required this.usedAt,
    this.note,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
