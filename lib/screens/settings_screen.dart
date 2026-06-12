import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    _nameController.text = ds.babyName;
    _birthday = ds.babyBirthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBabyInfo() async {
    if (_nameController.text.isEmpty || _birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写宝宝姓名和出生日期')),
      );
      return;
    }
    final ds = context.read<DataService>();
    await ds.setBabyInfo(_nameController.text, _birthday!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存！'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
            // 宝宝信息
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.child_care, color: Color(0xFF4A90E2)),
                      const SizedBox(width: 8),
                      Text('宝宝信息', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '宝宝姓名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 30)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _birthday = d);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '出生日期',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4A90E2)),
                        ),
                        child: Text(
                          _birthday != null
                              ? '${_birthday!.year}/${_birthday!.month}/${_birthday!.day}'
                              : '请填写宝宝姓名和出生日期',
                          style: TextStyle(color: _birthday == null ? Colors.grey : null),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveBabyInfo,
                        icon: const Icon(Icons.check),
                        label: const Text('保存'),
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
            const SizedBox(height: 12),

            // 关于
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF4A90E2)),
                    title: const Text('版本'),
                    trailing: const Text('3.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline, color: Color(0xFF4A90E2)),
                    title: const Text('关于'),
                    subtitle: const Text('宝宝喂养记录 App — 用心陪伴每一步'),
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 数据导出
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.download, color: Color(0xFF4A90E2)),
                title: const Text('数据导出 (开发中)'),
                subtitle: const Text('导出 Excel 方便给医生查看'),
                trailing: const Icon(Icons.lock_outline, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '宝宝记录',
      applicationVersion: '3.0.0',
      children: const [
        Text('记录宝宝成长每一步'),
        SizedBox(height: 8),
        Text('功能: 喂奶 | 换尿布 | 睡眠 | 营养补充 | 生长发育 | 里程碑', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}