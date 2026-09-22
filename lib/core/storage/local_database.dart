import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The on-device SQLite database backing offline support (spec section 2):
/// a durable outbox for transactions created while offline, plus a
/// read-through cache of reference data (products/customers/recent sales)
/// so those screens keep working without a connection.
class LocalDatabase {
  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'beverage_distribution_offline.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sync_outbox (
            uuid TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            payload TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            error_message TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE TABLE cached_products (id INTEGER PRIMARY KEY, data TEXT NOT NULL)');
        await db.execute('CREATE TABLE cached_customers (id INTEGER PRIMARY KEY, data TEXT NOT NULL)');
        await db.execute('CREATE TABLE cached_sales (id INTEGER PRIMARY KEY, customer_id INTEGER, data TEXT NOT NULL)');
      },
    );
  }
}

final localDatabaseProvider = Provider<LocalDatabase>((ref) => LocalDatabase());
