import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

import '../models/transaction.dart';

/// Helper class untuk mengelola database SQLite.
/// Menggunakan Singleton Pattern untuk satu koneksi database.
class DatabaseHelper {
  // Private constructor
  DatabaseHelper._privateConstructor();

  // Instance tunggal DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Variabel database
  static Database? _database;
  static const String _databaseName = 'money_notes.db';
  static const int _databaseVersion = 1;
  static const String tableTransactions = 'transactions';

  /// Mendapatkan referensi database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Membuat dan membuka file database.
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Membuat tabel transactions saat database pertama kali dibuat.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal   TEXT    NOT NULL,
        nominal   REAL    NOT NULL,
        keterangan TEXT,
        jenis     TEXT    NOT NULL
      )
    ''');
  }

  // =========================================================
  // --- FUNGSI CRUD DATABASE ---
  // =========================================================

  // --- CREATE (Insert) ---

  /// Menyimpan transaksi baru ke database.
  Future<int> insertTransaction(Transaction transaction) async {
    Database db = await database;
    Map<String, dynamic> row = transaction.toMap();
    row.remove('id'); // ID otomatis dibuat oleh database (AUTOINCREMENT)
    return await db.insert(tableTransactions, row);
  }

  // --- READ (Query All) ---

  /// Mengambil semua data transaksi dari database.
  Future<List<Transaction>> getAllTransactions() async {
    Database db = await database;

    // Mengambil data dan mengurutkannya dari yang terbaru
    List<Map<String, dynamic>> maps = await db.query(
      tableTransactions,
      orderBy: 'tanggal DESC',
    );

    // Mengubah hasil Map dari SQLite menjadi List<Transaction>
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }
}