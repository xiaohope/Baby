import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../models/feeding_record.dart';
import '../models/diaper_record.dart';
import '../models/sleep_record.dart';
import '../models/growth_record.dart';
import '../models/milestone_record.dart';
import '../models/supplement_record.dart';
import '../models/moment_record.dart';
import '../models/simple_record.dart';
import '../models/food_record.dart';
import '../models/temperature_record.dart';
import 'hive_helper.dart';
import '../adapters/feeding_record_adapter.dart';
import '../adapters/diaper_record_adapter.dart';
import '../adapters/sleep_record_adapter.dart';
import '../adapters/growth_record_adapter.dart';
import '../adapters/milestone_record_adapter.dart';
import '../adapters/moment_record_adapter.dart';
import '../adapters/simple_record_adapter.dart';
import '../adapters/food_record_adapter.dart';
import '../adapters/temperature_record_adapter.dart';
import '../adapters/supplement_record_adapter.dart';

class SyncService {
  /// 上传所有本地记录到服务器
  static Future<Map> uploadAll(DataService ds) async {
    if (!AuthService.isLoggedIn) return {'uploaded': 0, 'errors': 0};

    final records = <Map<String, dynamic>>[];

    // 喂奶
    for (final r in ds.feedingRecords) {
      records.add({
        'table': 'feeding',
        'data': {
          'id': r.id, 'time': r.time.toIso8601String(), 'type': r.type.index,
          'breast_minutes': r.breastMinutes, 'bottle_ml': r.bottleMl,
          'note': r.note, 'breast_side': r.breastSide?.index,
        },
      });
    }
    // 尿布
    for (final r in ds.diaperRecords) {
      records.add({
        'table': 'diaper',
        'data': {
          'id': r.id, 'time': r.time.toIso8601String(), 'type': r.type.index,
          'poop_color': r.poopColor, 'note': r.note,
        },
      });
    }
    // 睡眠
    for (final r in ds.sleepRecords) {
      records.add({
        'table': 'sleep',
        'data': {
          'id': r.id, 'start_time': r.startTime.toIso8601String(),
          'end_time': r.endTime?.toIso8601String(), 'quality': r.quality?.index,
          'note': r.note,
        },
      });
    }
    // 成长
    for (final r in ds.growthRecords) {
      records.add({
        'table': 'growth',
        'data': {
          'id': r.id, 'date': r.date.toIso8601String().substring(0, 10),
          'weight_kg': r.weightKg, 'height_cm': r.heightCm,
          'head_circumference_cm': r.headCircumferenceCm, 'note': r.note,
        },
      });
    }
    // 里程碑
    for (final r in ds.milestoneRecords) {
      records.add({
        'table': 'milestone',
        'data': {
          'id': r.id, 'date': r.date.toIso8601String().substring(0, 10),
          'title': r.title, 'note': r.note, 'category': r.category,
        },
      });
    }
    // 补充
    for (final r in ds.allSupplementRecords()) {
      records.add({
        'table': 'supplement',
        'data': {
          'id': r.id, 'date': r.date.toIso8601String().substring(0, 10),
          'items': r.items,
        },
      });
    }
    // 动态
    for (final r in ds.momentRecords) {
      records.add({
        'table': 'moment',
        'data': {
          'id': r.id, 'date': r.date.toIso8601String(),
          'text_content': r.text, 'images': r.imagePaths,
        },
      });
    }
    // 简单记录（尿尿/粑粑/用药/喝水/洗澡）
    for (final r in ds.simpleRecords) {
      records.add({
        'table': 'simple',
        'data': {
          'id': r.id, 'category': r.category,
          'time': r.time.toIso8601String(), 'note': r.note,
        },
      });
    }
    // 辅食
    for (final r in ds.foodRecords) {
      records.add({
        'table': 'food',
        'data': {
          'id': r.id, 'name': r.name, 'portion': r.portion,
          'feeling': r.feeling, 'time': r.time.toIso8601String(),
          'note': r.note,
        },
      });
    }
    // 体温
    for (final r in ds.tempRecords) {
      records.add({
        'table': 'temperature',
        'data': {
          'id': r.id, 'temperature': r.temperature,
          'time': r.time.toIso8601String(), 'note': r.note,
        },
      });
    }

    if (records.isNotEmpty) {
      await ApiService.uploadRecords(records);
    }

    // 同步宝宝信息
    try {
      await ApiService.uploadSettings({
        'babyName': ds.babyName,
        'babyBirthday': ds.babyBirthday?.toIso8601String() ?? '',
      });
    } catch (_) {}

    return {'uploaded': records.length, 'errors': 0};
  }

