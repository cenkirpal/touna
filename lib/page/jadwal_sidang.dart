import 'dart:io';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

class JadwalSidang extends StatefulWidget {
  const JadwalSidang({super.key});
  @override
  JadwalSidangState createState() => JadwalSidangState();
}

class JadwalSidangState extends State<JadwalSidang> {
  DateTime date = DateTime.now();
  AppState appState = AppState.done;
  List<SidangModel> lists = [];
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
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    var fetch = await ApiTouna.jadwal(date.formatDB);
    setState(() {
      appState = AppState.done;
      lists = fetch;
    });
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
      // terdakwa.value = exc.TextCellValue(lists[i]['terdakwa']);
      terdakwa.cellStyle = borderStyle;

      var lok = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6));
      lok.value = const exc.TextCellValue('Lapas Ampana');
      lok.cellStyle = borderStyle;
      var pasal = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6));
      // pasal.value = exc.TextCellValue(lists[i]['pasal']);
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
          Text(
            '${lists.length} perkara',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton(
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
              date.fullday,
              style: const TextStyle(fontSize: 16),
            ),
          ),
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
        child: appState == AppState.loading
            ? const Center(
                child: SizedBox(width: 200, child: LinearProgressIndicator()),
              )
            : lists.isEmpty
                ? const Center(child: Text('Tidak ada sidang hari ini'))
                : ListView.builder(
                    // shrinkWrap: true,
                    itemCount: lists.length,
                    itemBuilder: (context, i) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Text(
                                    lists[i]
                                        .perkara!
                                        .terdakwa
                                        .replaceAll(';', '\n'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 150,
                                  child: Text(lists[i].agenda),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 250,
                                  child: Text(lists[i]
                                      .perkara!
                                      .jpu
                                      .replaceAll(';', '\n')),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 200,
                                  child: Text(lists[i]
                                      .perkara!
                                      .majelis
                                      .replaceAll(';', '\n')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
