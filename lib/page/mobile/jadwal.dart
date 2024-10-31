import 'dart:io';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';
import 'package:url_launcher/url_launcher.dart';

class JadwalMobile extends StatefulWidget {
  const JadwalMobile({super.key});
  @override
  JadwalMobileState createState() => JadwalMobileState();
}

class JadwalMobileState extends State<JadwalMobile> {
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
    if (!mounted) return;
    setState(() {
      appState = AppState.done;
      lists = fetch;
    });
  }

  share() async {
    var disk = await Permission.storage.isGranted;
    if (!disk) await Permission.storage.request();

    final dir = Directory('/storage/emulated/0/Download');
    // print(dir?.path);
    print('exist : ${await dir.exists()}');
    if (!await dir.exists()) return;

    print('granted : ${await Permission.storage.isGranted}');
    if (!await Permission.storage.isGranted) return;

    var files = await dir.list().toList();
    files.forEach((e) => print(e.path));

    // final url = Uri.parse('https://wa.me');
    await launchUrl(Uri.file(files.first.absolute.path, windows: false));
    // Intent intent = Intent
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
    terdakwaT.value = const exc.TextCellValue('Nama Terdakwa');
    terdakwaT.cellStyle = borderStyle;
    var lapasT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0 + 5));
    lapasT.value = const exc.TextCellValue('Agenda');
    lapasT.cellStyle = borderStyle;
    var pasalT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0 + 5));
    pasalT.value = const exc.TextCellValue('JPU');
    pasalT.cellStyle = borderStyle;

    for (var i = 0; i < lists.length; i++) {
      var no = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 6));
      no.value = exc.TextCellValue('${i + 1}.');
      no.cellStyle = borderStyle;
      var terdakwa = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 6));
      terdakwa.value =
          exc.TextCellValue(lists[i].perkara!.terdakwa.replaceAll(';', '\n'));
      terdakwa.cellStyle = borderStyle;

      var lok = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6));
      lok.value = exc.TextCellValue(lists[i].agenda);
      lok.cellStyle = borderStyle;
      var pasal = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6));
      pasal.value =
          exc.TextCellValue(lists[i].perkara!.jpu.replaceAll(';', '\n'));
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
          IconButton(
            onPressed: () => share(),
            icon: const Icon(Icons.share),
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
                  height: 55,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
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
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Text(
                  lists.isEmpty ? '' : '${lists.length} perkara',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
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
                                    lists[i].perkara!.noPerkara,
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
                                        child: Text(lists[i]
                                            .perkara!
                                            .terdakwa
                                            .toString()
                                            .replaceAll(';', '\n')),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(lists[i].agenda),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(lists[i]
                                            .perkara!
                                            .jpu
                                            .toString()
                                            .replaceAll(';', '\n')),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(lists[i].date),
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
          ],
        ),
      ),
    );
  }
}
