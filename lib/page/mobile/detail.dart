import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

class DetailMobile extends StatefulWidget {
  const DetailMobile({super.key, required this.perkara});
  final QueryDocumentSnapshot perkara;
  @override
  DetailMobileState createState() => DetailMobileState();
}

class DetailMobileState extends State<DetailMobile> {
  late PerkaraModel perkara;
  List<QueryDocumentSnapshot>? listSidang = [];
  @override
  void initState() {
    perkara =
        PerkaraModel.fromJson((widget.perkara.data()) as Map<String, dynamic>);
    reload();
    super.initState();
  }

  reload() async {
    setState(() => listSidang = []);
    final ref = await FirebaseFirestore.instance
        .collection('perkara')
        .doc(widget.perkara.id)
        .collection('sidang')
        .orderBy('date')
        .get();
    setState(() => listSidang = ref.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perkara'),
        actions: [
          IconButton(
            onPressed: () => reload(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return AddSidang(perkara: widget.perkara);
                  });
              reload();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  perkara.noPerkara,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(height: 32),
              const Text('Terdakwa :'),
              const Divider(),
              Text(perkara.terdakwa.replaceAll(';', '\n')),
              Container(height: 32),
              const Text('JPU :'),
              const Divider(),
              Text(perkara.jpu.replaceAll(';', '\n')),
              Container(height: 25),
              listSidang == null
                  ? Container()
                  : listSidang!.isEmpty
                      ? Container()
                      : ListView.builder(
                          itemCount: listSidang!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            var sidang = SidangModel.fromJson(
                                listSidang![i].data()! as Map<String, dynamic>);
                            return ListTile(
                              leading: Text('${i + 1}'),
                              title: Text(DateTime.parse(sidang.date).fullday),
                              subtitle: Text(sidang.agenda),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return EditSidang(
                                              perkara: widget.perkara,
                                              sidang: listSidang![i],
                                            );
                                          });
                                      reload();
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('perkara')
                                          .doc(widget.perkara.id)
                                          .collection('sidang')
                                          .doc(listSidang![i].id)
                                          .delete();
                                      // await TounaDB.deleteSidang(
                                      //     perkara.noPerkara, listSidang![i].id!);
                                      reload();
                                    },
                                    color: Colors.pink,
                                    icon: const Icon(Icons.delete_forever),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddSidang extends StatefulWidget {
  const AddSidang({super.key, required this.perkara});
  final QueryDocumentSnapshot perkara;
  @override
  AddSidangState createState() => AddSidangState();
}

class AddSidangState extends State<AddSidang> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _agenda = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _date,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              onTap: () async {
                var d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d == null) return;
                setState(() => _date.text = d.formatDB);
              },
              validator: (value) {
                var d = DateTime.tryParse(_date.text);
                if (d == null) {
                  return 'invalid date';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _agenda,
              decoration: const InputDecoration(labelText: 'Agenda'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            var sidang = SidangModel(
              date: DateTime.parse(_date.text).formatDB,
              agenda: _agenda.text.toUpperCase(),
            );
            final ref = FirebaseFirestore.instance
                .collection('perkara')
                .doc(widget.perkara.id)
                .collection('sidang');
            await ref.add(sidang.toMap());
            // await TounaDB.addSidang(widget.perkara.noPerkara, sidang);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EditSidang extends StatefulWidget {
  const EditSidang({super.key, required this.perkara, required this.sidang});
  final QueryDocumentSnapshot perkara;
  final QueryDocumentSnapshot sidang;
  @override
  EditSidangState createState() => EditSidangState();
}

class EditSidangState extends State<EditSidang> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _agenda = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSidang();
  }

  loadSidang() async {
    final ref = await FirebaseFirestore.instance
        .collection('perkara')
        .doc(widget.perkara.id)
        .collection('sidang')
        .doc(widget.sidang.id)
        .get();
    setState(() {
      _date.text = ref.data()!['date'];
      _agenda.text = ref.data()!['agenda'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _date,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              onTap: () async {
                var d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d == null) return;
                setState(() => _date.text = d.formatDB);
              },
              validator: (value) {
                var d = DateTime.tryParse(_date.text);
                if (d == null) {
                  return 'invalid date';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _agenda,
              decoration: const InputDecoration(labelText: 'Agenda'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;

            var update = SidangModel(
              date: DateTime.parse(_date.text).formatDB,
              agenda: _agenda.text.toUpperCase(),
            );
            await FirebaseFirestore.instance
                .collection('perkara')
                .doc(widget.perkara.id)
                .collection('sidang')
                .doc(widget.sidang.id)
                .update(update.toMap());
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
