import 'package:hive_flutter/hive_flutter.dart';
import '../adapters/feeding_record_adapter.dart';
import '../adapters/diaper_record_adapter.dart';
import '../adapters/sleep_record_adapter.dart';
import '../adapters/growth_record_adapter.dart';
import '../adapters/milestone_record_adapter.dart';
import '../adapters/supplement_record_adapter.dart';
import '../adapters/moment_record_adapter.dart';
import '../adapters/simple_record_adapter.dart';

class HiveHelper {
  static const String _feedingBox = 'feeding_records';
  static const String _diaperBox = 'diaper_records';
  static const String _sleepBox = 'sleep_records';
  static const String _growthBox = 'growth_records';
  static const String _milestoneBox = 'milestone_records';
  static const String _supplementBox = 'supplement_records';
  static const String _momentsBox = 'moments';
  static const String _simpleBox = 'simple_records';
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
    Hive.registerAdapter(MomentRecordBoxAdapter());
    Hive.registerAdapter(SimpleRecordBoxAdapter());

    // 打开所有 box
    await Hive.openBox<FeedingRecordBox>(_feedingBox);
    await Hive.openBox<DiaperRecordBox>(_diaperBox);
    await Hive.openBox<SleepRecordBox>(_sleepBox);
    await Hive.openBox<GrowthRecordBox>(_growthBox);
    await Hive.openBox<MilestoneRecordBox>(_milestoneBox);
    await Hive.openBox<SupplementRecordBox>(_supplementBox);
    await Hive.openBox<MomentRecordBox>(_momentsBox);
    await Hive.openBox<SimpleRecordBox>(_simpleBox);
    await Hive.openBox(_settingsBox);
  }

  // 获取所有 box 的引用
  static Box<FeedingRecordBox> get feedingBox => Hive.box<FeedingRecordBox>(_feedingBox);
  static Box<DiaperRecordBox> get diaperBox => Hive.box<DiaperRecordBox>(_diaperBox);
  static Box<SleepRecordBox> get sleepBox => Hive.box<SleepRecordBox>(_sleepBox);
  static Box<GrowthRecordBox> get growthBox => Hive.box<GrowthRecordBox>(_growthBox);
  static Box<MilestoneRecordBox> get milestoneBox => Hive.box<MilestoneRecordBox>(_milestoneBox);
  static Box<SupplementRecordBox> get supplementBox => Hive.box<SupplementRecordBox>(_supplementBox);
  static Box<MomentRecordBox> get momentsBox => Hive.box<MomentRecordBox>(_momentsBox);
  static Box<SimpleRecordBox> get simpleBox => Hive.box<SimpleRecordBox>(_simpleBox);
  static Box get settingsBox => Hive.box(_settingsBox);

  // 关闭所有 box
  static Future<void> close() async {
    await Hive.close();
  }
}
