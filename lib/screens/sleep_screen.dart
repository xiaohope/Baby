import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_record.dart';
import '../services/data_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isOngoing = false;
  DateTime? _startTime;
  DateTime _recordStartTime = DateTime.now();
  SleepQuality _quality = SleepQuality.good;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecord;
    if (r != null) {
      _isOngoing = r.isOngoing;
      _startTime = r.startTime;
      _recordStartTime = r.startTime;
      if (r.quality != null) _quality = r.quality!;
      return;
    }
    final ds = context.read<DataService>();
    final ongoing = ds.ongoingSleep;
    if (ongoing != null) {
      _isOngoing = true;
      _startTime = ongoing.startTime;
    }
  }

  Future<void> _startSleep() async {
    final ds = context.read<DataService>();
    final record = SleepRecord(startTime: _recordStartTime);
    await ds.addSleep(record);
    setState(() {
      _isOngoing = true;
      _startTime = record.startTime;
    });
  }

  Future<void> _endSleep() async {
    final ds = context.read<DataService>();
    final ongoing = ds.ongoingSleep;
    if (ongoing == null) return;

    final endTime = DateTime.now();
    final updated = SleepRecord(
      id: ongoing.id,
      startTime: ongoing.startTime,
      endTime: endTime,
      quality: _quality,
    );
    await ds.updateSleep(updated);

    final duration = endTime.difference(ongoing.startTime);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('😴 睡眠结束，共 ${duration.inHours}小时${duration.inMinutes % 60}分钟${duration.inSeconds % 60}秒'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _isOngoing = false;
      _startTime = null;
      _quality = SleepQuality.good;
    });
  }

  String _fmt(DateTime t) => '${t.month}/${t.day} ${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  String _qualityName(SleepQuality q) {
    switch (q) {
      case SleepQuality.good: return '好';
      case SleepQuality.normal: return '一般';
      case SleepQuality.crying: return '哭闹';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((s) => !s.isOngoing).take(20).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('睡眠记录'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7FF), Color(0xFFF0FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 当前状态卡片
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isOngoing 
                            ? const Color(0xFF7C3AED).withValues(alpha: 0.1) 
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isOngoing ? Icons.bedtime : Icons.wb_twilight,
                        size: 32,
                        color: _isOngoing ? const Color(0xFF7C3AED) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isOngoing ? '宝宝正在睡觉 😴' : '宝宝醒着 ☀️',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (_isOngoing && _startTime != null) ...[
                      const SizedBox(height: 4),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (_, __) {
                          final duration = DateTime.now().difference(_startTime!);
                          final h = duration.inHours;
                          final m = duration.inMinutes % 60;
                          final s = duration.inSeconds % 60;
                          final timeStr = h > 0
                              ? '${h}时${m.toString().padLeft(2, '0')}分${s.toString().padLeft(2, '0')}秒'
                              : '${m.toString().padLeft(2, '0')}分${s.toString().padLeft(2, '0')}秒';
                          return Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          );
                        },
                      ),
                    ],
                    if (!_isOngoing) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time_outlined, size: 18, color: Color(0xFF4A90E2)),
                        label: Text(
                          '${_recordStartTime.month}/${_recordStartTime.day} ${_recordStartTime.hour.toString().padLeft(2,'0')}:${_recordStartTime.minute.toString().padLeft(2,'0')}',
                          style: const TextStyle(color: Color(0xFF4A90E2)),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _recordStartTime,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_recordStartTime),
                            );
                            if (time != null) {
                              setState(() {
                                _recordStartTime = DateTime(
                                  date.year, date.month, date.day,
                                  time.hour, time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (!_isOngoing)
                      FilledButton.icon(
                        onPressed: _startSleep,
                        icon: const Icon(Icons.bedtime),
                        label: const Text('开始记录睡眠'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else ...[
                      const Text('睡眠质量'),
                      const SizedBox(height: 8),
                      SegmentedButton<SleepQuality>(
                        segments: const [
                          ButtonSegment(value: SleepQuality.good, label: Text('好')),
                          ButtonSegment(value: SleepQuality.normal, label: Text('一般')),
                          ButtonSegment(value: SleepQuality.crying, label: Text('哭闹')),
                        ],
                        selected: {_quality},
                        onSelectionChanged: (s) => setState(() => _quality = s.first),
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
                            if (states.contains(WidgetState.selected)) return const Color(0xFF7C3AED);
                            return Colors.grey.shade100;
                          }),
                          side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF7C3AED), width: 1)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _endSleep,
                        icon: const Icon(Icons.wb_sunny),
                        label: const Text('醒来 - 结束睡眠'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('历史记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(padding: EdgeInsets.all(16), child: Text('暂无历史记录', style: TextStyle(color: Colors.grey))),
              )
            else
              ...records.map((r) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    child: const Icon(Icons.bedtime, color: Colors.purple),
                  ),
                  title: Text('${_fmt(r.startTime)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('睡眠时长: ${r.durationStr}${r.quality != null ? ' 质量: ${_qualityName(r.quality!)}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('确认删除'),
                        content: const Text('确定要删除这条睡眠记录吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                          FilledButton(onPressed: () { Navigator.pop(ctx); ds.deleteSleep(r.id); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('删除')),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}