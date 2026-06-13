import 'package:flutter/material.dart';
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
import 'sync_service.dart';
import '../adapters/feeding_record_adapter.dart';
import '../adapters/diaper_record_adapter.dart';
import '../adapters/sleep_record_adapter.dart';
import '../adapters/growth_record_adapter.dart';
import '../adapters/milestone_record_adapter.dart';
import '../adapters/supplement_record_adapter.dart';
import '../adapters/moment_record_adapter.dart';
import '../adapters/simple_record_adapter.dart';
import '../adapters/food_record_adapter.dart';
import '../adapters/temperature_record_adapter.dart';
import 'hive_helper.dart';

class DataService extends ChangeNotifier {
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

  Future<void> init() async {
    // 从 Hive 加载数据
    _loadAllData();
    
    // 加载宝宝信息
    final settingsBox = HiveHelper.settingsBox;
    _babyName = settingsBox.get('baby_name', defaultValue: '宝宝');
    final birthdayStr = settingsBox.get('baby_birthday');
    if (birthdayStr != null) {
      _babyBirthday = DateTime.parse(birthdayStr);
    }
    final themeIndex = settingsBox.get('theme_mode', defaultValue: 0);
    _themeMode = ThemeMode.values[themeIndex];
    
    notifyListeners();
  }

  void _loadAllData() {
    // 加载喂奶记录
    final feedingBox = HiveHelper.feedingBox;
    _feedingRecords = feedingBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    // 加载尿布记录
    final diaperBox = HiveHelper.diaperBox;
    _diaperRecords = diaperBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    // 加载睡眠记录
    final sleepBox = HiveHelper.sleepBox;
    _sleepRecords = sleepBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    // 加载成长记录
    final growthBox = HiveHelper.growthBox;
    _growthRecords = growthBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 加载里程碑记录
    final milestoneBox = HiveHelper.milestoneBox;
    _milestoneRecords = milestoneBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 加载营养补充记录
    final supplementBox = HiveHelper.supplementBox;
    _supplementRecords = supplementBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 加载动态记录
    final momentsBox = HiveHelper.momentsBox;
    _momentRecords = momentsBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // 加载通用记录
    final simpleBox = HiveHelper.simpleBox;
    _simpleRecords = simpleBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    // 加载辅食记录
    final foodBox = HiveHelper.foodBox;
    _foodRecords = foodBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    // 加载体温记录
    final tempBox = HiveHelper.tempBox;
    _tempRecords = tempBox.values.map((box) => box.toModel()).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    _initialized = true;
  }

  // ---- 宝宝信息 ----
  Future<void> setBabyInfo(String name, DateTime birthday) async {
    _babyName = name;
    _babyBirthday = birthday;
    
    final settingsBox = HiveHelper.settingsBox;
    await settingsBox.put('baby_name', name);
    await settingsBox.put('baby_birthday', birthday.toIso8601String());
    
    notifyListeners();
  }

