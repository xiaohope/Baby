import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/growth_record.dart';
import '../services/data_service.dart';

class GrowthScreen extends StatefulWidget {
  final GrowthRecord? initialRecord;
  const GrowthScreen({super.key, this.initialRecord});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  final _noteController = TextEditingController();
  String? _editingId;

  void _startEdit(GrowthRecord r) {
    setState(() {
      _editingId = r.id;
      _weightController.text = r.weightKg?.toString() ?? '';
      _heightController.text = r.heightCm?.toString() ?? '';
      _headController.text = r.headCircumferenceCm?.toString() ?? '';
      _noteController.text = r.note ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _weightController.clear();
      _heightController.clear();
      _headController.clear();
      _noteController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    final r = widget.initialRecord;
    if (r != null) _startEdit(r);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ds = context.read<DataService>();
    if (_editingId != null) await ds.deleteGrowth(_editingId!);
    await ds.addGrowth(GrowthRecord(
      id: _editingId,
      date: DateTime.now(),
      weightKg: double.tryParse(_weightController.text),
      heightCm: double.tryParse(_heightController.text),
      headCircumferenceCm: double.tryParse(_headController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    ));
    _weightController.clear();
    _heightController.clear();
    _headController.clear();
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final records = ds.growthRecords.take(20).toList();
    final latest = records.isNotEmpty ? records.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('身高体重记录'),
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
            if (latest != null) _buildLatestCard(latest),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('新增记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildField('体重 (kg)', _weightController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('身长 (cm)', _heightController)),
                    ]),
                    const SizedBox(height: 12),
                    _buildField('头围 (cm)', _headController),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
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
                          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F0EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCard(GrowthRecord r) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.straighten, color: Colors.teal),
              const SizedBox(width: 8),
              const Text('最新记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text('${r.date.month}/${r.date.day}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                if (r.weightKg != null) _latestItem('体重', '${r.weightKg}', 'kg', Colors.blue),
                if (r.heightCm != null) _latestItem('身长', '${r.heightCm}', 'cm', Colors.green),
                if (r.headCircumferenceCm != null) _latestItem('头围', '${r.headCircumferenceCm}', 'cm', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestItem(String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text('$label($unit)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4C5B5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4C5B5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F0EB),
      ),
    );
  }
}