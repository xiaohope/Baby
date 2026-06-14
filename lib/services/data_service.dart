import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeding_record.dart';
import '../models/diaper_record.dart';
import '../models/supplement_record.dart';
import '../models/sleep_record.dart';
import '../models/growth_record.dart';
import '../models/milestone_record.dart';
import '../models/moment_record.dart';
import '../models/simple_record.dart';
import '../models/food_record.dart';
import '../models/temperature_record.dart';
import 'auth_service.dart';
import 'api_service.dart';

class DataService extends ChangeNotifier {
  bool _isLoading = true;
  String? _loadError;

  List<FeedingRecord> _feedingRecords = [];
  List<DiaperRecord> _diaperRecords = [];
  List<SupplementRecord> _supplementRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<GrowthRecord> _growthRecords = [];
  List<MilestoneRecord> _milestoneRecords = [];
  List<MomentRecord> _momentRecords = [];
  List<SimpleRecord> _simpleRecords = [];
  List<FoodRecord> _foodRecords = [];
  List<TemperatureRecord> _tempRecords = [];
  String _babyName = '宝宝';
  DateTime? _babyBirthday;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  List<FeedingRecord> get feedingRecords => _feedingRecords;
  List<DiaperRecord> get diaperRecords => _diaperRecords;
  List<SupplementRecord> get supplementRecords => _supplementRecords;
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<GrowthRecord> get growthRecords => _growthRecords;
  List<MilestoneRecord> get milestoneRecords => _milestoneRecords;
  List<MomentRecord> get momentRecords => _momentRecords;
  List<SimpleRecord> get simpleRecords => _simpleRecords;
  List<FoodRecord> get foodRecords => _foodRecords;
  List<TemperatureRecord> get tempRecords => _tempRecords;
  String get babyName => _babyName;
  DateTime? get babyBirthday => _babyBirthday;
  ThemeMode get themeMode => _themeMode;

  // ---- 工具方法 ----
  String _tableName(dynamic record) {
    if (record is FeedingRecord) return 'feeding';
    if (record is DiaperRecord) return 'diaper';
    if (record is SleepRecord) return 'sleep';
    if (record is GrowthRecord) return 'growth';
    if (record is MilestoneRecord) return 'milestone';
    if (record is SupplementRecord) return 'supplement';
    if (record is MomentRecord) return 'moment';
    if (record is SimpleRecord) return 'simple';
    if (record is FoodRecord) return 'food';
    if (record is TemperatureRecord) return 'temperature';
    return '';
  }

  Map<String, dynamic> _recordToMap(dynamic record) {
    if (record is FeedingRecord) return {
      'id': record.id, 'time': _localDt(record.time), 'type': record.type.index,
      'breast_minutes': record.breastMinutes, 'bottle_ml': record.bottleMl,
      'note': record.note, 'breast_side': record.breastSide?.index,
    };
    if (record is DiaperRecord) return {
      'id': record.id, 'time': _localDt(record.time), 'type': record.type.index,
      'poop_color': record.poopColor, 'note': record.note,
    };
    if (record is SleepRecord) return {
      'id': record.id, 'start_time': _localDt(record.startTime),
      'end_time': record.endTime != null ? _localDt(record.endTime!) : null, 'quality': record.quality?.index,
      'note': record.note,
    };
    if (record is GrowthRecord) return {
      'id': record.id, 'date': record.date.toIso8601String().substring(0, 10),
      'weight_kg': record.weightKg, 'height_cm': record.heightCm,
      'head_circumference_cm': record.headCircumferenceCm, 'note': record.note,
    };
    if (record is MilestoneRecord) return {
      'id': record.id, 'date': record.date.toIso8601String().substring(0, 10),
      'title': record.title, 'note': record.note, 'category': record.category,
    };
    if (record is SupplementRecord) return {
      'id': record.id, 'date': record.date.toIso8601String().substring(0, 10),
      'items': record.items,
    };
    if (record is MomentRecord) return {
      'id': record.id, 'date': record.date.toIso8601String(),
      'text_content': record.text, 'images': record.imagePaths,
    };
    if (record is SimpleRecord) return {
      'id': record.id, 'category': record.category,
      'time': _localDt(record.time), 'note': record.note,
    };
    if (record is FoodRecord) return {
      'id': record.id, 'name': record.name, 'portion': record.portion,
      'feeling': record.feeling, 'time': _localDt(record.time),
      'note': record.note,
    };
    if (record is TemperatureRecord) return {
      'id': record.id, 'temperature': record.temperature,
      'time': _localDt(record.time), 'note': record.note,
    };
    return {};
  }

