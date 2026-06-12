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
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
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
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F0FF),
            Color(0xFFFFF5EE),
            Color(0xFFF0F8FF),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBabyCard(ds, size),
              const SizedBox(height: 20),
              _buildTodayStats(stats),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentSection('🍼 最近喂奶', ds.todayFeedings().take(3).toList(), context),
              const SizedBox(height: 12),
              _buildRecentSection('🧷 最近换尿布', ds.todayDiapers().take(3).toList(), context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ====== 👶 宝宝信息卡片 ======
  Widget _buildBabyCard(DataService ds, Size size) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 宝宝头像
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          // 名字 + 年龄
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ds.babyName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (ds.babyBirthday != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '👶 ${_calcAge(ds.babyBirthday!)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          // 编辑按钮
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== 📊 今日概览 ======
  Widget _buildTodayStats(Map stats) {
    final items = [
      _StatItem(
        label: '喂奶',
        value: '${stats['feedingCount'] ?? 0}次',
        icon: Icons.local_drink,
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)]),
      ),
      _StatItem(
        label: '奶量',
        value: '${stats['totalBottleMl'] ?? 0}ml',
        icon: Icons.water_drop,
        gradient: const LinearGradient(colors: [Color(0xFF81C9D6), Color(0xFFA8E6CF)]),
      ),
      _StatItem(
        label: '尿布',
        value: '${stats['diaperCount'] ?? 0}次',
        icon: Icons.baby_changing_station,
        gradient: const LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF8A80)]),
      ),
      _StatItem(
        label: '睡眠',
        value: _formatSleep(stats['totalSleepMinutes'] ?? 0),
        icon: Icons.bedtime,
        gradient: const LinearGradient(colors: [Color(0xFFD4A5FF), Color(0xFF6C63FF)]),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('今日概况', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildStatCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: item.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item.gradient.colors[0].withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
          const Spacer(),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ====== ✨ 快捷入口 ======
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(emoji: '🍼', label: '喂奶', icon: Icons.local_drink, color: const Color(0xFF6C63FF), screen: const FeedingScreen()),
      _QuickAction(emoji: '🧷', label: '尿布', icon: Icons.baby_changing_station, color: const Color(0xFFFF8A80), screen: const DiaperScreen()),
      _QuickAction(emoji: '💊', label: '补充', icon: Icons.medication, color: const Color(0xFF81C9D6), screen: const SupplementScreen()),
      _QuickAction(emoji: '😴', label: '睡眠', icon: Icons.bedtime, color: const Color(0xFFD4A5FF), screen: const SleepScreen()),
      _QuickAction(emoji: '📏', label: '成长', icon: Icons.straighten, color: const Color(0xFFA8E6CF), screen: const GrowthScreen()),
      _QuickAction(emoji: '🌟', label: '里程碑', icon: Icons.star, color: const Color(0xFFFFB347), screen: const MilestoneScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('快捷记录', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((a) => _buildActionCard(a)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => action.screen),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color,
                        action.color.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: action.color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(action.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: action.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====== 📅 近期记录 ======
  Widget _buildRecentSection(String title, List records, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              if (records.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 18, color: Colors.grey.shade300),
                        const SizedBox(width: 6),
                        Text('今日暂无记录', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                ...records.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final isLast = i == records.length - 1;
                  final color = r is FeedingRecord
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFFFF8A80);
                  return _buildTimelineItem(r, color, isLast);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(dynamic r, Color color, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线竖线 + 圆点
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 记录内容
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.typeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_fmtTime(r.time)}  ${r.displayAmount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r is FeedingRecord ? '🍼' : '🧷',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== 工具方法 ======
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

// ====== 辅助数据类 ======
class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });
}

class _QuickAction {
  final String emoji;
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;
  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
