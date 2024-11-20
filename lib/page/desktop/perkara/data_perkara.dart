import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:touna/api/api.dart';
import 'package:touna/api/response.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/desktop/perkara/add_perkara.dart';
import 'package:touna/page/desktop/perkara/detail_perkara.dart';
import 'package:touna/page/desktop/perkara/edit_perkara.dart';
import 'package:touna/util/date.dart';
import 'package:path/path.dart' as path;
import 'package:excel/excel.dart' as exc;

class DataPerkara extends StatefulWidget {
  const DataPerkara({super.key});
  @override
  DataPerkaraState createState() => DataPerkaraState();
}

class DataPerkaraState extends State<DataPerkara> {
  AppState appState = AppState.done;
  final _keyword = TextEditingController();
  List<PerkaraModel> lists = [];
  String error = '';

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    setState(() {
      appState = AppState.loading;
      lists = [];
    });
    ResponseApi d = await ApiTouna.getPerkara(keyword: _keyword.text);
    if (!mounted) return;
    setState(() {
      if (d.error) {
        error = d.msg ?? 'Unknown Error';
        appState = AppState.error;
      } else {
        lists = d.result == null ? [] : d.result as List<PerkaraModel>;
        appState = AppState.done;
      }
    });
  }

  insert() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const AddPerkara();
        });
    fetch();
  }

  setPutusan(int id, String no, int i) async {
    String p = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextFormField(
              autofocus: true,
              onFieldSubmitted: (value) async {
                if (context.mounted) Navigator.pop(context, value);
              },
            ),
          );
        });
    await ApiTouna.putus(id, p);
    var pkr = await ApiTouna.findPerkara(no);
    if (mounted) setState(() => lists[i] = pkr);
    // fetch();
  }

  download() async {
    var excel = exc.Excel.createExcel();
    excel.rename(excel.sheets.keys.first, 'perkara');
    var sheet = excel['perkara'];

    var headerStyle = exc.CellStyle(
      bold: true,
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

    var noT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0 + 5));
    noT.value = const exc.TextCellValue('No');
    noT.cellStyle = headerStyle;

    var perkaraT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0 + 5));
    perkaraT.value = const exc.TextCellValue('Nomor Perkara');
    perkaraT.cellStyle = headerStyle;

    var terdakwaT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0 + 5));
    terdakwaT.value = const exc.TextCellValue('Nama Terdakwa');
    terdakwaT.cellStyle = headerStyle;

    var jpuT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0 + 5));
    jpuT.value = const exc.TextCellValue('JPU');
    jpuT.cellStyle = headerStyle;

    var putusanT = sheet
        .cell(exc.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0 + 5));
    putusanT.value = const exc.TextCellValue('Putusan');
    putusanT.cellStyle = headerStyle;

    int next = 0;
    int maxSidang = 0;
    for (var i = 0; i < lists.length; i++) {
      var borderStyle = exc.CellStyle(
        bold: true,
        backgroundColorHex: (lists[i].putusan != null)
            ? exc.ExcelColor.red200
            : exc.ExcelColor.green100,
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

      var perkara = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 1, rowIndex: (i + next) + 6));
      perkara.value = exc.TextCellValue(lists[i].noPerkara);
      perkara.cellStyle = borderStyle;

      var terdakwa = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 2, rowIndex: (i + next) + 6));
      terdakwa.value =
          exc.TextCellValue(lists[i].terdakwa.replaceAll(';', '\n'));
      terdakwa.cellStyle = borderStyle;

      var jpu = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 3, rowIndex: (i + next) + 6));
      jpu.value = exc.TextCellValue(lists[i].jpu.replaceAll(';', '\n'));
      jpu.cellStyle = borderStyle;

      var putusan = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 4, rowIndex: (i + next) + 6));
      putusan.value =
          exc.TextCellValue(lists[i].putusan != null ? "sudah putus" : "");
      putusan.cellStyle = borderStyle;

      var no = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 0, rowIndex: (i + next) + 6));
      no.value = exc.TextCellValue('${i + 1}.');
      no.cellStyle = exc.CellStyle(
        bold: true,
        backgroundColorHex: (lists[i].putusan != null)
            ? exc.ExcelColor.red200
            : exc.ExcelColor.green100,
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
      if (lists[i].sidang!.isNotEmpty) {
        var listSidang = lists[i].sidang!.reversed.toList();
        for (var j = 0; j < listSidang.length; j++) {
          var sidangStyleUp = exc.CellStyle(
            backgroundColorHex: exc.ExcelColor.orange100,
            verticalAlign: exc.VerticalAlign.Center,
            textWrapping: exc.TextWrapping.WrapText,
            topBorder: exc.Border(
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
          var sidangStyleDown = exc.CellStyle(
            backgroundColorHex: exc.ExcelColor.orange100,
            verticalAlign: exc.VerticalAlign.Center,
            textWrapping: exc.TextWrapping.WrapText,
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
          var sidang = listSidang[j];
          var date = sheet.cell(exc.CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (i + next) + 6 + 1));
          date.value = exc.TextCellValue(sidang.date);
          date.cellStyle = sidangStyleUp;

          var agenda = sheet.cell(exc.CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (i + next) + 6 + 2));
          agenda.value = exc.TextCellValue(sidang.agenda);
          agenda.cellStyle = sidangStyleDown;
          if (j >= maxSidang) maxSidang = j + 1;
          // if (j == maxSidang) maxSidang = j + 1;
        }
        next += 2;
      }
    }
    for (var i = 0; i < maxSidang; i++) {
      sheet.setColumnWidth(i, 35);
    }

    var dir = await getApplicationDocumentsDirectory();
    List<int>? bytes = excel.save();
    File(path.join(dir.path, 'perkara touna.xlsx'))
        .writeAsBytesSync(bytes!, mode: FileMode.write);
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      actions: [
        Container(
          width: 200,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: TextFormField(
            controller: _keyword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  _keyword.clear();
                  fetch();
                },
                iconSize: 20,
                color: Colors.pink,
                icon: const Icon(Icons.close),
              ),
            ),
            onFieldSubmitted: (value) {
              if (_keyword.text.isNotEmpty) fetch();
            },
          ),
        ),
        PopupMenuButton(itemBuilder: (context) {
          return [
            PopupMenuItem(
              onTap: () => insert(),
              child: const Text('Tambah Data'),
            ),
            PopupMenuItem(
              onTap: () => fetch(),
              child: const Text('Refresh Data'),
            ),
            if (!Platform.isAndroid)
              PopupMenuItem(
                onTap: () => download(),
                child: const Text('Download Data'),
              ),
          ];
        }),
      ],
      body: appState == AppState.loading
          ? appState == AppState.error
              ? Center(
                  child: SizedBox(
                    width: 200,
                    child: Text(error),
                  ),
                )
              : const Center(
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(),
                  ),
                )
          : lists.isEmpty
              ? const Center(child: Text('No Data'))
              : ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, i) {
                    return perkaraTile(lists[i], i);
                  },
                ),
    );
  }

  Widget perkaraTile(PerkaraModel data, int i) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.green[400]!, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        shadowColor: Colors.pink[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${i + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetailPerkara(perkara: lists[i]);
                          }));
                        },
                        child: Text(
                          data.noPerkara,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        data.terdakwa.replaceAll(';', '\n'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (lists[i].putusan != null)
                  Container(
                    width: Platform.isAndroid ? 120 : 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lists[i].putusan!),
                  ),
                SizedBox(
                  width: 50,
                  child: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            Future.delayed(Duration.zero, () async {
                              if (!context.mounted) return;
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return EditPerkara(perkara: lists[i]);
                                  }).then((v) => fetch());
                            });
                          },
                          child: const Text('Edit'),
                        ),
                        PopupMenuItem(
                          onTap: () =>
                              setPutusan(lists[i].id!, lists[i].noPerkara, i),
                          child: const Text('Putusan'),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            Future.delayed(Duration.zero, () async {
                              if (!context.mounted) return;
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: const Text('Delete Data ?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await ApiTouna.deletePerkara(
                                                lists[i].id!);
                                            fetch();
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  });
                              fetch();
                            });
                          },
                          child: const Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.trackpad,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dataTambahan(70, 220, 'JPU', data.jpu),
                      dataTambahan(70, 220, 'Majelis', data.majelis),
                      dataTambahan(70, 200, 'Panitera', data.panitera),
                    ],
                  ),
                ),
              ),
            ),
            if (data.sidang == null)
              Container(height: 4)
            else
              sidangTile(data.sidang!.reversed.toList(), data.putusan != null)
          ],
        ),
      ),
    );
  }

  Widget dataTambahan(double w1, double w2, String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: w1,
          child: Text(
            '$k : ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(
          width: w2,
          child: Text(v.replaceAll(';', '\n')),
        ),
      ],
    );
  }

  Widget sidangTile(List<SidangModel> data, bool putus) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: putus ? Colors.pink[300] : Colors.green[300],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.touch,
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: data
                .toList()
                .asMap()
                .map((key, value) => MapEntry(
                    key,
                    Container(
                      decoration: decorSidang(key, value, putus),
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 8),
                          Text(
                            '${key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateTime.parse(value.date).fullday,
                                style: styleSidang(key, value, putus),
                              ),
                              Text(
                                value.agenda,
                                style: styleSidang(key, value, putus),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )))
                .values
                .toList(),
          ),
        ),
      ),
    );
  }

  decorSidang(int key, SidangModel sidang, bool putus) {
    return BoxDecoration(
      color: colorSidang(key, sidang, putus),
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
    );
  }

  colorSidang(int key, SidangModel sidang, bool putus) {
    if (putus) return null;
    var past = false;
    var first = key == 0;
    if (first) {
      var diff = DateTime.parse(sidang.date).difference(DateTime.now());
      past = diff.inDays < 0 ? true : false;
    }
    if (first && past) return Colors.pink[300];
    return null;
  }

  TextStyle styleSidang(int key, SidangModel sidang, bool putus) {
    var first = key == 0;
    return TextStyle(
      fontSize: 12,
      color: null,
      fontWeight: first ? FontWeight.bold : null,
    );
  }
}