  dynamic _mapToRecord(String table, Map r) {
    switch (table) {
      case 'feeding_records': return FeedingRecord(
        id: r['id'], time: _parseDt(r['time'].toString()), type: FeedingType.values[r['type']],
        breastMinutes: r['breast_minutes'], bottleMl: r['bottle_ml'],
        note: r['note'], breastSide: r['breast_side'] != null ? BreastSide.values[r['breast_side']] : null,
      );
      case 'diaper_records': return DiaperRecord(
        id: r['id'], time: _parseDt(r['time'].toString()), type: DiaperType.values[r['type']],
        poopColor: r['poop_color'], note: r['note'],
      );
      case 'sleep_records': return SleepRecord(
        id: r['id'], startTime: _parseDt(r['start_time'].toString()),
        endTime: r['end_time'] != null ? _parseDt(r['end_time'].toString()) : null,
        quality: r['quality'] != null ? SleepQuality.values[r['quality']] : null,
        note: r['note'],
      );
      case 'growth_records': return GrowthRecord(
        id: r['id'], date: DateTime.parse(r['date']),
        weightKg: (r['weight_kg'] as num?)?.toDouble(),
        heightCm: (r['height_cm'] as num?)?.toDouble(),
        headCircumferenceCm: (r['head_circumference_cm'] as num?)?.toDouble(),
        note: r['note'],
      );
      case 'milestone_records': return MilestoneRecord(
        id: r['id'], date: DateTime.parse(r['date']),
        title: r['title'], note: r['note'], category: r['category'] ?? 'milestone',
      );
      case 'supplement_records': return SupplementRecord(
        id: r['id'], date: DateTime.parse(r['date']),
        items: r['items'] != null ? (r['items'] is List ? List<String>.from(r['items']) : List<String>.from(jsonDecode(r['items']))) : [],
      );
      case 'moment_records': return MomentRecord(
        id: r['id'], date: DateTime.parse(r['date']),
        text: r['text_content'] ?? '',
        imagePaths: r['images'] != null ? (r['images'] is List ? List<String>.from(r['images']) : List<String>.from(jsonDecode(r['images']))) : [],
      );
      case 'simple_records': return SimpleRecord(
        id: r['id'], category: r['category'],
        time: _parseDt(r['time'].toString()), note: r['note'] ?? '',
      );
      case 'food_records': return FoodRecord(
        id: r['id'], name: r['name'], portion: r['portion'],
        feeling: r['feeling'], time: _parseDt(r['time'].toString()), note: r['note'],
      );
      case 'temperature_records': return TemperatureRecord(
        id: r['id'], temperature: (r['temperature'] as num).toDouble(),
        time: _parseDt(r['time'].toString()), note: r['note'],
      );
      default: return null;
    }
  }

