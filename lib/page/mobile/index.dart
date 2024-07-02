import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/page/edit_perkara.dart';
import 'package:touna/page/mobile/detail.dart';
import 'package:touna/page/mobile/jadwal.dart';
import 'package:touna/util/date.dart';

class HomeMobilePage extends StatefulWidget {
  const HomeMobilePage({super.key, required this.title});

  final String title;

  @override
  HomeMobilePageHomePageState createState() => HomeMobilePageHomePageState();
}

class HomeMobilePageHomePageState extends State<HomeMobilePage> {
  AppState appState = AppState.done;
  final _keyword = TextEditingController();
  List<PerkaraModel> lists = [];
  bool detail = false;

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
    var d = await ApiTouna.getPerkara(keyword: _keyword.text);
    if (!mounted) return;
    setState(() {
      lists = d;
      appState = AppState.done;
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const JadwalMobile();
              }));
            },
            icon: const Icon(Icons.schedule),
          ),
          IconButton(
            onPressed: () => setState(() => detail = !detail),
            color: detail ? Colors.blue : Colors.red,
            icon: const Icon(Icons.remove_red_eye),
          ),
          IconButton(onPressed: () => insert(), icon: const Icon(Icons.add)),
          IconButton(onPressed: () => fetch(), icon: const Icon(Icons.refresh))
        ],
      ),
      body: lists.isEmpty
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
                  color: data.putusan == true ? Colors.pink[300] : null,
                  surfaceTintColor: Colors.pink,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: size.width - 58,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width - 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              await Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return DetailMobile(
                                                    perkara: lists[i]);
                                              }));
                                              fetch();
                                            },
                                            child: Text(
                                              formatText(data.noPerkara),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            formatText(data.terdakwa),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
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
                                        Future.delayed(Duration.zero, () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return EditPerkara(
                                                    perkara: lists[i]);
                                              }).then((v) => fetch());
                                          // Navigator.push(context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) {
                                          //   return EditPerkara(perkara: lists[i]);
                                          // })).then((v) => fetch());
                                        });
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        Future.delayed(Duration.zero, () async {
                                          // bool inkrah = data.putusan ?? false;

                                          fetch();
                                        });
                                      },
                                      child: const Text('Putusan'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content:
                                                    const Text('Delete Data ?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
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
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (detail)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.jpu.replaceAll(';', '\n')),
                                Container(width: 32),
                                Text(data.majelis.replaceAll(';', '\n')),
                              ],
                            ),
                          ),
                        ),
                      if (data.sidang != null)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              )),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: data.sidang!
                                  .asMap()
                                  .map((key, value) => MapEntry(
                                      key,
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 4, 18, 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${key + 1}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(DateTime.parse(value.date)
                                                    .fullday),
                                                Text(
                                                  value.agenda,
                                                  style: key != 0
                                                      ? null
                                                      : const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
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
                      if (i == lists.length - 1) Container(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String formatText(String txt, {TextAlign? align, TextStyle? style}) {
    return txt.replaceAll(';', '\n');
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
            );
            await FirebaseAuth.instance.signInAnonymously();
            final ref = FirebaseFirestore.instance.collection('perkara');
            await ref.add(pkr.toMap());
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
