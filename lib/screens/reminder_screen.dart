import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_record.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  static const _weekNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  List<ReminderRecord> _reminders = [];
  final _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadReminders();
  }

  Future<void> _initNotifications() async {
    // 请求通知权限（Android 13+）
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    // 初始化时区
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (_) {}
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('reminders');
    if (data != null) {
      final list = jsonDecode(data) as List;
      setState(() => _reminders = list.map((e) => ReminderRecord(
        id: e['id'], type: e['type'], title: e['title'],
        remindTime: DateTime.parse(e['remindTime']),
        repeatDaily: e['repeatDaily'] ?? e['repeat'] ?? true,
        repeatDays: e['repeatDays'] != null ? List<int>.from(e['repeatDays']) : null,
        isActive: e['isActive'] ?? true,
        createdAt: DateTime.parse(e['createdAt']),
      )).toList());
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _reminders.map((r) => {
      'id': r.id, 'type': r.type, 'title': r.title,
      'remindTime': r.remindTime.toIso8601String(),
      'repeatDaily': r.repeatDaily, 'repeatDays': r.repeatDays,
      'isActive': r.isActive,
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();
    await prefs.setString('reminders', jsonEncode(data));
  }

  Future<void> _scheduleNotification(ReminderRecord r) async {
    // 取消所有旧通知
    await _notifications.cancel(int.parse(r.id));
    for (int d = 1; d <= 7; d++) {
      await _notifications.cancel(int.parse('${r.id}_$d'));
    }

    if (!r.isActive) return;

    final now = DateTime.now();
    final hour = r.remindTime.hour;
    final minute = r.remindTime.minute;

    if (r.repeatDaily) {
      // 每天固定时间
      var nextTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (nextTime.isBefore(now)) nextTime = nextTime.add(const Duration(days: 1));
      await _notifications.show(
        int.parse('${r.id}_dbg'), '⏰ 提醒已设置',
        '将在 ${nextTime.hour}:${nextTime.minute.toString().padLeft(2,'0')} 提醒: ${r.title}',
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
      );
      // 每天固定时间提醒
      await _notifications.zonedSchedule(
        int.parse(r.id), r.typeName, r.title,
        tz.TZDateTime.from(nextTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (r.repeatDays != null && r.repeatDays!.isNotEmpty) {
      // 每周指定天
      for (final day in r.repeatDays!) {
        final daysUntil = (day - now.weekday + 7) % 7;
        var nextTime = DateTime(now.year, now.month, now.day, hour, minute)
            .add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
        if (nextTime.isBefore(now)) nextTime = nextTime.add(const Duration(days: 7));
        await _notifications.zonedSchedule(
          int.parse('${r.id}_$day'), r.typeName, '$r.title (${_weekNames[day]})',
          tz.TZDateTime.from(nextTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails('reminders', '提醒',
              channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      // 一次（时间已过则顺延到明天）
      var nextTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (nextTime.isBefore(now)) nextTime = nextTime.add(const Duration(days: 1));
      await _notifications.zonedSchedule(
        int.parse(r.id), r.typeName, r.title,
        tz.TZDateTime.from(nextTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _addReminder() async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const _EditReminderScreen()));
    if (result != null && result is ReminderRecord) {
      _reminders.insert(0, result);
      await _saveReminders();
      // 立即弹一条通知（确认功能正常）
      _notifications.show(
        int.parse(result.id), result.typeName, result.title,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
      );
      _scheduleNotification(result);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 已添加提醒'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  void _editReminder(int index) async {
    final r = _reminders[index];
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => _EditReminderScreen(initial: r)));
    if (result != null && result is ReminderRecord) {
      _reminders[index] = result;
      await _saveReminders();
      _scheduleNotification(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 已更新'), duration: Duration(seconds: 1)),
        );
      }
      setState(() {});
    }
  }

  void _toggleReminder(int index) async {
    final r = _reminders[index];
    _reminders[index] = r.copyWith(isActive: !r.isActive);
    await _saveReminders();
    await _scheduleNotification(_reminders[index]);
    setState(() {});
  }

  Future<void> _deleteReminder(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认删除'),
        content: const Text('确定要删除这条提醒吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
        ],
      ),
    );
    if (confirm == true && index < _reminders.length) {
      final r = _reminders[index];
      final id = int.parse(r.id);
      _notifications.cancel(id);
      for (int d = 1; d <= 7; d++) {
        _notifications.cancel(int.parse('$id$d'));
      }
      _reminders.removeAt(index);
      await _saveReminders();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 已删除'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    await _notifications.show(
      99999,
      '🔔 测试通知',
      '如果看到这条通知，说明通知功能正常',
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', '提醒',
          channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 测试通知已发送，请查看通知栏'), duration: Duration(seconds: 3)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: _reminders.isEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_outlined, size: 64,
                    color: isDark ? Colors.white24 : Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('暂无提醒', style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 16)),
                const SizedBox(height: 4),
                Text('点击右下角添加', style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey.shade300, fontSize: 14)),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('测试通知'),
                ),
              ],
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (ctx, i) {
                final r = _reminders[i];
                return Card(
                  color: isDark ? const Color(0xFF1E1E1E) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        Switch(
                          value: r.isActive,
                          onChanged: (v) => _toggleReminder(i),
                          activeColor: const Color(0xFF6C63FF),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _editReminder(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${r.typeName}: ${r.title}',
                                      style: TextStyle(color: isDark ? Colors.white : null)),
                                  Text(
                                    '${r.remindTime.hour.toString().padLeft(2,'0')}:${r.remindTime.minute.toString().padLeft(2,'0')} (${r.repeatLabel})',
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                          onPressed: () => _deleteReminder(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ====== 添加/编辑提醒 ======
class _EditReminderScreen extends StatefulWidget {
  final ReminderRecord? initial;
  const _EditReminderScreen({this.initial});

  @override
  State<_EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<_EditReminderScreen> {
  late String _type;
  late TextEditingController _titleController;
  late TimeOfDay _time;
  late bool _repeatDaily;
  late List<int> _repeatDays;
  bool _showWeekly = false;

  static const _weekNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _type = r?.type ?? 'custom';
    _titleController = TextEditingController(text: r?.title ?? '');
    _time = r != null ? TimeOfDay.fromDateTime(r.remindTime) : TimeOfDay.now();
    _repeatDaily = r?.repeatDaily ?? true;
    _repeatDays = r?.repeatDays?.toList() ?? [];
    _showWeekly = r != null && !r.repeatDaily && (r.repeatDays?.isNotEmpty ?? false);
  }

  static const _types = [
    ('feeding', '🍼', '喂奶'),
    ('diaper', '🧷', '换尿布'),
    ('medicine', '💊', '用药'),
    ('water', '🥤', '喝水'),
    ('custom', '📝', '自定义'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加提醒'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : null,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('提醒类型', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _types.map((t) => ChoiceChip(
                        label: Text('${t.$1} ${t.$3}'),
                        selected: _type == t.$1,
                        onSelected: (v) => setState(() => _type = t.$1),
                        selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '提醒内容',
                        hintText: '例如：该喂奶了',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF) : const Color(0xFFD4C5B5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF6C63FF).withValues(alpha: 0.5) : const Color(0xFFD4C5B5)),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                      title: Text('提醒时间', style: TextStyle(color: isDark ? Colors.white : null)),
                      trailing: TextButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: _time);
                          if (t != null) setState(() => _time = t);
                        },
                        child: Text(
                          '${_time.hour.toString().padLeft(2,'0')}:${_time.minute.toString().padLeft(2,'0')}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('重复方式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : null)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('每天'),
                          selected: _repeatDaily,
                          onSelected: (v) => setState(() { _repeatDaily = true; _showWeekly = false; }),
                          selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        ),
                        ChoiceChip(
                          label: const Text('每周'),
                          selected: _showWeekly,
                          onSelected: (v) => setState(() { _repeatDaily = false; _showWeekly = v; }),
                          selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        ),
                        ChoiceChip(
                          label: const Text('一次'),
                          selected: !_repeatDaily && !_showWeekly,
                          onSelected: (v) => setState(() { _repeatDaily = false; _showWeekly = false; }),
                          selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    if (_showWeekly) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final selected = _repeatDays.contains(day);
                          return FilterChip(
                            label: Text(_weekNames[day], style: TextStyle(fontSize: 13, color: isDark ? Colors.white : null)),
                            selected: selected,
                            onSelected: (v) => setState(() {
                              if (v) { _repeatDays.add(day); }
                              else { _repeatDays.remove(day); }
                            }),
                            selectedColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (_titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入提醒内容')),
                            );
                            return;
                          }
                          final now = DateTime.now();
                          final remindTime = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
                          Navigator.pop(context, ReminderRecord(
                            type: _type,
                            title: _titleController.text.trim(),
                            remindTime: remindTime,
                            repeatDaily: _repeatDaily,
                            repeatDays: _repeatDaily ? null : (_showWeekly ? _repeatDays.toList() : null),
                          ));
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('添加提醒'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
