import 'package:flutter_mvvm_riverpod/features/tracker_list/model/tracker_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../constants/database_constants.dart';
import '../../common/local/database_provider.dart';
import '../../common/remote/api_client.dart';

part 'tracker_list_repository.g.dart';

@riverpod
Future<TrackerListRepository> trackerListRepository(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final db = await ref.watch(databaseProvider.future);
  return TrackerListRepository(apiClient, db);
}

class TrackerListRepository {
  final ApiClient apiClient;
  final Database database;

  TrackerListRepository(this.apiClient, this.database);

  Future<List<TrackerItem>> getTrackeresFromRemote() async {
    try {
      final response = await apiClient.get<List<dynamic>>('/trackers');
      final Trackeres =
          response.map((json) => TrackerItem.fromJson(json)).toList();
      return Trackeres;
    } catch (e) {
      throw Exception('Failed to fetch Trackeres from remote: $e');
    }
  }

  Future<List<TrackerItem>> getTrackeres() async {
    // TODO: remove this delay
    await Future.delayed(Duration(seconds: 1));
    // final maps = await database.query(TrackerTable.tableName);
    final maps = await database.query(
      TrackerTable.tableName,
      orderBy: '${TrackerTable.columnDate} DESC', // Sorts latest/newest first
    );
    return maps.map(TrackerItem.fromJson).toList();
  }

  Future<List<TrackerItem>> getTrackersByDate(DateTime targetDate) async {
    final startOfDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    ).millisecondsSinceEpoch;

    final endOfDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;

    // 2. Query using SQL BETWEEN operator
    final maps = await database.query(
      TrackerTable.tableName,
      where: '${TrackerTable.columnDate} BETWEEN ? AND ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: '${TrackerTable.columnDate} DESC',
    );

    return maps.map(TrackerItem.fromJson).toList();
  }

  Future<TrackerItem?> getTrackerFromRemote(String id) async {
    try {
      final response =
          await apiClient.get<Map<String, dynamic>>('/trackers/$id');
      final Tracker = TrackerItem.fromJson(response);
      return Tracker;
    } catch (e) {
      throw Exception('Failed to fetch Tracker from remote: $e');
    }
  }

  Future<TrackerItem?> getTracker(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      TrackerTable.tableName,
      where: '${TrackerTable.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TrackerItem.fromJson(maps[0]);
  }

  Future<void> insertTracker(TrackerItem Tracker) async {
    await database.insert(
      TrackerTable.tableName,
      Tracker.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTracker(TrackerItem tracker) async {
    final map = tracker.toJson()..remove(TrackerTable.columnId);
    map[TrackerTable.columnDate] = DateTime.now().millisecondsSinceEpoch;

    await database.update(
      TrackerTable.tableName,
      map,
      where: '${TrackerTable.columnId} = ?',
      whereArgs: [tracker.id],
    );
  }

  Future<void> deleteTracker(String id) async {
    await database.delete(
      TrackerTable.tableName,
      where: '${TrackerTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTotalAmountGroupedByType() async {
    final result = await database.rawQuery('''
    SELECT 
      ${TrackerTable.columnType} as type, 
      SUM(${TrackerTable.columnAmount}) as total 
    FROM ${TrackerTable.tableName}
    GROUP BY ${TrackerTable.columnType}
    ORDER BY total DESC
  ''');

    // Convert SQLite result list into a Map<String, int>
    // e.g., {'Expense': 4500, 'Income': 12000}
    final Map<String, int> totalsByType = {};
    for (final row in result) {
      final type = row['type'] as String;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      totalsByType[type] = total;
    }

    return totalsByType;
  }

  Future<Map<String, int>> getTotalAmountGroupedByTypeAndDate(
      DateTime? targetDate) async {
    DateTime newTargetDate = targetDate ?? DateTime.now();
    final startOfDay = DateTime(
      newTargetDate.year,
      newTargetDate.month,
      targetDate?.day ?? 1,
    ).millisecondsSinceEpoch;

    final endOfDay = DateTime(
      newTargetDate.year,
      targetDate?.month ?? newTargetDate.month + 1,
      targetDate?.day ?? 0,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;

    final result = await database.rawQuery('''
    SELECT 
      ${TrackerTable.columnType} as type,
      SUM(${TrackerTable.columnAmount}) as total
    FROM ${TrackerTable.tableName}
    WHERE ${TrackerTable.columnDate} BETWEEN ? AND ?
    GROUP BY ${TrackerTable.columnType}
    ORDER BY total DESC
  ''', [startOfDay, endOfDay]);

    // Convert SQLite result list into a Map<String, int>
    // e.g., {'Expense': 4500, 'Income': 12000}
    final Map<String, int> totalsByType = {};
    for (final row in result) {
      final type = row['type'] as String;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      totalsByType[type] = total;
    }

    return totalsByType;
  }
}
