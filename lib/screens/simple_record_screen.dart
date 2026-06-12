import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/simple_record.dart';
import '../services/data_service.dart';

class SimpleRecordScreen extends StatefulWidget {
  final String category;
  final String title;
  final IconData icon;
  final Color color;
  final String emoji;

  const SimpleRecordScreen({
    super.key,
    required this.category,
    required this.title,
    required this.icon,
    required this.color,
    required this.emoji,
  });

  @override
  State<SimpleRecordScreen> createState() => _SimpleRecordScreenState();
}

class _SimpleRecordScreenState extends State<SimpleRecordScreen> {
  final _noteController = TextEditingController();
  DateTime _recordTime = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    await ds.addSimpleRecord(SimpleRecord(
      category: widget.category,
      time: _recordTime,
      note: _noteController.text.trim(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已记录'), duration: Duration(seconds: 1)),
      );
      Navigator.pop(context);
    }
  }

  String _fmtTime(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.simpleRecordsByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            // 新增记录表单
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
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('新增${widget.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // 时间选择
                      TextButton.icon(
                        icon: Icon(Icons.access_time, size: 16, color: widget.color),
                        label: Text(_fmtTime(_recordTime), style: TextStyle(fontSize: 13, color: widget.color)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _recordTime,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_recordTime),
                            );
                            if (time != null) {
                              setState(() {
                                _recordTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: '备注（可选）',
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
                          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F0EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: Icon(widget.icon),
                        label: Text('记录${widget.title}'),
                        style: FilledButton.styleFrom(backgroundColor: widget.color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 历史记录
            Text('历史记录', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(widget.icon, size: 36, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('暂无记录', style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...records.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.color.withValues(alpha: 0.1),
                    child: Text(widget.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(
                    '${r.time.month}/${r.time.day} ${r.time.hour.toString().padLeft(2,'0')}:${r.time.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: r.note.isNotEmpty ? Text(r.note, style: const TextStyle(fontSize: 13)) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => ds.deleteSimpleRecord(r.id),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
