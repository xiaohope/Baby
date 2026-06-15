import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tooth_record.dart';
import '../services/data_service.dart';

class ToothScreen extends StatefulWidget {
  const ToothScreen({super.key});

  @override
  State<ToothScreen> createState() => _ToothScreenState();
}

class _EditToothDialog extends StatefulWidget {
  final ToothRecord record;
  final Function(DateTime, String?) onSave;
  const _EditToothDialog({required this.record, required this.onSave});

  @override
  State<_EditToothDialog> createState() => _EditToothDialogState();
}

class _EditToothDialogState extends State<_EditToothDialog> {
  late DateTime _date;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _date = widget.record.foundDate;
    _noteController = TextEditingController(text: widget.record.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('编辑 ${widget.record.toothName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text('${_date.year}/${_date.month}/${_date.day}'),
            onPressed: () async {
              final d = await showDatePicker(context: context, initialDate: _date,
                firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) setState(() => _date = d);
            },
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: '备注', hintText: '如：有点发烧'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: () {
          widget.onSave(_date, _noteController.text.trim().isEmpty ? null : _noteController.text.trim());
          Navigator.pop(context);
        }, child: const Text('保存')),
      ],
    );
  }
}

class _ToothScreenState extends State<ToothScreen> {
  final _noteController = TextEditingController();
  DateTime _foundDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addTooth(int index) async {
    final ds = context.read<DataService>();
    await ds.addTooth(ToothRecord(
      toothIndex: index,
      foundDate: _foundDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    ));
    if (mounted) {
      _noteController.clear();
      _foundDate = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${ToothRecord.toothNames[index]} 已记录'), duration: Duration(seconds: 1)),
      );
    }
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}';

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.toothRecords;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recordedIndexes = records.map((r) => r.toothIndex).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('牙齿记录'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : null,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 统计
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('已出 ${records.length} 颗牙', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend('左上', Colors.blue),
                        const SizedBox(width: 16),
                        _legend('右上', Colors.red),
                        const SizedBox(width: 16),
                        _legend('左下', Colors.green),
                        const SizedBox(width: 16),
                        _legend('右下', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 牙齿图
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 上排（左上1-5, 右上1-5）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final idx = 6 + i; // 左上 6-10
                        final has = recordedIndexes.contains(idx);
                        return _toothBtn(idx, has, Colors.blue, allRecords: records, isDarkMode: isDark);
                      }),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final idx = 1 + i; // 右上 1-5
                        final has = recordedIndexes.contains(idx);
                        return _toothBtn(idx, has, Colors.red, allRecords: records, isDarkMode: isDark);
                      }),
                    ),
                    const SizedBox(height: 16),
                    // 下排（左下11-15, 右下16-20）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final idx = 11 + i; // 左下 11-15
                        final has = recordedIndexes.contains(idx);
                        return _toothBtn(idx, has, Colors.green, allRecords: records, isDarkMode: isDark);
                      }),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final idx = 16 + i; // 右下 16-20
                        final has = recordedIndexes.contains(idx);
                        return _toothBtn(idx, has, Colors.orange, allRecords: records, isDarkMode: isDark);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 备注输入
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('备注（选填）', style: TextStyle(color: isDark ? Colors.white : null)),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(Icons.access_time, size: 16, color: Colors.grey),
                        label: Text(_fmt(_foundDate), style: const TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final d = await showDatePicker(context: context, initialDate: _foundDate,
                            firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (d != null && mounted) setState(() => _foundDate = d);
                        },
                      ),
                    ]),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: '如：有点发烧',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('出牙记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : null)),
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
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    child: const Icon(Icons.egg, color: Colors.teal),
                  ),
                  title: Text('${r.toothName} (${r.toothType})', style: TextStyle(color: isDark ? Colors.white : null)),
                  subtitle: Text('${_fmt(r.foundDate)}${r.note != null ? '  📝${r.note}' : ''}', style: TextStyle(color: isDark ? Colors.white70 : null)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这条牙齿记录吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                          FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteTooth(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
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

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _editTooth(ToothRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => _EditToothDialog(record: record, onSave: (newDate, newNote) async {
        final ds = context.read<DataService>();
        await ds.deleteTooth(record.id);
        await ds.addTooth(ToothRecord(
          toothIndex: record.toothIndex,
          foundDate: newDate,
          note: newNote,
        ));
      }),
    );
  }

  Widget _toothBtn(int index, bool hasRecord, Color color, {List<ToothRecord>? allRecords, bool? isDarkMode}) {
    final rec = allRecords ?? <ToothRecord>[];
    final dark = isDarkMode ?? false;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: hasRecord
            ? () => _editTooth(rec.firstWhere((r) => r.toothIndex == index))
            : () => _addTooth(index),
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: hasRecord ? color.withValues(alpha: 0.2) : (dark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hasRecord ? color : Colors.grey.shade300, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hasRecord ? '🦷' : '${index}',
                style: TextStyle(fontSize: hasRecord ? 20 : 11, color: hasRecord ? null : Colors.grey),
              ),
              if (hasRecord)
                Text('✓', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
