import 'dart:io';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';
import 'package:url_launcher/url_launcher.dart';

class RekapSidang extends StatefulWidget {
  const RekapSidang({super.key});
  @override
  RekapSidangState createState() => RekapSidangState();
}

class RekapSidangState extends State<RekapSidang> {
  AppState appState = AppState.done;
  List<SidangModel> lists = [];
  DateTimeRange? date;
  int perkara = 0;

  rekap(DateTimeRange date) async {
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    final data =
        await ApiTouna.rekapJadwal(date.start.formatDB, date.end.formatDB);
    data.sort((a, b) {
      if (DateTime.parse(a.date).isAfter(DateTime.parse(b.date))) return 1;
      return -1;
    });
    setState(() => lists = data);
    var perk = [];
    for (var item in data) {
      perk.add(item.perkara!.noPerkara);
    }
    var jml = perk.toSet().toList();

    setState(() {
      perkara = jml.length;
      appState = AppState.done;
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

    var tglT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0 + 5));
    tglT.value = const exc.TextCellValue('Tanggal');
    tglT.cellStyle = headerStyle;

    var terdakwaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0 + 5));
    terdakwaT.value = const exc.TextCellValue('Nama Terdakwa');
    terdakwaT.cellStyle = headerStyle;

    var agendaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0 + 5));
    agendaT.value = const exc.TextCellValue('Agenda');
    agendaT.cellStyle = headerStyle;

    var jpuT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0 + 5));
    jpuT.value = const exc.TextCellValue('JPU');
    jpuT.cellStyle = headerStyle;

    var majelisT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0 + 5));
    majelisT.value = const exc.TextCellValue('Majelis');
    majelisT.cellStyle = headerStyle;

    var paniteraT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0 + 5));
    paniteraT.value = const exc.TextCellValue('Panitera');
    paniteraT.cellStyle = headerStyle;

    for (var i = 0; i < lists.length; i++) {
      var no = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 6));
      no.value = exc.TextCellValue('${i + 1}.');
      no.cellStyle = borderStyle;

      var tanggal = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 6));
      // tanggal.value = exc.Date(year: year, month: month, day: day)
      tanggal.value =
          exc.DateCellValue.fromDateTime(DateTime.parse(lists[i].date));
      tanggal.cellStyle = borderStyle
        ..numberFormat = exc.NumFormat.custom(formatCode: 'd mmmm yyyy');

      var terdakwa = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 6));
      terdakwa.value =
          exc.TextCellValue(lists[i].perkara!.terdakwa.replaceAll(';', '\n'));
      terdakwa.cellStyle = borderStyle;

      var agenda = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 6));
      agenda.value = exc.TextCellValue(lists[i].agenda);
      agenda.cellStyle = borderStyle;

      var jpu = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 6));
      jpu.value =
          exc.TextCellValue(lists[i].perkara!.jpu.replaceAll(';', '\n'));
      jpu.cellStyle = borderStyle;

      var majelis = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 6));
      majelis.value =
          exc.TextCellValue(lists[i].perkara!.majelis.replaceAll(';', '\n'));
      majelis.cellStyle = borderStyle;

      var panitera = sheet.cell(
          exc.CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 6));
      panitera.value = exc.TextCellValue(lists[i].perkara!.panitera);
      panitera.cellStyle = borderStyle;
    }
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 35);
    sheet.setColumnWidth(3, 35);
    sheet.setColumnWidth(4, 35);
    sheet.setColumnWidth(5, 35);
    sheet.setColumnWidth(6, 35);
    sheet.setRowHeight(5, 20);

    var dir = await getApplicationDocumentsDirectory();
    List<int>? bytes = excel.save();
    var des = Directory(join(dir.path, 'sidang'));
    des.create(recursive: true);
    File(join(des.path, 'rekap sidang touna.xlsx'))
        .writeAsBytesSync(bytes!, mode: FileMode.write);
    await launchUrl(Uri.file(des.path));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(this.context).size;
    return PageContainer(
      title: lists.isEmpty
          ? ''
          : 'Total Sidang : ${lists.length} dari $perkara Perkara',
      actions: [
        TextButton(
          onPressed: () async {
            var picker = await showDateRangePicker(
              builder: (context, child) {
                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 400.0, maxHeight: size.height - 100),
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
          child: Text(
            date == null
                ? 'Pilih Tanggal'
                : '${date!.start.fullday} - ${date!.end.fullday}',
          ),
        ),
        if (lists.isNotEmpty)
          IconButton(
            onPressed: () => download(),
            icon: const Icon(Icons.download),
          ),
      ],
      body: appState == AppState.loading
          ? const Center(
              child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ))
          : lists.isEmpty
              ? const Center(child: Text('Tidak Ada Data'))
              : ListView.builder(
                  itemCount: lists.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) => sidangTile(i, lists[i]),
                ),
    );
  }

  sidangTile(int i, SidangModel data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text('${i + 1}'),
            ),
            SizedBox(
              width: 250,
              child: Text(lists[i].perkara!.terdakwa.replaceAll(';', '\n')),
            ),
            SizedBox(
              width: 200,
              child: Text(lists[i].agenda),
            ),
            Container(width: 16),
            SizedBox(
              width: 150,
              child: Text(DateTime.parse(lists[i].date).fullday),
            ),
          ],
        ),
      ),
    );
  }
}
