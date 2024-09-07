import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:touna/model/sidang_model.dart';

class TounaDB {
  static Future<Database> init() async {
    final doc = await getApplicationSupportDirectory();
    final dir = Directory(join(doc.path, 'touna'));
    await dir.create(recursive: true);
    final db = databaseFactoryIo.openDatabase(join(dir.path, 'touna.db'));
    return db;
  }

  static Future add(String record, Map<String, dynamic> data) async {
    final db = await init();
    final store = intMapStoreFactory.store(record);
    // await store.drop(db);
    try {
      await store.add(db, data);
    } catch (e) {
      print(e);
    }
  }

  static Future editJenis(int harga, int key) async {
    final db = await init();
    final store = intMapStoreFactory.store('jenis');
    await store.update(
      db,
      {'harga': harga},
      finder: Finder(filter: Filter.byKey(key)),
    );
  }

  static Future editSPBU(Map<String, dynamic> data, int key) async {
    final db = await init();
    final store = intMapStoreFactory.store('spbu');
    await store.update(
      db,
      data,
      finder: Finder(filter: Filter.byKey(key)),
    );
  }

  static Future delete(String record, int key) async {
    final db = await init();
    final store = intMapStoreFactory.store(record);
    // await store.drop(db);
    await store.delete(db, finder: Finder(filter: Filter.byKey(key)));
  }

  static Future<List<RecordSnapshot>> get(String record) async {
    final db = await init();
    final store = intMapStoreFactory.store(record);
    final data = await store.query().getSnapshots(db);
    return data;
  }

//
//

  static Future deletePerkara(int? key) async {
    final db = await init();
    final store = intMapStoreFactory.store('perkara');
    if (key == null) {
      await store.delete(db);
    } else {
      await store.delete(db, finder: Finder(filter: Filter.byKey(key)));
    }
  }

  static Future<List<RecordSnapshot>> fetch() async {
    final db = await init();
    final store = intMapStoreFactory.store('perkara');
    final data = await store.query().getSnapshots(db);
    return data;
  }

  static Future<List<RecordSnapshot>> cekJadwal() async {
    final db = await init();
    final store = intMapStoreFactory.store('perkara');
    final data = await store.query().getSnapshots(db);
    List<RecordSnapshot> lists = [];
    for (var item in data) {
      if (item.value['sidang'] != null) {
        List list = item.value['sidang'] as List;
        if (list.isNotEmpty) lists.add(item);
      }
    }
    return lists;
  }

  static Future addSidang(String perkara, SidangModel sidang) async {
    final db = await init();
    final store = intMapStoreFactory.store('perkara');
    final data = await store
        .query(finder: Finder(filter: Filter.equals('noPerkara', perkara)))
        .getSnapshot(db);
    var cek = data!.value['sidang'] as List;
    if (cek.isEmpty) {
      // sidang.id = 1;
      await store.update(
          db,
          {
            'sidang': [sidang.toMap()]
          },
          finder: Finder(filter: Filter.equals('noPerkara', perkara)));
    } else {
      // sidang.id = cek.length + 1;

      var clone = cloneList(cek);
      clone.add(sidang.toMap());
      await store.update(db, {'sidang': clone},
          finder: Finder(filter: Filter.equals('noPerkara', perkara)));
    }
  }

  static Future editSidang(String perkara, SidangModel sidang) async {
    // final db = await init();
    // final store = intMapStoreFactory.store('perkara');
    // final data = await store
    //     .query(finder: Finder(filter: Filter.equals('noPerkara', perkara)))
    //     .getSnapshot(db);
    // var cek = data?.value['sidang'];

    // var listSidang = cek as List;
    // var clone = cloneList(listSidang);
    // var list = [];
    // for (var item in listSidang) {
    //   var update = SidangModel.fromJson(item as Map<String, dynamic>);
    // if (sidang.id == update.id) {
    //   list.add(sidang.toMap());
    // } else {
    //   list.add(update.toMap());
    // }
    // }

    // await store.update(db, {'sidang': list},
    //     finder: Finder(filter: Filter.equals('noPerkara', perkara)));
  }

  static Future deleteSidang(String perkara, int id) async {
    final db = await init();
    final store = intMapStoreFactory.store('perkara');

    final data = await store
        .query(finder: Finder(filter: Filter.equals('noPerkara', perkara)))
        .getSnapshot(db);

    var sidang = data!.value['sidang'] as List;
    List update = [];
    for (var item in sidang) {
      if (item['id'] != id) {
        update.add(item);
      }
    }
    // var cek = sidang.where((e) {
    //   if (e['id'] == id) return true;
    //   return false;
    // });
    // print(cek);

    await store.update(db, {'sidang': update},
        finder: Finder(filter: Filter.equals('noPerkara', perkara)));
  }
}
