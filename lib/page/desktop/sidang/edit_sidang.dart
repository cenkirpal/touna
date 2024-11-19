import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/model/sidang_model.dart';
import 'package:touna/util/date.dart';

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
                widget.sidang.id!, _date.text, _agenda.text.toUpperCase(),
                ket: widget.sidang.ket, keterangan: _keterangan.text);
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
