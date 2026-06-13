import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 改成你的服务器地址
  static String baseUrl = 'http://8.138.224.195/api';

  static String? _token;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static void setToken(String token) => _token = token;
  static void setBaseUrl(String url) => baseUrl = url;

  // 注册
  static Future<Map> register(String phone, String password, String role, {String? nickname, String? inviteCode}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone, 'password': password, 'role': role,
        'nickname': nickname, 'inviteCode': inviteCode,
      }),
    ).timeout(const Duration(seconds: 15));
    return jsonDecode(res.body);
  }

  // 登录
  static Future<Map> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    ).timeout(const Duration(seconds: 15));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      _token = data['token'];
    }
    return data;
  }

  // 获取用户信息
  static Future<Map> getMe() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers);
    return jsonDecode(res.body);
  }

  // 获取家庭成员
  static Future<List> getMembers() async {
    final res = await http.get(Uri.parse('$baseUrl/family/members'), headers: _headers);
    return jsonDecode(res.body);
  }

  // 重新生成邀请码
  static Future<Map> refreshInviteCode() async {
    final res = await http.post(Uri.parse('$baseUrl/family/invite-code'), headers: _headers);
    return jsonDecode(res.body);
  }

  // 批量上传记录
  static Future<Map> uploadRecords(List records) async {
    final res = await http.post(
      Uri.parse('$baseUrl/records/upload'),
      headers: _headers,
      body: jsonEncode({'records': records}),
    ).timeout(const Duration(seconds: 30));
    return jsonDecode(res.body);
  }

  // 全量同步
  static Future<Map> syncRecords({String? since}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/records/sync?since=${since ?? '2000-01-01'}'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  // 删除记录
  static Future<Map> deleteRecord(String table, String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/records/$table/$id'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }
}
