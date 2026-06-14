import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'about_screen.dart';

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
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null : const LinearGradient(colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : null,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<DataService>().reloadFromServer();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已刷新'), duration: Duration(seconds: 1)));
          },
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ====== 用户卡片 ======
            if (AuthService.isLoggedIn)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 头像
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            AuthService.role == '妈妈' ? '👩' : '👨',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (AuthService.nickname != null && AuthService.nickname!.isNotEmpty) ? AuthService.nickname! : (AuthService.role ?? '用户'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(AuthService.role ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF6C63FF))),
                            ),
                            const SizedBox(height: 3),
                            Text(AuthService.phone ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      // 邀请码
                      GestureDetector(
                        onTap: () {
                          if (AuthService.inviteCode != null) {
                            Clipboard.setData(ClipboardData(text: AuthService.inviteCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('邀请码已复制'), duration: Duration(seconds: 1)),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Text('邀请码', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                AuthService.inviteCode ?? '',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFFB8860B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

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
                          context: context, initialDate: _birthday ?? DateTime.now(),
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
                    trailing: const Text('4.1.0'),
                    onTap: () => _checkUpdate(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline, color: Color(0xFF6C63FF)),
                    title: const Text('关于'),
                    subtitle: const Text('功能介绍和使用说明'),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
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

            const SizedBox(height: 12),

            // ====== 退出登录 ======
            if (AuthService.isLoggedIn)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('退出登录', style: TextStyle(color: Colors.red)),
                  onTap: () => _logout(),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }



  Future<void> _checkUpdate() async {
    try {
      final res = await http.get(Uri.parse('${ApiService.baseUrl}/version')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final serverVersion = data['version'] as String? ?? '4.0.0';
        const currentVersion = '4.1.0';
        if (serverVersion.compareTo(currentVersion) > 0 && mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('发现新版本 🎉'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('最新版本: $serverVersion'),
                  const SizedBox(height: 8),
                  Text(data['desc'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                FilledButton(onPressed: () {
                  Navigator.pop(ctx);
                  _downloadApk(data['updateUrl'] ?? 'https://github.com/xiaohope/Baby/releases/latest');
                }, child: const Text('去下载')),
              ],
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 已是最新版本'), duration: Duration(seconds: 1)));
        }
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('检查更新失败'), duration: Duration(seconds: 2)));
    }
  }

  void _downloadApk(String url) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请在浏览器打开: $url'), duration: const Duration(seconds: 3)));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认退出'),
        content: const Text('退出后需要重新登录'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('退出')),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
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

}
