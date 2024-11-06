import 'package:flutter/material.dart';
import 'package:touna/api/api.dart';
import 'package:touna/model/perkara_model.dart';

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
