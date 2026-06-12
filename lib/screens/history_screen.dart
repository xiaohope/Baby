import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '喂奶'),
            Tab(text: '尿布'),
            Tab(text: '睡眠'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF4A90E2)),
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
            colors: [Color(0xFFE6F7FF), Color(0xFFF0FAFF)],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingHistory() {
    final ds = context.watch<DataService>();
    final records = ds.feedingRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.local_drink, color: Colors.blue),
            ),
            title: Text(r.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_fmtTime(r.time)}  ${r.displayAmount}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteFeeding(r.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaperHistory() {
    final ds = context.watch<DataService>();
    final records = ds.diaperRecords.where((r) =>
      r.time.year == _selectedDate.year &&
      r.time.month == _selectedDate.month &&
      r.time.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.baby_changing_station, color: Colors.orange),
            ),
            title: Text(r.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_fmtTime(r.time)}${r.poopColor != null ? '  ${r.poopColor}' : ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteDiaper(r.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepHistory() {
    final ds = context.watch<DataService>();
    final records = ds.sleepRecords.where((r) =>
      r.startTime.year == _selectedDate.year &&
      r.startTime.month == _selectedDate.month &&
      r.startTime.day == _selectedDate.day
    ).toList();

    if (records.isEmpty) return const Center(child: Text('当日无记录', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final r = records[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: const Icon(Icons.bedtime, color: Colors.purple),
            ),
            title: Text(r.isOngoing ? '睡眠中' : '睡眠', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${_fmtTime(r.startTime)}${r.endTime != null ? ' - ${_fmtTime(r.endTime!)}' : ''}  ${r.durationStr}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => ds.deleteSleep(r.id),
            ),
          ),
        );
      },
    );
  }
}