import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._internal();
  AppDatabase._internal();
  static AppDatabase get instance => _singleton;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = p.join(dir.path, 'mykrono.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }
}