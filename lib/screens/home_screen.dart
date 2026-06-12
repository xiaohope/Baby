import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/feeding_record.dart';
import 'feeding_screen.dart';
import 'diaper_screen.dart';
import 'supplement_screen.dart';
import 'sleep_screen.dart';
import 'growth_screen.dart';
import 'milestone_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final stats = ds.todayStats();
    final ongoingSleep = ds.ongoingSleep;
    final supplement = ds.todaySupplement();

    final screens = [
      _buildMainPage(ds, stats, ongoingSleep, supplement),
      const HistoryScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF0FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        surfaceTintColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: '历史'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '统计'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildMainPage(DataService ds, Map stats, dynamic ongoingSleep, dynamic supplement) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👶 宝宝信息栏（卡通风格）
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.child_care, color: Color(0xFF4A90E2), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ds.babyName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          if (ds.babyBirthday != null)
                            Text(
                              _calcAge(ds.babyBirthday!),
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📊 今日概览（横向滚动）
            Text('今日概况', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final items = [
                    {'label': '喂奶', 'value': '${stats['feedingCount'] ?? 0}次', 'icon': Icons.local_drink_outlined, 'color': Colors.blue},
                    {'label': '奶量', 'value': '${stats['totalBottleMl'] ?? 0}ml', 'icon': Icons.water_drop, 'color': Colors.cyan},
                    {'label': '换尿布', 'value': '${stats['diaperCount'] ?? 0}次', 'icon': Icons.baby_changing_station, 'color': Colors.orange},
                    {'label': '睡眠', 'value': _formatSleep(stats['totalSleepMinutes'] ?? 0), 'icon': Icons.bedtime, 'color': Colors.purple},
                  ];
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(item['icon'], color: item['color'] as Color, size: 28),
                          const SizedBox(height: 8),
                          Text(item['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(item['label'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ✨ 快捷入口（大图标按钮）
            Text('快捷记录', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickButton('🍼 喂奶', Icons.local_drink, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedingScreen()))),
                _quickButton('🧷 换尿布', Icons.baby_changing_station, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaperScreen()))),
                _quickButton('💊 营养补充', Icons.medication, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplementScreen()))),
                _quickButton('😴 睡眠', Icons.bedtime, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()))),
                _quickButton('📏 身高体重', Icons.straighten, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowthScreen()))),
                _quickButton('🌟 里程碑', Icons.star, Colors.amber, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestoneScreen()))),
              ],
            ),
            const SizedBox(height: 16),

            // 📅 近期记录（时间轴样式）
            _buildRecentSection('最近喂奶', ds.todayFeedings().take(3).toList(), context),
            const SizedBox(height: 12),
            _buildRecentSection('最近换尿布', ds.todayDiapers().take(3).toList(), context),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 120,
      height: 120,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label.split(' ')[1], style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection(String title, List records, BuildContext context) {
    if (records.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('今日暂无记录', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...records.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: r is FeedingRecord ? Colors.blue : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.typeName, style: const TextStyle(fontSize: 14)),
                            Text(
                              '${_fmtTime(r.time)}  ${r.displayAmount}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _calcAge(DateTime birthday) {
    final now = DateTime.now();
    int months = (now.year - birthday.year) * 12 + now.month - birthday.month;
    if (now.day < birthday.day) months--;
    if (months < 0) return '';
    final years = months ~/ 12;
    final m = months % 12;
    if (years == 0) return '$m个月';
    if (m == 0) return '$years岁';
    return '$years岁${m}个月';
  }

  String _formatSleep(int minutes) {
    if (minutes == 0) return '0分钟';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}小时${m}分钟' : '${m}分钟';
  }

  String _fmtTime(DateTime t) {
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }
}