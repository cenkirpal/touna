import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/page/detail_perkara.dart';
import 'package:touna/page/edit_perkara.dart';
import 'package:touna/page/jadwal_sidang.dart';
import 'package:touna/util/date.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ref =
      FirebaseFirestore.instance.collection('perkara').orderBy('inkrah');

  List<QueryDocumentSnapshot> lists = [];
  bool detail = false;

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    await FirebaseAuth.instance.signInAnonymously();
    setState(() => lists = []);
    var d = await ref.get();
    lists = d.docs;

    setState(() => lists = d.docs);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
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
          IconButton(onPressed: () => insert(), icon: const Icon(Icons.add)),
          IconButton(onPressed: () => fetch(), icon: const Icon(Icons.refresh))
        ],
      ),
      body: lists.isEmpty
          ? const Center(child: Text('No Data'))
          : ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, i) {
                var data = PerkaraModel.fromJson(
                    lists[i].data() as Map<String, dynamic>);
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green[400]!, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  shadowColor: Colors.pink,
                  surfaceTintColor: Colors.pink,
                  child: Column(
                    children: [
                      ListTile(
                        tileColor:
                            data.inkrah == true ? Colors.blue[300] : null,
                        leading: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: formatText(
                          '${data.noPerkara}\n${data.terdakwa}',
                          align: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: !detail
                            ? Container()
                            : Container(
                                alignment: Alignment.centerLeft,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: formatText(data.terdakwa),
                                      ),
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: Text(data.pasal),
                                      ),
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: formatText(data.jpu),
                                      ),
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: Text(data.majelis),
                                      ),
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(8),
                                        child: Text(data.panitera),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return DetailPerkara(perkara: lists[i]);
                                }));
                                fetch();
                              },
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                showDialog(
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
                                              await FirebaseFirestore.instance
                                                  .collection('perkara')
                                                  .doc(lists[i].id)
                                                  .delete();
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
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.pink,
                              ),
                            ),
                            PopupMenuButton(
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
                                        bool inkrah = data.inkrah ?? false;
                                        await FirebaseFirestore.instance
                                            .collection('perkara')
                                            .doc(lists[i].id)
                                            .update({'inkrah': !inkrah});
                                        fetch();
                                      });
                                    },
                                    child: const Text('Putusan'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('perkara')
                              .doc(lists[i].id)
                              .collection('sidang')
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return Container();
                            }
                            if (snap.data!.docs.isNotEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    )),
                                child: SingleChildScrollView(
                                  child: Row(
                                    children: snap.data!.docs
                                        .asMap()
                                        .map((key, value) => MapEntry(
                                            key,
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      4, 4, 18, 4),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${key + 1}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(DateTime.parse((value
                                                                      .data()!
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'date'])
                                                          .fullday),
                                                      Text(
                                                        (value.data()! as Map<
                                                            String,
                                                            dynamic>)['agenda'],
                                                        style: key != 0
                                                            ? null
                                                            : const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                            return Container();
                          }),
                      if (i == lists.length - 1) Container(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
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
