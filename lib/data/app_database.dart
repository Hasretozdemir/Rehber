import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/contact.dart';
import '../models/department.dart';
import '../models/duty_person.dart';
import '../utils/mock_data.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await instance.database;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'hospital_directory.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE departments(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category INTEGER NOT NULL,
            description TEXT,
            isEmergency INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE contacts(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            departmentId TEXT NOT NULL,
            departmentName TEXT NOT NULL,
            internalNumber TEXT NOT NULL,
            mobileNumber TEXT,
            role TEXT,
            email TEXT,
            avatarInitials TEXT,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE duties(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            departmentId TEXT NOT NULL,
            departmentName TEXT NOT NULL,
            role INTEGER NOT NULL,
            phone TEXT NOT NULL,
            dutyDate TEXT NOT NULL,
            dutyStartTime TEXT,
            dutyEndTime TEXT,
            notes TEXT,
            isCriticalUnit INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> ensureSeeded() async {
    final db = await database;

    final depCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM departments'),
    );
    if ((depCount ?? 0) == 0) {
      final batch = db.batch();
      for (final department in MockData.departments) {
        batch.insert(
          'departments',
          _departmentToDbMap(department),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }

    final contactCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contacts'),
    );
    if ((contactCount ?? 0) == 0) {
      final batch = db.batch();
      for (final contact in MockData.contacts) {
        batch.insert(
          'contacts',
          _contactToDbMap(contact),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }

    final dutyCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM duties'),
    );
    if ((dutyCount ?? 0) == 0) {
      final batch = db.batch();
      for (final duty in MockData.generateDutyList()) {
        batch.insert(
          'duties',
          _dutyToDbMap(duty),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<Department>> getDepartments() async {
    final db = await database;
    final rows = await db.query('departments', orderBy: 'name ASC');
    return rows.map(Department.fromMap).toList();
  }

  Future<void> insertDepartment(Department department) async {
    final db = await database;
    await db.insert(
      'departments',
      _departmentToDbMap(department),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDepartment(Department department) async {
    final db = await database;
    await db.update(
      'departments',
      _departmentToDbMap(department),
      where: 'id = ?',
      whereArgs: [department.id],
    );
  }

  Future<void> deleteDepartment(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('departments', where: 'id = ?', whereArgs: [id]);
      await txn.delete('contacts', where: 'departmentId = ?', whereArgs: [id]);
      await txn.delete('duties', where: 'departmentId = ?', whereArgs: [id]);
    });
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'name ASC');
    return rows.map(Contact.fromMap).toList();
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert(
      'contacts',
      _contactToDbMap(contact),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      _contactToDbMap(contact),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DutyPerson>> getDuties() async {
    final db = await database;
    final rows = await db.query(
      'duties',
      orderBy: 'dutyDate ASC, departmentName ASC',
    );
    return rows.map(DutyPerson.fromMap).toList();
  }

  Future<void> insertDuty(DutyPerson duty) async {
    final db = await database;
    await db.insert(
      'duties',
      _dutyToDbMap(duty),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDuty(DutyPerson duty) async {
    final db = await database;
    await db.update(
      'duties',
      _dutyToDbMap(duty),
      where: 'id = ?',
      whereArgs: [duty.id],
    );
  }

  Future<void> deleteDuty(String id) async {
    final db = await database;
    await db.delete('duties', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _contactToDbMap(Contact contact) {
    final map = contact.toMap();
    map['isFavorite'] = (contact.isFavorite ? 1 : 0);
    return map;
  }

  Map<String, dynamic> _departmentToDbMap(Department department) {
    final map = department.toMap();
    map['isEmergency'] = (department.isEmergency ? 1 : 0);
    return map;
  }

  Map<String, dynamic> _dutyToDbMap(DutyPerson duty) {
    final map = duty.toMap();
    map['isCriticalUnit'] = (duty.isCriticalUnit ? 1 : 0);
    return map;
  }
}
