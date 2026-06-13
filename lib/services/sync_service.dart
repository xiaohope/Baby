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

    if (records.isEmpty) return {'uploaded': 0, 'errors': 0};

    return await ApiService.uploadRecords(records);
  }
}
