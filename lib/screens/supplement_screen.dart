import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplement_record.dart';
import '../services/data_service.dart';

class SupplementScreen extends StatefulWidget {
  final SupplementRecord? initialRecord;
  const SupplementScreen({super.key, this.initialRecord});

  @override
  State<SupplementScreen> createState() => _SupplementScreenState();
}

class _SupplementScreenState extends State<SupplementScreen> {
  final _newItemController = TextEditingController();
  List<String> _items = [];
  final Set<int> _checked = {};

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    final today = ds.todaySupplement();
    if (today != null) {
      _items = List.from(today.items);
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final checkedItems = _items.asMap().entries.where((e) => _checked.contains(e.key)).map((e) => e.value).toList();
    await ds.setSupplement(SupplementRecord(
      date: DateTime.now(),
      items: checkedItems,
    ));
    if (mounted) {
      setState(() => _checked.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(text);
    });
    _newItemController.clear();
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _editItem(int index, String newValue) {
    setState(() {
      _items[index] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final allRecords = ds.allSupplementRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('营养补充'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ====== 今日记录 ======
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.medication, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 8),
                      Text('今日补充', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _items.isNotEmpty
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_items.length}项',
                          style: TextStyle(
                            fontSize: 12,
                            color: _items.isNotEmpty ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // 添加新项目
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newItemController,
                            decoration: const InputDecoration(
                              hintText: '输入补充剂名称',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addItem(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _addItem,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 已添加项目列表
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.medication_outlined, size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text('今日尚未添加', style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(_items.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _checked.contains(i),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) { _checked.add(i); }
                                    else { _checked.remove(i); }
                                  });
                                },
                                activeColor: const Color(0xFF6C63FF),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _items[i],
                                          style: TextStyle(fontSize: 15, decoration: _checked.contains(i) ? TextDecoration.none : null),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _editItemDialog(i),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade500),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => _deleteItem(i),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(Icons.close, size: 18, color: Colors.red.shade300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: const Text('保存今日记录'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====== 历史记录 ======
            Text('历史记录', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (allRecords.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('暂无记录', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                ),
              )
            else
              ...allRecords.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    child: const Icon(Icons.medication, color: Colors.green),
                  ),
                  title: Text(
                    '${r.date.month}月${r.date.day}日',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(r.items.join('、'), style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这条补充记录吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                          FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteSupplement(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _editItemDialog(int index) {
    final controller = TextEditingController(text: _items[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('编辑补充剂'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入名称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _editItem(index, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
