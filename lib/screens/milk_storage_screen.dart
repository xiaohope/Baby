import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/milk_storage_record.dart';
import '../services/data_service.dart';

class MilkStorageScreen extends StatefulWidget {
  const MilkStorageScreen({super.key});

  @override
  State<MilkStorageScreen> createState() => _MilkStorageScreenState();
}

class _MilkStorageScreenState extends State<MilkStorageScreen> {
  String _type = 'breast'; // breast / formula
  final _mlController = TextEditingController();
  final _brandController = TextEditingController();
  final _gController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _dateTime = DateTime.now();

  @override
  void dispose() {
    _mlController.dispose();
    _brandController.dispose();
    _gController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    await ds.addMilkStorage(MilkStorageRecord(
      type: _type,
      dateTime: _dateTime,
      amountMl: _type == 'breast' ? int.tryParse(_mlController.text) : null,
      brand: _type == 'formula' && _brandController.text.trim().isNotEmpty
          ? _brandController.text.trim() : null,
      amountG: _type == 'formula' ? int.tryParse(_gController.text) : null,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    ));
    if (mounted) {
      _mlController.clear();
      _brandController.clear();
      _gController.clear();
      _noteController.clear();
      _dateTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  String _fmt(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.milkStorageRecords;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 统计
    final breastRecords = records.where((r) => r.type == 'breast').toList();
    final formulaRecords = records.where((r) => r.type == 'formula').toList();
    final totalBags = breastRecords.length;
    final totalLiters = breastRecords.fold<int>(0, (s, r) => s + (r.amountMl ?? 0));
    final totalCans = formulaRecords.length;
    final brands = formulaRecords.map((r) => r.brand).whereType<String>().toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('储奶记录'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : null,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 统计卡片
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(children: [
                      _statItem('🧊 母乳袋数', '$totalBags 袋', Colors.blue),
                      _statItem('📊 总量', '${(totalLiters / 1000).toStringAsFixed(2)} L', Colors.blue),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      _statItem('🥫 奶粉罐数', '$totalCans 罐', Colors.orange),
                      _statItem('🏷️ 品牌', '$brands 种', Colors.orange),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 新增表单
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.water_drop, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 8),
                      Text('新增记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(Icons.access_time, size: 16, color: Colors.grey),
                        label: Text(_fmt(_dateTime), style: const TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: _dateTime,
                            firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (d != null && mounted) {
                            final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
                            if (t != null) {
                              setState(() => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                            }
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'breast', label: Text('🧊 母乳')),
                        ButtonSegment(value: 'formula', label: Text('🥫 奶粉')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),
                    if (_type == 'breast')
                      TextField(
                        controller: _mlController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '毫升 (ml)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                        ),
                      ),
                    if (_type == 'formula') ...[
                      TextField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: '品牌',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _gController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '克数 (g)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: '备注（可选）',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: const Text('保存'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('历史记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : null)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Card(
                color: isDark ? const Color(0xFF1E1E1E) : null,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('暂无记录', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400))),
                ),
              )
            else
              ...records.map((r) => Card(
                color: isDark ? const Color(0xFF1E1E1E) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r.type == 'breast' ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    child: Icon(r.type == 'breast' ? Icons.water_drop : Icons.inventory_2, color: r.type == 'breast' ? Colors.blue : Colors.orange),
                  ),
                  title: Text('${r.typeName} ${r.displayAmount}', style: TextStyle(color: isDark ? Colors.white : null)),
                  subtitle: Text('${_fmt(r.dateTime)}${r.note != null ? '  📝${r.note}' : ''}', style: TextStyle(color: isDark ? Colors.white70 : null)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这条储奶记录吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                          FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteMilkStorage(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
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

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
