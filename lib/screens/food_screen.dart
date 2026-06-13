import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_record.dart';
import '../services/data_service.dart';

class FoodScreen extends StatefulWidget {
  final FoodRecord? initialRecord;
  const FoodScreen({super.key, this.initialRecord});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  String? _portion;
  String? _feeling;
  DateTime _recordTime = DateTime.now();

  static const _presetFoods = [
    '米粉', '南瓜泥', '胡萝卜泥', '土豆泥', '西兰花泥',
    '菠菜泥', '苹果泥', '香蕉泥', '梨泥', '牛油果泥',
    '蛋黄', '粥', '面条', '馒头', '山药泥', '紫薯泥',
  ];

  static const _portions = ['少量', '1/4碗', '半碗', '3/4碗', '一碗', '一勺', '两勺'];
  static const _feelings = ['😊 喜欢', '😐 一般', '😣 不喜欢', '🤮 吐了', '😴 吃着睡着'];

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecord;
    if (r != null) {
      _nameController.text = r.name;
      _portion = r.portion;
      _feeling = r.feeling;
      _recordTime = r.time;
      _noteController.text = r.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入辅食名称'), backgroundColor: Colors.orange),
      );
      return;
    }
    final ds = context.read<DataService>();
    await ds.addFood(FoodRecord(
      name: _nameController.text.trim(),
      portion: _portion,
      feeling: _feeling,
      time: _recordTime,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
      setState(() {
        _portion = null;
        _feeling = null;
        _nameController.clear();
        _noteController.clear();
        _recordTime = DateTime.now();
      });
    }
  }

  String _fmt(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.foodRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('辅食记录'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null : const LinearGradient(colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : null,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A80).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant, color: Color(0xFFFF8A80), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('新增辅食', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time, size: 16, color: Color(0xFFFF8A80)),
                        label: Text(_fmt(_recordTime), style: const TextStyle(fontSize: 13, color: Color(0xFFFF8A80))),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context, initialDate: _recordTime,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now(),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context, initialTime: TimeOfDay.fromDateTime(_recordTime),
                            );
                            if (time != null) setState(() => _recordTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // 食物名称输入
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '辅食名称',
                        hintText: '输入或从下方选择',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFFF8A80), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 预设选择
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _presetFoods.map((f) => ActionChip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _nameController.text = f,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: const Color(0xFFFF8A80).withValues(alpha: 0.3)),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 分量
                    const Text('分量', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _portions.map((p) => ChoiceChip(
                        label: Text(p, style: const TextStyle(fontSize: 13)),
                        selected: _portion == p,
                        onSelected: (_) => setState(() => _portion = p),
                        selectedColor: const Color(0xFFFF8A80).withValues(alpha: 0.2),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 宝宝感受
                    const Text('宝宝感受', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _feelings.map((f) => ChoiceChip(
                        label: Text(f, style: const TextStyle(fontSize: 13)),
                        selected: _feeling == f,
                        onSelected: (_) => setState(() => _feeling = f),
                        selectedColor: const Color(0xFFFF8A80).withValues(alpha: 0.2),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 备注
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '备注（可选）',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFFF8A80), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: const Text('保存记录'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A80)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
