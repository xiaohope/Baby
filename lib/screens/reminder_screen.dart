import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_record.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<ReminderRecord> _reminders = [];
  final _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadReminders();
  }

  Future<void> _initNotifications() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    // 初始化时区
    try {
      tz.initializeTimeZones();
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
        repeat: e['repeat'] ?? true,
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
      'repeat': r.repeat, 'isActive': r.isActive,
      'createdAt': r.createdAt.toIso8601String(),
    }).toList();
    await prefs.setString('reminders', jsonEncode(data));
  }

  Future<void> _scheduleNotification(ReminderRecord r) async {
    await _notifications.cancel(int.parse(r.id));

    if (!r.isActive) return;

    final now = DateTime.now();
    var nextTime = DateTime(now.year, now.month, now.day,
        r.remindTime.hour, r.remindTime.minute);
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    if (r.repeat) {
      await _notifications.periodicallyShow(
        int.parse(r.id), r.typeName, r.title,
        RepeatInterval.daily,
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _notifications.zonedSchedule(
        int.parse(r.id), r.typeName, r.title,
        tz.TZDateTime.from(nextTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails('reminders', '提醒',
            channelDescription: '定时提醒通知', importance: Importance.high, priority: Priority.high),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  void _addReminder() async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const _EditReminderScreen()));
    if (result != null && result is ReminderRecord) {
      _reminders.add(result);
      await _saveReminders();
      await _scheduleNotification(result);
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

  void _deleteReminder(int index) async {
    final r = _reminders[index];
    await _notifications.cancel(int.parse(r.id));
    _reminders.removeAt(index);
    await _saveReminders();
    setState(() {});
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
              ],
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (ctx, i) {
                final r = _reminders[i];
                return Card(
                  color: isDark ? const Color(0xFF1E1E1E) : null,
                  child: ListTile(
                    leading: Switch(
                      value: r.isActive,
                      onChanged: (_) => _toggleReminder(i),
                      activeColor: const Color(0xFF6C63FF),
                    ),
                    title: Text('${r.typeName}: ${r.title}',
                        style: TextStyle(color: isDark ? Colors.white : null)),
                    subtitle: Text(
                      '${r.remindTime.hour.toString().padLeft(2,'0')}:${r.remindTime.minute.toString().padLeft(2,'0')}${r.repeat ? ' (每天)' : ''}',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _deleteReminder(i),
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
  const _EditReminderScreen();

  @override
  State<_EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<_EditReminderScreen> {
  String _type = 'custom';
  final _titleController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  bool _repeat = true;

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
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('每天重复', style: TextStyle(color: isDark ? Colors.white : null)),
                      value: _repeat,
                      onChanged: (v) => setState(() => _repeat = v),
                      activeColor: const Color(0xFF6C63FF),
                    ),
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
                            repeat: _repeat,
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
