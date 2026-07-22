class InventoryCategory {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;

  InventoryCategory({
    String? id,
    required this.name,
    this.icon = '📦',
    this.sortOrder = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  static const defaults = [
    {'name': '尿不湿', 'icon': '🩲'},
    {'name': '湿巾', 'icon': '🧻'},
    {'name': '护肤', 'icon': '🧴'},
    {'name': '洗护', 'icon': '🧼'},
    {'name': '喂养', 'icon': '🍼'},
    {'name': '衣物', 'icon': '👕'},
    {'name': '医疗', 'icon': '🩹'},
    {'name': '其他', 'icon': '📦'},
  ];
}
