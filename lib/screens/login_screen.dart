import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _pwdController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _isRegister = false;
  String _role = '爸爸';
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pwdController.dispose();
    _nicknameController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _pwdController.text;
    if (phone.isEmpty || password.isEmpty) {
      _showMsg('请输入手机号和密码');
      return;
    }

    setState(() => _loading = true);
    try {
      Map result;
      if (_isRegister) {
        result = await ApiService.register(phone, password, _role,
          nickname: _nicknameController.text.trim(),
          inviteCode: _inviteController.text.trim().isEmpty
              ? null : _inviteController.text.trim());
      } else {
        result = await ApiService.login(phone, password);
      }

      if (result.containsKey('error')) {
        _showMsg(result['error']);
      } else if (result.containsKey('token')) {
        await AuthService.saveLogin(result);
        ApiService.setToken(result['token']);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showMsg('网络错误，请检查服务器连接');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.child_care, size: 64, color: Color(0xFF6C63FF)),
                  const SizedBox(height: 12),
                  const Text('Baby', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                  const Text('宝宝成长记录', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: '手机号', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pwdController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '密码', prefixIcon: Icon(Icons.lock)),
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: '昵称（选填）', prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Text('角色：'),
                      const SizedBox(width: 12),
                      ChoiceChip(label: const Text('爸爸'), selected: _role == '爸爸', onSelected: (_) => setState(() => _role = '爸爸')),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('妈妈'), selected: _role == '妈妈', onSelected: (_) => setState(() => _role = '妈妈')),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inviteController,
                      decoration: const InputDecoration(
                        labelText: '邀请码（加入家庭填，不填创建新家庭）',
                        prefixIcon: Icon(Icons.group),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isRegister ? '注册' : '登录'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister ? '已有账号？去登录' : '没有账号？去注册'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
