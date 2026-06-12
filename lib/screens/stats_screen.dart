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

  List<Map> _getWeekData(DataService ds, String type) {
    final now = DateTime.now();
    final result = <Map>[];
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      int count = 0;
      if (type == 'feeding') {
        count = ds.feedingRecords.where((r) => r.time.year == d.year && r.time.month == d.month && r.time.day == d.day).length;
      } else {
        count = ds.diaperRecords.where((r) => r.time.year == d.year && r.time.month == d.month && r.time.day == d.day).length;
      }
      result.add({'label': weekdays[d.weekday % 7], 'count': count, 'date': d});
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final stats = ds.todayStats();
    final weekFeedings = _getWeekData(ds, 'feeding');
    final weekDiapers = _getWeekData(ds, 'diaper');

    final feedingCount = stats['feedingCount'] ?? 0;
    final totalBottleMl = stats['totalBottleMl'] ?? 0;
    final diaperCount = stats['diaperCount'] ?? 0;
    final peeCount = stats['peeCount'] ?? 0;
    final poopCount = stats['poopCount'] ?? 0;
    final totalSleepMinutes = stats['totalSleepMinutes'] ?? 0;
    final totalBreastMinutes = stats['totalBreastMinutes'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 今日概况
          Text('今日概况', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard('喂奶次数', '$feedingCount次', Icons.local_drink, Colors.blue),
                      _statCard('总奶量', '${totalBottleMl}ml', Icons.water_drop, Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard('换尿布', '$diaperCount次', Icons.baby_changing_station, Colors.orange),
                      _statCard('便/尿', '$peeCount/$poopCount', Icons.show_chart, Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statCard('睡眠总长', _formatSleep(totalSleepMinutes), Icons.bedtime, Colors.purple),
                      _statCard('母乳时长', '$totalBreastMinutes分钟', Icons.child_care, Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 近7天喂奶趋势（渐变柱状图）
          Text('近7天喂奶趋势', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (weekFeedings.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                    barGroups: weekFeedings.asMap().entries.map((e) {
                      final count = e.value['count'] as int;
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: Colors.blue,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          // 渐变效果（从蓝到浅蓝）
                          fromY: 0,
                        ),
                      ]);
                    }).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            weekFeedings[v.toInt()]['label'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${weekFeedings[group.x]['label']}\n${rod.toY.toInt()}次',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 近7天换尿布趋势（渐变柱状图）
          Text('近7天换尿布趋势', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (weekDiapers.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                    barGroups: weekDiapers.asMap().entries.map((e) {
                      return BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(
                          toY: e.value['count']!.toDouble(),
                          color: Colors.orange,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          fromY: 0,
                        ),
                      ]);
                    }).toList(),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Text(
                            weekDiapers[v.toInt()]['label'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${weekDiapers[group.x]['label']}\n${rod.toY.toInt()}次',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 间隔分析
          _buildIntervalSection(
            title: '喂奶间隔分析',
            intervals: ds.getIntervals('feeding'),
            iconColor: Colors.blue,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildIntervalSection(
            title: '换尿布间隔分析',
            intervals: ds.getIntervals('diaper'),
            iconColor: Colors.orange,
            context: context,
          ),
          const SizedBox(height: 16),

          // 本周汇总
          _buildWeekSummary(ds, context),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIntervalSection({
    required String title,
    required List<Map<String, dynamic>> intervals,
    required Color iconColor,
    required BuildContext context,
  }) {
    if (intervals.isEmpty) return const SizedBox.shrink();

    final avg = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a + b) ~/ intervals.length;
    final minVal = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a < b ? a : b);
    final maxVal = intervals.map((e) => e['minutes'] as int).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _statCard('平均', _formatInterval(avg), Icons.timelapse, iconColor),
                _statCard('最短', _formatInterval(minVal), Icons.speed, Colors.green),
                _statCard('最长', _formatInterval(maxVal), Icons.slow_motion_video, Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSummary(DataService ds, BuildContext context) {
    final freqStats = ds.getFrequencyStats();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('本周汇总', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _statCard('日均喂奶', '${freqStats['avgFeedingPerDay']}次', Icons.local_drink, Colors.blue),
                    _statCard('本周喂奶', '${freqStats['totalFeeding']}次', Icons.calendar_today, Colors.cyan),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statCard('日均尿布', '${freqStats['avgDiaperPerDay']}次', Icons.baby_changing_station, Colors.orange),
                    _statCard('本周尿布', '${freqStats['totalDiaper']}次', Icons.calendar_today, Colors.amber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}