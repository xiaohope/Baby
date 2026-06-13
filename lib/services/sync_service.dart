import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';

class SyncService {
  /// 上传所有本地记录到服务器（手动全量同步用）
  static Future<Map> uploadAll(DataService ds) async {
    if (!AuthService.isLoggedIn) return {'uploaded': 0, 'errors': 0, 'error': '未登录'};
    final records = <Map<String, dynamic>>[];

    for (final r in ds.feedingRecords) {
      records.add({'table': 'feeding', 'data': _toMap(r, 'feeding')});
    }
    for (final r in ds.diaperRecords) {
      records.add({'table': 'diaper', 'data': _toMap(r, 'diaper')});
    }
    for (final r in ds.sleepRecords) {
      records.add({'table': 'sleep', 'data': _toMap(r, 'sleep')});
    }
    for (final r in ds.growthRecords) {
      records.add({'table': 'growth', 'data': _toMap(r, 'growth')});
    }
    for (final r in ds.milestoneRecords) {
      records.add({'table': 'milestone', 'data': _toMap(r, 'milestone')});
    }
    for (final r in ds.allSupplementRecords()) {
      records.add({'table': 'supplement', 'data': _toMap(r, 'supplement')});
    }
    for (final r in ds.momentRecords) {
      records.add({'table': 'moment', 'data': _toMap(r, 'moment')});
    }
    for (final r in ds.simpleRecords) {
      records.add({'table': 'simple', 'data': _toMap(r, 'simple')});
    }
    for (final r in ds.foodRecords) {
      records.add({'table': 'food', 'data': _toMap(r, 'food')});
    }
    for (final r in ds.tempRecords) {
      records.add({'table': 'temperature', 'data': _toMap(r, 'temperature')});
    }

    if (records.isEmpty) return {'uploaded': 0, 'errors': 0};

    final result = await ApiService.uploadRecords(records);
    return result;
  }

  static Map<String, dynamic> _toMap(dynamic r, String type) {
    switch (type) {
      case 'feeding': return {
        'id': r.id, 'time': r.time.toIso8601String(), 'type': r.type.index,
        'breast_minutes': r.breastMinutes, 'bottle_ml': r.bottleMl,
        'note': r.note, 'breast_side': r.breastSide?.index,
      };
      case 'diaper': return {
        'id': r.id, 'time': r.time.toIso8601String(), 'type': r.type.index,
        'poop_color': r.poopColor, 'note': r.note,
      };
      case 'sleep': return {
        'id': r.id, 'start_time': r.startTime.toIso8601String(),
        'end_time': r.endTime?.toIso8601String(), 'quality': r.quality?.index, 'note': r.note,
      };
      case 'growth': return {
        'id': r.id, 'date': r.date.toIso8601String().substring(0, 10),
        'weight_kg': r.weightKg, 'height_cm': r.heightCm,
        'head_circumference_cm': r.headCircumferenceCm, 'note': r.note,
      };
      case 'milestone': return {
        'id': r.id, 'date': r.date.toIso8601String().substring(0, 10),
        'title': r.title, 'note': r.note, 'category': r.category,
      };
      case 'supplement': return {
        'id': r.id, 'date': r.date.toIso8601String().substring(0, 10), 'items': r.items,
      };
      case 'moment': return {
        'id': r.id, 'date': r.date.toIso8601String(), 'text_content': r.text, 'images': r.imagePaths,
      };
      case 'simple': return {
        'id': r.id, 'category': r.category, 'time': r.time.toIso8601String(), 'note': r.note,
      };
      case 'food': return {
        'id': r.id, 'name': r.name, 'portion': r.portion, 'feeling': r.feeling,
        'time': r.time.toIso8601String(), 'note': r.note,
      };
      case 'temperature': return {
        'id': r.id, 'temperature': r.temperature, 'time': r.time.toIso8601String(), 'note': r.note,
      };
      default: return {};
    }
  }
}
