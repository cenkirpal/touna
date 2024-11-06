import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:touna/model/p38_model.dart';
import 'package:touna/util/date.dart';

class EditSurat extends StatefulWidget {
  const EditSurat({super.key, required this.p38, this.onsave});
  final P38Model p38;
  final Function(P38Model)? onsave;
  @override
  EditSuratState createState() => EditSuratState();
}

class EditSuratState extends State<EditSurat> {
  final _tgl = TextEditingController();
  final _nmr = TextEditingController();
  final _kasi = TextEditingController();
  final _nama = TextEditingController();
  final _jbt = TextEditingController();

  List<RecordSnapshot> listPjb = [];

  @override
  void initState() {
    super.initState();
    _tgl.text = widget.p38.tanggal;
    _nmr.text = widget.p38.nomor;
    _kasi.text = widget.p38.kasi;
    _nama.text = widget.p38.nama;
    _jbt.text = widget.p38.jabatan;
    getPejabat();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        height: MediaQuery.of(context).size.height / 2,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                labelPadding: EdgeInsets.all(8),
                tabs: [
                  Text('Edit Surat'),
                  Text('Data Pejabat'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                                width: 100, child: Text('Tgl Surat')),
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: const Text(':'),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _tgl,
                                onTap: () async {
                                  var val = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2030),
                                  );
                                  if (val == null) return;
                                  setState(() => _tgl.text = val.formatDB);
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text('Nomor')),
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: const Text(':'),
                            ),
                            Expanded(child: TextFormField(controller: _nmr)),
                          ],
                        ),
                        Container(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text('Kasi')),
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: const Text(':'),
                            ),
                            Expanded(child: TextFormField(controller: _kasi)),
                          ],
                        ),
                        Container(height: 16),
                        Row(
                          children: [
                            const SizedBox(
                                width: 100, child: Text('Nama Kasi')),
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: const Text(':'),
                            ),
                            Expanded(child: TextFormField(controller: _nama)),
                          ],
                        ),
                        Container(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 100, child: Text('Pangkat')),
                            Container(
                              width: 20,
                              alignment: Alignment.center,
                              child: const Text(':'),
                            ),
                            Expanded(child: TextFormField(controller: _jbt)),
                          ],
                        ),
                      ],
                    ),
                    tabPejabat(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: () => save(), child: const Text('Save')),
      ],
    );
  }

  final _pjb = TextEditingController();
  final _nip = TextEditingController();

  Widget tabPejabat() {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(child: TextFormField(controller: _pjb)),
              Container(width: 16),
              Expanded(child: TextFormField(controller: _nip)),
              Container(width: 16),
              TextButton(
                onPressed: () async {
                  if (_pjb.text.isEmpty && _nip.text.isEmpty) return;
                  await P38DB.addPejabat(_pjb.text, _nip.text);
                  await getPejabat();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
        Container(height: 16),
        if (listPjb.isNotEmpty)
          ListView.builder(
            itemCount: listPjb.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              var data = listPjb[i].value as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _nama.text = data['nama'];
                      _jbt.text = data['jabatan'];
                    });
                  },
                  title: Text(data['nama']),
                  subtitle: Text(data['jabatan']),
                  trailing: IconButton(
                    onPressed: () async {
                      await P38DB.deletePejabat(listPjb[i].key as int);
                      await getPejabat();
                    },
                    color: Colors.pink,
                    icon: const Icon(Icons.delete_forever),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  getPejabat() async {
    var get = await P38DB.getPejabat();
    setState(() {
      listPjb = get;
    });
  }

  save() async {
    var data = P38Model(
      tanggal: _tgl.text,
      nomor: _nmr.text,
      kasi: _kasi.text,
      nama: _nama.text,
      jabatan: _jbt.text,
    );
    await P38DB.savedata(data);
    widget.onsave?.call(data);
    if (mounted) Navigator.pop(context);
  }
}
