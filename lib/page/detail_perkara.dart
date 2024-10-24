import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/main.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

class DetailPerkara extends StatefulWidget {
  const DetailPerkara({super.key, required this.perkara});
  final PerkaraModel perkara;
  @override
  DetailPerkaraState createState() => DetailPerkaraState();
}

class DetailPerkaraState extends State<DetailPerkara> {
  late PerkaraModel perkara;
  AppState appState = AppState.done;
  List<SidangModel>? listSidang = [];
  @override
  void initState() {
    perkara = widget.perkara;
    reload();
    super.initState();
  }

  reload() async {
    setState(() {
      appState = AppState.loading;
      listSidang = [];
    });
    var data = await ApiTouna.getSidang(widget.perkara.id!);

    setState(() {
      appState = AppState.done;
      listSidang = data.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText(perkara.noPerkara),
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
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Terdakwa : '),
                      const Divider(endIndent: 300),
                      Text(
                        perkara.terdakwa.replaceAll(';', '\n'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(height: 25),
                      const Text('JPU : '),
                      const Divider(endIndent: 300),
                      Text(
                        perkara.jpu.replaceAll(';', '\n'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Majelis : '),
                      const Divider(endIndent: 300),
                      Text(
                        perkara.majelis.replaceAll(';', '\n'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(height: 25),
                      const Text('Panitera : '),
                      const Divider(endIndent: 300),
                      Text(
                        perkara.panitera,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(height: 25),
            listSidang == null
                ? Container()
                : appState == AppState.loading
                    ? const Center(child: LinearProgressIndicator())
                    : listSidang!.isEmpty
                        ? Container()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: listSidang!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                var sidang = listSidang![i];
                                return Card(
                                  child: ListTile(
                                    leading: Text('${i + 1}'),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateTime.parse(sidang.date)
                                            .fullday),
                                        if (sidang.keterangan != null)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 8, 16, 8),
                                            child: Text(sidang.keterangan!),
                                          )
                                      ],
                                    ),
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
                                            await ApiTouna.deleteSidang(
                                                listSidang![i].id!);
                                            reload();
                                          },
                                          color: Colors.pink,
                                          icon:
                                              const Icon(Icons.delete_forever),
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

class AddSidang extends StatefulWidget {
  const AddSidang({super.key, required this.perkara});
  final PerkaraModel perkara;
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
            await ApiTouna.addSidang(widget.perkara.noPerkara, _date.text,
                _agenda.text.toUpperCase());
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
  final PerkaraModel perkara;
  final SidangModel sidang;
  @override
  EditSidangState createState() => EditSidangState();
}

class EditSidangState extends State<EditSidang> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  final _agenda = TextEditingController();
  final _keterangan = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSidang();
  }

  loadSidang() async {
    setState(() {
      _date.text = widget.sidang.date;
      _agenda.text = widget.sidang.agenda;
      _keterangan.text = widget.sidang.keterangan ?? '';
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
            TextFormField(
              controller: _keterangan,
              decoration: const InputDecoration(labelText: 'Keterangan'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;

            await ApiTouna.editSidang(
                widget.sidang.id!, _date.text, _agenda.text,
                keterangan: _keterangan.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
