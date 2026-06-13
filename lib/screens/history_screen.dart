import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  int _selectedIndex = 0;

  static const _tabs = [
    _TabInfo('喂奶', Icons.local_drink, Color(0xFF6C63FF)),
    _TabInfo('尿布', Icons.baby_changing_station, Color(0xFFFF8A80)),
    _TabInfo('睡眠', Icons.bedtime, Color(0xFFD4A5FF)),
    _TabInfo('成长', Icons.straighten, Color(0xFFA8E6CF)),
    _TabInfo('补充', Icons.medication, Color(0xFF81C9D6)),
    _TabInfo('里程�?, Icons.star, Color(0xFFFFB347)),
    _TabInfo('疫苗', Icons.vaccines, Color(0xFF27AE60)),
    _TabInfo('就医', Icons.local_hospital, Color(0xFFE74C3C)),
    _TabInfo('动�?, Icons.photo_library, Color(0xFFFF6B6B)),
    _TabInfo('尿尿', Icons.water_drop, Color(0xFF4A90D9)),
    _TabInfo('粑粑', Icons.report, Color(0xFF8B5E3C)),
    _TabInfo('用药', Icons.medication, Color(0xFFE74C3C)),
    _TabInfo('喝水', Icons.local_drink, Color(0xFF3498DB)),
    _TabInfo('辅食', Icons.restaurant, Color(0xFFFF8A80)),
    _TabInfo('体温', Icons.thermostat, Color(0xFFE74C3C)),
    _TabInfo('洗澡', Icons.bathroom, Color(0xFF81C9D6)),
  ];

  String _fmtDate(DateTime d) => '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
  String _fmtTime(DateTime t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  bool _dateMatch(DateTime t) => _selectedDate == null || _isSameDay(t, _selectedDate!);

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final tab = _tabs[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_selectedDate != null ? Icons.clear : Icons.calendar_month, color: Color(0xFF6C63FF)),
            onPressed: () {
              if (_selectedDate != null) {
                setState(() => _selectedDate = null);
              } else {
                showDatePicker(
                  context: context, initialDate: DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime.now(),
                ).then((d) { if (d != null) setState(() => _selectedDate = d); });
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null : const LinearGradient(colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : null,
        ),
        child: Column(
          children: [
            // 日期显示
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_selectedDate != null ? _fmtDate(_selectedDate!) : '全部记录', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            // 左侧导航 + 右侧内容
            Expanded(
              child: Row(
                children: [
                  // 左侧导航
                  SizedBox(
                    width: 76,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                      itemCount: _tabs.length,
                      itemBuilder: (ctx, i) {
                        final t = _tabs[i];
                        final isSelected = i == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Material(
                            color: isSelected ? t.color.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => _selectedIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Icon(t.icon, color: isSelected ? t.color : Colors.grey, size: 22),
                                    const SizedBox(height: 3),
                                    Text(t.label, style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? t.color : Colors.grey,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 分割�?                  Container(width: 1, color: Colors.grey.withValues(alpha: 0.15)),
                  // 右侧内容
                  Expanded(
                    child: _buildContent(ds, tab),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DataService ds, _TabInfo tab) {
    final idx = _tabs.indexOf(tab);
    switch (idx) {
      case 0: return _buildList(ds, ds.feedingRecords.where((r) => _dateMatch(r.time)).toList(),
        (r) => _card(icon: Icons.local_drink, color: Colors.blue, title: r.typeName, subtitle: '${_fmtTime(r.time)}  ${r.displayAmount}', onDelete: () => ds.deleteFeeding(r.id), deleteLabel: '这条喂奶记录'));
      case 1: return _buildList(ds, ds.diaperRecords.where((r) => _dateMatch(r.time)).toList(),
        (r) => _card(icon: Icons.baby_changing_station, color: Colors.orange, title: r.typeName, subtitle: '${_fmtTime(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}', onDelete: () => ds.deleteDiaper(r.id), deleteLabel: '这条尿布记录'));
      case 2: return _buildList(ds, ds.sleepRecords.where((r) => _dateMatch(r.startTime)).toList(),
        (r) => _card(icon: Icons.bedtime, color: Colors.purple, title: r.isOngoing ? '睡眠�? : '睡眠', subtitle: '${_fmtTime(r.startTime)}${r.endTime != null ? ' - ${_fmtTime(r.endTime!)}' : ''}  ${r.durationStr}', onDelete: () => ds.deleteSleep(r.id), deleteLabel: '这条睡眠记录'));
      case 3: return _buildList(ds, ds.growthRecords.where((r) => _dateMatch(r.date)).toList(),
        (r) => _card(icon: Icons.straighten, color: Colors.teal, title: '${r.date.month}/${r.date.day}', subtitle: [
          if (r.weightKg != null) '体重: ${r.weightKg}kg',
          if (r.heightCm != null) '身长: ${r.heightCm}cm',
          if (r.headCircumferenceCm != null) '头围: ${r.headCircumferenceCm}cm',
        ].join('  '), onDelete: () => ds.deleteGrowth(r.id), deleteLabel: '这条成长记录'));
      case 4: return _buildList(ds, ds.allSupplementRecords().where((r) => _dateMatch(r.date)).toList(),
        (r) => _card(icon: Icons.medication, color: Colors.green, title: '${r.date.month}�?{r.date.day}�?, subtitle: r.items.join('�?), onDelete: () => ds.deleteSupplement(r.id), deleteLabel: '这条补充记录'));
      case 5: return _buildList(ds, ds.milestoneRecords.where((r) => _dateMatch(r.date) && r.category == 'milestone').toList(),
        (r) {
          return _card(icon: Icons.star, color: Colors.amber, title: '🌟 ${r.title}', subtitle: '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', onDelete: () => ds.deleteMilestone(r.id), deleteLabel: '这条里程碑记�?);
        });
      case 6: return _buildList(ds, ds.milestoneRecords.where((r) => _dateMatch(r.date) && r.category == 'vaccine').toList(),
        (r) {
          return _card(icon: Icons.vaccines, color: const Color(0xFF27AE60), title: '💉 ${r.title}', subtitle: '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', onDelete: () => ds.deleteMilestone(r.id), deleteLabel: '这条疫苗记录');
        });
      case 7: return _buildList(ds, ds.milestoneRecords.where((r) => _dateMatch(r.date) && r.category == 'hospital').toList(),
        (r) {
          return _card(icon: Icons.local_hospital, color: const Color(0xFFE74C3C), title: '🏥 ${r.title}', subtitle: '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', onDelete: () => ds.deleteMilestone(r.id), deleteLabel: '这条就医记录');
        });
      case 8: return _buildList(ds, ds.momentRecords.where((r) => _dateMatch(r.date)).toList(),
        (r) => _card(icon: Icons.photo_library, color: const Color(0xFFFF6B6B), title: r.text.isNotEmpty ? r.text : '[图片]', subtitle: '${_fmtTime(r.date)}${r.imagePaths.isNotEmpty ? '  📸${r.imagePaths.length}�? : ''}', onDelete: () => ds.deleteMoment(r.id), deleteLabel: '这条动�?));
      case 9: return _buildSimpleList(ds, 'pee', '尿尿', Icons.water_drop, const Color(0xFF4A90D9), '💦');
      case 10: return _buildSimpleList(ds, 'poop', '粑粑', Icons.report, const Color(0xFF8B5E3C), '💩');
      case 11: return _buildSimpleList(ds, 'medication', '用药', Icons.medication, const Color(0xFFE74C3C), '💊');
      case 12: return _buildSimpleList(ds, 'water', '喝水', Icons.local_drink, const Color(0xFF3498DB), '🥤');
      case 13: return _buildFoodList(ds);
      case 14: return _buildTempList(ds);
      case 15: return _buildSimpleList(ds, 'bath', '洗澡', Icons.bathroom, const Color(0xFF81C9D6), '🛁');
      default: return const SizedBox();
    }
  }

  Widget _buildSimpleList(DataService ds, String category, String label, IconData icon, Color color, String emoji) {
    final records = ds.simpleRecordsByCategory(category).where((r) => _dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) => _card(icon: icon, color: color, title: '$emoji $label', subtitle: '${_fmtTime(r.time)}${r.note.isNotEmpty ? '  ${r.note}' : ''}', onDelete: () => ds.deleteSimpleRecord(r.id), deleteLabel: '这条${label}记录'));
  }

  Widget _buildFoodList(DataService ds) {
    final records = ds.foodRecords.where((r) => _dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) => _card(icon: Icons.restaurant, color: const Color(0xFFFF8A80), title: r.name, subtitle: '${_fmtTime(r.time)}${r.portion != null ? '  ${r.portion}' : ''}${r.feeling != null ? '  ${r.feeling}' : ''}${r.note != null ? '  📝${r.note}' : ''}', onDelete: () => ds.deleteFood(r.id), deleteLabel: '这条辅食记录'));
  }

  Widget _buildTempList(DataService ds) {
    final records = ds.tempRecords.where((r) => _dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) {
      final isHot = r.temperature > 37.5;
      return _card(icon: Icons.thermostat, color: isHot ? Colors.red : Colors.green, title: '${r.temperature.toStringAsFixed(1)}�?, subtitle: '${_fmtTime(r.time)}${r.note != null ? '  📝${r.note}' : ''}', onDelete: () => ds.deleteTemperature(r.id), deleteLabel: '这条体温记录');
    });
  }

  Widget _buildList(DataService ds, List records, Widget Function(dynamic) builder) {
    if (records.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_tabs[_selectedIndex].icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('当日无记�?, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: records.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: builder(records[i]),
      ),
    );
  }

  Widget _card({
    required IconData icon, required Color color, required String title,
    required String subtitle, required VoidCallback onDelete,
    String deleteLabel = '这条记录',
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 11)) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('确认删除'),
              content: Text('确定要删�?deleteLabel吗？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(onPressed: () { Navigator.pop(ctx); onDelete(); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
              ],
            ),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _TabInfo(this.label, this.icon, this.color);
}
