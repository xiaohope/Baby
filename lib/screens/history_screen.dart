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

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  int _selectedIndex = 0;
  late TabController _tabController;

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
    ['储奶', Icons.kitchen, Color(0xFF6C63FF)],
    ['牙齿', Icons.egg, Color(0xFF26A69A)],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String dateStr(DateTime d) => '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
  String timeStr(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  bool dateMatch(DateTime t) => _selectedDate == null || isSameDay(t, _selectedDate!);

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('历史记录'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '📋 列表'),
              Tab(text: '⏱ 时间轴'),
            ],
            labelColor: const Color(0xFF6C63FF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6C63FF),
          ),
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
            gradient: isDark ? null : const LinearGradient(colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            color: isDark ? const Color(0xFF121212) : null,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryView(ds, isDark),
              _buildTimeline(ds, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Tab1: 分类列表 ======
  Widget _buildCategoryView(DataService ds, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DataService>().reloadFromServer();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_selectedDate != null ? dateStr(_selectedDate!) : '全部记录', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _tabData.length,
                itemBuilder: (ctx, i) {
                  final label = _tabData[i][0] as String;
                  final icon = _tabData[i][1] as IconData;
                  final color = _tabData[i][2] as Color;
                  final isSelected = i == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
                            const SizedBox(width: 4),
                            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverFillRemaining(child: _buildContent(ds)),
        ],
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
      case 16: return _buildMilkStorageList(ds);
      default: return _buildToothList(ds);
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

  Widget _buildMilkStorageList(DataService ds) {
    final records = ds.milkStorageRecords.where((r) => dateMatch(r.dateTime)).toList();
    return _buildList(ds, records, (r) => _card(r.type == 'breast' ? Icons.water_drop : Icons.kitchen, r.type == 'breast' ? Colors.blue : Colors.orange, '${r.typeName} ${r.displayAmount}', timeStr(r.dateTime), () => ds.deleteMilkStorage(r.id), '这条储奶记录'));
  }

  Widget _buildToothList(DataService ds) {
    final records = ds.toothRecords.where((r) => dateMatch(r.foundDate)).toList();
    return _buildList(ds, records, (r) => _card(Icons.egg, Colors.teal, '${r.toothName} (${r.toothType})', '${r.foundDate.month}/${r.foundDate.day}${r.note != null ? '  📝${r.note}' : ''}', () => ds.deleteTooth(r.id), '这条牙齿记录'));
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

  // ====== Tab2: 时间轴 ======
  Widget _buildTimeline(DataService ds, bool isDark) {
    // 收集所有记录
    final items = <_TimelineItem>[];
    for (final r in ds.feedingRecords) items.add(_TimelineItem(r.time, Icons.local_drink, Colors.blue, '🍼 喂奶', r.typeName));
    for (final r in ds.diaperRecords) items.add(_TimelineItem(r.time, Icons.baby_changing_station, Colors.orange, '🧷 尿布', r.typeName));
    for (final r in ds.sleepRecords) items.add(_TimelineItem(r.startTime, Icons.bedtime, Colors.purple, '😴 睡眠', r.isOngoing ? '睡眠中' : r.durationStr ?? ''));
    for (final r in ds.growthRecords) items.add(_TimelineItem(r.date, Icons.straighten, Colors.teal, '📏 成长', '体重: ${r.weightKg ?? "-"}kg'));
    for (final r in ds.milestoneRecords) items.add(_TimelineItem(r.date, Icons.star, Colors.amber, '🌟 ${r.category == "vaccine" ? "疫苗" : r.category == "hospital" ? "就医" : "里程碑"}', r.title));
    for (final r in ds.allSupplementRecords()) items.add(_TimelineItem(r.date, Icons.medication, Colors.green, '💊 补充', r.items.join('、')));
    for (final r in ds.momentRecords) items.add(_TimelineItem(r.date, Icons.photo_library, const Color(0xFFFF6B6B), '📸 动态', r.text.isNotEmpty ? r.text.substring(0, r.text.length > 20 ? 20 : r.text.length) : '[图片]'));
    for (final r in ds.simpleRecords) items.add(_TimelineItem(r.time, Icons.fiber_manual_record, Colors.grey, r.category, r.note));
    for (final r in ds.foodRecords) items.add(_TimelineItem(r.time, Icons.restaurant, const Color(0xFFFF8A80), '🥣 辅食', r.name));
    for (final r in ds.tempRecords) items.add(_TimelineItem(r.time, Icons.thermostat, r.temperature > 37.5 ? Colors.red : Colors.green, '🌡 体温', '${r.temperature}℃'));
    for (final r in ds.milkStorageRecords) items.add(_TimelineItem(r.dateTime, r.type == 'breast' ? Icons.water_drop : Icons.kitchen, r.type == 'breast' ? Colors.blue : Colors.orange, r.typeName, r.displayAmount));
    for (final r in ds.toothRecords) items.add(_TimelineItem(r.foundDate, Icons.egg, Colors.teal, '🦷 牙齿', r.toothName));

    // 按时间排序
    items.sort((a, b) => b.time.compareTo(a.time));

    // 按日期分组
    final grouped = <String, List<_TimelineItem>>{};
    for (final item in items) {
      final key = '${item.time.year}/${item.time.month.toString().padLeft(2,'0')}/${item.time.day.toString().padLeft(2,'0')}';
      if (dateMatch(item.time)) {
        grouped.putIfAbsent(key, () => []).add(item);
      }
    }

    if (grouped.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_selectedDate != null ? '当日无记录' : '暂无记录', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 16)),
        ],
      ));
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DataService>().reloadFromServer();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final dateKey in sortedDates) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(dateKey, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : null)),
            ),
            for (final item in grouped[dateKey]!) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                      ),
                      Container(width: 2, height: 30, color: item.color.withValues(alpha: 0.2)),
                    ]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: isDark ? const Color(0xFF1E1E1E) : null,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(item.icon, color: item.color, size: 16),
                                const SizedBox(width: 4),
                                Text(item.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                                const Spacer(),
                                Text('${item.time.hour.toString().padLeft(2,'0')}:${item.time.minute.toString().padLeft(2,'0')}', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ]),
                              if (item.desc.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(item.desc, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TimelineItem {
  final DateTime time;
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  _TimelineItem(this.time, this.icon, this.color, this.title, this.desc);
}
