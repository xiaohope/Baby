import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/milestone_record.dart';
import '../services/data_service.dart';

class MilestoneScreen extends StatefulWidget {
  final String initialCategory;
  final MilestoneRecord? initialRecord;

  const MilestoneScreen({super.key, this.initialCategory = 'milestone', this.initialRecord});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  late String _category;
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _editingId;

  final Map<String, List<String>> _presetMilestones = {
    'milestone': ['第一次微笑', '翻身', '独坐', '爬行', '站立', '迈步走', '叫爸爸妈妈', '长牙', '认人', '认生'],
    'hospital': ['体检', '就诊', '复查', '用药'],
    'vaccine': ['疫苗接种'],
  };

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    final r = widget.initialRecord;
    if (r != null) {
      _editingId = r.id;
      _titleController.text = r.title;
      _selectedDate = r.date;
      _noteController.text = r.note ?? '';
      _category = r.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) return;
    final ds = context.read<DataService>();
    if (_editingId != null) await ds.deleteMilestone(_editingId!);
    await ds.addMilestone(MilestoneRecord(
      id: _editingId,
      date: _selectedDate,
      title: _titleController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      category: _category,
    ));
    _titleController.clear();
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'hospital': return Icons.local_hospital;
      case 'vaccine': return Icons.vaccines;
      default: return Icons.star;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'hospital': return Colors.red;
      case 'vaccine': return Colors.green;
      default: return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.milestoneRecords.take(30).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('里程碑 & 备忘'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF0FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        color: isDark ? const Color(0xFF121212) : null,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E1E) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新增记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'milestone', label: Text('🌟 里程碑')),
                ButtonSegment(value: 'hospital', label: Text('🏥 就医')),
                ButtonSegment(value: 'vaccine', label: Text('💉 疫苗')),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return isDark ? Colors.white70 : Colors.black87;
                }),
                textStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const TextStyle(color: Colors.white);
                  return TextStyle(color: isDark ? Colors.white70 : Colors.black87);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF6C63FF);
                  return isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
                }),
                side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF6C63FF), width: 1)),
              ),
            ),
            const SizedBox(height: 12),
            // 预设快捷选项
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_presetMilestones[_category] ?? []).map((preset) =>
                ActionChip(
                  label: Text(preset, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : null)),
                  onPressed: () => _titleController.text = preset,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                )
              ).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '日期',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4A90E2)),
                ),
                child: Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}', style: TextStyle(color: isDark ? Colors.white : null)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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

  Widget _buildRecordItem(MilestoneRecord r, DataService ds) {
    final color = _categoryColor(r.category);
    final icon = _categoryIcon(r.category);
    String emoji;
    switch (r.category) {
      case 'hospital': emoji = '🏥';
      case 'vaccine': emoji = '💉';
      default: emoji = '🌟';
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E1E1E) : null,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text('$emoji ${r.title}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
        subtitle: Text('${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', style: TextStyle(color: isDark ? Colors.white70 : null)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('确认删除'),
              content: const Text('确定要删除这条里程碑记录吗？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteMilestone(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}