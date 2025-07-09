import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'patient.dart';
import 'visit.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doctor_app.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            phone TEXT,
            imagePath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER,
            diagnosis TEXT,
            comments TEXT,
            dateTime TEXT,
            imagePath TEXT,
            FOREIGN KEY(patientId) REFERENCES patients(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE visits ADD COLUMN imagePath TEXT;');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE patients ADD COLUMN imagePath TEXT;');
        }
      },
    );
  }

  // Patient CRUD
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getPatients({String? query}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query('patients', where: 'name LIKE ?', whereArgs: ['%$query%']);
    } else {
      maps = await db.query('patients');
    }
    return maps.map((e) => Patient.fromMap(e)).toList();
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update('patients', patient.toMap(), where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // Visit CRUD
  Future<int> insertVisit(Visit visit) async {
    final db = await database;
    return await db.insert('visits', visit.toMap());
  }

  Future<List<Visit>> getVisits(int patientId) async {
    final db = await database;
    final maps = await db.query('visits', where: 'patientId = ?', whereArgs: [patientId], orderBy: 'dateTime DESC');
    return maps.map((e) => Visit.fromMap(e)).toList();
  }

  Future<int> updateVisit(Visit visit) async {
    final db = await database;
    return await db.update('visits', visit.toMap(), where: 'id = ?', whereArgs: [visit.id]);
  }

  Future<int> deleteVisit(int id) async {
    final db = await database;
    return await db.delete('visits', where: 'id = ?', whereArgs: [id]);
  }
} 