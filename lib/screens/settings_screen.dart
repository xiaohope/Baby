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
  bool _isEditing = false;
  String _savedName = '';
  DateTime? _savedBirthday;

  @override
  void initState() {
    super.initState();
    final ds = context.read<DataService>();
    _nameController.text = ds.babyName;
    _birthday = ds.babyBirthday;
    _savedName = ds.babyName;
    _savedBirthday = ds.babyBirthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() {
      _nameController.text = _savedName;
      _birthday = _savedBirthday;
      _isEditing = false;
    });
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
    _savedName = _nameController.text;
    _savedBirthday = _birthday;
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ====== 主题设置 ======
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.dark_mode, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 8),
                      Text('主题设置', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    _buildThemeOption(ds, ThemeMode.light, '☀️ 浅色模式', '始终使用浅色主题'),
                    const Divider(height: 4),
                    _buildThemeOption(ds, ThemeMode.dark, '🌙 深色模式', '始终使用深色主题'),
                    const Divider(height: 4),
                    _buildThemeOption(ds, ThemeMode.system, '🔄 跟随系统', '自动跟随系统设置'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ====== 宝宝信息 ======
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.child_care, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 8),
                      Text('宝宝信息', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      // 编辑/取消按钮
                      if (!_isEditing)
                        InkWell(
                          onTap: _startEditing,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_outlined, color: Color(0xFF6C63FF), size: 18),
                          ),
                        )
                      else
                        InkWell(
                          onTap: _cancelEditing,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('取消', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      readOnly: !_isEditing,
                      decoration: InputDecoration(
                        labelText: '宝宝姓名',
                        filled: !_isEditing,
                        fillColor: !_isEditing ? Colors.grey.withValues(alpha: 0.05) : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isEditing ? () async {
                        final d = await showDatePicker(
                          context: context, initialDate: _birthday ?? DateTime.now().subtract(const Duration(days: 30)),
                          firstDate: DateTime(2020), lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _birthday = d);
                      } : null,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '出生日期',
                          suffixIcon: Icon(Icons.calendar_today, color: _isEditing ? const Color(0xFF6C63FF) : Colors.grey),
                          filled: !_isEditing,
                          fillColor: !_isEditing ? Colors.grey.withValues(alpha: 0.05) : null,
                        ),
                        child: Text(
                          _birthday != null
                              ? '${_birthday!.year}年${_birthday!.month}月${_birthday!.day}日'
                              : '请选择出生日期',
                          style: TextStyle(color: _birthday == null ? Colors.grey : null),
                        ),
                      ),
                    ),
                    // 保存按钮（仅编辑模式显示）
                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveBabyInfo,
                              icon: const Icon(Icons.check),
                              label: const Text('保存'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ====== 关于 ======
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF6C63FF)),
                    title: const Text('版本'),
                    trailing: const Text('4.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline, color: Color(0xFF6C63FF)),
                    title: const Text('关于'),
                    subtitle: const Text('记录宝宝成长的每一个瞬间 — 喂奶、换尿布、睡眠、辅食、体温……'),
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ====== 数据导出 ======
            Card(
              child: ListTile(
                leading: const Icon(Icons.download, color: Color(0xFF6C63FF)),
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

  Widget _buildThemeOption(DataService ds, ThemeMode mode, String title, String subtitle) {
    final isSelected = ds.themeMode == mode;
    return InkWell(
      onTap: () => ds.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Radio<ThemeMode>(
              value: mode,
              groupValue: ds.themeMode,
              onChanged: (v) => ds.setThemeMode(v!),
              activeColor: const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('当前', style: TextStyle(fontSize: 11, color: Color(0xFF6C63FF), fontWeight: FontWeight.w500)),
              ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Baby',
      applicationVersion: '4.0.0',
      children: const [
        Text('记录宝宝成长的每一个瞬间 📝'),
        SizedBox(height: 8),
        Text('功能: 喂奶 | 尿布 | 睡眠 | 成长 | 辅食 | 体温 | 洗澡 | 用药 | 动态 | 更多……', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
