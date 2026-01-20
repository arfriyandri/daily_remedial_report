import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/remedial_report_model.dart';
import '../models/master_nasabah_model.dart';
class DBHelper {
  static Database? _db;

  // ======================
  // INIT DATABASE
  // ======================
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> getMasterNasabah() async {
    final db = await database;
    return await db.query('master_nasabah');
  }

static Future<List<MasterNasabah>> searchNasabah(String keyword) async {
  final db = await database;

  final result = await db.query(
    'master_nasabah',
    where: 'nama LIKE ?',
    whereArgs: ['%$keyword%'],
    limit: 10,
  );

  return result.map((e) => MasterNasabah.fromMap(e)).toList();
}


  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'remedial_report.db');

    return await openDatabase(
      path,
      version: 1, // ⬅️ TURUNKAN KE 1 (AMAN)
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE laporan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            namaRemedial TEXT,
            namaNasabah TEXT,
            alamat TEXT,
            nominal TEXT,
            status TEXT,
            produk TEXT,
            hasil TEXT,
            tanggalLaporan TEXT,
            rencanaKunjungan TEXT,
            fotoPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS master_nasabah (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            alamat TEXT,
            produk TEXT,
            nominal TEXT
          )
        ''');
      },
    );
  }

  // ======================
  // INSERT DATA (ADD)
  // ======================
  static Future<int> insert(RemedialReport data) async {
    final db = await database;

    final map = data.toMap();
    map.remove('id'); // ⬅️ AUTOINCREMENT

    return await db.insert(
      'laporan',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ======================
  // GET ALL DATA
  // ======================
  static Future<List<RemedialReport>> getAll() async {
    final db = await database;

    final result = await db.query('laporan', orderBy: 'tanggalLaporan DESC');

    return result.map((e) => RemedialReport.fromMap(e)).toList();
  }

  // ======================
  // UPDATE DATA (EDIT)
  // ======================
  static Future<int> update(RemedialReport data) async {
    final db = await database;

    final map = data.toMap();
    map.remove('id');

    return await db.update(
      'laporan',
      map,
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // ======================
  // DELETE DATA
  // ======================
  static Future<int> delete(int id) async {
    final db = await database;

    return await db.delete('laporan', where: 'id = ?', whereArgs: [id]);
  }
}
