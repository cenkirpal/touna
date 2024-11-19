import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/api/response.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/page/desktop/perkara/add_perkara.dart';
import 'package:touna/page/desktop/perkara/edit_perkara.dart';
import 'package:touna/page/mobile/perkara/detail.dart';
import 'package:touna/util/date.dart';

class PerkaraMobile extends StatefulWidget {
  const PerkaraMobile({super.key});
  @override
  PerkaraMobileState createState() => PerkaraMobileState();
}

class PerkaraMobileState extends State<PerkaraMobile> {
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

  setPutusan(int id) async {
    String p = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextFormField(
              onFieldSubmitted: (value) async {
                if (context.mounted) Navigator.pop(context, value);
              },
            ),
          );
        });
    await ApiTouna.putus(id, p);
    fetch();
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DetailMobile(perkara: lists[i]);
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
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (lists[i].putusan != null)
                      Container(
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
                              onTap: () => setPutusan(lists[i].id!),
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
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