  /// 从云端下载所有数据到本地
  static Future<int> downloadAll(DataService ds) async {
    if (!AuthService.isLoggedIn) return 0;
    try {
      final data = await ApiService.syncRecords();
      int count = 0;

      // 喂奶
      if (data['feeding_records'] != null) {
        for (final r in data['feeding_records'] as List) {
          final box = FeedingRecordBox.fromModel(FeedingRecord(
            id: r['id'], time: DateTime.parse(r['time']),
            type: FeedingType.values[r['type']],
            breastMinutes: r['breast_minutes'], bottleMl: r['bottle_ml'],
            note: r['note'], breastSide: r['breast_side'] != null ? BreastSide.values[r['breast_side']] : null,
          ));
          await HiveHelper.feedingBox.put(r['id'], box);
          count++;
        }
      }
      // 尿布
      if (data['diaper_records'] != null) {
        for (final r in data['diaper_records'] as List) {
          final box = DiaperRecordBox.fromModel(DiaperRecord(
            id: r['id'], time: DateTime.parse(r['time']),
            type: DiaperType.values[r['type']],
            poopColor: r['poop_color'], note: r['note'],
          ));
          await HiveHelper.diaperBox.put(r['id'], box);
          count++;
        }
      }
      // 睡眠
      if (data['sleep_records'] != null) {
        for (final r in data['sleep_records'] as List) {
          final box = SleepRecordBox.fromModel(SleepRecord(
            id: r['id'], startTime: DateTime.parse(r['start_time']),
            endTime: r['end_time'] != null ? DateTime.parse(r['end_time']) : null,
            quality: r['quality'] != null ? SleepQuality.values[r['quality']] : null,
            note: r['note'],
          ));
          await HiveHelper.sleepBox.put(r['id'], box);
          count++;
        }
      }
      // 成长
      if (data['growth_records'] != null) {
        for (final r in data['growth_records'] as List) {
          final box = GrowthRecordBox.fromModel(GrowthRecord(
            id: r['id'], date: DateTime.parse(r['date']),
            weightKg: (r['weight_kg'] as num?)?.toDouble(),
            heightCm: (r['height_cm'] as num?)?.toDouble(),
            headCircumferenceCm: (r['head_circumference_cm'] as num?)?.toDouble(),
            note: r['note'],
          ));
          await HiveHelper.growthBox.put(r['id'], box);
          count++;
        }
      }
      // 里程碑
      if (data['milestone_records'] != null) {
        for (final r in data['milestone_records'] as List) {
          final box = MilestoneRecordBox.fromModel(MilestoneRecord(
            id: r['id'], date: DateTime.parse(r['date']),
            title: r['title'], note: r['note'], category: r['category'] ?? 'milestone',
          ));
          await HiveHelper.milestoneBox.put(r['id'], box);
          count++;
        }
      }
      // 动态
      if (data['moment_records'] != null) {
        for (final r in data['moment_records'] as List) {
          final box = MomentRecordBox.fromModel(MomentRecord(
            id: r['id'], date: DateTime.parse(r['date']),
            text: r['text_content'] ?? '',
            imagePaths: r['images'] != null ? List<String>.from(r['images']) : [],
          ));
          await HiveHelper.momentsBox.put(r['id'], box);
          count++;
        }
      }
      // 简单记录
      if (data['simple_records'] != null) {
        for (final r in data['simple_records'] as List) {
          final box = SimpleRecordBox.fromModel(SimpleRecord(
            id: r['id'], category: r['category'],
            time: DateTime.parse(r['time']), note: r['note'] ?? '',
          ));
          await HiveHelper.simpleBox.put(r['id'], box);
          count++;
        }
      }
      // 辅食
      if (data['food_records'] != null) {
        for (final r in data['food_records'] as List) {
          final box = FoodRecordBox.fromModel(FoodRecord(
            id: r['id'], name: r['name'],
            portion: r['portion'], feeling: r['feeling'],
            time: DateTime.parse(r['time']), note: r['note'],
          ));
          await HiveHelper.foodBox.put(r['id'], box);
          count++;
        }
      }
      // 体温
      if (data['temperature_records'] != null) {
        for (final r in data['temperature_records'] as List) {
          final box = TemperatureRecordBox.fromModel(TemperatureRecord(
            id: r['id'], temperature: (r['temperature'] as num).toDouble(),
            time: DateTime.parse(r['time']), note: r['note'],
          ));
          await HiveHelper.tempBox.put(r['id'], box);
          count++;
        }
      }

      // 补充
      if (data['supplement_records'] != null) {
        for (final r in data['supplement_records'] as List) {
          final box = SupplementRecordBox.fromModel(SupplementRecord(
            id: r['id'], date: DateTime.parse(r['date']),
            items: r['items'] != null ? List<String>.from(r['items']) : [],
          ));
          await HiveHelper.supplementBox.put(r['id'], box);
          count++;
        }
      }

      // 同步宝宝信息
      try {
        final settings = await ApiService.downloadSettings();
        if (settings['babyName'] != null) {
          final settingsBox = HiveHelper.settingsBox;
          await settingsBox.put('baby_name', settings['babyName']);
        }
      } catch (_) {}

      // 重新加载数据
      await ds.reload();
      return count;
    } catch (_) {
      return 0;
    }
  }
}
