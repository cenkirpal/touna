import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:touna/page/desktop/printer/nota_model.dart';

class PrinterDB {
  static Future<Database> init() async {
    final doc = await getApplicationSupportDirectory();
    final dir = Directory(join(doc.path, 'touna'));
    await dir.create(recursive: true);
    final db = databaseFactoryIo.openDatabase(join(dir.path, 'printer.db'));
    return db;
  }

  static Future note(String mode, String data) async {
    final db = await init();
    final store = intMapStoreFactory.store('note');
    if (mode == 'add') {
      await store.delete(db);
      await store.add(db, {'value': data});
    } else {
      var q = await store.query().getSnapshot(db);
      return q == null ? '' : (q.value as Map<String, dynamic>)['value'];
    }
  }

  static Future addNota(String model, Map<String, dynamic> data) async {
    final db = await init();
    final store = intMapStoreFactory.store(model);
    await store.delete(db);
    await store.add(db, data);
  }

  static Future<NotaModel?> getNota(String model) async {
    final db = await init();
    final store = intMapStoreFactory.store(model);

    final data = await store.query().getSnapshot(db);
    return data == null
        ? null
        : NotaModel.fromJson(data.value as Map<String, dynamic>);
  }

  static Future<List<RecordSnapshot>> getSpbu() async {
    final db = await init();
    final store = intMapStoreFactory.store('spbu');
    final data = await store.query().getSnapshots(db);
    if (data.isEmpty) {
      store.add(db, {'spbu': 'Bailo', 'ket': ''});
      return await store.query().getSnapshots(db);
    } else {
      return data;
    }
  }

  static Future editSpbu(int key, String val) async {
    final db = await init();
    final store = intMapStoreFactory.store('spbu');
    await store.update(db, {'ket': val},
        finder: Finder(filter: Filter.byKey(key)));
  }

  static Future addSpbu(String val) async {
    final db = await init();
    final store = intMapStoreFactory.store('spbu');
    await store.add(db, {'spbu': val, 'ket': ''});
  }
}
