import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// A helper class for managing SQLite database operations.
class DBHelper {
  /// Private constructor to prevent instantiation.
  DBHelper._();

  /// Singleton instance of [DBHelper].
  static final DBHelper getInstance = DBHelper._();

  /// Table name for notes.
  static final String TABLE_NOTE = 'note';

  /// Column name for the serial number of the note.
  static final String COLUMN_NOTE_SNO = 'sno';

  /// Column name for the title of the note.
  static final String COLUMN_NOTE_TITLE = 'title';

  /// Column name for the description of the note.
  static final String COLUMN_NOTE_DESC = 'desc';

  /// Database instance.
  Database? myDB;

  /// Returns the database instance. If the database is not initialized, it will be opened.
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;

    // if(myDB != null){
    //   return myDB!;
    // }else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  /// Opens the database. If the database does not exist, it will be created.
  Future<Database> openDB() async {
    /// Gets the application documents directory.
    Directory appDir = await getApplicationDocumentsDirectory();

    /// Constructs the database path.
    String dbPath = join(appDir.path, "noteDB.db");

    /// Opens the database and creates the table if it doesn't exist.
    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        String sql =
            "create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)";
        db.execute(sql);
      },
      version: 1,
    );
  }

  /// Inserting data
  /// all quires
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();

    int result = await db.insert(TABLE_NOTE, {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc});

    return result > 0;
  }

  /// Reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);

    return mData;
  }

  /// Update Data
  Future<bool> updateNotes({required String mTitle, required String mDesc, required int sno}) async {
    var db = await getDB();
    int result = await db.update(TABLE_NOTE, {COLUMN_NOTE_TITLE: mTitle, COLUMN_NOTE_DESC: mDesc}, where: '$COLUMN_NOTE_SNO = $sno');
    return result > 0;
  }

  /// Delete Note
  Future<bool> deleteNotes({required int sno}) async {
    var db = await getDB();

    int result = await db.delete(TABLE_NOTE, where: '$COLUMN_NOTE_SNO = ?', whereArgs: [sno]);
    return result > 0;
  }
}
