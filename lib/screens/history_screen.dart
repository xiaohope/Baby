import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/simple_record.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  static const _tabs = [
    _TabInfo('喂奶', Icons.local_drink, Color(0xFF6C63FF)),
    _TabInfo('尿布', Icons.baby_changing_station, Color(0xFFFF8A80)),
    _TabInfo('睡眠', Icons.bedtime, Color(0xFFD4A5FF)),
    _TabInfo('成长', Icons.straighten, Color(0xFFA8E6CF)),
    _TabInfo('补充', Icons.medication, Color(0xFF81C9D6)),
    _TabInfo('里程碑', Icons.star, Color(0xFFFFB347)),
    _TabInfo('动态', Icons.photo_library, Color(0xFFFF6B6B)),
    _TabInfo('尿急', Icons.water_drop, Color(0xFF4A90D9)),
    _TabInfo('粑粑', Icons.report, Color(0xFF8B5E3C)),
    _TabInfo('用药', Icons.medication, Color(0xFFE74C3C)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) => '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
  String _fmtTime(DateTime t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 16),
                  const SizedBox(width: 4),
                  Text(t.label),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _selectedDate = d);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _fmtDate(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedingHistory(),
                  _buildDiaperHistory(),
                  _buildSleepHistory(),
                  _buildGrowthHistory(),
                  _buildSupplementHistory(),
                  _buildMilestoneHistory(),
                  _buildMomentHistory(),
                  _buildSimpleHistory('pee', '尿急', Icons.water_drop, const Color(0xFF4A90D9), '💦'),
                  _buildSimpleHistory('poop', '粑粑', Icons.report, const Color(0xFF8B5E3C), '💩'),
                  _buildSimpleHistory('medication', '用药', Icons.medication, const Color(0xFFE74C3C), '💊'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  // ---- 喂奶 ----
  Widget _buildFeedingHistory() {
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.where((r) => _isSameDay(r.time, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.local_drink, '当日无喂奶记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.local_drink, color: Colors.blue,
        title: r.typeName,
        subtitle: '${_fmtTime(r.time)}  ${r.displayAmount}',
        onDelete: () => ds.deleteFeeding(r.id),
      );
    });
  }

  // ---- 尿布 ----
  Widget _buildDiaperHistory() {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.where((r) => _isSameDay(r.time, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.baby_changing_station, '当日无尿布记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.baby_changing_station, color: Colors.orange,
        title: r.typeName,
        subtitle: '${_fmtTime(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}',
        onDelete: () => ds.deleteDiaper(r.id),
      );
    });
  }

  // ---- 睡眠 ----
  Widget _buildSleepHistory() {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((r) => _isSameDay(r.startTime, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.bedtime, '当日无睡眠记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.bedtime, color: Colors.purple,
        title: r.isOngoing ? '睡眠中' : '睡眠',
        subtitle: '${_fmtTime(r.startTime)}${r.endTime != null ? ' - ${_fmtTime(r.endTime!)}' : ''}  ${r.durationStr}',
        onDelete: () => ds.deleteSleep(r.id),
      );
    });
  }

  // ---- 成长 ----
  Widget _buildGrowthHistory() {
    final ds = context.watch<DataService>();
    final records = ds.growthRecords.where((r) => _isSameDay(r.date, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.straighten, '当日无成长记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.straighten, color: Colors.teal,
        title: '${r.date.month}/${r.date.day}',
        subtitle: [
          if (r.weightKg != null) '体重: ${r.weightKg}kg',
          if (r.heightCm != null) '身长: ${r.heightCm}cm',
          if (r.headCircumferenceCm != null) '头围: ${r.headCircumferenceCm}cm',
        ].join('  '),
        onDelete: () => ds.deleteGrowth(r.id),
      );
    });
  }

  // ---- 营养补充 ----
  Widget _buildSupplementHistory() {
    final ds = context.watch<DataService>();
    final records = ds.allSupplementRecords().where((r) => _isSameDay(r.date, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.medication, '当日无补充记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.medication, color: Colors.green,
        title: '${r.date.month}月${r.date.day}日',
        subtitle: r.items.join('、'),
        onDelete: () => ds.deleteSupplement(r.id),
      );
    });
  }

  // ---- 里程碑 ----
  Widget _buildMilestoneHistory() {
    final ds = context.watch<DataService>();
    final records = ds.milestoneRecords.where((r) => _isSameDay(r.date, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.star, '当日无里程碑记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      final emoji = r.category == 'hospital' ? '🏥' : (r.category == 'vaccine' ? '💉' : '🌟');
      return _card(
        icon: Icons.star, color: Colors.amber,
        title: '$emoji ${r.title}',
        subtitle: '${r.date.month}/${r.date.day}${r.note != null ? '  ${r.note}' : ''}',
        onDelete: () => ds.deleteMilestone(r.id),
      );
    });
  }

  // ---- 动态 ----
  Widget _buildMomentHistory() {
    final ds = context.watch<DataService>();
    final records = ds.momentRecords.where((r) => _isSameDay(r.date, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(Icons.photo_library, '当日无动态');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: Icons.photo_library, color: const Color(0xFFFF6B6B),
        title: r.text.isNotEmpty ? r.text : '[图片]',
        subtitle: '${_fmtTime(r.date)}${r.imagePaths.isNotEmpty ? '  📸${r.imagePaths.length}张' : ''}',
        onDelete: () => ds.deleteMoment(r.id),
      );
    });
  }

  // ---- 通用记录（尿急/粑粑/用药） ----
  Widget _buildSimpleHistory(String category, String label, IconData icon, Color color, String emoji) {
    final ds = context.watch<DataService>();
    final records = ds.simpleRecordsByCategory(category).where((r) => _isSameDay(r.time, _selectedDate)).toList();
    if (records.isEmpty) return _emptyHint(icon, '当日无${label}记录');
    return _buildList(records.length, (ctx, i) {
      final r = records[i];
      return _card(
        icon: icon, color: color,
        title: '$emoji $label',
        subtitle: '${_fmtTime(r.time)}${r.note.isNotEmpty ? '  ${r.note}' : ''}',
        onDelete: () => ds.deleteSimpleRecord(r.id),
      );
    });
  }

  // ====== 通用组件 ======
  Widget _emptyHint(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildList(int itemCount, Widget Function(BuildContext, int) builder) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: builder,
    );
  }

  Widget _card({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: onDelete,
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
