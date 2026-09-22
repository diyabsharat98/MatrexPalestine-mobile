import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_database.dart';

/// A simple read-through cache for reference data a rep needs while
/// offline — the full product catalog, their customers, and each
/// customer's recent invoices (spec section 2). Every successful online
/// fetch overwrites the cache for that key; a failed (offline) fetch reads
/// whatever was last cached.
class ReferenceCacheService {
  ReferenceCacheService(this._db);

  final LocalDatabase _db;

  Future<void> replaceAll(String table, List<({int id, Map<String, dynamic> json})> rows) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete(table);
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert(table, {'id': row.id, 'data': jsonEncode(row.json)});
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, dynamic>>> all(String table) async {
    final db = await _db.database;
    final rows = await db.query(table);
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  Future<void> replaceCustomerSales(int customerId, List<({int id, Map<String, dynamic> json})> rows) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('cached_sales', where: 'customer_id = ?', whereArgs: [customerId]);
      final batch = txn.batch();
      for (final row in rows) {
        batch.insert('cached_sales', {'id': row.id, 'customer_id': customerId, 'data': jsonEncode(row.json)});
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, dynamic>>> customerSales(int customerId) async {
    final db = await _db.database;
    final rows = await db.query('cached_sales', where: 'customer_id = ?', whereArgs: [customerId]);
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }
}

final referenceCacheServiceProvider = Provider<ReferenceCacheService>((ref) {
  return ReferenceCacheService(ref.watch(localDatabaseProvider));
});
