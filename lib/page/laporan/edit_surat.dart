import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tgl.text = widget.p38.tanggal;
    _nmr.text = widget.p38.nomor;
    _kasi.text = widget.p38.kasi;
    _nama.text = widget.p38.nama;
    _jbt.text = widget.p38.jabatan;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Tgl Surat')),
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
                const SizedBox(width: 100, child: Text('Nama Kasi')),
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
