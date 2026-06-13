import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _phoneKey = 'user_phone';
  static const _roleKey = 'user_role';
  static const _familyIdKey = 'family_id';
  static const _inviteCodeKey = 'invite_code';
  static const _nicknameKey = 'user_nickname';

  static String? _token;
  static String? _userId;
  static String? _phone;
  static String? _role;
  static String? _familyId;
  static String? _inviteCode;
  static String? _nickname;

  static bool get isLoggedIn => _token != null;
  static String? get token => _token;
  static String? get familyId => _familyId;
  static String? get inviteCode => _inviteCode;
  static String? get phone => _phone;
  static String? get role => _role;
  static String? get nickname => _nickname;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _phone = prefs.getString(_phoneKey);
    _role = prefs.getString(_roleKey);
    _familyId = prefs.getString(_familyIdKey);
    _nickname = prefs.getString(_nicknameKey);
    _inviteCode = prefs.getString(_inviteCodeKey);
  }

  static Future<void> saveLogin(Map data) async {
    _token = data['token'];
    _userId = data['user']['id'];
    _phone = data['user']['phone'];
    _role = data['user']['role'];
    _familyId = data['family']['id'];
    _nickname = data['user']['nickname'];
    _inviteCode = data['family']['inviteCode'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userIdKey, _userId!);
    await prefs.setString(_phoneKey, _phone!);
    await prefs.setString(_roleKey, _role!);
    await prefs.setString(_familyIdKey, _familyId!);
    await prefs.setString(_nicknameKey, _nickname ?? '');
    await prefs.setString(_inviteCodeKey, _inviteCode ?? '');
  }

  static Future<void> logout() async {
    _token = null;
    _userId = null;
    _phone = null;
    _role = null;
    _familyId = null;
    _nickname = null;
    _inviteCode = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_familyIdKey);
    await prefs.remove(_nicknameKey);
    await prefs.remove(_inviteCodeKey);
  }
}
