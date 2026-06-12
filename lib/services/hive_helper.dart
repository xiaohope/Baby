import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/feeding_record.dart';
import '../models/diaper_record.dart';
import '../models/sleep_record.dart';
import '../models/growth_record.dart';
import '../models/milestone_record.dart';
import '../models/supplement_record.dart';
import '../adapters/feeding_record_adapter.dart';
import '../adapters/diaper_record_adapter.dart';
import '../adapters/sleep_record_adapter.dart';
import '../adapters/growth_record_adapter.dart';
import '../adapters/milestone_record_adapter.dart';
import '../adapters/supplement_record_adapter.dart';

class HiveHelper {
  static const String _feedingBox = 'feeding_records';
  static const String _diaperBox = 'diaper_records';
  static const String _sleepBox = 'sleep_records';
  static const String _growthBox = 'growth_records';
  static const String _milestoneBox = 'milestone_records';
  static const String _supplementBox = 'supplement_records';
  static const String _settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // 注册适配器
    Hive.registerAdapter(FeedingRecordBoxAdapter());
    Hive.registerAdapter(DiaperRecordBoxAdapter());
    Hive.registerAdapter(SleepRecordBoxAdapter());
    Hive.registerAdapter(GrowthRecordBoxAdapter());
    Hive.registerAdapter(MilestoneRecordBoxAdapter());
    Hive.registerAdapter(SupplementRecordBoxAdapter());

    // 打开所有 box
    await Hive.openBox<FeedingRecordBox>(_feedingBox);
    await Hive.openBox<DiaperRecordBox>(_diaperBox);
    await Hive.openBox<SleepRecordBox>(_sleepBox);
    await Hive.openBox<GrowthRecordBox>(_growthBox);
    await Hive.openBox<MilestoneRecordBox>(_milestoneBox);
    await Hive.openBox(_settingsBox);
  }

  // 获取所有 box 的引用
  static Box<FeedingRecordBox> get feedingBox => Hive.box<FeedingRecordBox>(_feedingBox);
  static Box<DiaperRecordBox> get diaperBox => Hive.box<DiaperRecordBox>(_diaperBox);
  static Box<SleepRecordBox> get sleepBox => Hive.box<SleepRecordBox>(_sleepBox);
  static Box<GrowthRecordBox> get growthBox => Hive.box<GrowthRecordBox>(_growthBox);
  static Box<MilestoneRecordBox> get milestoneBox => Hive.box<MilestoneRecordBox>(_milestoneBox);
  static Box get settingsBox => Hive.box(_settingsBox);

  // 关闭所有 box
  static Future<void> close() async {
    await Hive.close();
  }
}
