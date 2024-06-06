import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:touna/db/database.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/util/date.dart';

class JadwalSidang extends StatefulWidget {
  const JadwalSidang({super.key});
  @override
  JadwalSidangState createState() => JadwalSidangState();
}

class JadwalSidangState extends State<JadwalSidang> {
  DateTime date = DateTime.now();
  List<Map<String, dynamic>> lists = [];
  @override
  void initState() {
    super.initState();
    cek();
  }

  cek() async {
    if (date.dayname == 'Minggu') {
      date = date.add(const Duration(days: 1));
    }
    if (date.dayname == 'Sabtu') {
      date = date.add(const Duration(days: 2));
    }
    setState(() {});
    setState(() => lists = []);
    final ref = await FirebaseFirestore.instance.collection('perkara').get();
    for (var item in ref.docs) {
      final sdg = await FirebaseFirestore.instance
          .collection('perkara')
          .doc(item.id)
          .collection('sidang')
          .get();
      if (sdg.docs.isNotEmpty) {
        Map<String, dynamic> data = {};
        var now = sdg.docs.where((element) => element['date'] == date.formatDB);

        if (now.isNotEmpty) {
          var parent = now.first.reference.parent.parent;
          var pkr = await parent!.get();
          data['noPerkara'] = pkr['noPerkara'];
          data['terdakwa'] = pkr['terdakwa'];
          data['pasal'] = pkr['pasal'];
          data['jpu'] = pkr['jpu'];
          data['date'] = now.first.data()['date'];
          data['agenda'] = now.first.data()['agenda'];
          lists.add(data);
        }
      }
      setState(() {});
    }

    // print(ref.docs.where('date', isEqualTo: '2024-05-27'));
    var data = await TounaDB.cekJadwal();
    for (var pkr in data) {
      var perkara = PerkaraModel.fromJson((pkr.value as Map<String, dynamic>));

      for (var item in perkara.sidang!) {
        if (item.date == date.formatDB) {
          var sidang = {
            'noPerkara': perkara.noPerkara,
            'terdakwa': perkara.terdakwa,
            'jpu': perkara.jpu,
            'date': item.date,
            'agenda': item.agenda,
          };
          lists.add(sidang);
        }
      }
    }
    setState(() {});
  }

  download() async {
    var excel = exc.Excel.createExcel();
    excel.rename(excel.sheets.keys.first, 'sidang');
    var sheet = excel['sidang'];

    var borderStyle = exc.CellStyle(
      topBorder: exc.Border(
        borderStyle: exc.BorderStyle.Thin,
        borderColorHex: exc.ExcelColor.black,
      ),
      bottomBorder: exc.Border(
        borderStyle: exc.BorderStyle.Thin,
        borderColorHex: exc.ExcelColor.black,
      ),
      rightBorder: exc.Border(
        borderStyle: exc.BorderStyle.Thin,
        borderColorHex: exc.ExcelColor.black,
      ),
      leftBorder: exc.Border(
        borderStyle: exc.BorderStyle.Thin,
        borderColorHex: exc.ExcelColor.black,
      ),
    );

    var noT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0 + 5));
    noT.value = const exc.TextCellValue('No');
    noT.cellStyle = borderStyle;
    var terdakwaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0 + 5));
    terdakwaT.value = const exc.TextCellValue('Nama Terdakwa yang dipanggil');
    terdakwaT.cellStyle = borderStyle;
    var lapasT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0 + 5));
    lapasT.value = const exc.TextCellValue('Alamat');
    lapasT.cellStyle = borderStyle;
    var pasalT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0 + 5));
    pasalT.value = const exc.TextCellValue('Keterangan / Pasal');
    pasalT.cellStyle = borderStyle;

    for (var i = 0; i < lists.length; i++) {
      var no = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 6));
      no.value = exc.TextCellValue('${i + 1}');
      no.cellStyle = borderStyle;
      var terdakwa = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 6));
      terdakwa.value = exc.TextCellValue(lists[i]['terdakwa']);
      terdakwa.cellStyle = borderStyle;

      var lok = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6));
      lok.value = const exc.TextCellValue('Lapas Ampana');
      lok.cellStyle = borderStyle;
      var pasal = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6));
      pasal.value = exc.TextCellValue(lists[i]['pasal']);
      pasal.cellStyle = borderStyle;
    }

    var dir = await getApplicationDocumentsDirectory();
    List<int>? bytes = excel.save();
    File(join(dir.path, 'sidang touna.xlsx'))
        .writeAsBytesSync(bytes!, mode: FileMode.write);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sidang'),
        actions: [
          IconButton(
            onPressed: () => download(),
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () => cek(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      var pick = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (pick != null) {
                        setState(() => date = pick);
                        cek();
                      }
                    },
                    child: Text(
                      '${date.dayname}, ${date.fullday}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(width: 32),
                Text(
                  lists.isEmpty ? '' : '${lists.length} perkara',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: lists.isEmpty
                    ? const Center(child: Text('Tidak ada sidang hari ini'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (context, i) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    title: Text(
                                      lists[i]['noPerkara'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: Text(lists[i]['terdakwa']),
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(lists[i]['jpu']),
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(lists[i]['date']),
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(lists[i]['agenda']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