  // ---- 主题切换 ----
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final settingsBox = HiveHelper.settingsBox;
    await settingsBox.put('theme_mode', mode.index);
    notifyListeners();
  }

  /// 从 Hive 重新加载所有数据（云端同步后调用）
  Future<void> reload() async {
    _loadAllData();
    notifyListeners();
  }

  // ---- 自动同步 ----
  Future<void> _autoSync() async {
    if (!AuthService.isLoggedIn) return;
    try {
      await SyncService.uploadAll(this);
    } catch (_) {}
  }

  bool _initialized = false;

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_initialized) _autoSync();
  }

  // ---- 喂奶 ----
  Future<void> addFeeding(FeedingRecord record) async {
    final box = FeedingRecordBox.fromModel(record);
    await HiveHelper.feedingBox.put(record.id, box);
    _feedingRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteFeeding(String id) async {
    await HiveHelper.feedingBox.delete(id);
    _feedingRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<FeedingRecord> todayFeedings() {
    final now = DateTime.now();
    return _feedingRecords.where((r) =>
      r.time.year == now.year && r.time.month == now.month && r.time.day == now.day
    ).toList();
  }

  // ---- 尿布 ----
  Future<void> addDiaper(DiaperRecord record) async {
    final box = DiaperRecordBox.fromModel(record);
    await HiveHelper.diaperBox.put(record.id, box);
    _diaperRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteDiaper(String id) async {
    await HiveHelper.diaperBox.delete(id);
    _diaperRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<DiaperRecord> todayDiapers() {
    final now = DateTime.now();
    return _diaperRecords.where((r) =>
      r.time.year == now.year && r.time.month == now.month && r.time.day == now.day
    ).toList();
  }

  // ---- 营养补充 ----
  Future<void> setSupplement(SupplementRecord record) async {
    final todayKey = record.date.toIso8601String().substring(0, 10);
    final existingIdx = _supplementRecords.indexWhere(
      (r) => r.date.toIso8601String().substring(0, 10) == todayKey
    );
    
    if (existingIdx >= 0) {
      final oldId = _supplementRecords[existingIdx].id;
      _supplementRecords[existingIdx] = record;
      final box = SupplementRecordBox.fromModel(record);
      await HiveHelper.supplementBox.put(oldId, box);
    } else {
      _supplementRecords.insert(0, record);
      final box = SupplementRecordBox.fromModel(record);
      await HiveHelper.supplementBox.put(record.id, box);
    }
    notifyListeners();
  }

  Future<void> deleteSupplement(String id) async {
    await HiveHelper.supplementBox.delete(id);
    _supplementRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  SupplementRecord? todaySupplement() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      return _supplementRecords.firstWhere(
        (r) => r.date.toIso8601String().substring(0, 10) == today
      );
    } catch (e) {
      return null;
    }
  }

  List<SupplementRecord> allSupplementRecords() => List.unmodifiable(_supplementRecords);

  // ---- 睡眠 ----
  Future<void> addSleep(SleepRecord record) async {
    final box = SleepRecordBox.fromModel(record);
    await HiveHelper.sleepBox.put(record.id, box);
    _sleepRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> updateSleep(SleepRecord record) async {
    final box = SleepRecordBox.fromModel(record);
    await HiveHelper.sleepBox.put(record.id, box);
    
    final idx = _sleepRecords.indexWhere((r) => r.id == record.id);
    if (idx >= 0) {
      _sleepRecords[idx] = record;
      notifyListeners();
    }
  }

  Future<void> deleteSleep(String id) async {
    await HiveHelper.sleepBox.delete(id);
    _sleepRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  SleepRecord? get ongoingSleep {
    try {
      return _sleepRecords.firstWhere((r) => r.isOngoing);
    } catch (e) {
      return null;
    }
  }

  // ---- 生长发育 ----
  Future<void> addGrowth(GrowthRecord record) async {
    final box = GrowthRecordBox.fromModel(record);
    await HiveHelper.growthBox.put(record.id, box);
    _growthRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteGrowth(String id) async {
    await HiveHelper.growthBox.delete(id);
    _growthRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---- 里程碑 ----
  Future<void> addMilestone(MilestoneRecord record) async {
    final box = MilestoneRecordBox.fromModel(record);
    await HiveHelper.milestoneBox.put(record.id, box);
    _milestoneRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    await HiveHelper.milestoneBox.delete(id);
    _milestoneRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---- 动态 ----
  Future<void> addMoment(MomentRecord record) async {
    final box = MomentRecordBox.fromModel(record);
    await HiveHelper.momentsBox.put(record.id, box);
    _momentRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteMoment(String id) async {
    await HiveHelper.momentsBox.delete(id);
    _momentRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---- 通用记录(尿急/粑粑/用药) ----
  Future<void> addSimpleRecord(SimpleRecord record) async {
    final box = SimpleRecordBox.fromModel(record);
    await HiveHelper.simpleBox.put(record.id, box);
    _simpleRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteSimpleRecord(String id) async {
    await HiveHelper.simpleBox.delete(id);
    _simpleRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<SimpleRecord> simpleRecordsByCategory(String category) {
    return _simpleRecords.where((r) => r.category == category).toList();
  }

  // ---- 辅食 ----
  Future<void> addFood(FoodRecord record) async {
    final box = FoodRecordBox.fromModel(record);
    await HiveHelper.foodBox.put(record.id, box);
    _foodRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteFood(String id) async {
    await HiveHelper.foodBox.delete(id);
    _foodRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---- 体温 ----
  Future<void> addTemperature(TemperatureRecord record) async {
    final box = TemperatureRecordBox.fromModel(record);
    await HiveHelper.tempBox.put(record.id, box);
    _tempRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteTemperature(String id) async {
    await HiveHelper.tempBox.delete(id);
    _tempRecords.removeWhere((r) => r.id == id);
    notifyListeners();
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
