class ShoppingItem {
  final String id;
  final String? itemId;      // 关联库存物品ID(可选)
  final String itemName;
  final int quantity;
  final bool isDone;
  final String? note;

  ShoppingItem({
    String? id,
    this.itemId,
    required this.itemName,
    this.quantity = 1,
    this.isDone = false,
    this.note,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}
