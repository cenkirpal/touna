import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/desktop/laporan/p38_page.dart';
import 'package:touna/page/detail_perkara.dart';
import 'package:touna/util/date.dart';
import 'package:url_launcher/url_launcher.dart';

class JadwalSidang extends ConsumerStatefulWidget {
  const JadwalSidang({super.key});
  @override
  JadwalSidangState createState() => JadwalSidangState();
}

class JadwalSidangState extends ConsumerState<JadwalSidang> {
  DateTime date = DateTime.now();
  final controller = ScreenshotController();
  AppState appState = AppState.done;
  List<SidangModel> lists = [];
  Uint8List? bytes;

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
    var des = Directory(join(dir.path, 'sidang'));
    des.create(recursive: true);
    File(join(des.path, 'sidang touna.xlsx'))
        .writeAsBytesSync(bytes!, mode: FileMode.write);
    await launchUrl(Uri.file(des.path));
  }

  capture(BuildContext context) async {
    var dir = await getApplicationDocumentsDirectory();
    var des = Directory(join(dir.path, 'sidang'));
    des.create(recursive: true);

    if (context.mounted) {
      var byte = await controller.captureFromLongWidget(
        pixelRatio: 2,
        InheritedTheme.captureAll(context, sidangWidget(context, true)),
      );

      var file =
          await File(join(des.path, 'P38 - ${date.fullday}.png')).create();
      file.writeAsBytesSync(byte);

      final uri = Uri.file(des.path);
      await launchUrl(uri);
    }
  }

  datePick(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      actions: [
        Text(
          '${lists.length} Perkara',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => datePick(context),
          child: Text(
            date.fullday,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => capture(context),
          icon: const Icon(Icons.photo),
        ),
        PopupMenuButton(itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () => cek(),
              child: const Text('Refresh'),
            ),
            PopupMenuItem(
              onTap: () => download(),
              child: const Text('Save Excel'),
            ),
          ];
        }),
      ],
      body: appState == AppState.loading
          ? const Center(
              child: SizedBox(width: 200, child: LinearProgressIndicator()),
            )
          : lists.isEmpty
              ? const Center(child: Text('Tidak ada sidang hari ini'))
              : SingleChildScrollView(
                  child: Screenshot(
                    controller: controller,
                    child: sidangWidget(context, false),
                  ),
                ),
      floating: lists.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return P38Page(lists: lists, date: date);
                }));
              },
              child: const Icon(Icons.picture_as_pdf),
            ),
    );
  }

  Widget sidangWidget(BuildContext context, bool shot) {
    var data = lists.asMap();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data
          .map((i, v) {
            return MapEntry(
                i,
                Card(
                  color: colorTile(v),
                  child: sidangContainer(context, shot, i, v),
                ));
          })
          .values
          .toList(),
    );
  }

  sidangContainer(BuildContext context, bool shot, int i, SidangModel data) {
    if (shot) return sidangTile(context, i, data, shot);
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      }),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: sidangTile(context, i, data, shot),
      ),
    );
  }

  sidangTile(BuildContext context, int i, SidangModel data, bool shot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text('${i + 1}'),
          ),
          SizedBox(
            width: 300,
            child: Text(
              data.perkara!.terdakwa.replaceAll(';', '\n'),
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.perkara!.jpu.replaceAll(';', '\n'),
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.perkara!.majelis.replaceAll(';', '\n'),
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 250,
            child: Text(
              data.perkara!.panitera,
              overflow: TextOverflow.clip,
            ),
          ),
          if (!shot)
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DetailPerkara(perkara: data.perkara!);
                  }));
                },
                icon: const Icon(Icons.remove_red_eye),
              ),
            ),
          if (!shot)
            SizedBox(
              width: 50,
              child: IconButton(
                onPressed: () async {
                  await ApiTouna.ketSidang(data.id!, !(data.ket ?? false));
                  await cek();
                },
                icon: const Icon(Icons.done),
              ),
            ),
        ],
      ),
    );
  }

  colorTile(SidangModel data) {
    if (data.perkara!.putusan == true) return Colors.pink[200];
    if (data.ket == true) return Colors.green[200];
    return null;
  }
}
