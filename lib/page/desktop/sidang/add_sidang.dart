import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/model/perkara_model.dart';
import 'package:touna/util/date.dart';

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
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
