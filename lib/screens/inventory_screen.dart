import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_category.dart';
import '../models/inventory_item.dart';
import '../models/inventory_usage.dart';
import '../models/shopping_item.dart';
import '../services/data_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('仓库'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '📋 库存'),
            Tab(text: '🛒 待购买'),
            Tab(text: '📊 统计'),
          ],
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6C63FF),
          dividerColor: Colors.transparent,
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : null,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInventoryTab(ds, isDark),
            _buildShoppingTab(ds, isDark),
            _buildStatsTab(ds, isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 1) {
            _addShoppingItemDialog(context.read<DataService>());
          } else {
            _addItemDialog(context.read<DataService>());
          }
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== 库存 Tab ======
  Widget _buildInventoryTab(DataService ds, bool isDark) {
    final categories = ds.inventoryCategories;
    final items = _selectedCategoryId == null
        ? ds.inventoryItems
        : ds.inventoryItems.where((i) => i.categoryId == _selectedCategoryId).toList();

    return Column(
      children: [
        // 分类横向滚动（添加按钮固定右侧）
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  children: [
                    ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('${c.icon} ${c.name}', style: const TextStyle(fontSize: 13)),
                        selected: _selectedCategoryId == c.id,
                        onSelected: (v) => setState(() => _selectedCategoryId = v ? c.id : null),
                        selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      ),
                    )),
                    // 删除分类按钮(已选时显示)
                    if (_selectedCategoryId != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ActionChip(
                          avatar: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          label: Text('删除', style: TextStyle(fontSize: 12, color: Colors.red)),
                          onPressed: () => _deleteCategoryConfirm(_selectedCategoryId!, ds),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 添加分类按钮（固定右侧）
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('分类', style: TextStyle(fontSize: 12)),
                onPressed: () => _addCategoryDialog(ds),
              ),
            ),
          ],
        ),
        const Divider(height: 1),
        // 物品列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: items.isEmpty
                ? ListView(children: [Center(child: Padding(padding: EdgeInsets.only(top:80), child: Text('暂无物品，点击右下角添加', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400))))])
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      final cat = categories.cast<InventoryCategory?>().firstWhere(
                        (c) => c?.id == item.categoryId, orElse: () => null);
                      return _buildItemCard(item, cat, ds, isDark);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(InventoryItem item, InventoryCategory? cat, DataService ds, bool isDark) {
    final ratio = item.total > 0 ? item.remaining / item.total : 0.0;
    final isLow = item.isLow;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF1E1E1E) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('${cat?.icon ?? '📦'} ', style: const TextStyle(fontSize: 16)),
              Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : null))),
              if (isLow) const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
            ]),
            const SizedBox(height: 6),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: isLow ? Colors.red.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(isLow ? Colors.red : const Color(0xFF6C63FF)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Row(children: [
              Text('剩余 ${item.remaining} / ${item.total} ${item.unit}', style: TextStyle(fontSize: 12, color: isLow ? Colors.red : (isDark ? Colors.white70 : Colors.grey))),
              if (isLow) Text('  低于阈值${item.threshold}${item.unit}', style: const TextStyle(fontSize: 11, color: Colors.red)),
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionBtn(Icons.remove_circle_outline, '使用', () => _useItemDialog(item, ds)),
                const SizedBox(width: 4),
                _actionBtn(Icons.add_circle_outline, '补货', () => _restockItemDialog(item, ds)),
                const SizedBox(width: 4),
                _actionBtn(Icons.edit_outlined, '编辑', () => _editItemDialog(item, cat, ds)),
                const SizedBox(width: 4),
                _actionBtn(Icons.delete_outline, '删除', () => _deleteItemConfirm(item, ds), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, [Color? color]) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color ?? const Color(0xFF6C63FF)),
      label: Text(label, style: TextStyle(fontSize: 11, color: color ?? const Color(0xFF6C63FF))),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }

  // ====== 待购买 Tab ======
  Widget _buildShoppingTab(DataService ds, bool isDark) {
    final autoItems = <ShoppingItem>[];
    // 低于阈值的自动加入显示列表
    for (final item in ds.inventoryItems) {
      if (item.isLow && !ds.shoppingItems.any((s) => s.itemId == item.id && !s.isDone)) {
        autoItems.add(ShoppingItem(itemId: item.id, itemName: '${item.name} (剩余${item.remaining}/${item.threshold}${item.unit})'));
      }
    }
    final shoppingItems = ds.shoppingItems.where((s) => !s.isDone).toList();
    final doneItems = ds.shoppingItems.where((s) => s.isDone).toList();
    final allItems = [...autoItems, ...shoppingItems, ...doneItems];

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: allItems.isEmpty
                ? ListView(children: [Center(child: Padding(padding: EdgeInsets.only(top:80), child: Text('暂无待购物品', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400))))])
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: allItems.length,
                    itemBuilder: (ctx, i) {
                    final item = allItems[i];
                    final isAuto = item.itemId != null && autoItems.contains(item);
                    final isDone = item.isDone;
                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : null,
                      child: ListTile(
                        leading: Icon(isAuto ? Icons.warning_amber : (isDone ? Icons.check_circle : Icons.shopping_cart), color: isDone ? Colors.green : const Color(0xFF6C63FF)),
                        title: Text(item.itemName, style: TextStyle(color: isDone ? Colors.grey : (isDark ? Colors.white : null), decoration: isDone ? TextDecoration.lineThrough : null)),
                        subtitle: isAuto ? const Text('库存不足，自动加入', style: TextStyle(fontSize: 11, color: Colors.red)) : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isAuto) IconButton(
                              icon: Icon(isDone ? Icons.undo : Icons.check_circle_outline, color: isDone ? Colors.orange : Colors.green, size: 20),
                              onPressed: () => ds.toggleShoppingItem(item.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              onPressed: () => _deleteShoppingItemConfirm(item, ds),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _deleteShoppingItemConfirm(ShoppingItem item, DataService ds) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('确认删除'),
      content: Text('确定要删除「${item.itemName}」吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteShoppingItem(item.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
      ],
    ));
  }

  // ====== 统计 Tab ======
  Widget _buildStatsTab(DataService ds, bool isDark) {
    final categories = ds.inventoryCategories;
    if (categories.isEmpty) {
      return Center(child: Text('暂无数据', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400)));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: categories.map((cat) {
        final catItems = ds.inventoryItems.where((i) => i.categoryId == cat.id).toList();
        final totalItems = catItems.length;
        final lowItems = catItems.where((i) => i.isLow).length;
        final totalRemaining = catItems.fold<int>(0, (s, i) => s + i.remaining);
        final weekUsage = ds.inventoryUsage.where((u) =>
          catItems.any((i) => i.id == u.itemId) &&
          u.usedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
        ).fold<int>(0, (s, u) => s + u.usedCount);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isDark ? const Color(0xFF1E1E1E) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Text('${cat.icon} ', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : null)),
                    const SizedBox(height: 4),
                    Text('$totalItems 件物品  ·  库存不足 $lowItems 件  ·  剩余 $totalRemaining', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey)),
                    Text('本周使用 $weekUsage 次', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade500)),
                  ],
                ),
              ),
            ]),
          ),
        );
      }).toList(),
      ),
      ),
    );
  }

  // ====== 对话框 ======
  void _addCategoryDialog(DataService ds) {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: '📦');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('添加分类'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '分类名称', hintText: '如：尿不湿')),
        const SizedBox(height: 8),
        TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: '图标', hintText: '如：🩲🧴🧻'), maxLength: 2),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          if (nameCtrl.text.trim().isNotEmpty) {
            ds.addInventoryCategory(InventoryCategory(
              name: nameCtrl.text.trim(), icon: iconCtrl.text.trim().isNotEmpty ? iconCtrl.text.trim() : '📦',
            ));
            Navigator.pop(ctx);
          }
        }, child: const Text('添加')),
      ],
    ));
  }

  void _editItemDialog(InventoryItem item, InventoryCategory? cat, DataService ds) {
    final nameCtrl = TextEditingController(text: item.name);
    final totalCtrl = TextEditingController(text: item.total.toString());
    final remainCtrl = TextEditingController(text: item.remaining.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final thresholdCtrl = TextEditingController(text: item.threshold.toString());
    final noteCtrl = TextEditingController(text: item.note ?? '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('编辑物品'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 4),
        TextField(controller: nameCtrl, decoration: const InputDecoration(
          labelText: '名称', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        )),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: totalCtrl, decoration: const InputDecoration(
            labelText: '总量', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ), keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: remainCtrl, decoration: const InputDecoration(
            labelText: '剩余', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(
            labelText: '单位', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: thresholdCtrl, decoration: const InputDecoration(
            labelText: '阈值', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        TextField(controller: noteCtrl, decoration: const InputDecoration(
          labelText: '备注', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        )),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          ds.updateInventoryItem(InventoryItem(
            id: item.id, categoryId: item.categoryId, name: nameCtrl.text.trim(),
            total: int.tryParse(totalCtrl.text) ?? 0, remaining: int.tryParse(remainCtrl.text) ?? 0,
            unit: unitCtrl.text.trim().isEmpty ? '个' : unitCtrl.text.trim(),
            threshold: int.tryParse(thresholdCtrl.text) ?? 1, note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
          ));
          Navigator.pop(ctx);
        }, child: const Text('保存')),
      ],
    ));
  }

  void _useItemDialog(InventoryItem item, DataService ds) {
    final ctrl = TextEditingController(text: '1');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('使用 ${item.name}'),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '使用数量')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          final count = int.tryParse(ctrl.text) ?? 1;
          if (count > 0 && item.remaining >= count) {
            final newRemaining = item.remaining - count;
            ds.updateInventoryItem(InventoryItem(
              id: item.id, categoryId: item.categoryId, name: item.name,
              total: item.total, remaining: newRemaining, unit: item.unit,
              threshold: item.threshold, note: item.note,
            ));
            ds.addInventoryUsage(InventoryUsage(itemId: item.id, usedCount: count, usedAt: DateTime.now()));
            // 低于阈值自动加入购物清单
            if (newRemaining <= item.threshold &&
                !ds.shoppingItems.any((s) => s.itemId == item.id && !s.isDone)) {
              ds.addShoppingItem(ShoppingItem(
                itemId: item.id, itemName: '${item.name} (库存不足)',
              ));
            }
            Navigator.pop(ctx);
          }
        }, child: const Text('确定')),
      ],
    ));
  }

  void _restockItemDialog(InventoryItem item, DataService ds) {
    final ctrl = TextEditingController(text: '1');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('补货 ${item.name}'),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '补货数量')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          final count = int.tryParse(ctrl.text) ?? 1;
          if (count > 0) {
            ds.updateInventoryItem(InventoryItem(
              id: item.id, categoryId: item.categoryId, name: item.name,
              total: item.total + count, remaining: item.remaining + count, unit: item.unit,
              threshold: item.threshold, note: item.note,
            ));
            Navigator.pop(ctx);
          }
        }, child: const Text('补货')),
      ],
    ));
  }

  void _deleteItemConfirm(InventoryItem item, DataService ds) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('确认删除'),
      content: Text('确定要删除 ${item.name} 吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteInventoryItem(item.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
      ],
    ));
  }

  void _addShoppingItemDialog(DataService ds) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('添加待购'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '物品名称')),
        const SizedBox(height: 8),
        TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '数量')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          if (nameCtrl.text.trim().isNotEmpty) {
            ds.addShoppingItem(ShoppingItem(
              itemName: nameCtrl.text.trim(),
              quantity: int.tryParse(qtyCtrl.text) ?? 1,
            ));
            Navigator.pop(ctx);
          }
        }, child: const Text('添加')),
      ],
    ));
  }

  void _addItemDialog(DataService ds) {
    final categories = ds.inventoryCategories;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先添加分类')));
      return;
    }
    String? selCat = _selectedCategoryId ?? categories.first.id;
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final remainCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: '个');
    final thresholdCtrl = TextEditingController(text: '1');
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('添加物品'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selCat,
            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${c.name}'))).toList(),
            onChanged: (v) => setDState(() => selCat = v),
            decoration: const InputDecoration(
              labelText: '分类', contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(
            labelText: '名称',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          )),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: totalCtrl, decoration: const InputDecoration(
              labelText: '总量',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: remainCtrl, decoration: const InputDecoration(
              labelText: '剩余',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(
              labelText: '单位',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: thresholdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(
              labelText: '阈值',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ))),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () {
            if (nameCtrl.text.trim().isNotEmpty && selCat != null) {
              ds.addInventoryItem(InventoryItem(
                categoryId: selCat!, name: nameCtrl.text.trim(),
                total: int.tryParse(totalCtrl.text) ?? 0,
                remaining: int.tryParse(remainCtrl.text) ?? 0,
                unit: unitCtrl.text.trim().isEmpty ? '个' : unitCtrl.text.trim(),
                threshold: int.tryParse(thresholdCtrl.text) ?? 1,
              ));
              Navigator.pop(ctx);
            }
          }, child: const Text('添加')),
        ],
      ),
    ));
  }

  Future<void> _onRefresh() async {
    await context.read<DataService>().reloadFromServer();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
  }

  void _deleteCategoryConfirm(String id, DataService ds) {
    final cat = ds.inventoryCategories.cast<InventoryCategory?>().firstWhere((c) => c?.id == id, orElse: () => null);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('确认删除'),
      content: Text('确定要删除分类「${cat?.name ?? ''}」吗？该分类下的物品也会被删除。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        FilledButton(onPressed: () {
          ds.deleteInventoryCategory(id);
          if (_selectedCategoryId == id) setState(() => _selectedCategoryId = null);
          Navigator.pop(ctx);
        }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
      ],
    ));
  }
}