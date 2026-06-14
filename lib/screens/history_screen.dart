import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'feeding_screen.dart';
import 'diaper_screen.dart';
import 'sleep_screen.dart';
import 'growth_screen.dart';
import 'milestone_screen.dart';
import 'supplement_screen.dart';
import 'food_screen.dart';
import 'temperature_screen.dart';
import 'simple_record_screen.dart';
import 'moment_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  int _selectedIndex = 0;

  static const _tabData = [
    ['喂奶', Icons.local_drink, Color(0xFF6C63FF)],
    ['尿布', Icons.baby_changing_station, Color(0xFFFF8A80)],
    ['睡眠', Icons.bedtime, Color(0xFFD4A5FF)],
    ['成长', Icons.straighten, Color(0xFFA8E6CF)],
    ['补充', Icons.medication, Color(0xFF81C9D6)],
    ['里程碑', Icons.star, Color(0xFFFFB347)],
    ['疫苗', Icons.vaccines, Color(0xFF27AE60)],
    ['就医', Icons.local_hospital, Color(0xFFE74C3C)],
    ['动态', Icons.photo_library, Color(0xFFFF6B6B)],
    ['尿尿', Icons.water_drop, Color(0xFF4A90D9)],
    ['粑粑', Icons.report, Color(0xFF8B5E3C)],
    ['用药', Icons.medication, Color(0xFFE74C3C)],
    ['喝水', Icons.local_drink, Color(0xFF3498DB)],
    ['辅食', Icons.restaurant, Color(0xFFFF8A80)],
    ['体温', Icons.thermostat, Color(0xFFE74C3C)],
    ['洗澡', Icons.bathroom, Color(0xFF81C9D6)],
  ];

  String dateStr(DateTime d) => '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
  String timeStr(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  bool dateMatch(DateTime t) => _selectedDate == null || isSameDay(t, _selectedDate!);

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_selectedDate != null ? Icons.clear : Icons.calendar_month, color: const Color(0xFF6C63FF)),
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
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<DataService>().reloadFromServer();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
          },
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_selectedDate != null ? dateStr(_selectedDate!) : '全部记录', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                      itemCount: _tabData.length,
                      itemBuilder: (ctx, i) {
                        final label = _tabData[i][0] as String;
                        final icon = _tabData[i][1] as IconData;
                        final color = _tabData[i][2] as Color;
                        final isSelected = i == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Material(
                            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => setState(() => _selectedIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
                                    const SizedBox(height: 3),
                                    Text(label, style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? color : Colors.grey,
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
                  Container(width: 1, color: Colors.grey.withValues(alpha: 0.15)),
                  Expanded(
                    child: _buildContent(ds),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildContent(DataService ds) {
    switch (_selectedIndex) {
      case 0: return _buildList(ds, ds.feedingRecords.where((r) => dateMatch(r.time)).toList(),
        (r) => _card(Icons.local_drink, Colors.blue, r.typeName, '${timeStr(r.time)}  ${r.displayAmount}', () => ds.deleteFeeding(r.id), '这条喂奶记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeedingScreen(initialRecord: r)))));
      case 1: return _buildList(ds, ds.diaperRecords.where((r) => dateMatch(r.time)).toList(),
        (r) => _card(Icons.baby_changing_station, Colors.orange, r.typeName, '${timeStr(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}', () => ds.deleteDiaper(r.id), '这条尿布记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaperScreen(initialRecord: r)))));
      case 2: return _buildList(ds, ds.sleepRecords.where((r) => dateMatch(r.startTime)).toList(),
        (r) => _card(Icons.bedtime, Colors.purple, r.isOngoing ? '睡眠中' : '睡眠', '${timeStr(r.startTime)}${r.endTime != null ? ' - ${timeStr(r.endTime!)}' : ''}  ${r.durationStr}', () => ds.deleteSleep(r.id), '这条睡眠记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => SleepScreen(initialRecord: r)))));
      case 3: return _buildList(ds, ds.growthRecords.where((r) => dateMatch(r.date)).toList(),
        (r) => _card(Icons.straighten, Colors.teal, '${r.date.month}/${r.date.day}', [
          if (r.weightKg != null) '体重: ${r.weightKg}kg',
          if (r.heightCm != null) '身长: ${r.heightCm}cm',
          if (r.headCircumferenceCm != null) '头围: ${r.headCircumferenceCm}cm',
        ].join('  '), () => ds.deleteGrowth(r.id), '这条成长记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => GrowthScreen(initialRecord: r)))));
      case 4: return _buildList(ds, ds.allSupplementRecords().where((r) => dateMatch(r.date)).toList(),
        (r) => _card(Icons.medication, Colors.green, '${r.date.month}月${r.date.day}日', r.items.join('、'), () => ds.deleteSupplement(r.id), '这条补充记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupplementScreen(initialRecord: r)))));
      case 5: return _buildList(ds, ds.milestoneRecords.where((r) => dateMatch(r.date) && r.category == 'milestone').toList(),
        (r) => _card(Icons.star, Colors.amber, '🌟 ${r.title}', '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', () => ds.deleteMilestone(r.id), '这条里程碑记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MilestoneScreen(initialCategory: 'milestone', initialRecord: r)))));
      case 6: return _buildList(ds, ds.milestoneRecords.where((r) => dateMatch(r.date) && r.category == 'vaccine').toList(),
        (r) => _card(Icons.vaccines, const Color(0xFF27AE60), '💉 ${r.title}', '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', () => ds.deleteMilestone(r.id), '这条疫苗记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MilestoneScreen(initialCategory: 'vaccine', initialRecord: r)))));
      case 7: return _buildList(ds, ds.milestoneRecords.where((r) => dateMatch(r.date) && r.category == 'hospital').toList(),
        (r) => _card(Icons.local_hospital, const Color(0xFFE74C3C), '🏥 ${r.title}', '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}', () => ds.deleteMilestone(r.id), '这条就医记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MilestoneScreen(initialCategory: 'hospital', initialRecord: r)))));
      case 8: return _buildList(ds, ds.momentRecords.where((r) => dateMatch(r.date)).toList(),
        (r) => _card(Icons.photo_library, const Color(0xFFFF6B6B), r.text.isNotEmpty ? r.text : '[图片]', '${timeStr(r.date)}${r.imagePaths.isNotEmpty ? '  📸${r.imagePaths.length}张' : ''}', () => ds.deleteMoment(r.id), '这条动态', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MomentDetailScreen(text: r.text, imagePaths: r.imagePaths, timeStr: timeStr(r.date))))));
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
    final records = ds.simpleRecordsByCategory(category).where((r) => dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) => _card(icon, color, '$emoji $label', '${timeStr(r.time)}${r.note.isNotEmpty ? '  ${r.note}' : ''}', () => ds.deleteSimpleRecord(r.id), '这条${label}记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => SimpleRecordScreen(category: category, title: label, icon: icon, color: color, emoji: emoji, initialRecord: r)))));
  }

  Widget _buildFoodList(DataService ds) {
    final records = ds.foodRecords.where((r) => dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) => _card(Icons.restaurant, const Color(0xFFFF8A80), r.name, '${timeStr(r.time)}${r.portion != null ? '  ${r.portion}' : ''}${r.feeling != null ? '  ${r.feeling}' : ''}${r.note != null ? '  📝${r.note}' : ''}', () => ds.deleteFood(r.id), '这条辅食记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodScreen(initialRecord: r)))));
  }

  Widget _buildTempList(DataService ds) {
    final records = ds.tempRecords.where((r) => dateMatch(r.time)).toList();
    return _buildList(ds, records, (r) {
      final isHot = r.temperature > 37.5;
      return _card(Icons.thermostat, isHot ? Colors.red : Colors.green, '${r.temperature.toStringAsFixed(1)}℃', '${timeStr(r.time)}${r.note != null ? '  📝${r.note}' : ''}', () => ds.deleteTemperature(r.id), '这条体温记录', () => Navigator.push(context, MaterialPageRoute(builder: (_) => TemperatureScreen(initialRecord: r))));
    });
  }

  Widget _buildList(DataService ds, List records, Widget Function(dynamic) builder) {
    if (records.isEmpty) {
      final label = _tabData[_selectedIndex][0] as String;
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_tabData[_selectedIndex][1] as IconData, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('当日无$label记录', style: TextStyle(color: Colors.grey.shade400)),
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

  Widget _card(IconData icon, Color color, String title, String subtitle, VoidCallback onDelete, String deleteLabel, [VoidCallback? onTap]) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
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
              content: Text('确定要删除$deleteLabel吗？'),
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
