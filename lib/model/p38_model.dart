import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:touna/util/date.dart';

class P38Model {
  String tanggal;
  String nomor;
  String kasi;
  String nama;
  String jabatan;
  P38Model({
    required this.tanggal,
    required this.nomor,
    required this.kasi,
    required this.nama,
    required this.jabatan,
  });
  factory P38Model.fromJson(Map<String, dynamic> json) {
    return P38Model(
      tanggal: json['tanggal'],
      nomor: json['nomor'],
      kasi: json['kasi'],
      nama: json['nama'],
      jabatan: json['jabatan'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal,
      'nomor': nomor,
      'kasi': kasi,
      'nama': nama,
      'jabatan': jabatan,
    };
  }
}

class P38DB {
  static Future<Database> init() async {
    final doc = await getApplicationSupportDirectory();
    final dir = Directory(join(doc.path, 'touna'));
    await dir.create(recursive: true);
    final db = databaseFactoryIo.openDatabase(join(dir.path, 'surat.db'));
    return db;
  }

  static Future<P38Model> getdata() async {
    final db = await init();
    final store = intMapStoreFactory.store('data');
    final data = await store.query().getSnapshot(db);
    if (data == null) {
      var sample = P38Model(
        tanggal: DateTime.now().formatDB,
        nomor: 'B- 1587/P.2.18/Es.2/10/2024',
        kasi: 'Kepala Seksi Tindak Pidana Umum',
        nama: 'JUSRIN HUSEN, S.H.,M.H.',
        jabatan: 'Jaksa Muda / Nip. 19841106 200912 1 001',
      );
      await store.add(db, sample.toMap());
      return sample;
    } else {
      return P38Model.fromJson(data.value as Map<String, dynamic>);
    }
  }

  static Future savedata(P38Model data) async {
    final db = await init();
    final store = intMapStoreFactory.store('data');
    await store.delete(db);
    await store.add(db, data.toMap());
  }
}
