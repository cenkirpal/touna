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
  bool detail = false;
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

  download() async {
    var excel = exc.Excel.createExcel();
    excel.rename(excel.sheets.keys.first, 'sidang');
    var sheet = excel['sidang'];

    var headerStyle = exc.CellStyle(
      verticalAlign: exc.VerticalAlign.Center,
      horizontalAlign: exc.HorizontalAlign.Center,
      textWrapping: exc.TextWrapping.WrapText,
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
    var borderStyle = exc.CellStyle(
      verticalAlign: exc.VerticalAlign.Center,
      textWrapping: exc.TextWrapping.WrapText,
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
    noT.cellStyle = headerStyle;

    var terdakwaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0 + 5));
    terdakwaT.value = const exc.TextCellValue('Nama Terdakwa');
    terdakwaT.cellStyle = headerStyle;

    var agendaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0 + 5));
    agendaT.value = const exc.TextCellValue('Agenda');
    agendaT.cellStyle = headerStyle;

    var jpuT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0 + 5));
    jpuT.value = const exc.TextCellValue('JPU');
    jpuT.cellStyle = headerStyle;

    var majelisT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0 + 5));
    majelisT.value = const exc.TextCellValue('Majelis');
    majelisT.cellStyle = headerStyle;

    var paniteraT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0 + 5));
    paniteraT.value = const exc.TextCellValue('Panitera');
    paniteraT.cellStyle = headerStyle;

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

      var agenda = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6));
      agenda.value = exc.TextCellValue(lists[i].agenda);
      agenda.cellStyle = borderStyle;

      var jpu = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6));
      jpu.value =
          exc.TextCellValue(lists[i].perkara!.jpu.replaceAll(';', '\n'));
      jpu.cellStyle = borderStyle;

      var majelis = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 6));
      majelis.value =
          exc.TextCellValue(lists[i].perkara!.majelis.replaceAll(';', '\n'));
      majelis.cellStyle = borderStyle;

      var panitera = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 6));
      panitera.value = exc.TextCellValue(lists[i].perkara!.panitera);
      panitera.cellStyle = borderStyle;
    }
    sheet.setColumnWidth(1, 35);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 35);
    sheet.setColumnWidth(4, 35);
    sheet.setColumnWidth(5, 35);
    sheet.setRowHeight(5, 20);

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
                initialDate: date,
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
            onPressed: () => setState(() => detail = !detail),
            color: detail ? Colors.blue : Colors.pink,
            icon: const Icon(Icons.remove_red_eye),
          ),
          IconButton(
            onPressed: () => cek(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => rekap(),
            icon: const Icon(Icons.list),
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
                                  width: 200,
                                  child: Text(lists[i].agenda),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 250,
                                  child: detailText(lists[i].perkara!.jpu),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 250,
                                  child: detailText(lists[i].perkara!.majelis),
                                ),
                                Container(width: 16),
                                SizedBox(
                                  width: 250,
                                  child: Text(lists[i].perkara!.panitera),
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

  detailText(String text) {
    if (!detail) return Text(text.split(';').first);
    return Text(text.replaceAll(';', '\n'));
  }

  rekap() {
    showDialog(
        context: this.context,
        builder: (context) {
          return const RekapJadwal();
        });
  }
}

class RekapJadwal extends StatefulWidget {
  const RekapJadwal({super.key});

  @override
  RekapJadwalState createState() => RekapJadwalState();
}

class RekapJadwalState extends State<RekapJadwal> {
  List<SidangModel> lists = [];
  DateTimeRange? date;
  int perkara = 0;

  rekap(DateTimeRange date) async {
    setState(() => lists = []);
    final data =
        await ApiTouna.rekapJadwal(date.start.formatDB, date.end.formatDB);
    setState(() => lists = data);
    var perk = [];
    for (var item in data) {
      perk.add(item.perkara!.noPerkara);
    }
    var jml = perk.toSet().toList();

    setState(() => perkara = jml.length);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(this.context).size;

    return AlertDialog(
      content: SizedBox(
        height: size.height - 100,
        width: size.width - 100,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lists.isEmpty
                      ? ''
                      : 'Total Sidang : ${lists.length} dari $perkara Perkara\n\n${date == null ? '' : '${date!.start.fullday} - ${date!.end.fullday}'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    var picker = await showDateRangePicker(
                      builder: (context, child) {
                        return Column(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 400.0,
                                  maxHeight: size.height - 100),
                              child: child,
                            )
                          ],
                        );
                      },
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    setState(() => date = picker);
                    if (picker != null) rekap(picker);
                  },
                  child: const Text('Pilih Tanggal'),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            if (lists.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: lists.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return Card(
                      child: ListTile(
                        leading: Text(
                          '${i + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        title: Text(
                            lists[i].perkara!.terdakwa.replaceAll(';', '\n')),
                        trailing: Text(DateTime.parse(lists[i].date).fullday),
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(child: Center(child: Text('Tidak Ada Data'))),
          ],
        ),
      ),
    );
  }
}
