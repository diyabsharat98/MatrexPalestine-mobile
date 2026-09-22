import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'local_database.dart';

class OutboxItem {
  const OutboxItem({
    required this.uuid,
    required this.type,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.errorMessageEn,
    this.errorMessageAr,
  });

  final String uuid;
  final String type;
  final Map<String, dynamic> payload;
  final String status;
  final String? errorMessageEn;
  final String? errorMessageAr;
  final DateTime createdAt;

  String? errorMessage(bool isArabic) => isArabic ? (errorMessageAr ?? errorMessageEn) : errorMessageEn;

  factory OutboxItem.fromRow(Map<String, dynamic> row) {
    final rawError = row['error_message'] as String?;
    Map<String, dynamic>? error;
    if (rawError != null) {
      try {
        error = jsonDecode(rawError) as Map<String, dynamic>;
      } catch (_) {
        error = {'en': rawError};
      }
    }

    return OutboxItem(
      uuid: row['uuid'] as String,
      type: row['type'] as String,
      payload: jsonDecode(row['payload'] as String) as Map<String, dynamic>,
      status: row['status'] as String,
      errorMessageEn: error?['en'] as String?,
      errorMessageAr: error?['ar'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// A durable, on-device queue of transactions created while offline (spec
/// section 2). Nothing here ever talks to the network — [SyncManager]
/// drains this queue once connectivity is available.
class SyncOutboxService {
  SyncOutboxService(this._db);

  final LocalDatabase _db;

  Future<void> enqueue({required String uuid, required String type, required Map<String, dynamic> payload}) async {
    final db = await _db.database;
    await db.insert('sync_outbox', {
      'uuid': uuid,
      'type': type,
      'payload': jsonEncode(payload),
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<OutboxItem>> pending() async {
    final db = await _db.database;
    final rows = await db.query('sync_outbox', orderBy: 'created_at ASC');
    return rows.map(OutboxItem.fromRow).toList();
  }

  Future<int> pendingCount() async {
    final db = await _db.database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM sync_outbox WHERE status != 'synced'");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> markSynced(String uuid) async {
    final db = await _db.database;
    await db.delete('sync_outbox', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<void> markFailed(String uuid, {required String messageEn, String? messageAr}) async {
    final db = await _db.database;
    await db.update(
      'sync_outbox',
      {'status': 'failed', 'error_message': jsonEncode({'en': messageEn, 'ar': messageAr})},
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<void> remove(String uuid) async {
    final db = await _db.database;
    await db.delete('sync_outbox', where: 'uuid = ?', whereArgs: [uuid]);
  }
}

final syncOutboxServiceProvider = Provider<SyncOutboxService>((ref) {
  return SyncOutboxService(ref.watch(localDatabaseProvider));
});
