import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_record.dart';
import '../services/data_service.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> with WidgetsBindingObserver {
  FeedingType _selectedType = FeedingType.breastDirect;
  final _minutesController = TextEditingController();
  final _mlController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isTimerRunning = false;
  int _breastSeconds = 0;
  BreastSide _currentSide = BreastSide.left;
  bool _left15minAlerted = false;
  bool _right15minAlerted = false;
  bool _useManualInput = false;
  DateTime _recordTime = DateTime.now();

  DateTime? _timerStartTime;
  static const String _timerStartKey = 'feeding_timer_start';
  static const String _timerSideKey = 'feeding_timer_side';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
    _restoreTimerState();
  }

  Future<void> _initNotifications() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString(_timerStartKey);
    final sideStr = prefs.getString(_timerSideKey);
    
    if (startTimeStr != null) {
      final startTime = DateTime.parse(startTimeStr);
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed < 3600) {
        setState(() {
          _breastSeconds = elapsed;
          _isTimerRunning = true;
          _currentSide = sideStr == 'right' ? BreastSide.right : BreastSide.left;
          _check15MinAlert();
        });
      }
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isTimerRunning && _timerStartTime != null) {
      await prefs.setString(_timerStartKey, _timerStartTime!.toIso8601String());
      await prefs.setString(_timerSideKey, _currentSide == BreastSide.right ? 'right' : 'left');
    } else {
      await prefs.remove(_timerStartKey);
      await prefs.remove(_timerSideKey);
    }
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timerStartKey);
    await prefs.remove(_timerSideKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minutesController.dispose();
    _mlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreTimerState();
    } else if (state == AppLifecycleState.paused) {
      _saveTimerState();
    }
  }

  void _check15MinAlert() {
    const alertSeconds = 15 * 60;
    
    if (_currentSide == BreastSide.left && _breastSeconds >= alertSeconds && !_left15minAlerted) {
      _left15minAlerted = true;
      _showNotification('左侧母乳喂养已达到 15 分钟', '是时候换到右侧了');
    } else if (_currentSide == BreastSide.right && _breastSeconds >= alertSeconds && !_right15minAlerted) {
      _right15minAlerted = true;
      _showNotification('右侧母乳喂养已达到 15 分钟', '喂养完成');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feeding_timer',
          '喂养计时器',
          channelDescription: '母乳喂养计时提醒',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    final record = FeedingRecord(
      time: _recordTime,
      type: _selectedType,
      breastMinutes: _selectedType == FeedingType.breastDirect
          ? (_useManualInput 
              ? (_minutesController.text.isNotEmpty ? int.tryParse(_minutesController.text) : 0)
              : (_breastSeconds ~/ 60))
          : null,
      bottleMl: _selectedType != FeedingType.breastDirect
          ? int.tryParse(_mlController.text)
          : null,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      breastSide: _selectedType == FeedingType.breastDirect ? _currentSide : null,
    );
    await ds.addFeeding(record);
    setState(() {
      _selectedType = FeedingType.breastDirect;
      _breastSeconds = 0;
      _isTimerRunning = false;
      _left15minAlerted = false;
      _right15minAlerted = false;
      _timerStartTime = null;
      _useManualInput = false;
      _minutesController.clear();
      _mlController.clear();
      _noteController.clear();
      _recordTime = DateTime.now();
    });
    await _clearTimerState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerStartTime = DateTime.now();
      _left15minAlerted = false;
      _right15minAlerted = false;
      _useManualInput = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isTimerRunning) return false;
      setState(() => _breastSeconds++);
      _check15MinAlert();
      return _isTimerRunning;
    });
  }

  void _switchSide() {
    setState(() {
      if (_currentSide == BreastSide.left) {
        _currentSide = BreastSide.right;
        _right15minAlerted = false;
        if (_isTimerRunning) _breastSeconds = 0;
      } else {
        _currentSide = BreastSide.left;
        _left15minAlerted = false;
        if (_isTimerRunning) _breastSeconds = 0;
      }
    });
  }

  IconData _typeIcon(FeedingType type) {
    switch (type) {
      case FeedingType.breastDirect: return Icons.child_care;
      case FeedingType.breastBottle: return Icons.local_drink;
      case FeedingType.formula: return Icons.water_drop;
    }
  }

  String _fmt(DateTime t) {
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('喂奶记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildForm();
          final r = records[index - 1];
          return _buildRecordItem(r, ds);
        },
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 时间选择（圆角+蓝边）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('新增记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.access_time_outlined, size: 18, color: Color(0xFF4A90E2)),
                  label: Text(
                    '${_recordTime.month}/${_recordTime.day} ${_recordTime.hour.toString().padLeft(2,'0')}:${_recordTime.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(color: Color(0xFF4A90E2), fontSize: 14),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _recordTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_recordTime),
                      );
                      if (time != null) {
                        setState(() {
                          _recordTime = DateTime(
                            date.year, date.month, date.day,
                            time.hour, time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🍼 喂养方式（圆角SegmentedButton）
            SegmentedButton<FeedingType>(
              segments: const [
                ButtonSegment(value: FeedingType.breastDirect, label: Text('亲喂')),
                ButtonSegment(value: FeedingType.breastBottle, label: Text('母乳瓶喂')),
                ButtonSegment(value: FeedingType.formula, label: Text('奶粉')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) => setState(() => _selectedType = s.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return Colors.black87;
                }),
                textStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const TextStyle(color: Colors.white);
                  return const TextStyle(color: Colors.black87);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFF6C63FF);
                  return Colors.grey.shade100;
                }),
                side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF6C63FF), width: 1)),
              ),
            ),
            const SizedBox(height: 16),

            // ⏱️ 计时器区域（呼吸灯效+圆角卡片）
            if (_selectedType == FeedingType.breastDirect) ...[
              // 模式切换（圆角Chip）
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('计时器'),
                    selected: !_useManualInput,
                    onSelected: (_) => setState(() => _useManualInput = false),
                    selectedColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  FilterChip(
                    label: const Text('手动输入'),
                    selected: _useManualInput,
                    onSelected: (_) => setState(() => _useManualInput = true),
                    selectedColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_useManualInput) ...[
                // 左右侧选择（带呼吸灯效）
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text('喂养侧别：', style: TextStyle(fontSize: 14)),
                    ChoiceChip(
                      label: const Text('左侧'),
                      selected: _currentSide == BreastSide.left,
                      onSelected: (_) => setState(() {
                        _currentSide = BreastSide.left;
                        _left15minAlerted = false;
                        if (_isTimerRunning) _breastSeconds = 0;
                      }),
                      selectedColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      avatar: _currentSide == BreastSide.left 
                          ? const Icon(Icons.check, size: 16, color: Colors.white) 
                          : null,
                    ),
                    ChoiceChip(
                      label: const Text('右侧'),
                      selected: _currentSide == BreastSide.right,
                      onSelected: (_) => setState(() {
                        _currentSide = BreastSide.right;
                        _right15minAlerted = false;
                        if (_isTimerRunning) _breastSeconds = 0;
                      }),
                      selectedColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      avatar: _currentSide == BreastSide.right 
                          ? const Icon(Icons.check, size: 16, color: Colors.white) 
                          : null,
                    ),
                    if (_isTimerRunning)
                      ActionChip(
                        avatar: const Icon(Icons.swap_horiz_outlined, size: 16, color: Color(0xFF4A90E2)),
                        label: const Text('换边'),
                        onPressed: _switchSide,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🌟 计时器主区域（呼吸灯效+圆角）
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _currentSide == BreastSide.left 
                        ? const Color(0xFFE3F2FD) 
                        : const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _currentSide == BreastSide.left 
                          ? const Color(0xFF4A90E2) 
                          : const Color(0xFF9C27B0),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // 💡 呼吸灯效（根据侧别变色）
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _currentSide == BreastSide.left 
                              ? _isTimerRunning ? const Color(0xFF4A90E2).withOpacity(0.8) : const Color(0xFF4A90E2).withOpacity(0.3)
                              : _isTimerRunning ? const Color(0xFF9C27B0).withOpacity(0.8) : const Color(0xFF9C27B0).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_currentSide == BreastSide.left ? "左侧" : "右侧"}: ${_breastSeconds ~/ 60}分钟${_breastSeconds % 60}秒',
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          color: _currentSide == BreastSide.left 
                              ? const Color(0xFF4A90E2) 
                              : const Color(0xFF9C27B0),
                        ),
                      ),
                      if (_breastSeconds >= 15 * 60)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 4),
                              const Text(
                                '✅ 15分钟完成',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 🎯 控制按钮（圆角+蓝白配色）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isTimerRunning)
                      FilledButton.icon(
                        onPressed: () => setState(() => _isTimerRunning = false),
                        icon: const Icon(Icons.stop_circle_outlined, size: 24),
                        label: const Text('停止计时'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _startTimer(),
                        icon: const Icon(Icons.play_circle_fill_outlined, size: 24),
                        label: const Text('开始计时'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => setState(() { 
                        _breastSeconds = 0; 
                        _isTimerRunning = false; 
                        _left15minAlerted = false;
                        _right15minAlerted = false;
                      }),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('重置'),
                    ),
                  ],
                ),
              ] else ...[
                // 手动输入模式（圆角输入框）
                Row(
                  children: [
                    const Text('喂养侧别：', style: TextStyle(fontSize: 14)),
                    ChoiceChip(
                      label: const Text('左侧'),
                      selected: _currentSide == BreastSide.left,
                      onSelected: (_) => setState(() => _currentSide = BreastSide.left),
                      selectedColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('右侧'),
                      selected: _currentSide == BreastSide.right,
                      onSelected: (_) => setState(() => _currentSide = BreastSide.right),
                      selectedColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '时长（分钟）',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ] else ...[
              // 瓶喂/奶粉输入（圆角输入框）
              TextField(
                controller: _mlController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '奶量（ml）',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                hintText: '如：厌奶/呛奶/精神好',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_circle_outlined, size: 20),
                label: const Text('保存记录'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(FeedingRecord r, DataService ds) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(_typeIcon(r.type), color: primaryColor),
        ),
        title: Text(r.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${_fmt(r.time)}  ${r.displayAmount}${r.breastSide != null ? ' (${r.breastSide == BreastSide.left ? '左侧' : '右侧'})' : ''}${r.note != null ? '  📝${r.note}' : ''}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('确认删除'),
              content: const Text('确定要删除这条喂奶记录吗？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteFeeding(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

