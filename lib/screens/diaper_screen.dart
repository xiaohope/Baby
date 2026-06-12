import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diaper_record.dart';
import '../services/data_service.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  DiaperType _selectedType = DiaperType.pee;
  String? _poopColor;
  final _noteController = TextEditingController();
  DateTime _recordTime = DateTime.now();

  final List<String> _poopColors = [
    '黄色', '棕色', '绿色', '黑色', '灰色', '奶瓣', '水便'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final ds = context.read<DataService>();
      final record = DiaperRecord(
        time: _recordTime,
        type: _selectedType,
        poopColor: (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ? _poopColor : null,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      await ds.addDiaper(record);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
        );
        setState(() {
          _selectedType = DiaperType.pee;
          _poopColor = null;
          _noteController.clear();
          _recordTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _fmt(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('换尿布记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF0FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) return _buildForm();
            final r = records[index - 1];
            return _buildRecordItem(r, ds);
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('新增记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.access_time_outlined, size: 18, color: Color(0xFF4A90E2)),
                  label: Text(
                    '${_recordTime.month}/${_recordTime.day} ${_recordTime.hour.toString().padLeft(2,'0')}:${_recordTime.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 14),
                  ),
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
                          _recordTime = DateTime(
                            date.year, date.month, date.day,
                            time.hour, time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<DiaperType>(
              segments: const [
                ButtonSegment(value: DiaperType.pee, label: Text('小便')),
                ButtonSegment(value: DiaperType.poop, label: Text('大便')),
                ButtonSegment(value: DiaperType.both, label: Text('两者都有')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) => setState(() => _selectedType = s.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return Colors.black87;
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF6C63FF);
                  return Colors.grey.shade100;
                }),
                side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF6C63FF), width: 1)),
              ),
            ),
            if (_selectedType == DiaperType.poop || _selectedType == DiaperType.both) ...[
              const SizedBox(height: 12),
              const Text('大便颜色', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _poopColors.map((c) {
                  final colorMap = {
                    '黄色': Colors.yellow.shade700,
                    '棕色': Colors.brown.shade400,
                    '绿色': Colors.green.shade400,
                    '黑色': Colors.black87,
                    '灰色': Colors.grey,
                    '奶瓣': Colors.amber.shade200,
                    '水便': Colors.blue.shade200,
                  };
                  return ChoiceChip(
                    label: Text(c),
                    selected: _poopColor == c,
                    onSelected: (_) => setState(() => _poopColor = c),
                    selectedColor: Colors.orange.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    avatar: _poopColor == c
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colorMap[c] ?? Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                hintText: '如：形状异常/血丝等',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('保存记录'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(DiaperRecord r, DataService ds) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(Icons.baby_changing_station, color: Colors.orange),
        ),
        title: Text(r.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_fmt(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}${r.note != null ? '  📝${r.note}' : ''}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('确认删除'),
              content: const Text('确定要删除这条尿布记录吗？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteDiaper(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}