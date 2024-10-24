import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:touna/api/api.dart';
import 'package:touna/api/response.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/detail_perkara.dart';
import 'package:touna/page/drawer.dart';
import 'package:touna/page/edit_perkara.dart';
import 'package:touna/page/jadwal_sidang.dart';
import 'package:touna/util/date.dart';
import 'package:excel/excel.dart' as exc;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  AppState appState = AppState.done;
  final _keyword = TextEditingController();
  List<PerkaraModel> lists = [];
  bool detail = false;
  bool showDrawer = false;
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
        backgroundColorHex: (lists[i].putusan ?? false)
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
          exc.TextCellValue(lists[i].putusan == true ? "sudah putus" : "");
      putusan.cellStyle = borderStyle;

      var no = sheet.cell(exc.CellIndex.indexByColumnRow(
          columnIndex: 0, rowIndex: (i + next) + 6));
      no.value = exc.TextCellValue('${i + 1}.');
      no.cellStyle = exc.CellStyle(
        bold: true,
        backgroundColorHex: (lists[i].putusan ?? false)
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
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const JadwalSidang();
              }));
            },
            icon: const Icon(Icons.schedule),
          ),
          IconButton(
            onPressed: () => setState(() => detail = !detail),
            color: detail ? Colors.blue : Colors.red,
            icon: const Icon(Icons.remove_red_eye),
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
              PopupMenuItem(
                onTap: () => download(),
                child: const Text('Download Data'),
              ),
            ];
          }),
        ],
      ),
      body: appState == AppState.loading
          ? appState == AppState.error
              ? Center(
                  child: SizedBox(
                  width: 200,
                  child: Text(error),
                ))
              : const Center(
                  child: SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(),
                ))
          : lists.isEmpty
              ? const Center(child: Text('No Data'))
              : ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, i) {
                    var data = lists[i];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.green[400]!, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shadowColor: Colors.pink,
                      surfaceTintColor: Colors.pink,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return DetailPerkara(
                                                  perkara: lists[i]);
                                            }));
                                          },
                                          child: Text(
                                            data.noPerkara,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          data.terdakwa.replaceAll(';', '\n'),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return EditPerkara(
                                                      perkara: lists[i]);
                                                }).then((v) => fetch());
                                          });
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            bool putus = data.putusan ?? false;

                                            await ApiTouna.putus(
                                                lists[i].id!, !putus);

                                            fetch();
                                          });
                                        },
                                        child: const Text('Putusan'),
                                      ),
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero,
                                              () async {
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    content: const Text(
                                                        'Delete Data ?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('Batal'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await ApiTouna
                                                              .deletePerkara(
                                                                  lists[i].id!);
                                                          fetch();
                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Delete'),
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
                          if (detail) const Divider(),
                          if (detail)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.jpu.replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 32),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.majelis
                                                  .replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 32),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data.panitera
                                                  .replaceAll(';', '\n'),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (data.sidang != null)
                            sidang(data.sidang!.reversed.toList(),
                                data.putusan ?? false),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget sidang(List<SidangModel> data, bool putus) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: putus ? Colors.pink[300] : Colors.green[300],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: data
              .toList()
              .asMap()
              .map((key, value) => MapEntry(
                  key,
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${key + 1}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateTime.parse(value.date).fullday),
                            Text(
                              value.agenda,
                              style: key != 0
                                  ? null
                                  : TextStyle(
                                      color: colorSidang(value),
                                      fontWeight: FontWeight.bold,
                                    ),
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
    );
  }

  Color? colorSidang(SidangModel sidang) {
    if (DateTime.parse(sidang.date).difference(DateTime.now()).inDays >= 0) {
      return null;
    }
    return Colors.pink[700];
  }

  Widget formatText(String txt, {TextAlign? align, TextStyle? style}) {
    return SelectableText(txt.replaceAll(';', '\n'),
        textAlign: align, style: style);
  }
}

class AddPerkara extends StatefulWidget {
  const AddPerkara({super.key});
  @override
  AddPerkaraState createState() => AddPerkaraState();
}

class AddPerkaraState extends State<AddPerkara> {
  final _form = GlobalKey<FormState>();
  final _noPerkara = TextEditingController();
  final _terdakwa = TextEditingController();
  final _pasal = TextEditingController();
  final _jpu = TextEditingController();
  final _majelis = TextEditingController();
  final _panitera = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Tambah Perkara'),
      content: SizedBox(
        width: size.width - 200,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _noPerkara,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'No Perkara', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _terdakwa,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Terdakwa', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _pasal,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Pasal', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _jpu,
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'JPU', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _majelis,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Majelis', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _panitera,
                    validator: (value) {
                      if (value!.trim().isEmpty) return 'Harus Diisi';
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Panitera', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            var pkr = PerkaraModel(
              terdakwa: _terdakwa.text,
              pasal: _pasal.text,
              jpu: _jpu.text,
              majelis: _majelis.text,
              panitera: _panitera.text,
              noPerkara: _noPerkara.text,
              putusan: false,
            ).toMap();
            pkr.removeWhere((key, value) => key == 'sidang');

            await ApiTouna.addPerkara(pkr);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