  Future<bool> _saveToServer(dynamic record) async {
    if (!AuthService.isLoggedIn) return true;
    final table = _tableName(record);
    if (table.isEmpty) return true;
    try {
      final res = await ApiService.uploadRecords([{'table': table, 'data': _recordToMap(record)}]);
      final errors = res['errors'] ?? 0;
      return errors == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteFromServer(String tableName, String id) async {
    if (!AuthService.isLoggedIn) return true;
    try {
      await ApiService.deleteRecord(tableName, id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showError(BuildContext? context, String msg) async {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
    }
  }

  /// 把DateTime转成不带时区的字符串（存服务器用本地时间，避免时区转换）
  String _localDt(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}:${dt.second.toString().padLeft(2,'0')}';

  /// 从服务器返回的字符串解析DateTime（去除时区后缀，当作本地时间处理）
  DateTime _parseDt(String s) {
    try {
      return DateTime.parse(s.replaceAll(RegExp(r'[\.\d]*[Z\+-].*$'), ''));
    } catch (_) {
      return DateTime.parse(s.replaceAll('T', ' ').split('.').first.replaceAll('Z', ''));
    }
  }

  String _tableDbName(dynamic record) {
    switch (_tableName(record)) {
      case 'feeding': return 'feeding_records';
      case 'diaper': return 'diaper_records';
      case 'sleep': return 'sleep_records';
      case 'growth': return 'growth_records';
      case 'milestone': return 'milestone_records';
      case 'supplement': return 'supplement_records';
      case 'moment': return 'moment_records';
      case 'simple': return 'simple_records';
      case 'food': return 'food_records';
      case 'temperature': return 'temperature_records';
      default: return '';
    }
  }

  // ---- 手动重新加载（下拉刷新用） ----
  Future<int> reloadFromServer() async {
    if (!AuthService.isLoggedIn) return 0;
    try {
      final data = await ApiService.syncRecords();
      _parseServerData(data);
      // 刷新宝宝信息
      try {
        final settings = await ApiService.downloadSettings();
        if (settings['babyName'] != null) {
          _babyName = settings['babyName'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('baby_name', _babyName);
        }
      } catch (_) {}
      notifyListeners();
      return _feedingRecords.length;
    } catch (e) {
      notifyListeners();
      return -1;
    }
  }

  // ---- 初始化 ----
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // 从 SharedPreferences 加载设置
    try {
      final prefs = await SharedPreferences.getInstance();
      _babyName = prefs.getString('baby_name') ?? '宝宝';
      final birthdayStr = prefs.getString('baby_birthday');
      if (birthdayStr != null) _babyBirthday = DateTime.tryParse(birthdayStr);
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
    } catch (_) {}

    // 从服务器拉取所有数据
    if (AuthService.isLoggedIn) {
      try {
        final data = await ApiService.syncRecords();
        _parseServerData(data);
        _loadError = null;
      } catch (e) {
        _loadError = '加载失败: 网络错误';
      }
      // 从服务器拉取宝宝信息
      try {
        final settings = await ApiService.downloadSettings();
        if (settings['babyName'] != null) {
          _babyName = settings['babyName'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('baby_name', _babyName);
        }
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
  }

  void _parseServerData(Map data) {
    final tables = {
      'feeding_records': (List list) => _feedingRecords = list.cast<FeedingRecord>()..sort((a,b) => b.time.compareTo(a.time)),
      'diaper_records': (List list) => _diaperRecords = list.cast<DiaperRecord>()..sort((a,b) => b.time.compareTo(a.time)),
      'sleep_records': (List list) => _sleepRecords = list.cast<SleepRecord>()..sort((a,b) => b.startTime.compareTo(a.startTime)),
      'growth_records': (List list) => _growthRecords = list.cast<GrowthRecord>()..sort((a,b) => b.date.compareTo(a.date)),
      'milestone_records': (List list) => _milestoneRecords = list.cast<MilestoneRecord>()..sort((a,b) => b.date.compareTo(a.date)),
      'supplement_records': (List list) => _supplementRecords = list.cast<SupplementRecord>()..sort((a,b) => b.date.compareTo(a.date)),
      'moment_records': (List list) => _momentRecords = list.cast<MomentRecord>()..sort((a,b) => b.date.compareTo(a.date)),
      'simple_records': (List list) => _simpleRecords = list.cast<SimpleRecord>()..sort((a,b) => b.time.compareTo(a.time)),
      'food_records': (List list) => _foodRecords = list.cast<FoodRecord>()..sort((a,b) => b.time.compareTo(a.time)),
      'temperature_records': (List list) => _tempRecords = list.cast<TemperatureRecord>()..sort((a,b) => b.time.compareTo(a.time)),
    };

    for (final entry in tables.entries) {
      final rawList = data[entry.key] as List? ?? [];
      final parsed = rawList.map((r) => _mapToRecord(entry.key, r)).whereType<dynamic>().toList();
      entry.value(parsed);
    }
  }

  // ---- 宝宝信息 ----
  Future<void> setBabyInfo(String name, DateTime birthday) async {
    _babyName = name;
    _babyBirthday = birthday;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baby_name', name);
    await prefs.setString('baby_birthday', birthday.toIso8601String());
    // 存服务器
    try {
      await ApiService.uploadSettings({'babyName': name, 'babyBirthday': birthday.toIso8601String()});
    } catch (_) {}
    notifyListeners();
  }

  // ---- 主题切换 ----
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  // ---- 喂奶 ----
  Future<void> addFeeding(FeedingRecord record) async {
    if (await _saveToServer(record)) {
      _feedingRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteFeeding(String id) async {
    if (await _deleteFromServer('feeding_records', id)) {
      _feedingRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  List<FeedingRecord> todayFeedings() => _feedingRecords.where((r) =>
    r.time.year == DateTime.now().year && r.time.month == DateTime.now().month && r.time.day == DateTime.now().day
  ).toList();

  // ---- 尿布 ----
  Future<void> addDiaper(DiaperRecord record) async {
    if (await _saveToServer(record)) {
      _diaperRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteDiaper(String id) async {
    if (await _deleteFromServer('diaper_records', id)) {
      _diaperRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  List<DiaperRecord> todayDiapers() => _diaperRecords.where((r) =>
    r.time.year == DateTime.now().year && r.time.month == DateTime.now().month && r.time.day == DateTime.now().day
  ).toList();

  // ---- 营养补充 ----
  Future<void> setSupplement(SupplementRecord record) async {
    if (await _saveToServer(record)) {
      final todayKey = record.date.toIso8601String().substring(0, 10);
      final existingIdx = _supplementRecords.indexWhere(
        (r) => r.date.toIso8601String().substring(0, 10) == todayKey
      );
      if (existingIdx >= 0) {
        _supplementRecords[existingIdx] = record;
      } else {
        _supplementRecords.insert(0, record);
      }
      notifyListeners();
    }
  }

  Future<void> deleteSupplement(String id) async {
    if (await _deleteFromServer('supplement_records', id)) {
      _supplementRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  SupplementRecord? todaySupplement() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      return _supplementRecords.firstWhere((r) => r.date.toIso8601String().substring(0, 10) == today);
    } catch (_) { return null; }
  }

  List<SupplementRecord> allSupplementRecords() => List.unmodifiable(_supplementRecords);

  // ---- 睡眠 ----
  Future<void> addSleep(SleepRecord record) async {
    if (await _saveToServer(record)) {
      _sleepRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> updateSleep(SleepRecord record) async {
    if (await _saveToServer(record)) {
      final idx = _sleepRecords.indexWhere((r) => r.id == record.id);
      if (idx >= 0) _sleepRecords[idx] = record;
      notifyListeners();
    }
  }

  Future<void> deleteSleep(String id) async {
    if (await _deleteFromServer('sleep_records', id)) {
      _sleepRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  SleepRecord? get ongoingSleep {
    try { return _sleepRecords.firstWhere((r) => r.isOngoing); } catch (_) { return null; }
  }

  // ---- 生长发育 ----
  Future<void> addGrowth(GrowthRecord record) async {
    if (await _saveToServer(record)) {
      _growthRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteGrowth(String id) async {
    if (await _deleteFromServer('growth_records', id)) {
      _growthRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  // ---- 里程碑 ----
  Future<void> addMilestone(MilestoneRecord record) async {
    if (await _saveToServer(record)) {
      _milestoneRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteMilestone(String id) async {
    if (await _deleteFromServer('milestone_records', id)) {
      _milestoneRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  // ---- 动态 ----
  Future<void> addMoment(MomentRecord record) async {
    if (await _saveToServer(record)) {
      _momentRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteMoment(String id) async {
    if (await _deleteFromServer('moment_records', id)) {
      _momentRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  // ---- 通用记录 ----
  Future<void> addSimpleRecord(SimpleRecord record) async {
    if (await _saveToServer(record)) {
      _simpleRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteSimpleRecord(String id) async {
    if (await _deleteFromServer('simple_records', id)) {
      _simpleRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  List<SimpleRecord> simpleRecordsByCategory(String category) => _simpleRecords.where((r) => r.category == category).toList();

  // ---- 辅食 ----
  Future<void> addFood(FoodRecord record) async {
    if (await _saveToServer(record)) {
      _foodRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteFood(String id) async {
    if (await _deleteFromServer('food_records', id)) {
      _foodRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  // ---- 体温 ----
  Future<void> addTemperature(TemperatureRecord record) async {
    if (await _saveToServer(record)) {
      _tempRecords.insert(0, record);
      notifyListeners();
    }
  }

  Future<void> deleteTemperature(String id) async {
    if (await _deleteFromServer('temperature_records', id)) {
      _tempRecords.removeWhere((r) => r.id == id);
      notifyListeners();
    }
  }

  // ---- 今日统计 ----
  Map<String, dynamic> todayStats() {
    final now = DateTime.now();
    final feedings = todayFeedings();
    final diapers = todayDiapers();
    final sleeps = sleepRecords.where((s) =>
      s.startTime.year == now.year && s.startTime.month == now.month && s.startTime.day == now.day
    ).toList();

    int totalBottleMl = 0;
    int totalBreastMinutes = 0;
    for (final f in feedings) {
      if (f.type != FeedingType.breastDirect) {
        totalBottleMl += f.bottleMl ?? 0;
      } else {
        totalBreastMinutes += f.breastMinutes ?? 0;
      }
    }

    int peeCount = diapers.where((d) => d.type == DiaperType.pee || d.type == DiaperType.both).length;
    int poopCount = diapers.where((d) => d.type == DiaperType.poop || d.type == DiaperType.both).length;

    // SimpleRecord 统计
    final nowStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    int peeSimpleCount = _simpleRecords.where((r) =>
      r.category == 'pee' && r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int poopSimpleCount = _simpleRecords.where((r) =>
      r.category == 'poop' && r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int medCount = _simpleRecords.where((r) =>
      r.category == 'medication' && r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int waterCount = _simpleRecords.where((r) =>
      r.category == 'water' && r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int foodCount = _foodRecords.where((r) =>
      r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int tempCount = _tempRecords.where((r) =>
      r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int bathCount = _simpleRecords.where((r) =>
      r.category == 'bath' && r.time.toIso8601String().substring(0, 10) == nowStr
    ).length;
    int vaccineCount = _milestoneRecords.where((r) =>
      r.category == 'vaccine' && r.date.toIso8601String().substring(0, 10) == nowStr
    ).length;

    int totalSleepMinutes = 0;
    for (final s in sleeps) {
      if (s.duration != null) {
        totalSleepMinutes += s.duration!.inMinutes;
      }
    }

    return {
      'feedingCount': feedings.length,
      'totalBottleMl': totalBottleMl,
      'totalBreastMinutes': totalBreastMinutes,
      'diaperCount': diapers.length,
      'peeCount': peeCount,
      'poopCount': poopCount,
      'peeSimpleCount': peeSimpleCount,
      'poopSimpleCount': poopSimpleCount,
      'medCount': medCount,
      'waterCount': waterCount,
      'foodCount': foodCount,
      'tempCount': tempCount,
      'bathCount': bathCount,
      'vaccineCount': vaccineCount,
      'totalSleepMinutes': totalSleepMinutes,
    };
  }

  // 合并时间相近的记录（10分钟内视为一组）
  List<Map<String, dynamic>> getMergedRecords() {
    final feedingRecords = <Map<String, dynamic>>[];
    for (final f in _feedingRecords) {
      feedingRecords.add({'time': f.time, 'type': 'feeding', 'record': f});
    }
    final diaperRecords = <Map<String, dynamic>>[];
    for (final d in _diaperRecords) {
      diaperRecords.add({'time': d.time, 'type': 'diaper', 'record': d});
    }
    
    List<Map<String, dynamic>> mergeGroup(List<Map<String, dynamic>> records) {
      if (records.isEmpty) return [];
      records.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
      final merged = <Map<String, dynamic>>[];
      for (final item in records) {
        if (merged.isEmpty) {
          merged.add({'time': item['time'], 'type': item['type'], 'events': [item]});
        } else {
          final last = merged.last;
          final diff = (item['time'] as DateTime).difference(last['time'] as DateTime).inMinutes;
          if (diff <= 10) {
            (last['events'] as List).add(item);
          } else {
            merged.add({'time': item['time'], 'type': item['type'], 'events': [item]});
          }
        }
      }
      return merged;
    }
    
    final mergedFeeding = mergeGroup(feedingRecords);
    final mergedDiaper = mergeGroup(diaperRecords);
    
    final allMerged = [...mergedFeeding, ...mergedDiaper];
    allMerged.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));
    return allMerged;
  }

  // 间隔时间统计
  List<Map<String, dynamic>> getIntervals(String type) {
    final records = type == 'feeding' 
        ? _feedingRecords.cast<dynamic>() 
        : _diaperRecords.cast<dynamic>();
    if (records.length < 2) return [];
    final times = records.map((r) => r.time as DateTime).toList()..sort();
    return [
      for (int i = 1; i < times.length; i++)
        {'from': times[i-1], 'to': times[i], 'minutes': times[i].difference(times[i-1]).inMinutes}
    ];
  }

  // 每周每日频次统计
  Map<String, dynamic> getFrequencyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dailyStats = <String, Map<String, int>>{};
    for (int i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      dailyStats['${d.month}/${d.day}'] = {'feeding': 0, 'diaper': 0};
    }
    for (final f in _feedingRecords) {
      if (f.time.isAfter(weekStart)) {
        final key = '${f.time.month}/${f.time.day}';
        if (dailyStats.containsKey(key)) {
          dailyStats[key]!['feeding'] = (dailyStats[key]!['feeding'] ?? 0) + 1;
        }
      }
    }
    for (final d in _diaperRecords) {
      if (d.time.isAfter(weekStart)) {
        final key = '${d.time.month}/${d.time.day}';
        if (dailyStats.containsKey(key)) {
          dailyStats[key]!['diaper'] = (dailyStats[key]!['diaper'] ?? 0) + 1;
        }
      }
    }
    int totalFeeding = 0, totalDiaper = 0;
    for (final stat in dailyStats.values) {
      totalFeeding += stat['feeding']!;
      totalDiaper += stat['diaper']!;
    }
    return {
      'dailyStats': dailyStats,
      'avgFeedingPerDay': (totalFeeding / 7).toStringAsFixed(1),
      'avgDiaperPerDay': (totalDiaper / 7).toStringAsFixed(1),
      'totalFeeding': totalFeeding,
      'totalDiaper': totalDiaper,
    };
  }
}
