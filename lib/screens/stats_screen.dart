import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';


class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatSleep(int minutes) {
    if (minutes == 0) return '0分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}小时${m}分钟' : '${m}分钟';
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}小时${m}分钟';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final stats = ds.todayStats();

    final feedingCount = stats['feedingCount'] ?? 0;
    final totalBottleMl = stats['totalBottleMl'] ?? 0;
    final diaperCount = stats['diaperCount'] ?? 0;
    final peeSimpleCount = stats['peeSimpleCount'] ?? 0;
    final poopSimpleCount = stats['poopSimpleCount'] ?? 0;
    final medCount = stats['medCount'] ?? 0;
    final waterCount = stats['waterCount'] ?? 0;
    final foodCount = stats['foodCount'] ?? 0;
    final tempCount = stats['tempCount'] ?? 0;
    final bathCount = stats['bathCount'] ?? 0;
    final vaccineCount = stats['vaccineCount'] ?? 0;
    final totalSleepMinutes = stats['totalSleepMinutes'] ?? 0;
    final totalBreastMinutes = stats['totalBreastMinutes'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DataService>().reloadFromServer();
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
        },
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 今日概况 ======
          Text('今日概况', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(children: [
                    _statCard('喂奶', '$feedingCount次', Icons.local_drink, const Color(0xFF6C63FF)),
                    _statCard('奶量', '${totalBottleMl}ml', Icons.water_drop, const Color(0xFF81C9D6)),
                    _statCard('尿布', '$diaperCount次', Icons.baby_changing_station, const Color(0xFFFF8A80)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _statCard('睡眠', _formatSleep(totalSleepMinutes), Icons.bedtime, const Color(0xFFD4A5FF)),
                    _statCard('母乳', '$totalBreastMinutes分', Icons.child_care, const Color(0xFFFF6B6B)),
                    _statCard('尿尿', '$peeSimpleCount次', Icons.water_drop, const Color(0xFF4A90D9)),
                    _statCard('喝水', '$waterCount次', Icons.local_drink, const Color(0xFF3498DB)),
                    _statCard('辅食', '$foodCount次', Icons.restaurant, const Color(0xFFFF8A80)),
                    _statCard('体温', '$tempCount次', Icons.thermostat, const Color(0xFFE74C3C)),
                    _statCard('洗澡', '$bathCount次', Icons.bathroom, const Color(0xFF81C9D6)),
                    _statCard('疫苗', '$vaccineCount次', Icons.vaccines, const Color(0xFF27AE60)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _statCard('粑粑', '$poopSimpleCount次', Icons.report, const Color(0xFF8B5E3C)),
                    _statCard('用药', '$medCount次', Icons.medication, const Color(0xFFE74C3C)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ====== 近7天喂奶趋势 ======
          _buildWeekChart(
            title: '近7天喂奶趋势',
            getData: (d) => ds.feedingRecords.where((r) => _isSameDay(r.time, d)).length,
            color: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 24),

          // ====== 近7天尿布趋势 ======
          _buildWeekChart(
            title: '近7天尿布趋势',
            getData: (d) => ds.diaperRecords.where((r) => _isSameDay(r.time, d)).length,
            color: const Color(0xFFFF8A80),
          ),
          const SizedBox(height: 24),

          // ====== 近7天睡眠趋势 ======
          _buildWeekChart(
            title: '近7天睡眠时长趋势',
            getData: (d) {
              int totalMin = 0;
              for (final s in ds.sleepRecords.where((r) => _isSameDay(r.startTime, d))) {
                if (s.duration != null) totalMin += s.duration!.inMinutes;
              }
              return totalMin ~/ 60; // 显示小时
            },
            color: const Color(0xFFD4A5FF),
            unit: '小时',
          ),
          const SizedBox(height: 24),

          // ====== 近7天尿急/粑粑/用药趋势 ======
          _buildSimpleWeekChart(ds),
          const SizedBox(height: 24),

          // ====== 间隔分析 ======
          _buildIntervalSection(
            title: '喂奶间隔分析',
            intervals: ds.getIntervals('feeding'),
            color: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 16),
          _buildIntervalSection(
            title: '换尿布间隔分析',
            intervals: ds.getIntervals('diaper'),
            color: const Color(0xFFFF8A80),
          ),
          const SizedBox(height: 24),

          // ====== 本周汇总 ======
          _buildWeekSummary(ds, context),
          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }

  // ====== 组件 ======
  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWeekChart({
    required String title,
    required int Function(DateTime) getData,
    required Color color,
    String unit = '次',
  }) {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final data = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return {'label': weekdays[d.weekday % 7], 'count': getData(d)};
    });
    final maxVal = data.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal + 2).toDouble().clamp(4, double.infinity),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: (e.value['count'] as int).toDouble(),
                      color: color,
                      width: 24,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      fromY: 0,
                    ),
                  ]);
                }).toList(),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 30,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}$unit', style: const TextStyle(fontSize: 10)),
                  )),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(data[v.toInt()]['label'] as String, style: const TextStyle(fontSize: 10)),
                  )),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                    '${data[g.x]['label']}\n${rod.toY.toInt()}$unit',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )),
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleWeekChart(DataService ds) {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    final peeData = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ds.simpleRecordsByCategory('pee').where((r) => _isSameDay(r.time, d)).length;
    });
    final poopData = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ds.simpleRecordsByCategory('poop').where((r) => _isSameDay(r.time, d)).length;
    });
    final medData = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ds.simpleRecordsByCategory('medication').where((r) => _isSameDay(r.time, d)).length;
    });
    final waterData = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ds.simpleRecordsByCategory('water').where((r) => _isSameDay(r.time, d)).length;
    });

    final allMax = [...peeData, ...poopData, ...medData, ...waterData].fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('近7天尿尿/粑粑/用药/喝水趋势', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (allMax + 2).toDouble().clamp(3, double.infinity),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: peeData[i].toDouble(), color: const Color(0xFF4A90D9), width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), fromY: 0),
                    BarChartRodData(toY: poopData[i].toDouble(), color: const Color(0xFF8B5E3C), width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), fromY: 0),
                    BarChartRodData(toY: medData[i].toDouble(), color: const Color(0xFFE74C3C), width: 6, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), fromY: 0),
                    BarChartRodData(toY: waterData[i].toDouble(), color: const Color(0xFF3498DB), width: 6, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), fromY: 0),
                  ]);
                }),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(weekdays[v.toInt()], style: const TextStyle(fontSize: 9)))),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (g, gi, rod, ri) {
                    final labels = ['尿尿', '粑粑', '用药', '喝水'];
                    return BarTooltipItem('${weekdays[g.x]}\n${labels[ri]}: ${rod.toY.toInt()}次', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                  },
                )),
              )),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend('尿尿', const Color(0xFF4A90D9)),
            const SizedBox(width: 16),
            _legend('粑粑', const Color(0xFF8B5E3C)),
            const SizedBox(width: 16),
            _legend('用药', const Color(0xFFE74C3C)),
            const SizedBox(width: 16),
            _legend('喝水', const Color(0xFF3498DB)),
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildIntervalSection({required String title, required List<Map<String, dynamic>> intervals, required Color color}) {
    if (intervals.isEmpty) return const SizedBox.shrink();
    final avg = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a + b) ~/ intervals.length;
    final minVal = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a < b ? a : b);
    final maxVal = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        _statCard('平均', _formatInterval(avg), Icons.timelapse, color),
        _statCard('最短', _formatInterval(minVal), Icons.speed, Colors.green),
        _statCard('最长', _formatInterval(maxVal), Icons.slow_motion_video, Colors.red),
      ]))),
    ]);
  }

  Widget _buildWeekSummary(DataService ds, BuildContext context) {
    final now = DateTime.now();
    int totalFeeding = 0, totalDiaper = 0, totalPee = 0, totalPoop = 0, totalMed = 0, totalWater = 0, totalFood = 0, totalTemp = 0, totalBath = 0, totalVaccine = 0, totalSleepH = 0;
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      totalFeeding += ds.feedingRecords.where((r) => _isSameDay(r.time, d)).length;
      totalDiaper += ds.diaperRecords.where((r) => _isSameDay(r.time, d)).length;
      totalPee += ds.simpleRecordsByCategory('pee').where((r) => _isSameDay(r.time, d)).length;
      totalPoop += ds.simpleRecordsByCategory('poop').where((r) => _isSameDay(r.time, d)).length;
      totalMed += ds.simpleRecordsByCategory('medication').where((r) => _isSameDay(r.time, d)).length;
      totalWater += ds.simpleRecordsByCategory('water').where((r) => _isSameDay(r.time, d)).length;
      totalFood += ds.foodRecords.where((r) => _isSameDay(r.time, d)).length;
      totalTemp += ds.tempRecords.where((r) => _isSameDay(r.time, d)).length;
      totalBath += ds.simpleRecordsByCategory('bath').where((r) => _isSameDay(r.time, d)).length;
      totalVaccine += ds.milestoneRecords.where((r) => _isSameDay(r.date, d) && r.category == 'vaccine').length;
      for (final s in ds.sleepRecords.where((r) => _isSameDay(r.startTime, d))) {
        if (s.duration != null) totalSleepH += s.duration!.inHours;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('本周汇总', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          _statCard('喂奶', '${totalFeeding}次', Icons.local_drink, const Color(0xFF6C63FF)),
          _statCard('尿布', '${totalDiaper}次', Icons.baby_changing_station, const Color(0xFFFF8A80)),
          _statCard('睡眠', '${totalSleepH}小时', Icons.bedtime, const Color(0xFFD4A5FF)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _statCard('尿尿', '${totalPee}次', Icons.water_drop, const Color(0xFF4A90D9)),
          _statCard('粑粑', '${totalPoop}次', Icons.report, const Color(0xFF8B5E3C)),
          _statCard('用药', '${totalMed}次', Icons.medication, const Color(0xFFE74C3C)),
          _statCard('喝水', '${totalWater}次', Icons.local_drink, const Color(0xFF3498DB)),
          _statCard('辅食', '${totalFood}次', Icons.restaurant, const Color(0xFFFF8A80)),
          _statCard('体温', '${totalTemp}次', Icons.thermostat, const Color(0xFFE74C3C)),
          _statCard('洗澡', '${totalBath}次', Icons.bathroom, const Color(0xFF81C9D6)),
          _statCard('疫苗', '${totalVaccine}次', Icons.vaccines, const Color(0xFF27AE60)),
        ]),
      ]))),
    ]);
  }
}
