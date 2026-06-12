import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/temperature_record.dart';
import '../services/data_service.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final _tempController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _recordTime = DateTime.now();

  @override
  void dispose() {
    _tempController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final temp = double.tryParse(_tempController.text);
    if (temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的体温数值'), backgroundColor: Colors.orange),
      );
      return;
    }
    final ds = context.read<DataService>();
    await ds.addTemperature(TemperatureRecord(
      temperature: temp,
      time: _recordTime,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
      setState(() {
        _tempController.clear();
        _noteController.clear();
        _recordTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.tempRecords.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('体温记录'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.thermostat, color: Color(0xFFE74C3C), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('记录体温', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time, size: 16, color: Color(0xFFE74C3C)),
                        label: Text('${_recordTime.month}/${_recordTime.day} ${_recordTime.hour.toString().padLeft(2,'0')}:${_recordTime.minute.toString().padLeft(2,'0')}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFE74C3C))),
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: _recordTime,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
                          if (date != null && mounted) {
                            final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_recordTime));
                            if (time != null) setState(() => _recordTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tempController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: '体温 (℃)',
                        hintText: '例如 37.5',
                        suffixText: '℃',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFE74C3C), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '备注（可选）',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFFE74C3C), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: const Text('保存'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('历史记录', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Card(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Column(children: [
                  Icon(Icons.thermostat, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('暂无记录', style: TextStyle(color: Colors.grey.shade400)),
                ])),
              ))
            else
              ...records.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r.temperature > 37.5 ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    child: Icon(Icons.thermostat, color: r.temperature > 37.5 ? Colors.red : Colors.green),
                  ),
                  title: Text('${r.temperature.toStringAsFixed(1)}℃', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text([
                    '${r.time.month}/${r.time.day} ${r.time.hour.toString().padLeft(2,'0')}:${r.time.minute.toString().padLeft(2,'0')}',
                    if (r.note != null) '  📝${r.note}',
                  ].join('')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => ds.deleteTemperature(r.id),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
